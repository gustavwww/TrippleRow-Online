//
//  MainVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-22.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MainVC: UIViewController {
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Implement player delegate?
        
        player.singleObserve {}
        
    }
    
    
    
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toMenuVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MenuVC {
            dest.player = self.player
        }
        
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toNewGameVC", sender: nil)
        
    }
    
    @IBAction func slideUnwindSegue(unwindSegue: UnwindSlideSegue) {}
    
    @IBAction func unwindSegue(unwindSegue: MenuUnwindSegue) {}
    
    
}
