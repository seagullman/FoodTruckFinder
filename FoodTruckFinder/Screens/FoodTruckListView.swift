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
    @State private var searchText = ""
    @State private var selectedCuisineFilter: CuisineType? = nil
    @State private var scrollOffset: CGFloat = 0
    
    var contentHeight: CGFloat {
        let rowHeight: CGFloat = 64
        let padding: CGFloat = 50
        return CGFloat(Constants.distanceFilterOptions.count) * rowHeight + padding
    }
    
    var availableCuisineTypes: [CuisineType] {
        guard case .loaded(let items) = foodTruckStore.foodTruckListLoadingState else { return [] }
        
        // Get all effective cuisine types from the items
        let effectiveCuisineTypes = items.compactMap { item in
            item.cuisineType ?? inferCuisineType(from: item.name)
        }
        
        // Return unique cuisine types that have at least one food truck
        return Array(Set(effectiveCuisineTypes)).sorted { $0.displayName < $1.displayName }
    }
    
    var filteredItems: [FoodTruckListItem] {
        guard case .loaded(let items) = foodTruckStore.foodTruckListLoadingState else { return [] }
        
        print("🔍 Filtering \(items.count) items")
        print("🔍 Selected cuisine filter: \(selectedCuisineFilter?.rawValue ?? "nil")")
        
        let filtered = items.filter { item in
            let matchesSearch = searchText.isEmpty || 
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)
            
            // Get the effective cuisine type (either from data or inferred from name)
            let effectiveCuisineType = item.cuisineType ?? inferCuisineType(from: item.name)
            
            let matchesCuisine = selectedCuisineFilter == nil || 
                effectiveCuisineType == selectedCuisineFilter
            
            print("🔍 Item: \(item.name), cuisine: \(item.cuisineType?.rawValue ?? "nil"), inferred: \(effectiveCuisineType?.rawValue ?? "nil"), matchesCuisine: \(matchesCuisine)")
            
            return matchesSearch && matchesCuisine
        }
        
        print("🔍 Filtered to \(filtered.count) items")
        return filtered
    }
    
    private func inferCuisineType(from name: String) -> CuisineType? {
        let lowercasedName = name.lowercased()
        
        if lowercasedName.contains("pizza") || lowercasedName.contains("hut") {
            return .pizza
        } else if lowercasedName.contains("taco") || lowercasedName.contains("mexican") || lowercasedName.contains("cantina") {
            return .mexican
        } else if lowercasedName.contains("burger") || lowercasedName.contains("king") {
            return .american
        } else if lowercasedName.contains("subway") || lowercasedName.contains("sandwich") {
            return .sandwiches
        } else if lowercasedName.contains("coffee") || lowercasedName.contains("starbucks") {
            return .coffee
        } else if lowercasedName.contains("bbq") || lowercasedName.contains("barbecue") {
            return .bbq
        } else if lowercasedName.contains("japanese") || lowercasedName.contains("sushi") {
            return .japanese
        } else if lowercasedName.contains("italian") || lowercasedName.contains("pasta") {
            return .italian
        } else if lowercasedName.contains("asian") || lowercasedName.contains("chinese") || lowercasedName.contains("thai") {
            return .asian
        }
        
        // Default to American for chains and general restaurants
        return .american
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            switch foodTruckStore.foodTruckListLoadingState {
            case .loading:
                loadingView
            case .loaded(let _):
                mainContentView
            case .failed(let _):
                errorView
            }
        }
        .navigationTitle("Food Trucks")
        .navigationBarTitleDisplayMode(.large)
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
    
    private var mainContentView: some View {
        foodTruckList
            .sheet(isPresented: $showDistanceFilter) {
                DistanceFilterView(isPresented: $showDistanceFilter)
                    .presentationDetents([.height(contentHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(16)
            }
    }
    
    private var stickyHeaderSection: some View {
        VStack(spacing: 0) {
            // Only show search and filters when there are food trucks
            if !filteredItems.isEmpty {
                // Search bar (scrolls off)
                if scrollOffset < 50 {
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .opacity(1.0 - (scrollOffset / 50.0))
                        .animation(.easeInOut(duration: 0.2), value: scrollOffset)
                }
                
                // Sticky cuisine filter chips
                cuisineFilterChips
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                
                // Distance filter button (scrolls off)
                if scrollOffset < 80 {
                    distanceFilterButton
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .opacity(1.0 - (scrollOffset / 80.0))
                        .animation(.easeInOut(duration: 0.2), value: scrollOffset)
                }
            }
            // When no food trucks, show nothing in the header
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search food trucks...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .regular))
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private var cuisineFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All cuisines chip
                FilterChip(
                    title: "All",
                    isSelected: selectedCuisineFilter == nil,
                    action: { 
                        print("🔍 Setting cuisine filter to: All (nil)")
                        selectedCuisineFilter = nil 
                    }
                )
                
                // Individual cuisine chips - only show those with food trucks
                ForEach(availableCuisineTypes, id: \.self) { cuisine in
                    FilterChip(
                        title: cuisine.displayName,
                        isSelected: selectedCuisineFilter == .some(cuisine),
                        action: { 
                            print("🔍 Setting cuisine filter to: \(cuisine.rawValue)")
                            selectedCuisineFilter = cuisine 
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var distanceFilterButton: some View {
        Button {
            showDistanceFilter = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "location.circle")
                    .font(.system(size: 14))
                
                Text("Within \(sharedDataModel.distanceFilterOption.text)")
                    .font(.system(size: 13, weight: .regular))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    private var foodTruckList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header section that scrolls
                stickyHeaderSection
                
                // Content area
                if filteredItems.isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, minHeight: 400)
                        .padding(.top, 40)
                } else {
                    // Food truck list
                    LazyVStack(spacing: 8) {
                        ForEach(filteredItems, id: \.id) { listItem in
                            ModernFoodTruckCard(listItem: listItem) {
                                print("📋 FoodTruckListView: Tapped on food truck: \(listItem.name)")
                                navigate(.foodTruck(.detail(id: listItem.id, distanceInMiles: listItem.distanceInMiles)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = -value
        }
        .refreshable {
            foodTruckStore.locationManager.refreshLocation()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            // Animated loading indicator
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
            }
            
            VStack(spacing: 8) {
                Text("Discovering Food Trucks")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Searching for delicious options near you...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            // Animated empty state icon
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "truck.box")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Text("No Food Trucks Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Try adjusting your search or expanding the distance filter to discover more options.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Expand Search Area") {
                showDistanceFilter = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var errorView: some View {
        VStack(spacing: 24) {
            // Error icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Oops! Something went wrong")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("We couldn't load the food trucks. Please check your connection and try again.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button("Try Again") {
                foodTruckStore.locationManager.refreshLocation()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func fetchFoodTrucks() async {
        if let location = foodTruckStore.locationManager.lastLocation {
            await foodTruckStore.fetchFoodTrucks(sharedDataModel.distanceFilterOption.value, of: location)
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.red : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernFoodTruckCard: View {
    let listItem: FoodTruckListItem
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    // Dynamic accent color based on cuisine type
    private var accentColor: Color {
        guard let cuisine = listItem.cuisineType else {
            return .orange
        }
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
            HStack(alignment: .center, spacing: 14) {
                // Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    if let imageUrlString = listItem.imageUrl, let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(accentColor)
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(accentColor)
                    }
                }
                // Center content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(listItem.name)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                        // Distance badge (small, subtle, gray)
                        Text(String(format: "%.1f mi", listItem.distanceInMiles))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray4))
                            )
                    }
                    if let cuisine = listItem.cuisineType {
                        HStack(spacing: 4) {
                            Image(systemName: cuisineIcon(for: cuisine))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(accentColor)
                            Text(cuisine.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(accentColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(accentColor.opacity(0.12)))
                    }
                    Text(listItem.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 2)
                }
                .padding(.vertical, 2)
                .frame(minHeight: 60)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(isPressed ? 0.10 : 0.04), radius: isPressed ? 8 : 4, x: 0, y: isPressed ? 4 : 2)
            )
            .frame(minHeight: 90)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private func cuisineIcon(for cuisine: CuisineType) -> String {
        switch cuisine {
        case .mexican: return "flame.fill"
        case .pizza: return "circle.fill"
        case .asian, .japanese: return "leaf.fill"
        case .italian: return "leaf"
        case .bbq: return "flame"
        case .coffee: return "cup.and.saucer.fill"
        case .sandwiches: return "rectangle.fill"
        case .american: return "star.fill"
        }
    }
}

struct DistanceBadge: View {
    let distance: Double
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "location.fill")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white)
            
            Text(String(format: "%.1f", distance))
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}

struct CuisineBadge: View {
    let cuisine: CuisineType?
    
    private var badgeColors: (background: Color, text: Color) {
        guard let cuisine = cuisine else {
            return (Color.orange.opacity(0.2), Color.orange)
        }
        
        switch cuisine {
        case .mexican:
            return (Color.orange.opacity(0.2), Color.orange)
        case .pizza:
            return (Color.red.opacity(0.2), Color.red)
        case .asian, .japanese:
            return (Color.purple.opacity(0.2), Color.purple)
        case .italian:
            return (Color.green.opacity(0.2), Color.green)
        case .bbq:
            return (Color.brown.opacity(0.2), Color.brown)
        case .coffee:
            return (Color.brown.opacity(0.2), Color.brown)
        case .sandwiches:
            return (Color.yellow.opacity(0.2), Color.yellow)
        case .american:
            return (Color.blue.opacity(0.2), Color.blue)
        }
    }
    
    var body: some View {
        if let cuisine {
            HStack(spacing: 4) {
                // Cuisine icon
                Image(systemName: cuisineIcon(for: cuisine))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(badgeColors.text)
                
                Text(cuisine.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(badgeColors.text)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(badgeColors.background)
                    .overlay(
                        Capsule()
                            .stroke(badgeColors.text.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func cuisineIcon(for cuisine: CuisineType) -> String {
        switch cuisine {
        case .mexican:
            return "flame.fill"
        case .pizza:
            return "circle.fill"
        case .asian, .japanese:
            return "leaf.fill"
        case .italian:
            return "leaf"
        case .bbq:
            return "flame"
        case .coffee:
            return "cup.and.saucer.fill"
        case .sandwiches:
            return "rectangle.fill"
        case .american:
            return "star.fill"
        }
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationStack {
        FoodTruckListView()
            .environment(FoodTruckStore(httpClient: NetworkManager.shared))
            .environmentObject(SharedDataModel())
    }
}
