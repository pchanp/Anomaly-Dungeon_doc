#!/usr/bin/env python3
"""Abandoned TSUTAYA 2D 設定画の SVG 出力（svgwrite）"""
import random
import svgwrite

W,H=1600,900
dw=svgwrite.Drawing('tsutaya-view.svg',size=(W,H),viewBox=(0,0,W,H))
g=dw.add(dw.g(id='layer'))

def rect(x0,y0,x1,y1,c):
    g.add(dw.rect(insert=(x0,y0),size=(x1-x0,y1-y0),fill=rgbcol(c),stroke='none'))

def hexcol(s):
    s=s.lstrip('#')
    return '#%02X%02X%02X'%(int(s[0:2],16),int(s[2:4],16),int(s[4:6],16))

def rgbcol(c):
    if isinstance(c,str):
        c=c.lstrip('#')
        if not c: return (0,0,0)
        if len(c)==6: return '#'+c
        return '#'+hexcol(c)
    return '#%02X%02X%02X'%c

def fillgrad(y0,y1,cs):
    dy=y1-y0
    for y in range(y0,y1):
        t=(y-y0)/dy; i=min(len(cs)-1,int(t*(len(cs)-1)))
        rect(0,y,W,1,cs[i])

# 天井
ceiling=[(58,48,40),(90,74,56),(74,58,42),(46,38,32)]
fillgrad(0,315,ceiling)
floorgrad=[(30,24,18),(20,16,12),(14,12,10),(10,8,8)]
fillgrad(315,700,floorgrad)

# 中景背景
for y in range(400,900):
    rect(0,y,W,1,(60,50,40) if y<410 else rgbcol('#4A3A30'))

# 前景
rect(100,720,400,180,(58,46,34))
rect(160,760,200,40,(201,185,160))
rect(200,800,120,100,(42,34,26))
rect(220,700,80,60,(138,122,106))
rect(230,710,60,40,(191,217,232))
rect(240,718,40,22,(232,224,208))
rect(120,640,140,160,(46,36,28))
rect(124,644,10,152,(106,90,74))
rect(124,700,10,40,(138,122,106))

# 棚
def shelf(x,y,w,h,density):
    c=hexcol('#4A3A2A') if density else hexcol('#5A4A3A')
    rect(x,y,w,h,c)
    band=hexcol('#8A6A5A') if density else hexcol('#7A6A5A')
    for i in range(w*18 if density else w*9):
        g.add(dw.rect(insert=(x+random.random()*w,y+random.random()*h*0.9),size=(1,1),fill=band,stroke='none'))

def titleband(x,y,w,h,colors):
    rect(x,y,w,h,(46,36,28))
    for i in range(len(colors)):
        rect(x+2+i*(w-4)//len(colors),y+2,(w-4)//len(colors)-2,h-4,hexcol(colors[i]))

shelf(180,420,220,460,True)
shelf(420,430,90,450,False)
shelf(920,430,90,450,False)
shelf(1040,420,260,460,True)
titleband(220,640,160,60,['#C9A67C','#8F5A2E','#5F7A9A','#A87A5E','#7A4A2A','#9A7A6E'])
titleband(1100,620,200,70,['#5E7A9A','#7A6A5A','#8F5A2E','#6E5A4A','#9A8A7E'])

rect(680,780,70,30,(139,122,106))
rect(690,770,50,20,(106,90,74))
rect(760,790,50,25,(168,152,136))

for i in range(8):
    x=560+i*42; y=460
    rect(x,y,36,120,(26,20,16))
    rect(x+3,y+6,30,24,(58,46,34))

bg2=[(30,24,18),(20,16,12),(14,12,10),(10,8,8)]
fillgrad(0,300,bg2)
rect(700,180,200,100,(46,36,28))
rect(730,195,60,40,(74,58,42))
rect(810,200,80,30,(42,34,26))
rect(750,210,40,20,(26,20,16))
rect(1050,140,130,220,(58,46,34))
for i in range(18): rect(1060+i*7,155,6,18,(106,90,74))

def crt(x,y,on,color):
    rect(x-10,y-10,180,130,(26,20,16))
    rect(x,y,160,115,(46,36,28))
    if on:
        cr=hexcol(color)
        for dy in range(-60,61):
            for dx in range(-75,76):
                d=(dx*dx+dy*dy)/5625
                if d<=1:
                    a=1-d
                    g.add(dw.rect(insert=(x+80+dx,y+35+dy),size=(1,1),fill=blend(cr,(0,0,0),1-a),stroke='none'))
        for i in range(60):
            g.add(dw.rect(insert=(x+random.random()*160,y+random.random()*115),size=(2,2),fill=rgbcol((255,255,255)),stroke='none'))
    else:
        for dy in range(-40,41):
            for dx in range(-60,61):
                d=(dx*dx+dy*dy)/3600
                if d<=1:
                    a=1-d
                    g.add(dw.rect(insert=(x+80+dx,y+35+dy),size=(1,1),fill=blend((58,58,58),(0,0,0),1-a),stroke='none'))

def blend(a,b,a2):
    if isinstance(a,str): a=tuple(int(a.lstrip('#')[i:i+2],16) for i in (0,2,4))
    if isinstance(b,str): b=tuple(int(b.lstrip('#')[i:i+2],16) for i in (0,2,4))
    return '#%02X%02X%02X'%tuple(int(a[i]*(1-a2)+b[i]*a2) for i in range(3))

crt(300,320,True,'#7FD9E9')
crt(1000,330,True,'#E9D97F')
crt(700,560,False,'#3A3A3A')

def lamp(x,y,w,h,alive,brightness):
    if not alive: return
    lx,ly=x+w//2,y+h//2
    for dy in range(-int(h*0.9),int(h*0.9)+1):
        for dx in range(-int(w*0.7),int(w*0.7)+1):
            d=((dx)/(w*0.75))**2+((dy)/(h*0.95))**2
            if d<=1:
                a=1-d
                g.add(dw.rect(insert=(lx+dx,ly+dy),size=(1,1),fill=blend((255,250,220),(255,240,180),brightness*a*1.8),stroke='none'))

def blend2(a,b,alpha):
    if isinstance(a,str): a=hexcol(a)
    if isinstance(b,str): b=hexcol(b)
    return '#%02X%02X%02X'%tuple(int(a[i]*(1-a2)+b[i]*a2) for i in range(3))

lamp(260,60,260,16,True,0.7)
lamp(640,70,300,14,True,0.5)
lamp(1000,65,240,14,True,0.6)
lamp(620,160,220,12,False,0)
lamp(1100,150,200,12,True,0.3)

for t,(x,y) in {'入口・レジ':(140,600),'VHS/DVD 棚（背表紙密度）':(90,500),'CD 棚':(1360,500),
                '中央通路':(560,430),'VHS 選曲コーナー':(560,600),'放送室（暗）':(800,120),
                '未整理ケース棚':(1060,100),'落下ケース':(1020,820)}.items():
    g.add(dw.text(t,insert=(x,y),fill=rgbcol((255,255,255)),font_size=13))

dw.save()
print('svg written')