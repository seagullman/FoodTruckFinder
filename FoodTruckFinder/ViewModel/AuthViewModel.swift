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

enum LoadingState {
    case loading
    case loaded
    case failed(Error)
}

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var userSession: AuthUser?
    @Published var currentUser: User?
    @Published var shouldNavigateToConfirmCodeScreen: Bool = false
    @Published var loadingState: LoadingState = .loading
    
    init() {
        Task {
            await checkAuthSession()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        try await withLoadingState {
            let signInResult = try await Amplify.Auth.signIn(username: email, password: password)
            if signInResult.isSignedIn {
                print("DEBUG: User signed in successfully")
                await self.fetchUser()
            } else {
                print("DEBUG: Additional steps required for sign-in")
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String, phoneNumber: String) async throws {
        try await withLoadingState {
            let userAttributes = [
                AuthUserAttribute(.email, value: email),
                AuthUserAttribute(.name, value: fullName),
                AuthUserAttribute(.phoneNumber, value: phoneNumber)
            ]
            let signUpResult = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: .init(userAttributes: userAttributes)
            )
            
            switch signUpResult.nextStep {
            case .done:
                print("✅ DEBUG: Sign-up complete")
            case .confirmUser(_, _, _):
                print("✅ DEBUG: Confirmation required. Please check your email for the verification code.")
                self.shouldNavigateToConfirmCodeScreen = true
            case .completeAutoSignIn(let session):
                print("***** \(session)")
            }
        }
    }
    
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        try await withLoadingState {
            let confirmResult = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: confirmationCode)
            if confirmResult.isSignUpComplete {
                print("DEBUG: User confirmed successfully")
            } else {
                print("DEBUG: User confirmation incomplete")
            }
        }
    }
    
    func signOut() async {
        try? await withLoadingState {
            _ = try await Amplify.Auth.signOut()
            self.userSession = nil
            self.currentUser = nil
            print("DEBUG: User signed out successfully")
        }
    }
    
    func deleteAccount() async throws {
        try await withLoadingState {
            try await Amplify.Auth.deleteUser()
            self.userSession = nil
            self.currentUser = nil
            print("DEBUG: User account deleted successfully")
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        try await withLoadingState {
            let resetResult = try await Amplify.Auth.resetPassword(for: email)
            if resetResult.isPasswordReset {
                print("DEBUG: Password reset complete")
            } else {
                print("DEBUG: Further steps needed for password reset")
            }
        }
    }
    
    func fetchUser() async {
        try? await withLoadingState {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            let email = attributes.first(where: { $0.key == .email })?.value
            let name = attributes.first(where: { $0.key == .name })?.value
            
            self.currentUser = User(
                id: self.userSession?.userId ?? "Unknown",
                type: .customer,
                email: email ?? "No Email",
                fullName: name ?? "No Name"
            )
        }
    }
    
    func checkAuthSession() async {
        try? await withLoadingState {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                self.userSession = try await Amplify.Auth.getCurrentUser()
                await self.fetchUser()
            } else {
                self.userSession = nil
            }
        }
    }
}

@MainActor
extension AuthViewModel {
    private func withLoadingState<T>(
        task: @escaping () async throws -> T
    ) async rethrows -> T? {
        loadingState = .loading
        do {
            let result = try await task()
            loadingState = .loaded
            return result
        } catch {
            loadingState = .failed(error)
            throw error
        }
    }
}
