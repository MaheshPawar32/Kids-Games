# Asset manifest

Audit date: 2026-11-07

This manifest lists assets that actually exist in the repository. SVG illustrations are UI artwork; they are not real-time 3D models.

## Existing SVG artwork

| Asset ID | Repository path | Format | Purpose | Genuine 3D? |
|---|---|---|---|---|
| `buddy_fox_svg` | `assets/characters/fox_buddy.svg` | SVG | Existing small UI mascot | No |
| `buddy_rabbit_svg` | `assets/characters/rabbit_buddy.svg` | SVG | Existing small UI mascot | No |
| `buddy_panda_svg` | `assets/characters/panda_buddy.svg` | SVG | Existing small UI mascot | No |
| `baby_lion_3d_style_svg` | `assets/characters/baby_lion_3d_style.svg` | SVG | Glossy 3D-look Animal World UI artwork | No |
| `elephant_3d_style_svg` | `assets/characters/elephant_3d_style.svg` | SVG | Glossy 3D-look Animal World UI artwork | No |
| `monkey_3d_style_svg` | `assets/characters/monkey_3d_style.svg` | SVG | Glossy 3D-look Animal World UI artwork | No |
| `rabbit_3d_style_svg` | `assets/characters/rabbit_3d_style.svg` | SVG | Glossy 3D-look buddy/activity artwork | No |
| `panda_3d_style_svg` | `assets/characters/panda_3d_style.svg` | SVG | Glossy 3D-look buddy/activity artwork | No |
| `adventure_island_svg` | `assets/illustrations/adventure_island.svg` | SVG | Existing decorative island illustration | No |
| `playground_3d_style_svg` | `assets/illustrations/playground_3d_style.svg` | SVG | Layered floating-island playground UI artwork | No |
| `app_icon_svg` | `assets/icons/app_icon.svg` | SVG | Source artwork for launcher icon generation | No |

The new SVGs use gradients, layered forms, highlights, soft shadows and shading to create a toy-like 3D appearance. They remain 2D vector paths: they cannot provide genuine perspective camera movement, skeletal animation, mesh transforms or PBR rendering.

## Genuine 3D assets found

- Blender source files: none
- GLB/glTF files: none
- Rigged skeletons: none
- Animation clips: none
- PBR material libraries: none
- Environment maps/HDRs: none
- Exported texture atlases: none

## Metadata required for every production 3D entry

Record:
- Stable asset ID and semantic name
- Source `.blend` path and source-control revision
- Exported `.glb` path and SHA-256
- glTF version and exporter version
- Dimensions, scale, forward/up axes and origin convention
- Mesh/triangle count, materials, texture sizes and compression
- Skeleton and animation clip names/durations
- Licence, author/creator and commercial redistribution rights
- First supported app build and known renderer limitations

## Usage rule

Use the 3D-look SVGs in Flutter UI cards, category tiles, onboarding, loading states and decorative backgrounds. Do not use them as substitutes for the Blender/GLB deliverables. Mark a production 3D asset complete only after the real GLB is committed and loaded successfully by Flutter Scene.


## Educational 3D library — generator definitions

The Blender generator `blender/scripts/create_learning_asset_library.py` defines
71 independent runtime models and writes a matching editable `.blend` source
scene for each model under `blender/output/learning_assets/`.

| Category | Count | Runtime directory |
|---|---:|---|
| Number tokens 0–20 | 21 | `assets/models/numbers/` |
| Alphabet tokens A–Z | 26 | `assets/models/letters/` |
| Geometric shapes | 10 | `assets/models/shapes/` |
| Game props | 11 | `assets/models/props/` |
| Modular environments | 3 | `assets/models/environments/` |
| **Total** | **71** | |

These are generator-defined outputs, not a claim that the generated files have
already passed CI or visual review. Once a workflow artifact is produced, record
its run ID, file sizes, SHA-256 values and glTF Validator results here. Keep the
existing acceptance rule: runtime load and device review are required before
production approval.
