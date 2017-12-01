//
//  LoginView.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-01.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LoginView: UIView, Shadow {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        putShadow(radius: 2)
        
        layer.cornerRadius = 20
        
    }

}
