-- field of view
fov = 0.2 -- 0.2 = 72 degrees

-- true: to get wall patterns
-- based on distance

patterns={
[0]=0b0000000000000000,
0b0000000000000001,
0b0000010000000001,
0b0000010000000101,
0b0000010100000101,
0b0000010100100101,
0b1000010100100101,
0b1010010100100101,
0b1010010110100101}




function _init()
	-- create player
	pl = player:new()
    alist = {}
    add(alist,pl)
	-- map
	for y=0,31 do
		for x=0,31 do
			mset(x,y,mget(x,y)*3)
		end
	end
end



function _update()
	
	-- moving walls
	
	for x=10,18 do
		for y=26,28 do
			mset(x,y,34+cos(t()/4+x/14)*19)
		end
	end
	
	-- control player
	
	local dx=0
	local dy=0

	if (btn(❎)) then
		-- strafe
		if (btn(⬅️)) dx-=1
		if (btn(➡️)) dx+=1
	else
		-- turn
		if (btn(⬅️)) pl.d+=0.02
		if (btn(➡️)) pl.d-=0.02
	end
	
	-- forwards / backwards
	if (btn(⬆️)) dy+= 1
	if (btn(⬇️)) dy-= 1
	
	spd = sqrt(dx*dx+dy*dy)
	if (spd) then
	
		spd = 0.1 / spd
		dx *= spd
		dy *= spd
		
		pl.dx += cos(pl.d-0.25) * dx
		pl.dy += sin(pl.d-0.25) * dx
		pl.dx += cos(pl.d+0.00) * dy
		pl.dy += sin(pl.d+0.00) * dy
	
	end
	
	local q = pl.z - 0.6
	if (mz(pl.x+pl.dx,pl.y) > q)
	then pl.x += pl.dx end
	if (mz(pl.x,pl.y+pl.dy) > q)
	then pl.y += pl.dy end
	
	-- friction
	pl.dx *= 0.6
	pl.dy *= 0.6
	
	-- z means player feet
	if (pl.z >= mz(pl.x,pl.y) and pl.dz >=0) then
		pl.z = mz(pl.x,pl.y)
		pl.dz = 0
	else
		pl.dz=pl.dz+0.01
		pl.z =pl.z + pl.dz
	end

	-- jetpack / jump when standing
	if (btn(4)) then 
		if (pl.jetpack or 
					 mz(pl.x,pl.y) < pl.z+0.1)
		then
			pl.dz=-0.15
		end
	end

end

function draw_3d()
	local celz0
	local col
	
	-- calculate view plane
	
	local v={}
	v.x0 = cos(pl.d+fov/2) 
	v.y0 = sin(pl.d+fov/2)
	v.x1 = cos(pl.d-fov/2)
	v.y1 = sin(pl.d-fov/2)
	
	
	for sx=0,127,2 do
	
		-- make all of these local
		-- for speed
		local sy=127
	
		-- camera based on player pos
		local x=pl.x
		local y=pl.y
		-- (player eye 1.5 units high)
		local z=pl.z-1.5

		local ix=flr(x)
		local iy=flr(y)
		local tdist=0
		local col=mget(ix,iy)
		local celz=16-col*0.125
		
		-- calc cast vector
		local dist_x, dist_y,vx,vy
		local last_dir
		local t=sx/127
		
		vx = v.x0 * (1-t) + v.x1 * t
		vy = v.y0 * (1-t) + v.y1 * t
		local dir_x = sgn(vx)
		local dir_y = sgn(vy)
		local skip_x = 1/abs(vx)
		local skip_y = 1/abs(vy)
		
		if (vx > 0) then
			dist_x = 1-(x%1) else
			dist_x =   (x%1)
		end
		if (vy > 0) then
			dist_y = 1-(y%1) else
			dist_y =   (y%1)
		end
		
		dist_x = dist_x * skip_x
		dist_y = dist_y * skip_y
		
		-- start skipping
		local skip=true
		
		while (skip) do
			
			if (dist_x < dist_y) then
				ix=ix+dir_x
				last_dir = 0
				dist_y = dist_y - dist_x
				tdist = tdist + dist_x
				dist_x = skip_x
			else
				iy=iy+dir_y
				last_dir = 1
				dist_x = dist_x - dist_y
				tdist = tdist + dist_y
				dist_y = skip_y
			end
			
			-- prev cel properties
			col0=col
			celz0=celz
			
			-- new cel properties
			col=mget(ix,iy)
			
			--celz=mz(ix,iy) 
			celz=16-col*0.125 -- inlined for speed
			
-- print(ix.." "..iy.." "..col)
			
			if (col==72) then skip=false end
			
			--discard close hits
			if (tdist > 0.05) then
			-- screen space
			
			local sy1 = celz0-z
			sy1 = (sy1 * 64)/tdist
			sy1 = sy1 + 64 -- horizon 
			
			-- draw ground to new point
			
			if (sy1 < sy) then
				
				rectfill(sx,sy1-1,sx+1,sy-2,
					sget((celz0*2)%16,8))
				-- line if lower
				line(sx,sy1-1,sx+1,sy1-1,5)
				if (celz > celz0) then
					line(sx,sy1-1,sx+1,sy1-1,0)
				end	
				sy=sy1
			end
			
			-- draw wall if higher
			
			if (celz < celz0) then
				local sy1 = celz-z
				
				
				sy1 = (sy1 * 64)/tdist
				sy1 = sy1 + 64 -- horizon 
				if (sy1 < sy) then
					
					local wcol = last_dir*-6+13
					if (not skip) then
						wcol = last_dir+5
					end
					if (patterns) then
						fillp(patterns[min(flr(tdist/3),8)])
						wcol=103+last_dir*102
					end

					rectfill(sx,sy1-1,sx+1,sy,
					 wcol)
					line(sx,sy,sx+1,sy,0)
					line(sx,sy1-1,sx+1,sy1-1,0)
					 sy=sy1
					
					fillp()
				end
			end
		end   
		end -- skipping
	end -- sx

	cursor(0,0) color(7)
	print("cpu:"..flr(stat(1)*100).."%",1,1)
end


function _draw()
	cls()
	
	-- to do: sky? stars?
	rectfill(0,0,127,127,12)
	draw_3d()
	-- draw map
	if (false) then
		mapdraw(0,0,0,0,32,32)
		pset(pl.x*8,pl.y*8,12)
		pset(pl.x*8+cos(pl.d)*2,pl.y*8+sin(pl.d)*2,13)
	end
end
