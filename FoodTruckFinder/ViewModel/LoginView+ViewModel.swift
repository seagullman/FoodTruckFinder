//
//  LoginView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import Foundation
import FirebaseAuth

extension LoginView {
    
    @Observable
    internal class ViewModel {
        
        var alertItem: AlertItem?
        var email: String = ""
        var password: String = ""
        
        func login(username: String, password: String) async {
            do {
                try await FTFAuthManager.shared.loginUser(email: username, password: password)
            } catch {
                switch error {
                case FTFError.invalidCredentials:
                    alertItem = AlertContext.invalidLoginCredentials
                default:
                    alertItem = AlertContext.invalidRequest
                }
            }
        }
    }
}
