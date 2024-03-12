//
//  FTOwnerDashboardView+ViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/11/24.
//

import Foundation
import FirebaseAuth

extension FTOwnerDashboardView {
    
    @Observable
    internal class ViewModel {
        
        var foodTruck: FoodTruck?
        
        func loadFoodTruck() async {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            foodTruck = await NetworkManager.shared.getFoodTruck(by: currentUserId)
        }
    }
}
