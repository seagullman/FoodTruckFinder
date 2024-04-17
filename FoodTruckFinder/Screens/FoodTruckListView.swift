//
//  FoodTruckListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FoodTruckListView: View {
    
    @State var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.navigationPath) {
                List {
                    ForEach(viewModel.foodTrucks, id: \.id) { foodTruck in
                        NavigationLink(destination: FoodTruckDetailView(foodTruck: foodTruck)) {
                            FoodTruckListCell(
                                foodTruck: foodTruck,
                                distanceFromUserLocation: viewModel.currentDistance(
                                    from: foodTruck,
                                    currentUserLocation: viewModel.locationManager.lastLocation
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
                        ListViewToolbarView(distance: $viewModel.distance, isLoading: false)
                    }
                }
            }
            .onChange(of: viewModel.locationManager.lastLocation) {
                Task { await fetchFoodTrucks() }
            }
            .onChange(of: viewModel.distance) {
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
        if let location = viewModel.locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(viewModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
