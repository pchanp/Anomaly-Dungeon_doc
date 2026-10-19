"""Prepare supplied Shade Mixamo clip with the stored R15 pipeline.
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
for slug,filename,name in [('shade','shade.fbx','Shade_R15_v002')]:
 out=ROOT/'work/animations/motions'/slug
 src=ROOT/'work/animations/motions/_template/source'/filename
 for sub in ('source','blender','export','studio'): (out/sub).mkdir(parents=True,exist_ok=True)
 dest=out/'source'/filename
 if not dest.exists(): shutil.copy2(src,dest)
 assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(dest.read_bytes()).digest()
 bpy.ops.wm.open_mainfile(filepath=str(rig))
 if bpy.context.mode!='OBJECT': bpy.ops.object.mode_set(mode='OBJECT')
 before=set(bpy.data.objects)
 # This supplied Comfy exporter fixture parents its skeleton below the same
 # mesh it skins. Blender's mesh collection would create a hierarchy cycle.
 # Its mesh has an identity transform and no animation: lift the skeleton
 # root to scene root without changing any bone transforms or curves.
 from io_scene_fbx import parse_fbx
 original_parse = parse_fbx.parse
 repairs = []
 def compatible_parse(path, *args, **kwargs):
  tree, version = original_parse(path, *args, **kwargs)
  objects = next(n for n in tree.elems if n.id == b'Objects')
  links = next(n for n in tree.elems if n.id == b'Connections')
  models = {n.props[0]:n for n in objects.elems if n.id == b'Model'}
  for link in links.elems:
   if link.props[0] != b'OO': continue
   child, parent = link.props[1:3]
   if child not in models or parent not in models: continue
   if models[child].props[2] != b'LimbNode' or models[parent].props[2] != b'Mesh': continue
   mesh = models[parent]
   props = next(n for n in mesh.elems if n.id == b'Properties70')
   for prop in props.elems:
    if prop.props[0] in (b'Lcl Translation',b'Lcl Rotation',b'Lcl Scaling'):
     expected = 1 if prop.props[0] == b'Lcl Scaling' else 0
     assert all(abs(v-expected)<1e-8 for v in prop.props[4:]), 'Nonidentity mesh parent requires a different adapter'
   assert not any(l.props[0] == b'OP' and l.props[2] == parent for l in links.elems), 'Animated mesh parent unsupported'
   repairs.append({'child':child,'old_parent':parent,'new_parent':0})
   link.props[2] = 0
  assert len(repairs)==1, 'Unexpected fixture hierarchy'
  return tree, version
 parse_fbx.parse = compatible_parse
 try:
  bpy.ops.import_scene.fbx(filepath=str(dest))
 finally:
  parse_fbx.parse = original_parse
 (out/'export'/'import-compatibility-v002.json').write_text(json.dumps({'source_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'repair':'identity skinned-mesh parent cycle; skeleton root lifted to scene','connections':repairs,'animation_curves_modified':False},indent=2)+'\n')
 sources=[o for o in bpy.data.objects if o not in before and o.type=='ARMATURE']
 assert len(sources)==1
 source=sources[0]
 for bone in source.data.bones:
  if bone.name.startswith("mixamorig") and not bone.name.startswith("mixamorig:"): bone.name="mixamorig:"+bone.name[len("mixamorig"): ]
 print('SOURCE',source.name,'TARGETS',[(o.name,len(o.data.bones)) for o in before if o.type=='ARMATURE'])
 target=next(o for o in before if o.type=='ARMATURE' and 'LowerTorso' in o.data.bones)
 # The supplied skeleton's anatomical up is world -X, not scene +Z.
 # Align source anatomy to target anatomy before the fixed retarget bake.
 from mathutils import Matrix, Vector
 up=(source.data.bones['mixamorig:Head'].head_local-source.data.bones['mixamorig:Hips'].head_local).normalized()
 right=(source.data.bones['mixamorig:RightArm'].head_local-source.data.bones['mixamorig:LeftArm'].head_local).normalized()
 # Snap this nearly axis-aligned fixture's rest axes; do not remove the
 # character's small anatomical rest-pose lean as if it were scene rotation.
 def cardinal(v):
  axis=max(range(3),key=lambda i:abs(v[i]))
  assert abs(v[axis])>.98,'Non-cardinal rest axes need explicit review'
  out=Vector((0,0,0));out[axis]=1 if v[axis]>0 else -1;return out
 up=cardinal(up);right=cardinal(right)
 assert abs(up.dot(right))<1e-6
 front=up.cross(right)
 toe=source.data.bones['mixamorig:LeftToeBase']
 assert (toe.tail_local-toe.head_local).normalized().dot(front)>.8
 source_basis=Matrix((right,up,-front))
 target_basis,_=exporter.anatomical_basis(target)
 source_world=source.matrix_world.to_quaternion().to_matrix()@source_basis.inverted()
 target_world=target.matrix_world.to_quaternion().to_matrix()@target_basis.inverted()
 alignment=target_world@source_world.inverted()
 source.matrix_world=alignment.to_4x4()@source.matrix_world
 bpy.context.view_layer.update()
 (out/'export'/'source-axis-alignment-v002.json').write_text(json.dumps({'method':'anatomical source-to-target world alignment','source_local_up':list(up),'source_local_right':list(right),'source_local_forward':list(front),'world_alignment':[[v for v in row] for row in alignment]},indent=2)+'\n')

 _,report=retarget.run(source=source.name,target=target.name,action_name=name,root_mode='IN_PLACE',blend_path=out/'blender'/f'{slug}-r15-v002.blend',fbx_path=out/'export'/f'{slug}-r15-v002.fbx',report_path=out/'export'/'retarget-validation-v002.json')
 exporter.run(target.name,out/'export'/f'{slug}-poses-v002.json')
 print('MOVEMENT_COMPLETE',slug,json.dumps(report))
