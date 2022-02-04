pico-8 cartridge // http://www.pico-8.com
version 35
__lua__

#include thing.lua 
#include util.lua
#include actor.lua
#include player.lua
#include main.lua



__gfx__
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00700700111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00077000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00077000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00700700111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
32222228a9e89aeb00000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000ffffffff
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000f888888f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
0000000000000000000000000000000044ffff4400000000000000000000000088ffff88000000000000000000000000000000000000000000000000f8ffff8f
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000f888888f
000000000000000000000000000000004444444400000000000000000000000088888888000000000000000000000000000000000000000000000000ffffffff
70707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01888810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18188181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18188181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01888810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00188100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666
cc77c777c7c7ccccc777c7c7c7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666
c7ccc7c7c7c7cc7cc7ccc7c7ccc7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666
c7ccc777c7c7ccccc777c777cc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666
c7ccc7ccc7c7cc7cccc7ccc7c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666
cc77c7cccc77ccccc777ccc7c7c7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666
555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666666
55555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666
5555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666666666666666666
55555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666
5555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666
555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666666
55555555555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666666
555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666666666666666666666666
55555555555555555555555555555555555555555cccccccccccccccccccccccccccccccccccccccccccccccccccccc666666666666666666666666666666666
5555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccccccccc6666666667d666666666666666666666666
555555555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccccccccc66666666777ddddd66666666666666666666
5555555555555555555555555555555555555555555555555555555ccccccccccccccccccccccccccccccccccc6666666677777dddddddd66666666666666666
555555555555555555555555555555555555555555555555555555555555cccccccccccccccccccccccccccc666666666777777ddddddddddd66666666666666
55555555555555555555555555555555555555555555555555555555555555555cccccccccccccccccccccc6666666677777777dddddddddddddd66666666666
5555555555555555555555555555555555555555555555555555555555555555555555ccccccccccccccc666666667777777777dddddddddddddddddd6666666
55555555555555555555555555555555555555555555555555555555555555555555555555ccccccccc66666666777777777777ddddddddddddddddddddd6666
5555555555555555555555555555555555555555555555555555555555555555555555555555555ccc666666667777777777777dddddddddddddddddddddddd6
5555555555555555555555555555555555555555555555555555555555555555555555555555555556666666777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556666677777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556667777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555556677777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555555777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555557777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555555555555555555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555555dddddddddd55555555555577777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777dddddddddddddddddddddd77777777777777777777777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777dddddddddddddddddddddd77777777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777ddddddddddddddddddddddddd777777777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
555555555555555555555555555555555577777777ddddddddddddddddddddddddddd7777777777777777777777777777777777ddddddddddddddddddddddddd
55555555555555555555555555555555557777777777aaaaaaaaaaaaaaaaaaaaddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddddddddddddddd77777777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777ddddddddddddddddddeeeeeeeeeeeeeeeee7777777777777777777777ddddddddddddddddddddddddd
5555555555555555555555555555555555777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddd7777777777777777ddddddddddddddddddddddddd
5555555555555555555333333333333333377777777777777eeeeeeeeeeeeeddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333377777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333337777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333777777777777dddddddddddddddddddddddddddddddddddd7777777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333337777777777ddddddddddddddddddddddddddbbbbbbbbbbbbbb777777777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333333777777777dddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb777777ddddddddddddddddddddddddd
333333333333333333333333333333333333333333337777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7ddddddddddddddddddddddddd
33333333333333333333333333333333333333333333377777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddddddddddddddddddddddddddddddd
3333333333333333333333333333333333333333333333777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddddddddddddddddddddddddddddddddddddddddd
333333333333333333333333333333333333333333333333777777777bbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddddddddddddddddddddddddd333333
33333333333333333333333333333333333333333333333337777777777bbbbbbbddddddddddddddddddddddddddddddddddddddddddddddddd3333333333333
333333333333333333333333333333333333333333333333337777777777dddddddddddddddddddddddddddddddddddddddddddddddd33333333333333333333
333333333333333333333333333333333333333333333333333377777777ddddddddddddddddddddddddddddddddddddddddd333333333333333333333333333
333333333333333333333333333333333333333333333333333337777777dddddddddddddddddddddddddddddddddd3333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333377777dddddddddddddddddddddddddd333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333337777ddddddddddddddddddd3333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333777dddddddddddd33333333333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333337ddddd333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

__map__
1818181818181818181818181818181818181818181818181818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060708090a0b000000000000000001000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060708090a0b000100000000000101010000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060c0c0c0c0c000000000404000001000005000000000c030303030c0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060c0c0c0c0c000000000404000000000505050000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060504030201000000000000000000000005000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1806060504030201000000000000000000000000000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000303030303030018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000c030303030c0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000001000001000000000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000010000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000001000001000000000001000100000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000010000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800140d0d01010d0d1400000000000000000000000000000102030302010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d02020d0d0d00000000000000000000000001000102040402010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d03030d0d0d00000000000000000000000000000102050502010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d04040d0d0d00000000000000000000000000000102060602010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d05050d0d0d00000000000000000000000000000102070702010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d00000000000000000000000000000102080802010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d00000000000000000000000000000102090902010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d000000000000000000000000000001020a0a02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0606060606060d000000000000000000000000000001020b0b02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18001406060606060614000000000000000000000000000001020c0c02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d07070d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d08080d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d09090a0b0c0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d09090a0b0c0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
18000d0d0d0d0d0d0d0d0000000000000000000d0d0d0d0d0d0d0d0d02010018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1800000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1818181818181818181818181818181818181818181818181818181818181818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144
00 41414144

