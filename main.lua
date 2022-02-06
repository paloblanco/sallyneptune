

function _init()
	-- create player
	pl = player:new()
    alist = {}
    -- add(alist,pl)
	-- map
	for y=0,31 do
		for x=0,31 do
			mset(x,y,mget(x,y)*3)
		end
	end
	orb = actor:new({x=12,y=12,z=16})
	add(alist,orb)
	orb2 = actor:new({x=10,y=11,z=16})
	add(alist,orb2)
end


function _update()
	
	pl:update()
    for aa in all(alist) do
        aa:update()
    end

end

function draw_3d()
	local celz0
	local col
	
	-- calculate view plane
	
	local v = pl:return_view()
	-- camera based on player pos
	local x=pl.x
	local y=pl.y
	-- (player eye 1.5 units high)
	local z=pl.z-1.5
		
	for sx=0,127,2 do
	
		-- make all of these local
		-- for speed
		local sy=127
	
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
				
				rectfill(sx,sy1-1,sx+1,sy,
					sget((celz0*2)%16,8))
				line(sx,sy,sx+1,sy,5)
				if (wall_prev) then
					line(sx,sy,sx+1,sy,0)
					wall_prev=false
				end	
				if lower_elevation then
					line(sx,sy,sx+1,sy,0)
					lower_elevation=false
				end
				sy=sy1
			end
			-- flip()


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
					--line(sx,sy1-1,sx+1,sy1-1,0)
					 sy=sy1
					
					fillp()
					wall_prev=true
				end
				-- flip()
			end
			--lower floor?
			if (celz>celz0) then
				lower_elevation=true
				lowcount = lowcount +1
			end
			
		end   
		end -- skipping
	end -- sx
end


function _draw()
	cls()
	-- to do: sky? stars?
	rectfill(0,0,127,127,12)
	draw_3d()
	
	-- sort sprites
	for aa in all(alist) do
		aa:get_cam_params(pl.x,pl.y,pl.z,pl.d)
	end
	-- SORT HERE
	sort(alist)
	-- draw sprites
	for aa in all(alist) do
		aa:draw_simple(pl.x,pl.y,pl.z,pl.d)
	end

	cursor(0,0) color(7)
	print("cpu:"..flr(stat(1)*100).."%",1,1)
	print("pl :"..pl.d)
	print("orb:"..orb.x.." "..orb.y.." "..orb.z)
	print("lowcount: "..lowcount)

end
