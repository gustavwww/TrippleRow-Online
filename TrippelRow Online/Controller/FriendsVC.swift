//
//  FriendsVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-27.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    var player: Player!
    var friends: [DBUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        player.singleObserve {
            self.friends = self.player.friends
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let friends = self.friends {
            return friends.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendCell {
            
            cell.setupCell(displayName: (friends![indexPath.row].displayName)!)
            
            return cell
        }
        return FriendCell()
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindFromFriendsVC", sender: nil)
        
    }
    
    @IBAction func addFriendPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toAddFriendVC", sender: nil)
        
    }
    
    @IBAction func unwindToFriendsVC(segue: UIStoryboardSegue) {player.delegate = self}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? AddFriendVC {
            dest.player = self.player
        }
        
        if let dest = segue.destination as? MenuVC {
            dest.player = self.player
        }
        
    }
    
}
