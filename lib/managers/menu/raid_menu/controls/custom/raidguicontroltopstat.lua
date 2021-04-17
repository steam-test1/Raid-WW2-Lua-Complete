RaidGUIControlTopStat = RaidGUIControlTopStat or class(RaidGUIControl)
RaidGUIControlTopStat.WIDTH = 192
RaidGUIControlTopStat.HEIGHT = 320
RaidGUIControlTopStat.PLAYER_NAME_Y = 0
RaidGUIControlTopStat.PLAYER_NAME_H = 64
RaidGUIControlTopStat.PLAYER_NAME_COLOR = Color.white
RaidGUIControlTopStat.STAT_NAME_Y = 130
RaidGUIControlTopStat.STAT_NAME_H = 64
RaidGUIControlTopStat.STAT_NAME_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlTopStat.STAT_ICON_SIZE = 192
RaidGUIControlTopStat.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlTopStat.FONT_SIZE = tweak_data.gui.font_sizes.large
RaidGUIControlTopStat.FONT_KERNING = tweak_data.hud.medium_kern

function RaidGUIControlTopStat:init(parent, params)
	RaidGUIControlTopStat.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlTopStat:init] Parameters not specified for the customization details")

		return
	end

	self._pointer_type = "arrow"

	self:highlight_off()
	self:_create_control_panel()
	self:_create_stat_info()
	self:_create_icon_panel()
end

function RaidGUIControlTopStat:close()
end

function RaidGUIControlTopStat:_create_control_panel()
	local control_params = clone(self._params)
	control_params.w = RaidGUIControlTopStat.WIDTH
	control_params.h = RaidGUIControlTopStat.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlTopStat:_create_stat_info()
	local params_player_name = {
		vertical = "center",
		name = "player_name_label",
		align = "center",
		alpha = 0,
		text = "PLAYER NAME",
		y = 0,
		x = 0,
		layer = 1,
		w = self._object:w(),
		h = RaidGUIControlTopStat.PLAYER_NAME_H,
		color = RaidGUIControlTopStat.PLAYER_NAME_COLOR,
		font = RaidGUIControlTopStat.FONT,
		font_size = RaidGUIControlTopStat.FONT_SIZE
	}
	self._player_name_label = self._control_panel:label(params_player_name)
	local params_stat_name = {
		vertical = "top",
		name = "stat_name_label",
		wrap = true,
		align = "center",
		word_wrap = true,
		text = "Most specials killed",
		alpha = 0,
		x = 0,
		layer = 3,
		y = self._object:h() - RaidGUIControlTopStat.STAT_NAME_H,
		w = RaidGUIControlTopStat.WIDTH,
		h = RaidGUIControlTopStat.STAT_NAME_H,
		color = RaidGUIControlTopStat.STAT_NAME_COLOR,
		font = RaidGUIControlTopStat.FONT,
		font_size = RaidGUIControlTopStat.FONT_SIZE
	}
	self._stat_name_label = self._control_panel:label(params_stat_name)
end

function RaidGUIControlTopStat:_create_icon_panel()
	local icon_panel_params = {
		name = "icon_panel",
		x = 0,
		y = self._player_name_label:y() + self._player_name_label:h(),
		w = RaidGUIControlTopStat.STAT_ICON_SIZE,
		h = RaidGUIControlTopStat.STAT_ICON_SIZE,
		layer = self._object:layer() + 1
	}
	self._icon_panel = self._object:panel(icon_panel_params)
end

function RaidGUIControlTopStat:set_data(data)
	self._player_name_label:set_text(utf8.to_upper(data.player_nickname))
	self._stat_name_label:set_text(self:translate(data.stat, true))

	local params_stat_icon = {
		name = "stat_icon",
		y = 0,
		alpha = 0,
		x = 0,
		w = data.icon_texture_rect[3],
		h = data.icon_texture_rect[4],
		texture = data.icon_texture,
		texture_rect = data.icon_texture_rect
	}
	self._stat_icon = self._icon_panel:bitmap(params_stat_icon)

	self._stat_icon:set_center_x(self._icon_panel:w() / 2)
	self._stat_icon:set_center_y(self._icon_panel:h() / 2)
