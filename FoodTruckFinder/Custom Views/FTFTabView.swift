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
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen as AppScreen)
                    .tabItem { screen.label }
            }
        }
    }
}

#Preview {
    FTFTabView()
}
