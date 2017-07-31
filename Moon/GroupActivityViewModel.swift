//
//  GroupActivityViewModel.swift
//  Moon
//
//  Created by Evan Noble on 7/23/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import Action
import RxSwift

struct GroupActivityViewModel: BackType, NetworkingInjected, StorageNetworkingInjected, ImageNetworkingInjected, AuthNetworkingInjected {
    // MARK: - Global
    private let bag = DisposeBag()
    private let groupID: String
    private var group = Variable<Group?>(nil)
    private var hasLikedPlan = Variable<Bool>(false)
    
    // MARK: - Dependencies
    var sceneCoordinator: SceneCoordinatorType
    
    // MARK: - Actions
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    var groupName: Observable<String?> {
        return group.asObservable().filterNil().map { $0.name }
    }
    
    var barName: Observable<String?> {
        return group.asObservable().filterNil().map { $0.activityInfo?.barName }
    }
    
    var numberOfLikes: Observable<String> {
        return group.asObservable()
            .map({
                $0?.activityInfo?.numberOfLikes
            })
            .filterNil()
            .map({
                "\($0)"
            })
            .startWith("0")
    }
    
    var hasLikedGroupPlan: Observable<Bool> {
        return self.hasLikedPlan.asObservable()
    }
    
    var displayUsers: Observable<[SnapshotSectionModel]> {
        return self.groupAPI.getGroupMembersWithStatus(groupID: groupID)
            .map({
                $0.filter({
                  $0.isGoing == true
                })
            })
            .map({
                return [SnapshotSectionModel(header: "Users", items: $0)]
            })
    }
    
    var groupPicture: Observable<UIImage> {
        return Observable.just(#imageLiteral(resourceName: "DefaultGroupPic"))
    }
    
    init(sceneCoordinator: SceneCoordinatorType, groupID: String) {
        self.sceneCoordinator = sceneCoordinator
        self.groupID = groupID
        
        self.groupAPI.getGroup(groupID: groupID).bind(to: group).addDisposableTo(bag)
        //TODO: use has liked endpoint to update heart when view is loaded
        //self.groupAPI.checkGroupStatusEndpoint(userID: self.authAPI.SignedInUserID, groupID: self.groupID).bind(to: hasLikedPlan).addDisposableTo(bag)
    }
    
    func onShowProfile(userID: String) -> CocoaAction {
        return CocoaAction {
            let vm = ProfileViewModel(coordinator: self.sceneCoordinator, userID: userID)
            return self.sceneCoordinator.transition(to: Scene.User.profile(vm), type: .popover)
        }
    }
    
    func hasLikedActivity(activityID: String) -> Action<Void, Bool> {
        return Action<Void, Bool> {
            return self.userAPI.hasLikedActivity(userID: self.authAPI.SignedInUserID, ActivityID: activityID)
        }
    }
    
    func onLikeUserActivity(userID: String) -> CocoaAction {
        return CocoaAction {
            return self.userAPI.likeActivity(userID: self.authAPI.SignedInUserID, activityUserID: userID)
        }
    }
    
    func onViewUserActivityLikes(userID: String) -> CocoaAction {
        return CocoaAction {
            //TODO: view likers
            return Observable.just()
        }
    }
    
    func onLikeGroupActivity() -> CocoaAction {
        return CocoaAction {
            return self.userAPI.likeGroupActivity(userID: self.authAPI.SignedInUserID, groupID: self.groupID)
                .do(onSubscribe: {
                    guard let numLikes = self.group.value?.activityInfo?.numberOfLikes else {
                        return
                    }
                    let newNum = self.hasLikedPlan.value ? numLikes - 1 : numLikes + 1
                    self.group.value?.activityInfo?.numberOfLikes = newNum
                    self.hasLikedPlan.value = !self.hasLikedPlan.value
                })
        }
    }
    
    func onViewGroupLikers() -> CocoaAction {
        return CocoaAction {
            //TODO: Implement functionality
            return Observable.just()
        }
    }
    
    func onViewBar() -> CocoaAction {
        return CocoaAction {
            guard let barID = self.group.value?.activityInfo?.barID else {
                return Observable.just()
            }
            let vm = BarProfileViewModel(coordinator: self.sceneCoordinator, barID: barID)
            return self.sceneCoordinator.transition(to: Scene.Bar.profile(vm), type: .modal)
        }
    }
    
    func getProfileImage(id: String) -> Action<Void, UIImage> {
        return Action(workFactory: {_ in
            return self.storageAPI.getProfilePictureDownloadUrlForUser(id: id, picName: "pic1.jpg")
                .errorOnNil()
                .flatMap({
                    self.photoService.getImageFor(url: $0)
                })
                .catchErrorJustReturn(#imageLiteral(resourceName: "DefaultProfilePic"))
        })
    }
}
