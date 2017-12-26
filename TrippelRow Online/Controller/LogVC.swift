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

class LogVC: UIViewController, UITextFieldDelegate, PlayerDelegate {

    @IBOutlet weak var emailField: LoginTextFields!
    @IBOutlet weak var passwordField: LoginTextFields!
    @IBOutlet weak var background: UIImageView!
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        closeKeyboardFunction()
        
        player = Player()
        player.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = player.checkIfSignedIn()
        
    }
    
    func setupTextFields() {
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.keyboardType = .emailAddress
        passwordField.keyboardType = .default
        
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        
        return true
    }
    
    
    @IBAction func loginPressed(_ sender: LogScreenButtons) { //Login Button
        
        if let email = emailField.text , email != "" {
            if let password = passwordField.text , password != "" {
                
                showActivityIndicator()
                player.signInUser(email: email, password: password)
                
            }
            
        }
        
    }
    
    @IBAction func registerPressed(_ sender: LogScreenButtons) { //Move to another ViewController
        performSegue(withIdentifier: "toRegisterVC", sender: nil)
    }
    
    @IBAction func facebookLoginPressed(_ sender: LogScreenButtons) {
        showActivityIndicator()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "user_friends", "email"], from: self) { (loginResult, error) in
            
            if let error = error {
                
                self.errorOccured(error: error)
                
                self.removeActivityIndicator()
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: (loginResult?.token.tokenString)!)
            self.player.signInUser(credential: credential)
            
        }
    }
    
    func player(signedIn player: Player) {
        
        removeActivityIndicator()
        performSegue(withIdentifier: "toMainVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
        }
        
        if let dest = segue.destination as? RegisterVC {
            dest.player = self.player
        }
        
    }

}

