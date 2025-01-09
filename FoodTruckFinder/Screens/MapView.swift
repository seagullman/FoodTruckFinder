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
    @State private var navigationPath: [FTNavigationPath] = []
    @EnvironmentObject var sharedDataModel: SharedDataModel
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                mapLayer
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    header
                        .padding()
                    
                    Spacer()
                    
                    locationsPreviewStack
                }
            }
            .onAppear(perform: fetchFoodTrucks)
            .onChange(of: sharedDataModel.distance) { fetchFoodTrucks() }
            .onChange(of: viewModel.showDetailView) { showDetailViewChanged() }
            .navigationDestination(for: FTNavigationPath.self) { path in
                navigationDestination(for: path)
            }
        }
    }
    
    private func fetchFoodTrucks() {
        guard let location = viewModel.locationManager.lastLocation else { return }
        Task { @MainActor in
            await viewModel.fetchFoodTrucks(sharedDataModel.distance, of: location)
        }
    }
    
    private func showDetailViewChanged() {
        guard let id = viewModel.currentItem?.id,
              let distance = viewModel.currentItem?.distanceInMiles else { return }
        
        if viewModel.showDetailView {
            navigationPath.append(.foodTruckDetail(id: id, distanceInMiles: distance))
        }
    }
    
    @ViewBuilder
    private func navigationDestination(for path: FTNavigationPath) -> some View {
        switch path {
        case .foodTruckDetail(let id, let distanceInMiles):
            FoodTruckDetailView(
                foodTruckId: id,
                distanceInMiles: distanceInMiles,
                navigationPath: $navigationPath)
        case .locationDetail(let name, let location, let closingTimeDateString):
            FoodTruckDetailInfoView(viewModel: .init(name: name, location: location, openUntil: closingTimeDateString))
        }
    }
}

extension MapView {
    
    private var header: some View {
        VStack {
            Button(action: viewModel.toggleLocationsList) {
                Text(viewModel.currentItem?.name ?? "" + ", " + (viewModel.currentItem?.description ?? ""))
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: viewModel.currentItem)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .rotationEffect(Angle(degrees: viewModel.showLocationsList ? 180 : 0))
                    }
            }
            
            if viewModel.showLocationsList {
                LocationsListView(viewModel: viewModel)
            }
        }
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
    
    private var mapLayer: some View {
        Map(position: $viewModel.mapPosition) {
            ForEach(viewModel.foodTruckListItems) { item in
                Annotation(item.name, coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                    LocationMapAnnotationView()
                        .scaleEffect(viewModel.currentItem == item ? 1 : 0.7)
                        .shadow(radius: 10)
                        .onTapGesture {
                            viewModel.showNextItem(item: item)
                        }
                }
            }
        }
    }
    
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(viewModel.foodTruckListItems) { item in
                if viewModel.currentItem?.id == item.id {
                    LocationPreviewView(viewModel: $viewModel, item: item)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(SharedDataModel())
}
