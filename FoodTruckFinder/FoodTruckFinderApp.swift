//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import FirebaseCore
import Amplify
import AWSCognitoAuthPlugin
import Authenticator

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
    @State private var authViewModel = AuthViewModel()
    @State private var foodTruckStore = FoodTruckStore(httpClient: NetworkManager.shared) // TODO: Singleton necessary or no?
    @State private var selection: TabScreen?
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            ConfirmCodeView() // TODO: remove
            switch authViewModel.loadingState {
            case .loading:
                FullScreenLoadingView() // TODO: customize this
            case .loaded:
                if authViewModel.userSession != nil {
                    
                    FTFTabView(selection: $selection)
                        .tint(.red)
                        .environmentObject(sharedDataModel)
                        .environment(foodTruckStore)
                    
                } else {
                    LoginView()
                }
            case .failed(let error):
                // TODO: handle error /  maybe a retry button or just show login
                EmptyView()
            }
        }.environment(authViewModel)
    }
    
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
}
