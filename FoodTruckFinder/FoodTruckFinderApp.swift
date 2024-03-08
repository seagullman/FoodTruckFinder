//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct FoodTruckFinderApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            FTFTabView()
        }
    }
}
