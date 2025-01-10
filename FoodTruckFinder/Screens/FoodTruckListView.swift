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
    @EnvironmentObject var sharedDataModel: SharedDataModel
    @State var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.foodTruckListItems, id: \.id) { listItem in
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
            .disabled(viewModel.isLoading)
            .refreshable { viewModel.locationManager.refreshLocation() }
            .navigationTitle("Food Trucks")
            .toolbar {
                ToolbarItem {
                    ListViewToolbarView(isLoading: false)
                }
            }
            .onChange(of: viewModel.locationManager.lastLocation) {
                Task { await fetchFoodTrucks() }
            }
            .onChange(of: sharedDataModel.distance) {
                Task { await fetchFoodTrucks() }
            }
            
            if viewModel.isLoading {
                ProgressView {
                    Text("Looking for food trucks near you...")
                }
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.large)
            }
        }
    }
    
    func fetchFoodTrucks() async {
        // TODO: add error handling
        if let location = viewModel.locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
