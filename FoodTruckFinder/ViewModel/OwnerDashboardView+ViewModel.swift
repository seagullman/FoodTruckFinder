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
        
        var isFoodTruckRegistered: Bool = false
        var foodTruck: FoodTruck?
        
        init() {
            Task {
                let foodTruckRegistered = try await FTFAuthManager.shared.userHasRegisteredFoodTruck()
                isFoodTruckRegistered = foodTruckRegistered
            }
        }
        
        func loadFoodTruck() async {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            foodTruck = await NetworkManager.shared.getFoodTruck(by: currentUserId)
        }
    }
}
