pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function ___________built_in_funcitons()
		--remove me
end

function _init()

end

function _update()
end

--full lower case alphabet size =7*7		pos=0,16
--upper case alphabet size =12*11 			pos=37,23
--big font size = 12*21									pos=0,23
--big p is 23*26												pos,0,44
function _draw()
	cls(0)
	--a->z = 97->122
	--a->z = 65->90

	printlogo()

	print_str('412067616d65206d616465206279',24,72,7) --A game made by
	print_str('43726169672054696e6e6579',26,82,7) --Craig Tinney
	print_str('7b4769626c6574736f664a65737573',16,94,12) --@GibletsofJesus
	--Twitter handle shimmer
	for x=17,111 do
		for y=85,94 do
			if pget(x,y)!=0 then
				local start=((t()*66)-y*.5)%192
				if (x>start and x<start+4) pset(x,y,7)
			end
		end
	end

	local py=112+sin(t()*.5)*4
	print_str('5072657373',16,py,7) --Press
	print_str('58',52,py,8) --red X
	print_str('746f207374617274',64,py,7) --to start
	print(stat(1))
end

function ____________all_that_other_shit()
		--remove me
end

function printlogo()

	--Big P
	for x=0,23 do
		pal(1,13)
		local wiggle=sin(t()*-.33+((36+x)*.018))*2
		sspr(x,44,1,27,x+36,5+wiggle)
		pal(1,7)
		sspr(x,44,1,27,x+36,4+wiggle)
	end

	--ico
	local xls={59,69,81}
	for i=1,#xls do
		print_xl(xls[i],6,i-1,13)
		print_xl(xls[i],5,i-1,7)
	end

	--big P
	for x=0,23 do
		pal(1,13)
		local wiggle=sin(t()*-.33+((14+x)*.018))*2
		sspr(x,44,1,27,x+14,33+wiggle)
		pal(1,7)
		sspr(x,44,1,27,x+14,32+wiggle)
	end

	--pirates
	xls={37,47,60,72,80,92,104}
	local ls={0,3,4,5,7,8,9}
	for i=1,#xls do
		print_xl(xls[i],33,ls[i],13)
		print_xl(xls[i],32,ls[i],7)
	end
end

--pirate text
function print_s(_x,_y,_l,c)
	--total_layers=4
	--letters_per_layer=7
	--letter size, 7*7

	--Find index of letter to print and which colour layer to look at
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(c,layer)
	sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(c,layer)
	sspr((12*l)+37,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	local layer=(_l-l)/3

	set_col_layer(c,layer)

	for x=0,11 do
		local wiggle=sin(t()*-.33+((_x+x)*.018))*2
		sspr((12*l)+x,23,1,21,_x+x,_y+wiggle)
	end
	pal()
end

function print_str(str,x,y,c)
	str=unhex(str,2)
	local p=x--x position
	for s=0,#str-1 do
		if str[s+1]>96 then
			print_s(p,y,str[s+1]-97,c)
			p+=6
		else
			print_l(p,y,str[s+1]-65,c)
			p+=9
			if (str[s+1]<65)p-=6
		end
	end
end

function set_col_layer(c,b)
	for i=0,15 do
		pal(i,0)
		palt(i,true)
		if (band(shl(i),2^b)>0) pal(i,c) palt(i,false)
	end
end

function unhex(s,n)
	n=n or 2
	local t={}
	for i=1,#s,n do
		add(t,('0x'..sub(s,i,i+n-1))+0)
	end
	return t
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
00000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aae5fba057770008eff908ff7daa0bffd9005dddd046617760000000000000000000000000000000000000000000000000000000000000000000000000000000
0e501e088528d804d284008700f00c708500e14ad006320600000000000000000000000000000000000000000000000000000000000000000000000000000000
06b3b60085f580050a04000f6e10007d4000a3d2a007023700000000000000000000000000000000000000000000000000000000000000000000000000000000
070816008d28900582850007807040b04e00a1e8a007002700000000000000000000000000000000000000000000000000000000000000000000000000000000
23edf320df7b8008dfd8007ff9600ffffb023dde2222755200000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000022004400000060000001000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001100000000000000000000000000008800000000000000000000008880000000008880000000000000000000022200000000002220002220000000000
00000811000000000000000000000000000002aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd10000675555572000466515740000000000
000088900000000000000000000000000000002e9550a00009d40aa9d48800049e6090004512a845380000097208d10000623540370000067200700000000000
0008c8880000000000000000000020000044006f8114b100008817e9140800459a2c00000006f906910000017688010000223540230000077200600000000000
000cc88800000000000000000002200000440467993b6000008817fd400804551aa040000006fd68110000013ec5000000203743020000175220600000000000
0044e98002000000023400000022650000040067aa19640000089f69908000451aa0440000067be011000001bb15400000203753020000075221700000000000
0046ffd42220022227777222002677775440007608817000000097609900004592a840000006798710000001fa01060000201761020000075022700000000000
0467ffd72222002453777720027727775510003608853000000097619800000c12ac0100000679871000000db200c20000201760020000065022700000000000
0246fbb022200065510776400577200115100133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb31002225554222000226557200000000000
00467b10020000475102764005772000511002000000000000000000000000000200c40000200000060000020000000000010000000000000000200000000000
00467b10000000475102264405772004111000000000000000000000000000222000088000000000006600000000000000000000000000000000022000000000
00467b10000000677102260005772044551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000002655306620005776044555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000002655162220005776404555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000022655502220001776000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00467310000022655102220001336000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000022655102220001372000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0046fb90100022675122224011733000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
046effbd200026777753272213777752510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0046fff2000002267557720004677775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004b00000000200410200040002150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111000010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111100010111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000011110011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110110000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001111010000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000101110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011001110011000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111001110010111110111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111101110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110010111110111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011110011000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111110011110000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111110011111110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111110011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000001110010000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
090a0a0a0a0b00090a0a0a0a0a0a0a0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
192d2d2d2d1b00192d2d2d2d2d2d2d1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1a1c0a1d1a1a1a1a1a1a1a1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1a3c3d3e1a1a1a1a1a1a1a1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a051a1a1a1a1a1a0c0d1a1a1a1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1a0c2a0d1a1a1b191a1a1a1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2a2a2a2b00292a2a2b191a0c2a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0a0a0b090a0a0a0a0b09380b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
192d2d2d1b192d2d2d2d1c1d2d1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1b191a0c0d1a2c2e1a1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1c1d1a1b191a1a1a1a1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a2c2e1a1b292a2a2a2a2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1a1a1a1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a0c2a2a2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a1a1a1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292a2a2a2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
