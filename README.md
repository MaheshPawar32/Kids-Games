# Kids Games

A fresh, English-only, offline-first educational games app for children from Nursery through Grade 5.

## Product direction
- Flutter, Android only
- Package ID: `com.dev.kidsgames`
- Playful premium 3D visual direction using original illustrations, layered surfaces, gradients and motion
- No BrightBuddies branding or assets
- Core experience works offline
- Parent Zone protected by a parent gate

## Current setup
This repository contains the initial Flutter application source, theme foundation, original starter SVG assets and an activity catalogue.

## Create the Android project files
Install Flutter stable and Android Studio / Android SDK, then run:

```bash
git clone https://github.com/MaheshPawar32/Kids-Games.git
cd Kids-Games
# Generate Android files separately so the existing Dart source is preserved.
flutter create --platforms=android --org com.dev --project-name kidsgames /tmp/kidsgames_android
cp -R /tmp/kidsgames_android/android ./android
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

If Flutter asks to overwrite existing Dart files, keep the repository versions. The generated Android application ID should be `com.dev.kidsgames`.

## Build
```bash
flutter build apk --release
```

## Project structure
```
lib/
  app/
  core/
  features/
    home/
    games/
  shared/
assets/
  characters/
  illustrations/
  icons/
test/
docs/
```

## Initial activity catalogue
Complete Picture, Shadow Matching, Color Matching, Shape Matching, Alphabet Matching, Animal Recognition, Odd One Out, Big & Small, Missing Numbers, Missing Shapes, Find Differences, Magic Counting, Number Sequencing, What Comes Next, Jigsaw Puzzles.

## Development principles
- Keep learning content and game logic separate from widgets.
- Bundle assets and content needed for core activities.
- Save progress locally; never require an account for core play.
- Use age-appropriate, accessible interactions and large touch targets.
- No child-facing chat, social feed, external links or targeted advertising.
- Do not add network permissions or analytics without a reviewed requirement.
