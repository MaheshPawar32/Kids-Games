# 3D asset production backlog

No items below are exported production models yet. Do not create empty GLBs or mark placeholder meshes as complete.

## Characters

- [ ] Baby lion — body, head, ears, paws, eyes, mouth, tail; child-safe proportions
- [ ] Elephant — trunk, ears, tusks (rounded/non-threatening), body and feet
- [ ] Rabbit — long ears, muzzle, paws and tail
- [ ] Panda — head, eye patches, body and paws
- [ ] Monkey — face, ears, hands, feet and curled tail
- [ ] Optional later buddy: fox character matching the current SVG mascot

For each character, create:
- [ ] Editable Blender source
- [ ] Clean topology and mobile-friendly mesh
- [ ] UVs and packed texture/material resources
- [ ] PBR base color, roughness and subtle normal detail
- [ ] Rig and named armature
- [ ] Idle, blink, walk, run, jump and celebrate clips
- [ ] Optimized GLB export and Flutter Scene import smoke test

## Environments and props

- [ ] Premium playground environment
- [ ] Trees and plants (modular)
- [ ] Grass, rocks and background props
- [ ] Ball
- [ ] Cube, sphere, triangular prism and cylinder
- [ ] Number tokens 0–20
- [ ] Alphabet tokens A–Z
- [ ] Treasure chest
- [ ] Coins
- [ ] Stars
- [ ] Reusable habitat/object sets for Animal World

## Asset pipeline and release checks

- [ ] Blender export script with deterministic settings
- [ ] Asset naming validator
- [ ] GLB structural validation (gltf-validator)
- [ ] Scene load smoke tests for each model
- [ ] Texture memory budget check
- [ ] PBR material/lighting review on Android
- [ ] Animation playback and disposal test
- [ ] Asset licence/source metadata captured in ASSET_MANIFEST.md

## Acceptance rule

An asset is complete only when the editable `.blend` source, valid optimized `.glb` export, documented animation clips, licence/source record and runtime import test are all present. A render or SVG illustration alone does not satisfy this rule.
