"""Stored Mixamo -> official R15 workflow, Blender 5.2.1.
See README.md. No implicit save/export; paths are opt-in and never overwritten.
Bone rest directions MUST use tail_local-head_local (Bone.vector is parent-relative).
"""
import argparse
import json
import math
import sys
from pathlib import Path
import bpy
from mathutils import Matrix, Vector


def run(source='Armature.001', target='Armature', action_name='Mixamo_R15_Baked',
        root_mode='KEEP', frame_range=None, blend_path=None, fbx_path=None, report_path=None):
    if bpy.context.mode != 'OBJECT':
        raise ValueError('Object Mode required')
    if source == target:
        raise ValueError('Source and target must differ')
    if root_mode not in ('KEEP','IN_PLACE','NONE'):
        raise ValueError('Invalid root mode')
    for path in (blend_path, fbx_path, report_path):
        if path and Path(path).exists():
            raise FileExistsError(str(path))
        if path:
            Path(path).parent.mkdir(parents=True, exist_ok=True)
    for name in (source,target):
        obj = bpy.data.objects.get(name)
        if not obj or obj.type != 'ARMATURE' or obj.parent or obj.constraints:
            raise ValueError('Unparented, unconstrained Armature required: ' + name)
        if any(s <= 0 for s in obj.scale) or max(obj.scale)-min(obj.scale) > 1e-6:
            raise ValueError('Positive uniform scale required: ' + name)
        if obj.animation_data and (obj.animation_data.drivers or any(not t.mute for t in obj.animation_data.nla_tracks)):
            raise ValueError('Active NLA/drivers unsupported: ' + name)
    src_check = bpy.data.objects[source]
    if not src_check.animation_data or not src_check.animation_data.action:
        raise ValueError('Source has no active Action')
    source_curves = [fc for layer in src_check.animation_data.action.layers for strip in layer.strips for bag in strip.channelbags for fc in bag.fcurves]
    if any(not fc.data_path.startswith('pose.bones[') for fc in source_curves):
        raise ValueError('Object animation unsupported; bake to bones first')
    target_check = bpy.data.objects[target]
    if any(not b.use_inherit_rotation or b.inherit_scale != 'FULL' for b in target_check.data.bones):
        raise ValueError('Nonstandard inheritance unsupported')
    if bpy.data.actions.get(action_name):
        raise ValueError('Action name already exists; choose a new version')
    src = bpy.data.objects[source]
    dst = bpy.data.objects[target]
    scene = bpy.context.scene
    previous_action = dst.animation_data.action if dst.animation_data else None
    if previous_action:
        previous_action.use_fake_user = True
    assert not any(pb.constraints for pb in dst.pose.bones), 'Target has constraints'
    mapping = {'LowerTorso':'Hips','UpperTorso':'Spine2','Head':'Head'}
    for side in ('Left','Right'):
        for target, source in [('UpperArm','Arm'),('LowerArm','ForeArm'),('Hand','Hand'),('UpperLeg','UpLeg'),('LowerLeg','Leg'),('Foot','Foot')]:
            mapping[side+target] = side+source
    source_names = {}
    for bone in src.data.bones:
        short = bone.name.rsplit(':', 1)[-1]
        if short in source_names:
            raise ValueError('Ambiguous Source bone: ' + short)
        source_names[short] = bone.name
    mapping = {k:source_names[v] for k,v in mapping.items()}
    assert all(k in dst.pose.bones and v in src.pose.bones for k,v in mapping.items())
    source_action = src.animation_data.action
    hip_name = mapping['LowerTorso']
    start,end = frame_range or (math.floor(source_action.frame_range[0]), math.ceil(source_action.frame_range[1]))
    assert start <= end
    source_world_rot = src.matrix_world.to_quaternion().to_matrix()
    target_world_rot = dst.matrix_world.to_quaternion().to_matrix()
    coord = target_world_rot.inverted() @ source_world_rot
    rest = {k:dst.data.bones[k].matrix_local.to_3x3().normalized() for k in mapping}
    src_rest_inv = {k:src.data.bones[v].matrix_local.to_3x3().normalized().inverted() for k,v in mapping.items()}
    for k,v in mapping.items():
        target_axis = (dst.data.bones[k].tail_local - dst.data.bones[k].head_local).normalized()
        source_axis = (coord @ (src.data.bones[v].tail_local - src.data.bones[v].head_local)).normalized()
        rest[k] = target_axis.rotation_difference(source_axis).to_matrix() @ rest[k]
    # Hip origin is not body height: the official template places it near zero.
    # Estimate body scale from leg lengths in each armature's local units.
    target_leg = sum(dst.data.bones[n].length for n in ('LeftUpperLeg', 'LeftLowerLeg'))
    source_leg = sum(src.data.bones[source_names[n]].length for n in ('LeftUpLeg', 'LeftLeg'))
    if source_leg <= 1e-8 or target_leg <= 1e-8:
        raise ValueError('Zero leg length')
    height_ratio = target_leg / source_leg
    frames = {}
    for frame in range(start,end+1):
        scene.frame_set(frame)
        bpy.context.view_layer.update()
        frames[frame] = ({k:coord @ src.pose.bones[v].matrix.to_3x3().normalized() @ src_rest_inv[k] @ coord.inverted() @ rest[k] for k,v in mapping.items()}, coord @ (src.pose.bones[hip_name].head - src.data.bones[hip_name].head_local) * height_ratio)
    if root_mode == 'NONE':
        frames = {f:(r,Vector((0,0,0))) for f,(r,v) in frames.items()}
    elif root_mode == 'IN_PLACE':
        for r,delta in frames.values():
            world_delta = target_world_rot @ delta
            world_delta.x = world_delta.y = 0
            delta[:] = target_world_rot.inverted() @ world_delta
    action = bpy.data.actions.new(action_name)
    action.use_fake_user = True
    dst.animation_data_create().action = action
    previous = {}
    for frame,(rotations,hips_offset) in frames.items():
        scene.frame_set(frame)
        desired = {}
        for bone in dst.data.bones:
            pb = dst.pose.bones[bone.name]
            parent_pose = desired.get(bone.parent.name) if bone.parent else None
            basis = Matrix.Identity(4)
            if bone.name in mapping:
                parent_rot = parent_pose.to_3x3().normalized() if parent_pose is not None else Matrix.Identity(3)
                relative_rest = bone.parent.matrix_local.inverted() @ bone.matrix_local if bone.parent else bone.matrix_local
                local_rot = relative_rest.to_3x3().normalized().inverted() @ parent_rot.inverted() @ rotations[bone.name]
                q = local_rot.to_quaternion().normalized()
                if bone.name in previous and q.dot(previous[bone.name]) < 0:
                    q.negate()
                previous[bone.name] = q.copy()
                pb.rotation_mode = 'QUATERNION'
                pb.rotation_quaternion = q
                pb.location = (0,0,0)
                if bone.name == 'LowerTorso':
                    pb.location = relative_rest.to_3x3().normalized().inverted() @ parent_rot.inverted() @ hips_offset
                pb.scale = (1,1,1)
                pb.keyframe_insert('rotation_quaternion', frame=frame, group=bone.name)
                if bone.name == 'LowerTorso':
                    pb.keyframe_insert('location', frame=frame, group=bone.name)
                basis = pb.matrix_basis.copy()
            desired[bone.name] = bone.convert_local_to_pose(basis,bone.matrix_local,parent_matrix=parent_pose,parent_matrix_local=bone.parent.matrix_local) if bone.parent else bone.convert_local_to_pose(basis,bone.matrix_local)
    scene.frame_start,scene.frame_end = start,end
    scene.frame_set(start)
    bpy.context.view_layer.update()
    dst['retarget_source'] = src.name
    dst['retarget_source_action'] = source_action.name
    dst['retarget_method'] = 'rest-corrected global rotations, hierarchy-local quaternion bake'
    dst['retarget_frame_range'] = [start,end]
    dst['retarget_mapping_json'] = json.dumps(mapping)
    dst['retarget_root_mode'] = root_mode


    curves = [fc for layer in action.layers for strip in layer.strips for bag in strip.channelbags for fc in bag.fcurves]
    for fc in curves:
        for key in fc.keyframe_points:
            key.interpolation = 'LINEAR'
    max_direction_error = max_length_error = max_rotation_error = 0.0
    for frame in range(start,end+1):
        scene.frame_set(frame)
        bpy.context.view_layer.update()
        for name, source_bone in mapping.items():
            pb = dst.pose.bones[name]
            if not all(math.isfinite(v) for row in pb.matrix for v in row):
                raise RuntimeError('Non-finite pose: ' + name)
            max_direction_error = max(max_direction_error, pb.vector.normalized().angle((coord @ src.pose.bones[source_bone].vector).normalized()))
            max_length_error = max(max_length_error, abs(pb.length - dst.data.bones[name].length))
            angle = pb.matrix.to_quaternion().rotation_difference(frames[frame][0][name].to_quaternion()).angle
            max_rotation_error = max(max_rotation_error,min(angle,abs(2*math.pi-angle)))
    if max_direction_error > 0.001 or max_rotation_error > 0.001 or max_length_error > 0.0001:
        raise RuntimeError('Retarget validation failed')
    report = {'version': 1, 'source':src.name, 'source_action':source_action.name,
              'target':dst.name,'action':action.name,'frame_range':[start,end],
              'root_mode':root_mode,'translation_scale':height_ratio,'fps':scene.render.fps / scene.render.fps_base,
              'mapped_bones':len(mapping),'curves':len(curves),
              'keyframes':sum(len(fc.keyframe_points) for fc in curves),
              'max_source_direction_error_degrees':math.degrees(max_direction_error),
              'max_rotation_error_degrees':math.degrees(max_rotation_error),
              'max_bone_length_error':max_length_error,
              'studio_import_verified':False,'art_review':'pending'}
    record = bpy.data.texts.new(action.name + '_validation.json')
    record.write(json.dumps(report,indent=2))
    scene.frame_set(start)
    if fbx_path:
        bpy.ops.object.select_all(action='DESELECT')
        dst.select_set(True)
        bpy.context.view_layer.objects.active = dst
        bpy.ops.export_scene.fbx(filepath=str(fbx_path),use_selection=True,object_types={'ARMATURE'},
            add_leaf_bones=False,use_armature_deform_only=False,axis_forward='-Z',axis_up='Y',
            bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,
            bake_anim_force_startend_keying=True,bake_anim_step=1,bake_anim_simplify_factor=0)
        report['fbx_path'] = str(fbx_path)
    if report_path:
        Path(report_path).write_text(json.dumps(report,indent=2)+'\n')
    if blend_path:
        bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))
    print('RETARGET_VALIDATED',json.dumps(report))
    return dst, report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', default='Armature.001')
    parser.add_argument('--target', default='Armature')
    parser.add_argument('--action-name', required=True)
    parser.add_argument('--root-mode', choices=['KEEP','IN_PLACE','NONE'],default='KEEP')
    parser.add_argument('--blend-path')
    parser.add_argument('--fbx-path')
    parser.add_argument('--report-path')
    args = parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    run(**vars(args))

if __name__ == '__main__':
    main()
