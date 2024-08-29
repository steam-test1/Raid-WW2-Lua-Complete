HUDCrosshair = HUDCrosshair or class()
HUDCrosshair.MODE_OFF = 1
HUDCrosshair.MODE_ON = 2
HUDCrosshair.DEFAULT_W = 320
HUDCrosshair.DEFAULT_H = 320
HUDCrosshair.DEFAULT_A = 0.665
HUDCrosshair.DEFAULT_EDGE_PIP_COUNT = 4

-- Lines 15-35
function HUDCrosshair:init(hud)
	self._hud_panel = hud.panel
	self._tweak_data = {}
	self._offset_target = 0
	self._offset = 0
	self._crosshair_fade = false
	self._icons = {}
	self._object = self._hud_panel:panel({
		name = "crosshair_panel",
		w = HUDCrosshair.DEFAULT_W,
		h = HUDCrosshair.DEFAULT_H
	})

	self._object:set_center(self._hud_panel:center())
end

-- Lines 38-84
function HUDCrosshair:set_crosshair_type(type_id)
	Application:debug("[HUDCrosshair:set_crosshair_type]", type_id)

	self._tweak_data = tweak_data.gui.crosshairs[type_id]

	self._object:clear()

	self._icons = {}

	if not not self._tweak_data.edge_pips_icon then
		for i = 1, self._tweak_data.edge_pips or HUDCrosshair.DEFAULT_EDGE_PIP_COUNT do
			local gui = nil

			if type(self._tweak_data.edge_pips_icon) == "table" then
				local pip_i = 1 + i % #self._tweak_data.edge_pips_icon
				gui = tweak_data.gui:get_full_gui_data(self._tweak_data.edge_pips_icon[pip_i])
			else
				gui = tweak_data.gui:get_full_gui_data(self._tweak_data.edge_pips_icon)
			end

			local icon = self._object:bitmap({
				layer = 1,
				texture = gui.texture,
				texture_rect = gui.texture_rect,
				color = gui.color or tweak_data.gui.colors.raid_white,
				alpha = HUDCrosshair.DEFAULT_A
			})

			icon:set_center(self._object:w() / 2, self._object:h() / 2)
			table.insert(self._icons, icon)
		end
	end

	if not not self._tweak_data.core_dot then
		self._core_dot = self._object:bitmap({
			layer = 1,
			texture = tweak_data.gui.icons[self._tweak_data.core_dot].texture,
			texture_rect = tweak_data.gui.icons[self._tweak_data.core_dot].texture_rect,
			color = tweak_data.gui.colors.raid_white,
			alpha = HUDCrosshair.DEFAULT_A
		})

		self._core_dot:set_center(self._object:w() / 2, self._object:h() / 2)
	else
		self._core_dot = nil
	end
end

-- Lines 87-89
function HUDCrosshair:set_crosshair_offset(offset)
	self._offset_target = math.lerp(tweak_data.weapon.crosshair.MIN_OFFSET, tweak_data.weapon.crosshair.MAX_OFFSET, offset)
end

-- Lines 92-98
function HUDCrosshair:set_crosshair_offset_instant(offset)
	self._offset = math.lerp(tweak_data.weapon.crosshair.MIN_KICK_OFFSET, tweak_data.weapon.crosshair.MAX_KICK_OFFSET, offset)

	self:update_crosshair_offset(0, 0)
end

-- Lines 101-108
function HUDCrosshair:set_crosshair_offset_kick(spread_mul)
	self._offset = self._offset + math.lerp(tweak_data.weapon.crosshair.MIN_KICK_OFFSET, tweak_data.weapon.crosshair.MAX_KICK_OFFSET, spread_mul / 100) + 5
	self._offset = math.min(self._offset, tweak_data.weapon.crosshair.MAX_KICK_OFFSET)

	self:update_crosshair_offset(0, 0)
end

-- Lines 111-152
function HUDCrosshair:update_crosshair_offset(t, dt)
	local speed = 7
	self._offset = math.lerp(self._offset, self._offset_target, dt * speed)
	local opacity = math.lerp(tweak_data.weapon.crosshair.MAX_ALPHA, tweak_data.weapon.crosshair.MIN_ALPHA, self._offset / tweak_data.weapon.crosshair.MAX_OFFSET)

	if self._core_dot then
		self._core_dot:set_alpha(opacity)
	end

	if not table.empty(self._icons) then
		local div = self._tweak_data.degree_field / #self._icons
		local start_rotation = div + self._tweak_data.base_rotation
		local radius = self._offset

		for i, icon in ipairs(self._icons) do
			local c_x = self._object:w() / 2
			local c_y = self._object:h() / 2
			local degrees = div * i - start_rotation
			c_x = c_x + radius * math.cos(degrees)
			c_y = c_y + radius * math.sin(degrees)

			icon:set_center(c_x, c_y)
			icon:set_rotation(degrees)
			icon:set_alpha(opacity)
		end
	end
end

-- Lines 156-158
function HUDCrosshair:set_crosshair_visible(visible)
	self._object:set_visible(visible)
end

-- Lines 162-174
function HUDCrosshair:set_crosshair_fade(visible)
	if self._crosshair_fade == visible then
		return
	end

	self._object:stop()

	if visible then
		self._object:animate(callback(self, self, "_animate_alpha"), 0.099, 1)
	else
		self._object:animate(callback(self, self, "_animate_alpha"), 0.099, 0)
	end

	self._crosshair_fade = visible
end

-- Lines 176-184
function HUDCrosshair:_animate_alpha(panel, duration, e)
	local t = 0
	local s = panel:alpha()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt

		panel:set_alpha(math.lerp(s, e, t / duration))
	end
end
