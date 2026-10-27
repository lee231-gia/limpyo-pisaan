# Limpyo Pisaan Flutter app

The current mobile app is built with **Flutter and Dart**, using native Flutter widgets. It implements the Phase 5 prototype with no WebView, JavaScript UI, backend, or hosted website requirement.

## Source and APK

- Flutter project: `flutter_app/`
- Dart application: `flutter_app/lib/`
- Generated Android APK: `artifacts/Limpyo-Pisaan-Flutter.apk`
- Flutter build output: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

Copy the APK to your Android phone and open it in Files to install. It supports Android 7.0 (API 24) and later, including Android 13. The universal APK includes ARM, ARM64 and x86_64 builds. Application ID: `com.limpyopisaan.mobile`. This is distinct from the earlier Capacitor prototype.

The release-mode prototype is signed with the local Android development key. Play Store publishing and a permanent production signing key are separate tasks. Keep a consistent signing key for future in-place updates.

## Run and build

Install Flutter 3.41.9 or a compatible stable version, Android Studio, JDK 21 and the Android SDK. Then:

```sh
cd flutter_app
flutter pub get
flutter run
```

Verify and build:

```sh
flutter analyze
flutter test
flutter build apk --release
```

From the repository root, `npm run flutter:apk` builds the Flutter app and copies the APK to `artifacts/Limpyo-Pisaan-Flutter.apk`. This helper requires Node.js as well as Flutter. The Flutter project itself does not require Node.js.

## GitHub

Create an empty repository in your GitHub account, then from this project's root run these commands with your actual username and repository name:

```sh
git add .
git commit -m "Add Limpyo Pisaan Flutter mobile app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

If `origin` already exists, use `git remote set-url origin ...` instead. No GitHub remote was supplied during this conversion.

For an APK built by GitHub, open **Actions → Build Flutter Android APK → Run workflow**. After a successful run, download the **Limpyo-Pisaan-Flutter-APK** artifact and unzip `app-release.apk`. GitHub-generated development keys can differ between runs; they are not a permanent production signing setup.

## Included flows

Welcome, login and guest access, registration validation, account help, home, announcement/showcase tabs and details, collection notice/sample schedule/drop-off map, report issue picker, required-field errors, landmark suggestions, camera/gallery photo attachment, review/edit, local submission and unique reference, report filters and history, profile, waste guide, read-state notifications, about, and logout confirmation.

The interface uses native Flutter Material widgets, the green-and-cream Phase 5 palette, labeled bottom navigation, bundled local artwork, scrollable forms, system back navigation and portrait orientation.

## Local demo data

`shared_preferences` stores the sample profile, report list and notification state on the device. `image_picker` and `path_provider` attach and retain optional photos in the app's private documents directory. Passwords are never stored. Sign-in, notifications, status history, maps, collection details and report delivery are demonstrations. No report reaches barangay officials. Use sample data; authentication is simulated. Uninstalling the app removes its local data.

All content and artwork are bundled and can open offline. The native Flutter Android release does not require internet permission or a hosted website.

## Previous prototypes

The earlier HTML/CSS/JavaScript and Capacitor source is preserved in the root and `android/` for reference. The old `npm start`, `npm test` and `npm run capacitor:apk` commands apply to that previous prototype. Use `flutter_app/` and the Flutter commands above for the current app. The manually triggered GitHub Pages workflow remains an optional preview of the earlier web version; it does not run the Flutter Android app.
