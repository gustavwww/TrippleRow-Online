//
//  ViewController.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-20.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class LogView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: LoginTextFields!
    @IBOutlet weak var passwordField: LoginTextFields!
    @IBOutlet weak var background: UIImageView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        closeKeyboardFunction()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfOnline()
        
    }
    
    
    func checkIfOnline() {
        
        if FBSDKAccessToken.current() != nil { //User already logged in as Facebook , Move to another ViewController (Facebook signed in?)
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if error != nil {
                    print("Error signing in: \(String(describing: error?.localizedDescription))")
                } else {
                    self.user = user
                    self.performSegue(withIdentifier: "toMainVC", sender: nil)
                    print("Signed in: Facebook")
                }
                
            })
            
        } else if let user = Auth.auth().currentUser { //User already logged in , Move to another ViewController (Normal signed in?)
            
            self.user = user
            performSegue(withIdentifier: "toMainVC", sender: nil)
            print("Signed in: Normal")
        }
        
    }
    
    func setupTextFields() {
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.keyboardType = .emailAddress
        passwordField.keyboardType = .default
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        
        return true
    }
    
    
    @IBAction func loginPressed(_ sender: LogScreenButtons) { //Login Button
        
        if let email = emailField.text , email != "" {
            if let password = passwordField.text , password != "" {
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    
                    if error != nil {
                        print("Error signing in: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    self.user = user
                    //Move to another ViewController
                    self.performSegue(withIdentifier: "toMainVC", sender: nil)
                    
                })
                
                
            }
            
        }
        
        
        
    }
    
    @IBAction func registerPressed(_ sender: LogScreenButtons) { //Move to another ViewController
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.user = self.user
        }
        
    }

}

