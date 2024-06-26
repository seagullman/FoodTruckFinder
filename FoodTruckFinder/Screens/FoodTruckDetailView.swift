//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import SwiftUI
import MapKit

struct FoodTruckDetailView: View {
    
    let foodTruckId: String
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private let viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            if let foodTruck = viewModel.foodTruck {
                VStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Map(position: $cameraPosition) {
                                Marker(foodTruck.name, coordinate: CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude))
                            }
                            .opacity(0.5)
                            .disabled(true)
                            .onTapGesture {
                                // TODO: handle when user taps on map
                                print("MAP TAPPED")
                            }
                            
                            if let urlString = viewModel.foodTruck?.imageUrl,
                               let url = URL(string: urlString) {
                                CircleAsyncImageView(
                                    url: url,
                                    loadingIndicatorSize: CGSize(width: 75, height: 75),
                                    borderColor: .white,
                                    borderLineWidth: 4)
                                .frame(width: 100, height: 100)
                                .offset(CGSize(width: 20, height: geometry.size.height / 4))
                            } else {
                                // TODO: handle this case better
                                Circle()
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 100)
                                    .offset(CGSize(width: 0, height: geometry.size.height / 2))
                            }
                        }
                    }.frame(height: 200)
                    
                    VStack(alignment: .leading) {
                        Text(foodTruck.name)
                            .font(.title.bold())
                        
                        Text(foodTruck.cuisineType.description)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Text(foodTruck.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }.padding(.leading, 10)
                    
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
//                FullScreenLoadingView()
            }
        }
        .onAppear {
            Task { await viewModel.fetchFoodTruckBy(id: foodTruckId) }
        }
        .onChange(of: viewModel.foodTruck) { oldValue, newValue in
            if let foodTruck = viewModel.foodTruck {
                let location = CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude)
                let locationSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location, span: locationSpan)
                cameraPosition = .region(region)
            }
        }
    }
}

#Preview {
    FoodTruckDetailView(foodTruckId: "1234")
}
