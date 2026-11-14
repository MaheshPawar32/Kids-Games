# Testing report

Updated: 2026-11-14 · Flutter 3.47.9 / Dart 3.13.7

## Automated results

| Check | Result | Where |
|---|---|---|
| `flutter analyze` | No issues | Local + CI run 43583196073 |
| `dart format --set-exit-if-changed lib test` | Clean | Local |
| `flutter test` | 50 passed, 0 failed | Local + CI run 43583196073 |
| Blender asset generation (85 GLBs + .blend sources) | Passed | CI job `generate-baby-lion-3d` |
| Android debug APK build | Passed | CI job `analyze-and-test` |
| Release AAB build | Not run | Blocked on signing keystore |

## What the tests cover

| Suite | Covers |
|---|---|
| `level_generator_test.dart` | Every level 1–1000 of all 13 question games for all 8 grades (about 104,000 levels). Each answer is re-derived independently (number rules, colour facts, animal facts, spelling, categories, single-answer patterns). Also checks the difficulty curve, star thresholds, determinism and the Flame level specs. |
| `flame_counting_game_screen_test.dart` | Real taps on Flame components: collecting every star, decoy penalty, ask-total phase, pause/resume, saved session and level unlock. |
| `jigsaw_game_test.dart` | Real drags of Flame pieces: snapping, wrong drops counted as moves, tap-then-tap placement, completion, stars and saving. |
| `widget_test.dart` | Onboarding, profile restore, Games → level map → play → stars → Next level → Back to map → Rewards. |
| `parent_gate_test.dart`, `parent_access_test.dart`, `child_access_guard_test.dart` | Adult check, PIN creation and unlock, daily limit, bedtime. |
| `family_usage_repository_test.dart` | Daily usage persistence and midnight rollover. |
| `game_session_repository_test.dart` | Hive session save, flush and malformed-entry tolerance. |
| `learn_worlds_test.dart`, `create_studio_test.dart` | Lesson quiz completion; drawing, undo/redo, gallery save and delete. |
| `kids_games_3d_assets_test.dart` | Asset registry paths. |

## 3D asset validation

- All 85 GLBs: valid glTF 2.0 headers and chunk lengths, every primitive has normals and a material, 6.4 MB in total, no textures.
- The 13 icons were rendered with a geometry renderer and reviewed by eye; the four defects found are fixed (see `MASTER_PROJECT_AUDIT.md`).
- Khronos glTF Validator: not yet run.

## Not yet tested

- Physical Android devices (no device was available).
- Flutter Scene GPU rendering at runtime (widget tests cannot verify GPU output).
- Audio output, TalkBack, large text, airplane mode, low memory, rotation.
- Release-mode behaviour.
