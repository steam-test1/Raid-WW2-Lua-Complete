GreedLootScreenGui = GreedLootScreenGui or class(RaidGuiBase)
GreedLootScreenGui.CENTRAL_LOOT_IMAGE = "loot_greed_items"
GreedLootScreenGui.FRAME_ICON = "rewards_extra_loot_frame"
GreedLootScreenGui.LOOT_ICON = "rewards_extra_loot_middle_loot"
GreedLootScreenGui.GOLD_ICON = "rewards_extra_loot_middle_gold"
GreedLootScreenGui.TITLE_STRING = "menu_save_info_loot_title"
GreedLootScreenGui.LOOT_BAR_ICON_L = "loot_meter_parts_l"
GreedLootScreenGui.LOOT_BAR_ICON_M = "loot_meter_parts_m"
GreedLootScreenGui.LOOT_BAR_ICON_R = "loot_meter_parts_r"
GreedLootScreenGui.LOOT_BAR_COLOR = tweak_data.gui.colors.raid_dark_grey
GreedLootScreenGui.LOOT_BAR_FOREGROUND_COLOR = tweak_data.gui.colors.raid_gold
GreedLootScreenGui.REWARD_QUANTITY_FEW = 3
GreedLootScreenGui.REWARD_QUANTITY_MANY = 10
GreedLootScreenGui.GOLD_ICON_SINGLE = "gold_bar_single"
GreedLootScreenGui.GOLD_ICON_FEW = "gold_bar_3"
GreedLootScreenGui.GOLD_ICON_MANY = "gold_bar_box"
GreedLootScreenGui.ICON_HIDDEN_OFFSET = 60
GreedLootScreenGui.COUNTER_H = 32
GreedLootScreenGui.COUNTER_FONT = tweak_data.gui.fonts.din_compressed
GreedLootScreenGui.COUNTER_FONT_SIZE = tweak_data.gui.font_sizes.size_18
GreedLootScreenGui.COUNTER_COLOR = tweak_data.gui.colors.raid_dark_grey
GreedLootScreenGui.COUNTER_OFFSET = 6
GreedLootScreenGui.COUNTER_INCREASE_COLOR = tweak_data.gui.colors.raid_gold
GreedLootScreenGui.TITLE_DESCRIPTION_Y = 690
GreedLootScreenGui.TITLE_DESCRIPTION_H = 50
GreedLootScreenGui.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
GreedLootScreenGui.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
GreedLootScreenGui.TITLE_PADDING_TOP = -14
GreedLootScreenGui.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
GreedLootScreenGui.TITLE_COLOR = tweak_data.gui.colors.raid_red
GreedLootScreenGui.DESCRIPTION_Y = 304
GreedLootScreenGui.DESCRIPTION_W = 416
GreedLootScreenGui.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
GreedLootScreenGui.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
GreedLootScreenGui.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
GreedLootScreenGui.ITEM_TYPE_H = 64
GreedLootScreenGui.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
GreedLootScreenGui.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white

-- Lines 51-63
function GreedLootScreenGui:init(ws, fullscreen_ws, node, component_name)
	print("[GreedLootScreenGui:init()]")

	self._closing = false
	self.current_state = game_state_machine:current_state()

	GreedLootScreenGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_greed_loot_title")
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._greed_counter_before_mission, self._greed_counter_in_mission = managers.greed:cache()

	self:_set_progress(self._greed_counter_before_mission)
end

-- Lines 66-82
function GreedLootScreenGui:_layout()
	GreedLootScreenGui.super._layout(self)
	self:_create_fullscreen_panel()
	self:_create_flares()
	self:_create_loot_image()
	self:_create_greed_bar()
	self:_create_second_panel()
	self:_create_gold_bar_image()
	self:_create_description_panel()
	self:bind_controller_inputs()
	self._loot_image:stop()
	self._loot_image:animate(callback(self, self, "_animate_giving_points"))
end

-- Lines 84-87
function GreedLootScreenGui:_create_fullscreen_panel()
	self._full_workspace = Overlay:gui():create_screen_workspace()
	self._fullscreen_panel = self._full_workspace:panel()
