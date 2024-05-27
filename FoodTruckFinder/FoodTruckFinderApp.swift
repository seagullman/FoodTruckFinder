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
            FTFTabView()
        }
    }
}
