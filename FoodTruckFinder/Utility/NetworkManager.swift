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


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let db = Firestore.firestore()
    private let foodTrucksCollectionId = "food-trucks"
    
    private init() {}
    
    func getAllFoodTrucks() async throws -> Set<FoodTruck> {
        var foodTrucks: Set<FoodTruck> = Set()
        
        do {
          let snapshot = try await db.collection(foodTrucksCollectionId).getDocuments()
          for document in snapshot.documents {
              do {
                  let foodTruck = try document.data(as: FoodTruck.self)
                  foodTrucks.insert(foodTruck)
              }
          }
        } catch {
          print("Error getting documents: \(error)")
        }
        
        return foodTrucks
    }
    
    func getFoodTrucks(within miles: Double, of location: CLLocation) async throws -> [FoodTruckListItem] {
        let urlString = "https://us-central1-food-truck-finder-ed9db.cloudfunctions.net/api/location/foodtrucks?latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)&distance=\(miles)"
        return try await makeRequest(urlString: urlString)
    }
    
    func getFoodTruck(by documentId: String) async throws -> FoodTruck? {
        let docRef = db.collection(foodTrucksCollectionId).document(documentId)
        var foodTruck: FoodTruck?
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                foodTruck = try document.data(as: FoodTruck.self)
            }
        } catch {
            print("Error fetching food truck by documentId")
            throw FTFError.invalidData
        }
        return foodTruck
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
    
    func save(foodTruck: FoodTruck) async {
        // TODO: If no document exists, it is created. If a document already exists, it is overwritten.
        // need to fix this so it is an update if it exists
        do {
            try db.collection("food-trucks").document(Auth.auth().currentUser?.uid ?? String(describing: foodTruck.id)).setData(from: foodTruck)
        } catch let error {
          print("Error writing foodTruck to Firestore: \(error)")
        }
        
        
        
        // Add a second document with a generated ID.
//        do {
//            let ref = try await db.collection("food-trucks").addDocument(data: [
//                "id": foodTruck.id,
//                "name": foodTruck.name,
//                "description": foodTruck.description,
//                "websiteUrl": foodTruck.websiteUrl,
//                "hoursOfOperation": foodTruck.hoursOfOperation,
//                "cuisineType": foodTruck.cuisineType.rawValue,
//                "location": foodTruck.location
//            ])
//            
////            let locationRef =  db.collection("food-trucks").document(ref.documentID)
//            
//            
//          print("Document added with ID: \(ref.documentID)")
//        } catch {
//          print("Error adding document: \(error)")
//        }
    }
    
}

//let id = UUID()
//let name: String
//let description: String
//let websiteUrl: String
//let hoursOfOperation: String
//let cuisineType: CuisineType
//let location: FTFLocation





//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}
//
//@main
//struct YourApp: App {
//  // register app delegate for Firebase setup
//  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//  var body: some Scene {
//    WindowGroup {
//      NavigationView {
//        ContentView()
//      }
//    }
//  }
//}
