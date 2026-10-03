#!/usr/bin/env python3
"""KOROHKAN 2D 設定画（svgwrite）"""
import random
import svgwrite

W,H=1600,900
dw=svgwrite.Drawing('korohkan-view.svg',size=(W,H),viewBox=(0,0,W,H))
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

def circle(x,y,r,c):
    g.add(dw.circle(center=(x,y),r=r,fill=rgbcol(c),stroke='none'))

# 空
fillgrad=[(30,20,14),(70,50,34),(110,80,54),(150,110,74)]
for y in range(H):
    t=y/H; i=min(3,int(t/0.28*4)); rect(0,y,W,1,fillgrad[i] if i<3 else (210,150,100))

# 遠景山
def hill(x0,y0,x1,y1,c): rect(x0,y0,x1,y1,c)
hill(0,600,500,460,hexcol('#3E3228'))
hill(300,500,900,430,hexcol('#5A4A3C'))
hill(700,480,1600,600,hexcol('#4A3C30'))
hill(0,520,1600,600,hexcol('#3A2E24'))

# 遠景城壁のシルエット
def wall(x,y,w,h,c,blocks):
    rect(x,y,w,h,c)
    for i,b in enumerate(blocks):
        if b: rect(x+i*w//len(blocks),y,y+w//len(blocks),h,hexcol('#2E241C'))
        else: pass
# 外郭門
rect(700,500,200,300,hexcol('#2E241C'))
for i in range(8):
    for j in range(3): rect(720+i*22,515+j*90,18,76,hexcol('#5A4A3C'))
rect(760,520,80,120,hexcol('#4A3A2A'))

# 門の前広場
rect(600,800,400,100,hexcol('#4A3F32'))
# 砦の石垣
rect(100,660,1400,140,hexcol('#3E3428'))
for i in range(28):
    rect(120+i*50,680,44,30,hexcol('#5A4F42'))
    rect(130+i*50,730,44,30,hexcol('#4A3F32'))
    rect(140+i*50,780,44,30,hexcol('#3E3428'))

# 塔
def tower(x,y,w,h):
    rect(x,y,w,h,hexcol('#2E241C'))
    for i in range(4):
        for j in range(3): rect(x+10+i*24,y+15+j*28,14,22,hexcol('#1A1410'))
    rect(x-8,y-30,w+16,24,hexcol('#1A1410'))
    rect(x+8,y-50,8,34,hexcol('#1A1410'))
tower(200,440,120,220)
tower(1300,480,110,200)

# 攻める兵団（中景）
def soldier(x,y,h,axeDir):
    rect(x,y-h/2,6,h,hexcol('#1A1410'))
    rect(x-2,y-h/2-2,10,4,hexcol('#1A1410'))
    for yy in range(int(y-h/2-16),int(y-h/2)+1): rect(x+3+axeDir*18,yy,1,1,hexcol('#1A1410'))
    for xx in range(int(x),int(x+random.random()*10-5)+1): rect(xx,y+h/2+8,1,1,hexcol('#1A1410'))

def squad(xbase,ybase,count,hstep):
    for i in range(count):
        x=xbase+random.random()*180-90; y=ybase+random.random()*hstep
        soldier(x,y,26+random.random()*18,(i%3==0 and -1) or 1)

squad(150,760,18,50)
squad(900,770,20,52)
squad(1250,750,16,48)

# 守る兵（城壁上・裏道）
squad(260,430,8,30)
squad(1240,470,8,30)

# 裏道への坂
for i in range(40):
    x=100+random.random()*800; y=560+random.random()*40
    rect(x,y,random.random()*8+3,2,hexcol('#4A3F32'))

# ラベル
texts=[('外郭の門','400,480'),('砦の石垣','300,620'),('塔','260,420'),('守る兵（城壁）','1000,430'),('攻める兵団（前景）','500,780')]
for t in [('外郭の門',400,480),('砦の石垣',300,620),('塔',260,420),('守る兵（城壁）',1000,430),('攻める兵団（前景）',500,780)]:
    g.add(dw.text(t[0],insert=(t[1],t[2]),fill=rgbcol((255,255,255)),font_size=13))

dw.save()
print('svg written')