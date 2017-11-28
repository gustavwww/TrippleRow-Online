//
//  NewGameVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-27.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func backPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "newGameUnwind", sender: nil)
        
    }
    
}
