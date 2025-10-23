//
//  AuthStore.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//
import Foundation
import FirebaseAuth
// import Amplify  // Temporarily disabled due to Xcode 16 compatibility issues

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
@Observable
class AuthStore {
    
    var userSession: FirebaseAuth.User? // Firebase user (temporary until Amplify is fixed)
    var currentUser: User? // FoodTruckFinder user
    var loadingState: AuthLoadingState = .loading
    
    init() {
        Task { await checkAuthSession() }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            try await withLoadingState {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                self.userSession = authResult.user
                print("✅ User signed in successfully")
                try await self.fetchUser()
            }
        } catch {
            print("⚠️ Error signing in: \(error.localizedDescription)")
            loadingState = .failed(AlertContext.invalidRequest)
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            try await withLoadingState {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = authResult.user
                
                // Update display name
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                try await changeRequest.commitChanges()
                
                print("✅ Sign-up complete")
                try await self.fetchUser()
            }
        } catch {
            print("⚠️ Error signing up: \(error.localizedDescription)")
            loadingState = .failed(AlertContext.invalidRequest)
            throw error
        }
    }
    
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        // Firebase doesn't require email confirmation by default
        // This method is kept for compatibility but does nothing
        print("✅ Email confirmation not required with Firebase")
    }
    
    func signOut() async {
        do {
            try await withLoadingState {
                try Auth.auth().signOut()
                self.userSession = nil
                self.currentUser = nil
                print("🚪 User signed out successfully")
            }
        } catch {
            print("⚠️ Error signing out: \(error.localizedDescription)")
            loadingState = .failed(AlertContext.invalidRequest)
        }
    }
    
    func deleteAccount() async throws {
        try await withLoadingState {
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
            print("🗑️ User account deleted successfully")
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        try await withLoadingState {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("✅ Password reset email sent")
        }
    }
    
    func fetchUser() async throws {
        try await withLoadingState {
            guard let firebaseUser = Auth.auth().currentUser else {
                throw NSError(domain: "AuthStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            }
            
            self.userSession = firebaseUser
            self.currentUser = User(
                id: firebaseUser.uid,
                type: .customer,
                email: firebaseUser.email ?? "No Email",
                fullName: firebaseUser.displayName ?? "No Name"
            )
        }
    }
    
    func checkAuthSession() async {
        do {
            try await withLoadingState {
                if let firebaseUser = Auth.auth().currentUser {
                    self.userSession = firebaseUser
                    try await self.fetchUser()
                } else {
                    self.userSession = nil
                    self.currentUser = nil
                }
            }
        } catch {
            print("⚠️ Error checking authentication session: \(error.localizedDescription)")
            loadingState = .failed(AlertContext.invalidRequest)
        }
    }
}

@MainActor
extension AuthStore {
    private func withLoadingState<T>(
        task: @escaping () async throws -> T
    ) async throws -> T {
        loadingState = .loading
        do {
            let result = try await task()
            loadingState = .loaded
            return result
        } catch {
            loadingState = .failed(AlertContext.invalidRequest) // TODO: change this param
            throw error
        }
    }
}
