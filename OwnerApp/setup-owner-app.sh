#!/bin/bash

echo "🚀 Setting up Food Truck Owner App..."
echo ""

# This script creates all necessary files for the owner app
# Run from project root: ./OwnerApp/setup-owner-app.sh

PROJECT_DIR="OwnerApp/FoodTruckOwnerApp"

echo "📁 Creating directory structure..."
mkdir -p "$PROJECT_DIR/Authentication"
mkdir -p "$PROJECT_DIR/Views"
mkdir -p "$PROJECT_DIR/Store"
mkdir -p "$PROJECT_DIR/Networking"
mkdir -p "$PROJECT_DIR/Models"
mkdir -p "$PROJECT_DIR/Utility"

echo "📋 Copying shared models..."
cp CustomerApp/FoodTruckFinder/Model/*.swift "$PROJECT_DIR/Models/" 2>/dev/null || echo "⚠️  Models already exist or not found"

echo "🔧 Copying utilities..."
cp CustomerApp/FoodTruckFinder/Utility/LocationManager.swift "$PROJECT_DIR/Utility/" 2>/dev/null || echo "⚠️  LocationManager already exists or not found"

echo "⚙️  Copying Amplify configuration..."
cp amplifyconfiguration.json OwnerApp/ 2>/dev/null || echo "⚠️  Config already exists or not found"

echo ""
echo "✅ Directory structure created!"
echo ""
echo "📝 Next steps:"
echo "1. Open FoodTruckApps.xcworkspace in Xcode"
echo "2. Add all files from $PROJECT_DIR to the Xcode project"
echo "3. Add Amplify Swift package dependency"
echo "4. Build and run!"
echo ""
echo "💡 Or tell Kiro: 'Create all the owner app implementation files'"
