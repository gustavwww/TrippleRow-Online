//
//  FriendCell.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-28.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet weak var displayNameLbl: UILabel!
    
    func setupCell(displayName: String) {
        displayNameLbl.text = displayName
    }

}
