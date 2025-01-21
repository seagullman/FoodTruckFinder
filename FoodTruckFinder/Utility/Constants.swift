//
//  Constants.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/19/25.
//

import Foundation

struct FilterOption: Identifiable, Codable, Hashable, Equatable {
    var id: Double { value }
    
    let text: String
    let value: Double
}

struct Constants {
    
    static let distanceFilterOptions: [FilterOption] = [
        .init(text: "1 mile", value: 1.0),
        .init(text: "5 miles", value: 5.0),
        .init(text: "10 miles", value: 10.0),
        .init(text: "20 miles", value: 20.0)
    ]
    
}
