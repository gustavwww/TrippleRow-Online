//
//  RegisterVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-30.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, PlayerDelegate {

    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        
    }

}
