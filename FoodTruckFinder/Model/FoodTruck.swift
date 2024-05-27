//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation
import FirebaseFirestoreSwift

struct FoodTruckListItem: Codable {
    let id: String
    let name: String
    let description: String
    let distanceInMiles: Double
}

struct FoodTruck: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let description: String
    let websiteUrl: String
    let hoursOfOperation: String
    let cuisineType: CuisineType
    let location: FTFLocation
    
    private enum CodingKeys: String, CodingKey {
        case name, 
             description,
             websiteUrl,
             hoursOfOperation,
             cuisineType,
             location
    }
    
    static func == (lhs: FoodTruck, rhs: FoodTruck) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
