//
//  PlayerDelegate.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-10.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

enum PlayerStatus {
    
    case Online
    case Offline
    
}

protocol PlayerDelegate {
    
    func playerObserverRan(player: Player)
    
    func player(signedIn player: Player)
    func player(created player: Player)
    
    func friendRequestSent(to: String)
    func gotFriendRequest(from: [DBUser], to: Player)
    func acceptedFriendRequest(from: DBUser)
    
    func gameRequestSent(to: String)
    func gotGameRequest(from: [DBUser], to: Player)
    
    func errorOccured(error: Error)
}

extension PlayerDelegate where Self: UIViewController {
    
    func playerObserverRan(player: Player) {}
    
    func player(signedIn player: Player) {}
    func player(created player: Player) {}
    func friendRequestSent(to: String) {}
    
    func gameRequestSent(to: String) {}
    
    
    //Handling gameRequests
    func gotGameRequest(from: [DBUser], to: Player) {
        
        if from.isEmpty {
            return
        }
        
        let alertController = UIAlertController(title: "Spelförfrågan mottagen av \(from.last!.displayName!)", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Acceptera", style: .default, handler: { (action) in
            //Accept
            
            to.acceptLastGameRequest()
            
            self.gotGameRequest(from: to.gameRequests, to: to)
        }))
        
        alertController.addAction(UIAlertAction(title: "Neka", style: .destructive, handler: { (action) in
            //Decline
            
            to.declineLastGameRequest()
            
            self.gotGameRequest(from: to.gameRequests, to: to)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //Handling friendRequests
    func gotFriendRequest(from: [DBUser], to: Player) {
        
        if from.isEmpty {
            return
        }
        
        let alertController = UIAlertController(title: "Vänförfrågan mottagen av \(from.last!.displayName!)", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Acceptera", style: .default, handler: { (action) in
            //Accept
            
            to.acceptLastFriendRequest()
            
            self.gotFriendRequest(from: to.friendRequests, to: to)
        }))
        
        alertController.addAction(UIAlertAction(title: "Neka", style: .destructive, handler: { (action) in
            //Decline
            
            to.declineLastFriendRequest()
            
            self.gotFriendRequest(from: to.friendRequests, to: to)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func acceptedFriendRequest(from: DBUser) {}
    
    //Handling errors
    func errorOccured(error: Error) {
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
