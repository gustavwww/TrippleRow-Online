//
//  RegisterVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-30.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate, PlayerDelegate {

    @IBOutlet weak var usernameField: RegisterTextFields!
    @IBOutlet weak var emailField: RegisterTextFields!
    @IBOutlet weak var passField: RegisterTextFields!
    @IBOutlet weak var passVerificationField: RegisterTextFields!
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeKeyboardFunction()
        
        player.delegate = self
        
        setupTextFields()
        
    }
    
    func setupTextFields() {
        
        usernameField.delegate = self
        emailField.delegate = self
        passField.delegate = self
        passVerificationField.delegate = self
        
        emailField.keyboardType = .emailAddress
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        
        return true
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        
        showActivityIndicator()
        let registrationManager = RegistrationManager(username: usernameField.text!, password: passField.text!, passVerification: passVerificationField.text!, email: emailField.text!)
        
        registrationManager.checkFields { (error) in
            
            if error != nil {
                
                self.errorOccured(error: error!)
                return
            }
            
            self.player.createUser(email: self.emailField.text!, password: self.passField.text!, displayName: self.usernameField.text!)
        }
        
    }
    
    func player(created player: Player) {
        
        removeActivityIndicator()
        performSegue(withIdentifier: "toMainVCFromRegisterVC", sender: nil)
        
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        if let logVC = presentingViewController as? LogVC {
            logVC.player.delegate = logVC
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
            dest.isFirstTimeOnline = true
        }
        
    }
    
}
