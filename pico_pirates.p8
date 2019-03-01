pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (26/2/18)
-- Token count 7918 / 8192
--	remaining tokens:	 274
-- 21 func ___name instances = 63 tokens that acn be reallocated

state,nextState,st_t=3,1,5
--0 splash screen
--1 top down exploration
--2 screen transition
--3 side view combat
--4 treasure view

printStats,drawClouds,projectiles=false,true,{}

function stringToArray(str)
	local a,l={},0
	while l<#str do
		l+=1
		if sub(str,l,l)=="," then
 		add(a,tonum(sub(str,1,l-1)))
 		str,l=sub(str,l+1),0
		end
	end
	return a
end

camx,camy,cellseed,currentcell,cellwind,celltype=0,0,0,{},{},""
fillps=stringToArray"0b0101101001011010.1,0b111111111011111.1,0b1010010110100101.1,★"

function _________built_in_funcitons()
		--remove me
end

function _init()
	srand(1)
	currentcellx,currentcelly=flr(rrnd(2,30)),flr(rrnd(2,30))
	world_init()
	if (state==3) comb_init(1)
	clouds={}
	for i=0,50 do
		local cloud={
			x=camx+rnd(127),y=camy+rnd(127),
			r=4+rnd(10),z=rrnd(1.5,2),vx=0,vy=0,
			update=function(c)
				local x,y,vx,vy=c.x,c.y,c.vx,c.vy
				x+=cellwindy
				y-=cellwindx
				if (x+vx>camx+128) x-=128
				if (y+vy>camy+128) y-=128
				if (x+vx<camx-0) x+=128
				if (y+vy<camy-0) y+=128

				vx=(x-camx-64)*c.z
				vy=(y-camy-64)*c.z

				c.vx=mid(0xff80,vx,128)
				c.vy=mid(0xff80,vy,128)
				c.x,c.y=x,y
			end,
			draw=function(c)
				fillp(fillps[2-flr(c.r/8)])
				_circfill(c.x+c.vx,c.y+c.vy,c.r,7)
				fillp()
			end
		}
		add(clouds,cloud)
	end
	setcell()
end

function _update()
	if state==0 then
		if (btnp(5)) state=2 st_t=0
	elseif state==1 then
		cls()
		--check if boat is outside cell range
		checkboatpos()
		if (celltype=="island") island.update()
		if (celltype=="whirlpool") wp_update()
		if celltype=="enemy" then
			for i=0,4 do
				local r=rnd"1"
				local d=rnd(i*32)
			 	newWave(sin(r)*d,-cos(r)*d)
			end
		end
		if (player.draw) player_update(player)
		map=btn"4"
		--4% CPU usage
		for c in all(clouds) do
			c.update(c)
		end
		if map then
			mapPos=max(mapPos-16,0)
		else
			mapPos=min(mapPos+16,127)
		end
		if (not player.draw) boat.update(boat)
	elseif state==2 then
	elseif state==3 then
		for c in all(comb_objs) do
			c.update(c)
	 	end
	elseif state==4 then
		update_island_chest_view()
	end
	st_t+=0.016666--1/60
end

