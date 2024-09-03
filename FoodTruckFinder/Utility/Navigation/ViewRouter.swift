//
//  ViewRouter.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI

enum Screen {
    case login
    case foodTruckList
    case createFoodTruck
    case loading
}

class ViewRouter: FTFAuthManagerDelegate {
    
    var currentScreen: Screen = .loading

    init() {
        FTFAuthManager.shared.delegate = self
    }
    
    // MARK: FTFAuthManagerDelegate
    
    func authStateChanged(to authState: FTFAuthManager.AuthState) {
        switch authState {
        case .authenticated:
            // Upon authenticating, check to see if this is the user's (food truck owner) first
            // time signing in. If so, they need to enter food truck information.
            Task {
                let foodTruckRegistered = try await FTFAuthManager.shared.userHasRegisteredFoodTruck()
                
                if foodTruckRegistered {
                    currentScreen = .foodTruckList
                } else {
                    currentScreen = .createFoodTruck
                }
            }
        case .unauthenticated:
            currentScreen = .foodTruckList
        }
    }
}
