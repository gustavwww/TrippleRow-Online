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
        
        checkIfOnline()
        
    }
    
    
    func checkIfOnline() {
        
        _ = player.checkIfOnline()
        
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
        
        
        
    }
    
    @IBAction func facebookLoginPressed(_ sender: LogScreenButtons) {
        let loginManager = FBSDKLoginManager()
        showActivityIndicator()
        loginManager.logIn(withReadPermissions: ["public_profile", "user_friends"], from: self) { (loginResult, error) in
            
            if let error = error {
                
                self.errorOccured(error: error)
                
                return
            }
            if let result = loginResult , let token = result.token , let tokenString = token.tokenString {
                
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                self.player.signInUser(credential: credential)
                
                self.removeActivityIndicator()
                return
            }
            self.removeActivityIndicator()
        }
    }
    
    func player(signedIn player: Player) {
        
        performSegue(withIdentifier: "toMainVC", sender: nil)
        removeActivityIndicator()
        
    }
    
    func errorOccured(error: Error) {
        removeActivityIndicator()
        let alert = UIAlertController(title: "Fel", message: "Ett fel inträffade! \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Stäng", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
        }
        
    }

}

