//
//  FoodTruckListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FoodTruckListView: View {
    
    @State private var viewModel = ViewModel()
    @State private var currentTask: Task<Void, Never>?
    @State private var isInitialLoad = true
    
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach(viewModel.foodTruckListItems, id: \.id) { listItem in
                        NavigationLink(destination: FoodTruckDetailView(foodTruckId: listItem.id, distanceInMiles: listItem.distanceInMiles)) {
                            FoodTruckListCell(listItem: listItem)
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
                Task { runFetchFoodTrucksTask() }
            }
            .onChange(of: sharedDataModel.distance) {
                Task { runFetchFoodTrucksTask() }
            }
            .onAppear {
                if isInitialLoad {
                    Task { runFetchFoodTrucksTask() }
                    self.isInitialLoad = false
                }
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
    
    private func runFetchFoodTrucksTask() {
            currentTask?.cancel()
            currentTask = Task { await fetchFoodTrucks() }
        }
    
    private func fetchFoodTrucks() async {
        if let location = viewModel.locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
