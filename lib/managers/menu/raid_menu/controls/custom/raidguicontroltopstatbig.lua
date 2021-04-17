RaidGUIControlTopStatBig = RaidGUIControlTopStatBig or class(RaidGUIControl)
RaidGUIControlTopStatBig.WIDTH = 576
RaidGUIControlTopStatBig.HEIGHT = 928
RaidGUIControlTopStatBig.ICON_BACKGROUND = "bonus_bg_flag"
RaidGUIControlTopStatBig.ICON_BACKGROUND_FAIL = "bonus_bg_flag_fail"
RaidGUIControlTopStatBig.ICON_BACKGROUND_CENTER_Y = 413
RaidGUIControlTopStatBig.STAT_NAME_CENTER_Y_FROM_BOTTOM = 226
RaidGUIControlTopStatBig.STAT_NAME_H = 64
RaidGUIControlTopStatBig.STAT_NAME_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlTopStatBig.STAT_NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlTopStatBig.STAT_VALUE_CENTER_Y_FROM_BOTTOM = 101
RaidGUIControlTopStatBig.STAT_VALUE_H = 96
RaidGUIControlTopStatBig.STAT_VALUE_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlTopStatBig.STAT_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_84
RaidGUIControlTopStatBig.PLAYER_NAME_CENTER_Y_FROM_BOTTOM = 179
RaidGUIControlTopStatBig.PLAYER_NAME_H = 64
RaidGUIControlTopStatBig.PLAYER_NAME_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlTopStatBig.PLAYER_NAME_FONT_SIZE = tweak_data.gui.font_sizes.menu_list
RaidGUIControlTopStatBig.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlTopStatBig.FONT_KERNING = tweak_data.hud.medium_kern

-- Lines 31-44
function RaidGUIControlTopStatBig:init(parent, params)
	RaidGUIControlTopStatBig.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlTopStatBig:init] Parameters not specified for RaidGUIControlTopStatBig", params.name)

		return
	end

	self:_create_panel()
	self:_create_stat_info()
	self:_create_icon_background()

	self._shown = false
end

-- Lines 47-48
function RaidGUIControlTopStatBig:close()
end

-- Lines 51-61
function RaidGUIControlTopStatBig:_create_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x or 0
	control_params.w = RaidGUIControlTopStatBig.WIDTH
	control_params.h = RaidGUIControlTopStatBig.HEIGHT
	control_params.name = control_params.name .. "_top_stat_big_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 64-108
function RaidGUIControlTopStatBig:_create_stat_info()
	local player_name_params = {
		vertical = "center",
		name = "player_name_label",
		align = "center",
		alpha = 0,
		text = "PLAYER NAME",
		layer = 1,
		w = self._object:w(),
		h = RaidGUIControlTopStatBig.PLAYER_NAME_H,
		font = RaidGUIControlTopStatBig.FONT,
		font_size = RaidGUIControlTopStatBig.PLAYER_NAME_FONT_SIZE,
		color = RaidGUIControlTopStatBig.PLAYER_NAME_COLOR
	}
	self._player_name_label = self._object:label(player_name_params)

	self._player_name_label:set_center_y(self._object:h() - RaidGUIControlTopStatBig.PLAYER_NAME_CENTER_Y_FROM_BOTTOM)

	local stat_name_params = {
		vertical = "center",
		wrap = true,
		align = "center",
		name = "stat_name_label",
		word_wrap = true,
		text = "Most specials killed",
		alpha = 0,
		layer = 3,
		w = self._object:w(),
		h = RaidGUIControlTopStatBig.STAT_NAME_H,
		font = RaidGUIControlTopStatBig.FONT,
		font_size = RaidGUIControlTopStatBig.STAT_NAME_FONT_SIZE,
		color = RaidGUIControlTopStatBig.STAT_NAME_COLOR
	}
	self._stat_name_label = self._object:label(stat_name_params)

	self._stat_name_label:set_center_y(self._object:h() - RaidGUIControlTopStatBig.STAT_NAME_CENTER_Y_FROM_BOTTOM)

	local stat_value_params = {
		vertical = "center",
		wrap = true,
		align = "center",
		name = "stat_value_label",
		word_wrap = true,
		text = "1",
		alpha = 0,
		layer = 3,
		w = self._object:w(),
		h = RaidGUIControlTopStatBig.STAT_VALUE_H,
		font = RaidGUIControlTopStatBig.FONT,
		font_size = RaidGUIControlTopStatBig.STAT_VALUE_FONT_SIZE,
		color = RaidGUIControlTopStatBig.STAT_VALUE_COLOR
	}
	self._stat_value_label = self._object:label(stat_value_params)

	self._stat_value_label:set_center_y(self._object:h() - RaidGUIControlTopStatBig.STAT_VALUE_CENTER_Y_FROM_BOTTOM)
