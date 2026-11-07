# Visual assets

All bundled assets must be original or properly licensed for commercial use. Keep the core experience available offline. Do not add BrightBuddies artwork.

## Current art direction

Kids Games uses a **premium 3D-toy illustration style** built as scalable SVG vectors. SVG is technically 2D, so the dimensional appearance is created with layered vector forms, multi-stop gradients, bevel-like rim strokes, soft offset shadow shapes, highlights, and rounded geometry.

The current upgraded assets are:
- `characters/fox_buddy.svg` — main fox mascot with teal scarf
- `characters/rabbit_buddy.svg` — rabbit buddy with mint outfit and pink inner ears
- `characters/panda_buddy.svg` — panda buddy with yellow hoodie
- `illustrations/adventure_island.svg` — floating island with castle, trees, rocks and waterfall
- `icons/app_icon.svg` — matching fox-face app-icon artwork

## Flutter rendering

- Use `flutter_svg` to render SVG assets.
- Keep IDs unique within each SVG file.
- Prefer gradients and vector-built shadows over SVG filter blur/drop-shadow because filter support can vary across renderers.
- Add `semanticsLabel` when placing characters in child-facing screens.
- Keep the source SVG as the master artwork. For Android launcher icons, convert the approved icon to the required PNG/adaptive-icon assets as a separate release step.

## True 3D assets

These are detailed **3D-style vector illustrations**, not rotatable 3D models. When a scene needs real perspective, lighting, animation or user-controlled rotation, create the model in Blender and export an optimized GLB/GLTF asset for a dedicated Flutter 3D rendering workflow. Do not describe an SVG as a real 3D mesh.

## Production checklist

- Preserve the same character proportions, face language, lighting direction and palette across new assets.
- Keep each character readable at small sizes.
- Use transparent backgrounds unless a full scene is required.
- Avoid text baked into illustrations.
- Keep SVG paths and gradients optimized for mobile rendering.
