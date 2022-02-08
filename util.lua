
function tan(ang)
    return (sin(ang)/cos(ang))
end

-- field of view
fov = 0.2 -- 0.2 = 72 degrees
unit= abs(64/tan(fov*.5)) -- how big one block is
horizon = 64
resolution = 1
viewheight = 128
viewcenter = 64--viewheight/2

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
	return 16-mget(x,y)*0.125
end

-- sort on dist_cam
function sort(a)
    for i=1,#a do
        local j = i
        while j > 1 and a[j-1].dist_cam < a[j].dist_cam do
            a[j],a[j-1] = a[j-1],a[j]
            j = j - 1
        end
    end
end