//
//  Menu.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import Foundation

struct MenuCategory: Codable, Identifiable {
    let id: UUID = UUID()
    let category: String
    let items: [MenuItem]
    
    enum CodingKeys: CodingKey {
        case category
        case items
    }
}

struct MenuItem: Codable, Identifiable {
    let id: UUID = UUID()
    let name: String
    let description: String
    let price: Double
    let isVegetarian: Bool
    let isGlutenFree: Bool
    
    enum CodingKeys: CodingKey {
        case name
        case description
        case price
        case isVegetarian
        case isGlutenFree
    }
}
