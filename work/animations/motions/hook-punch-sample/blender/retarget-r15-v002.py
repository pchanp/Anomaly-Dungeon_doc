import bpy, math, json
from mathutils import Matrix, Vector
src = bpy.data.objects['Armature.001']
dst = bpy.data.objects['Armature']
scene = bpy.context.scene
if dst.animation_data and dst.animation_data.action:
    dst.animation_data.action.name = 'HookPunch_R15_Trial_RestOffset'
    dst.animation_data.action.use_fake_user = True
assert not any(pb.constraints for pb in dst.pose.bones), 'Target has constraints'
mapping = {'LowerTorso':'Hips','UpperTorso':'Spine2','Head':'Head'}
for side in ('Left','Right'):
    for target, source in [('UpperArm','Arm'),('LowerArm','ForeArm'),('Hand','Hand'),('UpperLeg','UpLeg'),('LowerLeg','Leg'),('Foot','Foot')]:
        mapping[side+target] = side+source
mapping = {k:'mixamorig:'+v for k,v in mapping.items()}
assert all(k in dst.pose.bones and v in src.pose.bones for k,v in mapping.items())
source_action = src.animation_data.action
start,end = [int(v) for v in source_action.frame_range]
source_world_rot = src.matrix_world.to_quaternion().to_matrix()
target_world_rot = dst.matrix_world.to_quaternion().to_matrix()
coord = target_world_rot.inverted() @ source_world_rot
rest = {k:dst.data.bones[k].matrix_local.to_3x3().normalized() for k in mapping}
src_rest_inv = {k:src.data.bones[v].matrix_local.to_3x3().normalized().inverted() for k,v in mapping.items()}
for k,v in mapping.items():
    target_axis = (dst.data.bones[k].tail_local - dst.data.bones[k].head_local).normalized()
    source_axis = (coord @ (src.data.bones[v].tail_local - src.data.bones[v].head_local)).normalized()
    rest[k] = target_axis.rotation_difference(source_axis).to_matrix() @ rest[k]
height_ratio = dst.data.bones['LowerTorso'].head_local.length / src.data.bones['mixamorig:Hips'].head_local.length
frames = {}
for frame in range(start,end+1):
    scene.frame_set(frame)
    frames[frame] = ({k:coord @ src.pose.bones[v].matrix.to_3x3().normalized() @ src_rest_inv[k] @ coord.inverted() @ rest[k] for k,v in mapping.items()}, coord @ (src.pose.bones['mixamorig:Hips'].head - src.data.bones['mixamorig:Hips'].head_local) * height_ratio)
action = bpy.data.actions.new('HookPunch_R15_Retarget_v002')
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
print('RETARGET_OK',action.name,'bones',len(mapping),'frames',start,end)
