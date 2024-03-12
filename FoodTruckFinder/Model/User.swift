//
//  User.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import Foundation

enum UserType: Codable {
    case foodTruck
    case customer
}

struct User: Codable {
    let id: String
    let type: UserType
    let email: String
    let phoneNumber: String
    let foodTruckId: String
    
    private enum CodingKeys: String, CodingKey {
        case id,
             type,
             email,
             phoneNumber,
             foodTruckId
    }
}
