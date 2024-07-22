//
//  FTFTabView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

struct FTFTabView: View {
    
    var body: some View {
        TabView {
            FoodTruckListView()
                .tabItem { Label("Food Trucks", systemImage: "truck.box") }
            MapView()
                .tabItem { Label("Map", systemImage: "mappin.and.ellipse") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    FTFTabView()
}
