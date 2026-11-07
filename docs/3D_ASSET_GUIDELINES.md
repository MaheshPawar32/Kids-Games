# 3D asset guidelines

## Source of truth

- Create and maintain genuine 3D assets in Blender.
- Commit editable `.blend` source files and small helper scripts under `blender/`.
- Export runtime assets as glTF 2.0 binary `.glb` under `assets/models/`.
- Do not use SVG/PNG renders as substitutes for required interactive 3D characters or objects.
- Do not commit zero-byte, empty, invalid or untested GLB files.

## Recommended directory layout

```
blender/
  characters/
  environments/
  animations/
  export_scripts/
assets/
  models/
    characters/
    animals/
    objects/
    numbers/
    letters/
    rewards/
    environments/
  textures/
  materials/
  scenes/
  images/
  icons/
  audio/
    music/
    effects/
    voice/
  fonts/
``

## Naming

- Blender source: `<asset_id>_source.blend`
- Exported model: `<asset_id>.glb`
- Armature: `<asset_id>_Armature`
- Animation clips: `Idle`, `Blink`, `Walk`, `Run`, `Jump`, `Celebrate`
- Nodes and materials: stable PascalCase identifiers without spaces.
- Asset IDs: lower_snake_case and stable after release.

## Character modelling and rigging

- Use friendly, rounded silhouettes with clear face readability at phone sizes.
- Keep joints, eyes, mouth and ears deforming cleanly.
- Apply transforms and set a consistent origin, scale and forward axis before export.
- Use a consistent skeleton strategy across buddy animals where practical.
- Keep animation loops seamless; remove unused actions and objects before export.
- Bake only when needed by the target runtime; preserve named clips.

## Materials, lighting and textures

- Use glTF-compatible PBR materials.
- Prefer few materials and shared texture atlases.
- Pack/resize textures for phone memory budgets; avoid unnecessarily large 4K maps.
- Use consistent roughness/specular response so characters look like one product family.
- Use environment image-based lighting plus controlled scene lights in Flutter Scene; validate on device.
- Keep lighting/shadow quality configurable for weaker Android GPUs.

## Export and validation

1. Save the editable source file.
2. Run the project's Blender export script.
3. Export glTF 2.0 binary with required animations and embedded textures when practical.
4. Run glTF validation and inspect warnings.
5. Import with the Flutter Scene build-time asset pipeline.
6. Load in an isolated scene, inspect framing/materials/animation and dispose resources.
7. Record source/export hashes and licence details in ASSET_MANIFEST.md.

## Mobile budget

No universal polygon/texture budget is assumed. Set per-asset budgets after first Android prototype measurements. Record triangles, material count, texture dimensions and approximate GPU memory in the manifest. Prefer instancing, atlases, LODs and object reuse over duplicating high-poly meshes.

## Licensing

Every third-party texture, HDRI, sound, font, model or Blender add-on must have a recorded source and commercial-use licence. Do not assume a free download permits bundling in a commercial Android app.
