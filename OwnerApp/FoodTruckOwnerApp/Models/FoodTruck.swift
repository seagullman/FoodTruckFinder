//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

struct FoodTruckListItem: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let distanceInMiles: Double
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let cuisineType: CuisineType?
}

struct FoodTruck: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let description: String
    let websiteUrl: String
    let cuisineType: CuisineType
    let location: FTFLocation
    let imageUrl: String?
    let openUntil: String?
    let menu: [MenuCategory]

    private enum CodingKeys: String, CodingKey {
        case id,
             name,
             description,
             websiteUrl,
             cuisineType,
             location,
             imageUrl,
             openUntil,
             menu
    }

    static func == (lhs: FoodTruck, rhs: FoodTruck) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
