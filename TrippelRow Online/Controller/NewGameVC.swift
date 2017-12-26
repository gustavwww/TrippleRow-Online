//
//  NewGameVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-27.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController, PlayerDelegate {
    
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player.delegate = self
        
    }
    
    @IBAction func playAgainstFriendPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toOpponentSelectionVC", sender: nil)
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindFromNewGameVC", sender: nil)
        
    }
    
    @IBAction func unwindToNewGameVC(segue: UIStoryboardSegue) {player.delegate = self}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
        }
        
        if let dest = segue.destination as? OpponentSelectionVC {
            dest.player = self.player
        }
        
    }
    
}
