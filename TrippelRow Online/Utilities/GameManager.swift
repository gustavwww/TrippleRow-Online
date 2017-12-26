//
//  GameManager.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-10.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GameManager {
    
    var dbRef: DatabaseReference
    
    init() {
        self.dbRef = Database.database().reference()
    }
    
    func createGame(hostUID: String, playerUID: String) {
        
        var gameDict = Dictionary<String, AnyObject>()
        
        gameDict["host"] = hostUID as AnyObject
        gameDict["player"] = playerUID as AnyObject
        
        gameDict["isFinished"] = false as AnyObject
        
        gameDict["currentRound"] = 1 as AnyObject
        gameDict["hostScore"] = 0 as AnyObject
        gameDict["playerScore"] = 0 as AnyObject
        
        var board = Dictionary<String, AnyObject>() //What do you need?
        
        var dictBoard = Dictionary<Int, String>()
        
        for i in 0...8 {
            dictBoard[i] = "empty"
        }
        
        board["board"] = dictBoard as AnyObject
        
        gameDict["board"] = board as AnyObject
        
        dbRef.child("games").childByAutoId().setValue(gameDict)
        
    }
    
    func downloadMultipleGames(gameIDs: [String], completed: @escaping ([Game]?, StringError?) -> Void) {
        
        var games = [Game]()
        
        for i in gameIDs {
            
            downloadGame(gameID: i, completed: { (game, error) in
                
                if error != nil {
                    completed(nil, error!)
                    return
                }
                
                games.append(game!)
                checkIfFinished()
            })
            
            func checkIfFinished() {
                
                if gameIDs.count == games.count {
                    
                    completed(games, nil)
                    return
                }
                
            }
            
        }
        
    }
    
    func downloadGame(gameID: String, completed: @escaping (Game?, StringError?) -> Void) {
        
        dbRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if let db = snapshot.value as? Dictionary<String, AnyObject> {
                
                let game = Game(gameID)
                
                var hostUID: String!
                var playerUID: String!
                
                if let games = db["games"] as? Dictionary<String, AnyObject> {
                    
                    if let gameDict = games[gameID] as? Dictionary<String, AnyObject> {
                        
                        if let finished = gameDict["isFinished"] as? Bool {
                            game.isFinished = finished
                        }
                        
                        if let roundsPlayed = gameDict["currentRound"] as? Int {
                            game.currentRound = roundsPlayed
                        }
                        
                        if let hostScore = gameDict["hostScore"] as? Int {
                            game.hostScore = hostScore
                        }
                        
                        if let playerScore = gameDict["playerScore"] as? Int {
                            game.playerScore = playerScore
                        }
                        
                        if let host = gameDict["host"] as? String {
                            hostUID = host
                        }
                        
                        if let player = gameDict["player"] as? String {
                            playerUID = player
                        }
                        
                        if let board = gameDict["board"] as? Dictionary<String, AnyObject> {
                            //Download board
                            
                            if let dictBoard = board["board"] as? Dictionary<Int, String> {
                                
                                let gameBoard = Board()
                                gameBoard.board = dictBoard
                                
                                game.board = gameBoard
                            }
                            
                        }
                        
                    }
                    
                }
                
                if let users = db["users"] as? Dictionary<String, AnyObject> {
                    
                    let playerUIDS: [String] = [hostUID, playerUID]
                    
                    for i in playerUIDS {
                        
                        if let user = users[i] as? Dictionary<String, AnyObject> {
                            
                            let detailedUser = DetailedUser()
                            detailedUser.userID = hostUID
                            
                            
                            if let displayName = user["displayName"] as? String {
                                detailedUser.displayName = displayName
                            }
                            
                            if let email = user["email"] as? String {
                                detailedUser.email = email
                            }
                            
                            if let status = user["status"] as? String {
                                
                                switch status {
                                    
                                case "online":
                                    detailedUser.status = .Online
                                    break;
                                    
                                case "offline":
                                    detailedUser.status = .Offline
                                    break;
                                    
                                default:
                                    detailedUser.status = .Offline
                                    break;
                                }
                                
                            }
                            
                            if i == playerUIDS.first {
                                
                                game.host = detailedUser
                                
                            } else {
                                
                                game.player = detailedUser
                            }
                            
                        }
                        
                    }
                    
                }
                completed(game, nil)
                
            } else {
                completed(nil, StringError(ErrorType.CouldNotDownloadGame))
            }
            
        }
        
        
    }
    
}
