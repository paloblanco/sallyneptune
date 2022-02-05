actor = thing:new()

actor.x=0
actor.y=0
actor.z=0
actor.sp=48
actor.vwidth=1
actor.dist_cam = 0
actor.ang_cam = 0

function actor:get_cam_params(x,y,z,dir)
    local dx = self.x-x
    local dy = self.y-y
    local dz = self.z-(z-1.5)
    local ang = atan2(dx,dy)
    local rel_ang = ang-dir -- angle of object off player angle
    if (rel_ang > .5) rel_ang = rel_ang-1
    if (rel_ang < -.5) rel_ang = 1+rel_ang
    self.ang_cam = rel_ang
    local dist = sqrt((dx)^2 + (dy)^2)
    self.dist_cam = dist*cos(rel_ang)/cos(.1) -- not sure why you need .1 here but you do
end

function actor:draw_simple(x,y,z,dir) -- needs view plane and player x,y,z,dir
    local dz = self.z-(z-1.5)
    local rel_ang = self.ang_cam
    if (abs(rel_ang) > fov/2) return -- escape function if not in fov
    local dist = self.dist_cam
    local sx = (-rel_ang*2/fov)*64+64
    local sy = (dz*64/dist)+64
    --circfill(sx,sy,unit/dist,11)
    local hw = self.vwidth*unit/dist
    sspr(self.sp%16,8*(self.sp\16),8,8,sx-.5*hw,sy-hw,hw,hw)
end