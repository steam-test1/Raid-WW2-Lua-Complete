HUDTabGreedBar = HUDTabGreedBar or class()
HUDTabGreedBar.WIDTH = 192
HUDTabGreedBar.HEIGHT = 96
HUDTabGreedBar.ICONS_W = 96
HUDTabGreedBar.FRAME_ICON = "rewards_extra_loot_small_frame"
HUDTabGreedBar.LOOT_ICON = "rewards_extra_loot_small_middle_loot"
HUDTabGreedBar.GOLD_ICON = "rewards_extra_loot_small_middle_gold"
HUDTabGreedBar.TITLE_H = 64
HUDTabGreedBar.TITLE_STRING = "menu_save_info_loot_title"
HUDTabGreedBar.TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDTabGreedBar.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDTabGreedBar.TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabGreedBar.LOOT_BAR_W = 80
HUDTabGreedBar.LOOT_BAR_ICON_L = "loot_meter_parts_l"
HUDTabGreedBar.LOOT_BAR_ICON_M = "loot_meter_parts_m"
HUDTabGreedBar.LOOT_BAR_ICON_R = "loot_meter_parts_r"
HUDTabGreedBar.LOOT_BAR_COLOR = tweak_data.gui.colors.raid_dark_grey
HUDTabGreedBar.LOOT_BAR_FOREGROUND_COLOR = tweak_data.gui.colors.raid_gold
HUDTabGreedBar.COUNTER_H = 16
HUDTabGreedBar.COUNTER_FONT = tweak_data.gui.fonts.din_compressed
HUDTabGreedBar.COUNTER_FONT_SIZE = tweak_data.gui.font_sizes.size_18
HUDTabGreedBar.COUNTER_COLOR = tweak_data.gui.colors.raid_dark_grey
HUDTabGreedBar.COUNTER_OFFSET = 6
HUDTabGreedBar.COUNTER_INCREASE_COLOR = tweak_data.gui.colors.raid_gold
HUDTabGreedBar.TUTORIALIZATION_STRING = "hud_greed_complete_mission_to_secure"
HUDTabGreedBar.TUTORIALIZATION_FONT = tweak_data.gui.fonts.lato
HUDTabGreedBar.TUTORIALIZATION_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDTabGreedBar.TUTORIALIZATION_COLOR = tweak_data.gui.colors.raid_grey
HUDTabGreedBar.ICON_HIDDEN_OFFSET = 40
HUDTabGreedBar.FRAME_PULSE_SPEEDS = {
	2.2,
	1,
	0.5,
	0.25
}

-- Lines 40-51
function HUDTabGreedBar:init(panel, params)
	self._gold_bars_obtained_in_mission = 0

	self:_create_panel(panel, params)
	self:_create_icons()
	self:_create_right_panel()
	self:_create_title()
	self:_create_bar()
	self:_create_counter()
end

-- Lines 53-64
function HUDTabGreedBar:_create_panel(panel, params)
	local panel_params = {
		halign = "right",
		name = "hud_tab_greed_bar",
		valign = "bottom",
		x = params.x or 0,
		y = params.y or 0,
		w = HUDTabGreedBar.WIDTH,
		h = HUDTabGreedBar.HEIGHT,
		layer = params.layer or panel:layer()
	}
	self._object = panel:panel(panel_params)
end

