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
    @MainActor
    internal class ViewModel {
        
        var foodTrucks: [FoodTruck] = []
        var isLoading: Bool = false

        
        func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async { // MARK: don't throw here. handle error in view model and make a property to show an error.
            
            foodTrucks = []
            isLoading.toggle()
            
            do {
                let foodTrucks = try await NetworkManager.shared.getAllFoodTrucks()
                self.foodTrucks = foodTrucks.filter { foodTruck in
                    let distanceInMiles = currentDistance(from: foodTruck, currentUserLocation: location)
                    
                    return distanceInMiles < withinMiles
                }
                
            } catch {
                print("***** Error fetching food trucks: \(error)")
            }
            
            foodTrucks.sort { truck1, truck2 in
                let distanceInMiles1 = currentDistance(from: truck1, currentUserLocation: location)
                let distanceInMiles2 = currentDistance(from: truck2, currentUserLocation: location)
                return distanceInMiles1 < distanceInMiles2
            }
            self.foodTrucks = foodTrucks
            
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
