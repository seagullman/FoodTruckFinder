//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FoodTruckFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var sharedDataModel = SharedDataModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var foodTruckStore = FoodTruckStore(httpClient: NetworkManager.shared) // TODO: Singleton necessary or no?
    @State private var selection: TabScreen?
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.userSession != nil {
                FTFTabView(selection: $selection)
                    .tint(.red)
                    .environmentObject(sharedDataModel)
                    .environment(foodTruckStore)
            } else {
                LoginView()
            }
        }.environmentObject(authViewModel)
    }
}
