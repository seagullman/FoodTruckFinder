//
//  Alert.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/12/24.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidLoginCredentials  = AlertItem(title: Text("Sign In Failed"),
                                                   message: Text("The username or password is incorrect. Please try again."),
                                                   dismissButton: .default(Text("OK")))
    
    static let invalidRequest           = AlertItem(title: Text("Something went wrong"),
                                                   message: Text("Sorry, we were unable to complete your request. Please try again."),
                                                   dismissButton: .default(Text("OK")))
    
//    static let unableToFetchFoodTrucks  = AlertItem(title: Text("Something went wrong"),
//                                                   message: Text("Sorry, we were unable to complete your request. Please try again."),
//                                                   dismissButton: .default(Text("OK")))
}
