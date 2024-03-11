//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth



@main
struct FoodTruckFinderApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
//            switch ViewRouter.shared.currentScreen {
//            case .login:
//                LoginView()
//            case .home:
//                FTFListView()
//            case .ownerDashboard:
//                FTOwnerDashboardView()
//            }
//            FTFListView()
            FTOwnerDashboardView()
        }
    }
}
