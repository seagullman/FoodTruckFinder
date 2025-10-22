# Quick Start Guide

Get your AWS backend up and running in 15 minutes.

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- AWS SAM CLI installed
- Python 3.11+

## Step 1: Install Tools (5 minutes)

```bash
# Install AWS CLI
brew install awscli

# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (us-east-1)

# Install AWS SAM CLI
brew install aws-sam-cli

# Verify installations
aws --version
sam --version
```

## Step 2: Deploy Backend (5 minutes)

```bash
cd aws-backend

# Make deploy script executable
chmod +x deploy.sh

# Deploy to dev environment
./deploy.sh dev
```

This will:
- Build all Lambda functions
- Create DynamoDB tables
- Create S3 bucket
- Set up API Gateway
- Configure Cognito User Pool

**Save the outputs!** You'll need:
- API Endpoint URL
- User Pool ID
- User Pool Client ID

## Step 3: Seed Test Data (2 minutes)

```bash
cd scripts

# Add sample food trucks
python3 seed-data.py dev

# Verify data was added
aws dynamodb scan --table-name FoodTrucks-dev --max-items 5
```

## Step 4: Test API (2 minutes)

```bash
# Make test script executable
chmod +x test-api.sh

# Test endpoints (replace with your API endpoint)
./test-api.sh https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev
```

You should see JSON responses with food truck data.

## Step 5: Update iOS App (1 minute)

1. Copy `ios-integration/amplifyconfiguration.json` to your Xcode project
2. Update with your User Pool ID and Client ID
3. Copy `ios-integration/AWSNetworkManager.swift` to your project
4. Update the base URL with your API endpoint

## Verify Everything Works

### Test 1: API Returns Data
```bash
curl "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/dev/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10"
```

Should return array of food trucks.

### Test 2: DynamoDB Has Data
```bash
aws dynamodb scan --table-name FoodTrucks-dev --select COUNT
```

Should show 5 items (from seed data).

### Test 3: S3 Bucket Exists
```bash
aws s3 ls | grep foodtruckfinder-images
```

Should show your images bucket.

### Test 4: Cognito User Pool Exists
```bash
aws cognito-idp list-user-pools --max-results 10
```

Should show FoodTruckFinder user pool.

## Next Steps

1. **Read the full README**: `aws-backend/README.md`
2. **iOS Integration**: Follow `ios-integration/INTEGRATION_GUIDE.md`
3. **Migrate Firebase Data**: See `MIGRATION.md`
4. **Monitor**: Check CloudWatch logs and metrics

## Common Issues

### Issue: "Stack already exists"
**Solution**: Delete the stack first
```bash
aws cloudformation delete-stack --stack-name foodtruckfinder-backend-dev
```

### Issue: "Access Denied"
**Solution**: Check AWS credentials
```bash
aws sts get-caller-identity
```

### Issue: "No module named boto3"
**Solution**: Install Python dependencies
```bash
pip3 install boto3
```

### Issue: API returns 403
**Solution**: Check API Gateway deployment
```bash
aws apigateway get-rest-apis
```

## Architecture Overview

```
┌─────────────┐
│   iOS App   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  API Gateway    │ ← REST API
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐ ┌────────┐
│Lambda  │ │Lambda  │ ← Business Logic
└───┬────┘ └───┬────┘
    │          │
    ▼          ▼
┌──────────────────┐
│    DynamoDB      │ ← Food Truck Data
└──────────────────┘

┌──────────────────┐
│       S3         │ ← Images
└──────────────────┘

┌──────────────────┐
│    Cognito       │ ← Authentication
└──────────────────┘
```

## Cost Estimate

For development/testing with low traffic:

- **DynamoDB**: ~$1-2/month (pay-per-request)
- **Lambda**: Free tier (1M requests/month)
- **API Gateway**: Free tier (1M requests/month)
- **S3**: ~$0.50/month (for images)
- **Cognito**: Free tier (50,000 MAUs)

**Total**: ~$2-3/month for dev environment

## Support

- **AWS Documentation**: https://docs.aws.amazon.com/
- **SAM Documentation**: https://docs.aws.amazon.com/serverless-application-model/
- **Amplify iOS**: https://docs.amplify.aws/lib/q/platform/ios/

## Cleanup

To delete everything and stop charges:

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name foodtruckfinder-backend-dev

# Delete S3 bucket (must be empty first)
aws s3 rm s3://foodtruckfinder-images-dev-{account-id} --recursive
aws s3 rb s3://foodtruckfinder-images-dev-{account-id}
```

---

**You're all set!** 🎉

Your AWS backend is now running and ready to integrate with your iOS app.
