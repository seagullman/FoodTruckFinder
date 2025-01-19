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
    
    private(set) var locationManager = LocationManager()
    
    // Use generic LoadingState for different cases
    private(set) var foodTruckListLoadingState: LoadingState<[FoodTruckListItem]> = .loading
    private(set) var foodTruckLoadingState: LoadingState<FoodTruck?> = .loading
    
    init(httpClient: NetworkClient) {
        self.httpClient = httpClient
    }
    
    func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async {
        foodTruckListLoadingState = .loading
        
        print("✅ fetchFoodTrucks: begin")
        
        do {
            print("✅ fetchFoodTrucks: calling network manager")
            let foodTruckListItems = try await httpClient.getFoodTrucks(within: withinMiles, of: location)
            self.foodTruckListLoadingState = .loaded(foodTruckListItems)
        } catch {
            // TODO: handle error
            print("❌ Error fetching food trucks: \(error.localizedDescription)")
            self.foodTruckListLoadingState = .failed(error)
        }
        
        print("✅ fetchFoodTrucks: end")
    }
    
    func fetchFoodTruckBy(id: String) async {
        self.foodTruckLoadingState = .loading
        
        do {
            let foodTruck = try await httpClient.getFoodTruck(by: id)
            self.foodTruckLoadingState = .loaded(foodTruck)
        } catch {
            // TODO: handle error
            print("***** Error fetching food truck: \(error)")
            self.foodTruckLoadingState = .failed(error)
        }
    }
    
    func mapRegionForFoodTruck(location: FTFLocation) -> MKCoordinateRegion? {
        return MapHelper.mapRegion(forLocation: location)
    }
    
}
