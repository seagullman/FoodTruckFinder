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

        
        func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async { // MARK: don't throw here. handle error in view model and make a property to show an error.
            
            // TODO: uncomment this to clear the list view when fetching updated food truck data
            //foodTrucks = []
            
            let foodTrucks = FTFMockData.foodTrucks.filter { foodTruck in
                let clLocation = CLLocation(
                    latitude: foodTruck.location.latitude,
                    longitude: foodTruck.location.longitude
                )
                
                let distanceInMiles = clLocation.distance(from: location).convert(from: .meters, to: .miles)
                
                return distanceInMiles < withinMiles
            }
            
            #warning("Remove this when api is working. This is used for mock data perposes.")
            do {
                try await Task.sleep(for: .seconds(2)) // This will be a call to the NetworkManager eventually
            } catch {
                print("***** Error")
            }
            
            self.foodTrucks = foodTrucks
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
