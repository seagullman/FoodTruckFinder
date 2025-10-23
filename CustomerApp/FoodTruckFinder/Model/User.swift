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
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
