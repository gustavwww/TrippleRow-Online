//
//  Shadow.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

protocol Shadow {}

extension Shadow where Self: UIView {
    
    func putShadow(offset: CGSize) {
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = offset
        
    }
    
    func putShadow(radius: CGFloat) {
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = radius
        
    }
    
}
