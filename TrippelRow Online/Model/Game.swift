//
//  Game.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-10.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol GameDelegate {
    
    func didReceiveGameUpdate(game: Game)
    func gameErrorOccured(error: Error)
    
}

extension GameDelegate where Self: UIViewController {
    
    func didReceiveGameUpdate(game: Game) {}
    
    func gameErrorOccured(error: Error) {
        removeActivityIndicator()
        
        var errorMsg = error.localizedDescription
        
        if let error = error as? StringError {
            errorMsg = error.stringDescription
        }
        
        let alertController = UIAlertController(title: "Fel", message: errorMsg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

class Game {
    
    var delegate: GameDelegate?
    
    var dbRef: DatabaseReference
    var handle: DatabaseHandle?
    
    var id: String
    
    var host: DetailedUser!
    var player: DetailedUser!
    
    var isFinished: Bool!
    
    var currentRound: Int!
    var hostScore: Int!
    var playerScore: Int!
    
    var board: Board!
    
    init(_ gameID: String) { self.id = gameID; dbRef = Database.database().reference() }
    
    func getWinner() -> DetailedUser? {
        
        if hostScore > playerScore {
            
            return host
            
        } else if playerScore > hostScore {
            
            return player
            
        } else {
            return nil
        }
    }
    
    func startObserve() {
        
        self.handle = dbRef.child("games").child(self.id).observe(.value, with: { (snapshot) in
            
            if let game = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let finished = game["isFinished"] as? Bool {
                    self.isFinished = finished
                }
                
                if let roundsPlayed = game["currentRound"] as? Int {
                    self.currentRound = roundsPlayed
                }
                
                if let hostScore = game["hostScore"] as? Int {
                    self.hostScore = hostScore
                }
                
                if let playerScore = game["playerScore"] as? Int {
                    self.playerScore = playerScore
                }
                
                if let board = game["board"] as? Dictionary<String, AnyObject> {
                    //Download board
                    
                    if let dictBoard = board["board"] as? Dictionary<Int, String> {
                        
                        let gameBoard = Board()
                        gameBoard.board = dictBoard
                        
                        self.board = gameBoard
                    }
                    
                }
                self.delegate?.didReceiveGameUpdate(game: self)
                
            } else {
                self.delegate?.gameErrorOccured(error: StringError(ErrorType.CouldNotDownloadGame))
            }
            
        })
        
        
    }
    
    func stopObserve() {
        
        if let handle = self.handle {
            dbRef.removeObserver(withHandle: handle)
        }
        
    }
    
    func uploadData() {
        
        var gameDict = Dictionary<String, AnyObject>()
        
        gameDict["host"] = host.userID as AnyObject
        gameDict["player"] = player.userID as AnyObject
        
        gameDict["isFinished"] = isFinished as AnyObject
        
        gameDict["currentRound"] = currentRound as AnyObject
        gameDict["hostScore"] = hostScore as AnyObject
        gameDict["playerScore"] = playerScore as AnyObject
        
        var boardObj = Dictionary<String, AnyObject>()
        
        var dictBoard = Dictionary<Int, String>()
        
        dictBoard = board.board
        
        boardObj["board"] = dictBoard as AnyObject
        
        gameDict["board"] = board as AnyObject
        
        dbRef.child("games").child(id).setValue(gameDict)
    }
    
}
