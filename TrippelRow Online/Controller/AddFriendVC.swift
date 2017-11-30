//
//  AddFriendVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-28.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFriendVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, PlayerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var player: Player!
    
    var users: [DBUser]!
    var filteredUsers: [DBUser]!
    
    var inSearchMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        player.delegate = self
        
        users = [DBUser]()
        
        player.singleObserve {
            
            for i in self.player.friends {
                
                self.users = self.player.allUsers.filter { $0.displayName != self.player.firUser?.displayName && $0.displayName != i.displayName }
                
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            view.endEditing(true)
            
            return
        }
        inSearchMode = true
        
        
        filteredUsers = users.filter { $0.displayName?.lowercased().range(of: searchText.lowercased()) != nil }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as? FriendCell {
            
            if inSearchMode {
                cell.setupCell(displayName: filteredUsers[indexPath.row].displayName!)
            } else {
                cell.setupCell(displayName: users[indexPath.row].displayName!)
            }
            
            return cell
        }
        
        return FriendCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: DBUser!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        let alertController = UIAlertController(title: "Lägg till ny vän", message: "Är du säker på att du vill skicka en vänförfråga till \(String(describing: user.displayName))?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Skicka", style: .default, handler: { (action) in
            
            self.showActivityIndicator()
            self.player.sendFriendRequest(to: user.userID)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: { (action) in }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func friendRequestSent(to: String) {
        
        self.removeActivityIndicator()
        
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindFromAddFriendVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? FriendsVC {
            dest.player = self.player
        }
        
    }
    
}
