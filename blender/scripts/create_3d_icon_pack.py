"""Generate reusable toy-style 3D UI icons for Kids Games.

Run:
  blender --background --python blender/scripts/create_3d_icon_pack.py

Exports one optimized GLB per icon into assets/models/icons/.
These are genuine low-poly beveled meshes with PBR materials, not SVG artwork.
"""
import bpy
import math
import os

ROOT = os.path.abspath(os.environ.get(
    "GITHUB_WORKSPACE",
    os.path.join(os.path.dirname(__file__), "..", ".."),
))
OUT_DIR = os.path.join(ROOT, "assets", "models", "icons")


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials):
        for block in list(datablocks):
            if block.users == 0:
                datablocks.remove(block)


def mat(name, color, roughness=0.34, metallic=0.0):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    bsdf = material.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return material


def assign(obj, material):
    obj.data.materials.append(material)
    return obj


def bevel(obj, width=0.06):
    mod = obj.modifiers.new("Soft_Toy_Edges", "BEVEL")
    mod.width = width
    mod.segments = 3
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def cube(name, location, scale, material, radius=0.06):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if radius:
        bevel(obj, min(radius, min(scale) * 0.35))
    return assign(obj, material)


def sphere(name, location, scale, material):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=24, ring_count=16, radius=1, location=location
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for face in obj.data.polygons:
        face.use_smooth = True
    return assign(obj, material)


