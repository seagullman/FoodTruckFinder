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
    case loading
}

@Observable
class ViewRouter: FTFAuthManagerDelegate {
    
    var currentScreen: Screen = .loading

    init() {
        FTFAuthManager.shared.delegate = self
    }
    
    // MARK: FTFAuthManagerDelegate
    
    func authStateChanged(to authState: FTFAuthManager.AuthState) {
        switch authState {
        case .authenticated:
            // TODO: check to see if user is a customer or food truck owner
            currentScreen = .ownerDashboard
        case .unauthenticated:
            currentScreen = .login
        }
    }
}
