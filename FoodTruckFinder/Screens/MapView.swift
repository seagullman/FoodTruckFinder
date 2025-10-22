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
            // Map background
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
            .tint(.blue)
            
            // Loading overlay with modern design
            if isUpdatingMapRegion || viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    LoadingSpinner()
                    
                    Text("Finding food trucks...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                )
            }
            
            // Top controls with modern design
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Recenter button
                        Button(action: {
                            print("🎯 MapView: Recenter button tapped - resetting map to optimal view")
                            handleMapRecenter()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.red)
                                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                                )
                        }
                        .disabled(viewModel.isLoading || isUpdatingMapRegion)
                        .opacity((viewModel.isLoading || isUpdatingMapRegion) ? 0.6 : 1.0)
                        
                        // Filter button
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14, weight: .medium))
                                Text("\(sharedDataModel.distanceFilterOption.text)")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                            )
                        }
                        .disabled(viewModel.isLoading || isUpdatingMapRegion)
                        .opacity((viewModel.isLoading || isUpdatingMapRegion) ? 0.6 : 1.0)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            
            // Bottom overlay for selected food truck
            if let selectedFoodTruck = selectedFoodTruck {
                VStack {
                    Spacer()
                    
                    FoodTruckCompactOverlay(
                        foodTruck: selectedFoodTruck,
                        onViewDetails: {
                            let foodTruckId = selectedFoodTruck.id
                            let distance = selectedFoodTruck.distanceInMiles
                            let name = selectedFoodTruck.name
                            
                            print("🗺️ MapView: Navigating to detail for food truck: \(name) (ID: \(foodTruckId))")
                            print("🗺️ MapView: Preserving selection for when user returns")
                            
                            isNavigatingToDetail = true
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
                .padding(.bottom, 100)
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
            }
        }
        .onChange(of: sharedDataModel.distanceFilterOption.value) { 
            print("🗺️ MapView: Distance filter changed - updating map region")
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
        
        withAnimation(.easeOut(duration: 0.3)) {
            selectedFoodTruck = nil
        }
        
        Task {
            await updateMapRegionForFoodTrucks()
        }
    }
    
    private func handleTabRefresh() {
        print("🔄 MapView: Performing tab refresh - fetching fresh data and updating map region")
        
        withAnimation(.easeOut(duration: 0.3)) {
            selectedFoodTruck = nil
        }
        
        viewModel.locationManager.refreshLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchFoodTrucks(shouldUpdateMapRegion: true)
        }
    }
    
    private func updateMapRegionForFoodTrucks() async {
        guard !viewModel.foodTruckListItems.isEmpty else { 
            await MainActor.run {
                isUpdatingMapRegion = false
            }
            return 
        }
        
        let foodTruckCoordinates = viewModel.foodTruckListItems.map { 
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) 
        }
        
        let minLat = foodTruckCoordinates.map { $0.latitude }.min()!
        let maxLat = foodTruckCoordinates.map { $0.latitude }.max()!
        let minLon = foodTruckCoordinates.map { $0.longitude }.min()!
        let maxLon = foodTruckCoordinates.map { $0.longitude }.max()!
        
        // Calculate center point based only on food truck locations
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        // Calculate optimal span with better padding
        let latDelta = max((maxLat - minLat) * 1.6, 0.015) // Increased padding for better visibility
        let lonDelta = max((maxLon - minLon) * 1.6, 0.015) // Increased padding for better visibility
        
        // Adjust center to account for UI elements
        let adjustedCenterLat = centerLat + (latDelta * 0.08) // Shift center up slightly
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 1.2)) {
                mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: adjustedCenterLat, longitude: centerLon),
                    span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                )
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isUpdatingMapRegion = false
            }
        }
    }
}

#Preview {
    MapView()
}
