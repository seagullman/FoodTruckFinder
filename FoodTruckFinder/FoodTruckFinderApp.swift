//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import FirebaseCore

@main
struct FoodTruckFinderApp: App {
    
    @StateObject private var sharedDataModel = SharedDataModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.userSession != nil {
                FTFTabView()
                    .tint(.red)
                    .environmentObject(sharedDataModel)
            } else {
                RegistrationView() // Make this LoginView and have LoginView have a link to create an account
            }
        }.environmentObject(authViewModel)
    }
}
