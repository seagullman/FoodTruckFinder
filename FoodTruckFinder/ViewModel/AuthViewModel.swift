//
//  AuthViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User? // firebase user
    @Published var currentUser: User?               // custom user object
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task { await fetchUser() }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(id: result.user.uid, type: .customer, email: email, fullName: fullName)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        Auth.auth().currentUser?.delete()
        self.userSession = nil
        self.currentUser = nil
    }
    
    func resetPassword(withEmail email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("DEBUG: Failed to send password reset with error: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard 
            let uid = Auth.auth().currentUser?.uid,
            let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        else { return }
        
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
