actor = thing:new()

actor.x=0
actor.y=0
actor.z=0
actor.sp=48
actor.spsize=8
actor.vwidth=1
actor.dist_cam = 0
actor.ang_cam = 0

function actor:get_cam_params(x,y,z,dir)
    local dx = self.x-x
    local dy = self.y-y
    local dz = self.z-(z-1)
    local ang = atan2(dx,dy)
    local rel_ang = ang-dir -- angle of object off player angle
    if (rel_ang > .5) rel_ang = rel_ang-1
    if (rel_ang < -.5) rel_ang = 1+rel_ang
    self.ang_cam = rel_ang
    local dist = sqrt((dx)^2 + (dy)^2)
    self.dist_cam = dist*cos(rel_ang)/cos(fov/2) -- not sure why you need .1 here but you do
    -- self.dist_cam = dist*cos(rel_ang) -- not sure why you need .1 here but you do
end

function actor:draw_prep(x,y,z,dir) -- needs view plane and player x,y,z,dir
    -- vp = pl:return_view()

    local dz = self.z-(z-1)
    local rel_ang = self.ang_cam
    if (abs(rel_ang) > fov/2) return -- escape function if not in fov
    local dist = self.dist_cam
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
    sspr(self.sp%16,8*(self.sp\16),self.spsize,self.spsize,sx0,sy0,hw,hw)
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
    sspr(self.sp%16,8*(self.sp\16),self.spsize,self.spsize,sx0,sy0,hw,hw)
    fillp()

end

function actor:draw_best(x,y,z,dir)
    -- draw sprite slice by slice according to geometry
    -- slowest option
    pblock=true
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
            local spx = self.sp%16 + self.spsize*(sxx-sx0)/hw
            local spy = 8*(self.sp\16)
            local pxx = self.spsize*resolution/hw
            pxx = max(pxx,1)
            sspr(spx,spy,pxx,pyy,sxx,sy0,resolution,syblock-sy0)        
        elseif pblock then
            print(syblock)
            pblock=false
        end
    end
    fillp()
end