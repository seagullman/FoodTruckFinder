//
//  Menu.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/26/24.
//

import Foundation

struct MenuCategory: Codable {
    let category: String
    let items: [MenuItem]
}

struct MenuItem: Codable {
    let name: String
    let description: String
    let price: Double
    let isVegetarian: Bool
    let isGlutenFree: Bool
}
