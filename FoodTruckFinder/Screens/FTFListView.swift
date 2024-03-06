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
        }
        .onChange(of: locationManager.lastLocation) {
            if let location = locationManager.lastLocation {
                _ = viewModel.fetchFoodTrucks(200, of: location)
            }
        }
    }
}

#Preview {
    FTFListView()
}
