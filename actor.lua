actor = thing:new()

actor.x=0
actor.y=0
actor.z=0
actor.sp=48
actor.vwidth=8

function actor:draw_simple(x,y,z,dir) -- needs view plane and player x,y,z,dir
    local dx = self.x-x
    local dy = self.y-y
    local dz = self.z-(z-1.5)
    local ang = atan2(dx,dy)
    local rel_ang = ang-dir -- angle of object off player angle
    if (abs(rel_ang) > fov/2) return -- escape function if not in fov
    local dist = sqrt((dx)^2 + (dy)^2)
    local sx = (-rel_ang*2/fov)*64+64
    local sy = (dz*64/dist)+64
    circfill(sx,sy,unit/dist,11)
end