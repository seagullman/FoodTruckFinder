//
//  CuisineType.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

public enum CuisineType: String, Codable, CaseIterable {
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
    
    var displayName: String {
        return description
    }
    
    var iconName: String {
        switch self {
        case .american:
            return "flag.fill"
        case .coffee:
            return "cup.and.saucer.fill"
        case .mexican:
            return "tortilla.fill"
        case .asian:
            return "chopsticks"
        case .japanese:
            return "fish.fill"
        case .italian:
            return "leaf.fill"
        case .bbq:
            return "flame.fill"
        case .sandwiches:
            return "sandwich"
        case .pizza:
            return "circle.grid.3x3.fill"
        }
    }
}
