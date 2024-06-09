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
    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.secondary
//                    .ignoresSafeArea()
//                
//                .navigationTitle("Nav Bar Background")
//                .font(.title2)
//            }
//            .frame(height: 250)
//            
//            Spacer()
//        }
//    }
    
    var body: some View {
        ScrollView {
            if let foodTruck = viewModel.foodTruck {
                VStack {
                    Text(foodTruck.name)
                    Text(foodTruck.description)
                    Text(foodTruck.location.description )
                    Text(foodTruck.websiteUrl)
                    Text(foodTruck.cuisineType.description)
                    Text(foodTruck.imageFileName ?? "nada")
                    
//                    Text("Monday")
//                    Text(foodTruck.regularHours?.monday.open ?? "empty")
//                    Text("Tuesday")
//                    Text(foodTruck.regularHours?.tuesday.open ?? "empty")
//                    Text("Wednesday")
//                    Text(foodTruck.regularHours?.wednesday.open ?? "empty")
//                    Text("Thursday")
//                    Text(foodTruck.regularHours?.thursday.open ?? "empty")
//                    Text("Friday")
//                    Text(foodTruck.regularHours?.friday.open ?? "empty")
//                    Text("Saturday")
//                    Text(foodTruck.regularHours?.saturday.open ?? "empty")
//                    Text("Sunday")
//                    Text(foodTruck.regularHours?.sunday.open ?? "empty")
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
