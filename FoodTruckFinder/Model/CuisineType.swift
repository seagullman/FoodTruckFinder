//
//  CuisineType.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

public enum CuisineType: String, Codable {
    case american   = "american"
    case coffee     = "coffee"
    case mexican    = "mexican"
    case asian      = "asian"
    case japanese   = "japanese"
    case italian    = "italian"
    case bbq        = "bbq"
    case sandwiches = "sandwiches"
    case pizza      = "pizza"
    
    var description: String {
        switch self {
        case .american:
            return "American"
        case .coffee:
            return "Coffee"
        case .mexican:
            return "Mexican"
        case .asian:
            return "Asian"
        case .japanese:
            return "Japanese"
        case .italian:
            return "Italian"
        case .bbq:
            return "BBQ"
        case .sandwiches:
            return "Sandwiches"
        case .pizza:
            return "Pizza"
        }
    }
}
