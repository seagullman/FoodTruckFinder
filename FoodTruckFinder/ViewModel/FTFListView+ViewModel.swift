//
//  FoodTruckListView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

extension FTFListView {
    
    @Observable
    internal class ViewModel {
        
        var foodTrucks: [FoodTruck] = []

        func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) -> [FoodTruck] {
            
            let foodTrucks = FTFMockData.foodTrucks.filter { foodTruck in
                let clLocation = CLLocation(
                    latitude: foodTruck.location.latitude,
                    longitude: foodTruck.location.longitude
                )
                
                let distanceInMiles = clLocation.distance(from: location).convert(from: .meters, to: .miles)
                
                return distanceInMiles < withinMiles
            }
            
            self.foodTrucks = foodTrucks
            
            return foodTrucks
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
