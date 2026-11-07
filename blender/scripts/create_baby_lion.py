"""Generate the Kids Games stylized Baby Lion starter model.

Run with Blender 4.2+:
  blender --background --python blender/scripts/create_baby_lion.py

Creates:
  blender/output/baby_lion.blend
  assets/models/characters/baby_lion.glb

This is a starter production asset, not yet approved for release. Review topology,
materials, rigging and exported animation clips in Blender and Flutter Scene.
"""
import bpy
import math
import os
from mathutils import Vector

ROOT = os.path.abspath(os.environ.get("GITHUB_WORKSPACE", os.path.join(os.path.dirname(__file__), "..", "..")))
BLEND_OUT = os.path.join(ROOT, "blender", "output", "baby_lion.blend")
GLB_OUT = os.path.join(ROOT, "assets", "models", "characters", "baby_lion.glb")


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials,
                       bpy.data.armatures, bpy.data.actions):
        for block in list(datablocks):
            if block.users == 0:
                datablocks.remove(block)


def material(name, color, roughness=0.38, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def sphere(name, location, scale, mat, bone, segments=24, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(
        segments=segments, ring_count=rings, radius=1, location=location
    )
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    obj["rig_bone"] = bone
    return obj


def make_armature():
    arm_data = bpy.data.armatures.new("BabyLion_Rig")
    arm = bpy.data.objects.new("BabyLion_Rig", arm_data)
    bpy.context.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    arm.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bones = {
        "root": ((0, 0, 0.15), (0, 0, 1.0), None),
        "body": ((0, 0, 1.0), (0, 0, 2.0), "root"),
        "head": ((0, 0, 2.0), (0, 0, 2.9), "body"),
        "tail": ((0, 0.45, 1.15), (0, 0.9, 1.4), "body"),
        "front_left": ((-0.42, -0.18, 0.95), (-0.48, -0.18, 0.25), "body"),
        "front_right": ((0.42, -0.18, 0.95), (0.48, -0.18, 0.25), "body"),
        "back_left": ((-0.38, 0.35, 0.95), (-0.42, 0.35, 0.25), "body"),
        "back_right": ((0.38, 0.35, 0.95), (0.42, 0.35, 0.25), "body"),
    }
    for name, (head, tail, parent) in bones.items():
        bone = arm_data.edit_bones.new(name)
        bone.head = head
        bone.tail = tail
        if parent:
            bone.parent = arm_data.edit_bones[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    arm.select_set(False)
    return arm


def attach_to_bone(obj, arm, bone_name):
    obj.parent = arm
    obj.parent_type = "BONE"
    obj.parent_bone = bone_name
    obj.matrix_parent_inverse = arm.matrix_world.inverted()


def animate(arm, action_name, keys):
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="POSE")
    for frame, bone_name, rotation in keys:
        pose_bone = arm.pose.bones[bone_name]
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = rotation
        pose_bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone_name)
    bpy.ops.object.mode_set(mode="OBJECT")
    action = arm.animation_data.action
    action.name = action_name
    action["clip_name"] = action_name
    # Push each action to its own NLA track so the glTF exporter can include clips.
    track = arm.animation_data.nla_tracks.new()
    track.name = action_name
    strip = track.strips.new(action_name, 1, action)
    strip.action_frame_start = action.frame_range[0]
    strip.action_frame_end = action.frame_range[1]
    arm.animation_data.action = None


def build():
    clear_scene()
    os.makedirs(os.path.dirname(BLEND_OUT), exist_ok=True)
    os.makedirs(os.path.dirname(GLB_OUT), exist_ok=True)

    gold = material("Lion_Golden_Fur", (0.95, 0.48, 0.08), 0.42)
    mane = material("Mane_Warm_Amber", (0.72, 0.22, 0.035), 0.48)
    cream = material("Muzzle_Cream", (1.0, 0.78, 0.48), 0.52)
    dark = material("Nose_Eyes_Paws", (0.075, 0.035, 0.025), 0.3)
    inner_ear = material("Ear_Inner_Coral", (0.95, 0.28, 0.22), 0.48)
    white = material("Eye_Glint", (1.0, 0.98, 0.88), 0.2)

    arm = make_armature()
    parts = []
    # Body and head are intentionally chunky, toy-like forms.
    parts.append(sphere("Body", (0, 0.08, 1.38), (0.68, 0.56, 0.72), gold, "body"))
    parts.append(sphere("Belly", (0, -0.43, 1.32), (0.43, 0.18, 0.48), cream, "body"))
    parts.append(sphere("Mane_Main", (0, -0.02, 2.18), (0.82, 0.58, 0.84), mane, "head", 32, 20))
    parts.append(sphere("Head", (0, -0.22, 2.28), (0.62, 0.48, 0.62), gold, "head", 32, 20))
    parts.append(sphere("Muzzle_Left", (-0.18, -0.65, 2.08), (0.27, 0.2, 0.19), cream, "head"))
    parts.append(sphere("Muzzle_Right", (0.18, -0.65, 2.08), (0.27, 0.2, 0.19), cream, "head"))
    parts.append(sphere("Nose", (0, -0.83, 2.18), (0.13, 0.09, 0.1), dark, "head"))
    for x in (-0.24, 0.24):
        parts.append(sphere("Eye", (x, -0.63, 2.42), (0.075, 0.055, 0.095), dark, "head", 20, 12))
        parts.append(sphere("Eye_Highlight", (x - 0.018, -0.681, 2.46), (0.022, 0.014, 0.026), white, "head", 12, 8))
    for x in (-0.42, 0.42):
        parts.append(sphere("Ear", (x, -0.16, 2.72), (0.22, 0.16, 0.25), gold, "head"))
        parts.append(sphere("Ear_Inner", (x, -0.30, 2.73), (0.12, 0.045, 0.14), inner_ear, "head"))
    # Four short legs and oversized paws.
    for x, y, bone in [
        (-0.43, -0.18, "front_left"), (0.43, -0.18, "front_right"),
        (-0.4, 0.38, "back_left"), (0.4, 0.38, "back_right")
    ]:
        parts.append(sphere("Leg", (x, y, 0.78), (0.2, 0.23, 0.48), gold, bone))
        parts.append(sphere("Paw", (x, y - 0.08, 0.32), (0.25, 0.28, 0.18), cream, bone))
    # Tail with a separate dark tuft.
    parts.append(sphere("Tail", (0, 0.58, 1.38), (0.13, 0.42, 0.13), gold, "tail"))
    parts.append(sphere("Tail_Tuft", (0, 0.95, 1.52), (0.19, 0.2, 0.2), mane, "tail"))

    for obj in parts:
        attach_to_bone(obj, arm, obj["rig_bone"])

    # Friendly studio lighting and camera for the editable Blender source.
    bpy.ops.object.camera_add(location=(4.2, -7.5, 3.6))
    camera = bpy.context.object
    camera.name = "BabyLion_Preview_Camera"
    direction = Vector((0, 0, 1.55)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.lens = 52
    bpy.context.scene.camera = camera

    bpy.ops.object.light_add(type="AREA", location=(1.5, -4.0, 5.5))
    key = bpy.context.object
    key.name = "Softbox_Key"
    key.data.energy = 480
    key.data.shape = "DISK"
    key.data.size = 4.0
    key.rotation_euler = (math.radians(25), 0, math.radians(18))
    bpy.ops.object.light_add(type="AREA", location=(-3.0, 1.5, 3.5))
    fill = bpy.context.object
    fill.name = "Softbox_Fill"
    fill.data.energy = 220
    fill.data.size = 3.0

    # Two starter clips. Limb/head motion is bone-driven and intentionally subtle.
    animate(arm, "Idle", [
        (1, "body", (0, 0, 0)), (18, "body", (0.025, 0, 0)),
        (36, "body", (0, 0, 0)), (1, "head", (0, 0, 0)),
        (18, "head", (0, 0.025, 0)), (36, "head", (0, 0, 0)),
    ])
    animate(arm, "Celebrate", [
        (1, "body", (0, 0, 0)), (8, "body", (-0.12, 0, 0)),
        (16, "body", (0.08, 0, 0)), (24, "body", (0, 0, 0)),
        (1, "front_left", (0, 0, 0)), (8, "front_left", (-0.65, 0, 0)),
        (16, "front_left", (-0.2, 0, 0)), (24, "front_left", (0, 0, 0)),
        (1, "front_right", (0, 0, 0)), (8, "front_right", (-0.65, 0, 0)),
        (16, "front_right", (-0.2, 0, 0)), (24, "front_right", (0, 0, 0)),
    ])

    scene = bpy.context.scene
    # Blender 4.0 (Ubuntu CI) uses BLENDER_EEVEE; newer releases use EEVEE_NEXT.
    engine_items = {item.identifier for item in scene.render.bl_rna.properties["engine"].enum_items}
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engine_items else "BLENDER_EEVEE"
    scene.render.resolution_x = 900
    scene.render.resolution_y = 900
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.world.color = (0.12, 0.12, 0.12)
    scene.frame_start = 1
    scene.frame_end = 36

    # Save editable source, then export the character hierarchy and its NLA clips.
    bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    for obj in parts:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.export_scene.gltf(
        filepath=GLB_OUT,
        export_format="GLB",
        use_selection=True,
        export_animations=True,
        export_nla_strips=True,
        export_skins=True,
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=False,
    )
    print("Baby Lion source saved:", BLEND_OUT)
    print("Baby Lion GLB exported:", GLB_OUT)
    for output_path in (BLEND_OUT, GLB_OUT):
        if not os.path.isfile(output_path) or os.path.getsize(output_path) == 0:
            raise RuntimeError(f"Expected generated asset is missing or empty: {output_path}")
        print(f"Verified output: {output_path} ({os.path.getsize(output_path)} bytes)")
    print("Review the model and verify both clips before marking the asset complete.")


if __name__ == "__main__":
    build()
