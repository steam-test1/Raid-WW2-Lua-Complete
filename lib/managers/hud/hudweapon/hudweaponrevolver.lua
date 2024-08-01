HUDWeaponRevolver = HUDWeaponRevolver or class(HUDWeaponGeneric)
HUDWeaponRevolver.CLIP_ICON = "weapon_panel_indicator_"

-- Lines 5-15
function HUDWeaponRevolver:init(index, weapons_panel, tweak_data)
	self._icon_cylinder = tweak_data.hud.icon_cylinder or "revolver_cyl6"
	self._icon_bullet = tweak_data.hud.icon_bullet or "revolver_bullet"
	self._feed_clockwise = tweak_data.hud.feed_clockwise or true
	self._load_clockwise = tweak_data.hud.load_clockwise or false
	self._offset_from_center = tweak_data.hud.offset_from_center or 9
	self._feed_speed = tweak_data.fire_mode_data.fire_rate or 0.13
	self._initial_rotation = tweak_data.hud.initial_rotation or 0

	HUDWeaponRevolver.super.init(self, index, weapons_panel, tweak_data)
end

-- Lines 17-63
function HUDWeaponRevolver:_create_clip_left_info(weapons_panel)
	local padding = 8
	local gui_cylinder = tweak_data.gui.icons[HUDWeaponRevolver.CLIP_ICON .. self._icon_cylinder]
	local gui_bullet = tweak_data.gui.icons[HUDWeaponRevolver.CLIP_ICON .. self._icon_bullet]
	local single_bullet_angle = 360 / self._max_clip
	local half_bullet_angle = single_bullet_angle / 2

	self._ammo_panel:set_w(self._ammo_left_text:w() + padding + gui_cylinder.texture_rect[3])
	self._ammo_panel:set_center_x(self._object:w() / 2)

	local ring_w = self._ammo_panel:h()
	local ring_h = self._ammo_panel:h()

	self:_create_rotation_panel(ring_w, ring_h)

	self._cylinder = self._rotation_panel:bitmap({
		name = "clip_left_background",
		texture = gui_cylinder.texture,
		texture_rect = gui_cylinder.texture_rect,
		w = ring_w,
		h = ring_h,
		rotation = self._initial_rotation
	})
	local layer = self._cylinder:layer() + 1
	self._bullet_list = {}
	self._cocked_bullet_index = 1

	for i = 1, self._max_clip do
		local dx, dy = self:_orbit_math(self._offset_from_center, single_bullet_angle * i + self._initial_rotation + single_bullet_angle / 2)
		local bullet = self._rotation_panel:bitmap({
			h = 8,
			w = 8,
			name = "bullet" .. i,
			texture = gui_bullet.texture,
			texture_rect = gui_bullet.texture_rect,
			layer = layer
		})

		bullet:set_center_x(ring_w / 2 + dx)
		bullet:set_center_y(ring_h / 2 + dy)
		table.insert(self._bullet_list, bullet)
	end
end

-- Lines 66-74
function HUDWeaponRevolver:_create_rotation_panel(w, h)
	self._rotation_panel = self._ammo_panel:panel({
		name = "rotation_panel",
		halign = "center",
		valign = "center",
		w = w,
		h = h
	})
end

-- Lines 76-80
function HUDWeaponRevolver:_orbit_math(offset, angle)
	local dx = offset * math.cos(angle)
	local dy = offset * math.sin(angle)

	return dx, dy
end

-- Lines 83-153
function HUDWeaponRevolver:set_current_clip(current_clip)
	local difference = current_clip - (self._previous_clip or 0)

	if difference == 0 then
		return
	end

	local adding_bullet = difference > 0
	local is_clockwise = nil

	if adding_bullet then
		is_clockwise = self._load_clockwise
	else
		is_clockwise = self._feed_clockwise
	end

	local reset = false

	if current_clip ~= self._max_clip then
		self._rotation_panel:stop()
		self._rotation_panel:animate(callback(self, self, "_animate_rotation_panel_items", is_clockwise))
	else
		self._cylinder:set_rotation(self._initial_rotation)

		reset = true
	end

	local clip_percentage = self._max_clip > 0 and current_clip / self._max_clip or 0

	self._cylinder:set_color(self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, clip_percentage))

	for i, bullet in ipairs(self._bullet_list) do
		i = is_clockwise and i or -i + self._max_clip + 1

		if reset then
			local single_bullet_angle = 360 / self._max_clip
			local ring_w = self._rotation_panel:h()
			local ring_h = self._rotation_panel:h()
			local dx, dy = self:_orbit_math(self._offset_from_center, single_bullet_angle * (i + 1) + self._initial_rotation + single_bullet_angle / 2 + 180)

			bullet:set_center_x(ring_w / 2 + dx)
			bullet:set_center_y(ring_h / 2 + dy)
		end

		local spent = current_clip < i
		local color = spent and self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_SPENT_COLORS, clip_percentage) or self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, clip_percentage)

		bullet:set_color(color)
	end

	self._previous_clip = current_clip
