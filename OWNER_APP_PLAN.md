# Food Truck Owner Operator App - Technical Plan

## Overview

**Consumer App** (Current): Customers find and discover food trucks
**Owner App** (New): Food truck operators manage their business

## Backend Architecture (Already Built!)

Your AWS backend already supports everything needed:

### ✅ Authentication
- **Cognito User Pool**: `us-east-1_2ZDCxmA6m`
- Owner operators get credentials from you
- Sign in with email/password
- JWT tokens for API authentication

### ✅ Database Schema
```
FoodTrucks Table:
- id (UUID)
- ownerId (Cognito user ID) ← Links truck to owner
- name
- description
- location { description, latitude, longitude }
- imageUrl (S3 URL)
- cuisineType
- menu (array of menu items)
- websiteUrl
- openUntil
- geoHash (for location queries)
- createdAt
- updatedAt
```

### ✅ API Endpoints

**Already Implemented:**
- `POST /foodtrucks` - Create food truck (requires auth)
- `PUT /foodtrucks/{id}` - Update food truck (requires auth, owner only)
- `DELETE /foodtrucks/{id}` - Delete food truck (requires auth, owner only)
- `POST /upload-url` - Get presigned URL for image upload (requires auth)

**Public (for consumer app):**
- `GET /foodtrucks` - Find nearby trucks
- `GET /foodtrucks/{id}` - Get truck details

## Owner App Features

### 1. Authentication Flow
```
Login Screen
  ↓
Enter credentials (provided by you)
  ↓
AWS Cognito authentication
  ↓
Dashboard
```

### 2. Dashboard
- **My Food Truck** card
  - Current location status
  - Open/Closed toggle
  - Quick stats (views, favorites)
- **Quick Actions**
  - Check In
  - Update Menu
  - Upload Photo
  - View Analytics

### 3. Check-In Feature (Core Feature!)

**How It Works:**
```swift
// Owner taps "Check In"
1. Get current GPS location
2. Show map to confirm/adjust location
3. Set "openUntil" time (e.g., "8:00 PM")
4. Update DynamoDB:
   - location: { lat, lon, description }
   - geoHash: calculated from lat/lon
   - openUntil: "8:00 PM"
   - updatedAt: timestamp

// Now visible to consumers!
Consumer app queries nearby trucks
  → Finds truck by geohash
  → Shows on map
```

**UI Flow:**
```
Dashboard
  ↓
Tap "Check In"
  ↓
Map View (shows current location)
  ↓
Confirm location or drag pin
  ↓
Set hours: "Open until 8:00 PM"
  ↓
Tap "Check In" button
  ↓
API: PUT /foodtrucks/{id}
  ↓
Success! "You're now visible to customers"
```

### 4. Menu Management

**Features:**
- Add/Edit/Delete menu items
- Organize by categories
- Set prices
- Mark vegetarian/gluten-free
- Upload item photos (optional)

**Data Structure:**
```json
{
  "menu": [
    {
      "category": "Tacos",
      "items": [
        {
          "name": "Carne Asada Taco",
          "description": "Grilled steak with onions",
          "price": 3.50,
          "isVegetarian": false,
          "isGlutenFree": true
        }
      ]
    }
  ]
}
```

**API Call:**
```swift
PUT /foodtrucks/{id}
Body: {
  "menu": [...]
}
```

### 5. Profile Management

**Edit Truck Info:**
- Name
- Description
- Cuisine type
- Website URL
- Logo/Photo

**Logo Upload Flow:**
```swift
1. Select image from photo library
2. Resize to 400x400
3. POST /upload-url → Get presigned S3 URL
4. PUT image to S3 URL
5. PUT /foodtrucks/{id} with new imageUrl
```

### 6. Location History

**Track where you've been:**
```
DynamoDB Table: LocationHistory
- id (UUID)
- truckId
- location { lat, lon, description }
- checkedInAt (timestamp)
- checkedOutAt (timestamp)
- revenue (optional)
```

**Benefits:**
- See which locations perform best
- Track hours worked
- Analytics for business decisions

### 7. Analytics Dashboard

**Metrics to Track:**
- Views (how many people saw your truck)
- Favorites (how many saved your truck)
- Popular locations
- Peak hours
- Menu item popularity

## Technical Implementation

### iOS App Structure

```
FoodTruckOwnerApp/
├── Authentication/
│   ├── LoginView.swift
│   └── AuthManager.swift (uses AWS Cognito)
├── Dashboard/
│   ├── DashboardView.swift
│   └── TruckStatusCard.swift
├── CheckIn/
│   ├── CheckInMapView.swift
│   ├── LocationPicker.swift
│   └── HoursSelector.swift
├── Menu/
│   ├── MenuListView.swift
│   ├── MenuItemEditor.swift
│   └── CategoryManager.swift
├── Profile/
│   ├── TruckProfileView.swift
│   ├── PhotoUploader.swift
│   └── InfoEditor.swift
├── Analytics/
│   ├── AnalyticsView.swift
│   └── LocationHistoryView.swift
└── Networking/
    ├── OwnerAPIClient.swift (uses AWSNetworkManager)
    └── Models.swift
```

