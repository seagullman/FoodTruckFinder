//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import MapKit

struct FoodTruckDetailView: View {
    
    @Environment(FoodTruckStore.self) private var foodTruckStore
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var initialLoadComplete: Bool = false // TODO: figure out a better solution than using a bool
    
    let foodTruckId: String
    let distanceInMiles: Double
    
    var body: some View {
        ZStack {
            switch foodTruckStore.foodTruckLoadingState {
            case .loading:
                FullScreenLoadingView()
            case .loaded(let foodTruck):
                loadedView(foodTruck: foodTruck)
            case .failed(let error):
                // TODO: change this parameter to use AlertContext and set a variable to the alert to show an error alert
                EmptyView()
            }
        }
        .task(id: foodTruckId) {
            print("🔍 FoodTruckDetailView: Loading food truck with ID: \(foodTruckId)")
            // Always fetch the food truck by ID to ensure we get the correct one
            await foodTruckStore.fetchFoodTruckBy(id: foodTruckId)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func loadedView(foodTruck: FoodTruck?) -> some View {
        if let foodTruck {
            ScrollView {
                // Center the map pin in the center of the header
                detailView(foodTruck: foodTruck)
                    .task {
                        if let region = await foodTruckStore.mapRegionForFoodTruck(location: foodTruck.location) {
                            cameraPosition = .region(region)
                        }
                    }
            }
        } else {
            // TODO: show error view
            EmptyView()
        }
    }
    
    private func detailView(foodTruck: FoodTruck) -> some View {
        VStack {
            FoodTruckDetailHeaderView(
                cameraPosition: $cameraPosition,
                foodTruck: foodTruck,
                distanceInMiles: distanceInMiles)
            
            // MARK: Menu
            
            MenuView(menuCategories: foodTruck.menu)
                .padding(.top, 20)
        }
        .padding(10)
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234", distanceInMiles: 12.5)
}
