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
                    await NetworkManager.shared.save(foodTruck: FoodTruck(name: "Brad's Grub", description: "Home cooking by Brad", websiteUrl: "bradsiegel.com", hoursOfOperation: "M-SUN: 8-10", cuisineType: .american, location: FTFLocation(name: "Outside the Embassy Suites", latitude: 35.9648496, longitude: -83.9184627)))
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
