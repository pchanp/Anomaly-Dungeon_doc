#!/usr/bin/env python3
"""8月31日 2D設定画の SVG 出力（HTML から生成）"""
import re
html=open('/Users/saitouyouwataru/Documents/Git/Anomaly-Dungeon_doc/work/visual-brainstorm/kilo/august-31/august-31-view.html').read()
svg=html[html.find('<canvas')+8:html.find('</canvas>')].replace('<canvas','<g id="canvas">').replace('</canvas>','</g>')
svg='<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1600 900" width="1600" height="900">\n'+svg+'\n</svg>'
open('/Users/saitouyouwataru/Documents/Git/Anomaly-Dungeon_doc/work/visual-brainstorm/kilo/august-31/august-31-view.svg','w').write(svg)
print('svg written')
