"""Blender regression check using the real official-R15 Hook Punch fixture.

blender --background <baked.blend> --python-exit-code 1 --python <this.py> -- <legacy-v004.json>
Old exporter must fail the independently specified Roblox facing contract.
"""
import json
import math
from pathlib import Path
import runpy
import sys
import tempfile
import bpy
from mathutils import Matrix, Vector

scripts = Path(__file__).resolve().parents[1]
workflow = runpy.run_path(str(scripts / 'export_r15_pose_samples.py'))
rig = bpy.data.objects['Armature']
basis, report = workflow['anatomical_basis'](rig)
front = (rig.data.bones['LeftFoot'].tail_local-rig.data.bones['LeftFoot'].head_local).normalized()
assert (basis @ front - Vector((0,0,-1))).length < 1e-5
assert (basis @ rig.data.bones['LeftUpperArm'].head_local).x < 0
assert (basis @ rig.data.bones['RightUpperArm'].head_local).x > 0
assert (basis @ (rig.data.bones['Head'].tail_local-rig.data.bones['Head'].head_local)).y > 0
# Actual v1 bug: up is correct while front and right are both backwards.
legacy_basis = Matrix.Rotation(-math.pi/2,3,'X') @ rig.matrix_world.to_quaternion().to_matrix()
assert (legacy_basis @ front).dot(Vector((0,0,-1))) < -.99, 'Fixture must reproduce the old bug'
original_world = rig.matrix_world.copy()
rig.matrix_world = Matrix.Rotation(.7,4,'Z') @ original_world
rotated_basis, _ = workflow['anatomical_basis'](rig)
assert all(abs(basis[i][j]-rotated_basis[i][j])<1e-6 for i in range(3) for j in range(3))
rig.matrix_world = original_world
with tempfile.TemporaryDirectory(prefix='w05-facing-') as folder:
    data = workflow['run']('Armature', str(Path(folder)/'poses.json'))
    assert data['version']==2 and data['orientation']['profile']=='r15-anatomical-v2'
    assert len(data['frames'])==65
    assert len(data['frames'][0]['poses'])==15
    assert abs(data['frames'][-1]['time']-64/30)<1e-6
    legacy_path = sys.argv[sys.argv.index('--')+1]
    legacy = json.loads(Path(legacy_path).read_text())
    # Independent 180-degree model-yaw change of basis, not a root/body turn.
    yaw = Matrix(((-1,0,0),(0,1,0),(0,0,-1)))
    maximum = 0.0
    for old,new in zip(legacy['frames'],data['frames']):
        for name,values in old['poses'].items():
            rotation = Matrix((values[3:6],values[6:9],values[9:12]))
            expected_rotation = yaw @ rotation @ yaw
            actual = new['poses'][name]
            expected_position = yaw @ Vector(values[:3])
            maximum = max(maximum,(expected_position-Vector(actual[:3])).length)
            for i in range(3):
                for j in range(3):
                    maximum=max(maximum,abs(expected_rotation[i][j]-actual[3+3*i+j]))
    assert maximum < 3e-6, maximum
print('R15_ORIENTATION_REGRESSION_PASS',json.dumps({'axes':report,'legacy_front_rejected':True,'object_rotation_independent':True,'frames':65,'yaw_basis_max_error':maximum}))
