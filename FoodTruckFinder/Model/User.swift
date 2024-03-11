//
//  User.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import Foundation


enum UserType {
    case foodTruck
    case customer
}

struct User {
    let id = UUID()
    let type: UserType
    let foodTruck: FoodTruck?
    let email: String
    let phoneNumber: String
}
