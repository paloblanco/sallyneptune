function _init()
	-- setup stuff
	setup_asciitables()
	-- start_gameplay()
	start_title()
end

function init_gameplay()
	
	-- create player
	pl = player:new()
    alist = {}
	cpt = neato:new({x=6,y=4,z=12})
	add(alist,cpt)



	-- m1 = myrtle:new({x=9,y=4,z=12})
	-- add(alist,m1)
	-- m2 = myrtle:new({x=9,y=6,z=12})
	-- add(alist,m2)

	-- g = goal:new({x=12,y=8,z=10})
	-- add(alist,g)
	fix_map()
	
	pl:update(cpt)

	locklistold = {}
	locklist={} -- who is in your sights
	mylock = nil

	timer=0
end

function fix_map()
	actor_tiles = {}
	actor_tiles[155] = heart
	actor_tiles[141] = myrtle
	actor_tiles[142] = goal
	actor_tiles[161] = neato

	for xx=0,15,1 do
		for yy=1,15,1 do
			tileup = mget(xx,yy-1)
			tilehere = mget(xx,yy)
			actorhere = actor_tiles[tilehere]
			if (actorhere!= nil) then
				mset(xx,yy,tileup)
				if tilehere == 161 then
					cpt.x=xx
					cpt.y=yy
				else
					local newact = actorhere:new({x=xx,y=yy,z=mz(xx,yy)})
					add(alist,newact)
				end
			end
		end
	end
	-- return cpt
end


function draw_3d()
	local celz0
	local col
	local deptharray = {}
	
	-- calculate view plane
	
	local v = pl:return_view()
	-- camera based on player pos
	local x=pl.x
	local y=pl.y
	-- (player eye 1.5 units high)
	local z=pl.z-1
	local res = resolution-1
	local ystart = viewheight-1
	local ymid = viewcenter
		
	for sx=0,127,resolution do
		local depthi = {}
	
		-- make all of these local
		-- for speed
		local sy = ystart
	
		local ix=flr(x)
		local iy=flr(y)
		local tdist=0
		local col=mget(ix,iy)
		local tiletype = tileinfo[col\16]
		local spr_ix = tiletype[1]
		local g_color =  tiletype[2]
		col = col%16
		local celz=16-col*.5
		
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
		local wall_prev=false
		local lower_elevation=false
		lowcount=0

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
			local g_color0 = g_color
			
			-- new cel properties
			col=mget(ix,iy)
			tiletype = tileinfo[col\16]
			spr_ix = tiletype[1]
			spr_x_coord = (spr_ix%16)*8
			spr_y_coord = (spr_ix\16)*8
			g_color =  tiletype[2]
			col = col%16

			celz=16-col*.5 -- inlined for speed
			
			
			if (col==15) then skip=false end
			if (tdist > 60) skip = false --max draw distance
			
			--discard close hits
			if (tdist > 0.005) then
			-- screen space
			
			local sy1 = celz0-z
			-- sy1 = (sy1 * ymid)/tdist
			sy1 = (sy1 * unit)/tdist
			sy1 = sy1 + horizon -- horizon 
			
			-- draw ground to new point
			
			if (sy1 < sy) then
				rectfill(sx,sy1-1,sx+res,sy,g_color0) -- floor drawing
				line(sx,sy,sx+res,sy,5) -- floor accent
				if (wall_prev) then
					line(sx,sy,sx+1,sy,0)
					wall_prev=false
				end	
				if lower_elevation then
					line(sx,sy,sx+res,sy,0)
					lower_elevation=false
				end
				sy=sy1
			end
			
			--lower floor?
			if (celz>celz0) then
				lower_elevation=true
				lowcount = lowcount +1
				add(depthi,{tdist,sy1})
			end

			-- draw wall if higher
			if (celz < celz0) then
				-- local wallx
				if last_dir == 0 then
					wallx = (y + tdist*vy)%1
				else
					wallx = (x + tdist*vx)%1
				end
				local pixx = flr(wallx*8)
				local sy1 = celz-z
				local yscale = unit/tdist
				sy1 = sy1 * yscale
				sy1 = sy1 + horizon -- horizon 
				if (sy1 < sy) then
					palt(0,false)
					fillp(patterns[min(flr(tdist/3),8)])
					local wcol=7 + (last_dir)*6
					-- rectfill(sx,sy1-1,sx+res,sy,wcol) -- wall draw
					local yf = sy1
					while yf+1 < sy do
						local ystep = yscale
						if yf+ystep > -1 then
							if (sy < 127) ystep = min(yscale,sy-yf)
							local dyspr = .5+8*ystep/yscale --  add .5 to improve tex tearing
							sspr(spr_x_coord+pixx,spr_y_coord,1,dyspr,sx,yf,resolution,ystep+1)
						end
						yf = yf+yscale
					end
					line(sx,sy,sx+res,sy,0) -- accent
					sy=sy1
					fillp()
					wall_prev=true
					add(depthi,{tdist,sy1})
					palt()
				end
				-- flip()
			end
			
			
		end   
	
		end -- skipping
		deptharray[sx]=depthi	
	end -- sx
	return deptharray
