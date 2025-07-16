# Technology Stack

## Platform & Framework
- **iOS**: Native iOS application
- **SwiftUI**: Primary UI framework
- **Swift**: Programming language
- **Xcode**: Development environment and build system

## Backend & Cloud Services
- **Firebase**: Primary backend service
  - Firebase Auth: User authentication
  - Firestore: Database for food truck data
  - Firebase Storage: Image and file storage
- **AWS Amplify**: Authentication and backend services
  - AWS Cognito: User pool management
  - Amplify Swift SDK for iOS integration

## Key Dependencies
- **MaterialActivityIndicator**: Loading indicators
- **Authenticator**: AWS Amplify UI components for auth flows

## Architecture Patterns
- **MVVM**: Model-View-ViewModel architecture
- **Observable**: Swift's @Observable macro for state management
- **Environment Objects**: SwiftUI environment for dependency injection
- **Protocol-Oriented**: NetworkClient protocol for network abstraction

## Common Commands

### Building
```bash
# Open project in Xcode
open FoodTruckFinder.xcodeproj

# Build from command line
xcodebuild -project FoodTruckFinder.xcodeproj -scheme FoodTruckFinder build
```

### Testing
```bash
# Run unit tests
xcodebuild test -project FoodTruckFinder.xcodeproj -scheme FoodTruckFinder -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project FoodTruckFinder.xcodeproj -scheme FoodTruckFinder -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FoodTruckFinderUITests
```

### Package Management
- Swift Package Manager is used for dependency management
- Dependencies are resolved automatically by Xcode
- Package.resolved file tracks exact versions