# iOS Integration Guide

Step-by-step guide to integrate AWS backend with your FoodTruckFinder iOS app.

## Step 1: Deploy Backend

First, deploy the AWS backend:

```bash
cd aws-backend
./deploy.sh dev
```

Save the outputs:
- API Endpoint URL
- User Pool ID
- User Pool Client ID
- Images Bucket Name

## Step 2: Update Amplify Configuration

1. Copy `amplifyconfiguration.json` to your Xcode project root
2. Replace placeholders with values from deployment:
   - `REPLACE_WITH_USER_POOL_ID` → Your Cognito User Pool ID
   - `REPLACE_WITH_APP_CLIENT_ID` → Your Cognito App Client ID
   - `REPLACE_WITH_IDENTITY_POOL_ID` → Your Identity Pool ID (if using)

3. Add to Xcode project (drag into project navigator)

## Step 3: Add AWS Dependencies

Update your `Package.swift` or add via Xcode:

```swift
dependencies: [
    .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Search: `https://github.com/aws-amplify/amplify-swift`
3. Add: `Amplify` and `AWSCognitoAuthPlugin`

## Step 4: Add New Files

Copy these files to your project:

1. `AWSNetworkManager.swift` → `FoodTruckFinder/Utility/`
2. `AWSAuthManager.swift` → `FoodTruckFinder/Utility/`

## Step 5: Update App Entry Point

In `FoodTruckFinderApp.swift`:

```swift
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct FoodTruckFinderApp: App {
    
    @State private var foodTruckStore: FoodTruckStore
    
    init() {
        // Configure Amplify
        configureAmplify()
        
        // Use AWS backend
        let networkClient = AWSNetworkManager.shared
        _foodTruckStore = State(initialValue: FoodTruckStore(httpClient: networkClient))
    }
    
    var body: some Scene {
        WindowGroup {
            FTFTabView()
                .environment(foodTruckStore)
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("✅ Amplify configured")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
}
```

## Step 6: Update NetworkManager Base URL

In `AWSNetworkManager.swift`, update the base URL:

```swift
private let baseURL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev"
```

Replace `YOUR_API_ID` with your actual API Gateway ID from deployment.

## Step 7: Update Authentication

Replace Firebase auth calls with AWS Cognito:

### Sign Up
```swift
// Old Firebase
try await Auth.auth().createUser(withEmail: email, password: password)

// New AWS Cognito
try await AWSAuthManager.shared.signUp(email: email, password: password, name: name)
```

### Sign In
```swift
// Old Firebase
try await Auth.auth().signIn(withEmail: email, password: password)

// New AWS Cognito
try await AWSAuthManager.shared.signIn(email: email, password: password)
```

### Sign Out
```swift
// Old Firebase
try Auth.auth().signOut()

// New AWS Cognito
try await AWSAuthManager.shared.signOut()
```

## Step 8: Update File Upload

Replace Firebase Storage with S3:

```swift
// Old Firebase Storage
let storage = Storage.storage()
let storageRef = storage.reference()
let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
try await imageRef.putDataAsync(imageData)
let url = try await imageRef.downloadURL()

// New S3 with Presigned URLs
let imageUrl = try await AWSNetworkManager.shared.uploadImage(
    imageData,
    fileName: "truck-image.jpg"
)
```

## Step 9: Test Authentication Flow

1. Run the app
2. Try signing up a new user
3. Check email for confirmation code
4. Confirm email with code
5. Sign in with credentials
6. Verify token is sent with API requests

## Step 10: Test API Endpoints

1. Launch app
2. Allow location permissions
3. Verify food trucks load on map
4. Tap a food truck to see details
5. Test creating a new food truck (if owner)
6. Test uploading images

## Feature Flag (Optional)

To gradually migrate users, use a feature flag:

```swift
enum BackendProvider {
    case firebase
    case aws
}

class AppConfiguration {
    static var backendProvider: BackendProvider {
        // Toggle this to switch backends
        return .aws
    }
}

// In FoodTruckFinderApp.swift
let networkClient: NetworkClient = {
    switch AppConfiguration.backendProvider {
    case .firebase:
        return NetworkManager.shared
    case .aws:
        return AWSNetworkManager.shared
    }
}()
```

## Troubleshooting

### Authentication Issues

**Problem**: "User is not authenticated"
**Solution**: 
- Verify `amplifyconfiguration.json` is in project
- Check User Pool ID and Client ID are correct
- Ensure user confirmed email

### API Errors

**Problem**: 401 Unauthorized
**Solution**:
- Check token is being sent in Authorization header
- Verify Cognito authorizer is configured in API Gateway
- Check token hasn't expired

**Problem**: 404 Not Found
**Solution**:
- Verify API endpoint URL is correct
- Check API Gateway stage is deployed
- Ensure Lambda functions are deployed

### Image Upload Issues

**Problem**: Images not uploading
**Solution**:
- Check S3 bucket CORS configuration
- Verify presigned URL hasn't expired
- Ensure Content-Type header matches

### Location/Distance Issues

**Problem**: No food trucks showing
**Solution**:
- Verify location permissions granted
- Check distance parameter (try increasing)
- Ensure DynamoDB has data
- Check Lambda logs for errors

## Monitoring

### CloudWatch Logs

View Lambda function logs:
```bash
sam logs -n GetFoodTrucksFunction --stack-name foodtruckfinder-backend-dev --tail
```

### API Gateway Metrics

Check API Gateway dashboard in AWS Console:
- Request count
- Error rates
- Latency

### DynamoDB Metrics

Monitor DynamoDB:
- Read/write capacity
- Throttled requests
- Item count

## Next Steps

1. Test thoroughly in development
2. Deploy to staging environment
3. Beta test with select users
4. Monitor metrics and logs
5. Roll out to production
6. Decommission Firebase

## Rollback Plan

If issues occur:

1. Change `backendProvider` to `.firebase`
2. Rebuild and deploy
3. Firebase data remains unchanged
4. Investigate AWS issues

## Support

Common issues:
- Check CloudWatch logs for Lambda errors
- Verify IAM permissions
- Test endpoints with curl
- Check Cognito user pool settings
- Verify DynamoDB table has data
