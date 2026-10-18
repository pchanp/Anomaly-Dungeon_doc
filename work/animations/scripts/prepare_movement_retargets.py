"""Prepare both supplied Mixamo movement clips with the stored R15 pipeline.
Run in background Blender; existing versioned outputs are never overwritten.
"""
import sys, shutil, hashlib, json
from pathlib import Path
import bpy
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'work/animations/scripts'))
import retarget_mixamo_r15 as retarget
import export_r15_pose_samples as exporter
rig=ROOT/'work/animations/rigs/roblox-r15-official/Rig_and_Attachments_Templates 2/Rig_and_Attachments_Template.blend'
for slug,filename,name in [('sprinting-forward-roll','Sprinting Forward Roll.fbx','SprintingForwardRoll_R15_v001'),('standard-run','Standard Run.fbx','StandardRun_R15_v001')]:
 out=ROOT/'work/animations/motions'/slug
 src=ROOT/'work/animations/motions/_template/source'/filename
 for sub in ('source','blender','export','studio'): (out/sub).mkdir(parents=True,exist_ok=True)
 dest=out/'source'/filename
 if not dest.exists(): shutil.copy2(src,dest)
 assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(dest.read_bytes()).digest()
 bpy.ops.wm.open_mainfile(filepath=str(rig))
 if bpy.context.mode!='OBJECT': bpy.ops.object.mode_set(mode='OBJECT')
 before=set(bpy.data.objects)
 bpy.ops.import_scene.fbx(filepath=str(dest))
 sources=[o for o in bpy.data.objects if o not in before and o.type=='ARMATURE']
 assert len(sources)==1
 source=sources[0]
 print('SOURCE',source.name,'TARGETS',[(o.name,len(o.data.bones)) for o in before if o.type=='ARMATURE'])
 target=next(o for o in before if o.type=='ARMATURE' and 'LowerTorso' in o.data.bones)
 _,report=retarget.run(source=source.name,target=target.name,action_name=name,root_mode='IN_PLACE',blend_path=out/'blender'/f'{slug}-r15-v001.blend',fbx_path=out/'export'/f'{slug}-r15-v001.fbx',report_path=out/'export'/'retarget-validation-v001.json')
 exporter.run(target.name,out/'export'/f'{slug}-poses-v001.json')
 print('MOVEMENT_COMPLETE',slug,json.dumps(report))