end

-- Lines 89-148
function GreedLootScreenGui:_create_flares()
	local flare_panel_params = {
		layer = 1,
		name = "loot_screen_flare_panel"
	}
	self._flare_panel = self._fullscreen_panel:panel(flare_panel_params)
	local flare_center_x = self._flare_panel:w() / 2 + 200
	local flare_center_y = self._flare_panel:h() / 2
	local lens_glint_params = {
		blend_mode = "add",
		name = "loot_screen_glint",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_glint.texture,
		texture_rect = tweak_data.gui.icons.lens_glint.texture_rect
	}
	self._lens_glint = self._flare_panel:bitmap(lens_glint_params)

	self._lens_glint:set_center(flare_center_x, flare_center_y)

	local lens_iris_params = {
		blend_mode = "add",
		name = "loot_screen_iris",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_iris.texture,
		texture_rect = tweak_data.gui.icons.lens_iris.texture_rect
	}
	self._lens_iris = self._flare_panel:bitmap(lens_iris_params)

	self._lens_iris:set_center(flare_center_x, flare_center_y)

	local lens_orbs_params = {
		blend_mode = "add",
		name = "loot_screen_orbs",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_orbs.texture,
		texture_rect = tweak_data.gui.icons.lens_orbs.texture_rect
	}
	self._lens_orbs = self._flare_panel:bitmap(lens_orbs_params)

	self._lens_orbs:set_center(flare_center_x, flare_center_y)

	local lens_shimmer_params = {
		blend_mode = "add",
		name = "loot_screen_shimmer",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_shimmer.texture,
		texture_rect = tweak_data.gui.icons.lens_shimmer.texture_rect
	}
	self._lens_shimmer = self._flare_panel:bitmap(lens_shimmer_params)

	self._lens_shimmer:set_center(flare_center_x, flare_center_y)

	local lens_spike_ball_params = {
		blend_mode = "add",
		name = "loot_screen_spike_ball",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_spike_ball.texture,
		texture_rect = tweak_data.gui.icons.lens_spike_ball.texture_rect
	}
	self._lens_spike_ball = self._flare_panel:bitmap(lens_spike_ball_params)

	self._lens_spike_ball:set_center(flare_center_x, flare_center_y)
end

