//
//  GameCell.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-25.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {

    
    @IBOutlet weak var gameLbl: UILabel!
    @IBOutlet weak var view: UIView!
    
    func setupCell(gameLbl: String) {
        
        self.gameLbl.text = gameLbl
        
    }

}
