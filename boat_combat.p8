pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--boat'n vidya gam--
--by craig tinney--

--start stats
--token count: 1615
--char count: 5927
--cpu load: ~76%

--current stats
--token count: 1975
--char count: 8917
--cpu load: ~57.5%


state=2--change to 1 to skip intro
--0 splash screen
--1 gameplay
--2 screen transition
--3 combat

function _init()
	comb_init()
end

function _update()
		comb_update()
end

function _draw()
	 comb_draw()
end

--boat combat-
function comb_init()
	comb_objs={}
	comb_clouds={}
	monster=newOctopus()
	boat=newBoat()
	add(comb_objs,monster)
	add(comb_objs,boat)
	for t in all(monster.tentacles) do
		t.o,t.w,t.h=rnd(1),5,24
	end
	for	i=0,160 do
		add(wpts,0)
		add(prevwpts,0)
	end
	clouds={}
	for i=0,25 do
		local x,y=rnd(127),rnd(32)+8
		local r,vx=rnd(8)+4,rnd(.5)
		add(comb_clouds,newcloud(x+2,y+1,r+1,6,vx))
		add(comb_clouds,newcloud(x,y,r,7,vx))
	end
	music(1,0)
end

function comb_update()
	camera(0,0)
	for c in all(comb_objs) do
		c.update(c)
 	end
	for c in all(comb_clouds) do
		c.update(c)
 	end
end

function comb_draw()
 cls(12)
 screenShake()
 circfill(124,8,24,10)
 for c in all(comb_clouds) do
 	if(c.c!=7) c.draw(c)
 end
 for c in all(comb_clouds) do
  if(c.c==7)	c.draw(c)
 end
  palt(0,false)
	for c in all(comb_objs) do
	 c.draw(c)
	end
	drawUpdateWater()

 waterReflections()
 if victory then
	 local cols={}
	 pal(15,sget(min((t()-victory_time)*15,4),9))
	 rectfill(0,48,127,64,0)
	 sspr(0,77,112,15,7,49,114,17)
	 pal(15,sget(min((t()-victory_time)*15,11),8))
	 sspr(0,77,112,15,8,50)
	 pal()
 else
	 cannonLines(2+boat.x,5+boat.y)
	 drawEnemyHP()
	end
end

function _______clouds()
end

function newcloud(_x,_y,_r,_c,_vx)
	local c={
		x=_x,y=_y,r=_r,c=_c,vx=_vx,
		update=function(c)
			c.x+=c.vx
 		if (c.x>140) c.x -= 160
		end,
	draw=function(c)
		circfill(c.x,c.y,c.r,c.c)
	end
	}
	return c
end

function _______water()
end


--water--
wpts={} --water points
prevwpts={}

