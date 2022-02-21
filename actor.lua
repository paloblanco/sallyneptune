actor = thing:new()

actor.x=0
actor.y=0
actor.z=0
actor.sx=0
actor.sy=0
actor.hw=0
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
actor.my_ang = 0
actor.dist=100 -- start big so weird stuff doesnt happen
actor.d=0
actor.timer=0
actor.jetpack=false
actor.killme=false
actor.ground=true
actor.health=5
actor.maxhealth=5
actor.hurt=false
actor.mainc=1
actor.offtime=0
actor.offx=0
actor.offy=0
actor.tz=0 -- floor height under character, for shadow
actor.shadow=false

function actor:check_lock()
    if abs(self.ang_cam) <= .02 and self.dist > 2 then
        add(locklist,self)
    else
        del(locklist,self)
    end
end

function actor:bump_me(other)
end

function actor:process_offtime()
    if self.offtime > 0 then
        if self.offtime%2==1 then
            self.offx = 4*flr(rnd(3))-1
            self.offy = 4*flr(rnd(3))-1
            self.hurt= not self.hurt
        end
        self.offtime += -1
    else
        self.offx=0
        self.offy=0
        self.hurt=false 
    end
end

function actor:kill_me()
    del(alist,self)
    del(locklist,self)
    self.killme=true
end

function actor:hurt_me()
    self.health += -1
    self.offtime = 8
    if self.health <= 0 then
        self:kill_me()
    end
end

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
    self.my_ang = ang
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
    if (sy>148 or sy < 1) return
    --circfill(sx,sy,unit/dist,11)
    local hw = self.vwidth*unit/dist
    local sx0 = sx-.5*hw
    local sy0 = sy-hw
    self.sx=sx
    self.sy=sy-.5*hw
    self.hw=hw
    return dist, sx0+self.offx, sy0+self.offy, hw
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
    if (self.hurt) pal(self.mainc,7)
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
    pal()
end

function actor:draw()
    self:draw_best(pl.x,pl.y,pl.z,pl.d)
end

neato = actor:new()
neato.sp = 96
neato.spsize = 16
neato.timer=0
neato.mylock = nil
neato.target = nil
neato.shottimemax = 10
neato.shottime = 0
neato.maxhealth=100
neato.health=100
neato.shadow=true
neato.keys=0
neato.mainc=10

neatosp0=96
neatosp={98,100,102,104}

function neato:draw()
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

    self:draw_best(pl.x,pl.y,pl.z,pl.d)
    pal()
end

function neato:hurt_me(damage)
    self.health += -damage
    self.offtime = 8
end

function neato:update()
    local dx=0
	local dy=0
    self.target = nil

	if (btn(❎)) then
        if mylock and not self.mylock then
            self.mylock = mylock
        end
        if self.mylock then
            if self.mylock.killme then
                self.mylock=nil
            else
                self.d = self.mylock.my_ang
                self.target = self.mylock
            end
        end

		-- strafe
		if (btn(⬅️)) dx-=1
		if (btn(➡️)) dx+=1

        -- shoot
        if self.shottime <= 0 then
            make_laser()
            self.shottime = self.shottimemax
        end
	else
		-- turn
		if (btn(⬅️)) self.d+=0.02
		if (btn(➡️)) self.d-=0.02
        self.mylock = nil
	end

    -- if btnp(5) then
        
    -- end

    self.d = self.d%1
	
	-- forwards / backwards
	if (btn(⬆️)) dy+= 1
	if (btn(⬇️)) dy-= 1
	
	spd = sqrt(dx*dx+dy*dy)
	if (spd) then
	
		-- spd = 0.1 / spd
        spd = 0.075 / spd
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
    self.tz=mz(self.x,self.y)
	if (self.z >= self.tz and self.dz >=0) then
		self.z = self.tz
		self.dz = 0
        self.ground = true
	else
		self.dz=self.dz+0.022
		self.z =self.z + self.dz
	end

	-- jetpack / jump when standing
	if (btn(4)) then 
		if (self.jetpack or 
					 mz(self.x,self.y) < self.z+0.1)
		then
			self.dz=-0.2
		end
	end
    self.shottime += -1

    self:process_offtime()
    self:check_collisions()
end

function actor:check_collisions()
    local i = #alist
    if (i==0) return
    while i>0 do
        local act = alist[i]
        if (act.dist > 3) return
        if abs(self.x-act.x)<.5 and abs(self.y-act.y)<.5 and abs(self.z-act.z)<.5 then
            act:bump_me(self)
        end
        i += -1
    end
end

