//
//  AuthService.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/12.
//

import Foundation
import FirebaseAuth


class AuthService : ObservableObject {
    let auth = Auth.auth()
    
    var user: User? = nil

    init() {
        auth.addStateDidChangeListener { auth, user in
            print("user: " + (user?.uid ?? "nil"))
            self.user = user
        }
        
        auth.signInAnonymously { authResult, error in
            print(authResult)
        }
    }
    public func registerGoogle() {
        
    }
}
