from pathlib import Path
import bpy,sys,tempfile,json
from mathutils import Vector
r=Path(__file__).resolve().parents[4];sys.path.insert(0,str(r/'work/animations/scripts'))
import export_r15_pose_samples as e
p=r/'work/animations/motions/shade'
bpy.ops.wm.open_mainfile(filepath=str(p/'blender/shade-r15-v002.blend'))
s=bpy.data.objects['Armature.001'];d=bpy.data.objects['Armature']
up=(s.data.bones['mixamorig:Head'].tail_local-s.data.bones['mixamorig:Head'].head_local).normalized()
right=(s.data.bones['mixamorig:RightArm'].head_local-s.data.bones['mixamorig:LeftArm'].head_local).normalized()
front=up.cross(right).normalized()
sr=s.matrix_world.to_quaternion();dr=d.matrix_world.to_quaternion()
print('SHADE_ANATOMY',list(sr@up),list(sr@front),'target',list(dr@Vector((0,1,0))),list(dr@Vector((0,0,1))))
assert (sr@up).dot(dr@Vector((0,1,0)))>.9
assert (sr@front).dot(dr@Vector((0,0,1)))>.9
with tempfile.TemporaryDirectory() as t:
 actual=e.run('Armature',Path(t)/'poses.json')
 expected=json.loads((p/'export/shade-poses-v002.json').read_text());assert actual==expected
 assert all(abs(f['poses']['LowerTorso'][0])<1e-5 and abs(f['poses']['LowerTorso'][2])<1e-5 for f in actual['frames'])
report={'savedPoseMatch':True,'horizontalRootMotionRemoved':True,'sourceTargetRestFacingDot':(sr@front).dot(dr@Vector((0,0,1))),'frames':39,'duration':38/24,'profile':actual['orientation']['profile']}
(p/'export/reopen-qa-v002.json').write_text(json.dumps(report,indent=2)+'\n');print('SHADE_REOPEN_PASS',json.dumps(report))
