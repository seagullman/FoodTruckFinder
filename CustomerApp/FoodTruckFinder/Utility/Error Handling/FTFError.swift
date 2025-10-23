//
//  FTFError.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import Foundation

enum FTFError: Error {
    case invalidCredentials
    case invalidUrl
    case invalidData
    case invalidResponse
    case documentNotFound
}
