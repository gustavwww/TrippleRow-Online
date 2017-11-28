//
//  UnwindSlideSegue.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-27.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class UnwindSlideSegue: UIStoryboardSegue {
    
    
    override func perform() {
        
        let destView = destination.view!
        let sourceView = source.view!
        
        let screenheight = UIScreen.main.bounds.height
        let screenwidth = UIScreen.main.bounds.width
        
        destView.center = CGPoint(x: screenwidth / 2 - 100, y: screenheight / 2)
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(sourceView)
        window.insertSubview(destView, belowSubview: sourceView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            
            sourceView.center = CGPoint(x: screenwidth / 2 + screenwidth, y: screenheight / 2)
            destView.center = CGPoint(x: screenwidth / 2, y: screenheight / 2)
            
        }) { (completed) in
            
            self.source.dismiss(animated: false, completion: nil)
            
        }
        
        
    }

}
