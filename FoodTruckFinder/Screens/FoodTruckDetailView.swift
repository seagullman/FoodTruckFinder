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
    
    let foodTruckId: String
    let distanceInMiles: Double
    
    
    var body: some View {
        ScrollView {
            switch foodTruckStore.foodTruckLoadingState {
            case .loading:
                FullScreenLoadingView()
            case .loaded(let foodTruck):
                if let foodTruck {
                    detailView(foodTruck: foodTruck)
                } else {
                    // TODO: show error view
                }
            case .failed(let error):
                // TODO: change this parameter to use AlertContext and set a variable to the alert to show an error alert
                EmptyView()
            }
        }
        .task(id: foodTruckId) {  // ✅ This ensures it only runs when foodTruckId changes
            await foodTruckStore.fetchFoodTruckBy(id: foodTruckId)
        }
        // TODO: fix this, maybe make the region a published var or add it to a tuple with the LoadingState enum
//        .onChange(of: foodTruckStore.foodTruck) {
//            // Center the map pin in the center of the header
//            guard let region = foodTruckStore.mapRegionForFoodTruckLocation() else { return }
//            
//            cameraPosition = .region(region)
//        }
        .navigationBarTitleDisplayMode(.inline)
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
