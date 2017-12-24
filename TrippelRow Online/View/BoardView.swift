//
//  BoardView.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-16.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class BoardView: UIView, Shadow {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        putShadow(radius: 3)
        
        layer.masksToBounds = false
        layer.cornerRadius = 2
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
    }

}
