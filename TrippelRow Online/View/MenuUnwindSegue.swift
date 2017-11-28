//
//  MenuUnwindSegue.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-24.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class MenuUnwindSegue: UIStoryboardSegue {
    
    override func perform() {
        
        let destView = destination.view
        let sourceView = source.view
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
            
            destView?.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            sourceView?.center = CGPoint(x: -(screenWidth / 2), y: screenHeight / 2)
            
        }) { (completed) in
            
            self.source.dismiss(animated: false, completion: nil)
            
        }
        
    }
    

}
