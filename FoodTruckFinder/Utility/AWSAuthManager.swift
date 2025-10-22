//
//  AWSAuthManager.swift
//  FoodTruckFinder
//
//  AWS Cognito Authentication Manager
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

class AWSAuthManager {
    
    static let shared = AWSAuthManager()
    
    weak var delegate: FTFAuthManagerDelegate?
    
    private init() {
        configureAmplify()
        setupAuthListener()
    }
    
    var authState: FTFAuthManager.AuthState {
        Task {
            let session = try? await Amplify.Auth.fetchAuthSession()
            return session?.isSignedIn == true ? .authenticated : .unauthenticated
        }
        return .unauthenticated
    }
    
    // MARK: - Configuration
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
    
    private func setupAuthListener() {
        Task {
            for await authEvent in Amplify.Hub.publisher(for: .auth).values {
                switch authEvent.eventName {
                case HubPayload.EventName.Auth.signedIn:
                    await MainActor.run {
                        delegate?.authStateChanged(to: .authenticated)
                    }
                    
                case HubPayload.EventName.Auth.signedOut:
                    await MainActor.run {
                        delegate?.authStateChanged(to: .unauthenticated)
                    }
                    
                case HubPayload.EventName.Auth.sessionExpired:
                    await MainActor.run {
                        delegate?.authStateChanged(to: .unauthenticated)
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String) async throws {
        let userAttributes = [
            AuthUserAttribute(.email, value: email),
            AuthUserAttribute(.name, value: name)
        ]
        
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        let result = try await Amplify.Auth.signUp(
            username: email,
            password: password,
            options: options
        )
        
        if case .confirmUser = result.nextStep {
            // User needs to confirm email
            print("✅ Sign up successful. Please confirm your email.")
        }
    }
    
    func confirmSignUp(email: String, code: String) async throws {
        try await Amplify.Auth.confirmSignUp(
            for: email,
            confirmationCode: code
        )
        print("✅ Email confirmed successfully")
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Amplify.Auth.signIn(
            username: email,
            password: password
        )
        
        if result.isSignedIn {
            print("✅ Sign in successful")
        }
    }
    
    func signOut() async throws {
        _ = await Amplify.Auth.signOut()
        print("✅ Sign out successful")
    }
    
    func resetPassword(email: String) async throws {
        try await Amplify.Auth.resetPassword(for: email)
        print("✅ Password reset code sent")
    }
    
    func confirmResetPassword(email: String, newPassword: String, code: String) async throws {
        try await Amplify.Auth.confirmResetPassword(
            for: email,
            with: newPassword,
            confirmationCode: code
        )
        print("✅ Password reset successful")
    }
    
    func getCurrentUser() async throws -> AuthUser {
        return try await Amplify.Auth.getCurrentUser()
    }
    
    func getUserAttributes() async throws -> [AuthUserAttribute] {
        return try await Amplify.Auth.fetchUserAttributes()
    }
    
    func updateUserAttribute(key: AuthUserAttributeKey, value: String) async throws {
        try await Amplify.Auth.update(userAttribute: AuthUserAttribute(key, value: value))
        print("✅ User attribute updated")
    }
    
    func deleteUser() async throws {
        try await Amplify.Auth.deleteUser()
        print("✅ User deleted")
    }
}

// MARK: - Convenience Extensions

extension AWSAuthManager {
    
    func isAuthenticated() async -> Bool {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            return session.isSignedIn
        } catch {
            return false
        }
    }
    
    func getUserId() async throws -> String {
        let user = try await getCurrentUser()
        return user.userId
    }
    
    func getUserEmail() async throws -> String? {
        let attributes = try await getUserAttributes()
        return attributes.first(where: { $0.key == .email })?.value
    }
}
