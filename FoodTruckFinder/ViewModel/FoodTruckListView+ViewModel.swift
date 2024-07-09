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
     }
}
