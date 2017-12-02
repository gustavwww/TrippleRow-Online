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
    
    func gotFriendRequest(from: [DBUser], to: Player) {
        
        if to.friendRequests.count == 0 {
            return
        }
        
        let alertController = UIAlertController(title: "Vänförfrågan mottagen från \(from.last!.displayName!)", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Acceptera", style: .default, handler: { (action) in
            
            to.acceptFriendRequest(from: from.last!)
            
            _ = to.friendRequests.popLast()
            self.gotFriendRequest(from: to.friendRequests, to: to)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Neka", style: .destructive, handler: { (action) in
            
            _ = to.friendRequests.popLast()
            self.gotFriendRequest(from: to.friendRequests, to: to)
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func acceptedFriendRequest(from: DBUser) {}
    
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
    
    //Global properties - Properties regarding everyone (UBUser object)
    var allUsers: [DBUser]!
    
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
    
    func acceptFriendRequest(from request: DBUser) { //Gör om, god natt :)
        
        for i in friendRequests {
            
            if i.userID == request.userID {
                
                return
            }
            
        }
        
        var currentFriends = friends
        
        
        dbRef.child("users").child(firUser!.uid).child("friends").setValue(friends)
        
        dbRef.child("users").child(request.userID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            
            if var friends = snapshot.value as? Dictionary<String, Bool> {
                
                self.dbRef.child("users").child(request.userID).child("friends").setValue(friends[self.firUser!.uid] = true)
                
                self.delegate?.acceptedFriendRequest(from: request)
            }
            
        }
        
        
    }
    
    //Start listening for incoming changes. - Listening to (gameinvites), friendrequests (CURRENTLY WORKING HERE)
    func startObserve() {
        
        if firUser == nil {
            return
        }
        
        dbRef.observe(.value) { (snapshot) in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                print("Observe running..")
                if let users = dict["users"] as? Dictionary<String, AnyObject> {
                    
                    var friendRequestsUID = [String]()
                    
                    if let me = users[self.firUser!.uid] as? Dictionary<String, AnyObject> {
                        print("Found me")
                        if let friendRequests = me["friendRequests"] as? Dictionary<String, Bool> {
                            print("Found friendRequests")
                            for i in friendRequests {
                                print("Found request: \(i.key)")
                                friendRequestsUID.append(i.key)
                                
                            }
                            
                        }
                        
                    }
                    //Back at users
                    var friendRequesters = [DBUser]()
                    
                    for i in users {
                        
                        if friendRequestsUID.contains(i.key) {
                            let dbUser = DBUser(i.key)
                            
                            if let displayName = i.value["displayName"] as? String {
                                
                                dbUser.displayName = displayName
                                friendRequesters.append(dbUser)
                            }
                            
                        }
                        
                    }
                    print("gotFriendRequest Called")
                    self.friendRequests = friendRequesters
                    self.delegate?.gotFriendRequest(from: friendRequesters, to: self)
                }
                
            }
            
        }
        
    }
    
    //Sending a single get request.
    func singleObserve(completed: @escaping () -> Void) { //NOT DONE
        
        if firUser == nil {
            return
        }
        
        dbRef.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            self.allUsers = [DBUser]()
            self.friends = [DBUser]()
            
            if let users = snapshot.value as? Dictionary<String, AnyObject> {
                
                //Everyone's fetch - Add whatever you need.
                //Fetching user column, i represetns a user.
                for i in users {
                    let dbUser = DBUser(i.key)
                    
                    if let displayName = i.value["displayName"] as? String {
                        
                        dbUser.displayName = displayName
                    }
                    self.allUsers.append(dbUser)
                }
                
                //Single player fetching - Add whatever you need.
                
                var friendsUID = [String]()
                
                if let me = users[(self.firUser?.uid)!] as? Dictionary<String, AnyObject> {
                    
                    if let friends = me["friends"] as? Dictionary<String, Bool> {
                        
                        for i in friends.keys {
                            
                            friendsUID.append(i)
                            
                        }
                        
                    }
                    
                }
                //Back to user fetching.
                for i in users {
                    
                    if friendsUID.contains(i.key) {
                        let dbUser = DBUser(i.key)
                        
                        if let displayName = i.value["displayName"] as? String {
                            
                            dbUser.displayName = displayName
                        }
                        self.friends.append(dbUser)
                    }
                    
                }
                completed()
            } else {
                self.delegate?.errorOccured(error: StringError(ErrorType.SingleObserveError))
            }
            
        }
        
    }
    
    func sendFriendRequest(to userID: String) {
        
        if firUser == nil {
            return
        }
        
        dbRef.child("users").child(userID).child("friendRequests").observeSingleEvent(of: .value) { (snapshot) in
            
            if let friendRequests = snapshot.value as? Dictionary<String, Bool> {
                
                var requests = [String]()
                
                for i in friendRequests {
                    requests.append(i.key)
                }
                
                if requests.contains(userID) {
                    
                    self.delegate?.errorOccured(error: StringError(ErrorType.FriendRequestAlreadySent))
                    
                    return
                }
                
                self.dbRef.child("users").child(userID).child("friendRequests").setValue(requests.append((self.firUser?.uid)!))
                
                self.delegate?.friendRequestSent(to: userID)
                
            } else {
                
                self.delegate?.errorOccured(error: StringError(ErrorType.SendFriendRequestError))
                
            }
            
        }
        
        
    }
    
}






















