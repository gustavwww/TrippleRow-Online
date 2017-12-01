//
//  RegistrationManeger.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-01.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct RegistrationManager {
    
    var username: String!
    var password: String!
    var email: String!
    
    var passVerification: String!
    
    init(username: String, password: String, passVerification: String, email: String) {
        
        self.username = username; self.password = password; self.passVerification = passVerification; self.email = email
        
    }
    
    init() {}
    
    func displayNameIsValid(username: String,isValid valid: @escaping (Bool?, StringError?) -> ()) {
        
        let ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                let amountOfUsers = dict.keys.count
                var amountOfValids = 0
                
                for i in dict {
                    
                    if let displayName = i.value["displayName"] as? String {
                        
                        if displayName == username {
                            valid(false, nil)
                            return
                        } else {
                            amountOfValids += 1
                            
                            if amountOfValids == amountOfUsers {
                                valid(true, nil)
                                return
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                valid(nil, StringError(ErrorType.CreateUserError))
            }
            
        }
        
    }
    
    
    //Checkfields algorythm, not yet working..
    func checkFields(_ completed: @escaping (StringError?) -> Void) {
        
        if fieldsAreEmpty().0 {
            
            completed(fieldsAreEmpty().1)
            return
        }
        
        if !hasProperLength().0 {
            
            completed(hasProperLength().1)
            return
        }
        
        if !hasProperContents().0 {
            
            completed(hasProperContents().1)
            return
        }
        
        displayNameIsValid(username: username) { (isValid, error) in
            
            if error != nil {
                
                completed(error!)
                return
            }
            
            if !isValid! {
                
                completed(StringError(ErrorType.UsernameAlreadyTaken))
                return
            }
            
            completed(nil)
        }
        
    }
    
    private func fieldsAreEmpty() -> (Bool, StringError?) {
        
        if username.isEmpty || password.isEmpty || passVerification.isEmpty || email.isEmpty {
            
            
            return (true, StringError(ErrorType.FillEveryField))
        }
        
        return (false, nil)
    }
    
    private func hasProperLength() -> (Bool, StringError?) {
        
        if username.count < 4 || username.count > 15 {
            
            return (false, StringError(ErrorType.UsernameInvalidLength))
        }
        
        if password.count < 6 {
            
            return (false, StringError(ErrorType.PasswordInvalidLength))
        }
        
        if password != passVerification {
            
            return (false, StringError(ErrorType.PasswordDoesntMatch))
        }
        
        return (true, nil)
    }
    
    private func hasProperContents() -> (Bool, StringError?) {
        
        if email.lowercased().range(of: "@") == nil || email.lowercased().range(of: ".") == nil {
            
            return (false, StringError(ErrorType.InvalidEmail))
        }
        
        
        return (true, nil)
    }
    
}
