function _init()
	-- setup stuff
	setup_asciitables()
	-- start_gameplay()
	start_title()
	music(6)
end

function init_gameplay()
	
	-- create player
	pl = player:new()
    alist = {}

	guns=0
	gunsmax=0
	kills=0
	killmax=0
	
	fix_map()
	
	pl:update(cpt)

	-- sort sprites
	for aa in all(alist) do
		aa:get_cam_params(pl.x,pl.y,pl.z,pl.d)
	end
	sort(alist)

	sectors={}
	for xx=0,127,16 do
		local sec = {}
		local xnext = xx+16
		secix = xx\16
		sectors[secix] = sec
	end

	for aa in all(alist) do
		if aa.x > 32 then
			aa:to_sector()
		end
	end

	locklistold = {}
	locklist={} -- who is in your sights
	mylock = nil
	
	timer=0
	music(-1)
	flipline=false
end

function fix_map()
	actor_tiles = {}
	actor_tiles[155] = heart
	actor_tiles[141] = myrtle
	actor_tiles[142] = goal
	actor_tiles[161] = neato
	actor_tiles[139] = key
	actor_tiles[191] = blue
	actor_tiles[154] = gun

	for xx=0,127,1 do
		for yy=1,31,1 do
			tileup = mget(xx,yy-1)
			tilehere = mget(xx,yy)
			actorhere = actor_tiles[tilehere]
			if (actorhere!= nil) then
				mset(xx,yy,tileup)
				if tilehere == 161 then
					cpt = neato:new({x=xx,y=yy,z=15})
					add(alist,cpt)
				else
					local newact = actorhere:new({x=xx,y=yy,z=mz(xx,yy)})
					add(alist,newact)
					if (tilehere==141 or tilehere==191) killmax += 1
				end
			end
		end
	end
	-- return cpt
end


function draw_3d()
	poke(0x5F38, 1) -- horiz loop tline
	poke(0x5F39, 1) -- vert loop tline
	local deptharray = {}

	-- calculate view plane
	local x0,y0,x1,y1 = pl:return_view()

	-- camera based on player pos
	local x=pl.x
	local y=pl.y

	-- (player eye 1.5 units high)
	local z=pl.z-1
	local ystart = viewheight-1
	local ymid = viewcenter
	local tileinfo = tileinfo -- localizing for better access
	local unit = unit -- localizing for better access
	local horizon = horizon -- localizing for better access
	local patterns = patterns -- localizing for better access
	local drawdist = drawdist -- localizing for better access
	local flrx = flr(x)
	local flry = flr(y)

	-- allocate for the loop
		
	-- for sx=0,127,1 do
	for sx=0,127,1 do
		local depthi = {}
	
		-- make all of these local for speed
		local sy = 128--ystart
		local syc = -1 -- ceiling
		local ix=flrx --flr(x)
		local iy=flry --flr(y)
		local tdist=0
		local mcol=mget(ix,iy)
		local col = mcol%16
		local tiletype = tileinfo[mcol\16]
		-- local spr_ix = tiletype[1]
		local g_color =  tiletype[2]
		local celz = 16-col*.5
		local celzc = 7.5 + (1+sgn(col-1))*.5
		
		-- calc cast vector
		local dist_x, dist_y
		-- local last_dir
		local t=sx/127
		
		local vx = x0 * (1-t) + x1 * t
		local vy = y0 * (1-t) + y1 * t
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
				-- last_dir = 0
				dist_y = dist_y - dist_x
				tdist = tdist + dist_x
				dist_x = skip_x
			else
				iy=iy+dir_y
				-- last_dir = 1
				dist_x = dist_x - dist_y
				tdist = tdist + dist_y
				dist_y = skip_y
			end
			-- prev cel properties
			local mcol0=mcol
			
			-- new cel properties
			mcol=mget(ix,iy)
						
			if mcol != mcol0 then
				local celz0=celz
				local celzc0=celzc
				local tiletype = tileinfo[mcol\16]
				local scale = unit/tdist
				local g_color0 = g_color
				g_color =  tiletype[2]
				local col = mcol%16

				celz=16-col*.5 -- inlined for speed
				celzc = 7.5 + (1+sgn(col-1))*.5
				
				if (col==15) skip = false
				if (tdist > drawdist) skip = false --max draw distance
				
				
				-- screen space
				local sy1 = ((celz0-z)*scale)+horizon -- inlined
				local syc1 = ((celzc0-z)*scale)+horizon -- inlined
				syc1 = min(min(sy1,syc1),sy)
				
				if (sy1 < sy) then
					line(sx,sy1,sx,sy-1,g_color0) -- floor drawing
					pset(sx,sy1,0) 
					sy=sy1
				end
				if (syc1 > syc) then
					line(sx,syc1,sx,syc+1,g_color0) -- ceiling drawing
					-- pset(sx,syc1,0) 
					syc=syc1
				end
				
				--lower floor?
				if (celz>celz0) then
					add(depthi,{tdist,sy1})
				end

				-- draw wall if higher
				if (celz < celz0) or (celzc > celzc0) then
					sy1 = ((celz-z)*scale) + horizon
					syc1 = ((celzc-z)*scale) + horizon 
					syc1 = min(min(sy1,syc1),sy)

					poke(0x5F3A, tiletype[3])
					poke(0x5F3B, tiletype[4])

					local wallx
					if dist_x == skip_x then
						wallx = .5*((y + tdist*vy)%2)
						fillp(0b1111111111111111.011)
					else
						wallx = .5*((x + tdist*vx)%2)
					end

					if (sy1 < sy) then						
						tline(sx,sy1,sx,sy-1,wallx,0,0,(.5/scale))
						pset(sx,sy1,0)
						sy=sy1
						add(depthi,{tdist,sy1})
					end
					if (syc1 > syc) then						
						tline(sx,syc+1,sx,syc1-1,wallx,0,0,(.5/scale))
						pset(sx,syc1,0)
						syc=syc1
						-- add(depthi,{tdist,sy1})
					end
					fillp()

				end
			
			elseif tdist < 7 and tdist > 2 and (dist_x < .3 or dist_y < .3) then
				if (tdist > drawdist) skip = false --max draw distance

				-- screen space
				local sy1 = (((16-(mcol%16)*.5)-z)*unit/tdist)+horizon -- inlined
				
				if (sy1 < sy) then
					line(sx,sy1,sx,sy-1,g_color) -- floor drawing
					pset(sx,sy1,2)
					sy=sy1
				end
			end
			if (syc >= sy) skip = false
	
		end -- skipping
		deptharray[sx]=depthi	
	end -- sx
	return deptharray
