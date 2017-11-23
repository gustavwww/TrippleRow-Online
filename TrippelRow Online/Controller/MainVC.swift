//
//  MainVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-22.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController {
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toMenuVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MenuVC {
            dest.user = self.user
        }
        
    }
    
}
