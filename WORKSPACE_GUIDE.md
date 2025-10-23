# FoodTruckApps Workspace

This workspace contains both the customer and owner apps, plus the AWS backend.

## Opening the Workspace

**Always open the workspace, not individual projects:**

```bash
open FoodTruckApps.xcworkspace
```

Or double-click `FoodTruckApps.xcworkspace` in Finder.

## Projects in Workspace

### 1. CustomerApp (FoodTruckFinder)
**Location**: `CustomerApp/FoodTruckFinder.xcodeproj`
**Purpose**: Consumer-facing app for finding food trucks
**Target Users**: Customers looking for food

**Features**:
- Find nearby food trucks on map
- Browse list of trucks
- View menus and details
- Filter by distance and cuisine
- Get directions

### 2. OwnerApp (FoodTruckOwnerApp)
**Location**: `OwnerApp/FoodTruckOwnerApp.xcodeproj`
**Purpose**: Business management app for food truck operators
**Target Users**: Food truck owners

**Features**:
- Check in at locations
- Update menu items
- Manage truck profile
- Upload logo
- View analytics

### 3. Backend (aws-backend)
**Location**: `aws-backend/`
**Purpose**: AWS serverless backend
**Components**: API Gateway, Lambda, DynamoDB, S3, Cognito

## Shared Code

### Option 1: Shared Framework (Recommended)

Create a shared framework for common code:

```
FoodTruckShared/
├── Models/
│   ├── FoodTruck.swift
│   ├── Menu.swift
│   ├── Location.swift
│   └── CuisineType.swift
├── Networking/
│   ├── AWSNetworkManager.swift
│   └── AuthManager.swift
└── Utilities/
    ├── LocationManager.swift
    └── Extensions.swift
```

**To create:**
1. File → New → Target → Framework
2. Name: `FoodTruckShared`
3. Add to both app targets
4. Move shared code to framework

### Option 2: File References (Current)

Keep files in one project, reference from the other:
- Right-click in Xcode
- Add Files to "ProjectName"
- Select files from other project
- Choose "Create folder references"
- Don't copy files

### Option 3: Duplicate Files (Simple)

Keep separate copies in each project:
- Easier to manage
- No dependencies
- Must update both when changing

## Working with Both Apps

### Switching Between Apps

In Xcode toolbar:
1. Click scheme dropdown (next to Run button)
2. Select either:
   - `FoodTruckFinder` (Customer app)
   - `FoodTruckOwnerApp` (Owner app)

### Running Both Apps

You can run both apps simultaneously:
1. Run customer app on iPhone 15 simulator
2. Switch scheme to owner app
3. Run owner app on iPhone 15 Pro simulator
4. Test interaction between apps!

### Building Both Apps

```bash
# Build customer app
xcodebuild -workspace FoodTruckApps.xcworkspace \
  -scheme FoodTruckFinder \
  -configuration Debug \
  build

# Build owner app
xcodebuild -workspace FoodTruckApps.xcworkspace \
  -scheme FoodTruckOwnerApp \
  -configuration Debug \
  build
```

## Kiro Integration

### Working with Kiro

When you open this workspace in Kiro, I can:
- ✅ See both projects
- ✅ Edit files in either app
- ✅ Create shared code
- ✅ Update backend
- ✅ Maintain consistency

### Kiro Commands

```
# Open workspace
open FoodTruckApps.xcworkspace

# List all files
ls -R CustomerApp/FoodTruckFinder/
ls -R OwnerApp/FoodTruckOwnerApp/

# Edit files in either project
# Just reference the path
```

## Development Workflow

### 1. Feature Development

**Adding a feature that affects both apps:**

1. Plan the feature
2. Update backend if needed (aws-backend/)
3. Update shared models
4. Implement in customer app
5. Implement in owner app
6. Test both apps together

### 2. Bug Fixes

**Fixing a bug in shared code:**

1. Identify the issue
2. Fix in one place (shared framework)
3. Both apps automatically get the fix
4. Test both apps

### 3. Backend Updates

