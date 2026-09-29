-- 8月31日 地形ヘルパ。湖と山に囲まれた谷を、箱の積み重ねではなく地層として作る。
-- 谷底は平らではなく緩い起伏を持ち、尾根は滑らかな稜線で谷を囲む。
local Terrain={}

-- 2つの軸ごとの滑らかな起伏。正弦を足すことで、直線的な台地をやめる。
function Terrain.baseHeight(x,z)
	local h=0
	h=h+math.sin(x*.0062)*13
	h=h+math.cos(z*.0048)*11
	h=h+math.sin((x+z)*.0031)*9
	h=h+math.cos((x-z)*.0025)*7
	return h
end

-- 湖のへこみ。戻り値は「地形そのものの高さ」で、自然地形との差分ではない。
-- 差分にすると、尾根の上に湖が重なったとき湖底が尾根の上に乗ったままになり、
-- 湖底が水面より上になって水が一度も現れない。
-- lake.Water は水面、lake.Depth は最深部、lake.Rim は外縁の水没を防ぐ持ち上げ量。
function Terrain.lakeProfile(distance,lake,naturalHeight)
	if distance>=lake.Inner then return naturalHeight end
	local t=distance/lake.Inner
	local s=t*t*(3-2*t)
	-- 外縁の自然地形が水面以下だと水が湖の外へにじみ出る。湖底側へ寄せる。
	local rim=math.max(naturalHeight,lake.Water+lake.Rim)
	return (lake.Water-lake.Depth)*(1-s)+rim*s
end

-- 尾根。滑らかな山を重なりで作り出す。ridges は {X,Z,Radius,Height} の配列。
function Terrain.ridgeHeight(x,z,ridges)
	local h=0
	for _,r in ipairs(ridges) do
		local dx=x-r.X
		local dz=z-r.Z
		local distance=math.sqrt(dx*dx+dz*dz)
		if distance<r.Radius then
			local t=1-distance/r.Radius
			-- 中心ほど急峻、外周ほど緩やかになるよう滑らかに落とす。
			h=h+r.Height*(t*t*(3-2*t))
		end
	end
	return h
end

-- 湖を含まない自然地形の高さ。尾根も含む。
function Terrain.naturalHeight(x,z,ridges)
	return Terrain.baseHeight(x,z)+Terrain.ridgeHeight(x,z,ridges)
end

-- ゾーンの領域を平らにする。建造物と床板は水平でなければ歩けないため、地形側を合わせる。
-- flats は {X,Z,Width,Depth,Y} の配列。Y は 1000 からの相対高。
function Terrain.flatten(x,z,flats,current,margin)
	margin=margin or 44
	if not flats or #flats==0 then return current end
	-- 完全に内側のゾーンがあれば、そこはその高さで固定する。床板と地表がぴったり一致する。
	for _,f in ipairs(flats) do
		if math.abs(x-f.X)<=f.Width/2 and math.abs(z-f.Z)<=f.Depth/2 then
			return f.Y
		end
	end
	-- ゾーンの外側。近いゾーンほど強く反映し、影響がなくなれば自然地形へ戻す。
	-- 最も近いゾーン 1 つだけを選ぶと、2 つのゾーンの境で高さが飛び、
	-- 不連続な壁になるため、影響するゾーンをすべて重み付けで重ねる。
	local sum,weight=0,0
	local nearest=math.huge
	for _,f in ipairs(flats) do
		local dx=math.max(0,math.abs(x-f.X)-f.Width/2)
		local dz=math.max(0,math.abs(z-f.Z)-f.Depth/2)
		local d=math.sqrt(dx*dx+dz*dz)
		if d<nearest then nearest=d end
		if d<margin then
			-- 距離の二乗の逆数。自身の縁では 1 になり、隣のゾーンの影響は残る。
			local w=1/(1+(d/8)^2)
			sum=sum+f.Y*w
			weight=weight+w
		end
	end
	if weight<=0 then return current end
	local h=sum/weight
	local t=math.clamp(nearest/margin,0,1)
	return h+(current-h)*(t*t*(3-2*t))
end

-- 谷全体の地表面の高さ。lake と ridges を渡すと湖と尾根を含めた高さになる。
function Terrain.heightAt(x,z,lake,ridges,flats)
	local natural=Terrain.naturalHeight(x,z,ridges)
	local h=Terrain.lakeProfile(math.sqrt((x-lake.X)^2+(z-lake.Z)^2),lake,natural)
	return Terrain.flatten(x,z,flats,h)
end

-- 格子状の地表メッシュ。heightFn(x,z) が返す高さに合わせて地块を並べる。
-- 隣接する地块は僅かに重ねて、隙間から空が見えるのを防ぐ。
function Terrain.buildSurface(name,size,origin,heightFn,colorFn,material,parent,step,out)
	step=step or 40
	-- colorFn(x,z,h) がその地块の色を返す。高さと色はここで同時に決める。
	local columns=math.max(2,math.floor(size.X/step))
	local rows=math.max(2,math.floor(size.Z/step))
	local cellX=size.X/columns
	local cellZ=size.Z/rows
	local parts={}
	for i=0,columns do
		local rowParts={}
		for j=0,rows do
			local x=-size.X/2+i*cellX
			local z=-size.Z/2+j*cellZ
			local h=heightFn(origin.X+x,origin.Z+z)
			-- thickness は下方向へ伸ばす。表面が origin.Y+h に一致する。
			-- 厚さは薄く保つ。厚いほど隣接タイルとの高さ差が段差の壁として見える。
			local thickness=2
			local p=Instance.new("Part")
			p.Name=name
			p.Size=Vector3.new(cellX+1,thickness,cellZ+1)
			p.Position=Vector3.new(origin.X+x,origin.Y+h-thickness/2,origin.Z+z)
			p.Color=type(colorFn)=="function" and colorFn(origin.X+x,origin.Z+z,h) or colorFn
			p.Material=material or Enum.Material.Ground
			p.TopSurface=Enum.SurfaceType.Smooth
			p.BottomSurface=Enum.SurfaceType.Smooth
			p.Anchored=true
			p.CanCollide=true
			p.CanTouch=false
			p.CanQuery=true
			p.Parent=parent
			rowParts[#rowParts+1]=p
			if out then out[#out+1]=p end
		end
		parts[#parts+1]=rowParts
	end
	return parts
end

-- 尾根の頂点に使う大きな岩。球を潰して稜線を作る。
function Terrain.cone(name,baseSize,height,position,color,material,parent)
	local p=Instance.new("Part")
	p.Name=name
	p.Shape=Enum.PartType.Ball
	p.Size=Vector3.new(baseSize,height,baseSize)
	p.Position=position
	p.Color=color
	p.Material=material or Enum.Material.Rock
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Anchored=true
	p.CanCollide=true
	p.CanTouch=false
	p.CanQuery=true
	p.Parent=parent
	return p
end

-- 指定領域を平らな地面にする単純な板。建物と道路の下地に使う。
-- 起伏は谷底のメッシュ側で作る。この板はゾーンの床としてだけ使う。
function Terrain.pad(name,size,position,color,material,parent)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.Position=position
	p.Color=color
	p.Material=material or Enum.Material.Ground
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Anchored=true
	p.CanCollide=true
	p.CanTouch=false
	p.CanQuery=true
	p.Parent=parent
	return p
end

return Terrain
