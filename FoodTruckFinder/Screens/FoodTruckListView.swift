//
//  FoodTruckListView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import CoreLocation

struct FoodTruckListView: View {
    
    @Environment(\.navigate) private var navigate
    @Environment(FoodTruckStore.self) private var foodTruckStore
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    @State private var showDistanceFilter: Bool = false
    @State private var errorItem: AlertItem?
    
    var contentHeight: CGFloat {
        let rowHeight: CGFloat = 64 // Approximate row height
        let padding: CGFloat = 50   // Extra space for safe area and title
        return CGFloat(Constants.distanceFilterOptions.count) * rowHeight + padding
    }
    
    var body: some View {
        ZStack {
            switch foodTruckStore.foodTruckListLoadingState {
            case .loading:
                loadingView
            case .loaded(let listItems):
                foodTruckItemList(items: listItems)
            case .failed(let _):
                errorView
            }
        }
        .navigationTitle("Food Trucks")
        .onChange(of: foodTruckStore.foodTruckListLoadingState) { newState in
            if case .failed(let errorItem) = newState {
                self.errorItem = errorItem
            }
        }
        .alert(item: $errorItem) { error in
            Alert(
                title: error.title,
                message: error.message,
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: foodTruckStore.locationManager.lastLocation) {
            Task { await fetchFoodTrucks() }
        }
        .onChange(of: sharedDataModel.distanceFilterOption) {
            Task { await fetchFoodTrucks() }
        }
        .task {
            guard case .loaded = foodTruckStore.foodTruckListLoadingState else {
                foodTruckStore.locationManager.refreshLocation()
                return
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView {
            Text("Looking for food trucks near you...")
        }
        .progressViewStyle(CircularProgressViewStyle())
        .controlSize(.large)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Food Trucks Found", systemImage: "magnifyingglass")
        } description: {
            Text("Try expanding your search or checking back later — more trucks might roll in soon!")
        } actions: {
            Button("Expand Search Area") {
                self.showDistanceFilter = true
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
        }
    }

    private var errorView: some View {
        ContentUnavailableView {
            Label("Error Loading Food Trucks", systemImage: "exclamationmark.triangle")
        } description: {
            Text("There was an error loading food trucks. Please try again.")
        } actions: {
            Button("Retry") {
                foodTruckStore.locationManager.refreshLocation()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func foodTruckItemList(items: [FoodTruckListItem]) -> some View {
        VStack {
            if items.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(items, id: \.id) { listItem in
                        FoodTruckListCell(listItem: listItem)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("📋 FoodTruckListView: Tapped on food truck: \(listItem.name)")
                                navigate(.foodTruck(.detail(id: listItem.id, distanceInMiles: listItem.distanceInMiles)))
                            }
                    }
                }
                .refreshable {
                    foodTruckStore.locationManager.refreshLocation()
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    self.showDistanceFilter = true
                } label: {
                    Image(systemName: "slider.vertical.3")
                }
            }
        }
        .sheet(isPresented: $showDistanceFilter) {
            DistanceFilterView(isPresented: $showDistanceFilter)
                .presentationDetents([.height(contentHeight)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(16)
        }
    }
    
    private func fetchFoodTrucks() async {
        if let location = foodTruckStore.locationManager.lastLocation {
            await foodTruckStore.fetchFoodTrucks(sharedDataModel.distanceFilterOption.value, of: location)
        }
    }
}

#Preview {
    NavigationStack {
        FoodTruckListView()
            .environment(FoodTruckStore(httpClient: NetworkManager.shared))
            .environmentObject(SharedDataModel())
    }
}
