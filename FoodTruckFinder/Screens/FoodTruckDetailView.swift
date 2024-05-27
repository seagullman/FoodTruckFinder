//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI

// TODO: add loading state
// TODO: layout UI
// TODO: display menu
// TODO: design UI
struct FoodTruckDetailView: View {
    
    private let viewModel = ViewModel()
    
    let foodTruckId: String
    
    var body: some View {
        Group {
            if let foodTruck = viewModel.foodTruck {
                VStack {
                    Text(foodTruck.name)
                    Text(foodTruck.description)
                    Text(foodTruck.hoursOfOperation)
                    Text(foodTruck.websiteUrl)
                    Text(foodTruck.cuisineType.description)
                }
            } else {
                FullScreenLoadingView()
            }
        }
        .onAppear {
            Task { await viewModel.fetchFoodTruckBy(id: foodTruckId) }
        }
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234")
}
