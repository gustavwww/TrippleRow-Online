//
//  SectionHeaderView.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-25.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    
    func setupView(_ section: Int, tableView: UITableView) {
        
        backgroundColor = UIColor.darkGray
        
        let label = UILabel()
        label.frame = CGRect(x: 30, y: 3, width: tableView.frame.width, height: 18)
        
        let font = UIFont(name: "Avenir Next", size: 18)
        
        
        label.font = font
        
        label.textColor = UIColor.white
        
        if section == 0 {
        
            label.text = "Pågående Spel"
        
        } else {
            
            label.text = "Avslutade Spel"
            
        }
        
        addSubview(label)
    }

}
