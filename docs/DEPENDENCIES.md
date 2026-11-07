# Dependency plan

Snapshot checked: 2026-11-07  
Target Flutter baseline: Flutter 3.47.9 stable / Dart 3.13.7, pinned in GitHub Actions.

The package versions below are now declared in `pubspec.yaml`. GitHub Actions must resolve the full set successfully before dependency integration is considered validated. The application lock file still needs to be generated and committed from a Flutter/Dart environment.

## Core

| Package | Declared constraint | Responsibility | Status |
|---|---:|---|---|
| `flame` | `^1.38.2` | 2D component game engine | Declared; lifecycle foundation pending |
| `flame_audio` | `^2.12.2` | Flame SFX/BGM playback | Declared; centralized audio manager pending |
| `flutter_scene` | `0.24.3` | Real-time glTF/GLB 3D renderer and scene asset pipeline | Declared and exact-pinned; build hook/prototype pending |
| `velocity_x` | `^4.3.1` | VxStore/VxState | Declared; VxState tab integration implemented |
| `go_router` | `^18.1.3` | App navigation | Declared and integrated for startup and game route |
| `flutter_animate` | `^4.5.2` | Declarative UI transitions/effects | Declared; reusable animation system pending |
| `lottie` | `^3.8.2` | Short offline UI animation assets | Declared; animation assets pending |

## Storage

| Package | Declared constraint | Responsibility | Status |
|---|---:|---|---|
| `hive_ce` | `^2.22.0` | Typed local database | Declared; boxes/adapters pending |
| `hive_ce_flutter` | `^2.5.0` | Flutter initialization and storage integration | Declared; integration pending |
| `shared_preferences` | `^2.5.6` | Small non-critical settings | Existing profile implementation; migrate durable profile/progress to Hive CE in a data migration |
| `path_provider` | `^2.1.6` | App-local file paths for saves/assets/cache | Declared; integration pending |

## Utilities and development

| Package | Declared constraint | Responsibility | Status |
|---|---:|---|---|
| `vector_math` | `^2.4.4` | Vector/matrix values used with Scene | Declared |
| `build_runner` | `^2.17.1` | Code generation | Declared |
| `hive_ce_generator` | `^1.12.1` | Hive CE adapter generation | Declared |
| `flutter_lints` | `^6.0.0` | Static analysis rules | Upgraded |
| `mocktail` | `^1.0.5` | Unit/widget test fakes and mocks | Declared |

## Optional and deferred

| Package | Candidate version | Gate |
|---|---:|---|
| `flutter_scene_rapier` | `0.5.2` | Add only if actual rigid-body physics is required; first use Scene interaction/transforms |
| `firebase_core` | `5.1.0` | Defer until a Firebase project/configuration is explicitly available |
| `firebase_crashlytics` | `6.0.1` | Defer until Firebase is configured and privacy review approves crash reporting |

## Compatibility and integration notes

- Flutter Scene 0.24.3 requires Flutter 3.47 stable or newer. Android is supported. Flutter GPU is disabled by default and must be enabled in the Android manifest for shipped builds.
- Flutter Scene is pre-1.0 and its own changelog warns that minor releases can contain breaking changes. Pin `0.24.3` exactly at first integration; upgrade only with documented migration and tests.
- Lottie 3.8.2 requires Dart 3.13; the pinned CI runner uses Dart 3.13.7.
- VelocityX 4.3.1 is older than the selected Flutter SDK; its changelog mentions Flutter 3.27 compatibility in 4.3.0. VxStore/VxBuilder integration is therefore gated by the pinned CI compile and widget tests. Do not expand usage until this gate passes.
- VelocityX depends on `vxstate` and exports the VxState APIs used in the app. Do not add a separate direct `vxstate` dependency unless a direct import becomes necessary.
- GoRouter 18.1.3 requires Dart 3.12; Dart 3.13.7 satisfies this.
- Flame Audio 2.12.2 depends on Flame and audioplayers. Use its APIs only inside the audio/game layer.
- Hive CE uses `hive_ce_generator` with `build_runner` for typed adapters; no adapters or generated files are claimed yet.
- SharedPreferences is for small settings only. Game sessions, progress and rewards belong in Hive CE repositories.
- Use `vector_math/vector_math.dart` with Flutter Scene examples; do not import the legacy `vector_math_64` path.
- Use the Scene package's `dart run flutter_scene:init` pipeline. No custom build hook exists in this repo. The helper script refuses to proceed if `hook/build.dart` already exists, so a custom hook cannot be overwritten by accident.
- Use Flame for 2D gameplay only. Do not mount Flame components inside Flutter Scene or pretend SceneView is a Flame component.
- Do not add Firebase, ads, network clients or analytics without a concrete requirement and child privacy review.

## Resolution procedure

1. Run `flutter pub get` with Flutter 3.47.9 stable and inspect solver output.
2. Commit the generated `pubspec.lock` for the application.
3. Run `flutter analyze`, all tests and a debug Android build.
4. Run `bash tool/setup_android.sh` on a configured workstation, verify generated manifest/Gradle output and commit the generated Android project.
5. Run `bash tool/setup_flutter_scene.sh`; inspect the generated `hook/build.dart`, `flutter_scene_generated/` entry and installed skills.
6. Record actual resolved versions, lockfile and any API differences here.
