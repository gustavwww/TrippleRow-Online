//
//  UserManager.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-05.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class UserManager {
    
    var allUsers: [DBUser]?
    
    var dbRef: DatabaseReference
    
    init() {
        dbRef = Database.database().reference()
    }
    
    //Used for overall fetching
    func fetchUsers(completed: @escaping (StringError?) -> Void) {
        
        dbRef.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            self.allUsers = [DBUser]()
            
            if let users = snapshot.value as? Dictionary<String, AnyObject> {

                for i in users {
                    let dbUser = DBUser(i.key)
                    
                    if let displayName = i.value["displayName"] as? String {
                        
                        dbUser.displayName = displayName
                    }
                    self.allUsers?.append(dbUser)
                }
                
                completed(nil)
            } else {
                
                completed(StringError(ErrorType.SingleObserveError))
                
            }
            
        }
        
    }
    
    //Used for specific user fetching
    func fetchUserDetails(userID: String, completed: @escaping (DetailedUser, StringError?) -> Void) {
        
        dbRef.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                let detailedUser = DetailedUser()
                
                detailedUser.userID = snapshot.key
                
                if let displayName = dict["displayName"] as? String {
                    detailedUser.displayName = displayName
                }
                
                if let email = dict["email"] as? String {
                    detailedUser.email = email
                }
                
                if let status = dict["status"] as? String {
                    
                    if status == "online" {
                        detailedUser.status = .Online
                    } else {
                        detailedUser.status = .Offline
                    }
                    
                }
                
                completed(detailedUser, nil)
                
            } else {
                completed(DetailedUser(), StringError(ErrorType.FetchUserError))
            }
            
        }
        
        
    }
    
}
