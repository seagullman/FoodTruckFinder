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
    
    private let viewModel = ViewModel()
    @Binding var navigationPath: [FTNavigationPath]
    
    var body: some View {
        ScrollView {
            if let foodTruck = viewModel.foodTruck {
                FoodTruckDetailHeaderView(
                    foodTruck: foodTruck,
                    distanceInMiles: distanceInMiles,
                    navigationPath: $navigationPath,
                    cameraPosition: $cameraPosition)
            } else {
                FullScreenLoadingView()
            }
        }
        .onAppear { Task { await viewModel.fetchFoodTruckBy(id: foodTruckId) } }
        .onChange(of: viewModel.foodTruck) { oldValue, newValue in
            // Center the map pin in the center of the header
            if let foodTruck = viewModel.foodTruck {
                let location = CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude)
                let locationSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location, span: locationSpan)
                cameraPosition = .region(region)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234", distanceInMiles: 12.5, navigationPath: .constant([]))
}
