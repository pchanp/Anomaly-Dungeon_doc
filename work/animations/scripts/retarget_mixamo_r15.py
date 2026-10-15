"""Mixamo -> standard R15 rotation retarget prototype. Run inside Blender."""
import bpy
import math
from mathutils import Matrix, Vector

# Change these settings for each scene. Bone names are not changed.
SOURCE = 'Armature.001'
TARGET = 'Armature'
OUTPUT_NAME = 'R15_HookPunch_Retarget'
FRAME_RANGE = None  # None: source Action range, or (start, end)
ROOT_MODE = 'IN_PLACE'  # IN_PLACE: vertical hip movement; KEEP: XYZ; NONE: fixed hips
TRANSLATION_SCALE = None  # None: estimate from rest-pose leg length

MAPPING = {'LowerTorso': 'Hips', 'UpperTorso': 'Spine2', 'Head': 'Head'}
for side in ('Left', 'Right'):
    for target, source in [('UpperArm', 'Arm'), ('LowerArm', 'ForeArm'),
                           ('Hand', 'Hand'), ('UpperLeg', 'UpLeg'),
                           ('LowerLeg', 'Leg'), ('Foot', 'Foot')]:
        MAPPING[side + target] = side + source


def run():
    src, template = bpy.data.objects.get(SOURCE), bpy.data.objects.get(TARGET)
    if not src or not template or src.type != 'ARMATURE' or template.type != 'ARMATURE':
        raise RuntimeError('SOURCE and TARGET must name different Armature objects')
    if src == template:
        raise RuntimeError('Source and target cannot be the same')
    if bpy.context.mode != 'OBJECT':
        raise RuntimeError('Switch to Object Mode before running')
    if not src.animation_data or not src.animation_data.action:
        raise RuntimeError('Source has no active Action')
    if ROOT_MODE not in ('IN_PLACE', 'KEEP', 'NONE'):
        raise ValueError('Invalid ROOT_MODE')
    if template.constraints or template.animation_data or any(p.constraints for p in template.pose.bones):
        raise RuntimeError('Target must be a clean template without animation or constraints')
    source_names = {}
    for name in src.data.bones.keys():
        short = name.split(':')[-1]
        if short in source_names:
            raise RuntimeError('Ambiguous source bone: ' + short)
        source_names[short] = name
    for target, source in MAPPING.items():
        if target not in template.data.bones or source not in source_names:
            raise RuntimeError('Missing bone mapping: ' + target + ' -> ' + source)
    if any(b.use_inherit_rotation is False for b in template.data.bones):
        raise RuntimeError('Nonstandard target inheritance is unsupported')
    action = src.animation_data.action
    start, end = FRAME_RANGE or (math.floor(action.frame_range[0]), math.ceil(action.frame_range[1]))
    start, end = int(start), int(end)
    if end < start:
        raise ValueError('Invalid frame range')
    original_frame = bpy.context.scene.frame_current
    original_active = bpy.context.view_layer.objects.active
    original_selection = list(bpy.context.selected_objects)
    bpy.context.view_layer.update()
    # Remove object scale from orientation math. All deltas use world axes.
    sw = src.matrix_world.copy()
    tw = template.matrix_world.copy()
    tr = tw.to_quaternion().to_matrix()
    source_rest = {t: (sw @ src.data.bones[source_names[s]].matrix_local).to_quaternion().to_matrix()
                   for t, s in MAPPING.items()}
    target_rest = {b.name: (tw @ b.matrix_local).to_quaternion().to_matrix()
                   for b in template.data.bones}
    def leg_length(obj, names):
        return sum(((obj.matrix_world @ obj.data.bones[n].tail_local) -
                    (obj.matrix_world @ obj.data.bones[n].head_local)).length for n in names)
    scale = TRANSLATION_SCALE
    if scale is None:
        scale = leg_length(template, ['LeftUpperLeg', 'LeftLowerLeg']) / leg_length(
            src, [source_names['LeftUpLeg'], source_names['LeftLeg']])
    hip_rest = sw @ src.data.bones[source_names['Hips']].head_local
    # Duplicate skeleton only. Keep original mesh/attachments and target untouched.
    out = template.copy()
    out.data = template.data.copy()
    out.animation_data_clear()
    out.name = OUTPUT_NAME
    bpy.context.collection.objects.link(out)
    out.show_in_front = True
    out.display_type = 'WIRE'
    for pb in out.pose.bones:
        pb.matrix_basis = Matrix.Identity(4)
        pb.rotation_mode = 'QUATERNION'
    out.animation_data_create()
    out.animation_data.action = bpy.data.actions.new(out.name + '_Action')
    result_action = out.animation_data.action
    previous = {}
    try:
        for frame in range(start, end + 1):
            bpy.context.scene.frame_set(frame)
            evaluated = src.evaluated_get(bpy.context.evaluated_depsgraph_get())
            desired = dict(target_rest)
            for target, source in MAPPING.items():
                pose_world = (evaluated.matrix_world @ evaluated.pose.bones[source_names[source]].matrix).to_quaternion().to_matrix()
                desired[target] = pose_world @ source_rest[target].inverted() @ target_rest[target]
            for bone in out.data.bones:
                if bone.name not in MAPPING:
                    continue
                pb = out.pose.bones[bone.name]
                parent = bone.parent
                rest_local = bone.matrix_local.to_quaternion().to_matrix()
                if parent:
                    rest_relative = parent.matrix_local.to_quaternion().to_matrix().inverted() @ rest_local
                    basis = rest_relative.inverted() @ desired[parent.name].inverted() @ desired[bone.name]
                else:
                    basis = rest_local.inverted() @ tr.inverted() @ desired[bone.name]
                q = basis.to_quaternion().normalized()
                if bone.name in previous and q.dot(previous[bone.name]) < 0:
                    q.negate()
                previous[bone.name] = q.copy()
                pb.rotation_quaternion = q
                pb.keyframe_insert('rotation_quaternion', frame=frame, group=bone.name)
            hip = out.pose.bones['LowerTorso']
            delta = ((evaluated.matrix_world @ evaluated.pose.bones[source_names['Hips']].head) - hip_rest) * scale
            if ROOT_MODE == 'NONE':
                delta = Vector((0, 0, 0))
            elif ROOT_MODE == 'IN_PLACE':
                delta.x = delta.y = 0
            # location is expressed in hip rest-local space; preserve template scale.
            hip.location = (tw @ out.data.bones['LowerTorso'].matrix_local).to_3x3().inverted() @ delta
            hip.keyframe_insert('location', frame=frame, group='LowerTorso')
        # Blender 4.4+ layered Action API, with legacy fallback.
        if hasattr(result_action, 'layers') and len(result_action.layers):
            curves = [fc for layer in result_action.layers for strip in layer.strips
                      for bag in strip.channelbags for fc in bag.fcurves]
        else:
            curves = list(result_action.fcurves)
        for fc in curves:
            for key in fc.keyframe_points:
                key.interpolation = 'LINEAR'
        out['retarget_source'] = src.name
        out['retarget_root_mode'] = ROOT_MODE
        out['retarget_translation_scale'] = float(scale)
        out['retarget_status'] = 'Draft - visual and Roblox validation required'
    except Exception:
        bpy.data.objects.remove(out, do_unlink=True)
        if result_action.users == 0:
            bpy.data.actions.remove(result_action)
        raise
    finally:
        bpy.context.scene.frame_set(original_frame)
        for obj in bpy.context.selected_objects:
            obj.select_set(False)
        for obj in original_selection:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = original_active
    bpy.context.scene.frame_start = start
    bpy.context.scene.frame_end = end
    print('RETARGET COMPLETE:', out.name, result_action.name, start, end, 'scale:', scale)
    print('Skeleton-only preview. No mesh copied, no file saved, no FBX exported.')
    return out


if __name__ == '__main__':
    run()
