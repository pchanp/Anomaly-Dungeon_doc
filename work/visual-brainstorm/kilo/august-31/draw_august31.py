#!/usr/bin/env python3
"""8月31日 2D設定画の描画（純粋 Python + pypng）"""
import random
import struct
import png

W, H = 1600, 900
im = [[(0,0,0)]*(W) for _ in range(H)]

def fill(x0,y0,x1,y1,color):
    x0=int(x0); y0=int(y0); x1=int(x1); y1=int(y1)
    for y in range(max(0,y0),min(H,y1)):
        row=im[y]
        for x in range(max(0,x0),min(W,x1)):
            row[x]=color

def rect(x,y,w,h,color):
    fill(x,y,x+w,y+h,color)

def put(x,y,color):
    x=int(round(x)); y=int(round(y))
    if 0<=x<W and 0<=y<H: im[y][x]=color

def line_x(y,x0,x1,color):
    for x in range(int(x0),int(x1)): put(x,y,color)

def circle(x,y,r,color):
    r2=r*r
    for dy in range(-int(r),int(r)+1):
        for dx in range(-int(r),int(r)+1):
            if dx*dx+dy*dy<=r2: put(x+dx,y+dy,color)

def hexcol(s):
    s=s.lstrip('#')
    return tuple(int(s[i:i+2],16) for i in (0,2,4))

def blend(dst,src,alpha):
    return tuple(int(dst[i]*(1-alpha)+src[i]*alpha) for i in range(3))

# 空
sky=[(135,206,235),(159,216,230),(188,227,240)]
for y in range(H):
    t=y/H
    i=min(2,int(t/0.3667*3)) if t<=0.75 else 2
    fill(0,y,W,y+1,sky[i])

# 霞
for y in range(int(H*0.55)):
    row=im[y]
    for x in range(W): row[x]=blend(row[x],hexcol('#FFF8DC'),0.12)

# 稜線
def hill(xs):
    n=max(W, xs[-1][0])+2
    Y=[H]*n
    for i in range(len(xs)-1):
        x0,y0=xs[i]; x1,y1=xs[i+1]
        dx=x1-x0; dy=y1-y0
        if abs(dx)<1e-6: dx=1e-6
        for xx in range(int(x0),int(x1)+1):
            t=(xx-x0)/dx; Y[xx]=min(Y[xx],y0+dy*t)
    for xx in range(W):
        y=int(Y[xx]); rect(xx,y,W-xx,1,(200,226,203))

hill([(0,620),(400,480),(700,420),(1200,300),(1600,560)])
# 山の重ね
hill([(0,440),(500,460),(1200,340),(1600,560)])
hill([(200,440),(700,420),(1200,300),(1600,560)])
# 稜線木
def trees(x,y,r):
    leaf=hexcol('#759A5A')
    for i in range(14):
        xx=x+random.random()*(r-60)
        circle(xx,y,random.random()*14+10,leaf)
        circle(xx,y+8,random.random()*8+6,hexcol('#4A6B4E'))
trees(280,445,420); trees(560,425,640); trees(980,355,560)

# 湖
for y in range(560,800):
    t=(y-560)/240
    c=hexcol('#5FA8C8') if t<0.4 else hexcol('#6FB8D8') if t<0.7 else hexcol('#5A9AB8')
    rect(300,y,1000,1,c)
# 葦
for i in range(260):
    x=340+random.random()*920
    for dy in range(18): line_x(548-dy,x,x+1,(127,163,107))
# 湖の石
for i in range(30):
    x=400+random.random()*800; y=552+random.random()*40; r=random.random()*9+5
    circle(x,y,r,hexcol('#8B8B83'))

# 河原
rect(260,680,1080,70,(194,178,142))
for i in range(40):
    x=300+random.random()*1000; y=695+random.random()*60; r=random.random()*8+4
    circle(x,y,r,hexcol('#A89878'))

# 田
for i in range(6):
    x=180+i*210
    rect(x,720,180,90,(165,201,110))
    line_x(730,x+10,x+170,hexcol('#8BC46A')); line_x(760,x+10,x+170,hexcol('#8BC46A'))
for i in range(15):
    x=200+random.random()*1000; y=730+random.random()*50
    circle(x,y,random.random()*6+3,hexcol('#7FB04B'))

# 道
rect(90,700,220,340,(184,168,136))
line_x(700,90,310,hexcol('#A89878'))
line_x(820,130,260,hexcol('#A89878'))

