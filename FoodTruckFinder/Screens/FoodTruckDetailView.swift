//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI

struct FoodTruckDetailView: View {
    
    let foodTruck: FoodTruck
    
    var body: some View {
        VStack {
            Text(foodTruck.name)
            Text(foodTruck.description)
            Text(foodTruck.hoursOfOperation)
            Text(foodTruck.websiteUrl)
            Text(foodTruck.cuisineType.rawValue)
        }
    }
}

#Preview {
    FoodTruckDetailView(foodTruck: FTFMockData.foodTruck)
}
