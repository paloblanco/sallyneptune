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
actor.z0 = actor.zf
actor.dx, actor.dy, actor.dz = 0,0,0
actor.sp=79
actor.spsize=8
actor.vwidth=1
actor.dist_cam = 0
actor.ang_cam = 0
actor.dist=100 -- start big so weird stuff doesnt happen
actor.d=0
actor.timer=0
actor.jetpack=false
actor.killme=false


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

    if btnp(5) then
        make_laser()
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

laser = actor:new()
colors = {8,9,10,11,12,13,6}

function laser:init()
    self.color = colors[1+flr(#colors*rnd())]
    self.x = cpt.x
    self.y = cpt.y
    self.z = cpt.z-.5
    self.x0,self.y0,self.z0=self.x,self.y,self.z
    self.s=.9
    self.d = cpt.d
    self.dx = self.s * cos(self.d)
    self.dy = self.s * sin(self.d)
end

function laser:update()
    if self.killme then
        self:kill_me()
        return
    end
    
    self.x0,self.y0,self.z0=self.x,self.y,self.z
    self.x = self.x + self.dx
    self.y = self.y + self.dy

    if (mz(self.x,self.y) < self.z) self.killme = true

    self.timer = self.timer + 1
    if (self.timer > 60) self.killme = true
end

function laser:draw()
    sx0,sy0,h0 = point2pix(self.x0,self.y0,self.z0,pl)
    sx,sy,h = point2pix(self.x,self.y,self.z,pl)

    if sx and sx0 then
        line(sx0,sy0,sx,sy,self.color)
    end
end

function laser:kill_me()
    -- self:draw()
    make_explosion(self.x,self.y,self.z,self.color)
    del(alist,self)
end

function make_laser()
    local ll = laser:new()
    add(alist,ll)
end

explosion = actor:new()
explosion.color = 8
explosion.timer = 8
explosion.sp = 108
spr_explosion = {108, 109, 110, 111}
explosion.timer = 9

function make_explosion(x,y,z,col)
    local ee = explosion:new({x=x,y=y,z=z,color=col})
    add(alist,ee)
end

function explosion:update()
    self.timer += -1

    local ixspr = 5-max(flr((self.timer/9)*4),1)
    if (self.timer < 0)  then
        self:kill_me()
        return
    end
    self.sp = spr_explosion[ixspr]
end

function explosion:kill_me()
    del(alist,self)
end

function explosion:draw()
    local sx,sy,h = point2pix(self.x,self.y,self.z,pl)
    pal(9,self.color)
    pal(10,self.color)
    if sx then
        sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx-h+1,sy-h+1,h,h)
        sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx,sy-h+1,h,h,true)
        sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx-h+1,sy,h,h,false,true)
        sspr(8*(self.sp%16),8*(self.sp\16),self.spsize,self.spsize,sx,sy,h,h,true,true)
    end
    pal()
end