def cylinder(name, location, radius, depth, material, rotation=(math.pi / 2, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=48, radius=radius, depth=depth,
        location=location, rotation=rotation
    )
    obj = bpy.context.object
    obj.name = name
    bevel(obj, 0.025)
    return assign(obj, material)


def torus(name, location, major, minor, material, rotation=(math.pi / 2, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(
        major_segments=36, minor_segments=12,
        location=location, major_radius=major, minor_radius=minor,
        rotation=rotation
    )
    obj = bpy.context.object
    obj.name = name
    for face in obj.data.polygons:
        face.use_smooth = True
    return assign(obj, material)


def prism_xz(name, points, depth, material, y=0.0):
    """Create a closed polygon prism whose visible face points toward -Y.

    [y] offsets the prism along the viewing axis. Details placed on a
    thicker base (a disc or coin) must sit in front of it (negative y),
    otherwise the base hides them completely.
    """
    count = len(points)
    vertices = [(x, y - depth / 2, z) for x, z in points]
    vertices += [(x, y + depth / 2, z) for x, z in points]
    faces = [tuple(range(count)), tuple(range(count, count * 2))[::-1]]
    for i in range(count):
        j = (i + 1) % count
        faces.append((i, j, j + count, i + count))
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    bevel(obj, 0.025)
    return obj


def star_points(outer=0.62, inner=0.29, count=5, center_z=0.0):
    points = []
    for i in range(count * 2):
        angle = math.pi / 2 + i * math.pi / count
        radius = outer if i % 2 == 0 else inner
        points.append((math.cos(angle) * radius,
                       center_z + math.sin(angle) * radius))
    return points


def build_star(m):
    prism_xz("Star_Body", star_points(), 0.22, m["yellow"])
    sphere("Star_Glint", (-0.20, -0.135, 0.27), (0.075, 0.025, 0.075), m["cream"])


def build_trophy(m):
    cylinder("Trophy_Base", (0, 0, -0.48), 0.34, 0.16, m["blue"], rotation=(0, 0, 0))
    cylinder("Trophy_Stem", (0, 0, -0.20), 0.12, 0.45, m["gold"], rotation=(0, 0, 0))
    bpy.ops.mesh.primitive_cone_add(
        vertices=48, radius1=0.48, radius2=0.28, depth=0.62,
        location=(0, 0, 0.28)
    )
    cup = bpy.context.object
    cup.name = "Trophy_Cup"
    bevel(cup, 0.035)
    assign(cup, m["gold"])
    torus("Trophy_Left_Handle", (-0.43, 0, 0.35), 0.22, 0.065, m["gold"],
          rotation=(math.pi / 2, 0, 0))
    torus("Trophy_Right_Handle", (0.43, 0, 0.35), 0.22, 0.065, m["gold"],
          rotation=(math.pi / 2, 0, 0))


def build_gift(m):
    cube("Gift_Box", (0, 0, -0.08), (0.92, 0.62, 0.78), m["pink"], 0.09)
    cube("Gift_Ribbon_Vertical", (0, -0.326, -0.08), (0.16, 0.035, 0.78), m["cream"], 0.025)
    cube("Gift_Lid", (0, 0, 0.39), (1.05, 0.70, 0.20), m["purple"], 0.055)
    cube("Gift_Ribbon_Lid", (0, -0.36, 0.39), (0.16, 0.04, 0.20), m["cream"], 0.02)
    torus("Gift_Bow_Left", (-0.17, -0.05, 0.60), 0.16, 0.065, m["yellow"],
          rotation=(math.pi / 2, 0, 0))
    torus("Gift_Bow_Right", (0.17, -0.05, 0.60), 0.16, 0.065, m["yellow"],
          rotation=(math.pi / 2, 0, 0))
    sphere("Gift_Bow_Knot", (0, -0.12, 0.60), (0.10, 0.09, 0.10), m["yellow"])


def build_heart(m):
    points = []
    for i in range(48):
        t = 2 * math.pi * i / 48
        x = 16 * math.sin(t) ** 3 / 19
        z = (13 * math.cos(t) - 5 * math.cos(2*t)
             - 2 * math.cos(3*t) - math.cos(4*t)) / 19
        points.append((x * 0.72, z * 0.72))
    # Center the mathematical heart and make its point sit below the lobes.
    z_values = [p[1] for p in points]
    offset = (max(z_values) + min(z_values)) / 2
    points = [(x, z - offset) for x, z in points]
    prism_xz("Heart_Body", points, 0.22, m["pink"])
    sphere("Heart_Highlight", (-0.22, -0.14, 0.22), (0.08, 0.025, 0.045), m["cream"])


def build_home(m):
    cube("House_Body", (0, 0, -0.12), (0.94, 0.62, 0.86), m["blue"], 0.06)
    roof = prism_xz("House_Roof", [(-0.62, 0.22), (0, 0.86), (0.62, 0.22)], 0.72, m["coral"])
    cube("House_Door", (0, -0.326, -0.35), (0.25, 0.04, 0.45), m["gold"], 0.045)
    cube("House_Window_Left", (-0.28, -0.33, 0.02), (0.19, 0.04, 0.19), m["cream"], 0.025)
    cube("House_Window_Right", (0.28, -0.33, 0.02), (0.19, 0.04, 0.19), m["cream"], 0.025)


def build_book(m):
    """A closed storybook standing upright, cover facing the viewer."""
    cube("Book_Front_Cover", (0, -0.17, 0), (0.80, 0.07, 1.00), m["blue"], 0.03)
    cube("Book_Back_Cover", (0, 0.17, 0), (0.80, 0.07, 1.00), m["blue"], 0.03)
    # Pages are inset so their cream edge shows on three sides.
    cube("Book_Pages", (0.03, 0, 0), (0.72, 0.28, 0.92), m["cream"], 0.02)
    cube("Book_Spine", (-0.40, 0, 0), (0.09, 0.42, 1.00), m["purple"], 0.035)
    cube("Book_Title_Label", (0.04, -0.215, 0.18), (0.50, 0.03, 0.20), m["cream"], 0.012)
    prism_xz("Book_Cover_Star", star_points(0.15, 0.07, 5, -0.18), 0.04,
             m["yellow"], y=-0.215)


def build_gear(m):
    cylinder("Gear_Core", (0, 0, 0), 0.38, 0.20, m["blue"])
    cylinder("Gear_Hub", (0, -0.13, 0), 0.16, 0.10, m["yellow"])
    for i in range(8):
        angle = 2 * math.pi * i / 8
        x, z = math.cos(angle) * 0.46, math.sin(angle) * 0.46
        tooth = cube("Gear_Tooth", (x, 0, z), (0.20, 0.22, 0.20), m["blue"], 0.035)
        tooth.rotation_euler[1] = -angle


def build_speaker(m):
    cube("Speaker_Case", (0, 0, 0), (0.76, 0.38, 0.86), m["purple"], 0.10)
    cylinder("Speaker_Cone", (0, -0.23, 0), 0.27, 0.13, m["cream"])
    cylinder("Speaker_Cone_Centre", (0, -0.31, 0), 0.12, 0.08, m["blue"])
    # Three rounded sound-wave rings on the right side.
    for radius in (0.36, 0.52, 0.68):
        arc = torus("Sound_Wave", (0.40 + radius * 0.30, -0.02, 0),
                    radius * 0.55, 0.035, m["yellow"])
        arc.scale.x = 0.72


def build_play(m):
    cylinder("Play_Disc", (0, 0, 0), 0.62, 0.22, m["green"])
    prism_xz("Play_Triangle", [(-0.18, -0.28), (0.34, 0), (-0.18, 0.28)],
             0.10, m["cream"], y=-0.15)


def build_pause(m):
    cylinder("Pause_Disc", (0, 0, 0), 0.62, 0.22, m["blue"])
    cube("Pause_Left_Bar", (-0.17, -0.18, 0), (0.14, 0.10, 0.52), m["cream"], 0.035)
    cube("Pause_Right_Bar", (0.17, -0.18, 0), (0.14, 0.10, 0.52), m["cream"], 0.035)


def build_lock(m):
    cube("Lock_Body", (0, 0, -0.20), (0.76, 0.28, 0.60), m["gold"], 0.10)
    torus("Lock_Shackle", (0, 0, 0.18), 0.25, 0.075, m["blue"],
          rotation=(math.pi / 2, 0, 0))
    sphere("Lock_Keyhole", (0, -0.17, -0.20), (0.075, 0.035, 0.11), m["cream"])


def build_medal(m):
    prism_xz("Medal_Ribbon_Left", [(-0.32, 0.68), (-0.05, 0.68), (-0.12, 0.20), (-0.36, 0.05)], 0.10, m["blue"])
    prism_xz("Medal_Ribbon_Right", [(0.05, 0.68), (0.32, 0.68), (0.36, 0.05), (0.12, 0.20)], 0.10, m["coral"])
    cylinder("Medal_Main", (0, 0, -0.10), 0.40, 0.18, m["gold"])
    prism_xz("Medal_Star", star_points(0.23, 0.11, 5, -0.10), 0.10,
             m["cream"], y=-0.13)


def puzzle_outline(half=0.38, neck=0.10, steps=14):
    """Classic jigsaw piece: tabs on top and right, a blank on the left."""

    def arc(cx, cz, start, end):
        radius = math.hypot(neck, neck)
        return [
            (cx + math.cos(a) * radius, cz + math.sin(a) * radius)
            for a in (start + (end - start) * i / steps for i in range(steps + 1))
        ]

    s, d = half, neck
    points = [(-s, -s), (s, -s)]
    # Right edge (upwards): tab pointing out (+x).
    points += arc(s + d, 0, math.radians(-135), math.radians(135))
    points.append((s, s))
    # Top edge (leftwards): tab pointing up (+z).
    points += arc(0, s + d, math.radians(-45), math.radians(225))
    points.append((-s, s))
    # Left edge (downwards): blank cut inwards (+x).
    points += arc(-s + d, 0, math.radians(135), math.radians(-135))
    return points


def build_puzzle(m):
    prism_xz("Puzzle_Piece", puzzle_outline(), 0.24, m["green"])
    cylinder("Puzzle_Shine", (-0.05, -0.13, 0.05), 0.10, 0.04, m["cream"])


BUILDERS = {
    "star": build_star,
    "trophy": build_trophy,
    "gift": build_gift,
    "heart": build_heart,
    "home": build_home,
    "book": build_book,
    "settings": build_gear,
    "sound": build_speaker,
    "play": build_play,
    "pause": build_pause,
    "lock": build_lock,
    "medal": build_medal,
    "puzzle_piece": build_puzzle,
}

PALETTE = {
    "yellow": (1.00, 0.66, 0.08),
    "gold": (1.00, 0.52, 0.08),
    "cream": (1.00, 0.91, 0.70),
    "pink": (0.96, 0.22, 0.40),
    "purple": (0.48, 0.28, 0.90),
    "blue": (0.12, 0.54, 0.92),
    "green": (0.16, 0.72, 0.48),
    "coral": (0.98, 0.30, 0.22),
}


def export_icon(icon_id, builder):
    clear_scene()
    materials = {
        key: mat("Toy_" + key.title(), value)
        for key, value in PALETTE.items()
    }
    builder(materials)
    bpy.ops.object.select_all(action="SELECT")
    bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
    output = os.path.join(OUT_DIR, icon_id + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=output,
        export_format="GLB",
        use_selection=True,
        export_animations=False,
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=False,
    )
    if not os.path.isfile(output) or os.path.getsize(output) < 100:
        raise RuntimeError("GLB export missing or unexpectedly small: " + output)
    print("EXPORTED", icon_id, os.path.getsize(output), "bytes")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for icon_id, builder in BUILDERS.items():
        export_icon(icon_id, builder)
    print("3D icon pack complete:", len(BUILDERS), "GLB files")


if __name__ == "__main__":
    main()
