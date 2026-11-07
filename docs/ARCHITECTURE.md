# Kids Games — target architecture

This document describes the required architecture. Items remain planned until the implementation and validation checklist is complete.

## Application foundation

- Flutter/Dart Android app, package ID `com.dev.kidsgames`.
- Offline-first: all core instructions, game levels and required assets ship locally.
- GoRouter owns page navigation and guarded parent-only routes.
- VelocityX VxStore/VxState is the selected app/session state mechanism, subject to a compatibility spike with Flutter 3.47.9 before broad adoption.
- SharedPreferences stores small settings only.
- Hive CE stores child profile, progress, game sessions, rewards and app settings that need structured persistence.
- Keep presentation widgets, game rules, storage adapters and renderers separated.

## Renderer boundaries

### Flutter UI
Owns app layout, buttons, overlays, accessibility, screen transitions and parent controls. Use reusable widgets from the design system.

### Flutter Scene
Owns true 3D rendering: GLB scenes, node transforms, camera, PBR materials, lighting, skeletal animation, picking and 3D effects. Flutter Scene is a separate scene graph, not a Flame component.

### Flame
Owns 2D mini-game components, sprites, input, collision, 2D particles and game-loop effects. Flame's component tree remains separate from Flutter Scene's graph.

### Shared game session
A renderer-agnostic application/domain controller owns game lifecycle, level, scoring, pause/resume, completion, persistence and result events. A game screen composes either a Scene view, Flame widget or a mixture of separately composed renderer views, but the controllers do not merge their render trees.

## Suggested module layout

```
lib/
  app/
    router/
    theme/
    store/
  core/
    audio/
    accessibility/
    persistence/
    game_session/
    widgets/
  features/
    onboarding/
    home/
    game_library/
    animal_world/
    shape_sorter/
    number_adventure/
    alphabet_world/
    color_match/
    puzzle_world/
    progress/
    rewards/
    parent/
    settings/
  data/
    hive/
    repositories/
    content/
  domain/
    models/
    rules/
    repositories/
assets/
  models/
  textures/
  materials/
  scenes/
  audio/
  images/
  icons/
  fonts/
blender/
  characters/
  environments/
  animations/
  export_scripts/
```

## Common game lifecycle

Every module uses the same session contract:

`initialize → loadAssets → start → pause/resume → restart → complete → dispose`

The controller exposes result events and progress changes. Rendering-specific code translates those events into Scene or Flame behaviour.

## Dependency responsibilities

- `flutter_scene`: genuine 3D engine and build-time glTF pipeline.
- `flame` / `flame_audio`: 2D game loop, components, sprite effects and offline audio.
- `velocity_x`: VxStore/VxState and selected UI convenience APIs; verify actual package API.
- `go_router`: app route tree and parent-gate route protection.
- `hive_ce` / `hive_ce_flutter`: structured offline storage.
- `shared_preferences`: lightweight preferences.
- `flutter_animate` / `lottie`: UI animation where appropriate; not a substitute for character rigging.
- `vector_math`: vector and matrix types used by Scene integrations.

## Privacy

No child-facing chat, public profiles, social network, location tracking, mandatory login or targeted advertising. Keep parent-only controls behind a parent gate. Defer Firebase and AdMob until there is an explicit configuration and privacy/Families review.