-- Lines 150-160
function GreedLootScreenGui:_create_loot_image()
	local loot_image_params = {
		name = "loot_image",
		layer = 15,
		texture = tweak_data.gui.icons[GreedLootScreenGui.CENTRAL_LOOT_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[GreedLootScreenGui.CENTRAL_LOOT_IMAGE].texture_rect
	}
	self._loot_image = self._root_panel:bitmap(loot_image_params)

	self._loot_image:set_center_x(self._root_panel:w() / 2 + 26)
	self._loot_image:set_center_y(self._root_panel:h() / 2)
end

-- Lines 162-266
function GreedLootScreenGui:_create_greed_bar()
	local greed_bar_panel_params = {
		halign = "center",
		name = "greed_bar_panel",
		h = 160,
		y = 32,
		w = 642,
		valign = "top"
	}
	self._greed_bar_panel = self._root_panel:panel(greed_bar_panel_params)

	self._greed_bar_panel:set_center_x(self._root_panel:w() / 2)

	local frame_params = {
		name = "frame",
		texture = tweak_data.gui.icons[GreedLootScreenGui.FRAME_ICON].texture,
		texture_rect = tweak_data.gui.icons[GreedLootScreenGui.FRAME_ICON].texture_rect
	}
	self._frame = self._greed_bar_panel:bitmap(frame_params)

	self._frame:set_center_x(self._greed_bar_panel:w() / 2)
	self._frame:set_center_y(self._greed_bar_panel:h() / 2)

	local loot_icon_params = {
		name = "loot_icon",
		texture = tweak_data.gui.icons[GreedLootScreenGui.LOOT_ICON].texture,
		texture_rect = tweak_data.gui.icons[GreedLootScreenGui.LOOT_ICON].texture_rect
	}
	self._loot_icon = self._greed_bar_panel:bitmap(loot_icon_params)

	self._loot_icon:set_center_x(self._greed_bar_panel:w() / 2)
	self._loot_icon:set_center_y(self._greed_bar_panel:h() / 2)

	local gold_icon_params = {
		name = "gold_icon",
		alpha = 0,
		texture = tweak_data.gui.icons[GreedLootScreenGui.GOLD_ICON].texture,
		texture_rect = tweak_data.gui.icons[GreedLootScreenGui.GOLD_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_gold
	}
	self._gold_icon = self._greed_bar_panel:bitmap(gold_icon_params)

	self._gold_icon:set_center_x(self._greed_bar_panel:w() / 2)
	self._gold_icon:set_center_y(self._greed_bar_panel:h() / 2)

	local loot_title_params = {
		name = "loot_title",
		vertical = "center",
		h = 64,
		align = "center",
		halign = "left",
		valign = "center",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_56),
		font_size = tweak_data.gui.font_sizes.size_56,
		color = tweak_data.gui.colors.raid_dirty_white,
		text = utf8.to_upper(managers.localization:text(GreedLootScreenGui.TITLE_STRING))
	}
	self._title = self._greed_bar_panel:text(loot_title_params)

	self._title:set_center_x(self._greed_bar_panel:w() * 3 / 4)
	self._title:set_center_y(self._greed_bar_panel:h() / 2 - 16)

	local progress_bar_background_params = {
		name = "greed_loot_menu_progress_bar_background",
		layer = 1,
		w = 160,
		left = GreedLootScreenGui.LOOT_BAR_ICON_L,
		center = GreedLootScreenGui.LOOT_BAR_ICON_M,
		right = GreedLootScreenGui.LOOT_BAR_ICON_R,
		color = GreedLootScreenGui.LOOT_BAR_COLOR
	}
	self._progress_bar_background = self._greed_bar_panel:three_cut_bitmap(progress_bar_background_params)

	self._progress_bar_background:set_center_x(self._greed_bar_panel:w() * 3 / 4)
	self._progress_bar_background:set_center_y(self._greed_bar_panel:h() / 2 + 32)

	local progress_bar_progress_panel_params = {
		name = "progress_bar_progress_panel",
		w = self._progress_bar_background:w(),
		h = self._progress_bar_background:h(),
		layer = self._progress_bar_background:layer() + 1
	}
	self._progress_bar_progress_panel = self._greed_bar_panel:panel(progress_bar_progress_panel_params)

	self._progress_bar_progress_panel:set_x(self._progress_bar_background:x())
	self._progress_bar_progress_panel:set_center_y(self._progress_bar_background:center_y())

	local progress_bar_foreground_params = {
		name = "loot_bar_foreground",
		alpha = 0,
		w = self._progress_bar_background:w(),
		left = GreedLootScreenGui.LOOT_BAR_ICON_L,
		center = GreedLootScreenGui.LOOT_BAR_ICON_M,
		right = GreedLootScreenGui.LOOT_BAR_ICON_R,
		color = GreedLootScreenGui.LOOT_BAR_FOREGROUND_COLOR
	}
	self._loot_bar_foreground = self._progress_bar_progress_panel:three_cut_bitmap(progress_bar_foreground_params)
	local counter_params = {
		name = "greed_bar_counter",
		vertical = "center",
		align = "left",
		text = "0",
		x = self._progress_bar_progress_panel:right() + 10,
		h = GreedLootScreenGui.COUNTER_H,
		font = GreedLootScreenGui.COUNTER_FONT,
		font_size = GreedLootScreenGui.COUNTER_FONT_SIZE,
		color = GreedLootScreenGui.COUNTER_COLOR
	}
	self._counter = self._greed_bar_panel:text(counter_params)

	self._counter:set_center_y(self._progress_bar_background:center_y())
end

-- Lines 268-273
function GreedLootScreenGui:_create_second_panel()
	local second_panel_params = {
		name = "second_panel"
	}
	self._second_panel = self._root_panel:panel(second_panel_params)
end

-- Lines 275-316
function GreedLootScreenGui:_create_gold_bar_image()
	local gold_bar_image_params = {
		name = "central_gold_bar_image",
		alpha = 0,
		texture = tweak_data.gui.icons[GreedLootScreenGui.GOLD_ICON_SINGLE].texture,
		texture_rect = tweak_data.gui.icons[GreedLootScreenGui.GOLD_ICON_SINGLE].texture_rect
	}
	self._central_gold_bar_image = self._second_panel:bitmap(gold_bar_image_params)

	self._central_gold_bar_image:set_center_x(self._second_panel:w() / 2)
	self._central_gold_bar_image:set_center_y(self._second_panel:h() / 2 - 80)

	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		y = GreedLootScreenGui.TITLE_DESCRIPTION_Y,
		h = GreedLootScreenGui.TITLE_DESCRIPTION_H,
		font = GreedLootScreenGui.COUNTER_FONT,
		font_size = GreedLootScreenGui.TITLE_DESCRIPTION_FONT_SIZE,
		color = GreedLootScreenGui.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._second_panel:text(title_description_params)
	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		vertical = "top",
		name = "gold_bars_name",
		alpha = 0,
		align = "center",
		text = "GOLD BAR",
		y = self._title_description:y() + self._title_description:h() + GreedLootScreenGui.TITLE_PADDING_TOP,
		font = GreedLootScreenGui.COUNTER_FONT,
		font_size = GreedLootScreenGui.TITLE_FONT_SIZE,
		color = GreedLootScreenGui.TITLE_COLOR
	}
	self._gold_bar_value = self._second_panel:text(title_params)

	self:_layout_gold_bar_value_text()
