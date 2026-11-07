#!/usr/bin/env bash
set -euo pipefail

readonly REQUIRED_SCENE_VERSION="0.24.3"

if ! command -v flutter >/dev/null 2>&1 || ! command -v dart >/dev/null 2>&1; then
  echo "Install Flutter stable 3.47.1 or newer (including Dart) before running this script."
  exit 1
fi

if [[ ! -f pubspec.yaml ]] || ! grep -Eq "^  flutter_scene:[[:space:]]*$REQUIRED_SCENE_VERSION[[:space:]]*$" pubspec.yaml; then
  echo "pubspec.yaml must declare flutter_scene: $REQUIRED_SCENE_VERSION."
  exit 1
fi

if [[ ! -f android/app/src/main/AndroidManifest.xml ]] ||
   ! grep -q "io.flutter.embedding.android.EnableFlutterGPU" android/app/src/main/AndroidManifest.xml; then
  echo "Run bash tool/setup_android.sh first so the Android app and Flutter GPU flag exist."
  exit 1
fi

if [[ -f hook/build.dart ]]; then
  echo "A build hook already exists at hook/build.dart."
  echo "Review it and merge Flutter Scene's generated build() integration manually."
  echo "The existing hook has not been modified."
  exit 1
fi

flutter pub get
dart run flutter_scene:init
dart run flutter_scene:skills
flutter pub get

echo "Flutter Scene asset pipeline initialized."
echo "Review hook/build.dart and flutter_scene_generated/ before committing."
echo "Run with: flutter run --enable-flutter-gpu"
