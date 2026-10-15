"""Blender background script: 同一の粗い岩に2材質を適用し距離比較する。"""
import bpy, json, math, pathlib, random
from mathutils import Vector
ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'work/material-preview/rock-v1'
(OUT/'renders').mkdir(exist_ok=True)
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
scene=bpy.context.scene
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
scene.render.resolution_x=800;scene.render.resolution_y=600;scene.render.resolution_percentage=100
scene.world.color=(0.25,0.25,0.25)
scene.view_settings.view_transform='AgX'
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=1)
rock=bpy.context.object;rock.name='ComparisonRock_80Tris'
rng=random.Random(831)
for v in rock.data.vertices:
    v.co*=rng.uniform(0.84,1.12)
    v.co.x*=1.4;v.co.y*=1.0;v.co.z*=0.9
    v.co.z=max(v.co.z,-0.55)
rock.location.z=0.55
for p in rock.data.polygons:p.use_smooth=False
bpy.ops.object.mode_set(mode='EDIT');bpy.ops.mesh.select_all(action='SELECT');bpy.ops.uv.smart_project(island_margin=0.03);bpy.ops.object.mode_set(mode='OBJECT')
# 比較用の共通UV。材質ごとに物理的な模様の大きさを近似して合わせる。
materials={}
for asset,width in [('rock_01',1.5),('rock_face',2.4)]:
    mat=bpy.data.materials.new(asset);mat.use_nodes=True
    n=mat.node_tree.nodes;l=mat.node_tree.links;n.clear();bs=n.new('ShaderNodeBsdfPrincipled');output=n.new('ShaderNodeOutputMaterial');l.new(bs.outputs['BSDF'],output.inputs['Surface'])
    uv=n.new('ShaderNodeTexCoord');mapping=n.new('ShaderNodeVectorMath');mapping.operation='SCALE';mapping.inputs[3].default_value=2.8/width
    l.new(uv.outputs['UV'],mapping.inputs[0])
    for kind in ['Diffuse','nor_gl','Rough']:
        tex=n.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(OUT/'textures'/f'{asset}_{kind}.png'));tex.label=kind
        if kind!='Diffuse':tex.image.colorspace_settings.name='Non-Color'
        l.new(mapping.outputs[0],tex.inputs['Vector'])
        if kind=='Diffuse':l.new(tex.outputs['Color'],bs.inputs['Base Color'])
        elif kind=='Rough':l.new(tex.outputs['Color'],bs.inputs['Roughness'])
        else:
            norm=n.new('ShaderNodeNormalMap');norm.inputs['Strength'].default_value=1.0
            l.new(tex.outputs['Color'],norm.inputs['Color']);l.new(norm.outputs['Normal'],bs.inputs['Normal'])
    materials[asset]=mat
bpy.ops.mesh.primitive_plane_add(size=200)
ground=bpy.context.object;ground.name='NeutralGround'
gm=bpy.data.materials.new('NeutralGround');gm.diffuse_color=(0.19,0.21,0.20,1);gm.use_nodes=True
gm.node_tree.nodes.clear();gbs=gm.node_tree.nodes.new('ShaderNodeBsdfPrincipled');gout=gm.node_tree.nodes.new('ShaderNodeOutputMaterial');gm.node_tree.links.new(gbs.outputs['BSDF'],gout.inputs['Surface']);gbs.inputs['Base Color'].default_value=(0.19,0.21,0.20,1);gbs.inputs['Roughness'].default_value=0.9
ground.data.materials.append(gm)
bpy.ops.object.light_add(type='SUN',location=(4,-6,8));sun=bpy.context.object;sun.data.energy=2;sun.data.angle=math.radians(12);sun.rotation_euler=(math.radians(28),math.radians(-20),math.radians(-30))
bpy.ops.object.light_add(type='AREA',location=(-3,-4,5));fill=bpy.context.object;fill.data.energy=350;fill.data.shape='DISK';fill.data.size=5
fill.rotation_euler=(Vector((0,0,0.5))-fill.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add();camera=bpy.context.object;scene.camera=camera;camera.data.lens=50
settings=dict(status='Prototype: Implemented（Blender試作のみ・Studio未確認）',blender=bpy.app.version_string,triangles=len(rock.data.polygons),seed=831,resolution=[800,600],samples=24,normal_strength=1.0,displacement=False,uv='共通Smart UV・模様密度は物理幅から近似。UV継ぎ目あり。',texture_resolution='1K',camera_lens_mm=50,distances={})
for asset,mat in materials.items():
    rock.data.materials.clear();rock.data.materials.append(mat)
    for label,distance in [('far',16),('mid',9),('near',5)]:
        target=Vector((0,0,0.65));direction=Vector((0.9,-1.5,0.75)).normalized()
        camera.location=target+direction*distance;camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
        settings['distances'][label]=distance
        scene.render.filepath=str(OUT/'renders'/f'{asset}_{label}.png')
        bpy.ops.render.render(write_still=True)
    for img in bpy.data.images:
        if img.source=='FILE' and not img.packed_file:img.pack()
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT/f'{asset}.blend'))
(OUT/'settings.json').write_text(json.dumps(settings,ensure_ascii=False,indent=2))
print('READY_FOR_REVIEW',OUT)
