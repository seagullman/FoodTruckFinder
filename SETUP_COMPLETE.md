# AWS Backend Setup Complete! 🎉

Your FoodTruckFinder app is now configured to use AWS instead of Firebase.

## What Was Done

### 1. Backend Deployed ✅
- **API Endpoint**: `https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev`
- **Region**: us-east-1
- **Stack**: foodtruckfinder-backend-dev

### 2. Resources Created ✅
- **DynamoDB Tables**: FoodTrucks-dev, Users-dev
- **S3 Bucket**: foodtruckfinder-images-dev-{your-account-id}
- **API Gateway**: 6 REST endpoints
- **Lambda Functions**: 6 Python functions
- **Cognito User Pool**: us-east-1_2ZDCxmA6m
- **Cognito Client**: 4ji0p0q4ln4j22idg3ehiaa00s

### 3. iOS App Updated ✅
- Added `AWSNetworkManager.swift` to `FoodTruckFinder/Utility/`
- Added `AWSAuthManager.swift` to `FoodTruckFinder/Utility/`
- Added `amplifyconfiguration.json` to project root
- Updated `FoodTruckFinderApp.swift` to use AWS backend

## Next Steps

### 1. Add Files to Xcode Project

Open Xcode and add these new files to your project:

1. **amplifyconfiguration.json** (project root)
   - Drag into Xcode project navigator
   - Make sure "Copy items if needed" is checked
   - Add to FoodTruckFinder target

2. **AWSNetworkManager.swift** (FoodTruckFinder/Utility/)
   - Already in the correct folder
   - Add to Xcode project if not visible

3. **AWSAuthManager.swift** (FoodTruckFinder/Utility/)
   - Already in the correct folder
   - Add to Xcode project if not visible

### 2. Add Amplify Swift Package

In Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/aws-amplify/amplify-swift`
3. Version: 2.0.0 or later
4. Add these products:
   - Amplify
   - AWSCognitoAuthPlugin

### 3. Seed Test Data

```bash
cd aws-backend/scripts
python3 seed-data.py dev
```

This adds 5 sample food trucks in San Francisco.

### 4. Test the API

```bash
cd aws-backend/scripts
chmod +x test-api.sh
./test-api.sh https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev
```

### 5. Build and Run

1. Clean build folder: Cmd+Shift+K
2. Build: Cmd+B
3. Run: Cmd+R

## API Endpoints

All endpoints are live at: `https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev`

### Public (No Auth)
- `GET /foodtrucks?latitude={lat}&longitude={lon}&distance={miles}` - Get nearby trucks
- `GET /foodtrucks/{id}` - Get truck details

### Protected (Requires Auth)
- `POST /foodtrucks` - Create food truck
- `PUT /foodtrucks/{id}` - Update food truck
- `DELETE /foodtrucks/{id}` - Delete food truck
- `POST /upload-url` - Get S3 presigned URL for image upload

## Testing

### Test API Directly
```bash
# Get food trucks near San Francisco
curl "https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10"
```

### Test in iOS App
1. Launch app
2. Allow location permissions
3. Food trucks should load on map
4. Tap a truck to see details

## Authentication

The app now uses AWS Cognito instead of Firebase Auth:

- Sign up creates user in Cognito
- Email verification required
- JWT tokens used for API authentication
- Tokens automatically refreshed by Amplify

## Troubleshooting

### Build Errors

**"Cannot find 'Amplify' in scope"**
- Add Amplify Swift package (see step 2 above)

**"Cannot find 'AWSNetworkManager' in scope"**
- Add AWSNetworkManager.swift to Xcode project

**"amplifyconfiguration.json not found"**
- Add amplifyconfiguration.json to Xcode project
- Ensure it's in the target membership

### Runtime Errors

**"No food trucks found"**
- Run seed-data.py to add test data
- Check location permissions
- Increase distance parameter

**"Authentication failed"**
- Check Cognito User Pool ID in amplifyconfiguration.json
- Verify user email is confirmed
- Check CloudWatch logs for errors

### View Logs

```bash
# Lambda logs
sam logs -n GetFoodTrucksFunction --stack-name foodtruckfinder-backend-dev --tail

# DynamoDB items
aws dynamodb scan --table-name FoodTrucks-dev --max-items 5
```

## Migration from Firebase

If you want to migrate existing Firebase data:

```bash
cd aws-backend/scripts

# 1. Export from Firebase
node export-firebase.js

# 2. Import to DynamoDB
python3 import-dynamodb.py dev food-trucks-export.json
```

See `aws-backend/MIGRATION.md` for full guide.

## Cost

Current setup costs approximately:
- **DynamoDB**: ~$1-2/month (pay-per-request)
- **Lambda**: Free tier (1M requests/month)
- **API Gateway**: Free tier (1M requests/month)
- **S3**: ~$0.50/month
- **Cognito**: Free tier (50,000 MAUs)

**Total**: ~$2-3/month for development

## Cleanup

To delete everything:

```bash
aws cloudformation delete-stack --stack-name foodtruckfinder-backend-dev
```

## Support

- **Backend Docs**: `aws-backend/README.md`
- **Integration Guide**: `aws-backend/ios-integration/INTEGRATION_GUIDE.md`
- **Troubleshooting**: `aws-backend/TROUBLESHOOTING.md`
- **CloudWatch Logs**: AWS Console → CloudWatch → Log groups

## What's Different from Firebase?

| Feature | Firebase | AWS |
|---------|----------|-----|
| Database | Firestore | DynamoDB |
| Storage | Firebase Storage | S3 |
| Auth | Firebase Auth | Cognito |
| Functions | Cloud Functions | Lambda |
| API | Firebase SDK | REST API (API Gateway) |

## Next Features to Add

1. **User profiles** - Store in DynamoDB Users table
2. **Favorites** - Add favorites list to user profile
3. **Reviews** - Create Reviews table
4. **Real-time updates** - Use DynamoDB Streams + WebSockets
5. **Push notifications** - Use SNS
6. **Analytics** - Use CloudWatch Insights

---

**Your backend is live and ready to use!** 🚀

Test it out and let me know if you hit any issues.
