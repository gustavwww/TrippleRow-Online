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
        layer.borderColor = UIColor(red: 0.94, green: 0.33, blue: 0.31, alpha: 0.91).cgColor
        layer.borderWidth = 1
        
    }

}
