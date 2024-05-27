//
//  CreateFoodTruckView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import SwiftUI

struct CreateFoodTruckView: View {
    
    @State var foodTruckName: String = ""
    @State var description: String = ""
    @State var websiteUrl: String = ""
    @State var hoursOfOperation: String = ""
//    @State var cuisineType: String = .american.rawValue
    
    
    var body: some View {
        Form {
            Section("Create Food Truck") {
                TextField("Food Truck Name", text: $foodTruckName)
                TextField("Description", text: $description)
                TextField("Website URL", text: $websiteUrl)
                TextField("Hours", text: $hoursOfOperation)
//                TextField("Cuisine Type", text: $cuisineType)
            }
            Button {
                Task {
                    await NetworkManager.shared.save(foodTruck: FoodTruck(name: "Southern Craft", description: "Southern BBQ", websiteUrl: "southerncraft.com", hoursOfOperation: "M-SUN: 12-7", cuisineType: .american, location: FTFLocation(name: "Downtown Greenville", latitude: 36.178210, longitude: -82.776820)))
                }
            } label: {
                Text("Register Food Truck")
            }

        }
    }
}

#Preview {
    CreateFoodTruckView()
}