end

-- Lines 318-377
function GreedLootScreenGui:_create_description_panel()
	local description_panel_params = {
		alpha = 0,
		name = "description_panel",
		halign = "right",
		w = 416,
		valign = "scale",
		h = self._second_panel:h()
	}
	self._description_panel = self._second_panel:panel(description_panel_params)

	self._description_panel:set_right(self._second_panel:w())

	local item_type_params = {
		name = "item_type",
		vertical = "center",
		align = "left",
		halign = "left",
		valign = "center",
		h = GreedLootScreenGui.ITEM_TYPE_H,
		font = GreedLootScreenGui.COUNTER_FONT,
		font_size = GreedLootScreenGui.ITEM_TYPE_FONT_SIZE,
		color = GreedLootScreenGui.ITEM_TYPE_COLOR,
		text = self:translate("menu_loot_screen_gold_bars_type", true)
	}
	local item_type = self._description_panel:text(item_type_params)
	local item_type_description_params = {
		name = "item_type_description",
		vertical = "top",
		wrap = true,
		align = "left",
		halign = "left",
		valign = "center",
		font = GreedLootScreenGui.DESCRIPTION_FONT,
		font_size = GreedLootScreenGui.DESCRIPTION_FONT_SIZE,
		color = GreedLootScreenGui.DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_gold_bars_description", false)
	}
	local item_type_description = self._description_panel:text(item_type_description_params)
	local _, _, _, h = item_type_description:text_rect()

	item_type_description:set_h(h)
	item_type_description:set_bottom(self._description_panel:h() / 2 - 54)
	item_type:set_bottom(item_type_description:y() - 14)

	local greed_bar_params = {
		y = 464
	}
	self._second_panel_greed_bar = HUDTabGreedBar:new(self._description_panel, greed_bar_params)
	local greed_description_params = {
		name = "greed_description_params",
		vertical = "top",
		wrap = true,
		align = "left",
		halign = "left",
		valign = "center",
		font = GreedLootScreenGui.DESCRIPTION_FONT,
		font_size = GreedLootScreenGui.DESCRIPTION_FONT_SIZE,
		color = GreedLootScreenGui.DESCRIPTION_COLOR,
		text = self:translate("menu_greed_description", false)
	}
	local greed_description = self._description_panel:text(greed_description_params)
	local _, _, _, h = greed_description:text_rect()

	greed_description:set_h(h)
	greed_description:set_y(self._second_panel_greed_bar._object:bottom())
end

