//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct FoodTruckFinderApp: App {
    
    var viewRouter: ViewRouter
    
    init() {
        FirebaseApp.configure()
        viewRouter = ViewRouter()
    }
    
    var body: some Scene {
        WindowGroup {
            switch viewRouter.currentScreen {
            case .login:
                LoginView()
            case .foodTruckList:
                FTFTabView()
            case .createFoodTruck:
                FTFTabView()
            case .loading:
                // Displayed before/while the auth state is being determined
                FullScreenLoadingView()
            }
        }
    }
}
