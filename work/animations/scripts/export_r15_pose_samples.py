"""Export baked official R15 to Roblox part-space Pose samples.

Run in Blender after the stored retarget step. Standard R15 joint attachment
rotations must be identity. FBX raw bone axes are not Motor6D/AnimationConstraint
part axes; this adapter removes rest rotations and dummy skeleton roots.
"""
import json
from pathlib import Path
import bpy
from mathutils import Matrix, Vector


SPACE_PROFILE = 'r15-anatomical-v2'


def anatomical_basis(rig):
    """Armature-local anatomy -> Roblox model right +X, up +Y, front -Z.

    The official template's left arm is +X and toes point +Z. Merely changing
    Z-up to Y-up silently leaves both horizontal axes reversed. Scene/object
    rotation is deliberately irrelevant to character model-space orientation.
    """
    bones = rig.data.bones
    up = (bones['Head'].tail_local - bones['Head'].head_local).normalized()
    right = bones['RightUpperArm'].head_local - bones['LeftUpperArm'].head_local
    right -= up * right.dot(up)
    if right.length < 1e-6 or up.length < 1e-6:
        raise ValueError('Cannot determine anatomical axes')
    right.normalize()
    forward = up.cross(right).normalized()
    for side in ('Left', 'Right'):
        foot = bones[side + 'Foot']
        toe = (foot.tail_local - foot.head_local).normalized()
        if toe.dot(forward) < 0.8:
            raise ValueError('Feet disagree with anatomical facing; inspect rig')
    # Rows project a local vector onto Roblox right, up and backward axes.
    basis = Matrix((right, up, -forward))
    expected = [(right, Vector((1, 0, 0))), (up, Vector((0, 1, 0))),
                (forward, Vector((0, 0, -1)))]
    if abs(basis.determinant() - 1) > 1e-5 or any((basis @ a - b).length > 1e-5 for a, b in expected):
        raise ValueError('Invalid right-handed Roblox orientation')
    return basis, {'profile': SPACE_PROFILE, 'right': list(basis @ right),
                   'up': list(basis @ up), 'forward': list(basis @ forward),
                   'rig_local_right': list(right), 'rig_local_up': list(up),
                   'rig_local_forward': list(forward)}


def run(target, output_path):
    path = Path(output_path)
    if path.exists():
        raise FileExistsError(str(path))
    rig = bpy.data.objects[target]
    action = rig.animation_data.action
    start, end = map(int, action.frame_range)
    names = ['LowerTorso', 'UpperTorso', 'Head']
    for side in ('Left', 'Right'):
        names += [side + suffix for suffix in ('UpperArm', 'LowerArm', 'Hand', 'UpperLeg', 'LowerLeg', 'Foot')]
    parents = {name: rig.data.bones[name].parent.name for name in names}
    parents['LowerTorso'] = 'HumanoidRootPart'
    basis, orientation = anatomical_basis(rig)
    inv = basis.inverted()
    frames = []
    for frame in range(start, end + 1):
        bpy.context.scene.frame_set(frame)
        bpy.context.view_layer.update()
        delta = {name: basis @ rig.pose.bones[name].matrix.to_3x3().normalized() @ rig.data.bones[name].matrix_local.to_3x3().normalized().inverted() @ inv for name in names}
        delta['HumanoidRootPart'] = Matrix.Identity(3)
        poses = {}
        for name in names:
            rotation = delta[parents[name]].inverted() @ delta[name]
            position = Vector((0, 0, 0))
            if name == 'LowerTorso':
                position = basis @ (rig.pose.bones[name].head - rig.data.bones[name].head_local)
            poses[name] = [round(v, 7) for v in position] + [round(v, 7) for row in rotation for v in row]
        frames.append({'time': (frame-start) * bpy.context.scene.render.fps_base / bpy.context.scene.render.fps, 'poses': poses})
    result = {'version': 2, 'orientation': orientation, 'name': action.name, 'parents': parents, 'frames': frames,
              'joint_attachment_rotations': 'identity', 'loop': False, 'priority': 'Action'}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, separators=(',', ':')))
    print('EXPORTED_R15_POSES', str(path), len(frames))
    return result


if __name__ == '__main__':
    import sys
    args = sys.argv[sys.argv.index('--') + 1:]
    run(args[0], args[1])
