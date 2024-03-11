//
//  FTOwnerDashboardView.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/8/24.
//

import SwiftUI

struct FTOwnerDashboardView: View {
    
    @State private var presentImporter = false
    
    var body: some View {
        VStack {
            Text("Food Truck Owner Dashboard!")
            Button("Open") {
                presentImporter = true
            }.fileImporter(isPresented: $presentImporter, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    let fileManager = FTFFileUploadManager()
                    fileManager.uploadPDF(from: url)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

#Preview {
    FTOwnerDashboardView()
}
