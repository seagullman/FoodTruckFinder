//
//  FTFListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FTFListView: View {
    
    @Bindable var viewModel = ViewModel()
    @StateObject var locationManager = LocationManager() // TODO: move this to .app file? or somewhere else and store
    @State var distance: Double = 5.0 // TODO: extract this to constant file
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach(viewModel.foodTrucks, id: \.id) { foodTruck in
                        FoodTruckListCell(
                            foodTruck: foodTruck,
                            distanceFromUserLocation: viewModel.currentDistance(
                                from: foodTruck,
                                currentUserLocation: locationManager.lastLocation
                            )
                        )
                    }
                }
                .disabled(viewModel.isLoading)
                .refreshable {
                    locationManager.refreshLocation()
                }
                .navigationTitle("Food Trucks")
                .toolbar {
                    ListViewToolbarView(distance: $distance, isLoading: false)
                }
            }
            .onChange(of: locationManager.lastLocation) {
                Task {
                    await fetchFoodTrucks()
                }
            }
            .onChange(of: distance) {
                Task {
                    await fetchFoodTrucks()
                }
            }
//            .onAppear {
//                Task {
//                    await NetworkManager.shared.save(
//                        foodTruck: FoodTruck(
//                            name: "Papa Joe's",
//                            description: "Italian Restaurant",
//                            websiteUrl: "papajoes.com",
//                            hoursOfOperation: "M-SUN: 10-10",
//                            cuisineType: .italian,
//                            location: FTFLocation(
//                                name: "14459 S. La Grange Rd",
//                                latitude: 123123,
//                                longitude: 123123
//                            )
//                        )
//                    )
//                    
////                    do {
////                        let trucks = try await NetworkManager.shared.getAllFoodTrucks()
////                        for truck in trucks {
////                            print(truck.name)
////                        }
////                    } catch {
////                        print("***** ERROR")
////                    }
//                    
//                }
//            }
            
            if viewModel.isLoading {
                ProgressView {
                    Text("Looking for food trucks near you...")
                }
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.large)
            }
        }
    }
    
    func fetchFoodTrucks() async {
        if let location = locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(distance, of: location)
        }
    }
}

#Preview {
    FTFListView()
}
