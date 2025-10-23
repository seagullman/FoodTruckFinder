//
//  FoodTruckOwnerAppApp.swift
//  FoodTruckOwnerApp
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct FoodTruckOwnerAppApp: App {
    
    @State private var authStore = OwnerAuthStore()
    @State private var truckStore: TruckStore?
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authStore.isAuthenticated {
                    if let truckStore = truckStore {
                        OwnerTabView()
                            .environment(truckStore)
                            .environment(authStore)
                    } else {
                        LoadingView(message: "Loading your truck...")
                            .task {
                                await loadTruckData()
                            }
                    }
                } else {
                    LoginView()
                        .environment(authStore)
                }
            }
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("✅ Amplify configured")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
    
    private func loadTruckData() async {
        do {
            let userId = try await authStore.getUserId()
            let store = TruckStore(ownerId: userId)
            
            // Load the truck data from API
            try await store.loadTruck()
            
            // Extract truck ID from loaded data
            if let truck = store.truck {
                store.truckId = truck.id
            }
            
            truckStore = store
        } catch {
            print("❌ Failed to load truck: \(error)")
        }
    }
}
