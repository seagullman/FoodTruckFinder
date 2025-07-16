# Project Structure

## Root Level
- `FoodTruckFinder.xcodeproj/` - Xcode project configuration
- `FoodTruckFinder/` - Main application source code
- `FoodTruckFinderTests/` - Unit tests
- `FoodTruckFinderUITests/` - UI automation tests
- `amplifyconfiguration.json` - AWS Amplify configuration
- `GoogleService-Info.plist` - Firebase configuration (referenced in project)

## Main Application Structure (`FoodTruckFinder/`)

### Core Files
- `FoodTruckFinderApp.swift` - App entry point and configuration
- `Info.plist` - iOS app configuration and permissions

### Organized by Feature/Layer

#### `/Model` - Data Models
- Core business objects (FoodTruck, User, Menu, etc.)
- Codable structs for API responses
- Navigation and location services

#### `/Screens` - Main UI Views
- Full-screen views representing app screens
- Authentication flows (Login, Registration, etc.)
- Main feature screens (Map, List, Detail views)

#### `/Custom Views` - Reusable UI Components
- Modular SwiftUI views used across screens
- Input components, cells, headers, toolbars
- Navigation and menu components

#### `/ViewModel` - Business Logic Layer
- Observable classes managing app state
- View-specific logic and data transformation
- Authentication and data stores

#### `/Store` - Data Management
- Centralized data stores (FoodTruckStore)
- State management for app-wide data

#### `/Utility` - Helper Classes & Extensions
- Network management and API clients
- Location services and map helpers
- Authentication managers
- Extensions and utility functions
- Error handling components

#### `/Assets.xcassets` - Visual Resources
- App icons, images, and color assets
- Organized in asset catalog format

## Naming Conventions
- **Files**: PascalCase with descriptive names
- **Views**: Suffix with "View" (e.g., `FoodTruckListView`)
- **Models**: Plain nouns (e.g., `FoodTruck`, `User`)
- **Stores**: Suffix with "Store" (e.g., `FoodTruckStore`)
- **Managers**: Suffix with "Manager" (e.g., `NetworkManager`)
- **Extensions**: Prefix with type name (e.g., `FTF+Double.swift`)

## Code Organization Principles
- Group related functionality in dedicated folders
- Separate UI components from business logic
- Keep reusable components in Custom Views
- Centralize utilities and helpers
- Follow SwiftUI and iOS development best practices