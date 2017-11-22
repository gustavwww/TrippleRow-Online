//
//  LogScreenButtons.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-21.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LogScreenButtons: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        
        
    }
    
    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        
        layer.cornerRadius = 3
        
        
    }
    
}
