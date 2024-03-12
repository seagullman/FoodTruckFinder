//
//  FTOwnerDashboardView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import SwiftUI
import FirebaseAuth

struct FTOwnerDashboardView: View {
    
    let viewModel = ViewModel()
    
//    @State private var presentImporter = false
    
    var body: some View {
        VStack {
            Text("Food Truck Owner Dashboard!")
            
            if let foodTruck = viewModel.foodTruck {
                Text(foodTruck.name)
                Text(foodTruck.description)
                Text(foodTruck.hoursOfOperation)
                Text(foodTruck.websiteUrl)
                Text(foodTruck.cuisineType.rawValue)
            }
            
            Button {
                Task {
                    do {
                         try FTFAuthManager.shared.signOut()
                    } catch {
                        print("***** Error signing user out")
                    }
                }
            } label: {
                Text("Sign Out")
            }

        }
        .task {
            await viewModel.loadFoodTruck()
        }
//        .onAppear {
//            Task {
////                for truck in FTFMockData.foodTrucks {
//                await NetworkManager.shared.save(foodTruck: FoodTruck(name: "Brad's Grub", description: "Home cooking by Brad", websiteUrl: "bradsiegel.com", hoursOfOperation: "M-SUN: 8-10", cuisineType: .american, location: FTFLocation(name: "Outside the Embassy Suites", latitude: 35.9648496, longitude: -83.9184627)))
////                }
//            }
//        }
    }
}

#Preview {
    FTOwnerDashboardView()
}





//VStack {
//    Text("Food Truck Owner Dashboard!")
//    
//    
//    
//    Button("Open") {
//        presentImporter = true
//    }.fileImporter(isPresented: $presentImporter, allowedContentTypes: [.pdf]) { result in
//        switch result {
//        case .success(let url):
//            let fileManager = FTFFileUploadManager()
//            fileManager.uploadPDF(from: url)
//        case .failure(let error):
//            print(error)
//        }
//    }
//}
