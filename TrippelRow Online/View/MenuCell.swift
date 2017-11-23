//
//  MenuCell.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-23.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    
    func setupCell(image: String, label: String) {
        
        menuLabel.text = label
        menuImage.image = UIImage(named: image)
        
    }
    

}
