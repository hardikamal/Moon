//
//  UsersTableViewModel.swift
//  Moon
//
//  Created by Evan Noble on 6/13/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct UsersTableViewModel: BackType {

    // Dependencies
    let sceneCoordinator: SceneCoordinatorType
    
    // Outputs
    var users: Driver<[UserSnapshot]> = {
        let userSnapshot = createFakeUsers().map({
            return UserSnapshot(name: $0.firstName!, id: $0.id!, picture: ($0.pics?[0])!)
        })
        return Observable.just(userSnapshot).asDriver(onErrorJustReturn: [])
    }()
    
    // Inputs
    
    init(coordinator: SceneCoordinatorType) {
        sceneCoordinator = coordinator
    }
}