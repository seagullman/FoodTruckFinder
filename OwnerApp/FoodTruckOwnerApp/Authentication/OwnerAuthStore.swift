//
//  OwnerAuthStore.swift
//  FoodTruckOwnerApp
//

import Foundation
import Amplify
import Observation

@MainActor
@Observable
class OwnerAuthStore {
    
    var isAuthenticated = false
    var currentUser: AuthUser?
    var isLoading = false
    var errorMessage: String?
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔐 Attempting sign in for: \(email)")
            let result = try await Amplify.Auth.signIn(username: email, password: password)
            
            print("📝 Sign in result: \(result)")
            
            if result.isSignedIn {
                isAuthenticated = true
                currentUser = try await Amplify.Auth.getCurrentUser()
                print("✅ Owner signed in: \(email)")
            } else {
                print("⚠️ Sign in returned but not fully signed in. Next step: \(result.nextStep)")
            }
        } catch let error as AuthError {
            print("❌ Auth error: \(error)")
            print("❌ Error description: \(error.errorDescription)")
            print("❌ Recovery suggestion: \(error.recoverySuggestion)")
            errorMessage = error.errorDescription
            throw error
        } catch {
            print("❌ Unknown error: \(error)")
            errorMessage = "Invalid credentials. Please check your email and password."
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            _ = await Amplify.Auth.signOut()
            isAuthenticated = false
            currentUser = nil
            print("✅ Owner signed out")
        } catch {
            print("❌ Sign out error: \(error)")
        }
    }
    
    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            isAuthenticated = session.isSignedIn
            
            if isAuthenticated {
                currentUser = try await Amplify.Auth.getCurrentUser()
            }
        } catch {
            isAuthenticated = false
            print("❌ Auth check error: \(error)")
        }
    }
    
    func getUserId() async throws -> String {
        guard let user = currentUser else {
            let user = try await Amplify.Auth.getCurrentUser()
            return user.userId
        }
        return user.userId
    }
}
