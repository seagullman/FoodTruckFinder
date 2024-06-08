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
                .tabItem { Label("List", systemImage: "list.bullet") }
            MapView()
                .tabItem { Label("Map", systemImage: "mappin.and.ellipse") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
            
            if FTFAuthManager.shared.authState == .authenticated {
                OwnerDashboardView()
                    .tabItem { Label("Dashboard", systemImage: "menucard") }
            }
        }
    }
}

#Preview {
    FTFTabView()
}
