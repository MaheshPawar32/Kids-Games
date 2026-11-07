# 3D runtime integration

## Current implementation

The app includes:

- `KidsGames3DAssets`: a central registry for the Baby Lion and 13 icon asset paths.
- `ThreeDAssetPreview`: a reusable, on-demand Flutter Scene widget that loads one GLB with `Node.fromGlbAsset`.
- A Rewards-screen 3D trophy preview that opens only when tapped.
- Flutter asset declarations for the generated character and icon directories.

The preview uses Flutter Scene's runtime GLB import path. That path does not require the build-time scene conversion hook, but it does parse the GLB when opened. For larger shipped scenes, migrate to Flutter Scene's build-time `.fsceneb` asset pipeline.

## Generate assets locally

Run from the repository root with Blender installed:

```bash
blender --background --python blender/scripts/create_baby_lion.py
blender --background --python blender/scripts/create_3d_icon_pack.py
flutter pub get
```

The scripts create:

- `blender/output/baby_lion.blend`
- `assets/models/characters/baby_lion.glb`
- `assets/models/icons/*.glb`

The GitHub Actions workflow performs the same generation and downloads its generated artifact before Flutter analysis and tests. The generated binary files are currently delivered as a workflow artifact rather than committed to the source repository.

## Android runtime requirements

Create the Android project and enable Flutter GPU metadata:

```bash
bash tool/setup_android.sh
```

The setup script creates the Android-only project with application ID `com.dev.kidsgames`, sets Android minimum SDK 24 and enables Flutter GPU in the manifest. Do not skip the GPU metadata when running Flutter Scene on Android.

Run the app with Flutter GPU enabled during development:

```bash
flutter run --enable-flutter-gpu
```

The shipped Android manifest must retain:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableFlutterGPU"
    android:value="true" />
```

## Flutter Scene asset pipeline

For production scenes and larger character/environment models, use the guarded setup script after the Android project exists:

```bash
bash tool/setup_flutter_scene.sh
```

It runs `dart run flutter_scene:init` and installs the package's coding skills. It checks for an existing `hook/build.dart` and refuses to overwrite it. Review the generated build hook before committing it.

## Verification status

CI confirms the Baby Lion Blender source, its GLB export and all 13 icon GLBs are non-empty and have the GLB binary signature. The Flutter analyzer/test run checks the asset registry and preview widget compile. A real Android device render, camera framing, lighting review, frame-time measurement and Khronos glTF Validator pass are still required before release approval.
