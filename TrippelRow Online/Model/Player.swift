//
//  User.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-21.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit


class Player {
    
    //firUser should never be nil while using this class.
    var firUser: User?
    var dbRef: DatabaseReference!
    
    var delegate: PlayerDelegate?
    
    //My properties - Properties regarding Player (UBUser object)
    var friends: [DBUser]!
    var friendRequests: [DBUser]!
    
    var gameIDs: [String]!
    var gameRequests: [DBUser]!
    
    init() {
        dbRef = Database.database().reference()
    }
    
    init(firUser: User) {
        dbRef = Database.database().reference()
        
        self.firUser = firUser
        
        self.setStatus(status: .Online)
        
        delegate?.player(signedIn: self)
    }
    
    func checkIfSignedIn() -> Bool {
        
        if let user = Auth.auth().currentUser {
            
            self.firUser = user
            
            setStatus(status: .Online)
            
            delegate?.player(signedIn: self)
            
            return true
        }
        
        return false
    }
    
    func hasBeenOnlineBefore(completed: @escaping (Bool) -> Void) {
        
        dbRef.child("users").child(firUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let hasBeenOnlineBefore = dict["hasBeenOnlineBefore"] as? Bool {
                    
                    if hasBeenOnlineBefore {
                        
                        completed(true)
                        return
                    }
                    completed(false)
                } else {
                    completed(false)
                }
                
            } else {
                completed(false)
            }
            
        }
        
    }
    
    
    func signInUser(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.SignInError))
            }
            
            self.firUser = user
            
            self.setStatus(status: .Online)
            
            self.delegate?.player(signedIn: self)
            
        }
        
    }
    
    //Used for new and old facebook accounts
    func signInUser(credential: AuthCredential) { //Setting displayName
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.FacebookSignInError))
                return
            }
            
            self.firUser = user
            
            self.hasBeenOnlineBefore(completed: { (hasBeenOnline) in
                
                if !hasBeenOnline {
                    
                    let longName = self.firUser!.displayName!
                    
                    var displayName: String!
                    
                    if let index = longName.range(of: " ")?.lowerBound {
                        
                        displayName = String(longName.prefix(upTo: index))
                        
                        if let index2 = longName.range(of: " ")?.upperBound {
                            
                            displayName.append(String(longName.suffix(from: index2).first!))
                            
                        }
                        
                        for _ in 0...4 {
                            
                            let suffix = arc4random_uniform(10)
                            
                            displayName.append(String(suffix))
                            
                        }
                        
                        print(displayName)
                    }
                    
                    self.setDisplayName(displayName: displayName)
                    self.setDBEmail(email: self.firUser!.email!)
                    
                    self.setStatus(status: .Online)
                    
                    self.dbRef.child("users").child(self.firUser!.uid).child("hasBeenOnlineBefore").setValue(true)
                    
                    self.delegate?.player(signedIn: self)
                    
                } else {
                    
                    self.delegate?.player(signedIn: self)
                    
                }
                
            })
            
        }
        
    }
    
    //Used for new accounts
    func createUser(email: String, password: String, displayName: String) { //Setting displayName
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: error!)
                return
            }
            
            self.firUser = user
            
            self.setDisplayName(displayName: displayName)
            self.setDBEmail(email: email)
            
            self.setStatus(status: .Online)
            self.delegate?.player(created: self)
        }
        
    }
    
    func setDisplayName(displayName: String) {
        
        let changeRequest = self.firUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { (error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.DisplayNameChangeError))
                return
            }
            self.dbRef.child("users").child((self.firUser?.uid)!).child("displayName").setValue(displayName)
            
        })
        
    }
    
    func setDBEmail(email: String) {
        
        dbRef.child("users").child(firUser!.uid).child("email").setValue(email)
        
    }
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
        } catch {
            delegate?.errorOccured(error: StringError(ErrorType.SignOutError))
        }
        
        setStatus(status: .Offline)
        
    }
    
    func setStatus(status: PlayerStatus) {
        
        if status == .Online {
            dbRef.child("users").child(firUser!.uid).child("status").setValue("online")
        } else if status == .Offline {
            dbRef.child("users").child(firUser!.uid).child("status").setValue("offline")
        }
        
    }
    
    func getStatus(completed: @escaping (PlayerStatus) -> Void) {
        
        dbRef.child("users").child(firUser!.uid).child("status").observeSingleEvent(of: .value) { (snapshot) in
            
            if let value = snapshot.value as? String {
                
                if value == "online" {
                    completed(.Online)
                } else {
                    completed(.Offline)
                }
                
            }
            
        }
        
    }
    
    func acceptLastFriendRequest(completed: @escaping () -> Void) {
        
        for i in friends {
            
            if i.userID == friendRequests.last!.userID {
                //Friend already exists
                
                _ = self.friendRequests.popLast()
                
                completed()
                return
            }
            
        }
        
        //Adding friend to both players
        
        var friendsDict = Dictionary<String, Bool>()
        
        for i in friends {
            friendsDict[i.userID] = true
        }
        
        friendsDict[friendRequests.last!.userID] = true
        
        dbRef.child("users").child(firUser!.uid).child("friends").setValue(friendsDict)
        
        dbRef.child("users").child(friendRequests.last!.userID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            
            if var friends = snapshot.value as? Dictionary<String, Bool> {
                
                self.dbRef.child("users").child(self.friendRequests.last!.userID).child("friends").setValue(friends[self.firUser!.uid] = true)
                
            } else {
                
                let friendsDictForFirstFriend = [self.firUser!.uid : true]
                
                self.dbRef.child("users").child(self.friendRequests.last!.userID).child("friends").setValue(friendsDictForFirstFriend)
                
            }
            let request = self.friendRequests.last!
            _ = self.friendRequests.popLast()
            
            var friendRequestsDict = Dictionary<String, Bool>()
            
            for i in self.friendRequests {
                friendRequestsDict[i.userID] = true
            }
            
            //Removing friendRequest - this is calling the observe function and makes sure friendRequests property is up-to-date.
            self.dbRef.child("users").child(self.firUser!.uid).child("friendRequests").setValue(friendRequestsDict)
            self.delegate?.acceptedFriendRequest(from: request)
            
            completed()
        }
        
    }
    
    func declineLastFriendRequest() {
        
        
        _ = self.friendRequests.popLast()
        
        var friendRequestsDict = Dictionary<String, Bool>()
        
        for i in friendRequests {
            friendRequestsDict[i.userID] = true
        }
        
        dbRef.child("users").child(firUser!.uid).child("friendRequests").setValue(friendRequestsDict)
    }
    
    //Start listening for incoming changes. - Listening to (gameinvites), friendrequests, friends, games
    func startObserve() {
        
        if firUser == nil {
            return
        }
        
        dbRef.child("users").child(firUser!.uid).observe(.value) { (snapshot) in
            
            if let me = snapshot.value as? Dictionary<String, AnyObject> {
                    
            var friendRequestsUID = [String]()
                    
            var currentFriendsUID = [String]()
                    
            var gameRequestsUID = [String]()
                
                if let friendRequests = me["friendRequests"] as? Dictionary<String, Bool> {
                            
                    for i in friendRequests {
                                
                        friendRequestsUID.append(i.key)
                                
                    }
                            
                }
                        
                if let friends = me["friends"] as? Dictionary<String, Bool> {
                            
                    for i in friends {
                                
                        currentFriendsUID.append(i.key)
                            
                    }
                    
                }
                        
                if let gameRequests = me["gameRequests"] as? Dictionary<String, Bool> {
                            
                    for i in gameRequests {
                                
                        gameRequestsUID.append(i.key)
                                
                    }
                            
                }
                
                self.dbRef.observeSingleEvent(of: .value, with: { (snapshotDB) in
                    
                    if let dict = snapshotDB.value as? Dictionary<String, AnyObject> {
                        
                        if let users = dict["users"] as? Dictionary<String, AnyObject> {
                            
                            //Fetching users information
                            var friendRequesters = [DBUser]()
                            
                            var currentFriends = [DBUser]()
                            
                            var gameRequesters = [DBUser]()
                            
                            for i in users {
                                
                                if friendRequestsUID.contains(i.key) {
                                    let dbUser = DBUser(i.key)
                                    
                                    if let displayName = i.value["displayName"] as? String {
                                        
                                        dbUser.displayName = displayName
                                        friendRequesters.append(dbUser)
                                    }
                                    
                                }
                                
                                if currentFriendsUID.contains(i.key) {
                                    let dbUser = DBUser(i.key)
                                    
                                    if let displayName = i.value["displayName"] as? String {
                                        
                                        dbUser.displayName = displayName
                                        currentFriends.append(dbUser)
                                    }
                                    
                                }
                                
                                if gameRequestsUID.contains(i.key) {
                                    let dbUser = DBUser(i.key)
                                    
                                    if let displayName = i.value["displayName"] as? String {
                                        
                                        dbUser.displayName = displayName
                                        gameRequesters.append(dbUser)
                                    }
                                    
                                }
                                
                            }
                            self.friends = currentFriends
                            
                            self.friendRequests = friendRequesters
                            self.gameRequests = gameRequesters
                            
                            self.delegate?.gotFriendRequest(from: self.friendRequests, to: self)
                            self.delegate?.gotGameRequest(from: self.gameRequests, to: self)
                        }
                            
                        if let games = dict["games"] as? Dictionary<String, AnyObject> {
                            
                            for game in games {
                                
                                if let gameDict = game.value as? Dictionary<String, AnyObject> {
                                    
                                    for i in gameDict {
                                        
                                        if let host = i.value["host"] as? String {
                                            if host == self.firUser!.uid {
                                                self.gameIDs.append(game.key)
                                            }
                                        }
                                        
                                        if let player = i.value["player"] as? String {
                                            if player == self.firUser!.uid {
                                                self.gameIDs.append(game.key)
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        self.delegate?.playerObserverRan(player: self)
                    }
                    
                })
                
            }
                    
        }
        
    }

    
    func sendFriendRequest(to userID: String) {
        
        dbRef.child("users").child(userID).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            
            var requests = Dictionary<String, Bool>()
            
            if let friendRequests = snapshot.value as? Dictionary<String, Bool> {
                
                for i in friendRequests {
                    requests[i.key] = true
                }
                
            }
            
            if let _ = requests[self.firUser!.uid] {
                
                self.delegate?.errorOccured(error: StringError(ErrorType.FriendRequestAlreadySent))
                
                return
            }
            
            requests[self.firUser!.uid] = true
            
            self.dbRef.child("users").child(userID).child("friendRequests").setValue(requests)
            self.delegate?.friendRequestSent(to: userID)
            
        }
        
        
    }
    
    func sendGameRequest(to userID: String) {
        
        dbRef.child("users").child(userID).child("gameRequests").observeSingleEvent(of: .value) { (snapshot) in
            
            var requests = Dictionary<String, Bool>()
            
            if let gameRequests = snapshot.value as? Dictionary<String, Bool> {
                
                for i in gameRequests {
                    requests[i.key] = true
                }
                
            }
            
            requests[self.firUser!.uid] = true
            
            self.dbRef.child("users").child(userID).child("gameRequests").setValue(requests)
            self.delegate?.gameRequestSent(to: userID)
        }
        
    }
    
    func declineLastGameRequest() {
        
        _ = gameRequests.popLast()
        
        var gameRequestsDict = Dictionary<String, Bool>()
        
        for i in gameRequests {
            gameRequestsDict[i.userID] = true
        }
        
        dbRef.child("users").child(firUser!.uid).child("gameRequests").setValue(gameRequestsDict)
    }
    
    func acceptLastGameRequest() {
        
        GameManager().createGame(hostUID: gameRequests.last!.userID, playerUID: firUser!.uid)
        
        _ = gameRequests.popLast()
        
        var gameRequestsDict = Dictionary<String, Bool>()
        
        for i in gameRequests {
            gameRequestsDict[i.userID] = true
        }
        
        dbRef.child("users").child(firUser!.uid).child("gameRequests").setValue(gameRequestsDict)
    }
    
}






















