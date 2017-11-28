//
//  DBUser.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-28.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation

class DBUser {
    
    var displayName: String?
    var userID: String
    
    init(_ userID: String) {
        self.userID = userID
    }
    
}
