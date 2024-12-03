//
//  NetworkManager.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation


class NetworkManager { // TODO: make a protocol for NetworkClient
    
    static let shared = NetworkManager()
    
    private let db = Firestore.firestore()
    
    private var baseUrlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "us-central1-food-truck-finder-ed9db.cloudfunctions.net"
        components.path = "/api/location/foodtrucks/"
        
        return components
    }
    
    private func allFoodTrucksUrlString(within miles: Double, of location: CLLocation) -> String? {
        var components = baseUrlComponents
        components.queryItems = [
            .init(name: "latitude", value: String(location.coordinate.latitude)),
            .init(name: "longitude", value: String(location.coordinate.longitude)),
            .init(name: "distance", value: String(miles))
        ]
        
        return components.url?.absoluteString
    }
    
    private func foodTruckDetailUrlString(id: String) -> String? {
        var components = baseUrlComponents
        components.path += "\(id)"
        
        return components.url?.absoluteString
    }
    
    private init() {}
    
    func getFoodTrucks(within miles: Double, of location: CLLocation) async throws -> [FoodTruckListItem] {
        guard let urlString = allFoodTrucksUrlString(within: miles, of: location) else {
            throw FTFError.invalidUrl
        }
        
        return try await makeRequest(urlString: urlString)
    }
    
    func getFoodTruck(by documentId: String) async throws -> FoodTruck {
        guard let urlString = foodTruckDetailUrlString(id: documentId) else {
            throw FTFError.invalidUrl
        }
        
        
        return try await makeRequest(urlString: urlString)
    }
    
    // MARK: Private functions
    
    private func makeRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw FTFError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200
        else {
            throw FTFError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)
        } catch {
            throw FTFError.invalidData
        }
    }
    
}

