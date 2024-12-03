//
//  FoodTruckDetailNavigationView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 7/22/24.
//

import SwiftUI
import MapKit

// TODO: make a view model
struct FoodTruckDetailNavigationView: View {
    
    let name: String
    let location: FTFLocation
    let openUntil: String?
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Formatter to parse and format the date
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }
    
    private var timeAMPMFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Format for time with AM/PM
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Map(position: $cameraPosition) {
                    Marker(name,
                           coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                VStack {
                    FoodTruckDetailLocationCellView(icon: "mappin.and.ellipse",
                                                    titleText: "Navigate to location",
                                                    subtitleText: location.description,
                                                    accessoryIcon: "arrow.up.right")
                    
                    if let openUntil {
                        if let date = timeFormatter.date(from: openUntil) {
                            FoodTruckDetailLocationCellView(icon: "clock",
                                                            titleText: "Open",
                                                            titleTextColor: .green,
                                                            subtitleText: "At this location until \(timeAMPMFormatter.string(from: date))")
                        }
                    }
                    
                    FoodTruckDetailLocationCellView(icon: "phone",
                                                    titleText: "708-403-3333",
                                                    accessoryIcon: "arrow.up.right")
                    .onTapGesture {
                        makeCall(to: "7084032584")
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                guard let region = MapHelper.mapRegion(forLocagtion: location) else { return }
                cameraPosition = .region(region)
            }
            .navigationTitle(name)
        }
    }
    
    func makeCall(to phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Handle the case where the phone call cannot be made
            print("Cannot make a call")
        }
    }
}

#Preview {
    FoodTruckDetailNavigationView(
        name: "Test Truck",
        location: FTFLocation(
            description: "Located in the Food City parking lot.",
            latitude: 35.9898,
            longitude: -83.777),
        openUntil: "2024-07-27 19:00:00")
}
