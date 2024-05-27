//
//  FoodTruckListView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

extension FoodTruckListView {
    
    @Observable
    internal class ViewModel {
        var distance: Double = 5.0
        var foodTruckListItems: [FoodTruckListItem] = []
        var locationManager = LocationManager()
        var isLoading: Bool = false

        func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async { 
            
            foodTruckListItems = []
            isLoading.toggle()
            
            do {
                let foodTruckListItems = try await NetworkManager.shared.getFoodTrucks(within: withinMiles, of: location)
                self.foodTruckListItems = foodTruckListItems
                
            } catch {
                // TODO: handle error
                print("***** Error fetching food trucks: \(error)")
            }
            
            isLoading.toggle()
        }
        
        /**
         *  Calculates and returns the distance in miles from the user's last known
         *  location and the FoodTruck's location.
         */
        func currentDistance(from foodTruck: FoodTruck, currentUserLocation: CLLocation?) -> Double {
            guard let currentUserLocation else { return 0 }
            
            let foodTruckLocation = CLLocation(
                latitude: foodTruck.location.latitude,
                longitude: foodTruck.location.longitude
            )
            let distance = foodTruckLocation.distance(from: currentUserLocation).convert(from: .meters, to: .miles)
            
            return distance
        }
     }
}
