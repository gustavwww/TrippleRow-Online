//
//  LoginTextFields.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-21.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LoginTextFields: UITextField {


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let font = UIFont(name: "Avenir Next", size: 16)
        let color = UIColor.white.withAlphaComponent(0.8)
        
        attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.font : font!, NSAttributedStringKey.foregroundColor : color])
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        
        
    }
    
    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        
        layer.cornerRadius = 5
        
    }

}