laser = actor:new()
laser.targs={}

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
    if cpt.mylock then
        self.dz = ((cpt.mylock.z-.5) - self.z)/cpt.mylock.dist
    else
        self.dz=0    
    end
    for i in all(locklistold) do
        add(self.targs,i)
    end
end

function laser:update()
    if self.killme then
        self:kill_me()
        return
    end
    
    self.x0,self.y0,self.z0=self.x,self.y,self.z
    self.x = self.x + self.dx
    self.y = self.y + self.dy
    self.z = self.z + self.dz

    if (mz(self.x,self.y) < self.z) self.killme = true

    self.timer = self.timer + 1
    if (self.timer > 60) self.killme = true

    local i = #self.targs
    while i>0 do
        newtarg = self.targs[i]
        if abs(self.x+self.dx-newtarg.x) < .5 then
            if abs(self.y+self.dy-newtarg.y) < .5 then
                self.killme=true
                newtarg:hurt_me()
            end
        end
        i += -1
    end
end

function laser:draw()
    sx0,sy0,h0 = point2pix(self.x0,self.y0,self.z0,pl)
    sx,sy,h = point2pix(self.x,self.y,self.z,pl)

    if sx and sx0 then
        circfill(sx,sy,1+(h/5),7)
        line(sx0,sy0,sx,sy,self.color)
        
        circfill(sx,sy,h/5,self.color)
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
explosion.timer = 8

function make_explosion(x,y,z,col)
    local ee = explosion:new({x=x,y=y,z=z,color=col})
    add(alist,ee)
end

function explosion:update()
    self.timer += -1

    local ixspr = 5-max(flr((self.timer/8)*4),1)
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

myrtle = actor:new()
myrtle.sp=77
myrtle.speed = 0.075
myrtle.ground = true
myrtle.timer = 0
myrtle.health = 5
myrtle.maxhealth = 5
myrtle.mainc=8

function myrtle:update()
    local cptdist = sqrt((self.x-cpt.x)^2 + (self.y-cpt.y)^2)
    local dx = -self.speed*(self.x-cpt.x)/cptdist
    local dy = -self.speed*(self.y-cpt.y)/cptdist
    
    local q = self.z - 0.6
	if (mz(self.x+dx,self.y) > q)
	then self.x += dx end
	if (mz(self.x,self.y + dy) > q)
	then self.y += dy end

    -- z means player feet
	if (self.z >= mz(self.x,self.y) and self.dz >=0) then
		self.z = mz(self.x,self.y)
		self.dz = 0
        self.ground = true
	else
		self.dz=self.dz+0.01
		self.z =self.z + self.dz
        self.ground = false
	end

	-- jetpack / jump when standing
	if self.ground then 
        self.dz=-0.05
		self.ground = false
	end

    --lock on me
    self:check_lock()

    self:process_offtime()
end

function myrtle:draw()
    pal(self.mainc,6)
    self:draw_best(pl.x,pl.y,pl.z,pl.d)
    pal()
    local len = 10*self.health/self.maxhealth
    if len < 10 then
        rectfill(self.sx-6,self.sy-self.hw-1,self.sx+6,self.sy-self.hw+1,0)
        rectfill(self.sx-5,self.sy-self.hw,self.sx-5+len,self.sy-self.hw,8)
    end
end

function myrtle:bump_me(other)
    if (other.offtime <= 0) other:hurt_me(5)
end

goal = actor:new()
goal.sp = 14
goal.spsize = 16

function goal:bump_me(other)
    for i = 127,0,-5 do
        _draw()
        rectfill(0,127,127,i,14)
        flip()
    end
    start_gamewin()
end

function goal:update()
    -- z means player feet
	if (self.z >= mz(self.x,self.y) and self.dz >=0) then
		self.z = mz(self.x,self.y)
		self.dz = 0
        self.ground = true
	else
		self.dz=self.dz+0.01
		self.z =self.z + self.dz
        self.ground = false
	end

	-- jetpack / jump when standing
	if self.ground then 
        self.dz=-0.05
		self.ground = false
	end
end

heart = actor:new()
heart.sp=91

function heart:bump_me(other)
    other.health += 20
    other.health = min(100,other.health)
    self:kill_me()
end

function heart:update()
    -- z means player feet
	if (self.z >= mz(self.x,self.y) and self.dz >=0) then
		self.z = mz(self.x,self.y)
		self.dz = 0
        self.ground = true
	else
		self.dz=self.dz+0.01
		self.z =self.z + self.dz
        self.ground = false
	end

	-- jetpack / jump when standing
	if self.ground then 
        self.dz=-0.05
		self.ground = false
	end
end