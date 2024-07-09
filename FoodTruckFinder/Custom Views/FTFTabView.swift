//
//  FTFTabView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

enum Tab {
    case list
    case map
    case settings
}

struct FTFTabView: View {
    
    @State var selectedTab: Tab = .list
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FoodTruckListView()
                .tabItem { Label("Food Trucks", systemImage: "truck.box") }
                .tag(Tab.list)
            MapView()
                .tabItem { Label("Map", systemImage: "mappin.and.ellipse") }
                .tag(Tab.map)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .onAppear {
            selectedTab = .list
        }
    }
}

#Preview {
    FTFTabView()
}
