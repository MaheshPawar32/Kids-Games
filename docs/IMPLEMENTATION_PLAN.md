# Kids Games — implementation plan

This is the phase gate and delivery checklist for the premium 3D Android app. An item is checked only after implementation and its relevant validation are complete.

## Phase 0 — Repository audit

- [x] Inventory current files, screens, tests, dependencies and bundled assets
- [x] Record missing Android platform project and missing production 3D assets
- [x] Verify Flutter Scene's minimum stable SDK requirement against remote CI
- [x] Record toolchain and validation limitations
- [x] Confirm green CI for analyzer and all four existing widget tests after fixes

## Phase 1 — Flutter compatibility and foundation

- [x] Pin GitHub Actions to Flutter stable 3.47.9 (Dart 3.13.7)
- [x] Set the Dart lower bound to 3.13 for the Lottie 3.8.2 dependency
- [x] Declare Flame, Flame Audio, Flutter Scene, VelocityX, GoRouter, animations, Hive CE, path_provider and utility/test packages
- [x] Implement VxStore/VxState for main-tab selection
- [x] Integrate GoRouter for loading, setup, home and Shape Matching routes
- [x] Add a guarded Android-only platform setup script that verifies app ID/minSdk and enables Flutter GPU metadata
- [x] Add a Flutter Scene setup script that installs the official asset pipeline and coding-agent skills without overwriting an existing custom build hook
- [x] Resolve dependencies on CI and record the resulting solver output
- [ ] Generate and commit pubspec.lock
- [ ] Generate Android platform folder locally and inspect Gradle/manifest settings
- [ ] Run flutter_scene:init and flutter_scene:skills on the development workstation; inspect generated files
- [ ] Compile the VxStore integration against the pinned dependency graph
- [x] Verify an Android debug APK build in CI (debug only; not a release artifact)

## Phase 2 — Flutter Scene 3D prototype

- [ ] Add a minimal, real Flutter Scene scene using documented APIs
- [ ] Render a built-in geometric primitive before importing models
- [ ] Load a valid GLB asset through the Scene asset pipeline
- [ ] Add PBR material and environment lighting
- [ ] Verify camera control, transforms and scene disposal
- [ ] Verify Flutter GPU on Android debug and release configurations
- [ ] Add a deterministic scene smoke test and record device/GPU results
- [ ] Do not mark Android rendering complete from analyzer or widget tests alone

## Phase 3 — Flame foundation

- [ ] Add a reusable Flame game configuration and lifecycle
- [ ] Add game-session event/result contracts shared with Flutter screens
- [ ] Add input, collision, pause/resume/restart/complete and disposal patterns
- [ ] Add audio and effect management
- [ ] Keep Flame's component tree independent of Flutter Scene's scene graph
- [ ] Add lifecycle and scoring tests

## Phase 4 — Blender and GLB pipeline

- [ ] Establish Blender source conventions and reproducible export scripts
- [ ] Create editable `.blend` sources; export and validate actual GLB files
- [ ] Establish consistent PBR material, UV, rig, scale, origin, camera and animation conventions
- [ ] Generate asset manifest entries for source and export hashes, clips, dimensions and license
- [ ] Build first real animal character, environment and animation set
- [ ] Check runtime file sizes, texture memory and GPU frame time on Android

## Phase 5 — First complete game: Animal World

- [ ] Animal discovery and identification
- [ ] Real 3D animal model loading and interactions
- [ ] Idle, blink, walk and celebrate clips where produced
- [ ] Offline animal sounds with settings controls
- [ ] Habitat discovery and progressive difficulty
- [ ] Game result and progress persistence
- [ ] Unit, widget, asset and Android smoke tests

## Phase 6 — Remaining educational games

- [ ] Shape Sorter
- [ ] Number Adventure (0–20)
- [ ] Alphabet World (A–Z)
- [ ] Color Match
- [ ] Puzzle World

Each module must implement the common lifecycle and result contract, provide child-safe feedback, work offline, and have isolated tests.

## Phase 7 — Application screens and navigation

- [ ] Splash and onboarding flow
- [x] Child profile setup
- [ ] Home playground with real 3D character/environment
- [ ] Game categories and library
- [ ] Game introduction, gameplay, pause, completion and results
- [ ] Rewards and progress
- [ ] Parent gate and parent dashboard
- [ ] Settings, About and privacy
- [x] GoRouter navigation for core entry and Shape Matching routes
- [ ] GoRouter parent-gate route protection and child-route policy

## Phase 8 — Local data, rewards and parent tools

- [ ] Hive CE adapters for ChildProfile, GameProgress, GameSession, Reward and AppSettings
- [ ] Versioned local schema and migration tests
- [ ] Progress, completion, stars, score, duration and last-played state
- [ ] Rewards and unlock rules
- [ ] Parent-only screen-time and bedtime controls
- [ ] Separate music and SFX volume settings
- [ ] Accessibility preferences and data reset safeguards

## Phase 9 — Quality, accessibility and privacy

- [ ] Airplane-mode and cold-start tests
- [ ] Scene lifecycle interruption tests
- [ ] Small/large screen and landscape policy tests
- [ ] TalkBack, contrast, large touch targets and reduced motion review
- [ ] Child privacy, permissions and Google Play Families review
- [ ] Graphics profile selection: High, Balanced and Performance
- [ ] Profile-mode 60 FPS target measurement and memory capture
- [ ] No ad SDK until the child-directed ads policy is explicitly reviewed

## Phase 10 — Android release preparation

- [ ] Release build with Flutter GPU enabled
- [ ] Signing configuration provided locally and never committed
- [ ] Launcher/adaptive icon outputs
- [ ] Play Store listing, Data safety and Families declarations
- [ ] Install/upgrade/uninstall and offline restore tests
- [ ] Final release checklist and signed APK/AAB delivery
