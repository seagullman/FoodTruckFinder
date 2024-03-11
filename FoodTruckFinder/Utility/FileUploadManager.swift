//
//  FileUploadManager.swift
//  FoodTruckFinder
//
//  Created by Brad Siegel on 3/10/24.
//

import Foundation
import FirebaseStorage


class FTFFileUploadManager {
    
    func uploadPDF(from url: URL) {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child(url.lastPathComponent)
        
        // Upload the file to the path "docs/rivers.pdf"
        let uploadTask = riversRef.putData(url.dataRepresentation, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                
                print("***** URL: \(downloadURL)")
            }
        }
        uploadTask.resume()
    }
}
