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
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.SignInError))
                return
            }
            
            if result == nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.SignInError))
                return
            }
            
            self.firUser = result!.user
            
            self.setStatus(status: .Online)
            
            self.delegate?.player(signedIn: self)
            
        }
        
    }
    
    //Used for new and old facebook accounts
    func signInUser(credential: AuthCredential) { //Setting displayName
        
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.FacebookSignInError))
                return
            }
            
            if result == nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.FacebookSignInError))
                return
            }
            
            self.firUser = result?.user
            
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
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: error!)
                return
            }
            
            if result == nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.CreateUserError))
                return
            }
            
            self.firUser = result!.user
            
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
        
        if Auth.auth().currentUser != nil {
            setStatus(status: .Offline)
        }
        
    }
    
    func setStatus(status: PlayerStatus) {
        
        if status == .Online {
            dbRef.child("users").child(firUser!.uid).child("status").setValue("online")
        } else {
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
    
    func acceptLastFriendRequest() {
        
        if friendRequests.isEmpty {
            return
        }
        
        for i in friends {
            
            if i.userID == friendRequests.last!.userID {
                //Friend already exists
                
                _ = self.friendRequests.popLast()
                return
            }
            
        }
        
        //Adding friend to both players
        
        dbRef.child("users").child(firUser!.uid).child("friends").child(friendRequests.last!.userID).setValue(true)
        
        dbRef.child("users").child(friendRequests.last!.userID).child("friends").child(firUser!.uid).setValue(true)
        
        //Removing request
        
        dbRef.child("users").child(firUser!.uid).child("friendRequests").child(friendRequests.last!.userID).removeValue()
        
        _ = self.friendRequests.popLast()
        
    }
    
    func declineLastFriendRequest() {
        
        if friendRequests.last == nil {
            return
        }
        
        dbRef.child("users").child(firUser!.uid).child("friendRequests").child(friendRequests.last!.userID).removeValue()
        
        _ = friendRequests.popLast()
        
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
                            
                            self.gameIDs = [String]()
                            
                            for game in games {
                                
                                if let gameDict = game.value as? Dictionary<String, AnyObject> {
                                    print("Found gameDict")
                                        
                                        if let host = gameDict["host"] as? String {
                                            if host == self.firUser!.uid {
                                                self.gameIDs.append(game.key); print("Host!")
                                            }
                                        }
                                        
                                        if let player = gameDict["player"] as? String {
                                            if player == self.firUser!.uid {
                                                self.gameIDs.append(game.key); print("Player!")
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
        
        dbRef.child("users").child(userID).child("friendRequests").child(firUser!.uid).setValue(true)
        
        delegate?.friendRequestSent(to: userID)
        
    }
    
    func sendGameRequest(to userID: String) {
        
        dbRef.child("users").child(userID).child("gameRequests").child(firUser!.uid).setValue(true)
        
        delegate?.gameRequestSent(to: userID)
        
    }
    
    func declineLastGameRequest() {
        
        if gameRequests.last == nil {
            return
        }
        
        dbRef.child("users").child(firUser!.uid).child("gameRequests").child(gameRequests.last!.userID).removeValue()
        
        _ = gameRequests.popLast()
    }
    
    func acceptLastGameRequest() {
        
        if gameRequests.last == nil {
            return
        }
        
        GameManager().createGame(hostUID: gameRequests.last!.userID, playerUID: firUser!.uid)
        
        dbRef.child("users").child(firUser!.uid).child("gameRequests").child(gameRequests.last!.userID).removeValue()
        
        _ = gameRequests.popLast()
    }
    
}






















