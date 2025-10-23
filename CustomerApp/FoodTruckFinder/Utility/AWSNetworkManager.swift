//
//  AWSNetworkManager.swift
//  FoodTruckFinder
//
//  AWS Backend Integration
//

import Foundation
import CoreLocation
import Amplify

class AWSNetworkManager: NetworkClient {
    
    static let shared = AWSNetworkManager()
    
    private let baseURL = "https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev"
    
    private var baseUrlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "c4yzk7yh86.execute-api.us-east-1.amazonaws.com"
        components.path = "/dev/foodtrucks"
        return components
    }
    
    private init() {}
    
    // MARK: - NetworkClient Protocol
    
    func getFoodTrucks(within miles: Double, of location: CLLocation) async throws -> [FoodTruckListItem] {
        var components = baseUrlComponents
        components.queryItems = [
            .init(name: "latitude", value: String(location.coordinate.latitude)),
            .init(name: "longitude", value: String(location.coordinate.longitude)),
            .init(name: "distance", value: String(miles))
        ]
        
        guard let url = components.url else {
            throw FTFError.invalidUrl
        }
        
        return try await makeRequest(url: url, method: "GET")
    }
    
    func getFoodTruck(by id: String) async throws -> FoodTruck {
        var components = baseUrlComponents
        components.path += "/\(id)"
        
        guard let url = components.url else {
            throw FTFError.invalidUrl
        }
        
        return try await makeRequest(url: url, method: "GET")
    }
    
    // MARK: - Authenticated Requests
    
    func createFoodTruck(_ truck: FoodTruckCreate) async throws -> String {
        guard let url = URL(string: "\(baseURL)/foodtrucks") else {
            throw FTFError.invalidUrl
        }
        
        let token = try await getAuthToken()
        
        let response: CreateFoodTruckResponse = try await makeAuthenticatedRequest(
            url: url,
            method: "POST",
            body: truck,
            token: token
        )
        
        return response.id
    }
    
    func updateFoodTruck(id: String, updates: FoodTruckUpdate) async throws {
        guard let url = URL(string: "\(baseURL)/foodtrucks/\(id)") else {
            throw FTFError.invalidUrl
        }
        
        let token = try await getAuthToken()
        
        let _: MessageResponse = try await makeAuthenticatedRequest(
            url: url,
            method: "PUT",
            body: updates,
            token: token
        )
    }
    
    func deleteFoodTruck(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/foodtrucks/\(id)") else {
            throw FTFError.invalidUrl
        }
        
        let token = try await getAuthToken()
        
        let _: MessageResponse = try await makeAuthenticatedRequest(
            url: url,
            method: "DELETE",
            body: nil as String?,
            token: token
        )
    }
    
    // MARK: - Image Upload
    
    func uploadImage(_ imageData: Data, fileName: String) async throws -> String {
        // Step 1: Get presigned URL
        let presignedResponse = try await getPresignedUrl(
            fileName: fileName,
            contentType: "image/jpeg"
        )
        
        // Step 2: Upload to S3
        guard let uploadUrl = URL(string: presignedResponse.uploadUrl) else {
            throw FTFError.invalidUrl
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FTFError.invalidResponse
        }
        
        // Step 3: Return public URL
        return presignedResponse.imageUrl
    }
    
    private func getPresignedUrl(fileName: String, contentType: String) async throws -> PresignedUrlResponse {
        guard let url = URL(string: "\(baseURL)/upload-url") else {
            throw FTFError.invalidUrl
        }
        
        let token = try await getAuthToken()
        
        let body = PresignedUrlRequest(fileName: fileName, contentType: contentType)
        
        return try await makeAuthenticatedRequest(
            url: url,
            method: "POST",
            body: body,
            token: token
        )
    }
    
    // MARK: - Private Helpers
    
    private func makeRequest<T: Decodable>(url: URL, method: String) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FTFError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw FTFError.invalidData
        }
    }
    
    private func makeAuthenticatedRequest<T: Decodable, B: Encodable>(
        url: URL,
        method: String,
        body: B?,
        token: String
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FTFError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw FTFError.serverError(errorResponse.error)
            }
            throw FTFError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw FTFError.invalidData
        }
    }
    
    private func getAuthToken() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        
        guard let cognitoSession = session as? AuthCognitoTokensProvider else {
            throw FTFError.notAuthenticated
        }
        
        let tokens = try cognitoSession.getCognitoTokens().get()
        return tokens.idToken
    }
}

// MARK: - Request/Response Models

struct FoodTruckCreate: Encodable {
    let name: String
    let description: String
    let cuisineType: String
    let location: LocationCreate
    let websiteUrl: String?
    let imageUrl: String?
    let openUntil: String?
    let menu: [MenuCategory]?
}

struct FoodTruckUpdate: Encodable {
    let name: String?
    let description: String?
    let cuisineType: String?
    let location: LocationCreate?
    let websiteUrl: String?
    let imageUrl: String?
    let openUntil: String?
    let menu: [MenuCategory]?
}

struct LocationCreate: Codable {
    let description: String
    let latitude: Double
    let longitude: Double
}

struct CreateFoodTruckResponse: Decodable {
    let id: String
    let message: String
}

struct MessageResponse: Decodable {
    let message: String
}

struct PresignedUrlRequest: Encodable {
    let fileName: String
    let contentType: String
}

struct PresignedUrlResponse: Decodable {
    let uploadUrl: String
    let imageUrl: String
    let key: String
}

struct ErrorResponse: Decodable {
    let error: String
}

// MARK: - Error Extension

extension FTFError {
    static func serverError(_ message: String) -> FTFError {
        // Map to appropriate error type
        return .invalidResponse
    }
    
    static var notAuthenticated: FTFError {
        return .invalidCredentials
    }
}
