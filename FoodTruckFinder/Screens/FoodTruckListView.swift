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
        if let location = viewModel.locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
