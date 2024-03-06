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
            FTFListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            FTFMapView()
                .tabItem {
                    Label("Map", systemImage: "mappin.and.ellipse")
                }
        }
    }
}

#Preview {
    FTFTabView()
}
