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

class MyUser { //Not yet done, requires initializers
    
    var firUser: User?
    
    
    init(firUser: User) {
        self.firUser = firUser
    }
    
    
    func signInUser(email: String, password: String, completed: @escaping (Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil { //Error handling sign in
                
                print(String(describing: error?.localizedDescription))
                completed(false)
                
                return
            }
            
            self.firUser = user
            
            completed(true)
        }
        
    }
    
    func createUser(email: String, password: String, completed: @escaping (Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil { //Error handling sign up
                completed(false)
                return
            }
            
            self.firUser = user
            
            completed(true)
            
        }
        
    }
    
    func createUser(credential: AuthCredential, completed: @escaping (Bool) -> Void) {
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if error != nil { //Error signing in with FaceBook
                
                completed(false)
                return
            }
            
            self.firUser = user
            
            _ = completed(true)
            
        }
        
    }
    
    func signOut() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
        
    }
    
    
}






















