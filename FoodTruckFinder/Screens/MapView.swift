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
    @State private var isUpdatingMapRegion = false
    @State private var hasInitiallyLoaded = false
    @State private var showingList = false
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFoodTruck = foodTruck
                            // Center map on selected truck
                            mapRegion.center = CLLocationCoordinate2D(
                                latitude: foodTruck.latitude,
                                longitude: foodTruck.longitude
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            // Loading overlay
            if isUpdatingMapRegion || viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)
                    
                    Text("Finding food trucks...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
            }
            
            // Top controls
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    // Results count badge
                    if !viewModel.foodTruckListItems.isEmpty && !viewModel.isLoading {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(viewModel.foodTruckListItems.count)")
                                .font(.system(size: 15, weight: .bold))
                            Text(viewModel.foodTruckListItems.count == 1 ? "truck" : "trucks")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // List toggle button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingList.toggle()
                            }
                        }) {
                            Image(systemName: showingList ? "map.fill" : "list.bullet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                        .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                        }
                        
                        // Recenter button
                        Button(action: handleMapRecenter) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                        }
                        
                        // Filter button
                        Button(action: { showingFilterSheet = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
            
            // Bottom sheet for selected food truck
            if let selectedFoodTruck = selectedFoodTruck {
                VStack {
                    Spacer()
                    
                    FoodTruckDetailCard(
                        foodTruck: selectedFoodTruck,
                        onViewDetails: {
                            navigate(.foodTruck(.detail(id: selectedFoodTruck.id, distanceInMiles: selectedFoodTruck.distanceInMiles)))
                        },
                        onClose: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.selectedFoodTruck = nil
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Sliding list view
            if showingList {
                VStack(spacing: 0) {
                    Spacer()
                    
                    MapListOverlay(
                        foodTrucks: viewModel.foodTruckListItems,
                        selectedTruck: $selectedFoodTruck,
                        onSelectTruck: { truck in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFoodTruck = truck
                                showingList = false
                                mapRegion.center = CLLocationCoordinate2D(
                                    latitude: truck.latitude,
                                    longitude: truck.longitude
                                )
                            }
                        },
                        onClose: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingList = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
                .background(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showingList = false
                            }
                        }
                )
            }
        }
        .onAppear {
            if !hasInitiallyLoaded {
                setupInitialLocation()
                fetchFoodTrucks(shouldUpdateMapRegion: true)
                hasInitiallyLoaded = true
            }
        }
        .onChange(of: sharedDataModel.distanceFilterOption.value) {
            selectedFoodTruck = nil
            fetchFoodTrucks(shouldUpdateMapRegion: true)
        }
        .sheet(isPresented: $showingFilterSheet) {
            DistanceFilterView(isPresented: $showingFilterSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: .mapTabRefreshRequested)) { _ in
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

// MARK: - Supporting Views

struct FoodTruckDetailCard: View {
    let foodTruck: FoodTruckListItem
    let onViewDetails: () -> Void
    let onClose: () -> Void
    
    private var accentColor: Color {
        guard let cuisine = foodTruck.cuisineType else { return .orange }
        switch cuisine {
        case .mexican: return .orange
        case .pizza: return .red
        case .asian, .japanese: return .purple
        case .italian: return .green
        case .bbq: return .brown
        case .coffee: return .brown
        case .sandwiches: return .yellow
        case .american: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            HStack(alignment: .top, spacing: 16) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: 80, height: 80)
                    
                    if let imageUrlString = foodTruck.imageUrl, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(accentColor)
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(accentColor)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(foodTruck.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        // Distance
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12, weight: .medium))
                            Text(String(format: "%.1f mi", foodTruck.distanceInMiles))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.secondary)
                        
                        // Cuisine
                        if let cuisine = foodTruck.cuisineType {
                            HStack(spacing: 4) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text(cuisine.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(accentColor.opacity(0.15))
                            )
                        }
                    }
                    
                    Text(foodTruck.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 20)
            
            // View Details button
            Button(action: onViewDetails) {
                HStack(spacing: 8) {
                    Text("View Details")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
    }
}

struct MapListOverlay: View {
    let foodTrucks: [FoodTruckListItem]
    @Binding var selectedTruck: FoodTruckListItem?
    let onSelectTruck: (FoodTruckListItem) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Header
            HStack {
                Text("\(foodTrucks.count) Food Trucks")
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
            
            // List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(foodTrucks, id: \.id) { truck in
                        MapListItem(
                            foodTruck: truck,
                            isSelected: selectedTruck?.id == truck.id
                        ) {
                            onSelectTruck(truck)
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

struct MapListItem: View {
    let foodTruck: FoodTruckListItem
    let isSelected: Bool
    let onTap: () -> Void
    
    private var accentColor: Color {
        guard let cuisine = foodTruck.cuisineType else { return .orange }
        switch cuisine {
        case .mexican: return .orange
        case .pizza: return .red
        case .asian, .japanese: return .purple
        case .italian: return .green
        case .bbq: return .brown
        case .coffee: return .brown
        case .sandwiches: return .yellow
        case .american: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)
                    
                    if let imageUrlString = foodTruck.imageUrl, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 22, weight: .light))
                                .foregroundColor(accentColor)
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(accentColor)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(foodTruck.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f mi", foodTruck.distanceInMiles))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let cuisine = foodTruck.cuisineType {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(cuisine.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(accentColor)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? accentColor.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MapView()
}
