//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import MapKit

struct FoodTruckDetailView: View {
    
    let foodTruckId: String
    let distanceInMiles: Double
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var viewModel = ViewModel()
    @Binding var navigationPath: [FTNavigationPath]
    
    var body: some View {
        ScrollView {
            if let foodTruck = viewModel.foodTruck {
                VStack {
                    FoodTruckDetailHeaderView(
                        foodTruck: foodTruck,
                        distanceInMiles: distanceInMiles,
                        navigationPath: $navigationPath,
                        cameraPosition: $cameraPosition)
                    
                    // MARK: Menu
                    
                    MenuView(menuCategories: foodTruck.menu)
                        .padding(.top, 20)
                }
                .padding(10)
                
            } else {
                FullScreenLoadingView()
            }
        }
        .onAppear { Task { await viewModel.fetchFoodTruckBy(id: foodTruckId) } }
        .onChange(of: viewModel.foodTruck) {
            // Center the map pin in the center of the header
            guard let region = viewModel.mapRegionForFoodTruckLocation() else { return }
            
            cameraPosition = .region(region)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234", distanceInMiles: 12.5, navigationPath: .constant([]))
}
