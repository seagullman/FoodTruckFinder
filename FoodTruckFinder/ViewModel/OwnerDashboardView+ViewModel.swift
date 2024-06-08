//
//  OwnerDashboardView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/11/24.
//

import Foundation
import FirebaseAuth

extension OwnerDashboardView {
    
    @Observable
    internal class ViewModel {
        
        var pushCreateFoodTruckView = false
        var isFoodTruckRegistered: Bool = false
        var foodTruck: FoodTruck?

        func foodTruckRegistered() async -> Bool {
            do {
                let isRegistered = try await FTFAuthManager.shared.userHasRegisteredFoodTruck()
                isFoodTruckRegistered = isRegistered
                return isRegistered
            } catch {
                print("***** ERROR checking food truck registration")
                // TODO: fix
            }
            return false
        }
        
        func loadFoodTruck() async {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
             
            do {
                foodTruck = try await NetworkManager.shared.getFoodTruck(by: currentUserId)
            } catch {
                // TODO: handle this
                print("***** Error fetching food truck by ID")
            }
        }
    }
}
