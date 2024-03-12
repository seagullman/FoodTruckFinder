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
            case .home:
                FTFListView()
            case .ownerDashboard:
                FTOwnerDashboardView()
            case .loading:
                // Displayed before/while the auth state is being determined
                FullScreenLoadingView()
            }
        }
//            switch viewRouter.currentScreen {
//            case .login:
//                FTFListView()
//            case .home:
//                FTFListView()
//            case .ownerDashboard:
//                FTOwnerDashboardView()
//            }
////            FTOwnerDashboardView()
//        }
//        .environment(viewRouter)
    }
}
