//
//  OwnerTabView.swift
//  FoodTruckOwnerApp
//

import SwiftUI

struct OwnerTabView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            CheckInView()
                .tabItem {
                    Label("Check In", systemImage: "location.fill")
                }
                .tag(1)
            
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "list.bullet")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.red)
    }
}
