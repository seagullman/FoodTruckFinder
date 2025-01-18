//
//  FoodTruckStore.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/12/25.
//

import Foundation
import Observation
import CoreLocation
import MapKit

@MainActor
@Observable
class FoodTruckStore {
    
    let httpClient: NetworkClient
    
    private(set) var foodTruckListItems: [FoodTruckListItem] = []
    private(set) var locationManager = LocationManager()
    private(set) var isLoading: Bool = false
    
    private(set) var foodTruck: FoodTruck?
    
    init(httpClient: NetworkClient) {
        self.httpClient = httpClient
    }
    
    func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async {
        
        print("✅ fetchFoodTrucks: begin")
        foodTruckListItems = []
        isLoading = true
        
        do {
            print("✅ fetchFoodTrucks: calling network manager")
            let foodTruckListItems = try await httpClient.getFoodTrucks(within: withinMiles, of: location)
            self.foodTruckListItems = foodTruckListItems
            isLoading = false
            
        } catch {
            // TODO: handle error
            print("❌ Error fetching food trucks: \(error.localizedDescription)")
        }
        
        print("✅ fetchFoodTrucks: end")
        isLoading = false
    }
    
    func fetchFoodTruckBy(id: String) async {
        self.foodTruck = nil
        
        do {
            let foodTruck = try await httpClient.getFoodTruck(by: id)
            self.foodTruck = foodTruck
        } catch {
            // TODO: handle error
            print("***** Error fetching food truck: \(error)")
        }
    }
    
    func mapRegionForFoodTruckLocation() -> MKCoordinateRegion? {
        if let foodTruck {
            return MapHelper.mapRegion(forLocation: foodTruck.location)
        }
        return nil
    }
    
}
