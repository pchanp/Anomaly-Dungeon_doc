"""Read-only Blender rig inspection; writes a timestamped JSON beside the blend."""
import bpy
import json
from pathlib import Path
from datetime import datetime

def matrix(m):
    return [[float(v) for v in row] for row in m]

report = {'blender': bpy.app.version_string, 'file': bpy.data.filepath, 'rigs': []}
for obj in bpy.data.objects:
    if obj.type != 'ARMATURE':
        continue
    anim = obj.animation_data
    action = anim.action if anim else None
    report['rigs'].append({
        'name': obj.name, 'matrix_world': matrix(obj.matrix_world),
        'action': action.name if action else None,
        'frame_range': list(action.frame_range) if action else None,
        'bones': [{'name': b.name, 'parent': b.parent.name if b.parent else None,
                   'rest_matrix': matrix(b.matrix_local),
                   'head': list(b.head_local), 'tail': list(b.tail_local),
                   'rotation_mode': obj.pose.bones[b.name].rotation_mode,
                   'constraints': [c.type for c in obj.pose.bones[b.name].constraints]}
                  for b in obj.data.bones]})
if not bpy.data.filepath:
    raise RuntimeError('Save the blend before inspection')
path = Path(bpy.data.filepath).parent / ('rig-inspection-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f') + '.json')
path.write_text(json.dumps(report, ensure_ascii=False, indent=2))
print('RIG_INSPECTION:', path)
print('RIGS:', [(r['name'], r['action'], r['frame_range']) for r in report['rigs']])