-- Lines 379-389
function GreedLootScreenGui:_set_progress(points)
	self._current_points = points
	local current_percentage = self._current_points % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar()

	self._progress_bar_progress_panel:set_w(self._progress_bar_background:w() * current_percentage)
	self._loot_bar_foreground:set_alpha(1)
	self._second_panel_greed_bar:set_progress(current_percentage)

	return current_percentage
end

-- Lines 391-396
function GreedLootScreenGui:_layout_gold_bar_value_text()
	local _, _, w, _ = self._gold_bar_value:text_rect()

	self._gold_bar_value:set_w(w)
	self._gold_bar_value:set_center_x(self._second_panel:w() / 2)
	self._title_description:set_x(self._gold_bar_value:x())
end

-- Lines 400-436
function GreedLootScreenGui:_animate_giving_points()
	local t = 0
	local duration = 2
	self._gold_bars_added = 0
	local sound_on_point_value = {}

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_progress = Easing.quintic_in_out(t, self._greed_counter_before_mission, self._greed_counter_in_mission, duration)

		if math.floor(current_progress - self._greed_counter_before_mission) % 4 == 0 and not sound_on_point_value[math.floor(current_progress - self._greed_counter_before_mission)] then
			managers.menu_component:post_event("one_number_one_click")

			sound_on_point_value[math.floor(current_progress - self._greed_counter_before_mission)] = true
		end

		local percentage = self:_set_progress(current_progress)

		if self._last_percentage and percentage < self._last_percentage then
			self:_add_gold_bar()
		end

		self._last_percentage = percentage
	end

	wait(1)
	self._title:stop()
	self._title:animate(callback(self, self, "_animate_central_image_hide"))
	managers.menu_component:post_event("generic_loot_reward_sound")
	self._lens_iris:stop()
	self._lens_iris:animate(callback(self, self, "_animate_hide_lens_flares"))
	self._central_gold_bar_image:stop()
	self._central_gold_bar_image:animate(callback(self, self, "_animate_second_panel"))
end

-- Lines 438-466
function GreedLootScreenGui:_add_gold_bar()
	self._gold_bars_added = self._gold_bars_added + 1

	if not self._animating_lens_flare then
		self._lens_glint:stop()
		self._lens_glint:animate(callback(self, self, "_animate_lens_flares"))

		self._animating_lens_flare = true

		self._loot_icon:stop()
		self._loot_icon:animate(callback(self, self, "_animate_change_icon"))
	end

	self._counter:stop()
	self._counter:animate(callback(self, self, "_animate_counter_add_gold_bar"))
	managers.menu_component:post_event("greed_item_picked_up")
	self._gold_icon:stop()
	self._gold_icon:animate(callback(self, self, "_animate_pulse"))

	local text = ""

	if self._gold_bars_added == 1 then
		text = self:translate("menu_loot_screen_gold_bars_single", true)
	else
		text = (self._gold_bars_added or 0) .. " " .. self:translate("menu_loot_screen_gold_bars", true)
	end

	self._gold_bar_value:set_text(text)
	self:_layout_gold_bar_value_text()
end

-- Lines 468-513
function GreedLootScreenGui:_animate_lens_flares()
	local fade_in_duration = 1.1
	local t = 0
	local icon_w = self._lens_glint:w()
	local icon_h = self._lens_glint:h()

	while t < fade_in_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.65, fade_in_duration)

		self._lens_glint:set_alpha(current_alpha)
		self._lens_orbs:set_alpha(current_alpha)
		self._lens_shimmer:set_alpha(current_alpha)
		self._lens_spike_ball:set_alpha(current_alpha)

		local current_scale = Easing.quartic_in_out(t, 0.6, 0.4, fade_in_duration)

		self._lens_glint:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_orbs:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_shimmer:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_spike_ball:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_glint:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_orbs:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_shimmer:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_spike_ball:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_glint:rotate(math.random() * 0.06 + 0.1)
		self._lens_shimmer:rotate(math.random() * -0.08 - 0.13)
		self._lens_spike_ball:rotate(math.random() * 0.11 + 0.06)
	end

	while true do
		local dt = coroutine.yield()
		t = t + dt

		self._lens_glint:rotate(math.random() * 0.06 + 0.1)
		self._lens_shimmer:rotate(math.random() * -0.08 - 0.13)
		self._lens_spike_ball:rotate(math.random() * 0.11 + 0.06)
	end
