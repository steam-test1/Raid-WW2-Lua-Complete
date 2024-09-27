HUDWeaponClipShots = HUDWeaponClipShots or class(HUDWeaponGeneric)
HUDWeaponClipShots.CLIP_ICON = "weapon_panel_indicator_"

function HUDWeaponClipShots:init(index, weapons_panel, _tweak_data)
	self._icon_spent = _tweak_data.hud.panel_clip_icon_spent or "9mm_spent"
	self._icon_spent_thin = _tweak_data.hud.panel_clip_icon_spent_thin or "9mm_spent_thin"
	self._icon_loaded = _tweak_data.hud.panel_clip_icon_loaded or "9mm_loaded"
	self._icon_loaded_thin = _tweak_data.hud.panel_clip_icon_loaded_thin or "9mm_spent_thin"
	self._icon_stack_min = _tweak_data.hud.panel_clip_icon_stack_min or 10
	self._icon_thin_min = _tweak_data.hud.panel_clip_icon_thin_min or 20
	self._guis = {
		{
			tweak_data.gui.icons[HUDWeaponClipShots.CLIP_ICON .. self._icon_loaded_thin],
			tweak_data.gui.icons[HUDWeaponClipShots.CLIP_ICON .. self._icon_spent_thin]
		},
		{
			tweak_data.gui.icons[HUDWeaponClipShots.CLIP_ICON .. self._icon_loaded],
			tweak_data.gui.icons[HUDWeaponClipShots.CLIP_ICON .. self._icon_spent]
		}
	}

	HUDWeaponClipShots.super.init(self, index, weapons_panel, _tweak_data)
end

function HUDWeaponClipShots:_create_clip_left_info(weapons_panel)
end

function HUDWeaponClipShots:set_current_clip(current_clip)
	local icon_to_ammo_spacing = 8
	local needed_width = self._ammo_left_text:w() + icon_to_ammo_spacing
	local chunk_w = self._ammo_panel:w() - self._ammo_left_text:w() - icon_to_ammo_spacing
	local is_thin = self._icon_thin_min < self._max_clip
	local guis = self._guis[is_thin and 1 or 2]
	local is_doublestack = (guis[1].texture_rect[4] / 2 <= self._ammo_panel:h() / 2 or guis[2].texture_rect[4] / 2 <= self._ammo_panel:h() / 2) and self._icon_stack_min < self._max_clip or false

	for i = 1, self._max_clip do
		local bullet = self._ammo_panel:child("clip_bullet" .. i)
		local spent = current_clip < i
		local gui = guis[spent and 2 or 1]

		if bullet then
			local clip_percentage = self._max_clip > 0 and current_clip / self._max_clip or 0

			bullet:set_color(spent and self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_SPENT_COLORS, clip_percentage) or self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, clip_percentage))
		else
			local gui_ratio = gui.texture_rect[3] / 2 / gui.texture_rect[4] / 2
			local is_short = gui.texture_rect[4] / 2 <= 16
			local scale = is_short and 0.5 or 1
			local h = scale * self._ammo_panel:h()
			local w = h * gui_ratio
			bullet = self._ammo_panel:bitmap({
				layer = nil,
				alpha = nil,
				w = nil,
				name = nil,
				h = nil,
				name = "clip_bullet" .. i,
				w = w,
				h = h,
				layer = self._ammo_panel:layer() + 1,
				alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
			})
		end

		bullet:set_image(gui.texture)
		bullet:set_texture_rect(unpack(gui.texture_rect))
		bullet:set_w(gui.texture_rect[3] / 2)
		bullet:set_h(gui.texture_rect[4] / 2)

		local x_bullet = i
		local bullets_in_row = self._max_clip

		if is_doublestack then
			bullets_in_row = math.floor(self._max_clip / 2)

			if bullets_in_row < x_bullet then
				x_bullet = x_bullet - bullets_in_row
			end
		end

		local top_row = bullets_in_row < i

		if is_doublestack then
			bullet:set_center_y(self._ammo_panel:h() / 4 * (top_row and 1 or 3))
		else
			bullet:set_center_y(self._ammo_panel:h() / 2)
		end

		local bullet_i = i - 1
		local bullet_w = bullet:w() - (is_thin and 1 or 3)
		local bullet_x = bullet_w * bullet_i

		if is_doublestack then
			local quarter = bullet_w * self._max_clip / 4

			if top_row then
				bullet_x = bullet_x - quarter
			else
				bullet_x = bullet_x + quarter
			end

			bullet_x = bullet_x - quarter

			if self._max_clip % 2 == 1 then
				bullet_x = bullet_x + bullet_w / 2
			end
		end

		bullet:set_x(bullet_x)

		needed_width = needed_width + (is_doublestack and bullet_w / 2 or bullet_w)
	end

	if self._ammo_panel:child("clip_bullet" .. self._max_clip + 1) then
		local i = self._max_clip + 1
		local bullet = self._ammo_panel:child("clip_bullet" .. self._max_clip + 1)

		while alive(bullet) do
			self._ammo_panel:remove(bullet)

			i = i + 1
			bullet = self._ammo_panel:child("clip_bullet" .. i)
		end
	end

	if self._max_clip % 2 == 1 then
		needed_width = needed_width + guis[1].texture_rect[3] / 2
	end

	self._ammo_panel:set_w(needed_width)
	self._ammo_panel:set_center_x(self._object:w() / 2)
end

function HUDWeaponClipShots:_animate_alpha(root_panel, new_alpha)
	local start_alpha = new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponBase.ALPHA_WHEN_UNSELECTED or HUDWeaponBase.ALPHA_WHEN_SELECTED
	local start_ammo_left_alpha = start_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED or HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED
	local new_ammo_left_alpha = start_ammo_left_alpha == HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED and HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED or HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED
	local duration = 0.2
	local t = (self._icon:alpha() - start_alpha) / (new_alpha - start_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, start_alpha, new_alpha - start_alpha, duration)

		self._icon:set_alpha(current_alpha)
		self._firemode_single:set_alpha(current_alpha)
		self._firemode_auto:set_alpha(current_alpha)

		local ammo_left_alpha = Easing.quartic_in_out(t, start_ammo_left_alpha, new_ammo_left_alpha - start_ammo_left_alpha, duration)

		self._ammo_left_text:set_alpha(ammo_left_alpha)

		for i = 1, self._max_clip do
			local bullet = self._ammo_panel:child("clip_bullet" .. i)

			if bullet then
				bullet:set_alpha(ammo_left_alpha)
			end
		end
	end

	self._icon:set_alpha(new_alpha)
	self._firemode_single:set_alpha(new_alpha)
	self._firemode_auto:set_alpha(new_alpha)
	self._ammo_left_text:set_alpha(new_ammo_left_alpha)

	for i = 1, self._max_clip do
		local bullet = self._ammo_panel:child("clip_bullet" .. i)

		if bullet then
			bullet:set_alpha(new_ammo_left_alpha)
		end
	end
end
