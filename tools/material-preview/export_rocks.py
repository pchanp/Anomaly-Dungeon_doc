import bpy,pathlib
root=pathlib.Path(__file__).resolve().parents[2];out=root/'work/material-preview/rock-v1/export';out.mkdir(exist_ok=True)
for asset in ['rock_01','rock_face']:
 bpy.ops.wm.open_mainfile(filepath=str(root/'work/material-preview/rock-v1'/f'{asset}.blend'))
 bpy.ops.object.select_all(action='DESELECT')
 rock=bpy.data.objects['ComparisonRock_80Tris'];rock.select_set(True);bpy.context.view_layer.objects.active=rock
 bpy.ops.export_scene.fbx(filepath=str(out/f'{asset}.fbx'),use_selection=True,object_types={'MESH'},bake_anim=False,axis_forward='-Z',axis_up='Y',path_mode='COPY',embed_textures=True)
print('EXPORTED',out)
