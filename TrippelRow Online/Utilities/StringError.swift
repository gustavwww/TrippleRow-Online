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
    case DisplayNameChangeError = "Ett fel inträffade vid ditt användarnamn."
    case SignOutError = "Ett fel inträffade vid utloggning, försök igen senare."
    case SendFriendRequestError = "Ett fel inträffade när vänförfrågan skulle skickas."
    case SingleObserveError = "Kunde inte hämta data från databasen, försök igen senare."
    case FriendRequestAlreadySent = "Spelaren inväntar din vänförfrågan."
    
    //Registration
    case CreateUserError = "Ett fel inträffade vid registrering, försök igen senare."
    case FillEveryField = "Var vänlig och fyll i alla fällt för att slutföra registreringen."
    case UsernameInvalidLength = "Användarnamnet måste vara mellan 4 och 15 tecken."
    case PasswordInvalidLength = "Lösenorden måste bestå utav minst 6 tecken."
    case PasswordDoesntMatch = "Lösenordet matchar inte."
    case InvalidEmail = "Email adressen är inte fullständig."
    case UsernameAlreadyTaken = "Användarnamnet finns redan, var god och välj ett annat."
}

struct StringError: LocalizedError {
    
    var stringDescription: String
    
    init(_ errorType: ErrorType) {
        self.stringDescription = errorType.rawValue
    }
    
}
