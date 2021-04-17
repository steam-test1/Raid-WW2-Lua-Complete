HUDWeaponGeneric = HUDWeaponGeneric or class(HUDWeaponBase)
HUDWeaponGeneric.W = 138
HUDWeaponGeneric.H = 84
HUDWeaponGeneric.AMMO_PANEL_X = 15
HUDWeaponGeneric.AMMO_PANEL_W = 110
HUDWeaponGeneric.AMMO_PANEL_H = 34
HUDWeaponGeneric.CLIP_BACKGROUND_W = 54
HUDWeaponGeneric.CLIP_BACKGROUND_THICKNESS = 1
HUDWeaponGeneric.CLIP_BACKGROUND_OUTLINE_COLOR = tweak_data.gui.colors.ammo_background_outline
HUDWeaponGeneric.CLIP_BACKGROUND_COLORS = tweak_data.gui.colors.ammo_clip_colors
HUDWeaponGeneric.CURRENT_CLIP_FONT = tweak_data.gui.fonts.din_compressed
HUDWeaponGeneric.CURRENT_CLIP_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDWeaponGeneric.CURRENT_CLIP_TEXT_COLOR = tweak_data.gui.colors.ammo_text
HUDWeaponGeneric.AMMO_LEFT_FONT = tweak_data.gui.fonts.din_compressed_outlined_32
HUDWeaponGeneric.AMMO_LEFT_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDWeaponGeneric.AMMO_LEFT_TEXT_COLOR = Color.white
HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_SELECTED = 1
HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED = 0.7
HUDWeaponGeneric.FIREMODE_AUTO_ICON = "weapon_panel_indicator_rapid_fire"
HUDWeaponGeneric.FIREMODE_SINGLE_ICON = "weapon_panel_indicator_single_fire"
HUDWeaponGeneric.FIREMODE_DISTANCE_FROM_RIGHT_EDGE = 19

-- Lines 31-42
function HUDWeaponGeneric:init(index, weapons_panel, tweak_data)
	HUDWeaponGeneric.super.init(self, index, weapons_panel, tweak_data)

	self._index = index

	self:_create_panel(weapons_panel)
	self:_create_icon(tweak_data.hud.icon)
	self:_create_ammo_info(weapons_panel)
	self:_create_firemodes()
end

-- Lines 44-52
function HUDWeaponGeneric:_create_panel(weapons_panel)
	local panel_params = {
		halign = "right",
		valign = "bottom",
		name = "weapon_" .. tostring(self._index),
		w = HUDWeaponGeneric.W,
		h = HUDWeaponGeneric.H
	}
	self._object = weapons_panel:panel(panel_params)
end

