# Kids Games

A playful, offline-first educational games app for children from Nursery through Grade 5.

## Product direction

- Flutter/Dart, Android only
- Android application ID: `com.dev.kidsgames` (committed Android Gradle project; minSdk 24)
- Offline-first; no mandatory account
- Flutter Scene is the planned runtime for genuine GLB/glTF 3D content
- Flame is planned for dedicated 2D mini-games
- Blender source files and GLB generation scripts are maintained in this repository
- VelocityX VxStore/VxState, GoRouter and Hive CE are the intended application architecture
- No Riverpod, Provider, GetX or BLoC
- No BrightBuddies branding or artwork

## Current implementation status

### Working in the Flutter source

- Child onboarding with name and grade selection
- Local child profile persistence through `SharedPreferencesAsync`
- Five-tab Home/Learn/Games/Create/Rewards shell
- VxStore/VxState for transient home-tab state
- GoRouter for onboarding, home and activity navigation
- Complete 15-activity catalogue
- Five-round offline question sets for 12 choice-based activities:
  Complete Picture, Shadow Matching, Color Matching, Alphabet Matching,
  Animal Recognition, Big & Small, Missing Numbers, Missing Shapes,
  Find Differences, Magic Counting, Number Sequencing and What Comes Next
- Dedicated playable Shape Matching, Odd One Out and drag-and-drop Jigsaw screens
- Feedback, score summary and replay for the implemented game loops
- Hive CE local game-session persistence and reactive Rewards summaries
- Android debug APK successfully built and uploaded by CI (debug/testing only)
- Widget tests for onboarding, navigation, selected games and Jigsaw drag/drop
- Blender scripts for procedural model generation and CI asset-generation checks

The 12 choice-based activities have activity-specific visual cues, prompts, four answer choices, answer keys and explanations. They currently share a tap-to-answer round engine; they are not yet 12 separately animated game engines.

### Not yet implemented or not release-validated

- Signed release configuration and verified Play Store AAB build
- Flutter Scene runtime initialization, build hook, native GPU setup and on-device GLB rendering
- Flame game foundation and dedicated Flame mini-games
- Child-scoped progress, streaks, mastery, difficulty progression and database migrations
- Complete Parent Gate, parent dashboard, parental controls and screen-time tools
- Full Rewards and Progress experiences backed by persisted data
- Full accessibility, audio narration, localization and child-friendly audio controls
- Production-quality, visually reviewed and optimized character/environment models and animation
- Device testing across screen sizes, Android versions, interruptions and low-memory conditions
- Privacy, data-safety, content-rating, Families policy, store listing and release-signing review

## Compatibility baseline

GitHub Actions uses Flutter stable 3.47.9 / Dart 3.13.7. Flutter Scene 0.24.3 is pinned in `pubspec.yaml`, but the native runtime has not yet been validated in an Android build or on a device.

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

The committed Android project contains the `com.dev.kidsgames` application ID, minSdk 24 and Flutter GPU metadata. `tool/setup_android.sh` remains available for regenerating the platform folder if needed. The Scene setup script runs the official asset-pipeline initializer and skills installer. These scripts still require execution and review in a configured development environment.

## Build

```bash
flutter build apk --debug
flutter build appbundle --release
```

The Android debug APK has been built successfully by GitHub Actions. A signed release AAB, store compliance and physical-device validation remain mandatory before publishing.

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
