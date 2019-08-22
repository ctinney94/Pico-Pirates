pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
    for x=0,160 do
      add(ps,{x=sin(x/50)*(rnd(96)),y=-cos(x/50)*(rnd(96))})
    end
end
r=0 z=1

ps={}

function _update()
  if (btn(0)) r+=0.01
  if (btn(1)) r-=0.01
  if (btn(2)) z+=1
  if (btn(3)) z-=1
  if (btn(4)) r=0
  if (btn(5)) z=1

  z=6+(sin(t())*5)
  --r+=0.01
end

function _draw()
  cls(12)

  for p in all(ps) do
    --rectfill(64+(p.x*z)-z,64+(p.y*z)-z,64+(p.x*z),64+(p.y*z),col)
    circfill(64+p.x*z,64-p.y*z,z-1,7)
  end

  local s=sin(r)
  local c=cos(r)
  local _b=s*s+c*c
  local size = 8/2
  local w = sqrt(size^2*2)
  for y=-w,w do
    for x=-w,w do
      local ox=( s*y+c*x)/_b+size
      local oy=(-s*x+c*y)/_b+size
      local col=sget(ox+12,oy+4)
      if col>0 then
        rectfill(64+(x*z)-z,64+(y*z)-z,
          64+(x*z),64+(y*z),col)
        --circfill(64+x*z,64+y*z,z,col)
      end
    end
  end
end
__gfx__
00000000700000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000000004f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000000004fff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000477740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007f4f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000004fff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000074f4f47000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000049f940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000499940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000