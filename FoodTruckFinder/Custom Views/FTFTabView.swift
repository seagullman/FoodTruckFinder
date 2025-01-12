//
//  FTFTabView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

struct FTFTabView: View {
    
    @Binding var selection: TabScreen?
    
    var body: some View {
        TabView {
            ForEach(TabScreen.allCases) { screen in
                screen.destination
                    .tag(screen as TabScreen)
                    .tabItem { screen.label }
            }
        }
    }
}

#Preview {
    FTFTabView(selection: .constant(.list))
}
