-- player object

player = thing:new()
player.x = 6 player.y = 4
player.dx = 0 player.dy = 0
player.z = 12
player.d = 0.25
player.dz = 0
player.jetpack=false

function player:update()
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

function player:return_view()
    local v={}
	v.x0 = cos(self.d+fov/2) 
	v.y0 = sin(self.d+fov/2)
	v.x1 = cos(self.d-fov/2)
	v.y1 = sin(self.d-fov/2)
    return v
end