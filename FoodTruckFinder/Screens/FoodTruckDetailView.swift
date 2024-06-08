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
