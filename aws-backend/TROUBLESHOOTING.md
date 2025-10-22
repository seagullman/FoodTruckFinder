# Troubleshooting Guide

Common issues and solutions when deploying the FoodTruckFinder AWS backend.

## Build Issues

### Python Version Mismatch

**Error:**
```
Binary validation failed for python, searched for python in following locations
which did not satisfy constraints for runtime: python3.11
```

**Solution:**
Install Python 3.12 (the Lambda runtime version):
```bash
brew install python@3.12
python3.12 --version  # Verify installation
```

The template uses `python3.12` runtime. If you need a different version, update `template.yaml`:
```yaml
Globals:
  Function:
    Runtime: python3.12  # Change this
```

### SAM CLI Not Found

**Error:**
```
sam: command not found
```

**Solution:**
```bash
brew install aws-sam-cli
sam --version
```

### AWS CLI Not Configured

**Error:**
```
Unable to locate credentials
```

**Solution:**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your Secret Access Key
# Enter region: us-east-1
# Enter output format: json
```

Verify:
```bash
aws sts get-caller-identity
```

## Deployment Issues

### Stack Already Exists

**Error:**
```
Stack [foodtruckfinder-backend-dev] already exists
```

**Solution:**
Delete the existing stack:
```bash
aws cloudformation delete-stack --stack-name foodtruckfinder-backend-dev

# Wait for deletion to complete
aws cloudformation wait stack-delete-complete --stack-name foodtruckfinder-backend-dev

# Then redeploy
./deploy.sh dev
```

### S3 Bucket Already Exists

**Error:**
```
Bucket already exists
```

**Solution:**
The bucket name must be globally unique. Update `template.yaml`:
```yaml
ImagesBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub 'foodtruckfinder-images-${Environment}-${AWS::AccountId}-unique'
```

### Insufficient Permissions

**Error:**
```
User is not authorized to perform: cloudformation:CreateStack
```

**Solution:**
Your AWS user needs these permissions:
- CloudFormation (full access)
- Lambda (full access)
- DynamoDB (full access)
- S3 (full access)
- API Gateway (full access)
- Cognito (full access)
- IAM (create/attach roles)

Ask your AWS admin to attach the `PowerUserAccess` policy.

### Lambda Function Size Too Large

**Error:**
```
Unzipped size must be smaller than 262144000 bytes
```

**Solution:**
Remove unnecessary dependencies from `requirements.txt` or use Lambda Layers.

## Runtime Issues

### API Returns 502 Bad Gateway

**Cause:** Lambda function error

**Solution:**
Check CloudWatch logs:
```bash
sam logs -n GetFoodTrucksFunction --stack-name foodtruckfinder-backend-dev --tail
```

Common causes:
- Missing environment variables
- DynamoDB table doesn't exist
- Python syntax errors
- Missing dependencies

### API Returns 403 Forbidden

**Cause:** Authentication/authorization issue

**Solution:**

For public endpoints (GET /foodtrucks):
- Check API Gateway configuration
- Verify `Auth: Authorizer: NONE` in template

For protected endpoints:
- Verify Cognito token is valid
- Check Authorization header format: `Bearer {token}`
- Verify Cognito User Pool ID matches

Test token:
```bash
# Get token from iOS app or Cognito
TOKEN="your-token-here"

curl -H "Authorization: Bearer $TOKEN" \
  https://your-api.execute-api.us-east-1.amazonaws.com/dev/foodtrucks
```

### API Returns 404 Not Found

**Cause:** Endpoint doesn't exist or API not deployed

**Solution:**
```bash
# Check API exists
aws apigateway get-rest-apis

# Check deployment
aws apigateway get-deployments --rest-api-id YOUR_API_ID

