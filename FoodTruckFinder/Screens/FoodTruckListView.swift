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
            List {
                ForEach(foodTruckStore.foodTruckListItems, id: \.id) { listItem in
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
            .disabled(foodTruckStore.isLoading)
            .refreshable { foodTruckStore.locationManager.refreshLocation() }
            .navigationTitle("Food Trucks")
            .toolbar {
                ToolbarItem {
                    ListViewToolbarView(isLoading: false)
                }
            }
            .onChange(of: foodTruckStore.locationManager.lastLocation) {
                Task { await fetchFoodTrucks() }
            }
            .onChange(of: sharedDataModel.distance) {
                Task { await fetchFoodTrucks() }
            }
            
            if foodTruckStore.isLoading {
                ProgressView {
                    Text("Looking for food trucks near you...")
                }
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.large)
            }
        }
        .task {
            if !initialLoadComplete {
                foodTruckStore.locationManager.refreshLocation()
                initialLoadComplete = true
            }
        }
    }
    
    func fetchFoodTrucks() async {
        // TODO: add error handling
        if let location = foodTruckStore.locationManager.lastLocation {
            await foodTruckStore.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
