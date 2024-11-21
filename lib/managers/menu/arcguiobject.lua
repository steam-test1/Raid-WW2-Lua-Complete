ArcGuiObject = ArcGuiObject or class()

function ArcGuiObject:init(panel, config)
	self._panel = panel
	self._radius_inner = config.radius_inner or 10
	self._radius_outer = config.radius_outer or 20
	self._sides = config.sides or 10
	self._total = config.total or 1
	config.triangles = self:_create_triangles(config)
	config.w = self._radius_outer * 2
	config.h = self._radius_outer * 2
	self._circle = self._panel:polygon(config)
end

function ArcGuiObject:_create_triangles(config)
	local amount = 360 * (config.current or 1) / (config.total or 1)
	local s = self._radius_outer
	local triangles = {}
	local step = 360 / self._sides

	for i = step, amount, step do
		local mid = Vector3(self._radius_outer, self._radius_outer, 0)

		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius_inner, -math.cos(i - step) * self._radius_inner, 0))
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius_outer, -math.cos(i) * self._radius_outer, 0))
		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius_outer, -math.cos(i - step) * self._radius_outer, 0))
		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius_inner, -math.cos(i - step) * self._radius_inner, 0))
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius_inner, -math.cos(i) * self._radius_inner, 0))
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius_outer, -math.cos(i) * self._radius_outer, 0))
	end

	return triangles
end

function ArcGuiObject:set_current(current)
	local triangles = self:_create_triangles({
		current = current,
		total = self._total
	})

	self._circle:clear()
	self._circle:add_triangles(triangles)
end

function ArcGuiObject:set_position(x, y)
	self._circle:set_position(x, y)
end

function ArcGuiObject:set_layer(layer)
	self._circle:set_layer(layer)
end

function ArcGuiObject:layer()
	return self._circle:layer()
end

function ArcGuiObject:remove()
	self._panel:remove(self._circle)
end
