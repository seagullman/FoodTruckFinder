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
    
    let foodTruckId: String
    let distanceInMiles: Double
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var initialLoadComplete: Bool = false // TODO: figure out a better solution than using a bool
    
    var body: some View {
        ScrollView {
            if let foodTruck = foodTruckStore.foodTruck {
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
                
            } else {
                FullScreenLoadingView()
            }
        }
        .onAppear {
            if !initialLoadComplete {
                Task { await foodTruckStore.fetchFoodTruckBy(id: foodTruckId) }
                initialLoadComplete = true
            }
        }
        .onChange(of: foodTruckStore.foodTruck) {
            // Center the map pin in the center of the header
            guard let region = foodTruckStore.mapRegionForFoodTruckLocation() else { return }
            
            cameraPosition = .region(region)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234", distanceInMiles: 12.5)
}
