//
//  FTFAuthManager.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol FTFAuthManagerDelegate: AnyObject {
    func authStateChanged(to authState: FTFAuthManager.AuthState)
}

class FTFAuthManager {
    
    enum AuthState {
        case authenticated
        case unauthenticated
    }
    
    static let shared = FTFAuthManager()
    
    private let db = Firestore.firestore()
    
    weak var delegate: FTFAuthManagerDelegate?
    
    private init() {
        addAuthStateListener()
    }
    
    var authState: AuthState {
        return (Auth.auth().currentUser != nil) ? .authenticated : .unauthenticated
    }
    
    func loginUser(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = try await getUser(for: authResult.user.uid)
        } catch {
            throw FTFError.invalidCredentials
        }
    }
    
    func getUser(for id: String) async throws -> User? {
        let docRef = db.collection("users").document(id)
        let document = try await docRef.getDocument()
        
        var fetchedUser: User?
        
        if document.exists {
            let user = try document.data(as: User.self)
            fetchedUser = user
        }
        
        return fetchedUser
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
