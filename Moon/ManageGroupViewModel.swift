//
//  ManageGroupViewModel.swift
//  Moon
//
//  Created by Evan Noble on 7/23/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import Action
import RxCocoa
import RxSwift

class ManageGroupViewModel: BackType, NetworkingInjected, AuthNetworkingInjected {
    // MARK: - Global
    private let groupID: String
    private let bag = DisposeBag()
    private var dateFormatter: DateFormatter! {
        let df = DateFormatter()
        df.timeStyle = .short
        return df
    }
    private var members = Variable<[GroupMemberSnapshot]>([])
    private var selectedVenueSnapshot = Variable<Snapshot?>(nil)
    private var group = Variable<Group?>(nil)
    
    // MARK: - Dependencies
    var sceneCoordinator: SceneCoordinatorType
    
    // MARK: - Actions
    lazy var onViewProfile: Action<String, Void> = { this in
        return Action {
            let vm = ProfileViewModel(coordinator: this.sceneCoordinator, userID: $0)
            return self.sceneCoordinator.transition(to: Scene.User.profile(vm), type: .popover)
        }
    }(self)
    
    lazy var onViewVenue: Action<String, Void> = { this in
        return Action {
            let vm = BarProfileViewModel(coordinator: this.sceneCoordinator, barID: $0)
            return self.sceneCoordinator.transition(to: Scene.Bar.profile(vm), type: .modal)
        }
    }(self)
    
    // MARK: - Inputs
    var endTime = Variable<Date?>(nil)
    var venueSearchText = PublishSubject<String>()
    var selectedVenue = PublishSubject<SearchSnapshotSectionModel.Item>()
    var reloadMembers = PublishSubject<Void>()
    
    // MARK: - Outputs
    var endTimeString: Observable<String> {
        return endTime.asObservable().filterNil()
            .map({ [unowned self] date in
                self.dateFormatter.string(from: date)
            })
    }
    
    var groupImage: Observable<UIImage> {
        return Observable.just(#imageLiteral(resourceName: "DefaultGroupPic"))
    }
    
    var planInProcess: Observable<Bool> {
        return group.asObservable()
            .map({
                return $0?.plan?.closingTime == nil ? false : true
            })
    }
    
    var displayMembers: Observable<[GroupMemberSectionModel]> {
        return members.asObservable()
            .map({
                [GroupMemberSectionModel(header: "Members", items: $0)]
            })
    }
    
    var displayOptions: Observable<[PlanOptionSectionModel]> {
        return group.asObservable()
            .map({
                $0?.plan?.options
            })
            .filterNil()
            .map({
                [PlanOptionSectionModel(header: "Options", items: $0)]
            })
    }
    
    var venueSearchResults: Observable<[SearchSnapshotSectionModel]> {
        return venueSearchText
            .filter { $0.isNotEmpty }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({
                self.barAPI.searchForBar(searchText: $0)
            })
            .map({
                return [SearchSnapshotSectionModel.snapshotsToSnapshotSectionModel(withTitle: "Venues", snapshots: $0), SearchSnapshotSectionModel.loadingSectionModel()]
            })
    }
    
    var currentPlanBarName: Observable<String?> {
        return group.asObservable().filterNil()
            .map({
                $0.activityInfo?.barName
            })
    }
    
    var currentPlanNumberOfLikes: Observable<String?> {
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
    
    var groupName: Observable<String?> {
        return group.asObservable().filterNil()
            .map({
                $0.name
            })
    }
    
    var selectedVenueText: Observable<String?> {
        return selectedVenueSnapshot.asObservable()
            .map({
                $0?.name
            })
    }
    
    var hasLikedGroupPlan: Observable<Bool> {
        return self.groupAPI.checkGroupStatusEndpoint(userID: self.authAPI.SignedInUserID, groupID: self.groupID)
    }
    
    init(sceneCoordinator: SceneCoordinatorType, groupID: String) {
        self.sceneCoordinator = sceneCoordinator
        self.groupID = groupID
        
        self.groupAPI.getGroup(groupID: groupID).bind(to: group).addDisposableTo(bag)
        Observable.combineLatest(group.asObservable(), reloadMembers)
            .flatMap({ [unowned self] group, _ -> Observable<[GroupMemberSnapshot]> in
                if group?.activityInfo == nil {
                    return self.groupAPI.getGroupMembers(groupID: self.groupID)
                } else {
                    return self.groupAPI.getGroupMembersWithStatus(groupID: self.groupID)
                }
            })
            .bind(to: members)
            .addDisposableTo(bag)
        
        selectedVenue
            .map({ searchResult -> Snapshot? in
                if case let .searchResult(snapshot) = searchResult {
                    return snapshot
                } else {
                    return nil
                }
            })
            .bind(to: selectedVenueSnapshot)
            .addDisposableTo(bag)
        
    }
    
    func onEdit() -> CocoaAction {
        return CocoaAction { [unowned self] in
            let vm = CreateEditGroupViewModel(sceneCoordinator: self.sceneCoordinator, groupID: self.groupID)
            return self.sceneCoordinator.transition(to: Scene.Group.editGroup(vm), type: .push)
        }
    }
    
    func onChangeAttendance() -> CocoaAction {
        return CocoaAction { [unowned self] in
            return self.userAPI.goWithGroup(userID: self.authAPI.SignedInUserID, groupID: self.groupID, timeStamp: Date().timeIntervalSince1970)
        }
    }
    
    func onStartPlan() -> CocoaAction {
        return CocoaAction { [unowned self] in
            guard let endTime = self.endTime.value else {
               return Observable.just()
            }
            return self.groupAPI.startPlan(groupID: self.groupID, endTime: endTime.timeIntervalSince1970)
        }
    }
    
    func onAddVenue() -> CocoaAction {
        return CocoaAction { [unowned self] in
            guard let snapshot = self.selectedVenueSnapshot.value, let selectedBarID = snapshot.id else {
                return Observable.just()
            }
            
            return self.groupAPI.addVenueToPlan(groupID: self.groupID, barID: selectedBarID)
                .do(onNext: {
                    let newOption = PlanOption(snapshot: snapshot)
                    self.group.value?.plan?.options?.append(newOption)
                })
        }
    }
    
    func onVote(barID: String) -> CocoaAction {
        return CocoaAction { [unowned self] in
            return self.groupAPI.placeVote(userID: self.authAPI.SignedInUserID, groupID: self.groupID, barID: barID)
        }
    }
    
    func onLikePlan() -> CocoaAction {
        return CocoaAction { [unowned self] in
            return self.userAPI.likeGroupActivity(userID: self.authAPI.SignedInUserID, groupID: self.groupID)
        }
    }
    
    func onViewPlanBar() -> CocoaAction {
        return CocoaAction { [unowned self] in
            guard let barID = self.group.value?.activityInfo?.barID else {
                return Observable.just()
            }
            let vm = BarProfileViewModel(coordinator: self.sceneCoordinator, barID: barID)
            return self.sceneCoordinator.transition(to: Scene.Bar.profile(vm), type: .modal)
        }
    }
    
    func onViewLikers() -> CocoaAction {
        return CocoaAction {
            //TODO: view likers endpoint should be called here
            Observable.just()
        }
    }

}
