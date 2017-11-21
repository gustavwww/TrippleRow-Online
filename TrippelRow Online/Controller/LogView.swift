//
//  ViewController.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-20.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LogView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: LoginTextFields!
    @IBOutlet weak var passwordField: LoginTextFields!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        
        
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
    
    @IBAction func loginPressed(_ sender: LogScreenButtons) {
        
        
        
        
        
    }
    
    @IBAction func registerPressed(_ sender: LogScreenButtons) {
        
        
        
    }
    
    
    


}

