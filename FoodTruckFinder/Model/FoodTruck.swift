//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

struct FoodTruckListItem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let distanceInMiles: Double
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
}

struct FoodTruck: Codable, Hashable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let websiteUrl: String
    let cuisineType: CuisineType
    let location: FTFLocation
    let imageFileName: String?
    let regularHours: RegularHours?

    private enum CodingKeys: String, CodingKey {
        case name,
             description,
             websiteUrl,
             cuisineType,
             location,
             imageFileName,
             regularHours
    }

    static func == (lhs: FoodTruck, rhs: FoodTruck) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
