# Blender asset pipeline

## Requirements
- Blender 4.2 or newer with the bundled glTF 2.0 exporter enabled.
- No paid add-on is required for the starter character generator.

## Generate the Baby Lion starter
From the repository root:

```bash
blender --background --python blender/scripts/create_baby_lion.py
```

The script writes:
- Editable Blender source: `blender/output/baby_lion.blend`
- Runtime export: `assets/models/characters/baby_lion.glb`

Open the .blend file in Blender and inspect the proportions, materials, parenting,
animation actions and NLA tracks. Play each clip before exporting for production.

## Important status
This script is a procedural starter asset generator. It does not prove that the
exported model meets final visual, topology, animation or Android runtime quality.
Do not mark Baby Lion complete until:
1. The .blend and .glb files exist.
2. The GLB passes Khronos glTF Validator.
3. Idle and Celebrate clips play correctly in Blender and Flutter Scene.
4. The model is reviewed on a real Android device.
5. Source/licence and export metadata are recorded in the asset manifest.

The starter uses separate toy-like mesh parts attached to named bones. A production
artist should refine the sculpt, topology, UVs, texture detail, facial expression,
deformation quality and the remaining animation set (blink, walk, run and jump).


## Generate the reusable 3D icon pack

From the repository root:

```bash
blender --background --python blender/scripts/create_3d_icon_pack.py
```

The generator creates separate, independently loadable GLB assets under
`assets/models/icons/`:

- `star.glb`, `trophy.glb`, `gift.glb`, `heart.glb`
- `home.glb`, `book.glb`, `settings.glb`, `sound.glb`
- `play.glb`, `pause.glb`, `lock.glb`, `medal.glb`
- `puzzle_piece.glb`

The icon models use a shared bright toy-like PBR palette and rounded geometry.
They are standalone 3D meshes; they are not flattened SVG or PNG icons. The
generator is an initial production pipeline and every model still requires
visual review, structural validation and a Flutter Scene load test before release.

## Generate the complete educational 3D library

Run:

```bash
blender --background --python blender/scripts/create_learning_asset_library.py
```

The generator creates **71 individual GLB models** and matching editable Blender
source scenes:

- 21 number tokens: 0–20 (`assets/models/numbers/number_00.glb` … `number_20.glb`)
- 26 alphabet tokens: A–Z (`assets/models/letters/letter_a.glb` … `letter_z.glb`)
- 10 shapes: cube, sphere, cone, cylinder, triangular prism, star, heart, oval,
  rectangle and diamond
- 11 reusable props: ball, treasure chest, coin, reward star, puzzle piece,
  tree, bush, rock, flower, cloud and platform
- 3 modular dioramas: playground island, animal habitat and learning island

Each asset is exported independently for on-demand loading. Editable source scenes
are written under `blender/output/learning_assets/<category>/`. The CI workflow
checks the expected count, non-empty files and GLB magic header, then uploads the
GLB and .blend files as the `kids-games-3d-assets` artifact.

These are procedural starter meshes. They still need visual inspection, Khronos
glTF validation, camera framing review, Flutter Scene load testing and real-device
performance review before release approval. The pipeline does not claim that
geometry, text readability or materials have passed those reviews.