//
//  FoodTruckListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

enum FTNavigationPath: Hashable {
    case foodTruckDetail(id: String, distanceInMiles: Double)
    case locationDetail(foodTruckName: String, location: FTFLocation, closingTimeDateString: String?)
}

struct FoodTruckListView: View {
    
    @EnvironmentObject var sharedDataModel: SharedDataModel
    @State var viewModel = ViewModel() // StateObject persists across view updates
    @State private var navigationPath = [FTNavigationPath]()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                List {
                    ForEach(viewModel.foodTruckListItems, id: \.id) { listItem in
                        FoodTruckListCell(listItem: listItem)
                            .onTapGesture {
                                navigationPath.append(
                                    .foodTruckDetail(
                                        id: listItem.id,
                                        distanceInMiles: listItem.distanceInMiles
                                    )
                                )
                            }
                    }
                }
                .disabled(viewModel.isLoading)
                .refreshable { viewModel.locationManager.refreshLocation() }
                .navigationTitle("Food Trucks")
                .toolbar {
                    ToolbarItem {
                        ListViewToolbarView(isLoading: false)
                    }
                }
                .navigationDestination(for: FTNavigationPath.self) { path in
                    switch path {
                    case .foodTruckDetail(let id, let distanceInMiles):
                        FoodTruckDetailView(
                            foodTruckId: id,
                            distanceInMiles: distanceInMiles,
                            navigationPath: $navigationPath)
                    case .locationDetail(let name, let location, let closingTimeDateString):
                        FoodTruckDetailNavigationView(
                            name: name, 
                            location: location,
                            openUntil: closingTimeDateString)
                    }
                }
            }
            .onChange(of: viewModel.locationManager.lastLocation) {
                Task { await fetchFoodTrucks() }
            }
            .onChange(of: sharedDataModel.distance) {
                Task { await fetchFoodTrucks() }
            }
            
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
        // TODO: add error handling
        if let location = viewModel.locationManager.lastLocation {
            await viewModel.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
}

#Preview {
    FoodTruckListView()
}
