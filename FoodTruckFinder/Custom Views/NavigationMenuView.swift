////
////  NavigationMenuView.swift
////  FoodTruckFinder
////
////  Created by Brad Siegel on 7/30/24.
////
//
//import SwiftUI
//import MapKit
//

//
//struct NavigationMenuView: View {
//    let location: FTFLocation
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Button("Navigate with Apple Maps") {
//                    openMapsApp(using: .appleMaps)
//                }
//                Button("Navigate with Google Maps") {
//                    openMapsApp(using: .googleMaps)
//                }
//            }
//            .navigationTitle("Choose a Map")
//        }
//    }
//    
//    func openMapsApp(using mapType: NavigationMapService) {
//        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//        
//        let urlString: String
//        switch mapType {
//        case .appleMaps:
//            urlString = "http://maps.apple.com/?ll=\(location.latitude),\(location.longitude)"
//        case .googleMaps:
//            urlString = "comgooglemaps://?q=\(location.latitude),\(location.longitude)"
//        }
//        if let url = URL(string: urlString) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
//    }
//}
//
//#Preview {
//    NavigationMenuView(location: FTFLocation(description: "In the Walmart parking lot.", latitude: 83.9020, longitude: -84.333))
//}