end

-- Lines 110-120
function RaidGUIControlTopStatBig:_create_icon_background()
	local icon_background_params = {
		name = "icon_background",
		alpha = 0,
		texture = tweak_data.gui.icons[RaidGUIControlTopStatBig.ICON_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlTopStatBig.ICON_BACKGROUND].texture_rect
	}
	local icon_background = self._object:bitmap(icon_background_params)

	icon_background:set_center_x(self._object:w() / 2)
	icon_background:set_center_y(RaidGUIControlTopStatBig.ICON_BACKGROUND_CENTER_Y)
end

-- Lines 122-150
function RaidGUIControlTopStatBig:set_data(data)
	self._player_name_label:set_text(utf8.to_upper(data.player_nickname))
	self._stat_name_label:set_text(self:translate(data.text_id, true))

	local score = data.score

	if data.score_format then
		score = string.format(data.score_format, data.score)
	end

	self._stat_value_label:set_text(score)

	local icon_params = {
		name = "stat_icon",
		alpha = 0,
		texture = tweak_data.gui.icons[data.icon].texture,
		texture_rect = tweak_data.gui.icons[data.icon].texture_rect
	}
	self._stat_icon = self._object:bitmap(icon_params)

	self._stat_icon:set_center_x(self._object:w() / 2)

	self._sound_effect = data.sound_effect
	local icon_background = self._object:child("icon_background")

	self._stat_icon:set_center_y(icon_background:y() + icon_background:h() / 2)

	if not data.mission_successful then
		icon_background:set_image(tweak_data.gui.icons[RaidGUIControlTopStatBig.ICON_BACKGROUND_FAIL].texture)
		icon_background:set_texture_rect(unpack(tweak_data.gui.icons[RaidGUIControlTopStatBig.ICON_BACKGROUND_FAIL].texture_rect))
	end
end

-- Lines 152-158
function RaidGUIControlTopStatBig:animate_show(delay, clbk)
	Application:trace("RaidGUIControlTopStatBig:animate_show", delay, clbk)

	delay = delay or 0

	self._stat_icon:animate(callback(self, self, "_animate_show_stat"), delay, self._stat_icon, self._stat_name_label)
	self._player_name_label._object:animate(callback(self, self, "_animate_show_result"), delay + 0.6, clbk)
end

-- Lines 160-162
function RaidGUIControlTopStatBig:shown()
	return self._shown
end

-- Lines 164-204
function RaidGUIControlTopStatBig:_animate_show_stat(panel, delay, icon, label)
	if delay then
		wait(delay)
	end

	local t = 0
	local duration = 0.7
	local initial_offset = 15
	local stat_icon_y = icon:y()
	local stat_name_y = label:y()
	local icon_background = self._object:child("icon_background")
	local icon_background_y = icon_background:y()

	icon_background:set_y(icon_background_y + initial_offset)
	icon:set_y(stat_icon_y + initial_offset)
	label:set_y(stat_name_y + initial_offset)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, duration)

		icon_background:set_y(icon_background_y + current_offset)
		icon:set_y(stat_icon_y + current_offset)
		label:set_y(stat_name_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, duration)

		icon_background:set_alpha(current_alpha)
		icon:set_alpha(current_alpha)
		label:set_alpha(current_alpha)
	end

	icon_background:set_y(icon_background_y)
	icon:set_y(stat_icon_y)
	label:set_y(stat_name_y)
	icon_background:set_alpha(1)
	icon:set_alpha(1)
	label:set_alpha(1)
end

-- Lines 206-250
function RaidGUIControlTopStatBig:_animate_show_result(label, delay, clbk)
	if delay then
		wait(delay)
	end

	local t = 0
	local duration = 0.7
	local initial_offset = 15
	local player_name_y = self._player_name_label:y()
	local stat_value_y = self._stat_value_label:y()

	self._player_name_label:set_y(player_name_y + initial_offset)
	self._stat_value_label:set_y(stat_value_y + initial_offset)

	if self._sound_effect then
		managers.menu_component:post_event(self._sound_effect)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, duration)

		self._player_name_label:set_y(player_name_y + current_offset)
		self._stat_value_label:set_y(stat_value_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, duration)

		self._player_name_label:set_alpha(current_alpha)
		self._stat_value_label:set_alpha(current_alpha)
	end

	self._player_name_label:set_y(player_name_y)
	self._stat_value_label:set_y(stat_value_y)
	self._player_name_label:set_alpha(1)
	self._stat_value_label:set_alpha(1)

	self._shown = true

	if clbk then
		clbk()
	end
end
