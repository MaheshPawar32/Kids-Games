#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter was not found. Install Flutter stable and run this script again."
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

# shared_preferences 2.5.6 supports Android API 24 and newer.
perl -0pi -e '
  s/minSdk\s*=\s*flutter\.minSdkVersion/minSdk = 24/;
  s/minSdkVersion\s+flutter\.minSdkVersion/minSdkVersion 24/;
' "$gradle_file"

if ! grep -Eq 'minSdk\s*=\s*24|minSdkVersion\s+24' "$gradle_file"; then
  echo "Could not set Android minSdk to 24 in $gradle_file."
  exit 1
fi

echo "Android project created."
echo "Application ID: com.dev.kidsgames"
echo "Minimum Android SDK: 24"
