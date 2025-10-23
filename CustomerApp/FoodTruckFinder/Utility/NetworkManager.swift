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

protocol NetworkClient {
    func getFoodTrucks(within miles: Double, of location: CLLocation) async throws -> [FoodTruckListItem]
    func getFoodTruck(by id: String) async throws -> FoodTruck
}

class NetworkManager: NetworkClient {
    
    static let shared = NetworkManager()
    
    private lazy var db: Firestore = {
        return Firestore.firestore()
    }()

    
    private var baseUrlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        // Switch between Firebase and AWS
        // Firebase: components.host = "us-central1-food-truck-finder-ed9db.cloudfunctions.net"
        // AWS: components.host = "c4yzk7yh86.execute-api.us-east-1.amazonaws.com"
        components.host = "c4yzk7yh86.execute-api.us-east-1.amazonaws.com"
        components.path = "/dev/foodtrucks"
        
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
        components.path += "/\(id)"
        
        return components.url?.absoluteString
    }
    
    private init() {}
    
    func getFoodTrucks(within miles: Double, of location: CLLocation) async throws -> [FoodTruckListItem] {
        guard let urlString = allFoodTrucksUrlString(within: miles, of: location) else {
            print("❌ Invalid URL")
            throw FTFError.invalidUrl
        }
        
        print("🌐 Fetching from: \(urlString)")
        let result: [FoodTruckListItem] = try await makeRequest(urlString: urlString)
        print("✅ Received \(result.count) food trucks")
        return result
    }
    
    func getFoodTruck(by id: String) async throws -> FoodTruck {
        guard let urlString = foodTruckDetailUrlString(id: id) else {
            throw FTFError.invalidUrl
        }
        
        
        return try await makeRequest(urlString: urlString)
    }
    
    // MARK: Private functions
    
    private func makeRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw FTFError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw FTFError.invalidResponse
        }
        
        print("📡 Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Error response: \(responseString)")
            }
            throw FTFError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Debug: print raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON: \(jsonString.prefix(200))...")
            }
            
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding details: \(decodingError)")
            }
            throw FTFError.invalidData
        }
    }
    
}

