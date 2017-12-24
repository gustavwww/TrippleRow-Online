//
//  DetailedUser.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-12-05.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation
import UIKit

class DetailedUser {
    
    var userID: String = ""
    var displayName: String = ""
    var email: String = ""
    var status: PlayerStatus = .Offline
    
    init(userID: String, displayName: String, email: String, status: PlayerStatus) {
        
        self.userID = userID
        self.displayName = displayName
        self.email = email
        self.status = status
        
    }
    
    init() {}
    
}
