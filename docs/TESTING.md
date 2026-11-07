# Testing strategy

## Current test inventory

The existing `test/widget_test.dart` has four widget scenarios:
- First launch completes child setup and opens the personalized home screen.
- A stored child profile skips onboarding.
- Bottom navigation opens the Games tab.
- Shape Matching opens and accepts the correct answer.

These tests were present in the repository before the 3D architecture work. A passing test result is not yet recorded for the latest commit.

## Required test layers

### Unit tests
- Game scoring and progression
- Game-session lifecycle state transitions
- Reward unlock rules
- Progress aggregation
- Hive adapters and repository behaviour
- Settings persistence and migration

### Widget tests
- GoRouter navigation and protected routes
- Onboarding validation
- Parent gate and parent-only settings
- Pause/resume and completion overlays
- Game result presentation and retry
- Accessibility labels and large touch targets

### Flame tests
- Component spawn/removal
- Input/collision response
- Pause/resume/restart/complete/dispose
- Score and result event delivery
- Audio lifecycle with mocked playback

### Flutter Scene tests
- Static resource initialization
- Build-time asset pipeline generation
- GLB load success/failure
- Scene mount/unmount/dispose
- Transform/camera/animation smoke tests
- Android GPU debug and release smoke tests

A widget test cannot substitute for a real GPU/device test.

## Commands

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

For Scene development:

```bash
flutter run --enable-flutter-gpu
```

After the Android application is configured for shipping, verify the Flutter GPU metadata flag in the merged Android manifest.

## CI gate

Every implementation phase must:
1. Run formatting.
2. Run analyzer with no warnings/errors and review info lints.
3. Run relevant unit and widget tests.
4. Build a debug APK when Android platform files exist.
5. Record command output and commit SHA.

## Manual Android testing

- Airplane mode on and off
- Cold start and repeated launch
- App background/resume during gameplay
- Low-memory interruption and scene teardown
- Small and large phone screens
- TalkBack, contrast, reduced motion and text scale
- Audio mute/volume and audio focus
- Thermal and battery test for a sustained session
