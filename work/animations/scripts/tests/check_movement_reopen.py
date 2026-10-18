"""Blender background regression: reopen saved movement bakes and compare every exported pose."""
import sys,json,tempfile
from pathlib import Path
import bpy
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'work/animations/scripts'))
import export_r15_pose_samples as exporter
results=[]
for slug in ('sprinting-forward-roll','standard-run'):
 folder=ROOT/'work/animations/motions'/slug
 bpy.ops.wm.open_mainfile(filepath=str(folder/'blender'/f'{slug}-r15-v001.blend'))
 expected=json.loads((folder/'export'/f'{slug}-poses-v001.json').read_text())
 with tempfile.TemporaryDirectory() as td:
  actual=exporter.run('Armature',Path(td)/'poses.json')
 assert actual==expected,'Saved Action and exported samples differ'
 assert actual['orientation']['profile']=='r15-anatomical-v2'
 assert all(abs(f['poses']['LowerTorso'][0])<1e-5 and abs(f['poses']['LowerTorso'][2])<1e-5 for f in actual['frames']),'Horizontal root motion remains'
 m=actual['frames'][6]['poses']['LowerTorso']
 assert -m[10]>.2,'First lean must face Roblox -Z'
 results.append({'clip':actual['name'],'frames':len(actual['frames']),'reopenedPoseMatch':True,'horizontalRootMotionRemoved':True,'firstForward':-m[10]})
(ROOT/'work/animations/motions/movement-reopen-qa-20261018.json').write_text(json.dumps(results,indent=2)+'\n')
print('MOVEMENT_REOPEN_PASS',json.dumps(results))
