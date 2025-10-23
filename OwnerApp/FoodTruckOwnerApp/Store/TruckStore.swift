//
//  TruckStore.swift
//  FoodTruckOwnerApp
//

import Foundation
import Observation
import CoreLocation

@MainActor
@Observable
class TruckStore {
    
    let ownerId: String
    var truckId: String
    var truck: FoodTruck?
    var isLoading = false
    var errorMessage: String?
    
    // Check-in state
    var isCheckedIn = false
    var currentLocation: CLLocation?
    
    private let apiClient = OwnerAPIClient.shared
    
    init(ownerId: String, truckId: String = "") {
        self.ownerId = ownerId
        self.truckId = truckId
    }
    
    func loadTruck() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            truck = try await apiClient.getMyTruck()
            
            // Extract truck ID from the loaded truck
            if let loadedTruck = truck {
                // Note: FoodTruck model needs to include id field
                print("✅ Loaded truck: \(loadedTruck.name)")
                
                // Check if truck is currently open
                if let openUntil = loadedTruck.openUntil, openUntil != "Closed" {
                    isCheckedIn = true
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func checkIn(at location: CLLocation, until closeTime: String, description: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let locationUpdate = LocationUpdate(
                description: description,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            let updates = TruckUpdate(
                location: locationUpdate,
                openUntil: closeTime
            )
            
            try await apiClient.updateTruck(id: truckId, updates: updates)
            
            isCheckedIn = true
            currentLocation = location
            
            print("✅ Checked in at: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("   Open until: \(closeTime)")
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func checkOut() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let updates = TruckUpdate(openUntil: "Closed")
            try await apiClient.updateTruck(id: truckId, updates: updates)
            
            isCheckedIn = false
            currentLocation = nil
            
            print("✅ Checked out")
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func updateMenu(_ menu: [MenuCategory]) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let updates = TruckUpdate(menu: menu)
            try await apiClient.updateTruck(id: truckId, updates: updates)
            
            // Update local truck object
            if let currentTruck = truck {
                truck = FoodTruck(
                    id: currentTruck.id,
                    name: currentTruck.name,
                    description: currentTruck.description,
                    websiteUrl: currentTruck.websiteUrl,
                    cuisineType: currentTruck.cuisineType,
                    location: currentTruck.location,
                    imageUrl: currentTruck.imageUrl,
                    openUntil: currentTruck.openUntil,
                    menu: menu
                )
            }
            
            print("✅ Menu updated with \(menu.count) categories")
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func updateProfile(name: String?, description: String?, cuisineType: String?, websiteUrl: String?) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let updates = TruckUpdate(
                name: name,
                description: description,
                cuisineType: cuisineType,
                websiteUrl: websiteUrl
            )
            
            try await apiClient.updateTruck(id: truckId, updates: updates)
            
            print("✅ Profile updated")
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func uploadLogo(_ imageData: Data) async throws -> String {
        isLoading = true
        errorMessage = nil
        
        do {
            let imageUrl = try await apiClient.uploadImage(imageData, fileName: "logo-\(truckId).jpg")
            
            // Update truck with new image URL
            let updates = TruckUpdate(imageUrl: imageUrl)
            try await apiClient.updateTruck(id: truckId, updates: updates)
            
            print("✅ Logo uploaded: \(imageUrl)")
            
            isLoading = false
            return imageUrl
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
}
