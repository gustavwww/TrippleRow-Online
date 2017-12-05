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
    
    var userID: String
    var displayName: String
    var email: String
    
    init(userID: String, displayName: String, email: String) {
        
        self.userID = userID
        self.displayName = displayName
        self.email = email
        
    }
    
}
