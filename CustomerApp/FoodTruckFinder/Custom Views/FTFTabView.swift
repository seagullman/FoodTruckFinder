//
//  FTFTabView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

struct FTFTabView: View {
    
    @Binding var selection: TabScreen?
    @State private var routes: [Route] = []
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(TabScreen.allCases) { screen in
                NavigationStack(path: $routes) {
                    screen.destination
                        .navigationDestination(for: Route.self) { route in
                            route.destination
                        }
                }
                .tag(screen as TabScreen)
                .tabItem { screen.label }
            }
        }
        .environment(\.navigate, NavigateAction { route in
            routes.append(route)
        })
    }
}

// Notification names for tab refresh
extension Notification.Name {
    static let mapTabRefreshRequested = Notification.Name("mapTabRefreshRequested")
    static let listTabRefreshRequested = Notification.Name("listTabRefreshRequested")
}

#Preview {
    FTFTabView(selection: .constant(.list))
}
