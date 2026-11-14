# Implementation roadmap

Updated: 2026-11-14 · Branch: `feature/complete-app-workflows`

See `MASTER_PROJECT_AUDIT.md` for evidence behind each item.

## Done

- [x] Android project, application ID `com.dev.kidsgames`, CI debug APK build
- [x] Child profile with grade (Nursery–Grade 5), saved and restored
- [x] Five-tab shell; Parent Gate (adult check + PIN); daily limit and bedtime
- [x] All 15 games with 1000 generated levels each, grade-based difficulty, stars, unlocking and Next level
- [x] Every level of every question game validated for correctness by an automated test
- [x] Drag-into-gap with tap alternative, spot-the-difference, compare two pictures, tap-in-order
- [x] Flame: Magic Counting (moving targets, decoys, count totals) and Jigsaw (interlocking pieces, snapping)
- [x] Level progress in Hive (schema v1); sessions record their level
- [x] Original sound effects; parent sound and reduced-motion settings applied in games
- [x] 3D icon defects fixed (play, medal, book, puzzle piece)

## Next (in priority order)

1. Verify on an Android device or emulator: levels, Flame games, audio, Flutter Scene gallery.
2. Release basics: app label "Kids Games", launcher icon, signing config that reads `key.properties`.
3. Home dashboard with real data: continue playing, daily mission, stars total, recommended next level.
4. Rewards: stars per game, buddy unlocks based on stars, streaks.
5. Spoken prompts (offline text-to-speech) and animal sounds.
6. Learn: more lessons per world, letter and number tracing.
7. Multiple child profiles with per-child progress (needs a migration for existing sessions).
8. Remove unused dependencies; run the Khronos glTF Validator in CI.
9. Characters: Fox, Rabbit, Panda, Elephant, Monkey as 3D buddies (only Baby Lion exists).
10. Store listing, privacy policy and signed AAB (owner inputs; see `RELEASE_READINESS.md`).

## Release rule

Green CI is necessary but not sufficient. The app is not publish-ready until a signed release build has been tested on physical devices and the Play Families declarations are complete.
