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

class User {
    
    private var _uid: String!
    private var _email: String!
    
    var uid: String {
        
            if _uid == nil {
                _uid = "1234567"
            }
            
            return _uid
        
    }
    
    var email: String {
        if _email == nil {
            _email = "nil@nothing.com"
        }
        
        return _email
    }
    
    
    init?(signIn email: String, password: String) {
        
        var didComplete = false
        
        signInUser(email: email, password: password) { (completed) in
            didComplete = completed
        }
        
        if !didComplete {
            return nil
        }
        
    }
    
    init?(signUp email: String, password: String) {
        
        var didComplete = false
        
        createUser(email: email, password: password) { (completed) in
            didComplete = completed
        }
        
        if !didComplete {
            return nil
        }
        
    }
    
    
    private func signInUser(email: String, password: String, completed: @escaping (Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil { //Error handling sign in
                
                completed(false)
                
                return
            }
            
            if let user = user {
                
                self._uid = user.uid
                self._email = user.email
                
                completed(true)
                
            } else {
                //Error
                completed(false)
            }
            
            
        }
        
    }
    
    private func createUser(email: String, password: String, completed: @escaping (Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil { //Error handling sign up
                completed(false)
                return
            }
            
            if let user = user {
                
                self._uid = user.uid
                self._email = user.email
                
                completed(true)
                
            } else {
                //Error
                completed(false)
            }
            
        }
        
    }
    
    
}






















