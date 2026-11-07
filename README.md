# Kids Games

A fresh, English-only, offline-first educational games app for children from Nursery through Grade 5.

## Product direction
- Flutter, Android only
- Package ID: `com.dev.kidsgames`
- Playful premium 3D visual direction using original illustrations, layered surfaces, gradients and motion
- No BrightBuddies branding or assets
- Core experience works offline
- Parent Zone will be protected by a parent gate

## Requirements
- Flutter 3.41 or newer (Dart 3.11+)
- Android Studio and Android SDK
- Android deployment minimum: API 24

## Setup on macOS
```bash
git clone https://github.com/MaheshPawar32/Kids-Games.git
cd Kids-Games
bash tool/setup_android.sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

The setup script creates only the Android platform folder and does not overwrite the existing Dart source. It sets the generated Android application ID to `com.dev.kidsgames` and the minimum SDK to 24.

## Build
```bash
flutter build apk --release
```

APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Current implementation
- First-run child onboarding with first name and grade selection
- Local profile save/restore using SharedPreferencesAsync
- Child-specific home greeting
- Five-tab navigation: Home, Learn, Games, Create and Rewards
- Fifteen activity catalogue entries
- Playable Shape Matching game with five rounds, visual answers, feedback, score and replay
- Original starter SVG buddy and adventure-world illustrations

The other fourteen games and the learning-world entries are catalogue/UI scaffolds until their individual gameplay is implemented.

## Project structure
```
lib/
  app/
    theme/
  features/
    onboarding/
    home/
    games/
      shape_matching/
assets/
  characters/
  illustrations/
  icons/
docs/
tool/
test/
```

## Initial activity catalogue
Complete Picture, Shadow Matching, Color Matching, Shape Matching, Alphabet Matching, Animal Recognition, Odd One Out, Big & Small, Missing Numbers, Missing Shapes, Find Differences, Magic Counting, Number Sequencing, What Comes Next, Jigsaw Puzzles.

## Development principles
- Keep learning content and game logic separate from widgets.
- Bundle assets and content needed for core activities.
- Save profile and progress locally; never require an account for core play.
- Use age-appropriate, accessible interactions and large touch targets.
- No child-facing chat, social feed, external links or targeted advertising.
- Do not add network permissions or analytics without a reviewed requirement.
- Starter SVGs are placeholders; replace them with original optimized 3D renders as asset production progresses.
