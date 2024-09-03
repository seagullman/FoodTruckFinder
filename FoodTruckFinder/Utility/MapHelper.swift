//
//  MapHelper.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 8/7/24.
//

import Foundation
import MapKit

struct MapHelper {
    
    static func mapRegion(forLocagtion location: FTFLocation) -> MKCoordinateRegion? {
        let location = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let locationSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: locationSpan)
        
        return region
    }
}
