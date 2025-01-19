//
//  AuthViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/28/24.
//
import Foundation
import Amplify

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

// Move this to a more general location if reused elsewhere
enum LoadingState<T> {
    case loading
    case loaded(T)
    case failed(Error)
}

@MainActor
@Observable
class AuthViewModel {
    
    var userSession: AuthUser? // AWS Cognito user
    var currentUser: User? // FoodTruckFinder user
    var shouldNavigateToConfirmCodeScreen:  Bool = false
    var loadingState: LoadingState<Void> = .loading
    
    init() {
        Task { await checkAuthSession() }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        try await withLoadingState {
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
            if signInResult.isSignedIn {
                print("✅ User signed in successfully")
                try await self.fetchUser()
            } else {
                print("⚠️ Additional steps required for sign-in")
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        try await withLoadingState {
            let userAttributes: [AuthUserAttribute] = [
                .init(.email, value: email),
                .init(.name, value: fullName)
            ]
            let signUpResult = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: .init(userAttributes: userAttributes)
            )
            
            switch signUpResult.nextStep {
            case .done:
                print("✅ Sign-up complete")
            case .confirmUser:
                print("📩 Confirmation required. Check email for verification code.")
                self.shouldNavigateToConfirmCodeScreen = true
            case .completeAutoSignIn(let session):
                print("🔄 Auto sign-in session: \(session)")
            }
        }
    }
    
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        try await withLoadingState {
            let confirmResult = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode)
            if confirmResult.isSignUpComplete {
                print("✅ User confirmed successfully")
            } else {
                print("⚠️ User confirmation incomplete")
            }
        }
    }
    
    func signOut() async {
        do {
            try await withLoadingState {
                _ = await Amplify.Auth.signOut()
                self.userSession = nil
                self.currentUser = nil
                print("🚪 User signed out successfully")
            }
        } catch {
            // TODO: handle error
            print("⚠️ Error signing out: \(error.localizedDescription)")
            loadingState = .failed(error)
        }
    }
    
    func deleteAccount() async throws {
        try await withLoadingState {
            try await Amplify.Auth.deleteUser()
            self.userSession = nil
            self.currentUser = nil
            print("🗑️ User account deleted successfully")
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        try await withLoadingState {
            let resetResult = try await Amplify.Auth.resetPassword(for: email)
            print(resetResult.isPasswordReset ? "✅ Password reset complete" : "⚠️ Further steps needed for password reset")
        }
    }
    
    func fetchUser() async throws {
        try await withLoadingState {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            let email = attributes.first(where: { $0.key == .email })?.value ?? "No Email"
            let name = attributes.first(where: { $0.key == .name })?.value ?? "No Name"
            
            self.userSession = try await Amplify.Auth.getCurrentUser()
            self.currentUser = User(
                id: self.userSession?.userId ?? "Unknown",
                type: .customer,
                email: email,
                fullName: name
            )
        }
    }
    
    func checkAuthSession() async {
        do {
            try await withLoadingState {
                let session = try await Amplify.Auth.fetchAuthSession()
                if session.isSignedIn {
                    self.userSession = try await Amplify.Auth.getCurrentUser()
                    try await self.fetchUser()
                } else {
                    self.userSession = nil
                }
            }
        } catch {
            // TODO: handle error
            print("⚠️ Error checking authentication session: \(error.localizedDescription)")
            loadingState = .failed(error)
        }
    }
}

@MainActor
extension AuthViewModel {
    private func withLoadingState<T>(
        task: @escaping () async throws -> T
    ) async throws -> T {
        loadingState = .loading
        do {
            let result = try await task()
            loadingState = .loaded(())
            return result
        } catch {
            loadingState = .failed(error)
            throw error
        }
    }
}
