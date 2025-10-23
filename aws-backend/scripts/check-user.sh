#!/bin/bash

# Script to check if a user exists and their status

REGION="us-east-1"
USER_POOL_ID="us-east-1_2ZDCxmA6m"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Check User Status${NC}\n"

read -p "Enter email address to check: " EMAIL

echo -e "\n${YELLOW}Checking user...${NC}\n"

aws cognito-idp admin-get-user \
  --region $REGION \
  --user-pool-id $USER_POOL_ID \
  --username "$EMAIL" \
  2>&1

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✅ User found${NC}"
else
  echo -e "\n${RED}❌ User not found or error occurred${NC}"
fi
