"""Generate the Kids Games educational 3D asset library with Blender.

Creates individual GLB files and editable .blend source files for:
- Number tokens 0–20
- Alphabet tokens A–Z
- Core geometric shapes
- Reusable game props
- Three small modular diorama environments

Run from repository root:
  blender --background --python blender/scripts/create_learning_asset_library.py
"""
import bpy
import math
import os
import string

ROOT = os.path.abspath(os.environ.get(
    "GITHUB_WORKSPACE", os.path.join(os.path.dirname(__file__), "..", "..")
))
ASSET_ROOT = os.path.join(ROOT, "assets", "models")
SOURCE_ROOT = os.path.join(ROOT, "blender", "output", "learning_assets")

PALETTE = [
    (1.00, 0.65, 0.08, 1), (0.98, 0.25, 0.36, 1),
    (0.16, 0.57, 0.96, 1), (0.20, 0.76, 0.48, 1),
    (0.57, 0.34, 0.92, 1), (1.00, 0.82, 0.36, 1),
    (0.12, 0.76, 0.78, 1), (1.00, 0.43, 0.18, 1),
]
CREAM = (1.0, 0.92, 0.76, 1)
DARK = (0.12, 0.09, 0.15, 1)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in (bpy.data.meshes, bpy.data.curves, bpy.data.materials,
                       bpy.data.cameras, bpy.data.lights):
        for block in list(collection):
            if block.users == 0:
                collection.remove(block)


def material(name, color, roughness=0.38, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def assign(obj, mat):
    obj.data.materials.append(mat)
    return obj


def soften(obj, width=0.06):
    if width > 0:
        mod = obj.modifiers.new("Toy_Soft_Edges", "BEVEL")
        mod.width = width
        mod.segments = 3
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def cube(name, loc, scale, mat, bevel=0.06):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    soften(obj, min(bevel, min(scale) * 0.25))
    return assign(obj, mat)


def sphere(name, loc, scale, mat, segments=24):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments, ring_count=max(12, segments // 2), radius=1, location=loc
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    for face in obj.data.polygons:
        face.use_smooth = True
    return assign(obj, mat)


def cylinder(name, loc, radius, depth, mat, vertices=48):
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=vertices, radius=radius, depth=depth, location=loc
    )
    obj = bpy.context.object
    obj.name = name
    soften(obj, 0.025)
    return assign(obj, mat)


def cone(name, loc, radius, depth, mat, vertices=48):
    bpy.ops.mesh.primitive_cone_add(
        vertices=vertices, radius1=radius, radius2=0, depth=depth, location=loc
    )
    obj = bpy.context.object
    obj.name = name
    soften(obj, 0.025)
    return assign(obj, mat)


def text_token(label, mat):
    curve = bpy.data.curves.new("Token_Text", "FONT")
    curve.body = label
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    curve.size = 1.25 if len(label) == 1 else 0.95
    curve.extrude = 0.12
    curve.bevel_depth = 0.025
    curve.bevel_resolution = 3
    obj = bpy.data.objects.new("Token_" + label, curve)
    bpy.context.collection.objects.link(obj)
    obj.location.z = 0.12
    assign(obj, mat)
    cube("Token_Base", (0, 0, -0.16), (1.55, 1.45, 0.28), material("Base_" + label, PALETTE[(ord(label[0]) if label.isalpha() else int(label)) % len(PALETTE)]), 0.14)
    return obj


def heart_mesh(mat):
    pts = []
    for i in range(64):
        t = 2 * math.pi * i / 64
        x = 16 * math.sin(t) ** 3 / 18
        z = (13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)) / 18
        pts.append((x, -0.12, z))
    verts = pts + [(x, 0.12, z) for x, _, z in pts]
    n = len(pts)
    faces = [tuple(range(n)), tuple(range(n, 2*n))[::-1]]
    for i in range(n):
        j = (i + 1) % n
        faces.append((i, j, j+n, i+n))
    mesh = bpy.data.meshes.new("Heart_Mesh")
    mesh.from_pydata(verts, [], faces)
    obj = bpy.data.objects.new("Heart", mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, mat)
    return soften(obj, 0.035)


