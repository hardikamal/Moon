//
//  FirebaseUserAPI.swift
//  Moon
//
//  Created by Evan Noble on 6/29/17.
//  Copyright © 2017 Evan Noble. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import ObjectMapper
import RxOptional
import Alamofire
import AlamofireObjectMapper

struct FirebaseUserAPI: UserAPIType {
    
    struct UserFunction {
        private static let userBaseURL = "https://us-central1-moon-4409e.cloudfunctions.net/"
        
        static let updateProfile = userBaseURL + "updateProfile"
        static let getUserProfile = userBaseURL + "getUserProfile"
        static let getFriends = userBaseURL + "getFriends"
        static let updatePhotoUrls = userBaseURL + "updatePhotoUrls"
        
        static let requestFriend = userBaseURL + "requestFriend"
        static let getFriendRequest = userBaseURL + "getFriendRequest"
        static let declineFriendRequest = userBaseURL + "declineFriendRequest"
        static let acceptFriendRequest = userBaseURL + "acceptFriendRequest"
        
        static let likeSpecial = userBaseURL + "likeSpecial"
        static let likeActivity = userBaseURL + "likeActivity"
        static let likeEvent = userBaseURL + "likeEvent"
        
        static let getActivityLikes = userBaseURL + "getActivityLikes"
        static let getActivityFeed = userBaseURL + "getActivityFeed"
        
        static let goToBar = userBaseURL + "goToBar"
        
        static let hasLikedSpecial = userBaseURL + "hasLikedSpecial"
        static let hasLikedEvent = userBaseURL + "hasLikedEvent"
        static let hasLikedActivity = userBaseURL + "hasLikedActivity"
        
        static let pendingFriendRequest = userBaseURL + "pendingFriendRequest"
        static let areFriends = userBaseURL + "areFriends"
        static let sentFriendRequest = userBaseURL + "sentFriendRequest"
    }
    
}

// MARK: - Relationship Actions
extension FirebaseUserAPI {
    func acceptFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)",
                "friendID": "\(friendID)"
            ]
            let request = Alamofire.request(UserFunction.acceptFriendRequest, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func declineFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)",
                "friendID": "\(friendID)"
            ]
            let request = Alamofire.request(UserFunction.declineFriendRequest, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func requestFriend(userID: String, friendID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)",
                "friendID": "\(friendID)"
            ]
            let request = Alamofire.request(UserFunction.requestFriend, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
// MARK: - Blocking
extension FirebaseUserAPI {
    func blockUser(userID: String, blockID: String) -> Observable<Void> {
        return Observable.empty()
    }
    func unblockUser(userID: String, blockID: String) -> Observable<Void> {
        return Observable.empty()
    }
    func getBlockedUserList(userID: String) -> Observable<[Snapshot]> {
        return Observable.empty()
    }
}
// MARK: - User Info
extension FirebaseUserAPI {
    func getFriends(userID: String) -> Observable<[Snapshot]> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)"
            ]
            let request = Alamofire.request(UserFunction.getFriends, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseArray(completionHandler: { (response: DataResponse<[Snapshot]>) in
                    switch response.result {
                    case .success(let snapshots):
                        observer.onNext(snapshots)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func getUserProfile(userID: String) -> Observable<UserProfile> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)"
            ]
            let request = Alamofire.request(UserFunction.getUserProfile, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseObject(completionHandler: { (response: DataResponse<UserProfile>) in
                    switch response.result {
                    case .success(let profile):
                        observer.onNext(profile)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
        
    }
    
    func update(profile: UserProfile) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = profile.toJSON()
            let request = Alamofire.request(UserFunction.updateProfile, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func getActivityLikes(activityID: String) -> Observable<[Snapshot]> {
        return Observable.empty()
    }
    func getActivityFeed(userID: String) -> Observable<[Activity]> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "id": "\(userID)"
            ]
            let request = Alamofire.request(UserFunction.getActivityFeed, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseArray(completionHandler: { (response: DataResponse<[Activity]>) in
                    switch response.result {
                    case .success(let activities):
                        observer.onNext(activities)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
// MARK: - Actions
extension FirebaseUserAPI {
    func goToBar(userID: String, barID: String, timeStamp: Double) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "id": userID,
                "barId": barID,
                "timeStamp": timeStamp
            ]
            let request = Alamofire.request(UserFunction.goToBar, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func likeActivity(userID: String, activityUserID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": activityUserID
            ]
            let request = Alamofire.request(UserFunction.likeActivity, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func likeSpecial(userID: String, specialID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": specialID
            ]
            let request = Alamofire.request(UserFunction.likeSpecial, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func likeEvent(userID: String, eventID: String) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": eventID
            ]
            let request = Alamofire.request(UserFunction.likeEvent, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .response(completionHandler: {
                    if let e = $0.error {
                        observer.onError(e)
                    } else {
                        observer.onNext()
                        observer.onCompleted()
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }

}
// MARK: - Liked Info
extension FirebaseUserAPI {
    func hasLikedSpecial(userID: String, SpecialID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": SpecialID
            ]
            let request = Alamofire.request(UserFunction.hasLikedSpecial, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func hasLikedEvent(userID: String, EventID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": EventID
            ]
            let request = Alamofire.request(UserFunction.hasLikedEvent, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func hasLikedActivity(userID: String, ActivityID: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": userID,
                "id": ActivityID
            ]
            let request = Alamofire.request(UserFunction.hasLikedActivity, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
// MARK: - Relation Info
extension FirebaseUserAPI {
    func pendingFriendRequest(userID1: String, userID2: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId1": userID1,
                "userId2": userID2
            ]
            let request = Alamofire.request(UserFunction.pendingFriendRequest, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func areFriends(userID1: String, userID2: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId1": userID1,
                "userId2": userID2
            ]
            let request = Alamofire.request(UserFunction.areFriends, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func sentFriendRequest(userID1: String, userID2: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId1": userID1,
                "userId2": userID2
            ]
            let request = Alamofire.request(UserFunction.sentFriendRequest, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let hasLiked = value as? Bool {
                            observer.onNext(hasLiked)
                            observer.onCompleted()
                            
                        } else {
                            observer.onError(UserAPIError.jsonCastingFailure)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func getFriendRequest(userID: String) -> Observable<[Snapshot]> {
        return Observable.create({ (observer) -> Disposable in
            let body: Parameters = [
                "userId": "\(userID)"
            ]
            let request = Alamofire.request(UserFunction.getFriendRequest, method: .post, parameters: body, encoding: JSONEncoding.default, headers: nil)
                .validate()
                .responseArray(completionHandler: { (response: DataResponse<[Snapshot]>) in
                    switch response.result {
                    case .success(let snapshots):
                        observer.onNext(snapshots)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
