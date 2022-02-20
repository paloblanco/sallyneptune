-- player object

player = thing:new()
player.x = 6 player.y = 4
player.dx = 0 player.dy = 0
player.z = 12
player.d = 0.25
player.dz = 0
player.jetpack=false
player.camd = 2

function player:update(target)
	self.x = target.x
	self.y = target.y
	self.z = target.z - 1
	self.d = target.d

	local xoff = -cos(self.d)*self.camd
	local yoff = -sin(self.d)*self.camd

	self.x = self.x + xoff
	self.y = self.y + yoff
end

function player:return_view()
    local v={}
	v.x0 = cos(self.d+fov/2) 
	v.y0 = sin(self.d+fov/2)
	v.x1 = cos(self.d-fov/2)
	v.y1 = sin(self.d-fov/2)
    return v
end