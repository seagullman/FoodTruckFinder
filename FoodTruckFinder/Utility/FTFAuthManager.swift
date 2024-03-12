//
//  FTFAuthManager.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import Foundation
import FirebaseAuth

protocol FTFAuthManagerDelegate: AnyObject {
    func authStateChanged(to authState: FTFAuthManager.AuthState)
}

class FTFAuthManager {
    
    enum AuthState {
        case authenticated
        case unauthenticated
    }
    
    static let shared = FTFAuthManager()
    
    weak var delegate: FTFAuthManagerDelegate?
    
    private init() {
        addAuthStateListener()
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
    
    func addAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self else { return  }
            
            if user == nil {
                self.delegate?.authStateChanged(to: .unauthenticated)
            } else {
                // Fetch foodtruck object by user uid and store in locally
                // Fetch User object and store it locally?
                self.delegate?.authStateChanged(to: .authenticated)
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
