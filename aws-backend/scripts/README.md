# Backend Scripts

Utility scripts for managing the FoodTruckFinder backend.

## Setup

Install dependencies:

```bash
# Python scripts
pip3 install boto3

# Node.js scripts
npm install firebase-admin
```

## Scripts

### seed-data.py

Seed DynamoDB with sample food truck data for testing.

```bash
python3 seed-data.py dev
```

Creates 5 sample food trucks in San Francisco area.

### test-api.sh

Test API endpoints to verify deployment.

```bash
chmod +x test-api.sh
./test-api.sh https://your-api-id.execute-api.us-east-1.amazonaws.com/dev
```

### export-firebase.js

Export data from Firebase Firestore to JSON files.

**Prerequisites:**
1. Install firebase-admin: `npm install firebase-admin`
2. Download `serviceAccountKey.json` from Firebase Console
3. Place in scripts directory

```bash
node export-firebase.js
```

Outputs:
- `food-trucks-export.json`
- `users-export.json`

### import-dynamodb.py

Import exported Firebase data to DynamoDB.

```bash
python3 import-dynamodb.py dev food-trucks-export.json
```

## Migration Workflow

Complete migration from Firebase to AWS:

```bash
# 1. Export from Firebase
node export-firebase.js

# 2. Import to DynamoDB
python3 import-dynamodb.py dev food-trucks-export.json

# 3. Test API
./test-api.sh https://your-api-id.execute-api.us-east-1.amazonaws.com/dev

# 4. Verify data
aws dynamodb scan --table-name FoodTrucks-dev --max-items 5
```

## AWS CLI Commands

Useful AWS CLI commands for managing the backend:

### DynamoDB

```bash
# List tables
aws dynamodb list-tables

# Scan table
aws dynamodb scan --table-name FoodTrucks-dev

# Get item
aws dynamodb get-item \
  --table-name FoodTrucks-dev \
  --key '{"id":{"S":"your-id"}}'

# Delete item
aws dynamodb delete-item \
  --table-name FoodTrucks-dev \
  --key '{"id":{"S":"your-id"}}'

# Count items
aws dynamodb scan \
  --table-name FoodTrucks-dev \
  --select COUNT
```

### Lambda

```bash
# List functions
aws lambda list-functions

# Invoke function
aws lambda invoke \
  --function-name GetFoodTrucks-dev \
  --payload '{"queryStringParameters":{"latitude":"37.7749","longitude":"-122.4194","distance":"10"}}' \
  response.json

# View logs
aws logs tail /aws/lambda/GetFoodTrucks-dev --follow
```

### S3

```bash
# List buckets
aws s3 ls

# List objects
aws s3 ls s3://foodtruckfinder-images-dev-{account-id}/

# Upload file
aws s3 cp image.jpg s3://foodtruckfinder-images-dev-{account-id}/food-trucks/test/

# Download file
aws s3 cp s3://foodtruckfinder-images-dev-{account-id}/food-trucks/test/image.jpg ./
```

### API Gateway

```bash
# Get APIs
aws apigateway get-rest-apis

# Get resources
aws apigateway get-resources --rest-api-id {api-id}

# Test invoke
aws apigateway test-invoke-method \
  --rest-api-id {api-id} \
  --resource-id {resource-id} \
  --http-method GET \
  --path-with-query-string "/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10"
```

### Cognito

```bash
# List user pools
aws cognito-idp list-user-pools --max-results 10

# List users
aws cognito-idp list-users --user-pool-id {pool-id}

# Create user
aws cognito-idp admin-create-user \
  --user-pool-id {pool-id} \
  --username test@example.com \
  --user-attributes Name=email,Value=test@example.com Name=name,Value="Test User"
```

## Troubleshooting

### Permission Errors

If you get permission errors:

```bash
# Check AWS credentials
aws sts get-caller-identity

# Configure AWS CLI
aws configure
```

### DynamoDB Errors

If items aren't appearing:

```bash
# Check table exists
aws dynamodb describe-table --table-name FoodTrucks-dev

# Check item count
aws dynamodb scan --table-name FoodTrucks-dev --select COUNT
```

### Lambda Errors

If Lambda functions fail:

```bash
# Check function exists
aws lambda get-function --function-name GetFoodTrucks-dev

# View recent errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/GetFoodTrucks-dev \
  --filter-pattern "ERROR"
```
