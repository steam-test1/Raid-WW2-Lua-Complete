HUDWeaponDrum = HUDWeaponDrum or class(HUDWeaponGeneric)
HUDWeaponDrum.CLIP_ICON = "weapon_panel_indicator_"

function HUDWeaponDrum:init(index, weapons_panel, tweak_data)
	self._icon_fg_ring = tweak_data.hud.icon_fg_ring or "drum_fg_ring"
	self._icon_bg_ring = tweak_data.hud.icon_bg_ring or "drum_bg_ring"
	self._icon_ooa_ring = tweak_data.hud.icon_ooa_ring or "drum_ooa_ring"
	self._drums = tweak_data.hud.drums or 1
	self._feed_flip_y = tweak_data.hud.feed_flip_y or false
	self._feed_flip_x = tweak_data.hud.feed_flip_x or false

	HUDWeaponDrum.super.init(self, index, weapons_panel, tweak_data)
end

function HUDWeaponDrum:_create_clip_left_info(weapons_panel)
	local padding = 8
	local gui = {
		tweak_data.gui.icons[HUDWeaponDrum.CLIP_ICON .. self._icon_bg_ring],
		tweak_data.gui.icons[HUDWeaponDrum.CLIP_ICON .. self._icon_fg_ring],
		tweak_data.gui.icons[HUDWeaponDrum.CLIP_ICON .. self._icon_ooa_ring]
	}

	self._ammo_panel:set_w(self._ammo_left_text:w() + padding + self._drums * gui[1].texture_rect[3])
	self._ammo_panel:set_center_x(self._object:w() / 2)

	for i = 1, self._drums do
		local bullets_each_drum = self._drums
		local chunk_w = self._ammo_panel:w() - self._ammo_left_text:w()
		local chunk_w_space = chunk_w / bullets_each_drum
		local chunk_w_c = chunk_w_space * i - chunk_w_space / 2
		local ring_w = self._ammo_panel:h()
		local ring_h = self._ammo_panel:h()

		if self._feed_flip_x then
			ring_w = -ring_w
		end

		if i > 1 then
			ring_w = -ring_w
		end

		if self._feed_flip_y then
			ring_h = -ring_h
		end

		local clip_left_background = self._ammo_panel:bitmap({
			name = "clip_left_background" .. i,
			texture = gui[1].texture,
			texture_rect = gui[1].texture_rect,
			w = ring_w,
			h = ring_h
		})

		clip_left_background:set_center_x(chunk_w_c)
		clip_left_background:set_center_y(self._ammo_panel:h() / 2)

		local layer = clip_left_background:layer() + 1
		local clip_left_fill = self._ammo_panel:bitmap({
			position_z = 1,
			render_template = "VertexColorTexturedRadial",
			name = "clip_left_fill" .. i,
			texture = gui[2].texture,
			texture_rect = gui[2].texture_rect,
			w = ring_w,
			h = ring_h,
			layer = layer
		})

		clip_left_fill:set_center_x(chunk_w_c)
		clip_left_fill:set_center_y(self._ammo_panel:h() / 2)

		layer = layer + 1
		local clip_left_ooa = self._ammo_panel:bitmap({
			visible = false,
			name = "clip_left_ooa" .. i,
			texture = gui[3].texture,
			texture_rect = gui[3].texture_rect,
			layer = layer,
			w = self._ammo_panel:h() / 2,
			h = self._ammo_panel:h() / 2
		})

		clip_left_ooa:set_center_x(chunk_w_c)
		clip_left_ooa:set_center_y(self._ammo_panel:h() / 2)
	end
end

function HUDWeaponDrum:set_current_clip(current_clip)
	local clip_percentage = self._max_clip > 0 and current_clip / self._max_clip or 0
	local color = self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, clip_percentage)

	for i = 1, self._drums do
		self._ammo_panel:child("clip_left_fill" .. i):set_position_z(clip_percentage)
		self._ammo_panel:child("clip_left_fill" .. i):set_color(color)

		local ooa = self._ammo_panel:child("clip_left_ooa" .. i)

		ooa:set_visible(current_clip <= 0)
		ooa:set_color(color)
	end
end

function HUDWeaponDrum:_animate_alpha(root_panel, new_alpha)
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

		for i = 1, self._drums do
			local fill = self._ammo_panel:child("clip_left_fill" .. i)

			fill:set_alpha(ammo_left_alpha)

			local back = self._ammo_panel:child("clip_left_background" .. i)

			back:set_alpha(ammo_left_alpha)

			local ooa = self._ammo_panel:child("clip_left_ooa" .. i)

			ooa:set_alpha(ammo_left_alpha)
		end
	end

	self._icon:set_alpha(new_alpha)
	self._firemode_single:set_alpha(new_alpha)
	self._firemode_auto:set_alpha(new_alpha)
	self._ammo_left_text:set_alpha(new_ammo_left_alpha)

	for i = 1, self._drums do
		local fill = self._ammo_panel:child("clip_left_fill" .. i)

		fill:set_alpha(new_ammo_left_alpha)

		local back = self._ammo_panel:child("clip_left_background" .. i)

		back:set_alpha(new_ammo_left_alpha)

		local ooa = self._ammo_panel:child("clip_left_ooa" .. i)

		ooa:set_alpha(new_ammo_left_alpha)
	end
end
