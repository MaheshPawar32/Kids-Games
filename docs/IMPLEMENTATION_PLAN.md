# Kids Games — implementation plan

This is the phase gate and delivery checklist for the premium 3D Android app. An item is checked only after implementation and its relevant validation are complete.

## Phase 0 — Repository audit

- [x] Inventory current files, screens, tests, dependencies and bundled assets
- [x] Record missing Android platform project and missing production 3D assets
- [x] Verify Flutter Scene's minimum stable SDK requirement against remote CI
- [x] Record toolchain and validation limitations
- [ ] Confirm final green CI after lint fixes

## Phase 1 — Flutter compatibility and foundation

- [ ] Pin the Flutter stable/Dart baseline in CI to Flutter 3.47.9 (Dart 3.13.7), or a later tested stable
- [ ] Set the project Dart lower bound to the chosen package baseline
- [ ] Resolve package versions and commit `pubspec.lock`
- [ ] Add target dependencies in controlled groups; test VelocityX 4.3.1 against Flutter 3.47.9 before committing to VxStore architecture
- [ ] Generate Android-only platform project
- [ ] Verify `applicationId = com.dev.kidsgames`
- [ ] Set the intended minimum SDK after checking all resolved plugin requirements
- [ ] Enable Flutter GPU in AndroidManifest.xml inside `<application>`
- [ ] Run `dart run flutter_scene:init`; inspect the generated build hook and merge rather than overwrite any future custom hook
- [ ] Run `dart run flutter_scene:skills` and read installed API guidance
- [ ] Add baseline design tokens and shared widgets while preserving existing screens
- [ ] Create a clean dependency and CI baseline

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
- [ ] Child profile setup
- [ ] Home playground with real 3D character/environment
- [ ] Game categories and library
- [ ] Game introduction, gameplay, pause, completion and results
- [ ] Rewards and progress
- [ ] Parent gate and parent dashboard
- [ ] Settings, About and privacy
- [ ] GoRouter navigation and deep-link policy (child routes remain internal/offline)

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
