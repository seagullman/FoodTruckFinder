#!/bin/bash

# Test API endpoints
# Usage: ./test-api.sh [api-endpoint]

set -e

API_ENDPOINT=${1:-"https://your-api-id.execute-api.us-east-1.amazonaws.com/dev"}

echo "🧪 Testing FoodTruckFinder API"
echo "API Endpoint: $API_ENDPOINT"
echo ""

# Test 1: Get food trucks
echo "Test 1: GET /foodtrucks (with location)"
echo "----------------------------------------"
curl -s "${API_ENDPOINT}/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=10" | jq '.'
echo ""
echo ""

# Test 2: Get food truck by ID (you'll need to replace with actual ID)
echo "Test 2: GET /foodtrucks/{id}"
echo "----------------------------------------"
echo "⚠️  Replace {id} with actual food truck ID from Test 1"
# curl -s "${API_ENDPOINT}/foodtrucks/{id}" | jq '.'
echo ""
echo ""

# Test 3: Create food truck (requires authentication)
echo "Test 3: POST /foodtrucks (requires auth)"
echo "----------------------------------------"
echo "⚠️  This requires a valid Cognito token"
echo "Example:"
echo 'curl -X POST "${API_ENDPOINT}/foodtrucks" \'
echo '  -H "Authorization: Bearer YOUR_TOKEN" \'
echo '  -H "Content-Type: application/json" \'
echo '  -d @- << EOF
{
  "name": "Test Truck",
  "description": "A test food truck",
  "cuisineType": "american",
  "location": {
    "description": "123 Test St",
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "websiteUrl": "https://test.com",
  "menu": []
}
EOF'
echo ""
echo ""

# Test 4: Health check
echo "Test 4: API Gateway Health"
echo "----------------------------------------"
if curl -s -o /dev/null -w "%{http_code}" "${API_ENDPOINT}/foodtrucks?latitude=37.7749&longitude=-122.4194&distance=1" | grep -q "200"; then
    echo "✅ API is healthy"
else
    echo "❌ API returned non-200 status"
fi
echo ""

echo "✅ Testing complete!"