once=true
function _draw()
	if (state==0) splash_screen()

	--Draw top down view of world
	if state==1 then
		camera(camx,camy)
		cls(12)
		--draw island dark blue backdrop before waves
		if celltype=="island" then
		 	for b in all(island.beach) do
				_circfill(b.x,b.y,b.rad+16,1)
			end
		end
		--draw waves from ship
		fillp(0b0101101001011010.1)
		for w in all(waves) do
			w.draw(w)
		end
		fillp()
		if (celltype=="island") island.draw()
		if (celltype=="whirlpool") wp_draw()
		if celltype=="enemy" then
			if (abs(boat.x) < 64 and abs(boat.y) < 64) state,nextState,st_t=2,3,0
		end
		boat.draw(boat) 	--60% CPU usage
		if drawClouds then
			for c in all(clouds) do
				c.draw(c)
			end
		end
		draw_minimap()
		draw_morale_bar()
		local r =atan2(cellwindx,cellwindy)
		for c=0,1 do
			pal(6,7^c)
			spr_rot(26,2,12,camx+120,camy+44-c,r,0)
			pal()
		end

		print_u("wIND",camx+112,camy+30)
		--print_u("wx: "..cellwindx,camx+64,camy+48)
		--print_u("wx: "..cellwindy,camx+64,camy+56)
		if (mapPos<127) draw_map()
	elseif state==2 then
		if st_t>0 and st_t<.8 then
			st_horizbars_out()
		end

		--this is very messy, but basically runs the vector smoothing function
		-- 9 times whilst the screen is completely black during the splash
		-- screen being off screen and just before the vertical bars start
		if once then
			if st_t>.8 and st_t <1.1 then
				cls(0)
				--"Loading"
				print_str('4c6f6164696e67',76,127,12)
				for i=0,(t()*12)%4 do
					_pset(120+i*2,126,1)
					_pset(120+i*2,125,12)
				end

				--smooth wind vectors for cells
				for _x=1,#cells do
					for _y=1,#cells[_x] do
						local xs=stringToArray"1,-1,0,0,★"
						local ys=stringToArray"0,0,1,-1,★"
						local self=cells[_x][_y]
						for i=1,#xs do
							local adjCell=cells[mid(1,flr(_x+xs[i]),#cells-1)][mid(1,flr(_y+ys[i]),#cells[_x]-1)]
							self.windx+=adjCell.windx
							self.windy+=adjCell.windy
						end
						self.windx/=5
						self.windy/=5
					end
				end
			end
		end

		--exit state condition
		if st_t>1 then
			state=nextState
			if (nextState==3)	comb_init(rnd"1")--change me!
			if (nextState==4)	init_island_chest_view()
			once=false
		end
	elseif state==3 then
		cls(12)
	  screenShake()
	  _circfill(124,8,24,10)

		--will be writing to screen + spritesheet here
		boat_text(boat_message)

	  for c in all(comb_objs) do
	 	 c.draw(c)
	 	end
	 	drawUpdateWater()

		--water reflections
		local h=2048 --32*64
		if (morale>0) h=1024 --24*64
		memcpy(0x2000-h,0x7940-h,h)
		palt(12,true)
		palt(1,true)
		pal_all"13"
		for y=1,(h/64)-1 do
			sspr(0,127-y,128,1,sin(t()+y/20)*(y/5),101+y)
		end
		for x=0,127 do
			local c=sget(x,127)
			if (pget(x,101)==1 and c!=12 and c!=7 and c!=1) pset(x,101,c)
		end

		pal()

	  if victory then
	 	 local cols={}
	 	 pal(15,sget(min((t()-victory_time)*15,4),9))
	 	 rectfill(0,48,127,64,0)
	 	 sspr(0,77,112,15,7,49,114,17)
	 	 pal(15,sget(min((t()-victory_time)*15,11),8))
	 	 sspr(0,77,112,15,8,50)
	 	 pal()
	 	 celltype="sea"
	 	 currentcell.type="sea"
	 	 if (t()-victory_time > 3) state=2 st_t=0 nextState =1
	  elseif morale>0 then
	 	 cannonLines(2+comb_boat.x,5+comb_boat.y,comb_boat)
 	 	 if (tentacles==null) cannonLines(2+enemy.x,5+enemy.y,enemy)
	 	 drawEnemyHP()
	 	end
		draw_morale_bar()
	elseif state==4 then
		draw_island_chest_view()
	end

	if st_t>.8  and st_t < 2.5 and state!=4 then
		st_vertbars_in()
	end

	if printStats then
		rectfill(camx,camy+14,camx+66,camy+31,5)
		rect(camx,camy+14,camx+66,camy+31,0)
		print_u("mEMORY: "..stat(0),camx+2,camy+16)
		print_u("cPU: "..stat(1),camx+2,camy+24)
	end
	tempFlip=false
end

function ___________top_down__HuD()
		--remove me
end

mapPos=127

function draw_map()
	--Draw base map
	local _y=camy+20
	local _x=camx-mapPos+1
	_sspr(121,0,4,105,_x,camy+18)
	_sspr(124,0,4,104,_x+107,camy+18)
	_sspr(0,70,109,4,_x,camy+15)
	_sspr(0,73,109,4,_x,camy+122)
	rectfill(_x+3,_y-2,_x+107,_y+102,15)
	_x+=4

	--Fill map in with discovered areas
	for x=1,32 do
		for y=1,32 do
			if cells[x][y].visited then
				_circfill(_x+x*3,_y+y*3,3,13)
			end
		end
	end
	for x=1,32 do
		for y=1,32 do
			if cells[x][y].visited then
				_circfill(_x+x*3,_y+y*3,2,12)
			end
		end
	end
	for x=1,32 do
		for y=1,32 do
			if cells[x][y].type=="island" then
				_circfill(_x+x*3,_y+y*3,1,15)
			elseif cells[x][y].type=="whirlpool" and cells[x][y].visited  then
				_circfill(_x+x*3,_y+y*3,1,7)
			elseif cells[x][y].type!="sea" then
				_circfill(_x+x*3,_y+y*3,0,13)
			end
		end
	end
	_x+=boat.x/128
	_y+=boat.y/128
	if (flr(t()*4)%2>0) _pset(_x+currentcellx*3,_y+currentcelly*3,4)
end

function draw_minimap()
	print_u(currentcellx,camx+102,camy+5)
	print_u(currentcelly,camx+116,camy+18)

	_rectfill(camx+111,camy,camx+127,camy+16,12)
	_rect(camx+111,camy,camx+127,camy+16,7)
	if (celltype=="island") _circfill(camx+119,camy+8,island.size/16,15)
	if celltype=="whirlpool" then
		fillp(fillps[1])
		_circfill(camx+119,camy+8,4,7)
		fillp()
	end
	--player indicator on minimap
	_pset(camx+112+flr(((boat.x+256)/512)*14),camy+1+flr(((boat.y+256)/512)*14),4)
end

playerHpTimer=0
prevMorale=100
function draw_morale_bar()
	--"Morale"
	print_str('4d6f72616c65a',camx+1,camy+11,7)
	local x=camx+42
	local y=camy+1
	local _x=x+57
	local l=lerp(57,0,morale/100)
	local _l=lerp(57,0,prevMorale/100)
	local _y=y+10

  if playerHpTimer>0 then
     playerHpTimer=max(0,playerHpTimer-.1)
     if (playerHpTimer<=1) _l=lerp(l,_l,playerHpTimer)
  else
    prevMorale=morale
    _l=l
  end
  --Drawing morale bar
	_rectfill(x,y,_x,_y+1,1)
	_rectfill(x,y,_x-_l,_y,14)
	_rectfill(x+1,y+1,_x-l,_y-1,8)
	_rect(x,y,_x-_l,_y-1,2)
	_rect(x,y,_x,_y,7)
end

function ___________________cool_flip()
		--remove me
end

tempFlip=false

function putAFlipInIt()
	tempFlip=true
end

function _circ(x,y,r,c)
	if x+r>camx and x-r<camx+128 and y+r>camy and y-r<camy+128 then
		if (tempFlip) flip()
		circ(x,y,r,c)
	end
end

function _circfill(x,y,r,c)
	if x+r>=camx and x-r<=camx+128 and y+r>=camy and y-r<=camy+128 then
		if (tempFlip) flip()
		circfill(x,y,r,c)
	end
end

function _pset(x,y,c)
	if (tempFlip) flip()
	pset(x,y,c)
end

function _line(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	line(x1,y1,x2,y2,c)
end

function _rect(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	rect(x1,y1,x2,y2,c)
end

function _rectfill(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	rectfill(x1,y1,x2,y2,c)
end

function _spr(n,x,y,tx,ty)
	if (tempFlip) flip()
	spr(n,x,y,tx,ty)
end

function _sspr(sx,sy,sw,sh,dx,dy)
	if (tempFlip) flip()
	sspr(sx,sy,sw,sh,dx,dy)
end

function ______________________meta()
		--remove me
end

function splash_screen()
	cls(0)
	--a->z = 97->122
	--a->z = 65->90

	printlogo() -- 42% CPU usage

	local x=stringToArray"24,26,16,52,64,★"
	local y=stringToArray"72,82,112,112,112,★"
	local c=stringToArray"7,12,7,8,7,★"
	local strs={'412067616d65206d616465206279','43726169672054696e6e6579','5072657373','58','746f207374617274'}
	for i=1,5 do
		local _y=y[i]
		if (i>2) _y+=sin(t()*.5)*4
		print_str(strs[i],x[i],_y,c[i])
	end
end

--screen transition
function st_horizbars_out()
	--1.2s duration
	--draw black bars
	local a=0
	for y=0,127 do
		if y%2==0 then
			_line(camx+127,camy+y,camx+127-(st_t*59),camy+y,0)
		else
			_line(camx,camy+y,camx+st_t*59,camy+y,0)
 		end
	end
	for y=0,127 do
		local scr=0x6000+(y*64)
		local l=-(st_t*2)
		if (y%2==0) l=(st_t+.48)*2
		memcpy(scr,scr+l,64)
	end
end

function st_vertbars_in()
	for x=0,127 do
		local _x=x+camx
		local _y=camy
		if x%2==0 then
			_line(_x,-1+_y,_x,_y+264-(st_t*120),0)
		else
			_line(_x,128+_y,_x,_y+(st_t*120)-137,0)
 		end
	end
end

function _______________pirate_crew()
		--remove me
end

morale=100

function ___________top_down_boat()
		--remove me
end

boat={
	x=-0xff60,y=0xff60,r=0,d=0,
	mx=0,my=0,max=2.5,--momentum x+y
	update=function(b)
		local speed,c,s=.05,cos(b.r),sin(b.r)
		local sc=(s*s)+(c*c)

		if(btn(0)) b.r=b.r%1+.01
		if(btn"1") b.r=b.r%1-.01

		b.mx+=cellwindy*.05
		b.my-=cellwindx*.05

		if btn"2" then
			b.mx+=s*speed
			b.my-=c*speed
			sfx(0)
		else
			b.mx*=.99
			b.my*=.99
		end
		b.mx,b.my=mid(-b.max,b.mx,b.max),mid(-b.max,b.my,b.max)
		sc=abs(b.mx*b.my)
		b.d+=sc
		if (flr(b.d)>2) newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4) b.d=0

		b.x,b.y=flr((b.x+b.mx)*2)/2,flr((b.y+b.my)*2)/2

		camx,camy=flr(boat.x-64),flr(boat.y-64)
		if checklandcol(b.x,b.y,b.r) and not map and not player.draw then
			player.draw=true
			sfx(3)
			player.x=b.x+sin(b.r)*8
			player.y=b.y-cos(b.r)*8
			b.mx=0 b.my=0
		end
	end,
	draw=function(b)
		if t()%.25==0 then
			newWave(b.x-sin(b.r)*4,
			b.y+cos(b.r)*4)
		end
		pal(0,5)
		spr_rot(-4,91,13,flr(b.x),flr(b.y),b.r,6)
	end
}

--check land collision
function checklandcol(x,y,r)
	local j=stringToArray"-r*2,0,.75,.25,★"
	local bool=false
	for i in all(j) do
		bool=bool or pget(x-sin(r+i)*8,y+cos(r+i)*8)==15
	end
	return bool
end

waves={}
function newWave(_x,_y)
	local w={
	x=flr(_x),y=flr(_y-1),r=2,
	draw=function(w)
		_circ(w.x,w.y,w.r,7)
		w.r+=0.2
		if (w.r>10) del(waves,w)
	end
	}
	add(waves,w)
end

function _______world_management()
		--remove me
end

function world_init()
	cells={}
	for cx=0,31 do
		local subcell={}
		add(cells,subcell)
		for cy=0,31 do
			--random wind vectors
			local wx=rrnd(.25,1)
			if (rnd"1">.5) wx*=0xffff
			local wy=rrnd(0.25,1)
			if (rnd"1">.5) wy*=0xffff

			local _type=""
			if rnd"1">.925 then
				 _type="island"
			elseif rnd"1">.7 then
				 _type="enemy"
			elseif rnd"1">.99 then
				 _type="whirlpool"
			else
				_type="sea"
			end
			add(subcell,{type=_type,treasure=1,seed=rnd(4096),windx=wx,windy=wy,visited=false})
		end
	end
end

function cell_shift(x,y)
	boat.x+=x
	boat.y+=y
	for w in all(waves) do
		w.x+=x
		w.y+=y
	end
	for c in all(clouds) do
		c.x+=x
		c.y+=y
	end
	setcell()
end

function checkboatpos()
	if (boat.x < 0xff00) then
		currentcellx-=1
		if (currentcellx<1) currentcellx+=#cells
		cell_shift(512,0)
	elseif (boat.x > 256) then
		currentcellx+=1
		if (currentcellx>#cells) currentcellx=1
		cell_shift(0xfe00,0)
	elseif (boat.y < 0xff00) then
		currentcelly-=1
		if (currentcelly<1) currentcelly+=#cells[currentcellx]
		cell_shift(0,512)
	elseif (boat.y > 256) then
		currentcelly+=1
		if (currentcelly>#cells) currentcelly=1
		cell_shift(0,0xfe00)
	end
end

function setcell()
	wp_ps={}
	fps={}
	currentcell=cells[currentcellx][currentcelly]
	currentcell.visited=true
	cellwindx=currentcell.windy
	cellwindy=currentcell.windx
	cellseed=currentcell.seed
	celltype=currentcell.type
	if celltype=="island" then
		createisland(cellseed)
	elseif celltype=="whirlpool" then
		wp_init()
	end
end

function _________island_generation()
		--remove me
end

island={
	update=function()
		for t in all(island.trees) do
			t.update(t)
		end
		--drawing beach for boat colision
		for b in all(island.beach) do
			circfill(b.x,b.y,b.rad,15)
		end
	end,
	draw=function()
		--white wave crest
		for b in all(island.beach) do
			_circ(b.x,b.y,b.rad+((1+sin(t()*.2))*8)+1,7)
			_circ(b.x,b.y,b.rad+((1+sin(t()*.2))*8),7)
		end
		--wet sand
		for b in all(island.beach) do
			_circfill(b.x,b.y,b.rad+((1+sin(t()*.2))*8),13)
		end
		--beach
		for b in all(island.beach) do
			_circfill(b.x,b.y,b.rad,15)
		end
		for b in all(island.beach) do
			_circfill(b.x+(b.r0*8),b.y+(b.r0*8),b.rad/15,6)
		end

		if (island.size > 8) _circfill(0,0,island.size*.8,6)
		if (island.size > 16) _circfill(0,0,island.size*.5,4)

		fillp(fillps[2],-camx,-camy)
		if (island.size > 6) _circfill(0,0,island.size*1.35,6)
		fillp(0b0101101001011010.1,-camx,-camy)
		if (island.size > 16) _circfill(0,0,island.size*.35,9)
		fillp()
		--draw trees
		for t in all(island.trees) do
			if(t.c<2) t.draw(t)
		end

		for f in all(fps) do
			f.draw(f) --draw footprints
		end

		--draw treasure cross
		if currentcell.treasure!=0 then
			local sx=1+sin(t())*2
			local crossX=sin(currentcell.seed/4096)*island.size-sx/2
			local crossY=cos(currentcell.seed/4096)*island.size-sx/2
			if (abs(crossX-player.x) < 6 and abs(crossY-player.y) < 6) state=2 st_t=0 nextState=4
			_sspr(110,0,10,11,crossX,crossY,10+sx,11+sx)
		end

		if (player.draw) player_draw(player)
		for t in all(island.trees) do
			if(t.c>1)t.draw(t)
		end
	end
}

function createisland(seed)
	srand(seed)
	--radius of this new island
	island.size=rrnd(6,70)
	local size=island.size
	--create the various _circles required to create this island
 	local total_circs=max(size/8,5)
	island.beach,island.wetsand,island.waves={},{},{}
	for i=0,total_circs do
		--offset around the overall island _circle to place this new _circle to be drawn
		local r=i/total_circs

		add(island.beach,{
			x=cos(r)*size,y=-sin(r)*size,
			rad=(size)*(rrnd(.7,1.3)),
			r0=rrnd(0xffff,1),r1=rrnd(0xffff,1),r2=rrnd(0xffff,1),r3=rrnd(0xffff,1)
		})
	end

	--now for some trees
	island.trees={}
	if size > 24 then
		size*=.5
		for i=0,size/2 do
			local r=i/(size/2)
			sz=rrnd(8,12)
			newtree(rrnd(0xfffb,5)+cos(r)*size,rrnd(0xfffb,5)-sin(r)*size,sz)
		end
		for i=0,size/4 do
			local r=i/(size/4)
			sz=rnd"2"+10
			newtree(rrnd(0xfffb,5)+(rnd"1"-.5)*size,rrnd(0xfffb,5)-(rnd"1"-.5)*size,sz)
		end

		--sort trees by z value
		local a=island.trees
		for i=1,#a do
		 local j = i
		 while j > 1 and a[j-1].z > a[j].z do
			a[j],a[j-1] = a[j-1],a[j]
			j=j-1
		 end
		end
	end
end

function toggleClouds()
	drawClouds = not drawClouds
end

function toggleStats()
	printStats = not printStats
end

menuitem(1, "toggle clouds", toggleClouds)
menuitem(2, "toggle stats ", toggleStats)
menuitem(3, "do a flip()!", putAFlipInIt)

function newtree(_x,_y,s)
	local z=rrnd(1,1.5)

	local z_array={0,0,0,z-.25,z-.15,z,z+.5,z+1,z+1.25,z+1.5}
	local c_array=stringToArray"4,1,1,3,3,3,11,11,7,7,★"
	local r_array=stringToArray".25,1,1.1,1,.9,.8,.667,.5,.25,.2,★"
	local fillp_array=stringToArray"0x0000,0b1010010110100101.1,0b0101101001011010.1,0b111111111011111.1,0b0101101001011010.1,0x0000,0b0101101001011010.1,0x0000,0b0101101001011010.1,0x0000,★"
	for i=1,10 do
		local tree={
			x=_x,y=_y,z=z_array[i]*.1,
			vx=0,vy=0,
			c=c_array[i],r=s*r_array[i],
			palette=fillp_array[i],
			update=function(t)
				t.vx=(t.x-camx-64)*t.z
				t.vy=(t.y-camy-64)*t.z
			end,
			draw=function(t)
				fillp(t.palette,-camx,-camy)
				_circfill(t.x+t.vx,t.y+t.vy,t.r,t.c)
				fillp()
			end
		}
		add(island.trees,tree)
	end
end

function _________walk_about_islands()
		--remove me
end

player={
	x=0,y=0,draw=false,speed=1,
	fp_dist=0, dir=0
}

function	player_update(p)
	if abs(p.x-boat.x) < 4 and abs(p.y-boat.y) < 4 then
		p.draw=false
		sfx(4)
		--push boat away from centre of island
		--island always found at (0,0)
		--vector topush boat away is same as position(normalised)
		magnitude=sqrt((boat.x*boat.x) + (boat.y*boat.y))*.1
	  boat.x+=boat.x/magnitude
		boat.y+=boat.y/magnitude
	end

	if (btn(0)) p.x-=p.speed p.fp_dist+=1
	if (btn"1") p.x+=p.speed p.fp_dist+=1
	if (btn"2") p.y-=p.speed p.fp_dist+=1
	if (btn"3") p.y+=p.speed p.fp_dist+=1

	camx,camy=player.x-64,player.y-64
end

function	player_draw(p)
	p.speed=1
	local c=pget(p.x,p.y)
	if (c==12) p.speed=.1
	if p.fp_dist>2 then
		if c==15 then
			add(fps,{x=p.x, y=p.y, draw=function(f)_pset(f.x,f.y,13)end})
			sfx(1)
		else
			sfx(12)
		end
		p.fp_dist=0
	end

	_circfill(p.x,p.y,1,0)
end

fps={}--footprints
function new_footprint(x,y)

end


function _________________island_loot()
		--remove me
end

function init_island_chest_view()
	camera(0,0)
	camx,camy=0,0
	poke(0x5f2c,3)
	sand,staticSand,chestClouds,circTrans_start,circTrans_end,sandIndex,chestPos,chestCol={},{},{},t(),0,1,53,4
	for i=0,15 do
		add(chestClouds,{x=rnd(72),y=rnd(4),r=rrnd(1,4)})
	end
	for _x=0,8,0.5 do
		for _y=1,3 do
			add(staticSand,{x=_x*8,y=_y*8+(48-_x^1.05),r=6})
		end
	end
	srand(3)
	for y=0,8,.75 do
		for x=-3,5 do
			if (y%2==0) x*=0xffff
			local grain={
				x=32+x*2,y=54+y*.4,
				vx=0,vy=0,r=rrnd(2,5),
				update=function(s)
					if (s.vx!=0) s.r-=0.1 s.vy+=0.5
					s.x+=s.vx
					s.y+=s.vy
				end,
				draw=function(s)
					circfill(s.x,s.y,s.r,15)
				end
			}
			add(sand,grain)
			if (y%2==0) x*=0xffff
		end
	end
end

function circTransition(x,y,t)
	for i=72,t-16,-1 do
		for _a in all(stringToArray"0,1,0xffff,★") do
			circ(x,y+_a,i,0)
		end
	end
end

function update_island_chest_view()
	if flr(chestPos)>44 and btnp(4) then
		sfx(7-rnd"2")
		for i=0,9 do
			if sandIndex<#sand+1then
				circTrans_end=t()
				local grain=sand[sandIndex]
				grain.vy-=4+rnd(2)
				grain.vx=.5+rnd(1)
				grain.r-=1.5
				if (rnd"1">.5) grain.vx*=0xffff
				sandIndex+=1
				chestPos-=0.1
				if (flr(chestPos)==44) sfx(7)
			end
		end
	end
	for s in all(sand) do
		s.update(s)
	end
end

chestCols={
	stringToArray"8,9,10,2,4,5,1,★",--red
	stringToArray"4,13,6,2,5,5,1,★",--grey
	stringToArray"3,9,10,1,4,5,0,★",--green
	stringToArray"13,4,9,1,2,2,1,★"--13 = orange
}

function draw_island_chest_view()
	cls(12)
	pal()
	--draw clouds
	for c in all(chestClouds) do
		c.x+=c.r*.05
		circfill((c.x-3)%72,c.y,c.r,7)
	end

	--draw water
	rectfill(0,28,127,127,1)

	--draw land
	local _pals={7,13,15}
	local p=sin(t()*.5)
	local w=4+p*2.5
	local r={w+1,w,0}
	local x={1+p,1+p,0}

	for i=1,3 do
		pal(15,_pals[i])
		for s in all(staticSand) do
			circfill(s.x+x[i],s.y,s.r+r[i],15)
		end
	end

	local h=16
	local	w=18
	--draw chest
	for i=1,#chestCols[1] do
		pal(chestCols[1][i],chestCols[chestCol][i])
	end
	if flr(chestPos)==44 then
		sspr(59,0,w,h,32-w/2,chestPos-h/2,w,h)--draw open chest
		pal()
		?"yOU FOUND SOME\n   TREASURE!",4,16,0
		?"yOU FOUND SOME\n   TREASURE!",4,15,9.5+p
		sspr(80,0,12,5,25,40)--draw chest contents
	else
		--draw closed chest
		_sspr(40,0,w,h,32-w/2-sin(chestPos/1.5)*.5,chestPos-h/2,w,h)
	end

	--draw sand particles
	for s in all(sand) do
		s.draw(s)
	end

	if flr(chestPos)==44 then
		circTransition(32,32,128+((circTrans_end-t()))*50)
		if circTrans_end-t()<-2.5 then
			--exit treasure chest state
			cls(0)
			poke(0x5f2c,0)
			nextState,state,st_t=1,2,1
			currentcell.treasure=0
		end
	else
		circTransition(32,32,(t()-circTrans_start)*50)
	end
end

function ________________whirlpools()
		--remove me
end

wp_ps={}--whilrpool points

function wp_init()
	local tot=48
	for i=0,tot do
		local _r=(192/tot)*i
		local _o=rnd"2"
		for j=0,4 do
			add(wp_ps,{x=0,y=0,r=_r,o=_o})
		end
	end
end

function wp_update()
	for p in all(wp_ps) do
		local t_=t()+p.o-rnd(.4)
		p.x=64+(sin(t_*(15/p.r))*p.r)+rnd(p.r*.03125)
		p.y=64-(cos(t_*(15/p.r))*p.r)+rnd(p.r*.03125)
	end
end

function wp_draw()
	--_circfill(64,64,128,1)
	--fillp(fillps[1])
	local _p;
  for p in all(wp_ps) do
		if (_p and _p.r==p.r and p.r > 8) then
			_line(p.x,p.y,_p.x,_p.y,7)
		else
			--_circfill(p.x,p.y,p.r*.015625,7)
		end
		_p=p
    --_pset(p.x,p.y,7)
  end
	--fillp(0)
end

function _________________fancy_text()
		--remove me
end

function print_s(_x,_y,_l,c)
	--total_layers=4
	--letters_per_layer=7
	--letter size, 7*7

	--Find index of letter to print and which colour layer to look at
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	_sspr(7*l,16,7,7,_x,_y-6)
	set_col_layer(c,layer)
	_sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	_sspr((12*l)+37,23,12,11,_x,_y-9)
	set_col_layer(c,layer)
	_sspr((12*l)+37,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	local layer=(_l-l)/3
	for x=0,11 do
		local wiggle=sin(t()*-.33+((_x+x)*.018))*2
		set_col_layer(13,layer)
		_sspr((12*l)+x,23,1,21,_x+x,_y+wiggle+1)
		set_col_layer(c,layer)
		_sspr((12*l)+x,23,1,21,_x+x,_y+wiggle)
	end
	pal()
end

function print_str(_str,x,y,c)
	local str={}
	for i=1,#_str,2 do
		add(str,('0x'..sub(_str,i,i+1))+0)
	end
	local p=x

	-- for each letter
	for s=0,#str-1 do
		--if ascii value > 96, lower case letter
		if str[s+1]>96 then
			print_s(p,y,str[s+1]-97,c)
			--move cursor for x position over by slightly smaller amount
			-- since lower case letters are smaller than upper case (duh)
			p+=6
		else
			print_l(p,y,str[s+1]-65,c)
			p+=9
			if (str[s+1]<65)p-=6
		end
	end
end

function printlogo()
	--ico
	local xls=stringToArray"59,69,81,★"
	for i=1,#xls do
		print_xl(xls[i],5,i-1,7)
	end

	local wx_array=stringToArray"14,14,36,36,★"
	local y_array=stringToArray"33,32,5,4,★"
	local pal_array=stringToArray"13,7,13,7,★"

	--big Ps
	for i=1,4 do
		for x=0,23 do
			pal(1,pal_array[i])
			local a=x+wx_array[i]
			_sspr(x,44,1,26,a,y_array[i]+sin(t()*-.33+(a*.018))*2)
		end
	end

	--pirates
	xls=stringToArray"37,47,60,72,80,92,104,★"
	local ls=stringToArray"0,3,4,5,7,8,9,★"
	for i=1,#xls do
		print_xl(xls[i],32,ls[i],7)
	end
end

function set_col_layer(c,b)
	b=2^b
	for i=0,15 do
		if (band(shl(i),b)>0) then
			pal(i,c)
		else
			palt(i,true)
		end
	end
end

function ____________________COMBAT()
	--#RemoveMe
end

--comb_boat combat-
function comb_init(enemyType)
	camx,camy,comb_objs,victory=0,0,{},false
	camera(0,0)
	for j=1,0,0xffff do
		srand"1"
		for i=0,25 do
			local x,y=rnd(127),rrnd(8,40)
			local r,vx=rrnd(4,12),rnd(.5)
			newCombCloud(x+j*2,y+j,r+j,7-j,vx)
		end
	end
	comb_boat=newComb_boat()
	comb_boat.hp=morale
	comb_boat.isPlayer=true
	boat_message="aLL HANDS\nON DECK! "
	txt_timer=0xfffa
	add(comb_objs,comb_boat)

	if enemyType==0 then
		enemyName="wATERY FIEND"
		enemy=newOctopus()
			add(comb_objs,enemy)
	else
		enemyName="aN BOAT"
		enemy=newComb_boat()
		enemy.isPlayer=false
		enemy.x=114
	end
	add(comb_objs,enemy)

	for	i=0,159 do
		add(wpts,0)
		add(prevwpts,0)
	end
	music(0,0)
end

function _______clouds()
end

function newCombCloud(_x,_y,_r,_c,_vx)
	local c={
		x=_x,y=_y,r=_r,c=_c,vx=_vx,
		update=function(c)
			c.x+=c.vx
 		if (c.x>140) c.x -= 160
		end,
	draw=function(c)
		_circfill(c.x,c.y,c.r,c.c)
	end
	}
	add(comb_objs,c)
end

function _______water()
end

--water--
wpts,prevwpts={},{}

--get corrected array value for water
function pt(i)
	return wpts[mid(1,flr(i),#wpts-1)]
end

function	drawUpdateWater()
	for i=1,#wpts do
		local vel = .975+(wpts[i]-prevwpts[i])*1.125
		prevwpts[i] = wpts[i]
		wpts[i]+=vel
		local surroundingPoints=0
		for j=0xfffc,4 do
			surroundingPoints+=pt(i+j)
		end
		local diff=-.095*surroundingPoints*
			(-8*wpts[i])

		wpts[i] -= diff*0.005

		wpts[i]=mid(wpts[i],0,128)

		_line(i-16,160,i-16,wpts[i]+97,1)

		if vel>1.25 or vel<-1.25 then
			_pset(i-16,wpts[i]+97,7)
		end
	end
end

function _________player_ship()
end

btn4=false

function comb_boat_move(b,left)
	local x=.1
	if (left) x*=0xffff
	b.vx=mid(-1.5,b.vx+x,1.5)
	b.flipx=left
	x=18
	if (left) x=23
	wpts[mid(1,flr(b.x+x),160)]-=.7
	sfx(0)
end

function comb_boat_fire_projectile(b)
	b.firecd=1
	sfx(9)
	fireProjectile(2+b.x,5+b.y,b.flipx,1,b.vx,b.aim,b)
	b.aim=.1
	b.vx-=1
	if (b.flipx) b.vx+=2
end

--combat comb_boat--
function newComb_boat()
	local comb_boat={
	 	x=16,y=62,w=8,h=8,vx=0,
		flipx=false,aim=.1,firecd=0,
		hp=100,flashing=0,isPlayer=false,
		update=function(b)
			b.firecd=max(b.firecd-.0333,0)

			--combat boat movement/firing
			if b.isPlayer then
				if (btn"0") comb_boat_move(b,true)
				if (btn"1") comb_boat_move(b,false)
				if (btn"4" and b.firecd==0) b.aim+=0.025
				if (btn4 and not btn"4" and b.firecd==0 or b.aim>1) comb_boat_fire_projectile(b)
				btn4=btn"4"
			elseif morale>0 then
				b.flipx=true
				if (abs(comb_boat.x-b.x) < 48) comb_boat_move(b,false)
				if (abs(comb_boat.x-b.x) > 72 or b.x>114) comb_boat_move(b,true)
				if (b.x>125) b.flipx=true

				local target=(abs(comb_boat.x-b.x)-4)/80

				local a=0.01
				if (b.aim>target) a*=0xffff
				b.aim+=a
				if (b.firecd==0 and abs(b.aim-target)<0.1 and b.flipx) comb_boat_fire_projectile(b)
			end

			if b.flashing<=0 and enemy!=null then
				if b.isPlayer then
					if (aabbOverlap(b,enemy)) hit(b,rrnd(12,17)) sfx(13)
				end
				for t in all(tentacles) do
					if (aabbOverlap(b,t)) hit(b,rrnd(12,17)) sfx(13)
				end
			end
			if b.hp<=0 then
				sfx(27)
				music(2)
				b.update=function(b)
					b.y+=0.1
					if not b.isPlayer and b.y>103 then
						victory=true
						txt_timer=0
						boat_message="gLORIOUS\nVICTORY! "
						sfx(29,0)
						sfx(30,1)
						music(2)
						victory_time=time()+0.01
						b.update=function()end
					end
				end

				if b.isPlayer then
					boat_message,txt_timer="abandon ship!",0

					b._draw=comb_boat.draw
					b.draw=function(b)
						b._draw(b)
						if b.y>100 then
							print_str('47414d45204f564552',24,40,8)
						end
						if b.y>105 then
							print_str('596f75722063726577206162616e646f6e6564',8,56,7)
							print_str('7468652073696e6b696e672073686970',20,64,7)
						end
						if b.y>115 then
							print_str('596f752077657265206e6f74',28,80,7)
							print_str('736f20636f776172646c79',32,88,7)
						end
					end
				end
				--todo: work on me!
			end
			b.vx*=.95
			b.x=mid(0,b.x+b.vx,120)
			local j=0
			for i=3,5 do
				j+=pt(b.x+i)
			end
			b.y=j/3+90
		end,
		draw=function(b)
			dmgFlash(b)
			pal(1,0)
			local s=27
			if (b.isPlayer) s=12
			spr(s,b.x,b.y,1,1,b.flipx,false)
			pal()
			if (b.firecd>0.9 and b.firecd<1.3) _circfill(b.x+4,b.y+5,1,b.firecd*25)
		end
	}
	return comb_boat
end

--comb_boat text plans

--State system
--nah fuck that, just have a timer number
--
--	idle, timer ticks up
--		when maxed, print generic message,
-- 		reset timer
--
--  HP falls below 25%, print negative
--	messages as morale is low
--
-- enemy hit, print generic positive
--	message

boat_message,txt_timer="tEST MESSAGE!",0

function boat_text(s)
	txt_timer+=.33
	if txt_timer>0 and txt_timer<#s+15 then

		print_u(sub(s,0,txt_timer),0,0)
		memcpy(0x1d00,0x6000,768)
		rectfill(0,0,64,12,12)
		local _y=0
		if (sub(s,#s,#s)==' ') _y=6
		for y=0,_y,6 do
		 for x=0,80,2 do
		 	wiggle=sin(t()+(x/#s))
		 	sspr(x,116+y,2,6,comb_boat.x+x,flr(comb_boat.y)-16+y+wiggle)
		 end
		end
	end
	if txt_timer>#s+45 then
		txt_timer=0
		boat_message="cOME ON THEN PAL,\nSQUARE TAE GO LIKE "
		if morale<70 then
			boat_message="nO SLACKING YOU\nLAZY SEA DOGS! "
		elseif morale<33 and morale>1 then
			boat_message="mAYBE I SHOULDN'T OF\nBEEN A PIRATE... "
		end
	end
end

function cannonLines(x0,y0,b)
	local c=11
	if (b.firecd > 0)	c=5

	for x=0,84,2 do
		local y=y0+((x^2)-(b.aim*80*x))/32
		local _x=x
		if (b.flipx) _x*=0xffff
		if (y<103) _pset(x0+_x,y,c)
	end
end

function ___________projectile()
end

function fireProjectile(_x,_y,_left,_r,_vx,_vy,_owner)
	proj={
		x0=_x,y0=_y,x=_x,y=_y,r=_r,owner=_owner,
		w=mid(1,_r*2,99),h=mid(1,_r*2,99),
		t=0,
		vx=1.32+abs(_vx),vy=_vy,
		left=_left,
		x2=0,y2=-64,
		x1=0,y1=-64,
	update=function(p)
		p.t+=.66
		if p.left then
			p.x-=p.vx
		else
			p.x+=p.vx
		end
		--p.y+=(0.125*p.t)-(5*p.vy)
		p.y=p.y0-(p.vy*5*p.t)+(0.125*p.t^2)
		if p.y > 102 then
			del(comb_objs,p)
			sfx(11)
			for i=p.x+15,p.x+17 do
				wpts[mid(1,flr(i),160)]-=10
			end
		end
		local b=p.owner.isPlayer
		if b and enemy!=null then
			for t in all(tentacles) do --tentacle collision
				if aabbOverlap(t,p) then
					del(comb_objs,p)
					del(projectiles,p)
					hit(enemy,rrnd(6,11))
					sfx(10)
					sfx(11)
				end
			end
			if aabbOverlap(enemy,p) then --enemy collision
				del(comb_objs,p)
				del(projectiles,p)
				hit(enemy,rrnd(12,18))
				sfx(10)
				sfx(11)
			end
		elseif not b then
			if aabbOverlap(comb_boat,p) then --player collision
				del(comb_objs,p)
				del(projectiles,p)
				hit(comb_boat,rrnd(10,14))
				sfx(10)
				sfx(11)
			end
		end
	end,
	draw=function(p)
		if p.owner.steps==null then
			_pset(p.x2,p.y2,7)
			_pset((p.x1+p.x2)/2,(p.y1+p.y2)/2,10)
			_pset(p.x1,p.y1,9)
			_pset((p.x+p.x1)/2,(p.y1+p.y)/2,8)
		end
			_circfill(p.x,p.y,p.r,0)
			p.x2,p.y2=p.x1,p.y1
			p.x1,p.y1=p.x,p.y
	end}
	add(comb_objs,proj)
	add(projectiles,proj)
end

function dmgFlash(e)
	e.flashing-=1
	if (e.flashing>0) pal_all"7"
end

function ______octopus()
end

enemyHpTimer=0
enemyPrevHp=100
enemyName=""
function drawEnemyHP()
	?enemyName,4,114,0
	?enemyName,4,113,7
	rect(4,120,123,126,0)
	local barLength0=lerp(0,118,enemy.hp/100)
	local barLength1=lerp(0,118,enemyPrevHp/100)
	if enemyHpTimer>0 then
		 enemyHpTimer=max(0,enemyHpTimer-.075)
		 if (enemyHpTimer<=1) barLength1=lerp(barLength0,barLength1,enemyHpTimer)
	else
		enemyPrevHp=enemy.hp
		barLength1=barLength0
	end
	_rectfill(5,119,5+barLength1,124,14)

	--true hp bar
	_rectfill(5,119,5+barLength0,124,8)

	_rect(4,119,5+barLength1,124,2)

	--HP bar outline
	_rect(4,119,123,125,7)
end

enemyTimer=0
--octodude--
function newOctopus()
	local enemy={
		hp=100,
		x=88,y=88,w=24,h=72,
		flashing=0,
		timer=0,
		stepIndex=4,
		steps=
		{
			function(o) --sink below surface
				o.y+=.5
				for t in all(tentacles) do
					t.y+=.5
				end
				if o.y>108 then
					if o.hp>0 then
						enemyTimer=0
						if rnd"1">.5 then
							o.stepIndex=3
						else
							o.stepIndex=5
						end
					else
						victory=true
						boat_message="tAKE THAT,\nFOUL BEAST! "
						txt_timer=0
						sfx(29,0)
						sfx(30,1)
						music(2)
						victory_time=time()
						victory_time+=0.01
						del(comb_objs,o)
						enemy=null
					end
				end
			end,
			function(o) --rise above surface
				o.y-=.5
				for t in all(tentacles) do
					t.y-=.5
				end
				if o.y<88 then
					o.stepIndex,enemyTimer=4,0
				end
			end,
			function(o)
				local target=(abs(comb_boat.x-o.x)-4)/80
				local ta={-rnd".2",0,rnd".2"}
				for i=1,3 do
					fireProjectile(o.x,o.y-8,true,2,ta[i],target+ta[i],o)
				end
				o.stepIndex=2--shoot at player
			end,
			function(o)--idle, exit after 5 seconds
				if (enemyTimer>3) o.stepIndex=1 enemyTimer=0
			end,
			function(o)--attack with tentacles
				local noodle = tentacles[1]
				if (noodle.x==119) noodle.x,noodle.y=comb_boat.x,105
				if enemyTimer < 1.5  and enemyTimer>1 then
					noodle.y-=1
				elseif enemyTimer>1 then
					noodle.y+=.5
					if noodle.y > 103 then
						noodle.x,noodle.y=119,114
						enemyTimer=0
						o.stepIndex=2
					end
				end
			end,
		},
		update=function(o)
			enemyTimer+=0.03
			o.y+=cos(t())*.25
			if (o.hp<=0) o.stepIndex=1
			o.steps[o.stepIndex](o)
		end,
		draw=function(o)
			dmgFlash(o)
		  palt(0,true)
			_spr(91,o.x,o.y,3,3)
			for i=o.x,o.x+33 do
				if (o.hp>0) wpts[flr(i+16)]+=rnd(.25)
			end
		 	--draw tentacles
		 	for t in all(tentacles) do
				for y=0,24 do
					local _x=t.x+2+(1.5*sin(time()+t.o+y*.1))
					local _y=t.y+cos(time()+t.o*2)
		  		if (y==1 and o.hp>0)	wpts[flr(_x+16)]+=rnd(.25)
					_sspr(24,45+y,3,1,_x+1,_y+y)
		  	end
		 	end
			pal()
		 end
	}
	local xs=stringToArray"119,112,87,79,73,★"
	local ys=stringToArray"96,92,90,88,97,★"
	tentacles={}
	for i=1,5 do
		add(tentacles,{x=xs[i],y=ys[i],o=rnd"1",w=5,h=24})
	end
	return enemy
end

function hit(this,dmg)
	flip()
	this.hp,this.flashing,shakeTimer=max(0,this.hp-dmg),10,1
	if this.isPlayer then
		morale,this.flashing,playerHpTimer=this.hp,25,2
	else
		enemyHpTimer=2
	end
end

function ___________________helpers()
end

function spr_rot(sx,sy,swh,dx,dy,rot,depth)
  local s=sin(rot)
  local c=cos(rot)
  local size = swh/2
  local _b=(s*s+c*c)
  local w = sqrt(size^2*2)
  for y=-w,w do
    for x=-w,w do
      local ox=(s*y+c*x)/_b+size
      local oy=(-s*x+c*y)/_b+size
      if ox<swh and oy<swh and ox>0 and oy>0 then
				for d=0,depth do
	        local col=sget(ox+sx+(d*16),oy+sy)
	        if (col>0) _pset(dx+x,dy+y-d,col)
				end
      end
    end
  end
end

--https://www.lexaloffle.com/bbs/?tid=30518
_fillp_original=fillp

--local fill pattern
function fillp(pattern,x,y)
    local add_bits=band(pattern,0x0000.ffff)
    pattern=band(pattern,0xffff)
    y=flr(y)%4
    if(y~=0)then
        local r={0xfff0,0xff00,0xf000}
        local l={0x000f,0x00ff,0x0fff}
        pattern=bxor(lshr(band(pattern,r[y]),y*4),shl(band(pattern,l[y]),(4-y)*4))
    end

    x=flr(x)%4
    if(x~=0)then
        local r={0xeeee,0xcccc,0x8888}
        local l={0x1111,0x3333,0x7777}
        pattern=bxor(lshr(band(pattern,r[x]),x),shl(band(pattern,l[x]),4-x))
    end

    return _fillp_original(bxor(pattern,add_bits))
end

function print_u(s,x,y)
	?s,x,y+1,1
	?s,x,y,7
end

shakeX,shakeY,shakeTimer=0,0,0
function screenShake()
	if shakeTimer > 0 then
		shakeX,shakeY=rrnd(0xfffc,4),rrnd(0xfffc,4)
		shakeTimer-=.33
	else
		shakeX,shakeY=0,0
	end
	camera(shakeX,shakeY)
end

function aabbOverlap(a,b)
	return ((a.x+a.w > b.x)
					and (a.x < b.x+b.w))
		and ((a.y+a.h > b.y)
					and (a.y < b.y+b.h))
end

function pal_all(c)
	for i=0,15 do
		pal(i,c)
	end
end

function lerp(a,b,t)
 return b*t+(a*(1-t))
end

function rrnd(min,max)
	return rnd(max-min)+min
end
__gfx__
0000000000000000000000007000000000000007000000000000000000000000000000000000000000007c0007c000000040000000000008800000800ddf0d00
00000000000000000000000000000000000000000000000000000000000000000000000000000000008cb9a07a8a00007777000000000088880008880dff0fd0
0070070000000000000000000000000660000000000000000000000000000000000000000000000007b9a897c9ab00000777700000000018888088880dff0fd0
00077000000000000000000000000066660000000000000000000000000000009999999999940000c9ac797a9ac900000777700000000001888888810dff0fd0
000770000000000000000000000006666660000000000000000000000000000955555555559240009b7a9c9ba99000007777000000000000188888100ddf0fdd
007007000000000000000000000066666666000000aaaaaaaaaaa900000000955555555559224000000000000000000040400440000000008888810000df0ffd
00000000000000000000000000000066660000000a22222222229240000009999999999999224000000000000000000041414400000000088888880000df0ffd
0000000000000000000000000000006666000000a2888888888922400000a1111111111114440000000000000000000044444000000000888818888000df0ffd
01249af777fa0000000000000000006666000000a2888aa288892440000a1111111111114400000000000000000400000040000000000088810188880ddf0fdd
012499aaa9900000000000000000006666000000aaaaa11999994240000aaaaaaaaaaa94240000000000000007670000ffff000000000018100018810dff0fd0
0000000000000000000000000000006666000000a222a11922292240000a222a119222922400000000000000007670000ffff00000000001000001100dff0fd0
0000000000000000000000000000006666000000a288a11928892240000a288a119288922400000000000000006767000ffff00000000000000000000dff0fd0
0000000000000000000000000000006666000000a288899288892240000a288899288892240000000000000006767000ffff000000000000000000000ddf0fdd
0000000000000000000000000000000000000000a288888888892240000a2888888888922400000000000000200400222040022000000000000000000dff0ffd
0000000000000000000000000000000000000000a288888888892400000a2888888888924000000000000000221212202121220000000000000000000dff0ffd
0000000000000000000000007000000000000007a999999999994000000a9999999999940000000000000000222222002222200000000000000000000dff0ffd
0000000000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
aae5fba057770008eff908ff7daa0bffd9005dddd04661776000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0e501e088528d804d284008700f00c708500e14ad00632060000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
06b3b60085f580050a04000f6e10007d4000a3d2a00702370000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
070816008d28900582850007807040b04e00a1e8a00700270000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
23edf320df7b8008dfd8007ff9600ffffb023dde222275520000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
1000000000000002200440000006000000100000000000002000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000110000000000000000000000000000880000000000000000000000888000000000888000000000000000000000220000000000222000222000dff0ffd
00000811000000000000000000000000000002aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd1000067555557200046651574000ddf0fdd
000088900000000000000000000000000000002e9550a00009d40aa9d48800049e6090004512a845380000097208d10000623540370000067200700000df0fd0
0008c8880000000000000000000020000044006f8114b100008817e9140800459a2c00000006f906910000017688010000223540230000077200600000df0fd0
000cc88800000000000000000002200000440467993b6000008817fd400804551aa040000006fd68110000013ec5000000203743020000175220600000df0fd0
0044e98002000000023400000022650000040067aa19640000089f69908000451aa0440000067be011000001bb154000002037530200000752217000000d0fdd
0046ffd42220022227777222002677775440007608817000000097609900004592a840000006798710000001fa01060000201761020000075022700000df0ffd
0467ffd72222002453777720027727775510003608853000000097619800000c12ac0100000679871000000db200c20000201760020000065022700000df0ffd
0246fbb022200065510776400577200115100133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb31002225554222000226557200000df0ffd
00467b10020000475102764005772000511002000000000000000000000000000200c400002000000600000200000000000100000000000000002000000d0fdd
00467b10000000475102264405772004111000000000000000000000000000222000088000000000006600000000000000000000000000000000022000df0fd0
00467b10000000677102260005772044551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00467b10000002655306620005776044555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00467b100000026551622200057764045550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0fdd
00467b10000022655502220001776000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00467310000022655102220001336000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00467b10000022655102220001372000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
0046fb9010002267512222401173300055500000000000000000000000000000000000000000000000000000000000000000022222000000000000000ddf0fdd
046effbd20002677775327221377775251000000000000000000000000000000000000000000000000000000000000000002288888220000000000000dff0ffd
0046fff200000226755772000467777500000000000000000000000000000000000000000000000000000000000000000228888282882000000000000dff0ffd
00004b0000000020041020004000215000000000000000000000000000000000000000000000000000000000000000002888888828888200000000000dff0ffd
0001111100001000100000000000040000000000000000000000000000000000000000000000000000000000000000028888888282888200000000000ddf0fdd
0011111110001011111000000200000000000000000000000000000000000000000000000000000000000000000000298888882888888200000000000dff0fd0
01000011110011111111000028800000000000000000000000000000000000000000000000000000000000000000002a9888888888888200000000000dff0fd0
00000001110110000111100028e000000000000000000000000000000000000000000000000000000000000000000029a988899998888200000000000dff0fcc
00000001111010000011110028800000000000000000000000000000000000000000000000000000000000000000002898889aaa98888200000000000ddf0fdd
00000001110010000001111028e00000000000000000000000000000000000000000000000000000000000000000002888889999888820000000000000df0ffd
00000011110010000000111028800000000000000000000000000000000000000000000000000000000000000000002888888888888820000000000000df0ffd
00000101110010000000111028e00000000000000000000000000000000000000000000000000000000000000000002888888888888200000000000000df0ffd
000110011100110000011110288000000000000000000000000000000000000000000000000000000000000000000028888888888828200000000000000d0fdd
00111001110010111110111028e00000000000000000000000000000000000000000000000000000000000000000028888888888228820000000000000df0fd0
01111101110010000000111028800000000000000000000000000000000000000000000000000000000000000000288888888822882882000000000000df0fd0
00011111110010000000111028e00000000000000000000000000000000000000000000000000000000000000002888888888288282882000000000000df0fd0
000011111100100000001110288000000000000000000000000000000000000000000000000000000000000000288822882882882828820000000000000d0fdd
00000011110010111110111028e00000000000000000000000000000000000000000000000000000000000000288828888288288282288228000000000df0ffd
000000111100110000011110288bbbb4bbbbbbbb0000000000000000000000000000000000000000000000000288288222888828288228888000000000df0ffd
00000001110010000000111028ebbb777bbb4bbb0000000000000000000000000000000000000000000000000282882002888828828882882000000000df0ffd
000000011100100000001110288bbbb777b77bbb00000000000000000000000000000000000000000000000028828820288288828828882200280000000d0fdd
00000001110010000000111028ebbbb777bb77bb0000000000000000000000000000000000000000000000002888288228202888288288882288200000df0fd0
000001111100111100001100288bbbb777bb77bb0000000000000000000000000000000000000000000000000288828288200288828828888882000000df0fd0
00011111110011111110100028ebfb777bb77bbb0000000000000000000000000000000000000000000000000028288282002288288202222220000000df0fd0
011111111100111111110000288444b4bbbb4bb400000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d00
11000001110010000110000028e444444444444b0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000001110010000000000028844440404044bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000001110010000000000028eb444444444bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
000000011100100000000000288bb44444444bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000d0fdd
00000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
000ddddd000ddddd0000000ddddddddddddddddddddd000ddddddddd000ddddd0000000ddddd0000000ddddddddd000ddddd0000000000000000000000df0ffd
00ddfffdddddfffdddd0ddddfffdfffdfffdfffdfffdddddfffdfffdddddfffdddd0ddddfffdddd0ddddfffdfffdddddfffdddd0ddd000000000000000df0ffd
0dfffffffffffffffffdfffffffffffffffffffffffffffffffffffffffffffffffdfffffffffffdfffffffffffffffffffffffdfffdd00000000000000d0fdd
ddf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000df0fd0
0dfffffffffffffffffffffffffffffdfffffffffffffffffffffffffffdfffdfffffffffffffffffffffffffffdfffffffffffffffdd0000000000000df0fd0
00ddfffdfffdddddfffdddddfffdddd0ddddfffdddddfffdfffdfffdddd0ddd0ddddfffdfffdfffdfffdfffdddd0ddddfffdfffdddd000000000000000df0fd0
000ddddddddd000ddddd000ddddd0000000ddddd000ddddddddddddd00000000000ddddddddddddddddddddd0000000ddddddddd0000000000000000000d0fdd
fff000ffffff00ffff000ffffff0000ffff000fffff00fff000ff000000ff00000ffff00fff00ff0ffffffff0fff000ffffffff0ffffff000000000000df0ffd
0f00000f00f00f0000f0f00f00f000f000ff000f000f00ff000f00000000f0000f0000f00f0000f00f00f00f00f00000f00f00f00f0000f00000000000df0ffd
00f000f000f0f00000f0000f00000f00000ff00f000f000f000f00000000f000f00000f00f0000f00f00f000000f000f000f00000f00000f0000000000df0ffd
00f000f000f0f0000000000f0000f0000000f00f000f000f00f00000000fff00f00000000f0000f00f00f000000f000f000f00000f00000f000000000ddf0fdd
00f000f000f0f0000000000f0000f0000000f00f000f0000f0f00000000f0f00f00000000f0000f00f00f00f000f000f000f00f00f00000f000000000dff0ffd
00f00f0000f0f0000000000f0000f0000000f00f00f00000ff000000000f0f00f00000000ffffff00f00ffff000f00f0000ffff00f00000f000000000dff0ffd
000f0f0000f0f0000000000f0000f0000000f00fff000000ff00000000f00f00f00000000f0000f00f00f00f0000f0f0000f00f00f00000f000000000dff0ffd
000f0f0000f0f0000000000f0000f0000000f00f0ff000000f00000000fffff0f00000000f0000f00f00f0000000f0f0000f00000f00000f000000000ddf0fdd
000f0f0000f0f0000000000f0000f0000000f00f00ff00000f00000000f000f0f00000000f0000f00f00f0000000f0f0000f00000f00000f000000000dff0ffd
0000f00000f0ff0000f0000f00000f000000f00f00ff00000f00000000f000f0ff0000f00f0000f00f00f000f0000f00000f000f0f00000f000000000dff0ffd
0000f00000f00f0000f0000f000000f0000f000f000ff0000f0000000f0000ff0f0000f00f0000f00f00f00f00000f00000f00f00f0000f0000000000dff0ffd
0000f0000fff00ffff00000ff000000ffff0000f0000f000ff000000ff0000ff00ffff00fff00fffffffffff00000f0000fffff0ffffff00000000000ddf0fdd
00000000000000000000000000000000000000f0f000ff0000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
000000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
0000000000000000000000000000000000004000000000000000400000000000000000000000000000000000000000000000000000000000000000000ddf0d00
0000000000000000000040000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
00044400000000000004f4000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0004440000000000004fff400000000000400040000000000000000000000000000777000000000000007000000000000000000000000000000000000ddf0fdd
0004440000000000004fff400000000000404040000000000000400000000000000040000000000000004000000000000000000000000000000000000dff0ffd
0004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0004440000000000004fff400000000000400040000000000000000000000000007777700000000000777770000000000000000000000000000000000dff0ffd
0004440000000000004fff400000000000404040000000000040404000000000000040000000000000004000000000000000400000000000000000000ddf0fdd
0004440000000000004fff400000000000490940000000000040004000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0004440000000000004444400000000000499940000000000040004000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000444000000000000044400000000000004440000000000000000000000000000000000000000000000000000000000000000000dff0fd0
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777c77cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000cccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000ccccccccccccccccccccccccccccccccccccccccccc
777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaa
717c7ccc7ccccccc7c7c777c77cc77ccc77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaa
777c7ccc7ccccccc7c7c717c717c717c711ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaa
717c7ccc7ccccccc777c777c7c7c7c7c1c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaa
7c7c777c777ccccc717c717c7c7c771c771cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
1c1c111c111ccccc1c1c1c1c1c1c11cc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
ccccccccccccccccccccccccccccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
c77c77cccccc77cc777c777c7c7cc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
717c717ccccc717c771c711c771cc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
7c7c7c7ccccc7c7c71cc7ccc717cc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
771c7c7ccccc771c777c777c7c7cc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
11cc1c1ccccc11cc111c111c1c1cc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaa
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000001000000000000000000000000000010000000000000000000000000000000101010000000000000000000001000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
cccccccccccccccc040444ccd4cccccccccccccccccccccccccccccccccccccccccccccccc2ce8cc82c1cccc2ce8828888888822888228cc2c88cccc82c8cccc11111111111111111111111111111111111111111111111111111111111111111111c111c111181182c111711228878188111118128128112c18c1cc1ce81c11
11111111111111111111111111111111111111111111111111111111111111111111111171111e1171111111117111111111111811111111711771111711111111111111111111111111111111111111111111111111111111111111111111111111111111111711111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
__sfx__
0003000004610066101f6001d6001d6001c6001c60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000661005650076503460037600236003e6003f6003f6003f6003c600346002b600236001b600126000d6000c6000c6000d60011600166001b600236002d6003360033600316002e60028600236001c600
010100001335110371233013e0013f0013f0013f0013c001340012b001230011b001120010d0010c0010c0010d00111001160011b001230012d0013300133001310012e00128001230011c001000010000100000
000200000c1500f150101500a15012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000c1500f150101501515012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0003000014753187531475309703187001870018700187001870318703187031b7030070300703007032770300703007030070300703007030070300703007030070300703007030070300703007030070300703
00040000137531c753107530070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c0000205551b5551d55521555005001b5552655500505005050050500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00100000145550f55511555155550c5050f5550d5051a5551a5001a5001a500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000a00003565329650186500060100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000400003145334453324532f4532b453254531f45317453114530d4430b4330e4231241300400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000016a701da701ba6017a600aa500da5013a4019a4008a3006a3013a2018a200ca1014a1000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a00
00010000060100505007050340001f000230003e0003f0003f0003f0003c000340002b000230001b000120000d0000c0000c0000d00011000160001b000230002d0003300033000310002e00028000230001c000
010400003115334153321532f1532b153251531f15317153111530d1430b1330e1231211300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
010a00003565329650186500060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006000060000600
010400003142334453324732f4732b473254731f47317463114530d4430b4330e423124131540314403104030d4030c4030b4030e40310403104030b4030a403094030b4030b4030b40308403054030440303403
010100001335110371213012f3012e301133011a3013a3012f301113011a3013f3011330125301293012e3013030131301313012b301123010c3010b3010c3010e3010030112301163011930118301133010c301
0003000016a701da701ba6017a600aa500da5013a4019a4008a300ba3013a2018a200ca1014a102ba0022a001aa0019a0019a001aa001ca001ba0018a0014a000fa000ca0009a0007a0006a0004a0000a0000a00
000100000d6100b6100b6100c6100d6100b6100b6100c6100d6100d61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100c101205014050160501205014050160501205014050160501405012050110500a05016050120500905001000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003564300003306430c603356433064300000000003564300003306430c6033564330643000000000035643000033064300003356430000330643000033564300003306433660335643306430000000000
000a00100b350286001735000000113501a3000b3501530018350333000b350183500b350193500c35000000113001d300000001630016300123000e3000e3000000000000000000000000000000000000000000
000f00101335313300153501535313300133531330015350153550000013350103530000012350143530000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014000005153295531f6502955300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c752007000c752007000c752007000c752107520c752157520c7521a7520c75006750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001200181875300703187530c75318753007030c753187530c7531875308753007031875300703187530c75318753007030c753187530c7531875308753087530070300703007030070300703007030070300703
001200180e0300b0301603011030180300c0300c03004030120301203002030140300e03015030140301603019030160300903003030020301203004030130302400019000000000000000000000000000000000
000400003132534355323752f3752b375253751f37517365113550d345253252835526375233751f37519375133750b3650535501345193251c3551a37517375133750d375073750530504305000000000000000
00080000077300c7301173013730077400a7400c750167501b7501876016760117600c7600f760167601d7602276022760227601d7601f7601d76024760247502473024700247002470000700007000070000700
000800001c5621a5721c5722257222572225721d5721f5721d5622456224552245422450224502245020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
000800000705005050070500c0500a0500a05007050070500a050070500705007050070000700007000070000700007000050000500005000050000500005000050000500005000070000a0000a0000a0000a000
011c00000755207552035520755205552075520a5520c5520a5520f5520f5520a5520755207552035520755205552055520a5520c5520a5520f5520c5520a5520755207552035520755205552075520a5520c552
001c00000755507555035550755505555075550a5550c5550a5550f5550f5550a5550755507555035550755505555055550a5550c5550a5550f5550c5550a5550755507555035550755505555075550a5550c555
__music__
03 19464344
03 07194344
