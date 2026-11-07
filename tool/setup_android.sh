#!/usr/bin/env bash
set -euo pipefail

readonly MIN_FLUTTER_MAJOR=3
readonly MIN_FLUTTER_MINOR=47
readonly MIN_FLUTTER_PATCH=1
readonly APPLICATION_ID="com.dev.kidsgames"
readonly GPU_METADATA_NAME="io.flutter.embedding.android.EnableFlutterGPU"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter was not found. Install Flutter stable 3.47.1 or newer."
  exit 1
fi

flutter_version="$(flutter --version | sed -n '1s/^Flutter[[:space:]]\+\([^[:space:]]\+\).*/\1/p')"
if [[ -z "$flutter_version" ]]; then
  echo "Could not parse 'flutter --version'."
  exit 1
fi

version_core="${flutter_version%%[-+]*}"
IFS='.' read -r flutter_major flutter_minor flutter_patch <<< "$version_core"
flutter_patch="${flutter_patch:-0}"

if (( flutter_major < MIN_FLUTTER_MAJOR ||
      (flutter_major == MIN_FLUTTER_MAJOR && flutter_minor < MIN_FLUTTER_MINOR) ||
      (flutter_major == MIN_FLUTTER_MAJOR && flutter_minor == MIN_FLUTTER_MINOR && flutter_patch < MIN_FLUTTER_PATCH) )); then
  echo "Flutter Scene requires Flutter 3.47 stable or newer."
  echo "Detected Flutter $flutter_version. Upgrade Flutter, then rerun this script."
  exit 1
fi

if [[ -d android ]]; then
  echo "The android/ folder already exists. This script will not overwrite it."
  exit 1
fi

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

flutter create \
  --platforms=android \
  --org com.dev \
  --project-name kidsgames \
  "$temp_dir/kidsgames_android"

if [[ ! -d "$temp_dir/kidsgames_android/android" ]]; then
  echo "Flutter did not generate an Android project."
  exit 1
fi

mkdir -p android
cp -R "$temp_dir/kidsgames_android/android/." android/

gradle_file=""
if [[ -f android/app/build.gradle.kts ]]; then
  gradle_file="android/app/build.gradle.kts"
elif [[ -f android/app/build.gradle ]]; then
  gradle_file="android/app/build.gradle"
else
  echo "Could not find the Android app Gradle file."
  exit 1
fi

# shared_preferences and path_provider 2.5.x/2.1.x support Android API 24+.
perl -0pi -e '
  s/minSdk\s*=\s*flutter\.minSdkVersion/minSdk = 24/;
  s/minSdkVersion\s+flutter\.minSdkVersion/minSdkVersion 24/;
' "$gradle_file"

if ! grep -Eq 'minSdk[[:space:]]*=[[:space:]]*24|minSdkVersion[[:space:]]+24' "$gradle_file"; then
  echo "Could not set Android minSdk to 24 in $gradle_file."
  exit 1
fi

if ! grep -Eq 'applicationId.*com\.dev\.kidsgames' "$gradle_file"; then
  echo "Generated Gradle file does not contain applicationId $APPLICATION_ID."
  echo "Inspect $gradle_file before proceeding."
  exit 1
fi

manifest_file="android/app/src/main/AndroidManifest.xml"
if [[ ! -f "$manifest_file" ]]; then
  echo "Could not find $manifest_file."
  exit 1
fi

if grep -q "$GPU_METADATA_NAME" "$manifest_file"; then
  perl -0pi -e '
    s#(<meta-data[^>]*android:name="io\.flutter\.embedding\.android\.EnableFlutterGPU"[^>]*android:value=")false(")#${1}true${2}#g;
  ' "$manifest_file"
else
  perl -0pi -e '
    s#(<application\b[^>]*>)#$1\n        <meta-data android:name="io.flutter.embedding.android.EnableFlutterGPU" android:value="true" />#;
  ' "$manifest_file"
fi

if ! grep -q "$GPU_METADATA_NAME" "$manifest_file" ||
   ! grep -Eq 'android:name="io\.flutter\.embedding\.android\.EnableFlutterGPU"[[:space:]]+android:value="true"' "$manifest_file"; then
  echo "Flutter GPU metadata was not enabled correctly in $manifest_file."
  exit 1
fi

echo "Android project created."
echo "Flutter version: $flutter_version"
echo "Application ID: $APPLICATION_ID"
echo "Minimum Android SDK: 24"
echo "Flutter GPU: enabled in AndroidManifest.xml"
echo "Next: flutter pub get && flutter run --enable-flutter-gpu"
