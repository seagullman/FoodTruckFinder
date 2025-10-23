//
//  OwnerAPIClient.swift
//  FoodTruckOwnerApp
//
//  API client for owner operations with AWS backend
//

import Foundation
import CoreLocation
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore

class OwnerAPIClient {
    
    static let shared = OwnerAPIClient()
    
    private let baseURL = "https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev"
    
    private init() {}
    
    // MARK: - Food Truck Operations
    
    func getMyTruck() async throws -> FoodTruck {
        let url = URL(string: "\(baseURL)/foodtrucks/mine")!
        let token = try await getAuthToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(FoodTruck.self, from: data)
    }
    
    func updateTruck(id: String, updates: TruckUpdate) async throws {
        let url = URL(string: "\(baseURL)/foodtrucks/\(id)")!
        let token = try await getAuthToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(updates)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.invalidResponse
        }
    }
    
    func uploadImage(_ imageData: Data, fileName: String) async throws -> String {
        // Step 1: Get presigned URL
        let presignedResponse = try await getPresignedUrl(fileName: fileName, contentType: "image/jpeg")
        
        // Step 2: Upload to S3
        guard let uploadUrl = URL(string: presignedResponse.uploadUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.uploadFailed
        }
        
        // Step 3: Return public URL
        return presignedResponse.imageUrl
    }
    
    private func getPresignedUrl(fileName: String, contentType: String) async throws -> PresignedUrlResponse {
        let url = URL(string: "\(baseURL)/upload-url")!
        let token = try await getAuthToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PresignedUrlRequest(fileName: fileName, contentType: contentType)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PresignedUrlResponse.self, from: data)
    }
    
    private func getAuthToken() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        
        guard let tokens = session as? AuthCognitoTokensProvider else {
            throw APIError.notAuthenticated
        }
        
        let cognitoTokens = try tokens.getCognitoTokens().get()
        return cognitoTokens.idToken
    }
}

// MARK: - Models

struct TruckUpdate: Encodable {
    let name: String?
    let description: String?
    let cuisineType: String?
    let location: LocationUpdate?
    let websiteUrl: String?
    let imageUrl: String?
    let openUntil: String?
    let menu: [MenuCategory]?
    
    init(name: String? = nil,
         description: String? = nil,
         cuisineType: String? = nil,
         location: LocationUpdate? = nil,
         websiteUrl: String? = nil,
         imageUrl: String? = nil,
         openUntil: String? = nil,
         menu: [MenuCategory]? = nil) {
        self.name = name
        self.description = description
        self.cuisineType = cuisineType
        self.location = location
        self.websiteUrl = websiteUrl
        self.imageUrl = imageUrl
        self.openUntil = openUntil
        self.menu = menu
    }
}

struct LocationUpdate: Codable {
    let description: String
    let latitude: Double
    let longitude: Double
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

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notAuthenticated
    case serverError(String)
    case uploadFailed
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notAuthenticated:
            return "Not authenticated"
        case .serverError(let message):
            return message
        case .uploadFailed:
            return "Failed to upload image"
        case .notImplemented:
            return "Feature not yet implemented"
        }
    }
}
