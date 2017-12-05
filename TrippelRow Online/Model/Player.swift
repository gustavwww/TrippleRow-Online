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

protocol PlayerDelegate {
    
    func player(signedIn player: Player)
    func player(created player: Player)
    func friendRequestSent(to: String)
    
    func gotFriendRequest(from: [DBUser], to: Player)
    func acceptedFriendRequest(from: DBUser)
    
    func errorOccured(error: Error)
    
}

extension PlayerDelegate where Self: UIViewController {
    
    func player(signedIn player: Player) {}
    func player(created player: Player) {}
    func friendRequestSent(to: String) {}
    
    //Handling friendRequests
    func gotFriendRequest(from: [DBUser], to: Player) {
        
        if from.count == 0 {
            return
        }
        print(from.count)
        let alertController = UIAlertController(title: "Vänförfrågan mottagen från \(from.last!.displayName!)", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Acceptera", style: .default, handler: { (action) in
            
            to.acceptFriendRequest(from: from.last!, completed: {
                
                self.gotFriendRequest(from: to.friendRequests, to: to)
                
            })
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Neka", style: .destructive, handler: { (action) in
            
            to.declineFriendRequest(from: from.last!)
            self.gotFriendRequest(from: to.friendRequests, to: to)
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func acceptedFriendRequest(from: DBUser) {}
    
    //Handling errors
    func errorOccured(error: Error) {
        removeActivityIndicator()
        
        var errorMsg = error.localizedDescription
        
        if let error = error as? StringError {
            errorMsg = error.stringDescription
        }
        
        let alertController = UIAlertController(title: "Fel", message: errorMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

class Player {
    
    var firUser: User?
    var dbRef: DatabaseReference!
    
    var delegate: PlayerDelegate?
    
    //My properties - Properties regarding Player (UBUser object)
    var friends: [DBUser]!
    var friendRequests: [DBUser]!
    
    init() {
        dbRef = Database.database().reference()
    }
    
    init(firUser: User) {
        dbRef = Database.database().reference()
        
        self.firUser = firUser
        delegate?.player(signedIn: self)
    }
    
    func checkIfOnline() -> Bool {
        
        if let user = Auth.auth().currentUser {
            
            self.firUser = user
            delegate?.player(signedIn: self)
            
            return true
        }
        
        return false
    }
    
    
    func signInUser(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.SignInError))
            }
            
            self.firUser = user
            self.delegate?.player(signedIn: self)
            
        }
        
    }
    
    //Used for new and old facebook accounts
    func signInUser(credential: AuthCredential) { //Setting displayName
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if error != nil {
                self.delegate?.errorOccured(error: StringError(ErrorType.FacebookSignInError))
            }
            
            self.firUser = user
            
            let displayName = (user?.displayName)!
            self.setDisplayName(displayName: displayName)
            
            self.delegate?.player(signedIn: self)
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
            self.dbRef.child("users").child((self.firUser?.uid)!).setValue(["displayName" : displayName])
            
        })
        
    }
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
        } catch {
            delegate?.errorOccured(error: StringError(ErrorType.SignOutError))
        }
    }
    
    func acceptFriendRequest(from request: DBUser, completed: @escaping () -> Void) {
        
        for i in friends {
            
            if i.userID == request.userID {
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
        
        friendsDict[request.userID] = true
        
        dbRef.child("users").child(firUser!.uid).child("friends").setValue(friendsDict)
        
        dbRef.child("users").child(request.userID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            
            if var friends = snapshot.value as? Dictionary<String, Bool> {
                
                self.dbRef.child("users").child(request.userID).child("friends").setValue(friends[self.firUser!.uid] = true)
                
            } else {
                
                let friendsDictForFirstFriend = [self.firUser!.uid : true]
                
                self.dbRef.child("users").child(request.userID).child("friends").setValue(friendsDictForFirstFriend)
                
            }
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
    
    func declineFriendRequest(from request: DBUser) {
        
        
        _ = self.friendRequests.popLast()
        
        var friendRequestsDict = Dictionary<String, Bool>()
        
        for i in friendRequests {
            friendRequestsDict[i.userID] = true
        }
        
        dbRef.child("users").child(firUser!.uid).child("friendRequests").setValue(friendRequestsDict)
    }
    
    //Start listening for incoming changes. - Listening to (gameinvites), friendrequests, friends
    func startObserve() {
        
        if firUser == nil {
            return
        }
        
        dbRef.observe(.value) { (snapshot) in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let users = dict["users"] as? Dictionary<String, AnyObject> {
                    
                    var friendRequestsUID = [String]()
                    var currentFriendsUID = [String]()
                    
                    if let me = users[self.firUser!.uid] as? Dictionary<String, AnyObject> {
                        
                        if let friendRequests = me["friendRequests"] as? Dictionary<String, Bool> {
                            
                            for i in friendRequests {
                                
                                friendRequestsUID.append(i.key)
                                
                            }
                            
                        }
                        
                        if let friends = me["friends"] as? Dictionary<String, Bool> {
                            
                            for i in friends {
                                currentFriendsUID.append(i.key)
                            }
                            print("Vänner hittade: \(currentFriendsUID.count)")
                        }
                        
                    }
                    //Fetching information about friends.
                    var friendRequesters = [DBUser]()
                    var currentFriends = [DBUser]()
                    
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
                        
                    }
                    
                    self.friendRequests = friendRequesters
                    self.friends = currentFriends
                    self.delegate?.gotFriendRequest(from: self.friendRequests, to: self)
                }
                
            }
            
        }
        
    }
    
    func sendFriendRequest(to userID: String) {
        
        if firUser == nil {
            return
        }
        
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
    
}






















