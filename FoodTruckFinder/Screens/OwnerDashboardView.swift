//
//  OwnerDashboardView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import SwiftUI
import FirebaseAuth

struct OwnerDashboardView: View {
    
    let viewModel = ViewModel()
    
    //    @State private var presentImporter = false
    
    var body: some View {
        NavigationStack {
            if !viewModel.isFoodTruckRegistered {
                CreateFoodTruckView()
            } else {
                VStack {
                    Text("Food Truck Owner Dashboard!")
                    if viewModel.isFoodTruckRegistered {
                        Text("Food Truck REGISTERED!")
                    } else {
                        Text("Food Truck NOT regisered!")
                    }
                }
            }
        }
    }
}
