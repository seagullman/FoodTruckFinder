# Migration Guide: Firebase to AWS

Step-by-step guide to migrate FoodTruckFinder from Firebase to AWS.

## Overview

This migration moves:
- **Firestore** → **DynamoDB**
- **Firebase Storage** → **S3**
- **Firebase Auth** → **Cognito**
- **Cloud Functions** → **Lambda + API Gateway**

## Phase 1: Deploy AWS Infrastructure

### 1. Deploy Backend
```bash
cd aws-backend
./deploy.sh dev
```

### 2. Save Outputs
Note these values from deployment:
- API Endpoint URL
- Cognito User Pool ID
- Cognito User Pool Client ID
- S3 Bucket Name

## Phase 2: Migrate Data

### 1. Export Firebase Data

Create a script to export Firestore data:

```javascript
// export-firestore.js
const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json')
});

const db = admin.firestore();

async function exportFoodTrucks() {
  const snapshot = await db.collection('food-trucks').get();
  const trucks = [];
  
  snapshot.forEach(doc => {
    trucks.push({
      id: doc.id,
      ...doc.data()
    });
  });
  
  fs.writeFileSync('food-trucks.json', JSON.stringify(trucks, null, 2));
  console.log(`Exported ${trucks.length} food trucks`);
}

exportFoodTrucks();
```

Run:
```bash
node export-firestore.js
```

### 2. Import to DynamoDB

Create import script:

```python
# import-dynamodb.py
import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FoodTrucks-dev')

def convert_floats(obj):
    """Convert floats to Decimal for DynamoDB"""
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats(item) for item in obj]
    return obj

with open('food-trucks.json', 'r') as f:
    trucks = json.load(f)

for truck in trucks:
    # Transform to match new schema
    item = {
        'id': truck['id'],
        'name': truck['name'],
        'description': truck['description'],
        'cuisineType': truck.get('cuisineType', 'other'),
        'location': {
            'description': truck['location']['description'],
            'latitude': truck['location']['latitude'],
            'longitude': truck['location']['longitude']
        },
        'imageUrl': truck.get('imageUrl'),
        'websiteUrl': truck.get('websiteUrl', ''),
        'openUntil': truck.get('openUntil'),
        'menu': truck.get('menu', []),
        'ownerId': truck.get('ownerId', 'migrated'),
        'geoHash': calculate_geohash(
            truck['location']['latitude'],
            truck['location']['longitude']
        )
    }
    
    item = convert_floats(item)
    table.put_item(Item=item)
    print(f"Imported: {truck['name']}")

def calculate_geohash(lat, lon, precision=5):
    lat_grid = int((lat + 90) * (10 ** precision) / 180)
    lon_grid = int((lon + 180) * (10 ** precision) / 360)
    return f"{lat_grid}_{lon_grid}"

print("Import complete!")
```

Run:
```bash
python3 import-dynamodb.py
```

### 3. Migrate Images to S3

```python
# migrate-images.py
import boto3
import requests
from urllib.parse import urlparse

s3 = boto3.client('s3')
bucket_name = 'foodtruckfinder-images-dev-{account-id}'

with open('food-trucks.json', 'r') as f:
    trucks = json.load(f)

for truck in trucks:
    if truck.get('imageUrl'):
        firebase_url = truck['imageUrl']
        
        # Download from Firebase
        response = requests.get(firebase_url)
        
        if response.status_code == 200:
            # Upload to S3
            file_name = f"food-trucks/migrated/{truck['id']}.jpg"
            s3.put_object(
                Bucket=bucket_name,
                Key=file_name,
                Body=response.content,
                ContentType='image/jpeg'
            )
            
            new_url = f"https://{bucket_name}.s3.amazonaws.com/{file_name}"
            print(f"Migrated image for {truck['name']}: {new_url}")
```

## Phase 3: Update iOS App

### 1. Update Network Manager

Replace Firebase calls with AWS API calls:

```swift
// NetworkManager.swift
private var baseUrlComponents: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "{api-id}.execute-api.us-east-1.amazonaws.com"
    components.path = "/dev/foodtrucks"
    return components
}
```

### 2. Update Authentication

Replace Firebase Auth with Cognito:

```swift
// Update amplifyconfiguration.json
{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "us-east-1:xxx",
              "Region": "us-east-1"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "{user-pool-id}",
            "AppClientId": "{app-client-id}",
            "Region": "us-east-1"
          }
        }
      }
    }
  }
}
```

### 3. Update File Upload

Replace Firebase Storage with S3 presigned URLs:

```swift
// FileUploadManager.swift
func uploadImage(_ imageData: Data) async throws -> String {
    // 1. Get presigned URL
    let presignedResponse = try await getPresignedUrl(
        fileName: "image.jpg",
        contentType: "image/jpeg"
    )
    
    // 2. Upload to S3
    var request = URLRequest(url: URL(string: presignedResponse.uploadUrl)!)
    request.httpMethod = "PUT"
    request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    request.httpBody = imageData
    
    let (_, response) = try await URLSession.shared.data(for: request)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw UploadError.failed
    }
    
    // 3. Return public URL
    return presignedResponse.imageUrl
}
```

## Phase 4: Testing

### 1. Test API Endpoints
```bash
# Test get food trucks
curl "https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10"

# Test get food truck by ID
curl "https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/foodtrucks/{id}"
```

### 2. Test iOS App
- Launch app and verify food trucks load
- Test authentication flow
- Test image uploads
- Test creating/updating food trucks

### 3. Compare Results
Verify data matches between Firebase and AWS:
- Same food trucks appear
- Images load correctly
- Distances calculated correctly

## Phase 5: Cutover

### 1. Gradual Migration
Use feature flags to gradually switch users:

```swift
let useAWS = UserDefaults.standard.bool(forKey: "useAWSBackend")
let networkClient: NetworkClient = useAWS ? AWSNetworkManager() : FirebaseNetworkManager()
```

### 2. Monitor
- Check CloudWatch logs for errors
- Monitor API Gateway metrics
- Track DynamoDB read/write capacity

### 3. Decommission Firebase
Once stable:
1. Stop Firebase billing
2. Archive Firebase data
3. Remove Firebase dependencies from iOS app

## Rollback Plan

If issues occur:

1. **Immediate**: Switch feature flag back to Firebase
2. **Data**: Firebase data remains unchanged during migration
3. **Images**: Keep Firebase Storage active during transition

## Cost Comparison

### Firebase (Current)
- Firestore: ~$X/month
- Storage: ~$Y/month
- Functions: ~$Z/month

### AWS (Estimated)
- DynamoDB: ~$X/month (pay-per-request)
- S3: ~$Y/month
- Lambda: ~$Z/month (likely free tier)
- API Gateway: ~$W/month (likely free tier)

## Checklist

- [ ] Deploy AWS infrastructure
- [ ] Export Firebase data
- [ ] Import to DynamoDB
- [ ] Migrate images to S3
- [ ] Update iOS app configuration
- [ ] Update NetworkManager
- [ ] Update authentication
- [ ] Update file uploads
- [ ] Test all endpoints
- [ ] Test iOS app thoroughly
- [ ] Enable feature flag for beta users
- [ ] Monitor for 1 week
- [ ] Roll out to all users
- [ ] Decommission Firebase

## Support

If you encounter issues:
1. Check CloudWatch logs
2. Verify IAM permissions
3. Test endpoints with curl
4. Check DynamoDB items
5. Verify Cognito configuration
