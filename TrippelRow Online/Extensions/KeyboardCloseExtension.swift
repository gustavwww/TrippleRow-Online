//
//  KeyboardCloseExtension.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func closeKeyboardFunction() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    
}
