# Owner App Implementation Plan

## Status: Ready to Implement

The owner app needs these components with full AWS integration:

## ✅ Already Have
- Fresh Xcode project
- Shared models copied (FoodTruck, Menu, Location, etc.)
- LocationManager copied
- amplifyconfiguration.json copied
- AWS backend fully deployed and working

## 🔨 Need to Create

### 1. Networking Layer
- `OwnerAPIClient.swift` - API calls to AWS
- Uses same endpoints as consumer app
- Adds owner-specific operations

### 2. Authentication
- `OwnerAuthStore.swift` - Cognito auth manager
- `LoginView.swift` - Beautiful login screen

### 3. Core Views
- `FoodTruckOwnerAppApp.swift` - App entry point
- `OwnerTabView.swift` - Tab navigation
- `DashboardView.swift` - Status & quick actions
- `CheckInView.swift` - Map-based check-in
- `MenuView.swift` - Menu management
- `ProfileView.swift` - Truck profile editor

### 4. Business Logic
- `TruckStore.swift` - Manages truck state
- Integrates with OwnerAPIClient

### 5. Supporting Views
- `LoadingView.swift`
- Various card components

## Implementation Order

1. ✅ Copy shared models
2. ✅ Copy utilities
3. ⬜ Create OwnerAPIClient (AWS integration)
4. ⬜ Create OwnerAuthStore (Cognito)
5. ⬜ Create LoginView
6. ⬜ Create TruckStore
7. ⬜ Create all main views
8. ⬜ Update app entry point
9. ⬜ Add to Xcode project
10. ⬜ Test & debug

## Key Features to Implement

### Check-In (Most Important!)
```swift
// Owner checks in at location
PUT /foodtrucks/{id}
Body: {
  "location": { lat, lon, description },
  "openUntil": "8:00 PM",
  "geoHash": calculated
}

// Immediately visible to consumers!
```

### Menu Management
```swift
PUT /foodtrucks/{id}
Body: {
  "menu": [
    {
      "category": "Tacos",
      "items": [...]
    }
  ]
}
```

### Logo Upload
```swift
// 1. Get presigned URL
POST /upload-url
Body: { "fileName": "logo.jpg", "contentType": "image/jpeg" }

// 2. Upload to S3
PUT {presignedUrl}
Body: imageData

// 3. Update truck
PUT /foodtrucks/{id}
Body: { "imageUrl": publicUrl }
```

## Next Step

Run: `kiro implement owner app with full AWS integration`

This will create all files with real API calls, proper error handling, and production-ready code.
