# Kids Games

Premium playful 3D educational game app for children from Nursery through Grade 5.

## Product direction

- Flutter/Dart, Android only
- Android application ID: `com.dev.kidsgames` (intended; generated Android project still needs to be created and verified)
- Offline-first; no mandatory account
- Flutter Scene for genuine real-time 3D (GLB/glTF, PBR, camera and skeletal animation)
- Flame for separate 2D mini-games
- Blender source files and optimized GLB exports for production character/environment assets
- VelocityX VxStore/VxState, GoRouter and Hive CE as the required state/navigation/storage architecture
- No Riverpod, Provider, GetX or BLoC
- No BrightBuddies branding or artwork

## Compatibility baseline

The remote GitHub Actions runner used Flutter stable 3.47.9 / Dart 3.13.7. Flutter Scene 0.24.3 documents Flutter 3.47 stable or newer and requires Flutter GPU to be enabled on Android for shipped builds.

The local execution workspace used for the current audit does not include Flutter, Dart, Android SDK/adb or Blender. Use the audit and dependency documents for exact setup and toolchain gaps.

## Current implementation status

Existing useful foundation:
- Child onboarding and grade selection
- Local child profile persistence through SharedPreferencesAsync
- Five-tab Home/Learn/Games/Create/Rewards shell
- 15-item educational activity catalogue
- One playable five-round Shape Matching activity

Not yet implemented:
- Flutter Scene and actual GLB loading
- Flame game foundation
- Hive CE and VelocityX VxStore migration
- GoRouter
- Generated Android project and Flutter GPU manifest flag
- Blender source assets and production GLB exports
- Animal World, Number Adventure, Alphabet World, Color Match, Puzzle World
- Parent gate/dashboard, rewards persistence and production progress tracking

Do not treat the SVG buddies/island as 3D models. They are only vector illustrations.

## Start-up (current repository state)

Install Flutter stable 3.47.9 or later, Android Studio and an Android SDK. Then:

```bash
git clone https://github.com/MaheshPawar32/Kids-Games.git
cd Kids-Games
bash tool/setup_android.sh
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```

The Android setup script currently generates the platform folder and sets the application ID/minimum SDK. Flutter GPU manifest integration is part of Phase 1 and is not yet completed.

## Build

```bash
flutter build apk --debug
```

Production Scene work must also use the Android Flutter GPU setting documented in [DEPENDENCIES.md](docs/DEPENDENCIES.md) and the Flutter Scene setup pipeline.

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
