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