end

function update_gameplay()
	
	locklistold = locklist
	locklist={}
    for aa in all(alist) do
        aa:update()
    end
	pl:update(cpt)

	if #locklist > 0 then
		sort(locklist)
		mylock = locklist[#locklist]
	else
		mylock = nil
	end

	timer += 1

	if cpt.health <= 0 then
		for i = 127,0,-5 do
			_draw()
			rectfill(0,127,127,i,0)
			flip()
		end
		start_gameover()
	end
end

function draw_gameplay()
	-- cls()
	-- to do: sky? stars?
	rectfill(0,0,127,viewheight-1,1)
	deptharray = draw_3d()
	
	-- sort sprites
	for aa in all(alist) do
		aa:get_cam_params(pl.x,pl.y,pl.z,pl.d)
	end
	sort(alist)
	
	-- draw sprites
	for aa in all(alist) do
		aa:draw()
	end


	-- GUI
	--LOCK
	if (mylock) then
		circ(mylock.sx,mylock.sy,10,9)
		-- circ()
	end
	if cpt.target then
		circ(cpt.target.sx,cpt.target.sy,11,8)
	end

	printo("health: ",2,2,10,0)
	healthmeter = max(50*(cpt.health/cpt.maxhealth),0)
	rectfill(30,2,82,5,0)
	rectfill(31,3,31+healthmeter,4,10)



	cursor(0,40) color(0)
	print("cpu:"..flr(stat(1)*100).."%")
	-- print("pl :"..pl.d)
	-- print("pl:"..pl.x.." "..pl.y.." "..pl.z)
	
	print("alist: "..#alist)
	print("cptz: "..cpt.z)
	print("off: "..cpt.offtime)
end

function start_gameplay()
	init_gameplay()
	cls(0)
	update_gameplay()
	for i=127,0,-5 do
		draw_gameplay()
		rectfill(0,0,127,i,0)
		flip()
	end
	_update = update_gameplay
	_draw = draw_gameplay
end

function init_title()
	colormax = #colors
	colornext = 1
	rectangles={}
	cls(0)
	titletimer=0
end

function update_title()
	if titletimer%10==0 then
		add(rectangles,{1,colornext})
		colornext = 1+((colornext)%colormax)
	end
	for r in all(rectangles) do
		r[1] += 1
		if (r[1] > 70) del(rectangles,r)
	end

	if btnp(4) or btnp(5) then
		for i = 127,0,-5 do
			rectfill(0,127,127,i,0)
			flip()
		end
		start_gameplay()
	end
	titletimer += 1
end

function draw_title()
	cls(1)
	for r in all(rectangles) do
		rectfill(64-r[1],64-r[1],64+r[1],64+r[1],colors[r[2]])
	end

	dsprintxy("sally",5,15,14,0,0)
	dsprintxy("neptune",12,32,14,0,0)
	printco('vs the monocronies', 52, 14, 0)

	printco("by palo blanco for toyboxjam 3",110,7,0)
	printco("press z or x to start!",118,14,0)

	pal(7,15)
    pal(13,1)
    pal(10,14)
    pal(3,10)
    pal(2,14)
    pal(12,6)
    -- pal(8,13)
    pal(5,1)
    pal(12,1)
    pal(6,10)
	ixnow = ((titletimer\3)%4)*2
	local spx = 16 + 8*ixnow
	local spy = 0
	sspr(spx,spy,16,16,64-16,76,32,32)
	pal()

end

function start_title()
	init_title()
	_update = update_title
	_draw = draw_title
end

function start_gameover()
	init_gameover()
	_update = update_gameover
	_draw = draw_gameover
end

function init_gameover()
	colormax = 3
	colornext = 1
	rectangles={}
	cls(0)
	titletimer=0
	color_gameover = {0,5,6}
end

function update_gameover()
	if titletimer%20==0 then
		add(rectangles,{1,colornext})
		colornext = 1+((colornext)%colormax)
	end
	for r in all(rectangles) do
		r[1] += 1
		if (r[1] > 70) del(rectangles,r)
	end

	if btnp(4) or btnp(5) then
		for i = 127,0,-5 do
			rectfill(0,127,127,i,0)
			flip()
		end
		start_gameplay()
	end
	titletimer += 1
end

function draw_gameover()
	cls(0)
	for r in all(rectangles) do
		rectfill(64-r[1],64-r[1],64+r[1],64+r[1],color_gameover[r[2]])
	end

	dsprintxy("nice try",0,15,6,0,0)
	dsprintxy("sally...",3,32,6,0,0)
	printco("press z or x to try again", 60, 7, 0)

	pal(7,15)
    pal(13,1)
    pal(10,14)
    pal(3,10)
    pal(2,14)
    pal(12,6)
    -- pal(8,13)
    pal(5,1)
    pal(12,1)
    pal(6,10)
	ixnow = ((titletimer\3)%4)*2
	local spx = 0
	local spy = 0
	sspr(spx,spy,16,16,64-16,76,32,32)
	pal()
end

function start_gamewin()
	init_gamewin()
	_update = update_gamewin
	_draw = draw_gamewin
end

function init_gamewin()
	colormax = #colors
	colornext = 1
	rectangles={}
	cls(0)
	titletimer=0
	time_minutes = timer\1800
	time_seconds = (timer\30)%60
	str_seconds = ""..time_seconds
	if (time_seconds < 10) str_seconds = "0"..time_seconds
	str_time = ""..time_minutes..":"..str_seconds
end

function update_gamewin()
	if titletimer%10==0 then
		add(rectangles,{1,colornext})
		colornext = 1+((colornext)%colormax)
	end
	for r in all(rectangles) do
		r[1] += 1
		if (r[1] > 70) del(rectangles,r)
	end

	if (btnp(4) or btnp(5)) and titletimer>60  then
		for i = 127,0,-5 do
			rectfill(0,127,127,i,0)
			flip()
		end
		start_gameplay()
	end
	titletimer += 1
end

function draw_gamewin()
	cls(14)
	for r in all(rectangles) do
		rectfill(64-r[1],64-r[1],64+r[1],64+r[1],colors[r[2]])
	end

	dsprintxy("you",5,15,14,0,0)
	dsprintxy("did it!",12,32,14,0,0)
	printco('time: '..str_time, 52, 14, 0)

	printco("by palo blanco for toyboxjam 3",110,7,0)
	printco("thanks for playing!",118,14,0)

	pal(7,15)
    pal(13,1)
    pal(10,14)
    pal(3,10)
    pal(2,14)
    pal(12,6)
    -- pal(8,13)
    pal(5,1)
    pal(12,1)
    pal(6,10)
	ixnow = ((titletimer\3)%4)*2
	local spx = 16 + 8*ixnow
	local spy = 0
	sspr(spx,spy,16,16,64-16,76,32,32)
	pal()

end