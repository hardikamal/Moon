//
//  BarProfileViewModel.swift
//  Moon
//
//  Created by Evan Noble on 6/8/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import Action
import RxSwift
import RxCocoa

enum UsersGoingType: Int {
    case everyone = 0
    case friends = 1
}

class BarProfileViewModel: ImageNetworkingInjected, NetworkingInjected, BackType, AuthNetworkingInjected, StorageNetworkingInjected {
    
    // Local
    private let bag = DisposeBag()
    private var barInfo: Observable<BarInfo> {
        return bar.map({ bar in
            return BarInfo(website: bar.website, address: bar.address, phoneNumber: bar.phoneNumber)
        })
    }
    private var bar: Observable<BarProfile> {
        return self.barAPI.getBarInfo(barID: barID)
    }
    private let barID: String!
    
    // Dependencies
    let sceneCoordinator: SceneCoordinatorType
    
    // Inputs
    var selectedUserIndex = BehaviorSubject<UsersGoingType>(value: .everyone)
    var reloadDisplayUsers = PublishSubject<Void>()
    
    // Outputs
    var barPics = Variable<[UIImage]>([])
    var barName: Observable<String> {
        return bar.map({ $0.name ?? "No Name" })
    }
    var displayedUsers = Variable<[Activity]>([])
    var specials = Variable<[Special]>([])
    var events = Variable<[BarEvent]>([])
    
    init(coordinator: SceneCoordinatorType, barID: String) {
        self.sceneCoordinator = coordinator
        self.barID = barID
        
        self.barAPI.getBarEvents(barID: barID).catchErrorJustReturn([]).bind(to: events).addDisposableTo(bag)
        self.barAPI.getBarSpecials(barID: barID).catchErrorJustReturn([]).bind(to: specials).addDisposableTo(bag)
    
        
        Observable.of(["pic1.jpg", "pic2.jpg", "pic3.jpg", "pic4.jpg"]).flatMap({ [unowned self] picNames in
            return Observable.from(picNames).flatMap({
                return self.storageAPI.getBarPictureDownloadUrlForBar(id: self.barID, picName: $0).filterNil().flatMap({ [unowned self] url in
                    return self.photoService.getImageFor(url: url)
                })
            }).toArray()
        }).catchErrorJustReturn([]).bind(to: barPics).addDisposableTo(bag)

        let peopleGoing = reloadDisplayUsers.flatMap({ [unowned self] _ in
           return self.barAPI.getBarPeople(barID: barID).catchErrorJustReturn([])
        })
        let friendsGoing = reloadDisplayUsers.flatMap({ [unowned self] _ in
           return self.barAPI.getBarFriends(barID: self.barID, userID: self.authAPI.SignedInUserID).catchErrorJustReturn([])
        })
        
         Observable.combineLatest(peopleGoing, friendsGoing, selectedUserIndex)
            .map({ (people, friends, userType) -> [Activity] in
                switch userType {
                case .everyone:
                    return people
                case .friends:
                    return friends
                }
            })
            .bind(to: displayedUsers)
            .addDisposableTo(bag)
        
    }
    
    func onShowInfo() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = BarInfoViewModel(coordinator: self.sceneCoordinator, barInfo: self.barInfo)
            return self.sceneCoordinator.transition(to: Scene.Bar.info(vm), type: .popover)
        }
    }
    
    func onAttendBar() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            return self.userAPI.goToBar(userID: self.authAPI.SignedInUserID, barID: self.barID, timeStamp: Date().timeIntervalSince1970)
        }
    }
    
    func onShowProfile(userID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = ProfileViewModel(coordinator: self.sceneCoordinator, userID: userID)
            return self.sceneCoordinator.transition(to: Scene.User.profile(vm), type: .popover)
        }
    }
    
    func onViewLikers(eventID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = UsersTableViewModel(coordinator: self.sceneCoordinator, sourceID: .event(id: eventID))
            return self.sceneCoordinator.transition(to: Scene.User.usersTable(vm), type: .modal)
        }
    }
    
    func onViewLikers(specialID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = UsersTableViewModel(coordinator: self.sceneCoordinator, sourceID: .special(id: specialID))
            return self.sceneCoordinator.transition(to: Scene.User.usersTable(vm), type: .modal)
        }
    }
    
    func onViewLikers(userID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = UsersTableViewModel(coordinator: self.sceneCoordinator, sourceID: .activity(id: userID))
            return self.sceneCoordinator.transition(to: Scene.User.usersTable(vm), type: .modal)
        }
    }
    
    func onLikeActivity(userID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            return self.userAPI.likeActivity(userID: self.authAPI.SignedInUserID, activityUserID: userID)
        }
    }
    
    func onLikeEvent(eventID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            return self.userAPI.likeEvent(userID: self.authAPI.SignedInUserID, eventID: eventID)
        }
    }
    
    func onShareEvent(eventID: String, barID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            //TODO: add api call
            print("Share event needs implementation")
            return Observable.empty()
        }
    }
    
    func onLikeSpecial(specialID: String) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            return self.userAPI.likeSpecial(userID: self.authAPI.SignedInUserID, specialID: specialID)
        }
    }
    
    func hasLikedSpecial(specialID: String) -> Action<Void, Bool> {
        return Action<Void, Bool> { [unowned self] _ in
            return self.userAPI.hasLikedSpecial(userID: self.authAPI.SignedInUserID, SpecialID: specialID)
        }
    }
    
    func hasLikedEvent(eventID: String) -> Action<Void, Bool> {
        return Action<Void, Bool> { [unowned self] _ in
            return self.userAPI.hasLikedEvent(userID: self.authAPI.SignedInUserID, EventID: eventID)
        }
    }
    
    func hasLikedActivity(activityID: String) -> Action<Void, Bool> {
        return Action<Void, Bool> { [unowned self] _ in
            return self.userAPI.hasLikedActivity(userID: self.authAPI.SignedInUserID, ActivityID: activityID)
        }
    }

}