-- Lines 54-73
function HUDWeaponGeneric:_create_icon(icon)
	local icon_panel_params = {
		halign = "center",
		name = "icon_panel",
		y = 0,
		x = 0,
		valign = "top",
		w = self._object:w(),
		h = self._object:h() / 2
	}
	self._icon_panel = self._object:panel(icon_panel_params)
	local icon_params = {
		name = "weapon_icon",
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	self._icon = self._icon_panel:bitmap(icon_params)

	self._icon:set_center_x(self._icon_panel:w() / 2)
	self._icon:set_center_y(self._icon_panel:h() / 2)
end

-- Lines 75-133
function HUDWeaponGeneric:_create_ammo_info(weapons_panel)
	local ammo_panel_params = {
		name = "ammo_panel",
		halign = "center",
		valign = "bottom",
		x = HUDWeaponGeneric.AMMO_PANEL_X,
		w = HUDWeaponGeneric.AMMO_PANEL_W,
		h = HUDWeaponGeneric.AMMO_PANEL_H
	}
	self._ammo_panel = self._object:panel(ammo_panel_params)

	self._ammo_panel:set_bottom(self._object:h())

	local current_clip_background_border_params = {
		halign = "left",
		name = "current_clip_background_border",
		y = 0,
		x = 0,
		valign = "top",
		w = HUDWeaponGeneric.CLIP_BACKGROUND_W,
		h = self._ammo_panel:h(),
		color = HUDWeaponGeneric.CLIP_BACKGROUND_OUTLINE_COLOR,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	local current_clip_background_border = self._ammo_panel:rect(current_clip_background_border_params)
	local current_clip_background_params = {
		halign = "left",
		name = "current_clip_background",
		valign = "top",
		x = HUDWeaponGeneric.CLIP_BACKGROUND_THICKNESS,
		y = HUDWeaponGeneric.CLIP_BACKGROUND_THICKNESS,
		w = current_clip_background_border:w() - HUDWeaponGeneric.CLIP_BACKGROUND_THICKNESS * 2,
		h = current_clip_background_border:h() - HUDWeaponGeneric.CLIP_BACKGROUND_THICKNESS * 2,
		color = tweak_data.gui.colors.progress_75,
		layer = current_clip_background_border:layer() + 1,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	self._current_clip_background = self._ammo_panel:rect(current_clip_background_params)
	local current_clip_text_params = {
		text = "",
		name = "current_clip_amount",
		halign = "left",
		valign = "top",
		font = tweak_data.gui:get_font_path(HUDWeaponGeneric.CURRENT_CLIP_FONT, HUDWeaponGeneric.CURRENT_CLIP_FONT_SIZE),
		font_size = HUDWeaponGeneric.CURRENT_CLIP_FONT_SIZE,
		color = HUDWeaponGeneric.CURRENT_CLIP_TEXT_COLOR,
		layer = self._current_clip_background:layer() + 1
	}
	self._current_clip_text = self._ammo_panel:text(current_clip_text_params)

	self:set_max_clip(1)
	self:set_current_clip(0)

	local ammo_left_text_params = {
		text = "",
		name = "ammo_left_amount",
		halign = "right",
		valign = "top",
		font = HUDWeaponGeneric.AMMO_LEFT_FONT,
		font_size = HUDWeaponGeneric.AMMO_LEFT_FONT_SIZE,
		color = HUDWeaponGeneric.AMMO_LEFT_TEXT_COLOR,
		alpha = HUDWeaponGeneric.AMMO_LEFT_ALPHA_WHEN_UNSELECTED
	}
	self._ammo_left_text = self._ammo_panel:text(ammo_left_text_params)

	self:set_current_left(0)
end

-- Lines 135-159
function HUDWeaponGeneric:_create_firemodes()
	local firemode_auto_params = {
		name = "firemode_auto",
		halign = "center",
		valign = "bottom",
		texture = tweak_data.gui.icons[HUDWeaponGeneric.FIREMODE_AUTO_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDWeaponGeneric.FIREMODE_AUTO_ICON].texture_rect,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	self._firemode_auto = self._icon_panel:bitmap(firemode_auto_params)

	self._firemode_auto:set_right(self._icon_panel:w() - 17)
	self._firemode_auto:set_bottom(self._icon_panel:h() + 2)

	local firemode_single_params = {
		name = "firemode_single",
		halign = "center",
		valign = "bottom",
		texture = tweak_data.gui.icons[HUDWeaponGeneric.FIREMODE_SINGLE_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDWeaponGeneric.FIREMODE_SINGLE_ICON].texture_rect,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	self._firemode_single = self._icon_panel:bitmap(firemode_single_params)

	self._firemode_single:set_right(self._icon_panel:w() - 12)
	self._firemode_single:set_bottom(self._icon_panel:h() + 2)
	self:set_firemode(self._tweak_data.FIRE_MODE)
end

-- Lines 161-173
function HUDWeaponGeneric:set_current_clip(current_clip)
	self._current_clip_text:set_text(string.format("%03d", current_clip))

	local _, _, w, h = self._current_clip_text:text_rect()

	self._current_clip_text:set_w(w)
	self._current_clip_text:set_h(h)
	self._current_clip_text:set_center_x(self._current_clip_background:w() / 2 + 1)
	self._current_clip_text:set_center_y(self._current_clip_background:h() / 2 - 1)

	local clip_percentage = self._max_clip > 0 and current_clip / self._max_clip or 0

	self._current_clip_background:set_color(self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, clip_percentage))
end

-- Lines 175-190
function HUDWeaponGeneric:set_current_left(current_left)
	self._ammo_left_text:set_text(string.format("%03d", current_left))

	local _, _, w, h = self._ammo_left_text:text_rect()

	self._ammo_left_text:set_w(w)
	self._ammo_left_text:set_h(h)
	self._ammo_left_text:set_right(self._ammo_panel:w() - 6)
	self._ammo_left_text:set_center_y(self._ammo_panel:h() / 2 - 3)

	if current_left == 0 then
		self._ammo_left_text:set_color(self:_get_color_for_percentage(HUDWeaponGeneric.CLIP_BACKGROUND_COLORS, 0))
	else
		self._ammo_left_text:set_color(HUDWeaponGeneric.AMMO_LEFT_TEXT_COLOR)
	end
end

-- Lines 192-194
function HUDWeaponGeneric:set_max_clip(max_clip)
	self._max_clip = max_clip
end

-- Lines 196-198
function HUDWeaponGeneric:set_max(max)
	self._max = max
end

-- Lines 200-203
function HUDWeaponGeneric:set_firemode(mode)
	self._firemode_single:set_visible(mode == "single" and true or false)
	self._firemode_auto:set_visible(mode == "auto" and true or false)
end

-- Lines 205-213
function HUDWeaponGeneric:_get_color_for_percentage(color_table, percentage)
	for i = #color_table, 1, -1 do
		if color_table[i].start_percentage < percentage then
			return color_table[i].color
		end
	end

	return color_table[1].color
end

-- Lines 216-247
function HUDWeaponGeneric:_animate_alpha(root_panel, new_alpha)
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
		self._ammo_panel:child("current_clip_background_border"):set_alpha(current_alpha)
		self._current_clip_background:set_alpha(current_alpha)

		local ammo_left_alpha = Easing.quartic_in_out(t, start_ammo_left_alpha, new_ammo_left_alpha - start_ammo_left_alpha, duration)

		self._ammo_left_text:set_alpha(ammo_left_alpha)
	end

	self._icon:set_alpha(new_alpha)
	self._firemode_single:set_alpha(new_alpha)
	self._firemode_auto:set_alpha(new_alpha)
	self._ammo_panel:child("current_clip_background_border"):set_alpha(new_alpha)
	self._current_clip_background:set_alpha(new_alpha)
	self._ammo_left_text:set_alpha(new_ammo_left_alpha)
end
