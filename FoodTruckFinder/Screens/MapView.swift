//
//  MapView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var viewModel = ViewModel()
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map {
                ForEach($viewModel.foodTruckListItems.wrappedValue, id: \.id) { result in
                    Marker(coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)) {
                        Text(result.name)
                    }
                }
            }
            
            ListViewToolbarView(isLoading: viewModel.isLoading)
                .frame(width: 150, height: 150)
        }
        .onAppear { fetchFoodTrucks() }
        .onChange(of: sharedDataModel.distanceFilterOption.value) { fetchFoodTrucks() }
    }
    
    func fetchFoodTrucks() {
        if let location = viewModel.locationManager.lastLocation {
            Task { await viewModel.fetchFoodTrucks(sharedDataModel.distanceFilterOption.value, of: location) }
        }
    }
}

#Preview {
    MapView()
}
