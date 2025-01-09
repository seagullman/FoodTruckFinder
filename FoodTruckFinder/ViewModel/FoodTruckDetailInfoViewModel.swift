//
//  FoodTruckDetailInfoViewModel.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 1/3/25.
//

import Foundation

extension FoodTruckDetailInfoView {
    
    @Observable
    internal class ViewModel {
        
        var name: String
        var location: FTFLocation
        var openUntil: String?
        
        init(name: String, location: FTFLocation, openUntil: String? = nil) {
            self.name = name
            self.location = location
            self.openUntil = openUntil
        }
    }
}