# Redeploy if needed
sam deploy --stack-name foodtruckfinder-backend-dev
```

### No Food Trucks Returned

**Cause:** DynamoDB table is empty

**Solution:**
Seed data:
```bash
cd scripts
python3 seed-data.py dev
```

Verify:
```bash
aws dynamodb scan --table-name FoodTrucks-dev --max-items 5
```

### Distance Calculation Wrong

**Cause:** Latitude/longitude in wrong format

**Solution:**
Ensure coordinates are:
- Latitude: -90 to 90
- Longitude: -180 to 180
- Stored as Decimal in DynamoDB
- Passed as float in API

### Images Not Loading

**Cause:** S3 bucket permissions or CORS

**Solution:**

Check bucket policy:
```bash
aws s3api get-bucket-policy --bucket foodtruckfinder-images-dev-{account-id}
```

Check CORS:
```bash
aws s3api get-bucket-cors --bucket foodtruckfinder-images-dev-{account-id}
```

Fix CORS:
```bash
aws s3api put-bucket-cors --bucket foodtruckfinder-images-dev-{account-id} --cors-configuration file://cors.json
```

cors.json:
```json
{
  "CORSRules": [
    {
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST"],
      "AllowedOrigins": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

## iOS Integration Issues

### Amplify Configuration Error

**Error:**
```
Failed to configure Amplify
```

**Solution:**
- Verify `amplifyconfiguration.json` is in project root
- Check User Pool ID and Client ID are correct
- Ensure file is added to Xcode target

### Authentication Fails

**Error:**
```
User is not authenticated
```

**Solution:**

Check Cognito user exists:
```bash
aws cognito-idp list-users --user-pool-id YOUR_POOL_ID
```

Verify email is confirmed:
```bash
aws cognito-idp admin-get-user \
  --user-pool-id YOUR_POOL_ID \
  --username user@example.com
```

Manually confirm user:
```bash
aws cognito-idp admin-confirm-sign-up \
  --user-pool-id YOUR_POOL_ID \
  --username user@example.com
```

### Network Request Fails

**Error:**
```
The request timed out
```

**Solution:**
- Check API endpoint URL is correct
- Verify internet connection
- Check API Gateway is deployed
- Test with curl first

### Image Upload Fails

**Error:**
```
Failed to upload image
```

**Solution:**

Check presigned URL generation:
```bash
# Get token from Cognito
TOKEN="your-token"

curl -X POST https://your-api.execute-api.us-east-1.amazonaws.com/dev/upload-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fileName":"test.jpg","contentType":"image/jpeg"}'
```

Verify S3 permissions:
```bash
aws s3api get-bucket-acl --bucket foodtruckfinder-images-dev-{account-id}
```

## Data Migration Issues

### Firebase Export Fails

**Error:**
```
Permission denied
```

**Solution:**
- Download service account key from Firebase Console
- Place in `scripts/serviceAccountKey.json`
- Verify Firebase project ID

### DynamoDB Import Fails

**Error:**
```
ValidationException: One or more parameter values were invalid
```

**Solution:**
- Check data types (use Decimal for numbers)
- Verify required fields exist
- Check item size < 400KB

### Geohash Calculation Wrong

**Cause:** Precision or formula issue

**Solution:**
For production, use a proper geohashing library:
```bash
pip install pygeohash
```

Update import script:
```python
import pygeohash as pgh

geohash = pgh.encode(latitude, longitude, precision=5)
```

## Performance Issues

### Lambda Cold Starts

**Symptom:** First request is slow

**Solution:**
- Increase memory (faster CPU)
- Use provisioned concurrency (costs more)
- Keep functions warm with CloudWatch Events

### DynamoDB Throttling

**Error:**
```
ProvisionedThroughputExceededException
```

**Solution:**
- Already using on-demand billing
- Check for hot partitions
- Implement exponential backoff

### API Gateway Timeout

**Error:**
```
Endpoint request timed out
```

**Solution:**
- Increase Lambda timeout (max 30s for API Gateway)
- Optimize Lambda code
- Use async processing for long operations

## Monitoring & Debugging

### View Lambda Logs

```bash
# Tail logs
sam logs -n GetFoodTrucksFunction --stack-name foodtruckfinder-backend-dev --tail

# View specific time range
aws logs filter-log-events \
  --log-group-name /aws/lambda/GetFoodTrucks-dev \
  --start-time $(date -u -d '1 hour ago' +%s)000
```

### Check API Gateway Metrics

```bash
# Get API ID
aws apigateway get-rest-apis

# View metrics in CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiName,Value=FoodTruckFinderAPI-dev \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

### Check DynamoDB Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=FoodTrucks-dev \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

### Enable X-Ray Tracing

Update `template.yaml`:
```yaml
Globals:
  Function:
    Tracing: Active
```

Redeploy and view traces in AWS X-Ray console.

## Getting Help

1. **Check CloudWatch Logs** - Most issues show up here
2. **Test with curl** - Isolate iOS vs backend issues
3. **Check AWS Console** - Verify resources exist
4. **Review IAM Permissions** - Many issues are permission-related
5. **Check AWS Service Health** - https://status.aws.amazon.com/

## Useful Commands

```bash
# Check all resources
aws cloudformation describe-stack-resources \
  --stack-name foodtruckfinder-backend-dev

# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name foodtruckfinder-backend-dev \
  --query 'Stacks[0].Outputs'

# Delete everything
aws cloudformation delete-stack --stack-name foodtruckfinder-backend-dev

# Validate template
sam validate

# Test locally
sam local start-api

# Deploy with debug
sam deploy --debug
```
