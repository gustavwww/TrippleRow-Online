//
//  OpponentSelectionVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-10.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class OpponentSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var player: Player!
    var friends: [DBUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        friends = player.friends
        
        if friends == nil {
            
            tableView.isHidden = true
            
        }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let numberOfFriends = friends?.count {
            return numberOfFriends
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as? FriendCell {
            
            cell.setupCell(displayName: friends![indexPath.row].displayName!)
            
            return cell
        }
        
        return FriendCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let clicked = friends![indexPath.row].userID
        
        let alertController = UIAlertController(title: "Utmana \(String(describing: clicked))?", message: "Vill du utmana \(String(describing: clicked)) i en tre-i-rad kamp?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ja", style: .default, handler: { (action) in
            
            self.player.sendGameRequest(to: clicked)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Avbryt", style: .default, handler: nil))
        
       present(alertController, animated: true, completion: nil)
    }
    
    func gameRequestSent(to: String) {
        
        let alertController = UIAlertController(title: "Spelförfrågan Skickad!", message: "En spelförfrågan har skickats till \(to)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindFromOpponentSelectionVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? NewGameVC {
            dest.player = self.player
        }
        
    }

}
