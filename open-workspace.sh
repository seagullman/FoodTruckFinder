#!/bin/bash

# Open FoodTruckApps workspace
# This ensures you're always working in the workspace, not individual projects

echo "🚀 Opening FoodTruckApps Workspace..."
echo ""
echo "This workspace contains:"
echo "  📱 Customer App (FoodTruckFinder)"
echo "  👨‍💼 Owner App (FoodTruckOwnerApp)"
echo "  ☁️  AWS Backend"
echo ""

if [ -d "FoodTruckApps.xcworkspace" ]; then
    open FoodTruckApps.xcworkspace
    echo "✅ Workspace opened!"
    echo ""
    echo "💡 Tip: Use the scheme dropdown to switch between apps"
else
    echo "❌ Workspace not found!"
    echo "Run this script from the project root directory"
    exit 1
fi
