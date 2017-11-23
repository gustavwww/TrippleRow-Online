//
//  MenuVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    let contents = ["Logga ut"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        initializeExit()
        
    }
    
    func initializeExit() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didPressOutsideMenu))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func didPressOutsideMenu() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            logout()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell {
            
            cell.setupCell(image: contents[indexPath.row], label: contents[indexPath.row])
            return cell
        }
        
        return MenuCell()
    }
    
    func logout() {
        
        do {
            
            try Auth.auth().signOut()
            
        } catch let error as NSError {
            print("Error logging out: \(String(describing: error.localizedDescription))")
        }
        
        
    }
    
    
    
    
    

}
