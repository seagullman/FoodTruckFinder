//
//  SharedDataModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 5/27/24.
//

import SwiftUI

class SharedDataModel: ObservableObject {
    
    private let distanceKey = "distance"
    private let navigationMapServiceKey = "navigationMapService"
    
   @Published var distance: Double {
        didSet {
            UserDefaults.standard.set(distance, forKey: distanceKey)
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
        // Load distance from UserDefaults or use default value
        let savedValue = UserDefaults.standard.double(forKey: distanceKey)
        distance = savedValue == 0 ? 5.0 : savedValue
        
        // Load navigationMapService from UserDefaults or use default value
        if let savedData = UserDefaults.standard.data(forKey: navigationMapServiceKey),
           let decodedService = try? JSONDecoder().decode(NavigationMapService.self, from: savedData) {
            self.navigationMapService = decodedService
        } else {
            self.navigationMapService = .appleMaps
        }
    }
}


