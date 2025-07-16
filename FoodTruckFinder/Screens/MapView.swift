//
//  MapView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var viewModel = ViewModel()
    @EnvironmentObject var sharedDataModel: SharedDataModel
    @Environment(\.navigate) var navigate
    @State private var showingFilterSheet = false
    @State private var selectedFoodTruck: FoodTruckListItem?
    @State private var isNavigatingToDetail = false
    @State private var isUpdatingMapRegion = false
    @State private var hasInitiallyLoaded = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: viewModel.foodTruckListItems) { foodTruck in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: foodTruck.latitude, longitude: foodTruck.longitude)) {
                    FoodTruckMapMarker(
                        foodTruck: foodTruck,
                        isSelected: selectedFoodTruck?.id == foodTruck.id
                    ) {
                        print("🗺️ MapView: Marker tapped for food truck: \(foodTruck.name) (ID: \(foodTruck.id))")
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedFoodTruck = foodTruck
                        }
                        print("🗺️ MapView: Selected food truck updated to: \(selectedFoodTruck?.name ?? "nil") (ID: \(selectedFoodTruck?.id ?? "nil"))")
                    }
                }
            }
            .tint(.blue) // Override the app's red tint to show standard blue user location dot
            
            // Loading spinner overlay
            if isUpdatingMapRegion || viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(1.5)
                    
                    Text("Finding food trucks..")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            
            // Top controls - filter and recenter buttons
            VStack {
                HStack {
                    Spacer()
                    
                    // Recenter button
                    Button(action: {
                        print("🎯 MapView: Recenter button tapped - resetting map to optimal view")
                        handleMapRecenter()
                    }) {
                        Image(systemName: "location")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.red)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .disabled(viewModel.isLoading || isUpdatingMapRegion)
                    .opacity((viewModel.isLoading || isUpdatingMapRegion) ? 0.6 : 1.0)
                    
                    // Filter button
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                            Text("\(sharedDataModel.distanceFilterOption.text)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.red)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .disabled(viewModel.isLoading || isUpdatingMapRegion)
                    .opacity((viewModel.isLoading || isUpdatingMapRegion) ? 0.6 : 1.0)
                }
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            
            // Compact bottom overlay for selected food truck - positioned above tab bar
            if let selectedFoodTruck = selectedFoodTruck {
                VStack {
                    Spacer()
                    
                    FoodTruckCompactOverlay(
                        foodTruck: selectedFoodTruck,
                        onViewDetails: {
                            // Capture the values for navigation
                            let foodTruckId = selectedFoodTruck.id
                            let distance = selectedFoodTruck.distanceInMiles
                            let name = selectedFoodTruck.name
                            
                            print("🗺️ MapView: Navigating to detail for food truck: \(name) (ID: \(foodTruckId))")
                            print("🗺️ MapView: Preserving selection for when user returns")
                            
                            // Set navigation flag to track that we're navigating
                            isNavigatingToDetail = true
                            
                            // Navigate without clearing selection - this preserves the selection for when user returns
                            navigate(.foodTruck(.detail(id: foodTruckId, distanceInMiles: distance)))
                        },
                        onClose: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                self.selectedFoodTruck = nil
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                        removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.9))
                    ))
                }
                .padding(.bottom, 100) // Space above tab bar (adjust based on your tab bar height)
            }
        }
        .onAppear { 
            if !hasInitiallyLoaded {
                print("🗺️ MapView: Initial load - setting up location and fetching food trucks")
                setupInitialLocation()
                fetchFoodTrucks(shouldUpdateMapRegion: true)
                hasInitiallyLoaded = true
            } else {
                print("🗺️ MapView: Returning from navigation - using existing data, no loading needed")
                // When returning from detail view, we don't need to refetch data or show loading
                // The food truck data is still fresh and the map region should stay as-is
            }
        }
        .onChange(of: sharedDataModel.distanceFilterOption.value) { 
            print("🗺️ MapView: Distance filter changed - updating map region")
            // Clear selection when filter changes
            selectedFoodTruck = nil
            fetchFoodTrucks(shouldUpdateMapRegion: true) 
        }
        .sheet(isPresented: $showingFilterSheet) {
            DistanceFilterView(isPresented: $showingFilterSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: .mapTabRefreshRequested)) { _ in
            print("🔄 MapView: Tab refresh requested - refreshing map data")
            handleTabRefresh()
        }
    }
    
    private func setupInitialLocation() {
        if let userLocation = viewModel.locationManager.lastLocation {
            mapRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    private func fetchFoodTrucks(shouldUpdateMapRegion: Bool = false) {
        if let location = viewModel.locationManager.lastLocation {
            if shouldUpdateMapRegion {
                isUpdatingMapRegion = true
            }
            
            Task { 
                await viewModel.fetchFoodTrucks(sharedDataModel.distanceFilterOption.value, of: location)
                
                if shouldUpdateMapRegion {
                    await updateMapRegionForFoodTrucks()
                } else {
                    print("🗺️ MapView: Skipping map region update - preserving current view")
                }
            }
        }
    }
    
    private func handleMapRecenter() {
        print("🎯 MapView: Recentering map to show all food trucks optimally")
        
        // Clear current selection when recentering
        withAnimation(.easeOut(duration: 0.3)) {
            selectedFoodTruck = nil
        }
        
        // Recalculate and animate to the optimal map region
        Task {
            await updateMapRegionForFoodTrucks()
        }
    }
    
    private func handleTabRefresh() {
        print("🔄 MapView: Performing tab refresh - fetching fresh data and updating map region")
        
        // Clear current selection when refreshing
        withAnimation(.easeOut(duration: 0.3)) {
            selectedFoodTruck = nil
        }
        
        // Refresh location and fetch fresh food truck data with map region update
        viewModel.locationManager.refreshLocation()
        
        // Add a small delay to allow location refresh, then fetch food trucks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchFoodTrucks(shouldUpdateMapRegion: true)
        }
    }
    
    private func updateMapRegionForFoodTrucks() async {
        guard !viewModel.foodTruckListItems.isEmpty,
              let userLocation = viewModel.locationManager.lastLocation else { 
            await MainActor.run {
                isUpdatingMapRegion = false
            }
            return 
        }
        
        let foodTruckCoordinates = viewModel.foodTruckListItems.map { 
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) 
        }
        let allCoordinates = foodTruckCoordinates + [userLocation.coordinate]
        
        let minLat = allCoordinates.map { $0.latitude }.min() ?? userLocation.coordinate.latitude
        let maxLat = allCoordinates.map { $0.latitude }.max() ?? userLocation.coordinate.latitude
        let minLon = allCoordinates.map { $0.longitude }.min() ?? userLocation.coordinate.longitude
        let maxLon = allCoordinates.map { $0.longitude }.max() ?? userLocation.coordinate.longitude
        
        // Calculate center point
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        // Add padding for better visibility
        let latDelta = max((maxLat - minLat) * 1.4, 0.01) // Increased padding for better centering
        let lonDelta = max((maxLon - minLon) * 1.4, 0.01) // Increased padding for better centering
        
        // Adjust center slightly north to account for bottom overlay taking up screen space
        let adjustedCenterLat = centerLat + (latDelta * 0.1) // Shift center up by 10% of the span
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 1.0)) {
                mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: adjustedCenterLat, longitude: centerLon),
                    span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                )
            }
            
            // Hide loading spinner after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isUpdatingMapRegion = false
            }
        }
    }
}

#Preview {
    MapView()
}
