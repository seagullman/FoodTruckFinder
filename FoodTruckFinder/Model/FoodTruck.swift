//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

struct FoodTruck: Codable {
    let id = UUID()
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
}
