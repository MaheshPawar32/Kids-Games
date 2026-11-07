# Asset manifest

Audit date: 2026-11-07

This manifest lists files that actually exist in the repository. A design note or TODO is not proof that an exported model, texture, sound or animation exists.

## Existing assets

| Asset ID | Repository path | Format | Current purpose | Production 3D model? |
|---|---|---|---|---|
| `buddy_fox_svg` | `assets/characters/fox_buddy.svg` | SVG | Small UI mascot illustration | No |
| `buddy_rabbit_svg` | `assets/characters/rabbit_buddy.svg` | SVG | Small UI mascot illustration | No |
| `buddy_panda_svg` | `assets/characters/panda_buddy.svg` | SVG | Small UI mascot illustration | No |
| `adventure_island_svg` | `assets/illustrations/adventure_island.svg` | SVG | Decorative 3D-style vector illustration | No |
| `app_icon_svg` | `assets/icons/app_icon.svg` | SVG | Source artwork for future launcher icon generation | No |

The SVGs are vector illustrations with gradient/shading techniques. They are not meshes, are not rigged, cannot be rotated as 3D objects and do not satisfy the requested Blender/GLB asset deliverable.

## Genuine 3D assets found

- Blender source files: none
- GLB/glTF files: none
- Rigged skeletons: none
- Animation clips: none
- PBR material libraries: none
- Environment maps/HDRs: none
- Exported texture atlases: none

## Asset metadata required for every production entry

Record:
- Stable asset ID and semantic name
- Source `.blend` path and source-control revision
- Exported `.glb` path and SHA-256
- glTF version and exporter version
- Dimensions, scale, forward/up axes and origin convention
- Mesh/triangle count, materials, texture sizes and compression
- Skeleton and animation clip names/durations
- Licence, author/creator and commercial redistribution rights
- First supported app build and any known renderer limitations

## Manifest status

No production 3D asset is marked complete yet. Update this table only after a real Blender export is committed and opened successfully by the Flutter Scene asset pipeline.
