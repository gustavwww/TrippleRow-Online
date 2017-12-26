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

class MainVC: UIViewController, PlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var player: Player!
    
    var gameIDs: [String]!
    
    var activeGames: [Game]!
    var finishedGames: [Game]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        activeGames = [Game]()
        finishedGames = [Game]()
        
        player.startObserve()
    }
    
    func playerObserverRan(player: Player) {
        
        gameIDs = player.gameIDs
        
        if gameIDs == nil {
            return
        }
        
        GameManager().downloadMultipleGames(gameIDs: gameIDs) { (games, error) in
            
            if error != nil {
                self.errorOccured(error: error!)
                return
            }
            
            if games == nil {
                
                return
            }
            
            print(games!.count)
            
            for i in games! {
                
                if i.isFinished {
                    
                    self.finishedGames.append(i)
                    continue
                }
                
                self.activeGames.append(i)
            }
            
            
            self.tableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return activeGames.count
        }
        
        return finishedGames.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21))
        
        view.setupView(section, tableView: tableView)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameCell {
            
            var gameLbl = "Spel mot "
            let array: [Game]!
            
            if indexPath.section == 0 {
                array = activeGames
            } else {
                array = finishedGames
            }
            
            let game = array[indexPath.row]
            
            if player.firUser?.uid == game.host.userID {
                gameLbl += game.player.displayName
            } else {
                gameLbl += game.host.displayName
            }
            
            cell.setupCell(gameLbl: gameLbl)
            
            return cell
        }
        
        return GameCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var game: Game!
        
        if indexPath.section == 0 {
            
            game = activeGames[indexPath.row]
            
        } else {
            game = finishedGames[indexPath.row]
        }
        
        performSegue(withIdentifier: "toGameVC", sender: game.id)
        
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
        
        if let dest = segue.destination as? GameVC {
            dest.player = self.player
            
            if let gameID = sender as? String {
                dest.gameID = gameID
            }
            
        }
        
    }
    
}