def star_mesh(mat):
    pts = []
    for i in range(10):
        a = math.pi / 2 + i * math.pi / 5
        r = 0.72 if i % 2 == 0 else 0.34
        pts.append((math.cos(a)*r, math.sin(a)*r))
    verts = [(x, -0.12, z) for x, z in pts] + [(x, 0.12, z) for x, z in pts]
    faces = [tuple(range(10)), tuple(range(10, 20))[::-1]]
    for i in range(10):
        j = (i + 1) % 10
        faces.append((i, j, j+10, i+10))
    mesh = bpy.data.meshes.new("Star_Mesh")
    mesh.from_pydata(verts, [], faces)
    obj = bpy.data.objects.new("Star", mesh)
    bpy.context.collection.objects.link(obj)
    assign(obj, mat)
    return soften(obj, 0.035)


def build_shape(shape, mat):
    if shape == "cube":
        cube("Shape_Cube", (0, 0, 0), (1.15, 1.15, 1.15), mat, 0.12)
    elif shape == "sphere":
        sphere("Shape_Sphere", (0, 0, 0), (0.68, 0.68, 0.68), mat)
    elif shape == "cone":
        cone("Shape_Cone", (0, 0, 0), 0.68, 1.35, mat)
    elif shape == "cylinder":
        cylinder("Shape_Cylinder", (0, 0, 0), 0.62, 1.2, mat)
    elif shape == "triangular_prism":
        bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=0.78, radius2=0.78, depth=0.45, location=(0,0,0), rotation=(0,0,math.pi/2))
        assign(bpy.context.object, mat)
    elif shape == "star":
        star_mesh(mat)
    elif shape == "heart":
        heart_mesh(mat)
    elif shape == "oval":
        sphere("Shape_Oval", (0,0,0), (0.52,0.72,0.42), mat)
    elif shape == "rectangle":
        cube("Shape_Rectangle", (0,0,0), (1.35,0.55,0.85), mat, 0.10)
    elif shape == "diamond":
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.72, radius2=0, depth=1.15, location=(0,0,0), rotation=(0,0,math.pi/4))
        assign(bpy.context.object, mat)


def build_prop(name, mats):
    main, accent, green = mats
    if name == "ball":
        sphere("Play_Ball", (0,0,0), (0.7,0.7,0.7), main)
        for z in (-0.28, 0.28):
            torus = bpy.ops.mesh.primitive_torus_add(major_radius=0.48, minor_radius=0.035, location=(0,0,z))
            assign(bpy.context.object, accent)
    elif name == "treasure_chest":
        cube("Chest_Base", (0,0,-0.12), (1.25,0.82,0.72), main, 0.12)
        cube("Chest_Band", (0,-0.43,-0.12), (0.16,0.04,0.72), accent, 0.02)
        cube("Chest_Lid", (0,0,0.34), (1.32,0.88,0.25), accent, 0.12)
    elif name == "coin":
        cylinder("Gold_Coin", (0,0,0), 0.58, 0.16, main)
        cylinder("Coin_Emboss", (0,-0.10,0), 0.34, 0.04, accent, 32)
    elif name == "reward_star":
        star_mesh(main)
        sphere("Star_Glint", (-0.22,-0.16,0.28), (0.08,0.03,0.08), CREAM)
    elif name == "puzzle_piece":
        cube("Puzzle_Square", (0,0,0), (0.9,0.28,0.9), main, 0.10)
        sphere("Puzzle_Knob", (0,-0.02,0.48), (0.2,0.18,0.2), main)
    elif name == "tree":
        cylinder("Tree_Trunk", (0,0,-0.35), 0.16, 0.9, accent, 16)
        sphere("Tree_Canopy", (0,0,0.35), (0.62,0.58,0.72), green)
        sphere("Tree_Canopy_Top", (0.24,0,0.72), (0.38,0.36,0.42), main)
    elif name == "bush":
        for x,z in [(-0.32,0),(0,0.12),(0.32,0)]:
            sphere("Bush_Leaf", (x,0,z), (0.42,0.38,0.38), green)
    elif name == "rock":
        sphere("Friendly_Rock", (0,0,0), (0.68,0.48,0.42), accent, 16)
    elif name == "flower":
        cylinder("Flower_Stem", (0,0,-0.28), 0.045, 0.65, green, 12)
        sphere("Flower_Centre", (0,0,0.12), (0.16,0.13,0.16), main)
        for i in range(5):
            a = i*2*math.pi/5
            sphere("Flower_Petal", (math.cos(a)*0.25,0,0.18+math.sin(a)*0.25), (0.18,0.12,0.18), accent)
    elif name == "cloud":
        for x,z,s in [(-0.35,0,(0.42,0.34,0.34)),(0,0.16,(0.52,0.38,0.42)),(0.38,0,(0.4,0.32,0.32))]:
            sphere("Cloud_Puff", (x,0,z), s, CREAM)
    elif name == "platform":
        cylinder("Floating_Platform", (0,0,-0.12), 1.0, 0.32, green, 64)
        cylinder("Platform_Top", (0,0,0.06), 0.88, 0.08, main, 64)


