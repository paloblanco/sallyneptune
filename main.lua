function _init()
	-- setup stuff
	setup_asciitables()

	-- create player
	pl = player:new()
    alist = {}

	orb = actor:new({x=6,y=6,z=16})
	add(alist,orb)
	orb2 = actor:new({x=7,y=6,z=16})
	add(alist,orb2)

	cpt = neato:new({x=6,y=4,z=12})
	add(alist,cpt)
	pl:update(cpt)
end


function _update()
	
	
    for aa in all(alist) do
        aa:update()
    end
	pl:update(cpt)

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
		local celz=16-col*1
		
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

			celz=16-col*1 -- inlined for speed
			
			
			if (col==15) then skip=false end
			
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


function _draw()
	-- cls()
	-- to do: sky? stars?
	rectfill(0,0,127,viewheight-1,13)
	deptharray = draw_3d()
	
	-- sort sprites
	for aa in all(alist) do
		aa:get_cam_params(pl.x,pl.y,pl.z,pl.d)
	end
	-- SORT HERE
	sort(alist)
	-- draw sprites
	for aa in all(alist) do
		-- aa:draw_simple(pl.x,pl.y,pl.z,pl.d)
		-- aa:draw_dumb(pl.x,pl.y,pl.z,pl.d)
		-- aa:draw_best(pl.x,pl.y,pl.z,pl.d)
		aa:draw()
	end

	cursor(0,0) color(0)
	print("cpu:"..flr(stat(1)*100).."%",1,1)
	-- print("pl :"..pl.d)
	-- print("pl:"..pl.x.." "..pl.y.." "..pl.z)
	
	print("alist: "..#alist)
	print("cptz: "..cpt.z)

end
