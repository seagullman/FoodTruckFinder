//
//  MapView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 5/27/24.
//

import Foundation
import MapKit

extension MapView {
    
    @Observable
    internal class ViewModel {
        
        let locationManager = LocationManager()
        
        var foodTruckListItems: [FoodTruckListItem] = []
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
    }
}
