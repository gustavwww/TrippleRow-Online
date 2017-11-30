//
//  ConectionErrors.swift
//  TrippelRow Online
//
//  Created by Gustav Wadström on 2017-11-30.
//  Copyright © 2017 Gustav Wadström. All rights reserved.
//

import Foundation

enum ErrorType: String {
    
    case SignInError = "Ett fel inträffade vid inloggning, kontrollera uppgifterna och försök igen."
    case FacebookSignInError = "Ett fel inträffade vid inloggning via Facebook, försök igen senare."
    case CreateUserError = "Ett fel inträffade vid registrering, försök igen senare."
    case DisplayNameChangeError = "Ett fel inträffade vid ditt användarnamn."
    case SignOutError = "Ett fel inträffade vid utloggning, försök igen senare."
    case SendFriendRequestError = "Ett fel inträffade när vänförfrågan skulle skickas."
    case SingleObserveError = "Kunde inte hämta data från databasen, försök igen senare."
    
}

struct StringError: LocalizedError {
    
    var stringDescription: String
    
    init(_ errorType: ErrorType) {
        self.stringDescription = errorType.rawValue
    }
    
}
