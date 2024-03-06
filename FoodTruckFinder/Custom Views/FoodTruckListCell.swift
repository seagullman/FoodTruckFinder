//
//  FoodTruckListCell.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI

struct FoodTruckListCell: View {
    
    let foodTruck: FoodTruck
    let distanceFromUserLocation: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(foodTruck.name)
                Text(foodTruck.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(foodTruck.location.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "%.1f mi", distanceFromUserLocation))
                .font(.system(.subheadline))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    FoodTruckListCell(foodTruck: FTFMockData.foodTruck, distanceFromUserLocation: 2.0)
}
