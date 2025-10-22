#!/bin/bash

# FoodTruckFinder Backend Deployment Script
# Usage: ./deploy.sh [dev|staging|prod]

set -e

ENVIRONMENT=${1:-dev}

echo "🚀 Deploying FoodTruckFinder Backend to $ENVIRONMENT environment..."

# Check if AWS SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo "❌ AWS SAM CLI is not installed. Please install it first:"
    echo "   brew install aws-sam-cli"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure'"
    exit 1
fi

# Build the application
echo "📦 Building Lambda functions..."
sam build

# Deploy the application
echo "🚢 Deploying to AWS..."
sam deploy --config-env $ENVIRONMENT

# Get outputs
echo "✅ Deployment complete!"
echo ""
echo "📋 Stack Outputs:"
aws cloudformation describe-stacks \
    --stack-name foodtruckfinder-backend-$ENVIRONMENT \
    --query 'Stacks[0].Outputs' \
    --output table

echo ""
echo "🎉 Backend is ready! Update your iOS app with the new API endpoint."
