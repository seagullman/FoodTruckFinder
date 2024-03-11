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
    @State private var path: [FoodTruck] = []
    @State var distance: Double = 5.0 // TODO: extract this to constant file
    @StateObject var locationManager = LocationManager() // TODO: move this to .app file? or somewhere else and store
    
    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                List {
                    ForEach(viewModel.foodTrucks, id: \.id) { foodTruck in
                        NavigationLink(destination: FoodTruckDetailView(foodTruck: foodTruck)) {
                            FoodTruckListCell(
                                foodTruck: foodTruck,
                                distanceFromUserLocation: viewModel.currentDistance(
                                    from: foodTruck,
                                    currentUserLocation: locationManager.lastLocation
                                )
                            )
                        }
                    }
                }
                .disabled(viewModel.isLoading)
                .refreshable { locationManager.refreshLocation() }
                .navigationTitle("Food Trucks")
                .toolbar { ListViewToolbarView(distance: $distance, isLoading: false) }
            }
            .onChange(of: locationManager.lastLocation) {
                Task { await fetchFoodTrucks() }
            }
            .onChange(of: distance) {
                Task { await fetchFoodTrucks() }
            }
//            .onAppear {
//                Task {
//                    for truck in FTFMockData.foodTrucks {
//                        await NetworkManager.shared.save(foodTruck: truck)
//                    }
//                }
//            }
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
