//
//  User.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import Foundation

enum UserType: String, Codable {
    case foodTruck = "foodTruck"
    case customer = "customer"
}

struct User: Codable {
    var id: String
    var type: UserType
    var email: String
    var fullName: String
}
