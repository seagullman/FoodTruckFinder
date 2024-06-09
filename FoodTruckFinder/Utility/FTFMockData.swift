//
//  FTFMockData.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/5/24.
//

import Foundation

public struct FTFMockData {
    
    static let foodTruck = FoodTruck(
                                name: "Taco Mafia",
                                description: "Authentic Mexican with a Cali twist!",
                                websiteUrl: "",
                                cuisineType: .mexican,
                                location: FTFLocation(
                                    description: "South Doyle Middle School",
                                    latitude: 35.940406,
                                    longitude: -83.894841
                                ),
                                imageFileName: nil
                            )
    
//    static let foodTrucks: [FoodTruck] = [
//        FoodTruck(
//            name: "Chick-fil-et",
//            description: "Eat more chicken!",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .american,
//            location: FTFLocation(
//                name: "Next to Gold's Gym",
//                latitude: 35.906570,
//                longitude: -83.837936
//            ), storeHours: <#StoreHours?#>
//        ),
//        FoodTruck(
//            name: "McDonalds",
//            description: "Great burgers and much more.",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .american,
//            location: FTFLocation(
//                name: "Food Truck Park old city",
//                latitude: 35.906820,
//                longitude: -83.839310
//            )
//        ),
//        FoodTruck(
//            name: "Aretha Frankensteins",
//            description: "Creepy good breakfast!",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .american,
//            location: FTFLocation(
//                name: "South side of Market Square",
//                latitude: 35.943350,
//                longitude: -83.910630
//            )
//        ),
//        FoodTruck(
//            name: "Yee Haw Johnson City",
//            description: "Beer and Tacos",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .american,
//            location: FTFLocation(
//                name: "Downtown by the train tracks",
//                latitude: 36.3144835,
//                longitude: -82.3536373
//            )
//        ),
//        FoodTruck(
//            name: "Honky Tonk Central",
//            description: "Burgers, hot dogs, and corn dogs.",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .american,
//            location: FTFLocation(
//                name: "On broadway",
//                latitude: 36.1609255,
//                longitude: -86.7768765
//            )
//        ),
//        FoodTruck(
//            name: "Taco Mafia",
//            description: "Authentic Mexican with a Cali twist!",
//            websiteUrl: "",
//            hoursOfOperation: "",
//            cuisineType: .mexican,
//            location: FTFLocation(
//                name: "South Doyle Middle School",
//                latitude: 35.940406,
//                longitude: -83.894841
//            )
//        )
//    ]
}
