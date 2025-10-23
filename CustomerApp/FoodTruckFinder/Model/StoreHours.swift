//
//  Store Hours.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/8/24.
//

import Foundation

// Model for regular store hours
struct RegularHours: Codable {
    let monday: OperatingHours
    let tuesday: OperatingHours
    let wednesday: OperatingHours
    let thursday: OperatingHours
    let friday: OperatingHours
    let saturday: OperatingHours
    let sunday: OperatingHours
}

// Model for operating hours of a single day
struct OperatingHours: Codable {
    let open: String
    let close: String
}

// Model for the main store hours structure
struct StoreHours: Codable {
    let regularHours: RegularHours
}
