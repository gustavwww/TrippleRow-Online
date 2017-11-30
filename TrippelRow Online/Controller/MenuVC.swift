//
//  MenuVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeView: UIView!
    
    var player: Player!
    let contents = ["Profil", "Vänner", "Logga ut"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupCloseGesture()
        
    }
    
    func setupCloseGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesturePressed))
        closeView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tapGesturePressed() {
        performSegue(withIdentifier: "unwindFromMenuVC", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if contents[indexPath.row] == "Logga ut" {
            signOut()
            
        } else if contents[indexPath.row] == "Vänner" {
            performSegue(withIdentifier: "toFriendsVC", sender: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell {
            
            if contents[indexPath.row] == "Vänner" {
                cell.setupCell(image: "Friends", label: contents[indexPath.row])
                return cell
            }
            
            cell.setupCell(image: contents[indexPath.row], label: contents[indexPath.row])
            return cell
        }
        
        return MenuCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? MenuCell {
            cell.view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        }
        
    }
    
    
    func signOut() {
        
        player.signOut()
        
        if let logVC = presentingViewController?.presentingViewController as? LogVC {
            logVC.player.delegate = logVC
        }
        
        dismiss(animated: true, completion: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindFromMenuVC", sender: nil)
    }
    
    @IBAction func unwindToMenuVC(segue: UIStoryboardSegue) {player.delegate = self}
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
        }
        if let dest = segue.destination as? FriendsVC {
            dest.player = self.player
        }
        
    }
    
    
    
    
    

}
