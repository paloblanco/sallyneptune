
function tan(ang)
    return (sin(ang)/cos(ang))
end

-- field of view
fov = 0.25 -- 0.2 = 72 degrees
unit= abs(64/sin(fov*.5)) -- how big one block is
horizon = 64
resolution = 1
viewheight = 128
viewcenter = 64--viewheight/2

--camera plane info
xplane0 = cos(fov/2) 
yplane0 = sin(fov/2)
xplane1 = cos(-fov/2)
yplane1 = sin(-fov/2)
planelength = sqrt((xplane0-xplane1)^2 + (yplane0-yplane1)^2)
shortestdist = cos(fov/2)

-- true: to get wall patterns
-- based on distance

patterns={
[0]=0b0000000000000000.011,
0b0000000000000001.011,
0b0000010000000001.011,
0b0000010000000101.011,
0b0000010100000101.011,
0b0000010100100101.011,
0b1000010100100101.011,
0b1010010100100101.011,
0b1010010110100101.011}

-- map z
function mz(x,y)
	return 16-mget(x,y)*1
end

-- sort on dist
function sort(a)
    for i=1,#a do
        local j = i
        while j > 1 and a[j-1].dist < a[j].dist do
            a[j],a[j-1] = a[j-1],a[j]
            j = j - 1
        end
    end
end

-- tbj utility stuff
function center_x(str)
    return 64 - strwidth(str)/2
end

-------------------------------
function printc(_str,_y,_c)
    where=center_x(_str)
    if (where<0) where=0
    print(_str,where,_y,_c)
end
-------------------------------
-- centered and outlined
function printco(_str,_y,_c,_co)
    where=center_x(_str)
    if (where<0) where=0
    printo(_str,where,_y,_c,_co)
end

-------------------------------
function printo(str, x, y, c0, c1)
    for xx = -1, 1 do
        for yy = -1, 1 do
            print(str, x+xx, y+yy, c1)
        end
    end
    print(str,x,y,c0)
end
-------------------------------
-- string width with glyphs
function strwidth(str)
    local px=0
    for i=1,#str do
        px+=(ord(str,i)<128 and 4 or 8)
    end
    --remove px after last char
    return px-1
end

-------------------------------
-- sprite print
-- _c = letter color
-- _c2 = line color
-- _c3 = background color of font
-- collapse all these sprite
-- printing routines into one
-- function if you want!
function sprint(_str,_x,_y,_c,_c2,_c3)
    local i, num
    palt(0,false) -- make sure black is solid
    if (_c != nil) pal(7,_c) -- instead of white, draw this
    if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
    if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
    -- make color 5 and 6 transparent for font plus shadow on screen
     
    for i=1,#_str do
     num=asc(sub(_str,i,i))+160
     spr(num,(_x+i-1)*8,_y*8)
    end
    pal()
   end
   -------------------------------
   -- sprite print centered on x
   function sprintc(_str,_y,_c,_c2,_c3)
    local i, num
    _x=63-(flr(#_str*8)/2)
    palt(0,false) -- make sure black is solid
    if (_c != nil) pal(7,_c) -- instead of white, draw this
    if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
    if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
    -- make color 5 and 6 transparent for font plus shadow on screen
     
    for i=1,#_str do
     num=asc(sub(_str,i,i))+160
     spr(num,_x+(i-1)*8,_y*8)
    end
    pal()
   end
   -------------------------------
   -- sprite print at x,y pixel coords
   function sprintxy(_str,_x,_y,_c,_c2,_c3)
    local i, num
    palt(0,false) -- make sure black is solid
    if (_c != nil) pal(7,_c) -- instead of white, draw this
    if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
    if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
    -- make color 5 and 6 transparent for font plus shadow on screen
     
    for i=1,#_str do
     num=asc(sub(_str,i,i))+160
     spr(num,_x+(i-1)*8,_y)
    end
    pal()
   end
   -------------------------------
   -- double-sized sprite print at x,y pixel coords
   function dsprintxy(_str,_x,_y,_c,_c2,_c3)
    local i, num,sx,sy
    palt(0,false) -- make sure black is solid
    if (_c != nil) pal(7,_c) -- instead of white, draw this
    if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
    if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
    -- make color 5 and 6 transparent for font plus shadow on screen
    -- (btw you can use this technique
    -- just to draw sprites bigger)
    for i=1,#_str do
     num=asc(sub(_str,i,i))+160
     sy=flr(num/16)*8
     sx=(num%16)*8
     sspr(sx,sy,8,8,_x+(i-1)*16,_y,16,16)
    end
    pal()
   end
   -------------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
    chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|██▒🐱⬇️░✽●♥☉웃⌂⬅️🅾️😐♪🅾️◆…➡️★⧗⬆️ˇ∧❎▤▥~"
    -- '
    s2c={}
    c2s={}
    for i=1,#chars do
     c=i+31
     s=sub(chars,i,i)
     c2s[c]=s
     s2c[s]=c
    end
   end
   ---------------------------
   function asc(_chr)
    return s2c[_chr]
   end
   ---------------------------
   function chr(_ascii)
    return c2s[_ascii]
   end

   