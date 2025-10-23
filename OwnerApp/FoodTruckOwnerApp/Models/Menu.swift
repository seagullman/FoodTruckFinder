//
//  Menu.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import Foundation

struct MenuCategory: Codable, Identifiable, Equatable {
    let id: UUID = UUID()
    let category: String
    let items: [MenuItem]
    
    enum CodingKeys: CodingKey {
        case category
        case items
    }
    
    static func == (lhs: MenuCategory, rhs: MenuCategory) -> Bool {
        lhs.category == rhs.category && lhs.items == rhs.items
    }
}

struct MenuItem: Codable, Identifiable, Equatable {
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
    
    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.price == rhs.price &&
        lhs.isVegetarian == rhs.isVegetarian &&
        lhs.isGlutenFree == rhs.isGlutenFree
    }
}
