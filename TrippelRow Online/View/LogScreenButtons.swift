//
//  LogScreenButtons.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-21.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LogScreenButtons: UIButton, Shadow {
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = bounds.height / 2
        putShadow(offset: CGSize(width: 2, height: 2))
        
    }
    
    
}
