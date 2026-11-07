# Performance plan

## Target

- 60 FPS target on a defined baseline Android device class.
- High, Balanced and Performance graphics profiles.
- Short frame-time spikes during scene entry, loading or garbage collection.
- Predictable scene disposal and no unbounded asset/cache growth.

These are targets, not measured results. No performance pass is claimed until profile-mode measurements are collected from physical Android devices.

## Measurement matrix

For each baseline/low-end test phone record:
- Manufacturer/model, Android version, SoC and GPU
- Flutter version, app commit and build mode
- Scene/GLB asset IDs and texture resolution
- Average and p95 frame time, missed frames and jank count
- CPU/GPU usage and memory footprint
- Cold-start and scene-load time
- Battery/thermal behaviour during a representative 10-minute session

## Rendering practices

- Load only the active game scene and a small prefetch set.
- Use Flutter Scene for 3D transforms, cameras, materials and skeletal animations.
- Use Flame for 2D component/effect systems only.
- Keep the Scene and Flame component trees separate.
- Dispose scenes, textures, audio and listeners when game sessions end.
- Pool repeated 2D objects and avoid per-frame allocations.
- Limit particles, dynamic lights and simultaneous skinned characters.
- Use texture atlases and compressed/resized textures after validating quality.
- Avoid idle animations when the game is backgrounded or a screen is inactive.

## Graphics profiles

| Profile | Intended behavior | Acceptance evidence |
|---|---|---|
| High | Full resolution textures, shadows and richer lighting | Device profile trace and thermal test |
| Balanced | Reduced shadow/texture quality and particles | Same scene stable under target frame-time |
| Performance | Reduced render scale/effects and fewer concurrent animations | Stable on low-end baseline device |

Profile selection must change real renderer settings. It must not be a cosmetic preference toggle.

## Loading and lifecycle

- Show loading UI while assets are decoded; never block the main thread with custom CPU-heavy work.
- Preload only the next likely asset pack.
- Handle app pause/resume and audio focus.
- Verify scene and GPU resources are released after navigation away.
- Persist progress before a session is torn down.

## Status

- [ ] Baseline physical device selected
- [ ] First Flutter Scene profile trace captured
- [ ] Scene load/dispose memory test
- [ ] High/Balanced/Performance profiles implemented
- [ ] 60 FPS measured against the named device matrix
