# Implementation roadmap

Updated: 2026-11-10  
Branch: `feature/complete-app-workflows`

## Phase 1 — Foundation
- [x] Flutter source scaffold, theme and app entry point
- [x] 15-game catalogue and reusable activity data model
- [x] Target dependencies declared and dependency resolution verified in CI
- [x] Blender generation scripts and CI asset validation
- [ ] Generate and commit the Android platform project
- [ ] Run Android debug and release builds in CI

## Phase 2 — Onboarding and navigation
- [x] Child profile and grade selection (Nursery, LKG, UKG, Grades 1–5)
- [x] Local child profile save/restore
- [x] Five-tab home shell and Games catalogue navigation
- [ ] Splash and welcome experience
- [ ] Parent gate
- [ ] Adventure map and world selection

## Phase 3 — First playable versions of all catalogue activities

All 15 catalogue entries now have a playable route. The 12 choice-based activities share a five-round question engine with activity-specific cues, prompts, options, answer keys and explanations. This is the first playable version, not the final differentiated game design for every activity.

- [x] Complete Picture — five visual completion rounds
- [x] Shadow Matching — five silhouette-clue rounds
- [x] Color Matching — five color identification rounds
- [x] Shape Matching — dedicated matching screen
- [x] Alphabet Matching — five initial-letter rounds
- [x] Animal Recognition — five animal sound/identity rounds
- [x] Odd One Out — dedicated themed rounds
- [x] Big & Small — five size-comparison rounds
- [x] Missing Numbers — five number-line rounds
- [x] Missing Shapes — five repeating-pattern rounds
- [x] Find Differences — five visual odd-detail rounds
- [x] Magic Counting — five object-counting rounds
- [x] Number Sequencing — five counting-sequence rounds
- [x] What Comes Next — five repeating-sequence rounds
- [x] Jigsaw Puzzles — dedicated drag-and-drop puzzle

Still required within this phase:
- [ ] Replace choice-only mechanics with age-appropriate gestures where appropriate
- [ ] Difficulty settings for age/grade and progressive challenge
- [ ] Sound, spoken prompts, haptics and accessible alternatives
- [ ] Persist results, retries and activity mastery
- [ ] Expand question banks and review educational correctness with educators/parents

## Phase 4 — Learning and creativity
- [ ] Phonics, tracing, spelling and vocabulary
- [ ] Mathematics and guided practice
- [ ] Drawing, coloring and guided drawing
- [ ] Music, stories, science discovery and life skills

## Phase 5 — Motivation and progress
- [ ] Buddy collection, XP, badges and unlocks
- [ ] Daily missions and achievement gallery
- [ ] Mastery tracking and smart revision
- [ ] Rewards and progress backed by local persistence

## Phase 6 — Parent tools
- [ ] Parent Gate and dashboard
- [ ] Weekly report and learning history
- [ ] Screen-time limits and bedtime
- [ ] Accessibility preferences and offline content controls
- [ ] Safe reset/export safeguards and privacy controls

## Phase 7 — 3D runtime and release readiness
- [ ] Generate Android platform project and verify application ID `com.dev.kidsgames`
- [ ] Integrate Flutter Scene build hook and native GPU requirements
- [ ] Verify GLB rendering, animation clips and memory behavior on physical devices
- [ ] Integrate Flame only for game loops that need its 2D engine
- [ ] Optimize and visually approve production assets; record licenses/attributions
- [ ] Airplane-mode, lifecycle interruption, persistence and migration tests
- [ ] Accessibility, localization and child-safety review
- [ ] Performance profiling across low/mid/high-range Android devices
- [ ] Privacy policy, Play Data Safety, content rating and Families policy review
- [ ] Release keystore, signed AAB, internal testing and pre-launch report
- [ ] Final Play Store listing and release approval

## Release rule

A green analyzer/test run is necessary but not sufficient. Do not mark the app publish-ready until Android release builds, physical-device runtime checks, data/privacy compliance and Play Console pre-launch testing have all passed.
