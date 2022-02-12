
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