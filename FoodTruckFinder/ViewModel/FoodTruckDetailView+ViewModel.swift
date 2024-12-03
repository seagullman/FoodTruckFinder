//
//  FoodTruckDetailView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 5/27/24.
//

import Foundation
import MapKit

extension FoodTruckDetailView {
    
    @Observable
    internal class ViewModel {
        
        var foodTruck: FoodTruck?
        
        func fetchFoodTruckBy(id: String) async {
            do {
                let foodTruck = try await NetworkManager.shared.getFoodTruck(by: id)
                self.foodTruck = foodTruck
            } catch {
                // TODO: handle error
                print("***** Error fetching food truck: \(error)")
            }
        }
        
        func mapRegionForFoodTruckLocation() -> MKCoordinateRegion? {
            if let foodTruck {
                return MapHelper.mapRegion(forLocagtion: foodTruck.location)
            }
            return nil
        }
    }
}