# 送電柱
def pylon(x,y):
    rect(x,y,7,180,(139,125,107))
    rect(x-46,y+26,97,6,(107,93,75))
    rect(x-50,y+20,15,18,(107,93,75)); rect(x+35,y+20,15,18,(107,93,75))
    for k,(a,b) in enumerate([(300,60),(600,90),(200,70),(700,110)]):
        cx0,cy0,x0,y0=a,b+28,x+50,y+32
        cx1=200 if k==1 else 600 if k==0 else 700
        # ベジェ風直線近似
        px0,py0=x0-50,y0
        px1=px0+500 if k==0 else px0+300
        py1=py0+60 if k==0 else py0+80
        for i in range(50):
            t=i/49
            mx=px0+(px1-px0)*t+(2*t*(1-t))*(random.random()-0.5)*20
            my=py0+(py1-py0)*t+(2*t*(1-t))*(random.random()-0.5)*20
            for j in range(i,min(i+4,49)):
                t2=j/49
                qx=px0+(px1-px0)*t2+(2*t2*(1-t2))*(random.random()-0.5)*20
                qy=py0+(py1-py0)*t2+(2*t2*(1-t2))*(random.random()-0.5)*20
                line_x(int(qy),int(qx),int(mx),hexcol('#4A4036'))
pylon(140,760); pylon(620,640); pylon(1050,590); pylon(1380,560)

# 集落
houses=[]
for _ in range(4):
    h=(random.random()>0.5)*2
    houses.append((160,60))
def house(x,y,w,h,rch):
    hc=hexcol('#D9CBB2') if random.random()>0.5 else hexcol('#C9B9A0')
    if random.random()>0.5: hc=hexcol('#E0D4BC') if random.random()>0.5 else hexcol('#CDC1A8')
    rect(x,y,w,h,hc)
    # 屋根（三角形）
    for yy in range(int(y-34),int(y)):
        tr=float(yy-(y-34))/34
        lw=int(w/2*(1-tr))
        line_x(yy,int(x-8)+lw,int(x+w+8-lw),rch)
    rect(x+w/2-12,y+h-30,24,30,(92,78,58))
    put(int(x+25),y+25,hexcol('#BFD9E8')); put(int(x+w-14),y+25,hexcol('#BFD9E8'))
    rect(x+10,y+h-24,w-20,8,hexcol('#8B5A2F'))
    for k in range(7): rect(x+14+k*11,y+h-18,4,8,hexcol('#C9A67C'))

house(600,600,70,55,hexcol('#7A4A2A'))
house(760,630,62,48,hexcol('#6E4426'))
house(860,585,78,60,hexcol('#824F2E'))
house(1180,610,66,50,hexcol('#7A4A2A'))

# 団地
def apartment(x,y,w,h):
    rect(x,y,w,h,(180,184,192))
    for r in range(5):
        for c in range(3):
            if random.random()>0.25:
                c2=hexcol('#7FB3D9') if random.random()>0.5 else hexcol('#AAB0B8')
                rect(x+10+c*18,y+8+r*14,14,10,c2)
apartment(1100,400,140,90); apartment(1300,420,130,85)
rect(1080,500,400,70,(157,176,149))
for i in range(12): circle(1100+random.random()*360,502,random.random()*8+5,hexcol('#5F875C'))

# 鳥
for i,(bx,by) in enumerate([(700,200),(450,150)]):
    x1=bx-15 if i==0 else bx-30
    x2=bx-20 if i==0 else bx-30
    y2=by if i==0 else by+10
    line_x(by,bx,x1,(58,58,58))
    line_x(y2,x2,x1,(58,58,58))

# バス停前景
bg=[(143,176,110),(106,138,77)]
for y in range(720,900):
    t=(y-720)/180
    c=bg[0] if t<0.5 else bg[1]
    rect(0,y,W,1,c)
for i in range(120):
    x=random.random()*W; y=730+random.random()*150
    line_x(y,x,x+1,(90,120,61))
for i in range(80):
    x=random.random()*W; y=740+random.random()*130
    circle(x,y,random.random()*4+2,(74,102,52))

# バス停ポール
rect(260,760,10,140,(58,74,62))
rect(220,760,140,0,(53,69,58))
rect(240,730,100,30,(53,69,58))
rect(245,745,80,24,(232,232,224))
# バス停時刻表枠
rect(210,790,140,70,(216,208,192))
rect(214,794,132,4,(74,64,54))
# ベンチ
rect(380,810,130,8,(107,82,56))
rect(388,810,6,52,(91,68,40)); rect(500,810,6,52,(91,68,40))
rect(388,818,116,6,(92,68,46))

# RGB 変換
data=[]
for row in im:
    flat=[]
    for px in row: flat.extend(px)
    data.append(flat)
w=png.Writer(W,H,greyscale=False)
with open('/Users/saitouyouwataru/Documents/Git/Anomaly-Dungeon_doc/work/visual-brainstorm/kilo/august-31/august-31-view.png','wb') as f:
    w.write(f,data)
print('written')
