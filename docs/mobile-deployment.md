# Mobile deployment implementation

User request: prepare the frontend for GitHub and deployment, showing the mobile app rather than a desktop website.

Implementation: retain the Phase 5 mobile layout at every viewport width, capped at 430px on desktop and full width on phones. Keep normal mouse behavior; the cursor graphic reported by the user is absent from the application's source and DOM. Add a relative-path web manifest with standalone mode, portrait preference, PNG and maskable icons, Apple home-screen metadata, and scoped offline caching. Offer installation from Profile with browser-native prompting when supported and platform instructions otherwise.

Deployment: dependency-free Node build copies an explicit app file allowlist and assets into dist. GitHub Actions tests and packages the static frontend, then deploys to Pages. App shell, manifest and worker resolve paths under arbitrary repository subpaths. Build output excludes supplied reference images and development files.

Validation: Node tests cover actual PNG dimensions, standalone manifest scope, complete production assets, and simulated offline navigation/module loading and cache isolation. No GitHub remote is configured; preparation does not imply a completed remote push, successful hosted deployment, or tested phone installation.
