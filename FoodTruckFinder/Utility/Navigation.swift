//
//  Navigation.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/8/25.
//

import SwiftUI

enum FoodTruckRoute: Hashable {
    case list
    case detail(id: String, distanceInMiles: Double)
    case info(name: String, location: FTFLocation, closingTimeDateString: String?)
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .list:
            FoodTruckNavigationStack()
        case .detail(let id, let distanceInMiles):
            FoodTruckDetailView(foodTruckId: id, distanceInMiles: distanceInMiles)
        case .info(let name, let location, let closingTimeDateString):
            FoodTruckDetailNavigationView(name: name, location: location, openUntil: closingTimeDateString)
        }
    }
}

// Each case is a seperate tab in the TabView

enum TabScreen: Hashable, Identifiable, CaseIterable {
    case list
    case map
    case settings
    
    var id: TabScreen { self }
    
    @ViewBuilder
    var label: some View {
        switch self {
        case .list:
            Label("Food Trucks", systemImage: "truck.box")
        case .map:
            Label("Map", systemImage: "mappin.and.ellipse")
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .list:
            FoodTruckNavigationStack()
        case .map:
            MapView()
        case .settings:
            SettingsView()
        }
    }
}

enum Route: Hashable {
    case foodTruck(FoodTruckRoute)
    
    var destination: some View {
        switch self {
        case .foodTruck(let foodTruckRoute):
            foodTruckRoute.destination
        }
    }
}

struct NavigateAction {
    typealias Action = (Route) -> ()
    
    let action: Action
    
    func callAsFunction(_ route: Route) {
        action(route)
    }
}

struct NavigateEnvironmentKey: EnvironmentKey {
    static var defaultValue: NavigateAction = NavigateAction { _ in }
}

extension EnvironmentValues {
    var navigate: NavigateAction {
        get { self[NavigateEnvironmentKey.self] }
        set { self[NavigateEnvironmentKey.self] = newValue }
    }
}
