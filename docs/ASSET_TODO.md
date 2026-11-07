# Asset TODO — genuine 3D production assets

The repository contains SVG UI artwork, some styled to look like glossy 3D toys. **No production GLB character or environment model is claimed complete.**

## SVG UI artwork created

- [x] Baby lion — `assets/characters/baby_lion_3d_style.svg`
- [x] Elephant — `assets/characters/elephant_3d_style.svg`
- [x] Monkey — `assets/characters/monkey_3d_style.svg`
- [x] Rabbit — `assets/characters/rabbit_3d_style.svg`
- [x] Panda — `assets/characters/panda_3d_style.svg`
- [x] Floating-island playground — `assets/illustrations/playground_3d_style.svg`

These are 2D vector UI assets with depth effects, not GLB models.

## Blender / GLB character deliverables

- [ ] Baby lion: editable `.blend`, optimized `.glb`, rig, idle, blink, walk, run, jump, celebrate
- [ ] Elephant: editable `.blend`, optimized `.glb`, rig, idle, blink, walk, run, jump, celebrate
- [ ] Rabbit: editable `.blend`, optimized `.glb`, rig and required clips
- [ ] Panda: editable `.blend`, optimized `.glb`, rig and required clips
- [ ] Monkey: editable `.blend`, optimized `.glb`, rig and required clips

For each character:
- [ ] Child-friendly proportions and clean mobile topology
- [ ] UV mapping and packed texture/material resources
- [ ] PBR base color, roughness and subtle normal detail
- [ ] Named armature and documented animation clips
- [ ] Optimized GLB export
- [ ] Flutter Scene import and animation smoke test on Android

## Reusable 3D icon library

- [ ] Generate 13 separate GLB icon meshes: star, trophy, gift, heart, home, book, settings, sound, play, pause, lock, medal and puzzle piece
- [ ] Validate GLB headers and Khronos glTF structure
- [ ] Review every icon from the intended Flutter Scene camera angle
- [ ] Add Flutter Scene icon-gallery smoke test and performance budget
- [ ] Record final icon previews, file sizes and source revision in the manifest

## Environments and props

- [ ] Real 3D playground floating island
- [ ] Modular trees, plants, grass, rocks and habitat props
- [ ] Ball, cube, sphere, triangular prism and cylinder
- [ ] Number tokens 0–20
- [ ] Alphabet tokens A–Z
- [ ] Treasure chest, coins and stars
- [ ] Reusable Animal World habitat sets

## Pipeline and release checks

- [ ] Blender export script with deterministic settings
- [ ] Asset naming validator
- [ ] GLB structural validation with gltf-validator
- [ ] Scene load smoke tests for every model
- [ ] Texture memory budget check
- [ ] PBR material and lighting review on Android
- [ ] Animation playback and resource disposal tests
- [ ] Licence/source metadata recorded in ASSET_MANIFEST.md

## Acceptance rule

An asset is complete only when its editable `.blend` source, valid optimized `.glb` export, documented animation clips, licence/source record and runtime import test are all present. A render or SVG illustration alone does not satisfy this rule.