-- Lines 66-108
function HUDTabGreedBar:_create_icons()
	local icons_panel_params = {
		name = "icons_panel",
		halign = "left",
		valign = "top",
		w = HUDTabGreedBar.ICONS_W,
		h = self._object:h()
	}
	self._icons_panel = self._object:panel(icons_panel_params)
	local frame_icon_params = {
		name = "frame_icon",
		valign = "center",
		halign = "center",
		layer = 10,
		texture = tweak_data.gui.icons[HUDTabGreedBar.FRAME_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTabGreedBar.FRAME_ICON].texture_rect
	}
	self._frame_icon = self._icons_panel:bitmap(frame_icon_params)

	self._frame_icon:set_center_x(self._icons_panel:w() / 2)
	self._frame_icon:set_center_y(self._icons_panel:h() / 2)

	local loot_icon_params = {
		name = "loot_icon",
		valign = "center",
		halign = "center",
		layer = 10,
		texture = tweak_data.gui.icons[HUDTabGreedBar.LOOT_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTabGreedBar.LOOT_ICON].texture_rect
	}
	self._loot_icon = self._icons_panel:bitmap(loot_icon_params)

	self._loot_icon:set_center_x(self._icons_panel:w() / 2)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)

	local gold_icon_params = {
		name = "gold_icon",
		valign = "center",
		halign = "center",
		alpha = 0,
		layer = 10,
		texture = tweak_data.gui.icons[HUDTabGreedBar.GOLD_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTabGreedBar.GOLD_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_gold
	}
	self._gold_icon = self._icons_panel:bitmap(gold_icon_params)

	self._gold_icon:set_center_x(self._icons_panel:w() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
end

-- Lines 110-119
function HUDTabGreedBar:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		halign = "right",
		valign = "top",
		w = self._object:w() - self._icons_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 121-135
function HUDTabGreedBar:_create_title()
	local title_params = {
		vertical = "center",
		name = "tab_greed_bar_title",
		align = "center",
		w = self._right_panel:w(),
		h = HUDTabGreedBar.TITLE_H,
		font = tweak_data.gui:get_font_path(HUDTabGreedBar.TITLE_FONT, HUDTabGreedBar.TITLE_FONT_SIZE),
		font_size = HUDTabGreedBar.TITLE_FONT_SIZE,
		color = HUDTabGreedBar.TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(HUDTabGreedBar.TITLE_STRING))
	}
	self._title = self._right_panel:text(title_params)

	self._title:set_center_x(self._right_panel:w() / 2)
	self._title:set_center_y(32)
end

-- Lines 137-170
function HUDTabGreedBar:_create_bar()
	local progress_bar_background_params = {
		name = "tab_greed_progress_bar_background",
		layer = 1,
		w = HUDTabGreedBar.LOOT_BAR_W,
		left = HUDTabGreedBar.LOOT_BAR_ICON_L,
		center = HUDTabGreedBar.LOOT_BAR_ICON_M,
		right = HUDTabGreedBar.LOOT_BAR_ICON_R,
		color = HUDTabGreedBar.LOOT_BAR_COLOR
	}
	self._progress_bar_background = RaidGUIControlThreeCutBitmap:new(self._right_panel, progress_bar_background_params)

	self._progress_bar_background:set_center_y(64)

	local progress_bar_progress_panel_params = {
		name = "tab_progress_bar_progress_panel",
		w = self._progress_bar_background:w(),
		h = self._progress_bar_background:h(),
		layer = self._progress_bar_background:layer() + 1
	}
	self._progress_bar_progress_panel = self._right_panel:panel(progress_bar_progress_panel_params)

	self._progress_bar_progress_panel:set_x(self._progress_bar_background:x())
	self._progress_bar_progress_panel:set_center_y(self._progress_bar_background:center_y())

	local progress_bar_foreground_params = {
		name = "tab_loot_bar_foreground",
		alpha = 0,
		w = self._progress_bar_background:w(),
		left = HUDTabGreedBar.LOOT_BAR_ICON_L,
		center = HUDTabGreedBar.LOOT_BAR_ICON_M,
		right = HUDTabGreedBar.LOOT_BAR_ICON_R,
		color = HUDTabGreedBar.LOOT_BAR_FOREGROUND_COLOR
	}
	self._loot_bar_foreground = RaidGUIControlThreeCutBitmap:new(self._progress_bar_progress_panel, progress_bar_foreground_params)
end

-- Lines 172-186
function HUDTabGreedBar:_create_counter()
	local counter_params = {
		vertical = "center",
		name = "tab_greed_bar_counter",
		align = "right",
		text = "0",
		w = self._right_panel:w(),
		h = HUDTabGreedBar.COUNTER_H,
		font = tweak_data.gui:get_font_path(HUDTabGreedBar.COUNTER_FONT, HUDTabGreedBar.COUNTER_FONT_SIZE),
		font_size = HUDTabGreedBar.COUNTER_FONT_SIZE,
		color = HUDTabGreedBar.COUNTER_COLOR
	}
	self._counter = self._right_panel:text(counter_params)

	self._counter:set_right(self._right_panel:w())
	self._counter:set_center_y(self._progress_bar_background:center_y())
end

-- Lines 188-205
function HUDTabGreedBar:_create_tutorialization()
	local tutorialization_params = {
		wrap = true,
		name = "tab_greed_tutorialization",
		y = self._object:h(),
		w = self._object:w(),
		font = tweak_data.gui:get_font_path(HUDTabGreedBar.TUTORIALIZATION_FONT, HUDTabGreedBar.TUTORIALIZATION_FONT_SIZE),
		font_size = HUDTabGreedBar.TUTORIALIZATION_FONT_SIZE,
		color = HUDTabGreedBar.TUTORIALIZATION_COLOR,
		text = managers.localization:text(HUDTabGreedBar.TUTORIALIZATION_STRING)
	}
	self._tutorialization = self._object:text(tutorialization_params)
	local _, _, _, h = self._tutorialization:text_rect()

	self._tutorialization:set_h(h)
	self._object:set_h(self._icons_panel:h() + h)
end

-- Lines 207-216
function HUDTabGreedBar:change_progress(old_progress, new_progress)
	self._updated_progress = new_progress

	if not self._animating_progress_change then
		self._current_progress = old_progress

		self._progress_bar_progress_panel:stop()
		self._progress_bar_progress_panel:animate(callback(self, self, "_animate_change_progress"))
	end
end

-- Lines 218-220
function HUDTabGreedBar:set_current_greed_amount(amount)
	self:set_progress(amount % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar())
end

-- Lines 222-225
function HUDTabGreedBar:set_progress(progress)
	self._progress_bar_progress_panel:set_w(self._progress_bar_background:w() * progress)
	self._loot_bar_foreground:set_alpha(1)
end

-- Lines 227-248
function HUDTabGreedBar:reset_state()
	self._frame_icon:stop()
	self._frame_icon:set_w(tweak_data.gui:icon_w(HUDTabGreedBar.FRAME_ICON))
	self._frame_icon:set_h(tweak_data.gui:icon_h(HUDTabGreedBar.FRAME_ICON))
	self._frame_icon:set_center_x(self._icons_panel:w() / 2)
	self._frame_icon:set_center_y(self._icons_panel:h() / 2)
	self._frame_icon:set_color(Color.white)
	self._icons_panel:stop()
	self._loot_icon:set_alpha(1)
	self._gold_icon:set_alpha(0)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
	self._counter:stop()
	self._counter:set_center_y(self._progress_bar_background:center_y())
	self._counter:set_color(HUDTabGreedBar.COUNTER_COLOR)
	self._counter:set_text("0")

	self._gold_bars_obtained_in_mission = 0

	self:set_current_greed_amount(managers.greed:current_loot_counter())
end

-- Lines 250-276
function HUDTabGreedBar:_animate_change_progress(o)
	self._animating_progress_change = true
	local points_per_second = 120
	local t = 0

	while self._updated_progress - self._current_progress > 0 do
		local dt = coroutine.yield()
		t = t + dt
		self._current_progress = self._current_progress + points_per_second * dt
		local current_percentage = self._current_progress % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar()

		self:set_progress(current_percentage)

		if self._previous_percentage and current_percentage < self._previous_percentage then
			self:_acquire_gold_bar()
		end

		self._previous_percentage = current_percentage
	end

	local current_percentage = self._updated_progress % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar()

	self:set_progress(current_percentage)

	self._current_progress = self._updated_progress
	self._animating_progress_change = false
end

-- Lines 278-291
function HUDTabGreedBar:_acquire_gold_bar()
	self._gold_bars_obtained_in_mission = self._gold_bars_obtained_in_mission + 1

	self._icons_panel:stop()
	self._icons_panel:animate(callback(self, self, "_animate_gold_bar"))

	if not self._pulsing then
		self._frame_icon:stop()
		self._frame_icon:animate(callback(self, self, "_animate_pulse"))
	end

	self._counter:stop()
	self._counter:animate(callback(self, self, "_animate_counter_increase"))
end

-- Lines 293-314
function HUDTabGreedBar:_animate_counter_increase(o)
	local duration = 0.5
	local t = 0

	self._counter:set_text(tostring(self._gold_bars_obtained_in_mission))

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in(t, HUDTabGreedBar.COUNTER_OFFSET, -HUDTabGreedBar.COUNTER_OFFSET, duration)

		self._counter:set_center_y(self._progress_bar_background:center_y() - current_offset)

		local current_r = Easing.quartic_in(t, HUDTabGreedBar.COUNTER_INCREASE_COLOR.r, HUDTabGreedBar.COUNTER_COLOR.r - HUDTabGreedBar.COUNTER_INCREASE_COLOR.r, duration)
		local current_g = Easing.quartic_in(t, HUDTabGreedBar.COUNTER_INCREASE_COLOR.g, HUDTabGreedBar.COUNTER_COLOR.g - HUDTabGreedBar.COUNTER_INCREASE_COLOR.g, duration)
		local current_b = Easing.quartic_in(t, HUDTabGreedBar.COUNTER_INCREASE_COLOR.b, HUDTabGreedBar.COUNTER_COLOR.b - HUDTabGreedBar.COUNTER_INCREASE_COLOR.b, duration)

		self._counter:set_color(Color(current_r, current_g, current_b))
	end

	self._counter:set_center_y(self._progress_bar_background:center_y())
	self._counter:set_color(HUDTabGreedBar.COUNTER_COLOR)
end

-- Lines 316-346
function HUDTabGreedBar:_animate_pulse(o)
	self._pulsing = true
	local frame_default_w = tweak_data.gui:icon_w(HUDTabGreedBar.FRAME_ICON)
	local frame_default_h = tweak_data.gui:icon_h(HUDTabGreedBar.FRAME_ICON)
	local duration_in = 0.5
	local t = 0

	while true do
		while t < duration_in do
			local dt = coroutine.yield()
			t = t + dt
			local current_frame_scale = Easing.quartic_out(t, 1.4, -0.4, duration_in)

			self._frame_icon:set_w(frame_default_w * current_frame_scale)
			self._frame_icon:set_h(frame_default_h * current_frame_scale)
			self._frame_icon:set_center_x(self._icons_panel:w() / 2)
			self._frame_icon:set_center_y(self._icons_panel:h() / 2)

			local current_r = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.r, tweak_data.gui.colors.raid_gold.r - tweak_data.gui.colors.raid_light_gold.r, duration_in)
			local current_g = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.g, tweak_data.gui.colors.raid_gold.g - tweak_data.gui.colors.raid_light_gold.g, duration_in)
			local current_b = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.b, tweak_data.gui.colors.raid_gold.b - tweak_data.gui.colors.raid_light_gold.b, duration_in)

			self._frame_icon:set_color(Color(current_r, current_g, current_b))
		end

		local wait_time = HUDTabGreedBar.FRAME_PULSE_SPEEDS[math.clamp(self._gold_bars_obtained_in_mission, 1, #HUDTabGreedBar.FRAME_PULSE_SPEEDS)]

		wait(wait_time)

		t = 0
	end
end

-- Lines 348-407
function HUDTabGreedBar:_animate_gold_bar(o)
	self._animating_gold_bar = true
	local duration_in = 0.5
	local t = 0

	while duration_in > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in_out(t, 0, HUDTabGreedBar.ICON_HIDDEN_OFFSET, duration_in)
		local current_loot_icon_alpha = Easing.quartic_in_out(t, 1, -1, duration_in / 2)

		self._loot_icon:set_alpha(current_loot_icon_alpha)
		self._loot_icon:set_center_y(self._icons_panel:h() / 2 - current_offset)

		if t >= duration_in / 2 then
			local current_gold_icon_alpha = Easing.quartic_in_out(t - duration_in / 2, 0, 1, duration_in / 2)

			self._gold_icon:set_alpha(current_gold_icon_alpha)
		end

		self._gold_icon:set_center_y(self._icons_panel:h() / 2 + HUDTabGreedBar.ICON_HIDDEN_OFFSET - current_offset)
	end

	self._loot_icon:set_alpha(0)
	self._gold_icon:set_alpha(1)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
	wait(1.5)

	local duration_out = 0.7
	t = 0

	while duration_out > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in_out(t, 0, HUDTabGreedBar.ICON_HIDDEN_OFFSET, duration_in)
		local current_gold_icon_alpha = Easing.quartic_in_out(t, 1, -1, duration_in / 2)

		self._gold_icon:set_alpha(current_gold_icon_alpha)
		self._gold_icon:set_center_y(self._icons_panel:h() / 2 - current_offset)

		if t >= duration_in / 2 then
			local current_loot_icon_alpha = Easing.quartic_in_out(t - duration_in / 2, 0, 1, duration_in / 2)

			self._loot_icon:set_alpha(current_loot_icon_alpha)
		end

		self._loot_icon:set_center_y(self._icons_panel:h() / 2 + HUDTabGreedBar.ICON_HIDDEN_OFFSET - current_offset)
	end

	self._loot_icon:set_alpha(1)
	self._gold_icon:set_alpha(0)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
	wait(0.8)

	self._animating_gold_bar = false
end

-- Lines 409-411
function HUDTabGreedBar:set_right(right)
	self._object:set_right(right)
end
