# Kids Games

Premium playful 3D educational game app for children from Nursery through Grade 5.

## Product direction

- Flutter/Dart, Android only
- Android application ID: `com.dev.kidsgames`
- Offline-first; no mandatory account
- Flutter Scene for genuine real-time 3D (GLB/glTF, PBR, camera and skeletal animation)
- Flame for separate 2D mini-games
- Blender source files and optimized GLB exports for production character/environment assets
- VelocityX VxStore/VxState, GoRouter and Hive CE as the required state/navigation/storage architecture
- No Riverpod, Provider, GetX or BLoC
- No BrightBuddies branding or artwork

## Compatibility baseline

The GitHub Actions runner is pinned to Flutter stable 3.47.9 / Dart 3.13.7. Flutter Scene 0.24.3 requires Flutter 3.47 stable or newer. Native rendering uses Flutter GPU, which must be enabled in the Android manifest for shipped builds.

## Current implementation status

Existing useful foundation:
- Child onboarding and grade selection
- Local child profile persistence through SharedPreferencesAsync
- Five-tab Home/Learn/Games/Create/Rewards shell
- VxStore/VxState holds the selected home tab
- GoRouter handles onboarding/home and the Shape Matching route
- 15-item educational activity catalogue
- One playable five-round Shape Matching activity

Declared foundation dependencies:
- Flame and Flame Audio
- Flutter Scene 0.24.3 (pinned for initial integration)
- VelocityX, GoRouter and Flutter animation packages
- Hive CE, SharedPreferences and path_provider
- vector_math, build_runner, Hive CE generator and mocktail

Not yet implemented:
- Flutter Scene runtime prototype, asset build hook and actual GLB loading
- Flame game foundation
- Hive CE repositories/adapters and profile migration
- Generated Android project in the repository
- Blender source assets and production GLB exports
- Animal World, Number Adventure, Alphabet World, Color Match and Puzzle World
- Parent gate/dashboard, rewards persistence and production progress tracking

Do not treat the SVG buddies/island as 3D models. They are only vector illustrations.

## Setup on macOS

Install Flutter stable 3.47.9 or newer, Android Studio and an Android SDK. Then:

```bash
git clone https://github.com/MaheshPawar32/Kids-Games.git
cd Kids-Games
bash tool/setup_android.sh
flutter pub get
bash tool/setup_flutter_scene.sh
dart format lib test
flutter analyze
flutter test
flutter run --enable-flutter-gpu
```

The Android setup script creates the Android platform folder, verifies `com.dev.kidsgames`, sets minSdk 24 and adds Flutter GPU metadata. The Scene setup script runs the official asset-pipeline initializer and skills installer. It refuses to modify an existing custom `hook/build.dart`; merge generated instructions manually if a custom hook exists.

The current chat workspace has no local Flutter/Android SDK/Blender toolchain, so the scripts have not been executed here. GitHub Actions validates Dart source and dependency resolution; a local Android build and physical-device GPU check remain necessary.

## Build

```bash
flutter build apk --debug
```

Release build and device GPU validation remain release-readiness tasks.

## Project documentation

- [Repository audit](docs/REPOSITORY_AUDIT.md)
- [Implementation plan](docs/IMPLEMENTATION_PLAN.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Dependencies](docs/DEPENDENCIES.md)
- [Asset manifest](docs/ASSET_MANIFEST.md)
- [Asset TODO](docs/ASSET_TODO.md)
- [3D asset guidelines](docs/3D_ASSET_GUIDELINES.md)
- [Performance plan](docs/PERFORMANCE.md)
- [Testing plan](docs/TESTING.md)
- [Changelog](docs/CHANGELOG.md)
