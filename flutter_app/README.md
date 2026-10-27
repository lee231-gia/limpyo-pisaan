# Limpyo Pisaan

Native Flutter and Dart frontend based on the Phase 5 wireframes. No WebView and no backend.

For exact VS Code terminal commands, see [RUN_IN_VSCODE.md](RUN_IN_VSCODE.md). The current interface uses finished product wording, starts with an empty report list, and retains any reports created by the resident when upgrading from the earlier version.

Run `flutter pub get`, then `flutter run`. Analyze with `flutter analyze`, run tests with `flutter test`, and build with `flutter build apk --release`.

Android ID: `com.limpyopisaan.mobile`. Minimum Android API: 24. The universal release-mode APK uses the development signing key for local prototype installation. Output: `build/app/outputs/flutter-apk/app-release.apk`.

The implementation lives in `lib/`: `state.dart` handles local persistence, `auth.dart` handles welcome and account forms, `shell.dart` owns native navigation and system back behavior, `community.dart` implements updates and collection examples, `reports.dart` implements camera/gallery and reporting, `profile.dart` implements profile and extra screens, and `ui.dart` holds the shared native theme and widgets.

Resident profiles, reports and read state persist locally. Passwords are never saved. Photos are copied into the app's private documents folder. Collection schedules, maps, report statuses and submissions are illustrative; no real reports or emails are sent. Shared household devices do not have real account-level access control. Uninstalling removes local data.

See the repository root README for GitHub APK builds and full setup instructions.

## Community photographs (version 1.2)

All eight supplied community photos are bundled in `assets/community/` for offline use. Showcase retains the Phase 5 tab and story flow, with shared-space observations and a bottle-reuse story. Announcements and Waste Guide use relevant photos. Tap a photo to open its full framing and pinch to zoom; close it to return to the current screen. No photographs are labeled as completed cleanup results or before/after pairs. The photos do not create resident reports or designate dumping sites as collection points.

Original filename mapping is recorded in `../docs/community-photo-sources.json`. Bundled JPEGs have a maximum width of 1600px with metadata removed; original files are untouched. `lib/community_photos.dart` defines their descriptions and shared viewer.

## Showcase and custom issues (version 1.3)

In Updates → Showcase, tap **Add showcase**. Enter a title and story, optionally choose a gallery/camera photo, then **Save showcase**. New entries appear first and open into a story detail screen. Stories and durable photo copies remain on the device across restarts; they are not broadcast to other residents. No backend is required.

In Report an Issue, choose **Other waste-related concern** and enter **Specify issue**. The custom name is required, appears in review, and is retained in My Reports. Existing predefined issues continue to work.

The eight supplied Bisaya-English posts appear in Showcase (three stories) and Announcements (education, drainage and cleanliness). All supplied community photographs remain bundled offline. Android photo recovery tracks its originating form so showcase photos cannot attach to reports after a process restart.
