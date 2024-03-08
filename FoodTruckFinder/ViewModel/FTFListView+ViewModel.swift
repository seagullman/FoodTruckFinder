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
                    let clLocation = CLLocation(
                        latitude: foodTruck.location.latitude,
                        longitude: foodTruck.location.longitude
                    )
                    
                    let distanceInMiles = clLocation.distance(from: location).convert(from: .meters, to: .miles)
                    
                    return distanceInMiles < withinMiles
                }
                
            } catch {
                print("***** Error fetching food trucks: \(error)")
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