### Key Code Snippets

**Check In:**
```swift
func checkIn(at location: CLLocation, until closeTime: String) async throws {
    let updates = FoodTruckUpdate(
        location: LocationCreate(
            description: await reverseGeocode(location),
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ),
        openUntil: closeTime
    )
    
    try await AWSNetworkManager.shared.updateFoodTruck(
        id: myTruckId,
        updates: updates
    )
}
```

**Upload Logo:**
```swift
func uploadLogo(_ image: UIImage) async throws -> String {
    // Resize image
    let resizedImage = image.resize(to: CGSize(width: 400, height: 400))
    guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
        throw UploadError.invalidImage
    }
    
    // Upload to S3
    let imageUrl = try await AWSNetworkManager.shared.uploadImage(
        imageData,
        fileName: "truck-logo.jpg"
    )
    
    // Update truck profile
    try await AWSNetworkManager.shared.updateFoodTruck(
        id: myTruckId,
        updates: FoodTruckUpdate(imageUrl: imageUrl)
    )
    
    return imageUrl
}
```

**Update Menu:**
```swift
func updateMenu(_ menu: [MenuCategory]) async throws {
    try await AWSNetworkManager.shared.updateFoodTruck(
        id: myTruckId,
        updates: FoodTruckUpdate(menu: menu)
    )
}
```

## Backend Enhancements Needed

### 1. Owner Registration Endpoint

**New Lambda Function:**
```python
POST /owners/register
Body: {
  "email": "owner@example.com",
  "name": "John's Tacos",
  "phone": "555-1234"
}

Response: {
  "message": "Registration request submitted",
  "requestId": "abc123"
}
```

You review and approve, then create Cognito user.

### 2. Analytics Endpoints

**New Lambda Functions:**
```python
# Track views
POST /foodtrucks/{id}/analytics/view

# Track favorites
POST /foodtrucks/{id}/analytics/favorite

# Get analytics
GET /foodtrucks/{id}/analytics
Response: {
  "views": 1234,
  "favorites": 56,
  "popularLocations": [...],
  "peakHours": [...]
}
```

### 3. Location History

**New Lambda Functions:**
```python
# Check in
POST /foodtrucks/{id}/checkin
Body: {
  "location": {...},
  "openUntil": "8:00 PM"
}

# Check out
POST /foodtrucks/{id}/checkout

# Get history
GET /foodtrucks/{id}/history
```

### 4. Push Notifications (Optional)

**Use AWS SNS:**
- Notify owner when customer favorites their truck
- Remind owner to check out at end of day
- Alert when truck is inactive for too long

## User Management Strategy

### Option 1: Manual Approval (Recommended for MVP)

**Process:**
1. Owner fills out application form (web or email)
2. You review application
3. You manually create Cognito user via AWS Console
4. Send credentials to owner
5. Owner logs in to app

**Pros:**
- Full control over who gets access
- Verify business legitimacy
- Build relationships with owners
- Prevent spam/abuse

### Option 2: Self-Service with Approval

**Process:**
1. Owner signs up in app
2. Request goes to approval queue (DynamoDB)
3. You review in admin dashboard
4. Approve/Reject
5. If approved, Cognito user created automatically
6. Owner receives email with credentials

### Option 3: Subscription Model

**Process:**
1. Owner signs up
2. Enters payment info (Stripe)
3. Auto-approved after payment
4. Monthly subscription ($29/month?)
5. Cognito user created automatically

## Monetization Ideas

1. **Subscription**: $29-49/month per truck
2. **Commission**: Small % of sales (if you add ordering)
3. **Premium Features**: 
   - Advanced analytics
   - Multiple locations
   - Promoted listings
4. **Freemium**: Basic free, pay for premium features

## Development Timeline

### Phase 1: MVP (4-6 weeks)
- ✅ Backend (Already done!)
- Week 1-2: Authentication & Dashboard
- Week 3-4: Check-In feature
- Week 5-6: Menu management & Profile

### Phase 2: Enhanced Features (4-6 weeks)
- Week 1-2: Analytics
- Week 3-4: Location history
- Week 5-6: Push notifications

### Phase 3: Polish & Launch (2-4 weeks)
- Testing
- Bug fixes
- App Store submission
- Marketing materials

## Next Steps

1. **Design mockups** for owner app
2. **Add analytics endpoints** to backend
3. **Build authentication flow** in iOS
4. **Implement check-in feature** (most important!)
5. **Test with beta owners**

## Questions to Consider

1. **Pricing**: Free, subscription, or commission?
2. **Approval process**: Manual or automated?
3. **Features**: What's MVP vs nice-to-have?
4. **Support**: How will you help owners?
5. **Marketing**: How will you find food truck owners?

---

Your backend is already 80% ready for the owner app! The main work is building the iOS app UI and adding analytics/history tracking.