end

function update_gameplay()
	needkey=false

	-- sector load
	local secnow = cpt.x \ 16
	for ss=max(0,secnow-1),min(secnow+1,#sectors),1 do
		for aa in all(sectors[ss]) do
			aa:load_alist()
		end
	end

	locklistold = locklist
	locklist={}
    for aa in all(alist) do
        if (aa.x\16 < secnow-1) or (aa.x\16 > secnow+1) then
			aa:to_sector()
		else
			aa:update()
		end
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
		sfx(56)
		for i = 127,0,-5 do
			_draw()
			rectfill(0,127,127,i,0)
			flip()
		end
		start_gameover()
	end
	-- if (btnp(4)) flipline = not flipline
end

function get_gpoints()
	local pnum=10
	local ptable={}
	local i = 0
	local xoff = 1
	local yoff = 0
	while i < pnum do

	end
end

function draw_gameplay()
	cls(1)
	scenery = pl.d
	if (scenery > .5) scenery = scenery-1
	circfill(64+64*8*scenery,horizon,36,2)
	circfill(-64+64*8*scenery,horizon,36,6)
	circfill(-192+64*8*scenery,horizon,36,10)
	circfill(192+64*8*scenery,horizon,36,14)
	


	palt(0,false)
	deptharray = draw_3d()
	palt()

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
	printo("keys: "..cpt.keys.." gun: "..guns,2,10,10,0)
	printo(scenery,2,17,10,0)

	if (needkey) printco('you need a key',40,7,0)
        

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
	music(26)
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
		-- start_gameplay()
		run()
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
	music(25)
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

	-- if (btnp(4) or btnp(5)) and titletimer>60  then
	-- 	for i = 127,0,-5 do
	-- 		rectfill(0,127,127,i,0)
	-- 		flip()
	-- 	end
	-- 	start_gameplay()
	-- end
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
	printco('kills: '..kills.."/"..killmax, 60, 14, 0)
	printco("gun ups: "..guns.."/"..gunsmax, 68, 14, 0)


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