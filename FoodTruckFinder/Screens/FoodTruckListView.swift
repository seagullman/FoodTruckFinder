//
//  FoodTruckListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FoodTruckNavigationStack: View {
    
    @State private var routes: [FoodTruckRoute] = []
    
    var body: some View {
        NavigationStack(path: $routes) {
            FoodTruckListView()
                .navigationDestination(for: FoodTruckRoute.self) { route in
                    route.destination
                }
        }.environment(\.navigate, NavigateAction(action: { route in
            if case let .foodTruck(foodTruckRoute) = route {
                routes.append(foodTruckRoute)
            }
        }))
    }
}

struct FoodTruckListView: View {
    
    @Environment(\.navigate) private var navigate
    @Environment(FoodTruckStore.self) private var foodTruckStore
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    @State private var initialLoadComplete: Bool = false // TODO: figure out a better solution than using a bool
    
    var body: some View {
        ZStack {
            switch foodTruckStore.foodTruckListLoadingState {
            case .loading:
                loadingView
            case .loaded(let listItems):
                foodTruckItemList(items: listItems)
            case .failed(_):
                // TODO: update with error handling
                EmptyView()
            }
        }
        .onChange(of: foodTruckStore.locationManager.lastLocation) {
            Task { await fetchFoodTrucks() }
        }
        .onChange(of: sharedDataModel.distanceFilterOption) {
            Task { await fetchFoodTrucks() }
        }
        .task {
            if !initialLoadComplete {
                foodTruckStore.locationManager.refreshLocation()
                initialLoadComplete.toggle()
            }
        }
    }
    
    func fetchFoodTrucks() async {
        // TODO: add error handling
        if let location = foodTruckStore.locationManager.lastLocation {
            await foodTruckStore.fetchFoodTrucks(sharedDataModel.distanceFilterOption.value, of: location)
        }
    }
    
    var loadingView: some View {
        ProgressView {
            Text("Looking for food trucks near you...")
        }
        .progressViewStyle(CircularProgressViewStyle())
        .controlSize(.large)
    }
    
    func foodTruckItemList(items: [FoodTruckListItem]) -> some View {
        VStack {
            if items.isEmpty {
                VStack {
                    // TODO: move this to another file
                    ContentUnavailableView {
                        Label("No Food Trucks Found", systemImage: "magnifyingglass")
                        
                    } description: {
                        Text("Try expanding your search or checking back later — more trucks might roll in soon!")
                        Button {
                            print()
                        } label: {
                            Text("Expand Search Area")
                                .padding(5)
                        }.buttonStyle(.bordered).tint(.secondary)
                    }
                }
            } else {
                List {
                    ForEach(items, id: \.id) { listItem in
                        FoodTruckListCell(listItem: listItem)
                            .onTapGesture {
                                navigate(
                                    .foodTruck(
                                        .detail(
                                            id: listItem.id,
                                            distanceInMiles: listItem.distanceInMiles
                                        )
                                    )
                                )
                            }
                    }
                }
                .refreshable { foodTruckStore.locationManager.refreshLocation() }
            }
        }
        .navigationTitle("Food Trucks")
        .toolbar {
            ToolbarItem {
                ListViewToolbarView(isLoading: false)
            }
        }
    }
}

#Preview {
    FoodTruckListView()
}
