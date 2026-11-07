# Dependency plan

Snapshot checked: 2026-11-07  
Target Flutter baseline: Flutter 3.47.9 stable / Dart 3.13.7, as observed in GitHub Actions.

These are candidate package versions from pub.dev, not yet declared or resolved in this repository. Versions must be tested together in CI and captured in `pubspec.lock` before the dependency phase is marked complete.

## Core

| Package | Candidate version | Responsibility | Status |
|---|---:|---|---|
| `flame` | `1.38.2` | 2D component game engine | Planned |
| `flame_audio` | `2.12.2` | Flame SFX/BGM playback | Planned |
| `flutter_scene` | `0.24.3` | Real-time glTF/GLB 3D renderer and scene asset pipeline | Planned; pin exactly until upgrades are tested |
| `velocity_x` | `4.3.1` | VxStore/VxState and selected UI helpers | Planned; compatibility gate required |
| `go_router` | `18.1.3` | App navigation | Planned |
| `flutter_animate` | `4.5.2` | Declarative UI transitions/effects | Planned |
| `lottie` | `3.8.2` | Short offline UI animation assets | Planned; avoid using for real character skeletal animation |

## Storage

| Package | Candidate version | Responsibility | Status |
|---|---:|---|---|
| `hive_ce` | `2.22.0` | Typed local database | Planned |
| `hive_ce_flutter` | `2.5.0` | Flutter initialization and storage integration | Planned |
| `shared_preferences` | `2.5.6` | Small non-critical settings only | Already declared |
| `path_provider` | `2.1.6` | App-local file paths for saves/assets/cache | Planned |

## Utilities and development

| Package | Candidate version | Responsibility | Status |
|---|---:|---|---|
| `vector_math` | `2.4.4` | Vector/matrix values used with Scene | Planned |
| `build_runner` | `2.17.1` | Code generation | Planned |
| `hive_ce_generator` | `1.12.1` | Hive CE adapters (add only if annotations/codegen are used) | Candidate |
| `flutter_lints` | `6.0.0` | Static analysis rules | Current is `^5.0.0`; update during foundation |
| `mocktail` | `1.0.5` | Unit/widget test fakes and mocks | Planned |

## Optional and deferred

| Package | Candidate version | Gate |
|---|---:|---|
| `flutter_scene_rapier` | `0.5.2` | Add only if actual rigid-body physics is required; first use Scene interaction/transforms |
| `firebase_core` | `5.1.0` | Defer until a Firebase project/configuration is explicitly available |
| `firebase_crashlytics` | `6.0.1` | Defer until Firebase is configured and privacy review approves crash reporting |

## Compatibility and integration notes

- Flutter Scene 0.24.3 requires Flutter 3.47 stable or later. Android is supported. Flutter GPU is disabled by default and must be enabled for Android in the app manifest for shipped builds.
- Flutter Scene is pre-1.0 and its own changelog warns that minor releases can contain breaking changes. Pin `0.24.3` exactly at first integration; upgrade only with documented migration and tests.
- The latest stable CI runner observed Flutter 3.47.9 / Dart 3.13.7, which is above the Scene baseline and satisfies the candidates that require Dart 3.13.
- VelocityX 4.3.1's changelog mentions Flutter 3.27 compatibility in its 4.3.0 entry; its release is older than the chosen SDK. Keep the mandated package, but perform a compile/runtime compatibility spike for `VxStore`/VxState before using it as the app-wide store.
- Use `vector_math/vector_math.dart` with Flutter Scene examples; do not import the legacy `vector_math_64` path.
- Use the Scene package's `dart run flutter_scene:init` pipeline. No custom build hook exists in this repo. Inspect generated content and preserve any later custom hook rather than overwriting it.
- Use Flame for 2D gameplay only. Do not mount Flame components inside Flutter Scene or pretend SceneView is a Flame component.
- `SharedPreferences` is for small preferences. Game sessions, progress and rewards belong in Hive CE repositories.
- Do not add Firebase, ads, network clients or analytics without a concrete requirement and child privacy review.

## Resolution procedure

1. Update `pubspec.yaml` in a dedicated dependency commit.
2. Run `flutter pub get` with Flutter 3.47.9 stable and inspect solver output.
3. Commit the generated `pubspec.lock` for the application.
4. Run `flutter analyze`, all tests and a debug Android build.
5. Run `dart run flutter_scene:init` only after the dependency resolves; inspect all files it creates/changes.
6. Record actual resolved versions and any API differences here.
