//
//  SharedDataModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 5/27/24.
//

import SwiftUI

class SharedDataModel: ObservableObject {
    
    private let distanceFilterOptionKey = "distanceFilterOption"
    private let navigationMapServiceKey = "navigationMapService"
    
    @Published var distanceFilterOption: FilterOption {
        didSet {
            if let encoded = try? JSONEncoder().encode(distanceFilterOption) {
                UserDefaults.standard.set(encoded, forKey: distanceFilterOptionKey)
            }
        }
    }
    
    @Published var navigationMapService: NavigationMapService {
        didSet {
            if let encoded = try? JSONEncoder().encode(navigationMapService) {
                UserDefaults.standard.set(encoded, forKey: navigationMapServiceKey)
            }
        }
    }
    
    init() {
        // Load distanceFilterOption from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: distanceFilterOptionKey),
           let decodedOption = try? JSONDecoder().decode(FilterOption.self, from: savedData) {
            self.distanceFilterOption = decodedOption
        } else {
            self.distanceFilterOption = FilterOption(text: "5 miles", value: 5.0)
        }
        
        // Load navigationMapService from UserDefaults or use default value
        if let savedData = UserDefaults.standard.data(forKey: navigationMapServiceKey),
           let decodedService = try? JSONDecoder().decode(NavigationMapService.self, from: savedData) {
            self.navigationMapService = decodedService
        } else {
            self.navigationMapService = .appleMaps
        }
    }
}


