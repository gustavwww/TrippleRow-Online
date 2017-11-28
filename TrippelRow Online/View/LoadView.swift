//
//  LoadView.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-28.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class LoadView: UIView {
    
    func setupView() {
        
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.cornerRadius = 10
        
        let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activitySpinner.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        addSubview(activitySpinner)
        activitySpinner.startAnimating()
        
    }

}
