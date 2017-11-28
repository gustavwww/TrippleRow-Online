//
//  ViewControllerLoadExtension.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-28.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    fileprivate static var activityIndicatorView: LoadView!
    
    func showActivityIndicator() {
        
        view.isUserInteractionEnabled = false
        
        UIViewController.activityIndicatorView = LoadView()
        UIViewController.activityIndicatorView.frame.size = CGSize(width: 80, height: 80)
        UIViewController.activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        UIViewController.activityIndicatorView.setupView()
        
        view.addSubview(UIViewController.activityIndicatorView)
    }
    
    func removeActivityIndicator() {
        
        if let indicator = UIViewController.activityIndicatorView {
            
            view.isUserInteractionEnabled = true
            
            indicator.removeFromSuperview()
            
        }
        
    }
    
    
}