--get corrected array value for water
function pt(i)
	return wpts[mid(1,flr(i),#wpts-1)]
end

--same as above but for indexing
function _pt(i)
	return mid(flr(i),1,#wpts)
end

function	drawUpdateWater()
	for i=1,#wpts do
		local vel = .975+(wpts[i]-prevwpts[i])*1.125
		prevwpts[i] = wpts[i]
		wpts[i]+=vel


		local surroundingPoints=0
		for j=-4,4 do
			surroundingPoints+=pt(i+j)
		end
		local diff=-.095*surroundingPoints*
			(-8*wpts[i])

		wpts[i] -= diff*0.005

		wpts[i]=mid(wpts[i],0,128)

		line(i-16,160,i-16,wpts[i]+97,1)

		if vel>1.25 or vel<-1.25 then
			pset(i-16,wpts[i]+97,7)
		end
	end
end

function waterReflections()
	for x=1,127 do
		for y=0,48 do
			local c=pget(x,103-y)
			if c!=12 and c!=1 then
				if 103+y/2>wpts[x]+97 then
					pset(x+(sin(time()+(y/50))),103+y*.5,13)
				end
			end
		end
	end
end

function _________player_ship()
end

--combat boat--
function newBoat()
	local boat={
	 	x=16,y=62,w=8,h=8,vx=0,
		flipx=false,aim=.5,firecd=0,
		hp=100,flashing=0,
		update=function(b)
			if (btn(0)) then
				b.vx=mid(-1.5,b.vx-0.1,1.5)
				b.flipx=true
				wpts[_pt(b.x+23)]-=.7
				sfx(4)
			end
			if (btn(1)) then
	 			b.flipx=false
				b.vx=mid(-1.5,b.vx+0.1,1.5)
				wpts[_pt(b.x+18)]-=.7
				sfx(4)
			end

			if (btn(2))	b.aim+=0.025
			if (btn(3)) b.aim-=0.025

			if btn(4) and b.firecd==0 then
				b.firecd=1
				sfx(0)
				fireProjectile(2+b.x,5+b.y,b.flipx,1,b.aim)
			end

			if b.flashing<=0 and monster!=null then
				if (aabbOverlap(b,monster)) hit(b,12+rnd(5))
				for t in all(monster.tentacles) do
					if (aabbOverlap(b,t)) hit(b,12+rnd(5))
				end
			end
			if boat.hp<=0 then
				?""
				state=4
			end
			b.vx*=.95
			b.firecd=max(b.firecd-.0333,0)
			b.aim=mid(b.aim,.1,1)
			b.x=mid(0,b.x+b.vx,120)
			b.y=((pt(b.x+3)+pt(b.x+4)+pt(b.x+5))/3)+90
			txt_timer+=.066
		end,
		draw=function(b)
			dmgFlash(b)
		  palt(11,true)
			palt(0,false)
			sspr(27,50,8,8,b.x,b.y,8,8,b.flipx,false)
			pal()
			--[[boat_text(messages[message_index])
			if txt_timer*5>(#messages[message_index]) then
				 if (message_index<#messages) txt_timer=0
				 message_index=mid(1,message_index+1,#messages)
			 end]]
		end
	}
	return boat
end

--boat text plans

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

txt_timer=0

messages={
	"aLL HANDS\nON DECK!",
	"wHAT IS\nTHAT THING?",
	"wE'RE GOING\nTO DIE!",
	"pULL YOURSELF\nTOGETHER!",
	"abandon\nship!"
}
message_index=1

function boat_text(s)
	local text=sub(s,0,txt_timer*10)
	--?text,boat.x-12,boat.y-11,1
	--?text,boat.x-12,boat.y-12,7

	for i=1,txt_timer*10 do
		?sub(s,i,i),boat.x-12+(i*4),boat.y-10+sin(t()+i/10)*2,1
		?sub(s,i,i),boat.x-12+(i*4),boat.y-11+sin(t()+i/10)*2,7
	end
end

function cannonLines(x0,y0)
 local c=11
 if (boat.firecd > 0)	c=5
 --for i=1,50 do
 for i=0,50-boat.firecd*75 do
	local x,y=x0,y0
 	if boat.flipx then
		x+=1
 		x-=i*2
 	else
		x+=i*2
 	end
 	y+=(0.125*(i^2))-(boat.aim*5*i)

 	if (y<103) pset(x,y,c)
 end
end

function ___________enemy_ship()
end

function ___________projectile()
end
projectiles={}
--fire cannon--
function fireProjectile(_x,_y,_left,_r,aim)
	proj={
		x0=_x,y0=_y,x=_x,y=_y,r=_r,
		w=mid(1,_r*2,99),h=mid(1,_r*2,99),
		t=0,
		vx=1.32+abs(boat.vx),vy=aim,
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
			sfx(1)
			for i=p.x+15,p.x+17 do
				wpts[_pt(i)]-=10
			end
		end

		if monster!=null then
			for t in all(monster.tentacles) do --tentacle collision
				if aabbOverlap(t,p) then
					del(comb_objs,p)
					del(projectiles,p)
					monster.hit(monster)
					sfx(3)
					sfx(1)
				end
			end
			if aabbOverlap(monster,p) then --octopos collision
				del(comb_objs,p)
				del(projectiles,p)
				monster.hit(monster)
				sfx(3)
				sfx(1)
			end
		end
	end,
	draw=function(p)
			pset(p.x2,p.y2,7)
			pset((p.x1+p.x2)/2,(p.y1+p.y2)/2,10)
			pset(p.x1,p.y1,9)
			pset((p.x+p.x1)/2,(p.y1+p.y)/2,8)
			circfill(p.x,p.y,p.r,0)
			p.x2=p.x1 p.y2=p.y1
			p.x1=p.x	p.y1=p.y
	end}
	add(comb_objs,proj)
	add(projectiles,proj)
end

function dmgFlash(e)
	e.flashing-=1
	if (t()%.01>.005 and e.flashing>0) pal_all(7)
end

function ______octopus()
end

-- octopus in various states
-- 	idle, current implementation
-- 	tentacle attack, duck below surface
--  	and tentacles come up and hit player
--	projectile attack, octopus head ducks
-- 		below surface, comes up a moment later
--		and fires a rock or some shit (mb ink)

hpTimer=0
prevhp=100
enemyName=""
function drawEnemyHP()
	?enemyName,4,114,0
	?enemyName,4,113,7
	rect(4,120,123,126,0)
	local barLength0=monster.hp*1.18
	local barLength1=prevhp*1.18
	if hpTimer>0 then
		 hpTimer-=0.066
		 if (hpTimer<=1) prevHp=monster.hp barLength1=lerp(barLength0,barLength1,hpTimer)
	else
		prevhp=monster.hp
		barLength1=barLength0
	end

	rectfill(5,119,5+barLength1,124,14)

	--true hp bar
	rectfill(5,119,5+barLength0,124,8)

	rect(4,119,5+barLength1,124,2)

	--HP bar outline
	rect(4,119,123,125,7)
end

--octodude--
function newOctopus()
	enemyName="wATERY FIEND"
	local monster={
		tentacles={
			{x=119,y=96},
			{x=112,y=92},
			{x=87,y=90},
			{x=79,y=88},
			{x=73,y=97}
		},
		hp=1,
		x=88,y=88,w=24,h=72,
		flashing=0,
		timer=1,
		stepIndex=4,
		steps=
		{
			function(o) --sink below surface
				o.y+=.5
				for t in all(o.tentacles) do
					t.y+=.5
				end
				if o.y>104 then
					if o.hp>0 then
						o.stepIndex+=1
					else
						victory=true
						victory_time=t()+0.01
						del(comb_objs,monster)
						monster=null
					end
				end
			end,
			function(o) --rise above surface
				o.y-=.5
				for t in all(o.tentacles) do
					t.y-=.5
				end
				if o.y<88 then
					o.stepIndex=1
				end
			end,
			function(o)
				fireProjectile(o.x,o.y,true,3,boat.aim)
			end,
			function(o)

			end
		},
		update=function(o)
			o.y+=cos(t())*.25
			if (o.hp<=0) o.stepIndex=1
			o.steps[o.stepIndex](o)
		end,
		draw=function(o)
			dmgFlash(o)
		  palt(0,true)
			sspr(35,34,33,24,o.x,o.y)
			for i=o.x,o.x+33 do
				if (o.hp>0) wpts[flr(i+16)]+=rnd(.25)
			end
		 	--draw tentacles
		 	for t in all(o.tentacles) do
				for y=0,24 do
					local _x=t.x+2+(1.5*sin(time()+t.o+y*.1))
					local _y=t.y+cos(time()+t.o*2)
		  		if (y==1 and o.hp>0)	wpts[flr(_x+16)]+=rnd(.25)
					sspr(24,45+y,3,1,_x+1,_y+y)
		  	end
		 	end
			pal()
		 end,

		 hit=function(o)
			 hpTimer=2
			 hit(o,30+rnd(6))
		 end
	}
	return monster
end

function hit(this,dmg)
	flip()
	this.hp=mid(0,this.hp-dmg,1000)
	shakeTimer=1
	this.flashing=10
end

function _______helpers()
end

shakeTimer=0
shakeAmount=4
shakeX=0 shakeY=0
function screenShake()
	if shakeTimer > 0 then
		shakeX=rnd(shakeAmount*2)-shakeAmount
		shakeY=rnd(shakeAmount*2)-shakeAmount
		shakeTimer-=0.33
	else
		shakeX=0 shakeY=0
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

__gfx__
0000000000000000000000007000000000000007000000000000000000000000000000000000000000007c0007c000000000000000000008800000800ddf0d00
00000000000000000000000000000000000000000000000000000000000000000000000000000000008cb9a07a8a00000000000000000088880008880dff0fd0
0070070000000000000000000000000660000000000000000000000000000000000000000000000007b9a897c9ab00000000000000000018888088880dff0fd0
00077000000000000000000000000066660000000000000000000000000000009999999999940000c9ac797a9ac900000000000000000001888888810dff0fd0
000770000000000000000000000006666660000000000000000000000000000955555555559240009b7a9c9ba99000000000000000000000188888100ddf0fdd
007007000000000000000000000066666666000000aaaaaaaaaaa900000000955555555559224000000000000000000000000000000000008888810000df0ffd
00000000000000000000000000000066660000000a22222222229240000009999999999999224000000000000000000000000000000000088888880000df0ffd
0000000000000000000000000000006666000000a2888888888922400000a1111111111114440000000000000000000000000000000000888818888000df0ffd
01249af777fa0000000000000000006666000000a2888aa288892440000a1111111111114400000000000000000000000000000000000088810188880ddf0fdd
012499aaa9900000000000000000006666000000aaaaa11999994240000aaaaaaaaaaa942400000000000000000000000000000000000018100018810dff0fd0
0000000000000000000000000000006666000000a222a11922292240000a222a119222922400000000000000000000000000000000000001000001100dff0fd0
0000000000000000000000000000006666000000a288a11928892240000a288a119288922400000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000006666000000a288899288892240000a2888992888922400000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000a288888888892240000a2888888888922400000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000a288888888892400000a2888888888924000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000007000000000000007a999999999994000000a9999999999940000000000000000000000000000000000000000000000000dff0ffd
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
00467b10000000677102260005772044551000000000000022222000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00467b10000002655306620005776044555000000000002288888220000000000000000000000000000000000000000000000000000000000000000000df0fd0
00467b100000026551622200057764045550000000002288882828820000000000000000000000000000000000000000000000000000000000000000000d0fdd
00467b10000022655502220001776000555000000002888888828888200000000000000000000000000000000000000000000000000000000000000000df0ffd
00467310000022655102220001336000555000000028888888282888200000000000000000000000000000000000000000000000000000000000000000df0ffd
00467b10000022655102220001372000555000000298888882888888200000000000000000000000000000000000000000000000000000000000000000df0ffd
0046fb901000226751222240117330005550000002a988888888888820000000000000000000000000000000000000000000000000000000000000000ddf0fdd
046effbd20002677775327221377775251000000029a98889999888820000000000000000000000000000000000000000000000000000000000000000dff0ffd
0046fff20000022675577200046777750000000002898889aaa9888820000000000000000000000000000000000000000000000000000000000000000dff0ffd
00004b0000000020041020004000215000000000028888899998888200000000000000000000000000000000000000000000000000000000000000000dff0ffd
0001111100001000100000000000040000000000028888888888888200000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0011111110001011111000000200077000000000028888888888882000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0100001111001111111100002880040000000000028888888888828200000000000000000000000000000000000000000000000000000000000000000dff0fd0
00000001110110000111100028e0f40000000000288888888882288200000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000111101000001111002884444440000002888888888228828820000000000000000000000000000000000000000000000000000000000000000ddf0fdd
00000001110010000001111028e44444000000288888888828828288200000000000000000000000000000000000000000000000000000000000000000df0ffd
000000111100100000001110288bb4bbbbb002888228828828828288200000000000000000000000000000000000000000000000000000000000000000df0ffd
00000101110010000000111028e7777bbbb028882888828828828228822800000000000000000000000000000000000000000000000000000000000000df0ffd
000110011100110000011110288b7777bbb0288288222888828288228888000000000000000000000000000000000000000000000000000000000000000d0fdd
00111001110010111110111028eb7777bbb028288200288882882888288200000000000000000000000000000000000000000000000000000000000000df0fd0
0111110111001000000011102887777bbbb288288202882888288288822002800000000000000000000000000000000000000000000000000000000000df0fd0
00011111110010000000111028e4b4bb44b288828822820288828828888228820000000000000000000000000000000000000000000000000000000000df0fd0
000011111100100000001110288404044bb0288828288200288828828888882000000000000000000000000000000000000000000000000000000000000d0fdd
00000011110010111110111028e44444bbb002828828200228828820222222000000000000000000000000000000000000000000000000000000000000df0ffd
000000111100110000011110288bbbb4bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00000001110010000000111028ebbb777bbb4bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
000000011100100000001110288bbbb777b77bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000d0fdd
00000001110010000000111028ebbbb777bb77bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
000001111100111100001100288bbbb777bb77bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00011111110011111110100028ebfb777bb77bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0d00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004000000000000000400000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000040000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000
000040000000000000044400000000000004f4000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000777000000000000007000000000000000000000000000
00004000000000000004440000000000004fff400000000000404040000000000000400000000000000040000000000000004000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000007777700000000000777770000000000000000000000000
00004000000000000004440000000000004fff400000000000404040000000000040404000000000000040000000000000004000000000000000400000000000
00004000000000000004440000000000004fff400000000000490940000000000040004000000000000000000000000000000000000000000000000000000000
00000000000000000004440000000000004444400000000000499940000000000040004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000444000000000000044400000000000004440000000000000000000000000000000000000000000000000000000000
__sfx__
010a00003565329650186500060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006000060000600
010400003142334453324732f4732b473254731f47317463114530d4430b4330e423124131540314403104030d4030c4030b4030e40310403104030b4030a403094030b4030b4030b40308403054030440303403
010100001335110371213012f3012e301133011a3013a3012f301113011a3013f3011330125301293012e3013030131301313012b301123010c3010b3010c3010e3010030112301163011930118301133010c301
0003000016a701da701ba6017a600aa500da5013a4019a4008a300ba3013a2018a200ca1014a102ba0022a001aa0019a0019a001aa001ca001ba0018a0014a000fa000ca0009a0007a0006a0004a0002a0001a00
000100000d6100b6100b6100c6100d6100b6100b6100c6100d6100d61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100c101205014050160501205014050160501205014050160501405012050110500a05016050120500905001000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003564300003306430c603356433064300000000003564300003306430c6033564330643000000000035643000033064300003356430000330643000033564300003306433660335643306430000000000
000a00100b350286001735000000113501a3000b3501530018350333000b350183500b350193500c35000000113001d300000001630016300123000e3000e3000000000000000000000000000000000000000000
000f00101335313300153501535313300133531330015350153550000013350103530000012350143530000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014000005153295531f6502955300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c752007000c752007000c752007000c752107520c752157520c7521a7520c75006750007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011200181875300703187530c75318753007030c753187530c7531875308753007031875300703187530c75318753007030c753187530c7531875308753087530070300703007030070300703007030070300703
001200180e0300b0301603011030180300c0300c03004030120301203002030140300e03015030140301603019030160300903003030020301203004030130302400019000000000000000000000000000000000
000400003132534355323752f3752b375253751f37517365113550d345253252835526375233751f37519375133750b3650535501345193251c3551a37517375133750d375073750530504305000000000000000
__music__
02 05064344
03 0b4c4344
