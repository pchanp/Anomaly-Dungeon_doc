#!/usr/bin/env python3
"""Observation / Open Liminal Map 2D 設定画（svgwrite）"""
import random
import svgwrite

W,H=1600,900
dw=svgwrite.Drawing('open-liminal-view.svg',size=(W,H),viewBox=(0,0,W,H))
g=dw.add(dw.g(id='layer'))

def rect(x0,y0,x1,y1,c):
    g.add(dw.rect(insert=(x0,y0),size=(x1-x0,y1-y0),fill=rgbcol(c),stroke='none'))

def hexcol(s):
    s=s.lstrip('#')
    return '#%02X%02X%02X'%(int(s[0:2],16),int(s[2:4],16),int(s[4:6],16))

def rgbcol(c):
    if isinstance(c,str): c=c.lstrip('#')
    if isinstance(c,tuple): return '#%02X%02X%02X'%c
    return '#'+c

# 空（薄明かり・霧）
for y in range(H):
    t=y/H
    if t<0.35: rect(0,y,W,1,(100,110,120))
    elif t<0.6: rect(0,y,W,1,(130,140,150))
    else: rect(0,y,W,1,(160,170,180))

# 雲（ぼんやり）
for k in range(6):
    cx=200+k*260; cy=60+random.random()*60; r=70+random.random()*40
    g.add(dw.circle(center=(cx,cy),r=r,fill=rgbcol((190,200,210)),stroke='none'))

# 地面（開けた風景）
rect(0,560,W,340,hexcol('#4A5A44'))
for i in range(400):
    x=random.random()*W; y=570+random.random()*300
    rect(x,y,random.random()*8+2,random.random()*4+2,hexcol('#5A6A54'))

# 道
rect(700,640,200,260,hexcol('#5A4A36'))
for i in range(3): rect(730+i*50,660,40,220,hexcol('#4A3A26'))

# 小施設（遠景に点在）
def small(x,y,w,h):
    rect(x,y,w,h,hexcol('#7A8A76'))
    rect(x+8,y+8,w-16,20,hexcol('#3A4A36'))
    rect(x+4,y+28,12,16,hexcol('#4A3A26'))
small(300,660,90,60)
small(1100,640,100,70)
small(1350,700,70,50)

# 街灯
def lamp(x,y):
    rect(x,y,6,140,hexcol('#2E241C'))
    rect(x-24,y,52,8,hexcol('#4A3A2A'))
    g.add(dw.circle(center=(x,y),r=12,fill=rgbcol((255,240,180)),stroke='none'))
    g.add(dw.circle(center=(x,y),r=24,fill=rgbcol((255,230,140)),stroke='none'))
    g.add(dw.circle(center=(x,y),r=40,fill=rgbcol((255,200,80)),stroke='none'))
    g.add(dw.circle(center=(x,y),r=55,fill=rgbcol((255,160,40)),stroke='none'))
lamp(500,620)
lamp(900,680)
lamp(1150,640)

# 人物
def person(x,y):
    rect(x,y-30,12,30,hexcol('#1A1410'))
    rect(x-6,y-42,14,14,hexcol('#2A2218'))

# 遠景の物体（徐々に変化）
def changing(x,y,size):
    c1=(120,130,140); c2=(150,160,170); c3=(180,190,200)
    g.add(dw.rect(insert=(x,y),size=(size,size),fill=rgbcol(c1 if random.random()>0.3 else c2),stroke='none'))
    if random.random()>0.5:
        g.add(dw.rect(insert=(x+size//3,y+size//3),size=(size//3,size//3),fill=rgbcol(c3),stroke='none'))

for i in range(12):
    x=random.random()*W; y=560+random.random()*100
    changing(x,y,10+random.random()*18)

# 視線誘導の筋（霧・光）
for i in range(4):
    x=400+i*300
    g.add(dw.line((x,560),(x-50,900),stroke=rgbcol((200,210,220)),stroke_width=1,opacity=0.3))
    g.add(dw.line((x+160,560),(x+110,900),stroke=rgbcol((200,210,220)),stroke_width=1,opacity=0.3))

# ラベル
labels=[('観察対象の物体（遠景）',(320,650)),('開けた風景・草地',(800,800)),('道',(800,750)),('街灯・照明',(500,600)),('小施設',(1150,660)),('霧・光の筋',(700,520))]
for t,(x,y) in labels:
    g.add(dw.text(t,insert=(x,y),fill=rgbcol((255,255,255)),font_size=13))

dw.save()
print('svg written')