end

function RaidGUIControlTopStat:animate_show(delay)
	delay = delay or 0

	self._stat_icon:animate(callback(self, self, "_animate_show_stat"), delay, self._stat_icon, self._stat_name_label)
	self._player_name_label._object:animate(callback(self, self, "_animate_show_player_name"), delay + 0.6)
end

function RaidGUIControlTopStat:_animate_show_stat(panel, delay, icon, label)
	if delay then
		wait(delay)
	end

	local t = 0
	local duration = 0.7
	local initial_offset = 15
	local stat_icon_y = icon:y()
	local stat_name_y = label:y()

	icon:set_y(stat_icon_y + initial_offset)
	label:set_y(stat_name_y + initial_offset)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, duration)

		icon:set_y(stat_icon_y + current_offset)
		label:set_y(stat_name_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, duration)

		icon:set_alpha(current_alpha)
		label:set_alpha(current_alpha)
	end

	icon:set_y(stat_icon_y)
	label:set_y(stat_name_y)
	icon:set_alpha(1)
	label:set_alpha(1)
end

function RaidGUIControlTopStat:_animate_show_player_name(label, delay)
	if delay then
		wait(delay)
	end

	local t = 0
	local duration = 0.15
	local font_size = RaidGUIControlTopStat.FONT_SIZE
	local center_x = self._player_name_label._object:center_x()
	local center_y = self._player_name_label._object:center_y()
	local mid_offset = 5
	local initial_offset = 10

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.linear(t, -initial_offset, initial_offset + mid_offset, duration)

		self._player_name_label:set_font_size(font_size + current_offset)
		self._player_name_label._object:set_center(center_x, center_y)

		local current_alpha = Easing.quintic_out(t, 0, 1, duration - 0.05)

		self._player_name_label:set_alpha(current_alpha)
	end

	self._player_name_label:set_font_size(font_size + mid_offset)
	self._player_name_label._object:animate(callback(self, self, "_animate_text_glow"), tweak_data.gui.colors.raid_light_red, 1, 1)

	t = 0
	duration = 0.6

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_out(t, mid_offset, -mid_offset, duration)

		self._player_name_label:set_font_size(font_size + current_offset)
		self._player_name_label._object:set_center(center_x, center_y)
	end

	self._player_name_label:set_font_size(font_size)
	self._player_name_label._object:set_center(center_x, center_y)
end

function RaidGUIControlTopStat:_animate_text_glow(text, new_color, duration, number_of_laps, delay)
	local number_of_letters = string.len(text:text())
	local original_color = text:color()
	local change_r = new_color.r - original_color.r
	local change_g = new_color.g - original_color.g
	local change_b = new_color.b - original_color.b
	local change_a = new_color.a - original_color.a
	local t = 0
	local delay_between_letters = 0.05
	local duration_per_letter = duration / number_of_laps - delay_between_letters * (number_of_letters - 1)

	if delay ~= nil then
		wait(delay)
	end

	local laps_done = 0
	local lap_time = duration / number_of_laps

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt

		for i = 1, number_of_letters do
			local blend_amount = Easing.sine_pulse((t - laps_done * lap_time - (i - 1) * delay_between_letters) / duration_per_letter)
			local current_a = original_color.a + blend_amount * change_a
			local current_r = original_color.r + blend_amount * change_r
			local current_g = original_color.g + blend_amount * change_g
			local current_b = original_color.b + blend_amount * change_b

			text:set_range_color(i - 1, i, Color(current_a, current_r, current_g, current_b))
		end

		if laps_done < math.floor(t / (duration / number_of_laps)) then
			laps_done = laps_done + 1
		end
	end

	text:clear_range_color(0, number_of_letters)
end
