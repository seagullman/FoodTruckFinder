#!/bin/bash

# Script to create a food truck owner account in Cognito

REGION="us-east-1"
USER_POOL_ID="us-east-1_2ZDCxmA6m"
CLIENT_ID="4ji0p0q4ln4j22idg3ehiaa00s"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🍔 Food Truck Owner Account Creator${NC}\n"

# Get user input
read -p "Enter email address: " EMAIL
read -sp "Enter password (min 8 characters): " PASSWORD
echo ""
read -p "Enter owner name: " NAME

echo -e "\n${YELLOW}Creating account...${NC}"

# Create user
aws cognito-idp sign-up \
  --region $REGION \
  --client-id $CLIENT_ID \
  --username "$EMAIL" \
  --password "$PASSWORD" \
  --user-attributes Name=email,Value="$EMAIL" Name=name,Value="$NAME" \
  2>&1

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Account created successfully!${NC}"
  
  # Auto-confirm the user (for development)
  echo -e "\n${YELLOW}Auto-confirming user for development...${NC}"
  aws cognito-idp admin-confirm-sign-up \
    --region $REGION \
    --user-pool-id $USER_POOL_ID \
    --username "$EMAIL"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ User confirmed!${NC}"
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}You can now login with:${NC}"
    echo -e "  Email: ${YELLOW}$EMAIL${NC}"
    echo -e "  Password: ${YELLOW}[the password you entered]${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  else
    echo -e "${RED}❌ Failed to confirm user${NC}"
    echo -e "${YELLOW}You may need to verify your email manually${NC}"
  fi
else
  echo -e "${RED}❌ Failed to create account${NC}"
  echo -e "${YELLOW}Check if the email already exists or password requirements${NC}"
fi