def build_environment(name, mats):
    main, accent, green = mats
    # A compact diorama with a round floating base and reusable toy props.
    cylinder("Island_Base", (0,0,-0.28), 2.25, 0.52, accent, 64)
    cylinder("Grass_Top", (0,0,0.0), 2.12, 0.20, green, 64)
    if name == "playground_island":
        cube("Playground_Slide", (-0.75,0,0.48), (0.45,0.55,1.1), main, 0.12)
        sphere("Playground_Ball", (0.8,-0.25,0.38), (0.32,0.32,0.32), accent)
        for x in (-1.3,1.3):
            sphere("Playground_Bush", (x,0.1,0.35), (0.42,0.38,0.42), green)
        cylinder("Playground_Tower", (0,0.5,0.55), 0.3, 1.0, main, 24)
    elif name == "animal_habitat":
        for x,y in [(-1.0,-0.6),(1.0,-0.5),(-0.8,0.9),(1.0,0.9)]:
            sphere("Habitat_Tree_Canopy", (x,y,0.55), (0.48,0.42,0.55), green)
            cylinder("Habitat_Tree_Trunk", (x,y,0.18), 0.10, 0.55, accent, 16)
        sphere("Habitat_Pond", (0,-0.4,0.16), (0.75,0.52,0.06), main)
    else:
        for i in range(5):
            x = -1.35 + i*0.68
            cube("Learning_Block", (x,0.1,0.35), (0.48,0.48,0.55), PALETTE[i % len(PALETTE)], 0.07)
        sphere("Learning_Cloud", (0,0.9,0.8), (0.65,0.35,0.3), CREAM)


def export_one(category, name, builder):
    clear_scene()
    palette_mats = [material(category + "_" + str(i), color) for i, color in enumerate(PALETTE)]
    builder(palette_mats)
    out_dir = os.path.join(ASSET_ROOT, category)
    src_dir = os.path.join(SOURCE_ROOT, category)
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(src_dir, exist_ok=True)
    # Save an editable source scene for every independently loadable asset.
    blend_path = os.path.join(src_dir, name + ".blend")
    glb_path = os.path.join(out_dir, name + ".glb")
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    bpy.ops.object.select_all(action="SELECT")
    bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
    bpy.ops.export_scene.gltf(
        filepath=glb_path, export_format="GLB", use_selection=True,
        export_materials="EXPORT", export_cameras=False, export_lights=False,
        export_animations=False,
    )
    if not os.path.isfile(glb_path) or os.path.getsize(glb_path) < 100:
        raise RuntimeError("Missing/invalid export: " + glb_path)
    print("EXPORTED", category, name, os.path.getsize(glb_path))


def main():
    jobs = []
    for n in range(21):
        label = str(n)
        jobs.append(("numbers", f"number_{n:02d}", lambda m, v=label: text_token(v, m[n % len(m)])))
    for letter in string.ascii_uppercase:
        jobs.append(("letters", f"letter_{letter.lower()}", lambda m, v=letter: text_token(v, m[ord(v) % len(m)])))
    for i, shape in enumerate(("cube","sphere","cone","cylinder","triangular_prism","star","heart","oval","rectangle","diamond")):
        jobs.append(("shapes", shape, lambda m, v=shape, i=i: build_shape(v, m[i % len(m)])))
    prop_names = ("ball","treasure_chest","coin","reward_star","puzzle_piece","tree","bush","rock","flower","cloud","platform")
    for i, prop in enumerate(prop_names):
        jobs.append(("props", prop, lambda m, v=prop, i=i: build_prop(v, [m[i % len(m)], m[(i+1)%len(m)], m[(i+2)%len(m)]])))
    for i, env in enumerate(("playground_island","animal_habitat","learning_island")):
        jobs.append(("environments", env, lambda m, v=env, i=i: build_environment(v, [m[i%len(m)],m[(i+1)%len(m)],m[(i+2)%len(m)]])))
    for category, name, builder in jobs:
        export_one(category, name, builder)
    print("LEARNING_ASSET_LIBRARY_COMPLETE", len(jobs))


if __name__ == "__main__":
    main()
