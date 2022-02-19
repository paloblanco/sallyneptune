actor = thing:new()

actor.x=0
actor.y=0
actor.z=0
actor.loc = flr(256*actor.y) + flr(actor.x)
actor.loc0= actor.loc
actor.xf = flr(actor.x)
actor.yf = flr(actor.y)
actor.x0 = actor.xf
actor.y0 = actor.yf
actor.dx, actor.dy, actor.dz = 0,0,0
actor.sp=79
actor.spsize=8
actor.vwidth=1
actor.dist_cam = 0
actor.ang_cam = 0
actor.dist=100 -- start big so weird stuff doesnt happen
actor.d=0
actor.jetpack=false


function actor:move()
    local q = self.z - 0.6
	if (mz(self.x+self.dx,self.y) > q)
	then self.x += self.dx end
	if (mz(self.x,self.y+self.dy) > q)
	then self.y += self.dy end
end


function actor:get_cam_params(x,y,z,dir)
    local dx = self.x-x
    local dy = self.y-y
    local dz = self.z-(z-1)
    local ang = atan2(dx,dy)
    local rel_ang = ang-dir -- angle of object off player angle
    if (rel_ang > .5) rel_ang = rel_ang-1
    if (rel_ang < -.5) rel_ang = 1+rel_ang
    self.ang_cam = rel_ang
    self.dist = sqrt((dx)^2 + (dy)^2)
    
    -- self.dist_cam = dist*cos(rel_ang) -- not sure why you need .1 here but you do
end

function actor:draw_prep(x,y,z,dir) -- needs view plane and player x,y,z,dir
    -- vp = pl:return_view()

    local dz = self.z-(z-1)
    local rel_ang = self.ang_cam
    if (abs(rel_ang) > fov/2) return -- escape function if not in fov
    local dist = self.dist*cos(rel_ang)/cos(fov/2) -- not sure why you need .1 here but you do
    local fix_ang = (shortestdist*tan(rel_ang))/planelength
    -- local sx = (-rel_ang*2/fov)*64+64
    local sx = (fix_ang)*128+64
    -- local sy = (dz*viewcenter/dist)+horizon
    local sy = (dz*unit/dist)+horizon
    if (sy>127 or sy < 1) return
    --circfill(sx,sy,unit/dist,11)
    local hw = self.vwidth*unit/dist
    local sx0 = sx-.5*hw
    local sy0 = sy-hw
    return dist, sx0, sy0, hw
end

function actor:draw_simple(x,y,z,dir)
    -- actor is drawn regardless of blocking geometry
    -- fast!
    dist, sx0, sy0, hw = self:draw_prep(x,y,z,dir)
    if (dist == nil) return
    fillp(patterns[min(flr(dist/3),8)])
    sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx0,sy0,hw,hw)
    fillp()
end

function actor:draw_dumb(x,y,z,dir)
    -- only check left and right edges for blocking.
    -- draw completely if not blocked
    -- dont draw at all if any blocking detected
    -- medium speed
    dist, sx0, sy0, hw = self:draw_prep(x,y,z,dir)
    if (dist == nil) return
    local sy1 = sy0+hw
    --checkleft
    slice = deptharray[sx0+1 - (sx0+1)%resolution]
    if slice != nil then
        for i=#slice,1,-1 do
            ss=slice[i]
            if dist>ss[1] then
                if (sy1-1 > ss[2]) return -- escape drawing
            end
        end
    end
    --checkright
    slice = deptharray[sx0-1 + hw - (sx0-1 + hw)%resolution]
    if slice != nil then
        for i=#slice,1,-1 do
            ss=slice[i]
            if dist>ss[1] then
                if (sy1-1 > ss[2]) return -- escape drawing
            end
        end
    end
    fillp(patterns[min(flr(dist/3),8)])
    sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx0,sy0,hw,hw)
    fillp()

end

function actor:draw_best(x,y,z,dir)
    -- draw sprite slice by slice according to geometry
    -- slowest option
    dist, sx0, sy0, hw = self:draw_prep(x,y,z,dir)
    if (dist == nil) return
    local sy1 = sy0+hw
    fillp(patterns[min(flr(dist/3),8)])
    --start checking
    for sxx=sx0,sx0+hw,resolution do
        local syblock=sy1
        local slice = deptharray[sxx - (sxx)%resolution]
        if slice != nil then
            local i = #slice
            while i >=1 do
                if dist > slice[i][1] then
                    syblock = min(syblock,slice[i][2])
                end
                i = i-1
            end
        end
        if syblock > sy0 then
            local pyy = self.spsize*(syblock-sy0)/hw
            local spx = 8*(self.sp%16) + self.spsize*(sxx-sx0)/hw
            local spy = 8*(self.sp\16)
            local pxx = self.spsize*resolution/hw
            pxx = max(pxx,1)
            sspr(spx,spy,pxx,pyy,sxx,sy0,resolution,syblock-sy0)        
        end
    end
    fillp()
end

function actor:draw()
    self:draw_best(pl.x,pl.y,pl.z,pl.d)
end

neato = actor:new()
neato.sp = 96
neato.spsize = 16
neato.timer=0

neatosp0=96
neatosp={98,100,102,104}

function neato:draw()
    self:draw_best(pl.x,pl.y,pl.z,pl.d)
end

function neato:update()
    local dx=0
	local dy=0

	if (btn(❎)) then
		-- strafe
		if (btn(⬅️)) dx-=1
		if (btn(➡️)) dx+=1
	else
		-- turn
		if (btn(⬅️)) self.d+=0.02
		if (btn(➡️)) self.d-=0.02
	end
    self.d = self.d%1
	
	-- forwards / backwards
	if (btn(⬆️)) dy+= 1
	if (btn(⬇️)) dy-= 1
	
	spd = sqrt(dx*dx+dy*dy)
	if (spd) then
	
		spd = 0.1 / spd
		dx *= spd
		dy *= spd
		
		self.dx += cos(self.d-0.25) * dx
		self.dy += sin(self.d-0.25) * dx
		self.dx += cos(self.d+0.00) * dy
		self.dy += sin(self.d+0.00) * dy
	
    end

    if dx!=0 or dy!=0 then
        self.timer = self.timer+1
    else
        self.timer=0
    end

    if self.timer==0 then
        self.sp = neatosp0
    else
        self.sp = neatosp[1+(self.timer\3)%4]
    end
	
	local q = self.z - 0.6
	if (mz(self.x+self.dx,self.y) > q)
	then self.x += self.dx end
	if (mz(self.x,self.y+self.dy) > q)
	then self.y += self.dy end
	
	-- friction
	self.dx *= 0.6
	self.dy *= 0.6
	
	-- z means player feet
	if (self.z >= mz(self.x,self.y) and self.dz >=0) then
		self.z = mz(self.x,self.y)
		self.dz = 0
	else
		self.dz=self.dz+0.01
		self.z =self.z + self.dz
	end

	-- jetpack / jump when standing
	if (btn(4)) then 
		if (self.jetpack or 
					 mz(self.x,self.y) < self.z+0.1)
		then
			self.dz=-0.15
		end
	end
end