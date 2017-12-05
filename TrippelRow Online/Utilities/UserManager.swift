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
    func fetchUsers(completed: @escaping (_ error: StringError?) -> Void) {
        
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
    
    func fetchUserDetails(for userID: String) {
        
        
        
        
    }
    
}
