//
//  LoginTextFields.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-21.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LoginTextFields: UITextField, Shadow {
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let font = UIFont(name: "Avenir Next", size: 16)
        let color = UIColor.white.withAlphaComponent(0.8)
        
        attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.font : font!, NSAttributedStringKey.foregroundColor : color])
        
        layer.cornerRadius = bounds.height / 2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        
    }

}
