//
//  FoodTruckDetailHeaderView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 7/22/24.
//

import SwiftUI
import MapKit

struct FoodTruckDetailHeaderView: View {
    
    let foodTruck: FoodTruck
    let distanceInMiles: Double
    
    @Binding var navigationPath: [FTNavigationPath]
    @Binding var cameraPosition: MapCameraPosition
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    // MARK: Header map image
                    
                    Map(position: $cameraPosition) {
                        Marker(
                            foodTruck.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: foodTruck.location.latitude,
                                longitude: foodTruck.location.longitude
                            )
                        )
                    }
                    .opacity(0.5)
                    .disabled(true)
                    
                    // MARK: Food truck circle image
                    
                    if let urlString = foodTruck.imageUrl,
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
            
            // MARK: Food truck info
            
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            // MARK: Name
                            
                            Text(foodTruck.name)
                                .font(.title.bold())
                            
                            Spacer()
                            
                            // MARK: Distance
                            
                            Text(String(format: "%.1f mi", distanceInMiles))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // MARK: Cuisine type
                        
                        Text(foodTruck.cuisineType.description)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        // MARK: Description
                        
                        Text(foodTruck.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(.lightGray))
                }

                // MARK: Menu
                
                MenuView(menuCategories: foodTruck.menu)
                    .padding(.top, 20)
                
            }
            .onTapGesture {
                navigationPath.append(.locationDetail(
                    foodTruckName: foodTruck.name,
                    location: foodTruck.location,
                    closingTimeDateString: "TODO: implement me"))
            }
            .padding(10)
        }
    }
}

#Preview {
    FoodTruckDetailHeaderView(foodTruck:
                                FoodTruck(
                                    name: "El Hurradurra",
                                    description: "Mexican food known for their tacos.",
                                    websiteUrl: "Hurradurra.com",
                                    cuisineType: .mexican,
                                    location: FTFLocation(description: "",
                                                          latitude: 123,
                                                          longitude: 123),
                                    imageUrl: "",
                                    regularHours: nil,
                                    menu: [MenuCategory(
                                        category: "Apps",
                                        items: [MenuItem(
                                            name: "Cheese Sticks",
                                            description: "Yummy",
                                            price: 12.99,
                                            isVegetarian: false,
                                            isGlutenFree: false
                                        )]
                                    )]),
                              distanceInMiles: 123, navigationPath: .constant([]),
                              cameraPosition: .constant(.automatic))
}
