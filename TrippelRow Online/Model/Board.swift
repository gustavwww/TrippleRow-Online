//
//  Board.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-10.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

class Board {
    
    var board: [Int : String]!
    
    func resetBoard() {
        
        board = [Int : String]()
        
        for i in 0...8 {
            board[i] = "empty"
        }
        
    }
    
    func moveToPosition(previous: Int, new: Int, button: UIButton, buttonViews: inout [Int : UIButton], boardView: BoardView) {
        
        let movedButton = button
        let replaceButton = buttonViews[new]!
        
        resetPosition(for: movedButton, with: new, boardView: boardView, animated: true)
        resetPosition(for: replaceButton, with: previous, boardView: boardView, animated: false)
        //ADDED ANOTHER ONE INSTEAD OF CHANGING! - Try to set every normal piece to an image?
        
        var newButtons = [Int : UIButton]()
        
        print("COUNT buttons: \(buttonViews.count)")
        
        for i in buttonViews {
            
            if i.key == previous {
                newButtons[i.key] = replaceButton
            } else if i.key == new {
                newButtons[i.key] = movedButton
            } else {
                newButtons[i.key] = i.value
            }
            
        }
        print("COUNT newButtons: \(newButtons.count)")
        buttonViews = newButtons
        updateToGameDict(buttonViews: newButtons)
    }
    
    func getDictFromGameBoard(buttonViews: inout [Int : UIButton]) {
        
        var newButtons = buttonViews
        
        for i in 0...8 {
            
            if board[i] == "host" {
                
                newButtons[i]?.setImage(UIImage(named: "circle"), for: .normal)
                
            } else if board[i] == "player" {
                
                newButtons[i]?.setImage(UIImage(named: "cross"), for: .normal)
                
            } else {
                
                newButtons[i]?.setImage(nil, for: .normal)
                
            }
            
        }
        
        buttonViews = newButtons
    }
    
    func updateToGameDict(buttonViews: [Int : UIButton]) {
        
        board = [Int : String]()
        
        for i in 0...8 {
            
            if buttonViews[i]?.imageView?.image == UIImage(named: "circle") {
                print("\(i): host")
                board[i] = "host"
                
            } else if buttonViews[i]?.imageView?.image == UIImage(named: "cross") {
                print("\(i): player")
                board[i] = "player"
                
            } else {
                print("\(i): empty")
                board[i] = "empty"
                
            }
            
        }
        
    }
    
    func getCurrentPosition(of: UIButton, boardView: BoardView) -> Int? {
        
        if of.center.x > boardView.bounds.minX && of.center.x < boardView.bounds.maxX / 3 {
            //First row from left.
            
            if of.center.y > boardView.bounds.minY && of.center.y < boardView.bounds.maxY / 3 {
                //1
                
                return 0
            }
            
            if of.center.y > boardView.bounds.maxY / 3 && of.center.y < (boardView.bounds.maxY / 3) * 2 {
                //4
                
                return 3
            }
            
            if of.center.y > (boardView.bounds.maxY / 3) * 2 && of.center.y < boardView.bounds.maxY {
                //7
                
                return 6
            }
            
            
        }
        
        if of.center.x > boardView.bounds.maxX / 3 && of.center.x < (boardView.bounds.maxX / 3) * 2 {
            //Second row from left.
            
            if of.center.y > boardView.bounds.minY && of.center.y < boardView.bounds.maxY / 3 {
                //2
                
                return 1
            }
            
            if of.center.y > boardView.bounds.maxY / 3 && of.center.y < (boardView.bounds.maxY / 3) * 2 {
                //5
                
                return 4
            }
            
            if of.center.y > (boardView.bounds.maxY / 3) * 2 && of.center.y < boardView.bounds.maxY {
                //8
                
                return 7
            }
            
        }
        
        if of.center.x > (boardView.bounds.maxX / 3) * 2 && of.center.x < boardView.bounds.maxX {
            //Third row from left.
            
            if of.center.y > boardView.bounds.minY && of.center.y < boardView.bounds.maxY / 3 {
                //3
                
                return 2
            }
            
            if of.center.y > boardView.bounds.maxY / 3 && of.center.y < (boardView.bounds.maxY / 3) * 2 {
                //6
                
                return 5
            }
            
            if of.center.y > (boardView.bounds.maxY / 3) * 2 && of.center.y < boardView.bounds.maxY {
                //9
                
                return 8
            }
            
        }
        
        return nil
    }
    
    func resetPosition(for button: UIButton, with index: Int, boardView: BoardView, animated: Bool) {
        
        var moveToPoint: CGPoint!
        
        switch index {
            
        case 0:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6, y: boardView.bounds.maxY / 6)
            
        case 1:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 3, y: boardView.bounds.maxY / 6)
            
        case 2:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 5, y: boardView.bounds.maxY / 6)
            
        case 3:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6, y: boardView.bounds.maxY / 6 * 3)
            
        case 4:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 3, y: boardView.bounds.maxY / 6 * 3)
            
        case 5:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 5, y: boardView.bounds.maxY / 6 * 3)
            
        case 6:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6, y: boardView.bounds.maxY / 6 * 5)
            
        case 7:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 3, y: boardView.bounds.maxY / 6 * 5)
            
        case 8:
            moveToPoint = CGPoint(x: boardView.bounds.maxX / 6 * 5, y: boardView.bounds.maxY / 6 * 5)
            
        default:
            
            break;
            
        }
        
        if moveToPoint != nil {
            
            if animated {
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    
                    button.center = moveToPoint
                    
                }, completion: nil)
                
            } else {
                
                button.center = moveToPoint
                
            }
            
        }
        
    }
    
    func checkForRoundWinner() -> String? {
        
        if board[0] == board[1] && board[0] == board[2] && board[0] != "empty" {
            
            return board[0]
        }
        
        if board[3] == board[4] && board[3] == board[5] && board[3] != "empty" {
            
            return board[3]
        }
        
        if board[6] == board[7] && board[6] == board[8] && board[6] != "empty" {
            
            return board[6]
        }
        
        if board[0] == board[3] && board[0] == board[6] && board[0] != "empty" {
            
            return board[0]
        }
        
        if board[1] == board[4] && board[1] == board[7] && board[1] != "empty" {
            
            return board[1]
        }
        
        if board[2] == board[5] && board[2] == board[8] && board[2] != "empty" {
            
            return board[2]
        }
        
        if board[0] == board[4] && board[0] == board[8] && board[0] != "empty" {
            
            return board[0]
        }
        
        if board[6] == board[4] && board[6] == board[2] && board[6] != "empty" {
            
            return board[6]
        }
        
        return nil
    }
    
}
