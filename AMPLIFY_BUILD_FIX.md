# Fix: Amplify Build Error

## Error
```
Cannot find '__IPHONE_OS_VERSION_MIN_REQUIRED' in scope
```

This is a known compatibility issue with Amplify Swift and certain Xcode/iOS versions.

## Solution 1: Update Amplify (Recommended)

1. In Xcode, go to **File → Packages → Update to Latest Package Versions**
2. This will update Amplify to the latest version which has better compatibility
3. Clean build folder: **Cmd+Shift+K**
4. Build: **Cmd+B**

## Solution 2: Specify Amplify Version

If Solution 1 doesn't work:

1. Remove Amplify package:
   - Select your project in Xcode
   - Go to **Package Dependencies** tab
   - Select Amplify and click **-** to remove

2. Re-add with specific version:
   - **File → Add Package Dependencies**
   - URL: `https://github.com/aws-amplify/amplify-swift`
   - **Dependency Rule**: Exact Version → `2.42.0` (or latest stable)
   - Add products: `Amplify`, `AWSCognitoAuthPlugin`

3. Clean and rebuild

## Solution 3: Xcode Build Settings

If the error persists, add this build setting:

1. Select your project in Xcode
2. Select **FoodTruckFinder** target
3. Go to **Build Settings** tab
4. Search for "Other Swift Flags"
5. Add: `-Xcc -D__IPHONE_OS_VERSION_MIN_REQUIRED=170000`

This tells the compiler to use iOS 17.0 as the minimum version.

## Solution 4: Use Cocoapods Instead (Alternative)

If SPM continues to have issues, you can use CocoaPods:

1. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```

2. Create Podfile in project root:
   ```ruby
   platform :ios, '17.0'
   use_frameworks!

   target 'FoodTruckFinder' do
     pod 'Amplify'
     pod 'AmplifyPlugins/AWSCognitoAuthPlugin'
   end
   ```

3. Install:
   ```bash
   pod install
   ```

4. Open `FoodTruckFinder.xcworkspace` instead of `.xcodeproj`

## Solution 5: Temporary Workaround (Quick Fix)

If you need to test quickly without Amplify auth:

1. Comment out Amplify imports in `FoodTruckFinderApp.swift`:
   ```swift
   // import Amplify
   // import AWSCognitoAuthPlugin
   ```

2. Comment out Amplify configuration:
   ```swift
   // func configureAmplify() {
   //     do {
   //         try Amplify.add(plugin: AWSCognitoAuthPlugin())
   //         try Amplify.configure()
   //         print("✅ Amplify configured successfully")
   //     } catch {
   //         print("❌ Failed to configure Amplify: \(error)")
   //     }
   // }
   ```

3. Use the public API endpoints (no auth required):
   - GET /foodtrucks
   - GET /foodtrucks/{id}

4. Update `FoodTruckFinderApp.swift` to use NetworkManager temporarily:
   ```swift
   @State private var foodTruckStore = FoodTruckStore(httpClient: NetworkManager.shared)
   ```

5. Update `NetworkManager.swift` to use AWS endpoint:
   ```swift
   private var baseUrlComponents: URLComponents {
       var components = URLComponents()
       components.scheme = "https"
       components.host = "c4yzk7yh86.execute-api.us-east-1.amazonaws.com"
       components.path = "/dev/foodtrucks"
       return components
   }
   ```

This lets you test the AWS backend without authentication while you fix the Amplify issue.

## Verify Fix

After applying any solution:

1. Clean build folder: **Cmd+Shift+K**
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Restart Xcode
4. Build: **Cmd+B**

## Still Having Issues?

Check these:

1. **Xcode version**: Make sure you're on Xcode 15.0 or later
   ```bash
   xcodebuild -version
   ```

2. **iOS deployment target**: Should be 17.0 or later
   - Project settings → Deployment Info → iOS Deployment Target

3. **Swift version**: Should be Swift 5.9 or later
   - Build Settings → Swift Language Version

4. **Clean everything**:
   ```bash
   # Close Xcode first
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf .build
   ```

## Recommended Approach

Try solutions in this order:
1. ✅ Solution 1 (Update packages) - Easiest
2. ✅ Solution 2 (Specific version) - Most reliable
3. ✅ Solution 3 (Build settings) - If 1 & 2 fail
4. ⚠️ Solution 5 (Workaround) - For quick testing only
5. ⚠️ Solution 4 (CocoaPods) - Last resort

## Need Help?

If none of these work, share:
- Xcode version
- macOS version
- Full error message
- Amplify version installed
