//
//  FTFListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FTFListView: View {
    
    @Bindable var viewModel = ViewModel()
    @StateObject var locationManager = LocationManager() // TODO: move this to .app file? or somewhere else and store
    
    @State private var distance: Double = 5.0 // TODO: extract this to constant file
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.foodTrucks, id: \.id) { foodTruck in
                    FoodTruckListCell(
                        foodTruck: foodTruck,
                        distanceFromUserLocation: viewModel.currentDistance(
                            from: foodTruck,
                            currentUserLocation: locationManager.lastLocation
                        )
                    )
                }
            }
            .refreshable {
                locationManager.refreshLocation()
            }
            .navigationTitle("Food Trucks")
            .toolbar {
                Menu("Distance", systemImage: "line.3.horizontal.decrease.circle") {
                    Picker("Distance", selection: $distance) {
                        Text("1 mile")
                            .tag(1.0)
                        
                        Text("5 miles")
                            .tag(5.0)
                        
                        Text("10 miles")
                            .tag(10.0)
                        
                        Text("200 miles")
                            .tag(200.0)
                    }
                }
            }
        }
        .onChange(of: locationManager.lastLocation) {
            Task {
                await fetchFoodTrucks()
            }
        }
        .onChange(of: distance) {
            Task {
                await fetchFoodTrucks()
            }
        }
    }
    
    func fetchFoodTrucks() async {
        if let location = locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(distance, of: location)
        }
    }
}

#Preview {
    FTFListView()
}
