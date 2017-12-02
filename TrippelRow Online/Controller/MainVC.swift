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

class MainVC: UIViewController, PlayerDelegate {
    
    var player: Player!
    var isFirstTimeOnline: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        
        if isFirstTimeOnline {
            firstTimeManagement()
        }
        
        player.singleObserve {}
        
        player.startObserve()
        
    }
    
    func firstTimeManagement() {} //Might do something here
    
    func gotFriendRequest(from: [DBUser]) {
        

        
    }
    
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toMenuVC", sender: nil)
        
    }
    
    @IBAction func newGamePressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toNewGameVC", sender: nil)
        
    }
    
    @IBAction func unwindToMainVC(segue: UIStoryboardSegue) {player.delegate = self}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MenuVC {
            dest.player = self.player
        }
        
        if let dest = segue.destination as? NewGameVC {
            dest.player = self.player
        }
        
    }
    
}
