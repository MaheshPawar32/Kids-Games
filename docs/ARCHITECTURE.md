# Architecture

## Initial approach
Use a feature-first Flutter structure with clear presentation, application, domain and data boundaries as the codebase grows. Avoid introducing a state-management package until the first persistent features are designed.

## Planned layers
- Presentation: screens, reusable widgets, visual states and accessibility.
- Application: feature controllers and user workflows.
- Domain: entities, activity rules, scoring and use cases.
- Data: local repositories, bundled content and persistence adapters.

## Feature areas
- onboarding and child profiles
- home and adventure map
- learning worlds and activity catalogue
- 15 mini-games
- phonics, tracing, vocabulary and mathematics
- drawing, coloring, music and interactive stories
- science discovery and life skills
- buddies, rewards and daily missions
- progress, revision and mistake review
- parent zone, screen time and accessibility
- offline content manager

## Offline-first rules
- Bundle all core activity instructions, question sets, illustrations and audio.
- Save profile, progress, settings and artwork locally.
- Keep the child experience usable in airplane mode.
- Treat network features as optional future additions requiring a privacy review.

## 3D visual strategy
Use Flutter for navigation, layouts, cards, controls and most mini-games. Prefer optimized pre-rendered transparent 3D illustrations and short animation assets for characters and worlds. Use Flame for selected 2D game loops. Introduce a real-time 3D renderer only for a feature that truly needs camera or object manipulation.

## Privacy and child safety
No public chat, social profiles, location tracking, unnecessary permissions or child-facing external links. Parent-only controls must be protected by a parent gate. Avoid targeted advertising and collect as little child data as possible.
