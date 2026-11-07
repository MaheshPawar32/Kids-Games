# Changelog

## 2026-11-07 — Repository audit baseline

- Audited current Flutter source, onboarding, profile storage, navigation, activity catalogue, Shape Matching, tests, CI, dependency declarations and assets.
- Confirmed no Android platform directory or committed dependency lock file exists yet.
- Verified remote GitHub Actions uses Flutter stable 3.47.9 / Dart 3.13.7.
- Documented Flutter Scene Flutter GPU requirements and dependency candidates.
- Added repository audit, implementation plan, dependency plan, asset manifest/backlog, 3D asset conventions, performance and testing plans.
- No production GLB or Blender project is claimed as complete in this phase.

## Existing app foundation

- First-run child profile and grade selection
- On-device profile persistence using SharedPreferencesAsync
- Home/Learn/Games/Create/Rewards starter navigation
- 15-item activity catalogue
- Shape Matching five-round playable widget activity
- SVG visual artwork for fox, rabbit, panda, adventure island and app icon
