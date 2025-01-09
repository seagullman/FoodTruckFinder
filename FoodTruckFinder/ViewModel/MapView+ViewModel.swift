//
//  MapView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 5/27/24.
//

import SwiftUI
import MapKit

extension MapView {
    
    @Observable
    internal class ViewModel {
        
        let locationManager = LocationManager()
        var foodTruckListItems: [FoodTruckListItem] = []
        var isLoading: Bool = false
        var showLocationsList: Bool = false
        var showDetailView: Bool = false
        
        var mapPosition: MapCameraPosition = .automatic
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        var currentItem: FoodTruckListItem? 
        
        private func updateMapRegion(for item: FoodTruckListItem) {
            withAnimation(.easeInOut) {
                let mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude),
                    span: mapSpan)
                mapPosition = .region(mapRegion)
            }
        }
        
        func showNextItem(item: FoodTruckListItem) {
            withAnimation(.easeInOut) {
                currentItem = item
                updateMapRegion(for: item)
                showLocationsList = false
            }
        }
        
        func toggleLocationsList() {
            withAnimation(.easeInOut) {
                showLocationsList.toggle()
            }
        }
        
        func detailButtonPressed() {
            showDetailView.toggle()
        }
        
        func nextButtonPressed() {
            // Get the current index
            guard let currentIndex = foodTruckListItems.firstIndex(where: { $0 == currentItem }) else {
                print("Could not find current index in locations array! Should never happen.")
                return
            }
            
            // Check if the currentIndex is valid
            let nextIndex = currentIndex + 1
            guard foodTruckListItems.indices.contains(nextIndex) else {
                // Next index is NOT valid
                // Restart from 0
                guard let firstItem = foodTruckListItems.first else { return }
                showNextItem(item: firstItem)
                return
            }
            
            // Next index IS valid
            let nextItem = foodTruckListItems[nextIndex]
            showNextItem(item: nextItem)
        }
        
        func fetchFoodTrucks(_ withinMiles: Double, of location: CLLocation) async {
            
            foodTruckListItems = []
            isLoading.toggle()
            
            do {
                let foodTruckListItems = try await NetworkManager.shared.getFoodTrucks(within: withinMiles, of: location)
                self.foodTruckListItems = foodTruckListItems
                
                guard let firstItem = foodTruckListItems.first else { return }
                
                self.currentItem = firstItem
                
            } catch {
                // TODO: handle error
                print("***** Error fetching food trucks: \(error)")
            }
            
            isLoading.toggle()
        }
    }
}
