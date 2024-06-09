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
                    
                    if foodTruck.regularHours == nil {
                        Text("REG HOURS NIL")
                    }
                    
                    Text("Monday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.monday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.monday.close ?? "empty")
                    
                    Text("Tuesday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.tuesday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.tuesday.close ?? "empty")
                    
                    Text("Wednesday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.wednesday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.wednesday.close ?? "empty")
                    
                    Text("Thursday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.thursday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.thursday.close ?? "empty")
                    
                    Text("Friday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.friday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.friday.close ?? "empty")
                    
                    Text("Saturday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.saturday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.saturday.close ?? "empty")
                    
                    Text("Sunday")
                    Text("OPEN")
                    Text(foodTruck.regularHours?.sunday.open ?? "empty")
                    Text("CLOSE")
                    Text(foodTruck.regularHours?.sunday.close ?? "empty")
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