**Updating the API:**

1. Update Lambda functions (aws-backend/lambda/)
2. Deploy: `cd aws-backend && sam deploy`
3. Update network managers in both apps
4. Test both apps with new API

## Configuration

### Shared Configuration

Both apps use the same:
- **Cognito User Pool**: `us-east-1_2ZDCxmA6m`
- **API Gateway**: `https://c4yzk7yh86.execute-api.us-east-1.amazonaws.com/dev`
- **S3 Bucket**: `foodtruckfinder-images-dev-867605436045`
- **DynamoDB**: `FoodTrucks-dev`

### App-Specific Configuration

**Customer App**:
- Bundle ID: `com.yourcompany.foodtruckfinder`
- Display Name: "Food Truck Finder"
- Icon: Customer-facing design

**Owner App**:
- Bundle ID: `com.yourcompany.foodtruckowner`
- Display Name: "Food Truck Owner"
- Icon: Business-focused design

## Testing

### Test Scenario: Check-In Flow

1. **Owner App**: 
   - Login as owner
   - Check in at location
   - Set hours

2. **Customer App**:
   - Open app
   - Search nearby
   - Verify truck appears on map
   - Tap truck to see details

### Test Scenario: Menu Update

1. **Owner App**:
   - Update menu items
   - Add new category

2. **Customer App**:
   - View truck details
   - Verify menu updates appear

## Deployment

### Customer App (App Store)

```bash
# Archive
xcodebuild -workspace FoodTruckApps.xcworkspace \
  -scheme FoodTruckFinder \
  -configuration Release \
  archive

# Upload to App Store Connect
# Submit for review
```

### Owner App (TestFlight/App Store)

```bash
# Archive
xcodebuild -workspace FoodTruckApps.xcworkspace \
  -scheme FoodTruckOwnerApp \
  -configuration Release \
  archive

# Upload to App Store Connect
# Distribute to owners
```

## Advantages of Workspace

✅ **Single Window**: Both projects in one Xcode window
✅ **Easy Navigation**: Switch between apps quickly
✅ **Shared Code**: Reference files across projects
✅ **Consistent Build**: Same build settings
✅ **Version Control**: Commit changes to both apps together
✅ **Kiro Integration**: I can see and edit both apps

## Tips

### Organizing Files

Keep this structure:
```
FoodTruckApps.xcworkspace
├── CustomerApp/
│   └── FoodTruckFinder.xcodeproj
├── OwnerApp/
│   └── FoodTruckOwnerApp.xcodeproj
├── aws-backend/
│   ├── lambda/
│   ├── scripts/
│   └── template.yaml
└── Shared/ (optional)
    └── FoodTruckShared.xcodeproj
```

### Git Workflow

```bash
# Commit changes to both apps
git add CustomerApp/ OwnerApp/ aws-backend/
git commit -m "Add check-in feature to both apps"
git push
```

### Xcode Settings

**Derived Data**: Keep separate for each project
- Xcode → Preferences → Locations
- Derived Data: Default location

**Build Settings**: Keep consistent
- Deployment Target: iOS 17.0
- Swift Version: 5.9
- Optimization: Debug/Release

## Troubleshooting

### "Cannot find module"

If one app can't find shared code:
1. Check target membership
2. Verify framework is linked
3. Clean build folder (Cmd+Shift+K)
4. Rebuild

### "Scheme not found"

If schemes are missing:
1. Product → Scheme → Manage Schemes
2. Ensure both schemes are checked "Show"
3. Make schemes shared (check "Shared" box)

### "Workspace is damaged"

If workspace won't open:
1. Close Xcode
2. Delete `FoodTruckApps.xcworkspace/xcuserdata/`
3. Reopen workspace

## Next Steps

1. ✅ Open `FoodTruckApps.xcworkspace`
2. ⬜ Create shared framework (optional)
3. ⬜ Move common code to shared location
4. ⬜ Test both apps together
5. ⬜ Deploy to TestFlight

---

**Always work in the workspace, not individual projects!**