end

-- Lines 515-546
function GreedLootScreenGui:_animate_hide_lens_flares()
	local fade_out_duration = 0.2
	local t = 0

	wait(0.1)

	local icon_w = self._lens_glint:w()
	local icon_h = self._lens_glint:h()

	while t < fade_out_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.65, -0.65, fade_out_duration)

		self._flare_panel:set_alpha(current_alpha)

		local current_scale = Easing.quartic_in_out(t, 1, -0.7, fade_out_duration)

		self._lens_glint:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_orbs:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_shimmer:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_spike_ball:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_glint:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_orbs:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_shimmer:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_spike_ball:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
	end

	self._flare_panel:set_alpha(0)
end

-- Lines 548-571
function GreedLootScreenGui:_animate_central_image_hide()
	local duration = 0.2
	local t = 0
	local initial_w, initial_h = self._loot_image:size()
	local center_x, center_y = self._loot_image:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local crate_alpha = Easing.quartic_in(t, 1, -1, duration)

		self._loot_image:set_alpha(crate_alpha)
		self._greed_bar_panel:set_alpha(crate_alpha)

		local crate_scale = Easing.quartic_in(t, 1, -0.4, duration)

		self._loot_image:set_size(initial_w * crate_scale, initial_h * crate_scale)
		self._loot_image:set_center_x(center_x)
		self._loot_image:set_center_y(center_y)
	end

	self._loot_image:set_alpha(0)
	self._greed_bar_panel:set_alpha(0)
end

-- Lines 573-595
function GreedLootScreenGui:_animate_counter_add_gold_bar()
	local duration = 0.5
	local t = 0

	self._counter:set_text(tostring(self._gold_bars_added))
	self._counter:set_color(GreedLootScreenGui.COUNTER_INCREASE_COLOR)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in(t, GreedLootScreenGui.COUNTER_OFFSET, -GreedLootScreenGui.COUNTER_OFFSET, duration)

		self._counter:set_center_y(self._progress_bar_background:center_y() - current_offset)
	end

	self._counter:set_center_y(self._progress_bar_background:center_y())
end

-- Lines 597-624
function GreedLootScreenGui:_animate_change_icon()
	local duration = 0.5
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quartic_in_out(t, 0, GreedLootScreenGui.ICON_HIDDEN_OFFSET, duration)
		local current_loot_icon_alpha = Easing.quartic_in_out(t, 1, -1, duration / 2)

		self._loot_icon:set_alpha(current_loot_icon_alpha)
		self._loot_icon:set_center_y(self._greed_bar_panel:h() / 2 - current_offset)

		if t >= duration / 2 then
			local current_gold_icon_alpha = Easing.quartic_in_out(t - duration / 2, 0, 1, duration / 2)

			self._gold_icon:set_alpha(current_gold_icon_alpha)
		end

		self._gold_icon:set_center_y(self._greed_bar_panel:h() / 2 + GreedLootScreenGui.ICON_HIDDEN_OFFSET - current_offset)
	end

	self._loot_icon:set_alpha(0)
	self._gold_icon:set_alpha(1)
	self._loot_icon:set_center_y(self._greed_bar_panel:h() / 2)
	self._gold_icon:set_center_y(self._greed_bar_panel:h() / 2)
end

