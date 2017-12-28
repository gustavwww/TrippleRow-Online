//
//  GameVC.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-16.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class GameVC: UIViewController, PlayerDelegate, GameDelegate { //Behöver göras om ordentligt.

    //These should come from MainVC
    var player: Player!
    var gameID: String!
    
    //This object is created here.
    var game: Game!
    
    var myImageType: String!
    var isMyTurn: Bool = false
    
    @IBOutlet weak var boardView: BoardView!
    
    @IBOutlet weak var headerLbl: UILabel!
    
    @IBOutlet weak var hostLbl: UILabel!
    @IBOutlet weak var playerLbl: UILabel!
    
    @IBOutlet weak var hostScoreLbl: UILabel!
    @IBOutlet weak var playerScoreLbl: UILabel!
    
    @IBOutlet weak var hostWinnerLbl: UILabel!
    @IBOutlet weak var playerWinnerLbl: UILabel!
    
    @IBOutlet var buttonViews: [UIButton]!
    var buttons : [Int : UIButton]! // [Position : Button] -    0 = left upper corner, 8 = right down corner.
    
    var panGestures: [UIPanGestureRecognizer]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        player.delegate = self
        
        buttons = [Int : UIButton]()
        
        for i in 0...8 {
            buttons[i] = buttonViews[i]
        }
        
        panGestures = [UIPanGestureRecognizer]()
        
        setupGame()
        
    }
    
    func setupGame() {
        showActivityIndicator()
        
        let gameManager = GameManager()
        
        gameManager.downloadGame(gameID: gameID) { (game, error) in
            
            if error != nil {
                self.gameErrorOccured(error: error!)
                return
            }
            
            self.game = game
            self.game.delegate = self
            self.updateViews()
            
            if !self.game.isFinished {
                
                self.game.startObserve()
                self.setupGestures()
                
            }
            
            self.removeActivityIndicator()
        }
        
    }
    
    //Used when game is finished.
    func disapleInteracton() {
        
        for i in buttonViews {
            i.isUserInteractionEnabled = false
        }
        
        for i in panGestures {
            i.isEnabled = false
        }
        
    }
    
    func getRole() -> String { //Returns either "player" or "host"
        
        if game.host.userID == player.firUser!.uid {
            
            return "host"
            
        } else {
            
            return "player"
        }
        
    }
    
    func setupGestures() {
        
        if game.currentRound <= 6 {
            
            for i in buttons {
                i.value.addTarget(self, action: #selector(self.buttonPressed(sender:)), for: .touchUpInside)
            }
            
        }
        
        for i in buttons {
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gestureRecognized(panGesture:)))
            
            i.value.addGestureRecognizer(panGesture)
            
            panGestures.append(panGesture)
        }
        
    }
    
    @objc func gestureRecognized(panGesture: UIPanGestureRecognizer) {
        
        if game.currentRound <= 6 {
            return
        }
        
        let button: UIButton = panGesture.view as! UIButton
        
        if panGesture.state == .ended {
            
            var buttonIndex: Int = 0
            
            for i in 0...8 {
                
                if buttons[i] == button {
                    buttonIndex = i
                }
                
            }
            
            panGestureEnded(panGesture: panGesture, button: button, buttonIndex: buttonIndex)
            
            return
        }

        if button.imageView?.image == nil || button.imageView?.image != UIImage(named: myImageType) || !isMyTurn {
            return
        }

        //Button is being moved
        
        let translation = panGesture.translation(in: button)
        
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        
        panGesture.setTranslation(CGPoint.zero, in: button)
    }
    
    func panGestureEnded(panGesture: UIPanGestureRecognizer, button: UIButton, buttonIndex: Int) { //Something wrong here
        
        let position = game.board.getCurrentPosition(of: button, boardView: boardView) //Return either nil, or index 0-8
        
        if position == nil {
            //Out of bounds.
            print("Out of bounds")
            game.board.resetPosition(for: button, with: buttonIndex, boardView: boardView, animated: true)
            return
        }
        
        if buttons[position!]?.imageView?.image != nil {
            //Already occupied
            print("Already occupied")
            game.board.resetPosition(for: button, with: buttonIndex, boardView: boardView, animated: true)
            return
        }
        
        //Placing - make changes in buttons dictionary
        print("Making Move...")
        let previousPosition = buttonIndex
        let newPosition = position!
        
        print(previousPosition)
        print(newPosition)
        
        //Something might be wrong in moveToPosition
        var buttonViews = buttons
        game.board.moveToPosition(previous: previousPosition, new: newPosition, button: button, buttonViews: &buttonViews!, boardView: boardView)
        buttons = buttonViews
        
        increaseRoundAndUploadData()
    }
    
    func increaseRoundAndUploadData() {
        
        game.currentRound = game.currentRound + 1 // += Can't be used here.
        
        let winner = game.board.checkForRoundWinner()
        
        if winner != nil {
            //Found winner
            
            if winner == "host" {
                
                game.hostScore = game.hostScore + 1
                
            } else {
                
                game.playerScore = game.playerScore + 1
                
            }
            
            game.currentRound = 1
            game.board.resetBoard()
        }
        
        if game.hostScore == 3 || game.playerScore == 3 {
            
            game.isFinished = true
            
        }
        
        game.uploadData()
    }
    
    func didReceiveGameUpdate(game: Game) {
        
        updateViews()
    }
    
    func updateViews() {
        
        //Player begins.
        
        let role = getRole()
        
        if role == "host" {
            
            self.myImageType = "circle"
            
            if self.game.currentRound % 2 == 0 {
                self.isMyTurn = true
            } else {
                self.isMyTurn = false
            }
            
        } else if role == "player" {
            
            self.myImageType = "cross"
            
            if self.game.currentRound % 2 != 0 {
                self.isMyTurn = true
            } else {
                self.isMyTurn = false
            }
            
        }
        //--------
        
        hostLbl.text = game.host.displayName
        playerLbl.text = game.player.displayName
        hostScoreLbl.text = String(game.hostScore)
        playerScoreLbl.text = String(game.playerScore)
        
        if getRole() == "host" {
            
            headerLbl.text = "Spelar mot \(game.player.displayName)"
            
        } else {
            headerLbl.text = "Spelar mot \(game.host.displayName)"
        }
        
        if game.isFinished {
            
            disapleInteracton()
            
            switch game.getWinner()!.userID {
                
            case game.host.userID:
                hostWinnerLbl.isHidden = false
                break;
                
            case game.player.userID:
                playerWinnerLbl.isHidden = false
                break;
                
            default:
                
                break;
                
            }
            
        }
        
        //Board setup
        var buttonViews = buttons
        game.board.getDictFromGameBoard(buttonViews: &buttonViews!)
        buttons = buttonViews
        
    }
    
    @objc func buttonPressed(sender: UIButton) {
        
        if !isMyTurn {
            return
        }
        
        if game.currentRound > 6 {
            return
        }
        
        if sender.imageView?.image != nil {
            return
        }
        
        sender.setImage(UIImage(named: myImageType), for: .normal)
        
        game.board.updateToGameDict(buttonViews: buttons)
        
        increaseRoundAndUploadData()
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        if game != nil {
            game.stopObserve()
        }
        
        performSegue(withIdentifier: "unwindFromGameVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? MainVC {
            dest.player = self.player
        }
        
    }
    
}
