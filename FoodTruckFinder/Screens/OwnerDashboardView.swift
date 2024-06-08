//
//  OwnerDashboardView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import SwiftUI
import FirebaseAuth

struct OwnerDashboardView: View {
    
    @State var viewModel = ViewModel()
    @State var showCreateView = false
    
    //    @State private var presentImporter = false
    
    var body: some View {
        @State var path = NavigationPath()
        
        NavigationStack() {
            if showCreateView {
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
        .onAppear {
            Task { self.showCreateView = await !viewModel.foodTruckRegistered() }
        }
    }
}
