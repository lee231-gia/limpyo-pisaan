# Run Limpyo Pisaan from VS Code

1. Open VS Code and choose **File → Open Folder**.
2. Open `C:\Users\Admin\Documents\ChatGPT\HCI - APP - RESPONSIVE - FRONTEND ONLY 2\flutter_app`.
3. Open **Terminal → New Terminal**. The terminal should be inside `flutter_app`.

Run:

```powershell
flutter pub get
flutter emulators
flutter emulators --launch flutter_emulator
```

Wait for the emulator's Android home screen. Then run:

```powershell
flutter devices
flutter run -d emulator-5554
```

If `flutter devices` lists a different emulator ID, use that ID instead of `emulator-5554`. While it runs, press **r** in the terminal for hot reload, **R** for hot restart, or **q** to stop.

## Android phone over USB

Enable Developer options and USB debugging on your Android phone, connect it with a data USB cable, unlock it, and approve the phone's debugging prompt for your computer. Then run:

```powershell
flutter devices
flutter run -d YOUR_PHONE_ID
```

Use the phone ID printed by `flutter devices`. Flutter installs and opens the app directly on the selected device.

## Build an APK

From `flutter_app`:

```powershell
flutter build apk --release
```

The output is `build\app\outputs\flutter-apk\app-release.apk`. The repository-root command `npm run android:apk` also builds the current Flutter app and copies it to `artifacts\Limpyo-Pisaan-Flutter.apk`.

## If Flutter is not recognized

Flutter is installed at `C:\flutter` on this computer. Use the full command, such as `C:\flutter\bin\flutter.bat devices`, or add `C:\flutter\bin` to your user PATH and reopen VS Code.

## Application behavior

The interface uses the finished product wording. Data continues to be stored on the device. The presentation changes do not add a backend, remote authentication, email delivery, live schedules, or official report delivery. Facebook sign-in was removed rather than presenting a local sign-in as Facebook authentication. Account help provides guidance without claiming an email was sent. Earlier seeded reports are filtered out while resident-created reports remain available.
