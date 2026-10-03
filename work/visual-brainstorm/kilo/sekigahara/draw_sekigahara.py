#!/usr/bin/env python3
"""SEKIGAHARA 2D 設定画の描画（純粋 Python + pypng）"""
import random
import png

W,H=1600,900
im=[[(0,0,0)]*W for _ in range(H)]
def px_set(x,y,c):
    x=int(round(x)); y=int(round(y))
    if 0<=x<W and 0<=y<H: im[y][x]=rgbcol(c)
def rect(x0,y0,x1,y1,c):
    c=rgbcol(c); x0=int(x0);y0=int(y0);x1=int(x1);y1=int(y1)
    for y in range(max(0,y0),min(H,y1)):
        row=im[y]
        for x in range(max(0,x0),min(W,x1)): row[x]=c
def hexcol(s):
    s=s.lstrip('#'); return '#%02X%02X%02X'%(int(s[0:2],16),int(s[2:4],16),int(s[4:6],16))

def blend(a,b,alpha): return tuple(int(a[i]*(1-alpha)+b[i]*alpha) for i in range(3))

def rgbcol(c):
    if isinstance(c,str): c=c.lstrip('#')
    if isinstance(c,tuple): return c
    return '#%02X%02X%02X'%tuple(int(c[i:i+2],16) for i in (0,2,4))

# 空
sky=[(46,32,22),(94,58,36),(138,90,52),(184,122,72)]
for y in range(H):
    t=y/H; i=min(3,int(t/0.3*3)); rect(0,y,W,1,sky[i] if i<3 else hexcol('#B87A48'))

# 霞
for y in range(int(H*0.6)):
    for x in range(0,W,8): rect(x,y,8,1,blend((62,42,30),(138,90,68),0.15))

def hill(x0,y0,x1,y1,c):
    rect(x0,y0,x1,y1,c)

hill(0,640,600,480,hexcol('#3E2A1E'))
hill(200,520,800,420,hexcol('#5E4230'))
hill(400,460,1300,360,hexcol('#7A5440'))
hill(700,400,1600,600,hexcol('#5E4230'))
for k in range(5):
    rect(0,500+k*140,1600,140+6*k,hexcol('#4A3224'))

# 炎
for i in range(6):
    x=300+i*280; r=25+random.random()*20
    for dy in range(-int(r)-40,41):
        for dx in range(-int(r)-50,51):
            d=((dx+20)/(r*1.3))**2+((dy+20)/r)**2
            if d<=1:
                a=1-d
                px_set(x+dx,500+dy,blend((255,208,96),(224,112,32),a*1.6))

# 地面
rect(0,560,W,340,hexcol('#3E3428'))
for i in range(300):
    x=random.random()*W; y=570+random.random()*320
    rect(x,y,random.random()*6+2,random.random()*4+2,hexcol('#4A3C30'))

def soldier(x,y,h,axeDir):
    rect(x,y-h/2,6,h,hexcol('#1A1410'))
    rect(x-2,y-h/2-2,10,4,hexcol('#1A1410'))
    for yy in range(int(y-h/2-16),int(y-h/2)+1): px_set(x+3+axeDir*18,yy,hexcol('#1A1410'))
    for xx in range(int(x),int(x+random.random()*12-6)+1): px_set(xx,y+h/2+8,hexcol('#1A1410'))

def squad(xbase,ybase,count,hstep):
    for i in range(count):
        x=xbase+random.random()*220-110; y=ybase+random.random()*hstep
        soldier(x,y,28+random.random()*20,(i%3==0 and -1) or 1)

squad(200,700,24,60); squad(450,720,20,55); squad(700,690,26,62)
squad(980,730,18,58); squad(1250,710,22,60); squad(100,680,16,55)

# 遠景の兵士列
for i in range(120):
    x=random.random()*W; y=585+random.random()*200; s=0.5+random.random()*0.4
    yy=int(y/s)
    if 0<=yy<H: rect(int(x/s),yy,4,28,hexcol('#0F0C08'))

# 血痕
for i in range(20):
    x=random.random()*W; y=780+random.random()*120
    for dy in range(-int(random.random()*6)-3,int(random.random()*6)+4):
        for dx in range(-int(random.random()*12)-5,int(random.random()*12)+6):
            d=((dx)/(10))**2+((dy)/(5))**2
            if d<=1: px_set(x+dx,y+dy,hexcol('#3A2018'))

for i in range(15):
    x=random.random()*W; y=800+random.random()*100
    rect(x,y,random.random()*20+8,2,hexcol('#2A1A12'))

data=[]
for row in im:
    flat=[]
    for px in row: flat.extend(px)
    data.append(flat)
w=png.Writer(W,H,greyscale=False)
with open('/Users/saitouyouwataru/Documents/Git/Anomaly-Dungeon_doc/work/visual-brainstorm/kilo/sekigahara/sekigahara-view.png','wb') as f:
    w.write(f,data)
print('written')