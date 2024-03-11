//
//  ViewRouter.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import FirebaseAuth

enum Screen {
    case login
    case home
    case ownerDashboard
}

@Observable
class ViewRouter {
    static let shared = ViewRouter()
    
    var currentScreen: Screen = .login
    
    private var authState: FTFAuthManager.AuthState
    
    private init() {
        authState = FTFAuthManager.shared.authState
        determineCurrentScreen()
    }
    
    // MARK: Private functions
    
    private func determineCurrentScreen() {
        switch authState {
        case .authenticated:
            // TODO: check to see if user is a customer or food truck owner
            currentScreen = .ownerDashboard
        case .unauthenticated:
            currentScreen = .login
        }
    }
}
