# FoodTruckFinder AWS Backend

Complete AWS serverless backend for the FoodTruckFinder iOS application.

## Architecture

- **API Gateway**: REST API endpoints
- **Lambda Functions**: Business logic (Python 3.11)
- **DynamoDB**: NoSQL database for food trucks and users
- **S3**: Image storage with presigned URLs
- **Cognito**: User authentication and authorization

## Prerequisites

1. **AWS CLI**: Install and configure
   ```bash
   brew install awscli
   aws configure
   ```

2. **AWS SAM CLI**: For deployment
   ```bash
   brew install aws-sam-cli
   ```

3. **Python 3.11**: For Lambda functions
   ```bash
   brew install python@3.11
   ```

## Project Structure

```
aws-backend/
├── template.yaml              # CloudFormation/SAM template
├── samconfig.toml            # SAM deployment configuration
├── deploy.sh                 # Deployment script
└── lambda/
    ├── get_food_trucks/      # GET /foodtrucks
    ├── get_food_truck_by_id/ # GET /foodtrucks/{id}
    ├── create_food_truck/    # POST /foodtrucks
    ├── update_food_truck/    # PUT /foodtrucks/{id}
    ├── delete_food_truck/    # DELETE /foodtrucks/{id}
    └── get_presigned_url/    # POST /upload-url
```

## API Endpoints

### Public Endpoints (No Auth Required)

#### GET /foodtrucks
Get food trucks within a distance
```
Query Parameters:
- latitude: User's latitude
- longitude: User's longitude
- distance: Max distance in miles (default: 10)

Response: Array of FoodTruckListItem
```

#### GET /foodtrucks/{id}
Get detailed food truck information
```
Response: FoodTruck object with full details
```

### Protected Endpoints (Auth Required)

#### POST /foodtrucks
Create a new food truck
```
Headers:
- Authorization: Bearer {cognito-token}

Body:
{
  "name": "Taco Truck",
  "description": "Best tacos in town",
  "cuisineType": "mexican",
  "location": {
    "description": "123 Main St",
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "websiteUrl": "https://example.com",
  "imageUrl": "https://...",
  "menu": [...]
}
```

#### PUT /foodtrucks/{id}
Update existing food truck (owner only)

#### DELETE /foodtrucks/{id}
Delete food truck (owner only)

#### POST /upload-url
Get presigned URL for image upload
```
Body:
{
  "fileName": "truck-image.jpg",
  "contentType": "image/jpeg"
}

Response:
{
  "uploadUrl": "https://...",  // Use this to PUT the file
  "imageUrl": "https://...",   // Use this in food truck data
  "key": "food-trucks/..."
}
```

## Deployment

### Quick Deploy
```bash
chmod +x deploy.sh
./deploy.sh dev
```

### Manual Deploy
```bash
# Build
sam build

# Deploy to dev
sam deploy --config-env dev

# Deploy to production
sam deploy --config-env prod
```

### First Time Setup
```bash
# Initialize SAM
sam deploy --guided

# Follow prompts and save configuration
```

## Configuration

Update `samconfig.toml` with your AWS settings:
- S3 bucket for deployment artifacts
- AWS region
- Stack name

## DynamoDB Schema

### FoodTrucks Table
```
Primary Key: id (String)
GSI: geoHash (for location queries)

Attributes:
- id: UUID
- ownerId: Cognito user ID
- name: String
- description: String
- cuisineType: String
- location: Map {description, latitude, longitude}
- imageUrl: String
- websiteUrl: String
- openUntil: String
- menu: List of MenuCategory
- geoHash: String (for indexing)
- createdAt: String
- updatedAt: String
```

### Users Table
```
Primary Key: id (String)
GSI: email

Attributes:
- id: Cognito user ID
- email: String
- name: String
- type: String (customer/owner)
```

## Image Upload Flow

1. iOS app requests presigned URL: `POST /upload-url`
2. Backend returns presigned URL and final image URL
3. iOS app uploads image directly to S3 using presigned URL
4. iOS app includes image URL when creating/updating food truck

## Testing Locally

```bash
# Start local API
sam local start-api

# Test endpoint
curl http://localhost:3000/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10
```

## Monitoring

View logs in CloudWatch:
```bash
sam logs -n GetFoodTrucksFunction --stack-name foodtruckfinder-backend-dev --tail
```

## Cost Optimization

- DynamoDB: Pay-per-request billing
- Lambda: Free tier covers 1M requests/month
- S3: Standard storage with lifecycle policies
- API Gateway: Free tier covers 1M requests/month

## Security

- Cognito handles authentication
- API Gateway validates JWT tokens
- S3 bucket has CORS configured for iOS app
- Lambda functions have minimal IAM permissions
- Presigned URLs expire after 1 hour

## Updating iOS App

After deployment, update your iOS app:

1. Get API endpoint from stack outputs
2. Update `NetworkManager.swift` base URL
3. Configure Cognito in `amplifyconfiguration.json`
4. Update authentication flow to use Cognito

## Troubleshooting

### Lambda Errors
```bash
# View recent logs
sam logs -n FunctionName --stack-name foodtruckfinder-backend-dev --tail

# Check CloudWatch Logs
aws logs tail /aws/lambda/FunctionName --follow
```

### DynamoDB Issues
```bash
# Scan table
aws dynamodb scan --table-name FoodTrucks-dev

# Get item
aws dynamodb get-item --table-name FoodTrucks-dev --key '{"id":{"S":"uuid"}}'
```

### API Gateway
```bash
# Test endpoint
aws apigateway test-invoke-method \
  --rest-api-id {api-id} \
  --resource-id {resource-id} \
  --http-method GET
```

## Migration from Firebase

See `MIGRATION.md` for step-by-step guide to migrate data from Firebase to AWS.

## Support

For issues or questions, check:
- AWS SAM Documentation: https://docs.aws.amazon.com/serverless-application-model/
- AWS Lambda: https://docs.aws.amazon.com/lambda/
- DynamoDB: https://docs.aws.amazon.com/dynamodb/
