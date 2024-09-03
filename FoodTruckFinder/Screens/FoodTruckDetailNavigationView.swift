//
//  FoodTruckDetailNavigationView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 7/22/24.
//

import SwiftUI

struct FoodTruckDetailNavigationView: View {
    
    let name: String
    let location: FTFLocation
    let closingTimeDateString: String
    
    var body: some View {
        VStack {
            Text(name)
            Text(location.description)
            Text(closingTimeDateString)
        }
    }
}

#Preview {
    FoodTruckDetailNavigationView(
        name: "Test Truck",
        location: FTFLocation(
            description: "Located in the Food City parking lot.",
            latitude: 35.9898,
            longitude: -83.777),
        closingTimeDateString: "2024-07-27 19:00:00")
}
