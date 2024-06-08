//
//  Store Hours.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 6/8/24.
//

import Foundation

// Model for regular store hours
struct RegularHours: Codable {
    let Monday: OperatingHours
    let Tuesday: OperatingHours
    let Wednesday: OperatingHours
    let Thursday: OperatingHours
    let Friday: OperatingHours
    let Saturday: OperatingHours
    let Sunday: OperatingHours
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
