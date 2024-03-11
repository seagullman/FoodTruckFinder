//
//  FTFAuthManager.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import Foundation
import FirebaseAuth


class FTFAuthManager {
    
    static let shared = FTFAuthManager()
    
    private init() {}
    
    enum AuthState {
        case authenticated
        case unauthenticated
    }
    
    var authState: AuthState {
        return (Auth.auth().currentUser != nil) ? .authenticated : .unauthenticated
    }
    
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [ weak self ] authResult, error in
            guard let strongSelf = self else { return }
          
            if let authResult {
                print("***** user")
                print(authResult.user.email ?? "no email on file")
                let user = User(type: .customer, foodTruck: nil, email: authResult.user.email ?? "", phoneNumber: "7084445566")
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
