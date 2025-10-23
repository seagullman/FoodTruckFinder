#!/bin/bash

# Script to link an owner (Cognito user) to a food truck

REGION="us-east-1"
USER_POOL_ID="us-east-1_2ZDCxmA6m"
TABLE_NAME="FoodTrucks-dev"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔗 Link Owner to Food Truck${NC}\n"

# Get user email
read -p "Enter owner email: " EMAIL

# Get user ID from Cognito
echo -e "\n${YELLOW}Looking up user...${NC}"
USER_INFO=$(aws cognito-idp admin-get-user \
  --region $REGION \
  --user-pool-id $USER_POOL_ID \
  --username "$EMAIL" \
  2>&1)

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ User not found${NC}"
  exit 1
fi

USER_ID=$(echo "$USER_INFO" | grep -A 1 '"Name": "sub"' | grep "Value" | cut -d'"' -f4)

if [ -z "$USER_ID" ]; then
  echo -e "${RED}❌ Could not extract user ID${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Found user: $USER_ID${NC}"

# List existing food trucks
echo -e "\n${YELLOW}Existing food trucks:${NC}"
aws dynamodb scan \
  --region $REGION \
  --table-name $TABLE_NAME \
  --projection-expression "id, #n, ownerId" \
  --expression-attribute-names '{"#n":"name"}' \
  --output table

# Get truck ID
echo ""
read -p "Enter food truck ID to link: " TRUCK_ID

# Update the food truck with ownerId
echo -e "\n${YELLOW}Linking owner to truck...${NC}"
aws dynamodb update-item \
  --region $REGION \
  --table-name $TABLE_NAME \
  --key "{\"id\": {\"S\": \"$TRUCK_ID\"}}" \
  --update-expression "SET ownerId = :ownerId" \
  --expression-attribute-values "{\":ownerId\": {\"S\": \"$USER_ID\"}}" \
  2>&1

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Successfully linked!${NC}"
  echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}Owner: ${YELLOW}$EMAIL${NC}"
  echo -e "${GREEN}User ID: ${YELLOW}$USER_ID${NC}"
  echo -e "${GREEN}Truck ID: ${YELLOW}$TRUCK_ID${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
  echo -e "${RED}❌ Failed to link owner to truck${NC}"
  exit 1
fi
