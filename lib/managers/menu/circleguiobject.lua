CircleGuiObject = CircleGuiObject or class()

function CircleGuiObject:init(panel, config)
	self._panel = panel
	self._radius = config.radius or 20
	self._sides = config.sides or 10
	self._total = config.total or 1
	config.triangles = self:_create_triangles(config)
	config.w = self._radius * 2
	config.h = self._radius * 2
	self._circle = self._panel:polygon(config)
end

function CircleGuiObject:_create_triangles(config)
	local amount = 360 * (config.current or 1) / (config.total or 1)
	local s = self._radius
	local triangles = {}
	local step = 360 / self._sides

	for i = step, amount, step do
		local mid = Vector3(self._radius, self._radius, 0)

		table.insert(triangles, mid)
		table.insert(triangles, mid + Vector3(math.sin(i) * self._radius, -math.cos(i) * self._radius, 0))
		table.insert(triangles, mid + Vector3(math.sin(i - step) * self._radius, -math.cos(i - step) * self._radius, 0))
	end

	return triangles
end

function CircleGuiObject:set_current(current)
	local triangles = self:_create_triangles({
		current = current,
		total = self._total
	})

	self._circle:clear()
	self._circle:add_triangles(triangles)
end

function CircleGuiObject:set_position(x, y)
	self._circle:set_position(x, y)
end

function CircleGuiObject:set_layer(layer)
	self._circle:set_layer(layer)
end

function CircleGuiObject:layer()
	return self._circle:layer()
end

function CircleGuiObject:set_rotation(rotation)
	self._circle:set_rotation(rotation)
end

function CircleGuiObject:rotation()
	return self._circle:rotation()
end

function CircleGuiObject:remove()
	self._panel:remove(self._circle)
end

CircleBitmapGuiObject = CircleBitmapGuiObject or class()

function CircleBitmapGuiObject:init(panel, config)
	self._panel = panel
	self._radius = config.radius or 20
	self._sides = config.sides or 64
	self._total = config.total or 1
	self._size = 128
	config.texture_rect = config.texture_rect or nil
	config.texture = config.image or "guis/textures/pd2/hud_progress_active"
	config.w = self._radius * 2
	config.h = self._radius * 2
	self._circle = self._panel:bitmap(config)

	self._circle:set_render_template(Idstring("VertexColorTexturedRadial"))
	self._circle:set_color(self._circle:color())

	if config.use_bg then
		local bg_config = deep_clone(config)
		bg_config.texture_rect = bg_config.bg_texture_rect or nil
		bg_config.texture = config.bg_image or "guis/textures/pd2/hud_progress_bg"
		bg_config.layer = bg_config.layer - 1
		bg_config.blend_mode = "normal"
		bg_config.color = bg_config.bg_color or Color(1, 1, 1)
		bg_config.alpha = bg_config.bg_alpha or 1
		self._bg_circle = self._panel:bitmap(bg_config)
	end
end

function CircleBitmapGuiObject:radius()
	return self._radius
end

function CircleBitmapGuiObject:current()
	return self._circle:position_z()
end

function CircleBitmapGuiObject:set_current(current)
	local j = math.mod(math.floor(current), 8)
	local i = math.floor(current / 8)

	self._circle:set_position_z(current)
end

function CircleBitmapGuiObject:position()
	return self._circle:position()
end

function CircleBitmapGuiObject:bottom()
	return self._circle:bottom()
end

function CircleBitmapGuiObject:right()
	return self._circle:right()
end

function CircleBitmapGuiObject:set_position(x, y)
	self._circle:set_position(x, y)

	if self._bg_circle then
		self._bg_circle:set_position(x, y)
	end
end

function CircleBitmapGuiObject:set_center_x(x)
	self._circle:set_center_x(x)

	if self._bg_circle then
		self._bg_circle:set_center_x(x)
	end
end

function CircleBitmapGuiObject:set_center_y(y)
	self._circle:set_center_y(y)

	if self._bg_circle then
		self._bg_circle:set_center_y(y)
	end
end

function CircleBitmapGuiObject:set_center(x, y)
	self._circle:set_center(x, y)

	if self._bg_circle then
		self._bg_circle:set_center(x, y)
	end
end

function CircleBitmapGuiObject:set_visible(visible)
	self._circle:set_visible(visible)

	if self._bg_circle then
		self._bg_circle:set_visible(visible)
	end
end

function CircleBitmapGuiObject:visible()
	return self._circle:visible()
end

function CircleBitmapGuiObject:set_alpha(alpha)
	self._circle:set_alpha(alpha)
end

function CircleBitmapGuiObject:alpha()
	self._circle:alpha()
end

function CircleBitmapGuiObject:set_color(color)
	self._circle:set_color(color)
end

function CircleBitmapGuiObject:color()
	return self._circle:color()
end

function CircleBitmapGuiObject:set_rotation(rotation)
	self._circle:set_rotation(rotation)
end

function CircleBitmapGuiObject:rotation()
	return self._circle:rotation()
end

function CircleBitmapGuiObject:size()
	return self._circle:size()
end

function CircleBitmapGuiObject:set_w(w)
	self._circle:set_w(w)

	if self._bg_circle then
		self._bg_circle:set_w(w)
	end
end

function CircleBitmapGuiObject:set_h(h)
	self._circle:set_h(h)

	if self._bg_circle then
		self._bg_circle:set_h(h)
	end
end

function CircleBitmapGuiObject:set_size(w, h)
	self._circle:set_size(w, h)

	if self._bg_circle then
		self._bg_circle:set_size(w, h)
	end
end

function CircleBitmapGuiObject:set_image(texture)
	self._circle:set_image(texture)
end

function CircleBitmapGuiObject:set_layer(layer)
	self._circle:set_layer(layer)

	if self._bg_circle then
		self._bg_circle:set_layer(layer - 1)
	end
end

function CircleBitmapGuiObject:layer()
	return self._circle:layer()
end

function CircleBitmapGuiObject:remove()
	self._panel:remove(self._circle)

	if self._bg_circle then
		self._panel:remove(self._bg_circle)
	end

	self._panel = nil
end

function CircleBitmapGuiObject:hide_bg()
	self._bg_circle:set_visible(false)
end

function CircleBitmapGuiObject:show_bg()
	self._bg_circle:set_visible(true)
end