end

-- Lines 155-196
function HUDWeaponRevolver:_animate_rotation_panel_items(clockwise)
	local single_bullet_angle = 360 / self._max_clip
	local degrees = clockwise and single_bullet_angle or -single_bullet_angle
	local from = self._cylinder:rotation()
	local to = from + degrees
	local duration = self._feed_speed
	local i_offs = clockwise and 1.5 or 0.5
	local ring_w = self._rotation_panel:h()
	local ring_h = self._rotation_panel:h()
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local ratio = t / duration

		self._cylinder:set_rotation(math.lerp(from, to, ratio))

		for i, bullet in ipairs(self._bullet_list) do
			local dx, dy = self:_orbit_math(self._offset_from_center, single_bullet_angle * (i + i_offs) + math.lerp(from, to, ratio) + 180)

			bullet:set_center_x(ring_w / 2 + dx)
			bullet:set_center_y(ring_h / 2 + dy)
		end
	end

	for i, bullet in ipairs(self._bullet_list) do
		local dx = self._offset_from_center * math.cos(single_bullet_angle * (i + i_offs) + to + 180)
		local dy = self._offset_from_center * math.sin(single_bullet_angle * (i + i_offs) + to + 180)

		bullet:set_center_x(ring_w / 2 + dx)
		bullet:set_center_y(ring_h / 2 + dy)
	end

	self._cylinder:set_rotation(to)
end

-- Lines 198-251
function HUDWeaponRevolver:_animate_alpha(root_panel, new_alpha)
	local cowboy = math.random(100) <= 1 and new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED
	local start_alpha = new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponBase.ALPHA_WHEN_UNSELECTED or HUDWeaponBase.ALPHA_WHEN_SELECTED
	local start_ammo_left_alpha = start_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED or HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED
	local new_ammo_left_alpha = start_ammo_left_alpha == HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED and HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED or HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED
	local duration = cowboy and 0.45 or 0.2
	local t = (self._icon:alpha() - start_alpha) / (new_alpha - start_alpha) * duration
	local cx, cy = self._icon_panel:center()

	self._icon:set_center_x(cx)
	self._icon:set_center_y(cy)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, start_alpha, new_alpha - start_alpha, duration)

		self._icon:set_alpha(current_alpha)

		if cowboy then
			local aaa = t / duration
			local dx, dy = self:_orbit_math(16, math.lerp(0, 360, aaa))

			self._icon:set_center_x(cx + dx + 8)
			self._icon:set_center_y(cy + dy)
			self._icon:set_rotation(math.lerp(0, -720, aaa))
		end

		self._firemode_single:set_alpha(current_alpha)
		self._firemode_auto:set_alpha(current_alpha)

		local ammo_left_alpha = Easing.quartic_in_out(t, start_ammo_left_alpha, new_ammo_left_alpha - start_ammo_left_alpha, duration)

		self._ammo_left_text:set_alpha(ammo_left_alpha)
		self._cylinder:set_alpha(ammo_left_alpha)

		for _, bullet in ipairs(self._bullet_list) do
			bullet:set_alpha(ammo_left_alpha)
		end
	end

	self._icon:set_rotation(0)
	self._icon:set_alpha(new_alpha)
	self._icon:set_center(cx, cy)
	self._firemode_single:set_alpha(new_alpha)
	self._firemode_auto:set_alpha(new_alpha)
	self._ammo_left_text:set_alpha(new_ammo_left_alpha)
	self._cylinder:set_alpha(new_ammo_left_alpha)

	for _, bullet in ipairs(self._bullet_list) do
		bullet:set_alpha(new_ammo_left_alpha)
	end
end
