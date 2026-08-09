# Remove Native Splash Screen (Keep Flutter Splash)

## Goal
Remove the native Android and iOS launch splash screens so the app shows **nothing** while Flutter initializes, then immediately presents the existing animated Flutter `SplashScreen` widget (`lib/features/auth/presentation/screens/splash_screen.dart`).

## Constraints
- Do **not** touch `lib/features/auth/presentation/screens/splash_screen.dart`.
- Do **not** touch router config (`lib/app/router/app_router.dart`).
- The `flutter_native_splash` block in `pubspec.yaml` can remain; it is not actively generating assets.

## Changes

### Android
1. **`android/app/src/main/res/values/styles.xml`**
   - In `LaunchTheme`, remove the `<item name="android:windowBackground">@drawable/launch_background</item>` line.
   - Keep all other items in `LaunchTheme` (`forceDarkAllowed`, `windowFullscreen`, etc.).
2. **`android/app/src/main/res/drawable/launch_background.xml`**
   - Replace contents with an empty `<layer-list>` (or delete the `@drawable/background` item so it does nothing).

### iOS
1. **`ios/Runner/Assets.xcassets/LaunchImage.imageset/`**
   - Delete `LaunchImage.png`, `LaunchImage@2x.png`, `LaunchImage@3x.png`.
   - Delete `Contents.json`.
   - Remove the entire `LaunchImage.imageset` folder.
2. **`ios/Runner/Info.plist`**
   - Remove `<key>UILaunchStoryboardName</key>` / `<string>LaunchScreen</string>`.
   - Optionally keep `UILaunchStoryboardName` pointing to an empty `LaunchScreen` storyboard, but removing the key is cleaner.

## Validation
1. Run `flutter clean && flutter pub get`.
2. Run the app on Android — expect blank/black background during native launch, then the Flutter animated splash appears.
3. Run the app on iOS — expect blank/black background during native launch, then the Flutter animated splash appears.
4. Verify no references to `@drawable/launch_background` or `LaunchImage` remain in Android/iOS native configs.
