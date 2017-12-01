//
//  RegisterTextFields.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-01.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class RegisterTextFields: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let font = UIFont(name: "Avenir Next", size: 16)
        let color = UIColor.white.withAlphaComponent(0.8)
        
        attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedStringKey.font : font!, NSAttributedStringKey.foregroundColor : color])
        
        layer.cornerRadius = 10
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.94, green: 0.33, blue: 0.31, alpha: 0.91).cgColor
        
    }

}
