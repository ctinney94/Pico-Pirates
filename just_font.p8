pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _draw()
	cls(12)

	--controls

	--what is pp
	print_str('5720686174206973205069636f20506972617465733f',4,12,7)
	--What's new?
	--What's next?
	--Where can I keep up with development news?
	print_str('57206861742773206e657720696e20746869732076657273696f6e3f',4,24,7)

	?"?",68,31,1
	?"?",68,30,7

	--what next?
	print_str('572068617473206e6578743f',4,36,7)

	print_str('5720686572652063616e2049206b656570207570207769746820646576656c6f706d656e74206e657773',4,48,7)

	print_str('536f6d657468696e672062726f6b6521',4,64,7)

end

function print_s(_x,_y,_l,c)
	--total_layers=4
	--letters_per_layer=7
	--letter size, 7*7

	--Find index of letter to print and which colour layer to look at
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	sspr(7*l,16,7,7,_x,_y-6)
	set_col_layer(c,layer)
	sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	sspr(12*l,23,12,11,_x,_y-9)
	set_col_layer(c,layer)
	sspr(12*l,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	local layer=(_l-l)/3
	for x=49,61 do
		local wiggle=sin(t()*-.33+((_x+x)*.018))*2
		set_col_layer(13,layer)
		sspr((12*l)+x,0,1,22,_x+x,_y+wiggle+1)
		set_col_layer(c,layer)
		sspr((12*l)+x,0,1,22,_x+x,_y+wiggle)
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
	local xls=stringToArray"10,20,32,★"
	for i=1,#xls do
		print_xl(xls[i],5,i-1,7)
	end

	local vals=stringToArray"-71,33,13,-71,32,7,-49,5,13,-49,4,7,★"
	--big Ps
	for i=1,12,3 do
		for x=86,109 do
			pal(1,vals[i+2])
			local a=x+vals[i]
			sspr(x,0,1,26,a,vals[i+1]+sin(t()*-.33+(a*.018))*2)
		end
	end

	--pirates
	xls=stringToArray"-12,-2,11,23,31,43,55,★"
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
0040000000040000000001d77000000000000007000000000000000011000000000000000000000000000000011111000010001000000000000000000000000d
7777000007670000011115d7000000000000000011000000000000811000000000000000000000000000000011111110001011111000000000000000000000df
0777700000767000022449a7000000066000000021100000000008890000000000000000000000000000000100001111001111111100000000000000000000df
077770000067670003399aa700000066660000003311000000008c888000000000000000000002000004400000000111011000011110000000000000000000df
777700000676700004499aa70000066666600000442210000000cc88800000000000000000002200000440000000011110100000111100000000000000000ddf
4040044020040022055dd66700006666666600005511000000044e98002000000023400000022650000040000000011100100000011110000000000000000dff
414144002212122006677777000000666600000066dd510000046ffd422200222277772220026777754400000000111100100000001110000000000000000dff
4444400022222200077777770000006666000000776dd51000467ffd722220024537777200277277755100000001011100100000001110000000000000000dff
01249af777fa00000888ee7700000066660000008882210000246fbb022200065510776400577200115100000110011100110000011110000000000000000ddf
012499aaa99000000999aaa7000000666600000099942100000467b10020000475102764005772000511000011100111001011111011100000000000000000df
00000000000000000aa777770000006666000000aa994210000467b10000000475102264405772004111000111110111001000000011100000000000000000df
00000000000000000bbaaa770000006666000000bbb33100000467b10000000677102260005772044551000001111111001000000011100000000000000000df
00000000000000000ccc77770000006666000000ccdd5110000467b1000000265530662000577604455500000011111100100000001110000000000000000ddf
00000000000000000dd666670000000000000000dd511000000467b1000000265516222000577640455500000000111100101111101110000000000000000dff
00000000000000000eeee7770000000000000000ee882210000467b1000002265550222000177600055500000000111100110000011110000000000000000dff
00000000000000000fffff777000000000000007fff9421000046731000002265510222000133600055500000000011100100000001110000000000000000dff
000000000000000000000000000000000000000000220000000467b1000002265510222000137200055500000000011100100000001110000000000000000ddf
aae5fba057770008eff908ff7daa0bffd9005dddd046617760046fb9010002267512222401173300055500000000011100100000001110000000000000000dff
0e501e088528d804d284008700f00c708500e14ad00632060046effbd20002677775327221377775251000000001111100111100001100000000000000000dff
06b3b60085f580050a04000f6e10007d4000a3d2a007023700046fff200000226755772000467777500000000111111100111111101000000000000000000dff
070816008d28900582850007807040b04e00a1e8a0070027000004b0000000020041020004000215000000011111111100111111110000000000000000000ddf
23edf320df7b8008dfd8007ff9600ffffb023dde2222755200000000000000000000000000000040000000110000011100100001100000000000000000000dff
10000000000000022004400000060000001000000000000020000000000000000000000000000000000000000000011100100000000000000000000000000dff
88000000000000000000000088800000000088800000000000000000000022000000000022200022200000000000011100100000000000000000000000000dff
2aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd100006755555720004665157400000000000011100100000000000000000000000000ddf
02e9550a00009d40aa9d48800049e6090004512a845380000097208d1000062354037000006720070000000000000111110000000000000000000000000000df
06f8114b100008817e9140800459a2c00000006f90691000001768801000022354023000007720060000000000000000000000000000000000000000000000df
467993b6000008817fd400804551aa040000006fd68110000013ec500000020374302000017522060000000000000000000000000000000000000000000000df
067aa19640000089f69908000451aa0440000067be011000001bb154000002037530200000752217000000000000000000000000000000000000000000000ddf
07608817000000097609900004592a840000006798710000001fa010600002017610200000750227000000000000000000000000000000000000000000000dff
03608853000000097619800000c12ac0100000679871000000db200c200002017600200000650227000000000000000000000000000000000000000000000dff
133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb310022255542220002265572000000000000000000000000000000000000000000000dff
2000000000000000000000000000200c400002000000600000200000000000100000000000000002000000000000000000000000000000000000000000000ddf
000000000000000000000000022200008800000000000660000000000000000000000000000000002200000000000000000000000000000000000000000000df
0000000000000222220000000000002000000999999999994000007c0007c00000000000000000000000000000000000000000000000000000000000000000df
00000000000228888822000000000288000095555555555924008cb9a07a8a0000000000000000000000000000000000000000000000000000000000000000df
0000000002288882828820000000028e00095555555555922407b9a897c9ab000000000000000000000000000000000000000000000000000000000000000ddf
00000000288888882888820000000288009999999999999224c9ac797a9ac9000000000000000000000000000000000000000000000000000000000000000dff
0000000288888882828882000000028e0a11111111111144409b7a9c9ba990000000000000000000000000000000000000000000000000000000000000000dff
00000029888888288888820000000288a11111111111144000000000000000000000000000000000000000000000000000000000000000000000000000000dff
0000002a98888888888882000000028eaaaaaaaaaaa9424000000000000000000000000000000000000000000000000000000000000000000000000000000ddf
00000029a98889999888820000000288a222a1192229224000000000000000000000000000000000000000000000000000000000000000000000000000000dff
0000002898889aaa988882000000028ea288a1192889224000000000000000000000000000000000000000000000000000000000000000000000000000000dff
00000028888899998888200000000288a28889928889224000000000000000000000000000000000000000000000000000000000000000000000000000000dff
0000002888888888888820000000028ea28888888889224000000000000000000000000000000000000000000000000000000000000000000000000000000ddf
00000028888888888882000000000288a288888888892400000000000000000000000000000000000000000000000000000000000000000000000000000000df
0000002888888888882820000000028ea999999999994000000000000000000000000000000000000000000000000000000000000000000000000000000000df
0000028888888888228820000000028800aaaaaaaaaaa90088000008000000000000000000000000000000000000000000000000000000000000000000000ddf
0000288888888822882882000000028e0a2222222222924888800088800000000000000000000000000000000000000000000000000000000000000000000ddf
00028888888882882828820000000288a28888888889224188880888800000000000000000000000000000000000000000000000000000000000000000000dff
0028882288288288282882000000028ea2888aa28889244018888888100000000000000000000000000000000000000000000000000000000000000000000dff
02888288882882882822882280000288aaaaa1199999424001888881000000000000000000000000000000000000000000000000000000000000000000000dff
0288288222888828288228888000028ea222a1192229224008888810000000000000000000000000000000000000000000000000000000000000000000000000
02828820028888288288828820000288a288a1192889224088888880000000000000000000000000000000000000000000000000000000000000000000000000
2882882028828882882888220028028ea28889928889224888818888000000000000000000000000000000000000000000000000000000000000000000000000
28882882282028882882888822882288a28888888889224888101888800000000000000000000000000000000000000000000000000000000000000000000000
0288828288200288828828888882028ea28888888889240181000188100000000000000000000000000000000000000000000000000000000000000000000000
00282882820022882882022222200288a99999999999400010000011000000000000000000000000000000000000000000000000000000000000000000000000
0ddddd000ddddd0000000ddddddddddddddddddddd000ddddddddd000ddddd0000000ddddd0000000ddddddddd000ddddd000000000000000000000000000000
ddfffdddddfffdddd0ddddfffdfffdfffdfffdfffdddddfffdfffdddddfffdddd0ddddfffdddd0ddddfffdfffdddddfffdddd0ddd00000000000000000000000
dffffffffffffffffdfffffffffffffffffffffffffffffffffffffffffffffffdfffffffffffdfffffffffffffffffffffffdfffd0000000000000000000000
fff000ffffff00ffff000ffffff0000ffff000fffff00fff000ff000000ff00000ffff00fff00ff0ffffffff0fff000ffffffff0ffffff000000000000000000
0f00000f00f00f0000f0f00f00f000f000ff000f000f00ff000f00000000f0000f0000f00f0000f00f00f00f00f00000f00f00f00f0000f00000000000000000
00f000f000f0f00000f0000f00000f00000ff00f000f000f000f00000000f000f00000f00f0000f00f00f000000f000f000f00000f00000f0000000000000000
00f000f000f0f0000000000f0000f0000000f00f000f000f00f00000000fff00f00000000f0000f00f00f000000f000f000f00000f00000f0000000000000000
00f000f000f0f0000000000f0000f0000000f00f000f0000f0f00000000f0f00f00000000f0000f00f00f00f000f000f000f00f00f00000f0000000000000000
00f00f0000f0f0000000000f0000f0000000f00f00f00000ff000000000f0f00f00000000ffffff00f00ffff000f00f0000ffff00f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00fff000000ff00000000f00f00f00000000f0000f00f00f00f0000f0f0000f00f00f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00f0ff000000f00000000fffff0f00000000f0000f00f00f0000000f0f0000f00000f00000f0000000000000000
000f0f0000f0f0000000000f0000f0000000f00f00ff00000f00000000f000f0f00000000f0000f00f00f0000000f0f0000f00000f00000f0000000000000000
0000f00000f0ff0000f0000f00000f000000f00f00ff00000f00000000f000f0ff0000f00f0000f00f00f000f0000f00000f000f0f00000f0000000000000000
0000f00000f00f0000f0000f000000f0000f000f000ff0000f0000000f0000ff0f0000f00f0000f00f00f00f00000f00000f00f00f0000f00000000000000000
0000f0000fff00ffff00000ff000000ffff0000f0000f000ff000000ff0000ff00ffff00fff00fffffffffff00000f0000fffff0ffffff000000000000000000
00000000000000000000000000000000000000f0f000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004440000000004f400000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000400040000000000000000000077700000000007000000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000404040000000004000000000004000000000004000000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000400040000000000000000000777770000000777770000000000000000000000000000000000000000000000000000000000000
000444000000004fff40000000404040000000404040000000004000000000004000000000004000000000000000000000000000000000000000000000000000
000444000000004fff40000000490940000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044400000000444440000000499940000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000044400000000044400000000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
