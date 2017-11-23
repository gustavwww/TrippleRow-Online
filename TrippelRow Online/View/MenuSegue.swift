//
//  MenuSegue.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class MenuSegue: UIStoryboardSegue {
    
    
    override func perform() {
        
        let destView = destination.view!
        let sourceView = source.view!
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        destView.center = CGPoint(x: screenWidth / 2 - screenWidth, y: screenHeight / 2)
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(destView, aboveSubview: sourceView)
        
        UIView.animate(withDuration: 0.2, delay: 0.5, options: [.curveEaseOut], animations: {
            
            destView.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            sourceView.center = CGPoint(x: screenWidth / 2 + 100, y: screenHeight / 2)
            
            
        }) { (completed) in
            
            self.source.modalPresentationStyle = .overCurrentContext
            self.source.navigationController?.popToViewController(self.destination, animated: false)
            
        }
        
    }

}