-- Lines 626-648
function GreedLootScreenGui:_animate_pulse()
	local frame_default_w = tweak_data.gui:icon_w(GreedLootScreenGui.FRAME_ICON)
	local frame_default_h = tweak_data.gui:icon_h(GreedLootScreenGui.FRAME_ICON)
	local duration_in = 0.5
	local t = 0

	while duration_in > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_frame_scale = Easing.quartic_out(t, 1.4, -0.4, duration_in)

		self._frame:set_w(frame_default_w * current_frame_scale)
		self._frame:set_h(frame_default_h * current_frame_scale)
		self._frame:set_center_x(self._greed_bar_panel:w() / 2)
		self._frame:set_center_y(self._greed_bar_panel:h() / 2)

		local current_r = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.r, tweak_data.gui.colors.raid_gold.r - tweak_data.gui.colors.raid_light_gold.r, duration_in)
		local current_g = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.g, tweak_data.gui.colors.raid_gold.g - tweak_data.gui.colors.raid_light_gold.g, duration_in)
		local current_b = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.b, tweak_data.gui.colors.raid_gold.b - tweak_data.gui.colors.raid_light_gold.b, duration_in)

		self._frame:set_color(Color(current_r, current_g, current_b))
	end
end

-- Lines 650-713
function GreedLootScreenGui:_animate_second_panel()
	local duration = 1.9
	local t = 0
	local original_image_w, original_image_h = self._central_gold_bar_image:size()
	local center_x, center_y = self._central_gold_bar_image:center()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local gold_bar_value_y = self._gold_bar_value:y()
	local gold_bar_value_offset = 20
	local title_delay = 0
	local title_duration = 1
	local description_panel_offset = 50

	wait(0.15)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, image_duration)

		self._central_gold_bar_image:set_alpha(current_alpha)

		if t < image_duration then
			local current_scale = Easing.linear(t, 1.4, -0.35, image_duration)

			self._central_gold_bar_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif image_duration < t and t < image_duration + image_duration_slowdown then
			local current_scale = Easing.quartic_out(t - image_duration, 1.05, -0.05, image_duration_slowdown)

			self._central_gold_bar_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif t > image_duration + image_duration_slowdown then
			self._central_gold_bar_image:set_size(original_image_w, original_image_h)
		end

		self._central_gold_bar_image:set_center_x(center_x)
		self._central_gold_bar_image:set_center_y(center_y)

		if title_delay < t then
			local current_title_alpha = Easing.quartic_out(t - title_delay, 0, 1, title_duration)

			self._title_description:set_alpha(current_title_alpha)
			self._gold_bar_value:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, gold_bar_value_offset, -gold_bar_value_offset, title_duration)

			self._gold_bar_value:set_y(gold_bar_value_y - customization_name_current_offset)

			local current_description_panel_offset = Easing.quartic_out(t - title_delay, description_panel_offset, -description_panel_offset, title_duration)

			self._description_panel:set_right(self._second_panel:w() - current_description_panel_offset)
			self._description_panel:set_alpha(current_title_alpha)
		end
	end

	self._central_gold_bar_image:set_alpha(1)
	self._central_gold_bar_image:set_size(original_image_w, original_image_h)
	self._central_gold_bar_image:set_center_x(center_x)
	self._central_gold_bar_image:set_center_y(center_y)
	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._gold_bar_value:set_alpha(1)
	self._gold_bar_value:set_y(gold_bar_value_y)
end

-- Lines 721-745
function GreedLootScreenGui:close()
	self._root_panel:get_engine_panel():stop()
	self._loot_image:stop()
	self._title:stop()
	self._lens_iris:stop()
	self._central_gold_bar_image:stop()
	self._lens_glint:stop()
	self._loot_icon:stop()
	self._counter:stop()
	self._gold_icon:stop()

	if self._closing then
		return
	end

	self._closing = true

	if game_state_machine:current_state_name() == "event_complete_screen" then
		game_state_machine:current_state():continue()
	end

	Overlay:gui():destroy_workspace(self._full_workspace)
	GreedLootScreenGui.super.close(self)
end

-- Lines 748-750
function GreedLootScreenGui:on_escape()
	return true
end

-- Lines 752-767
function GreedLootScreenGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_continue_button_on_click")
		}
	}
	local legend = {
		controller = {
			"menu_legend_continue"
		},
		keyboard = {
			{
				key = "footer_continue",
				callback = callback(self, self, "_continue_button_on_click", nil)
			}
		}
	}

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

-- Lines 769-771
function GreedLootScreenGui:_continue_button_on_click()
	managers.raid_menu:close_menu()
end
