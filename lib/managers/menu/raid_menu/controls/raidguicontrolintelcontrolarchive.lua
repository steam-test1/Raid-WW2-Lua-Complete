RaidGUIControlIntelControlArchive = RaidGUIControlIntelControlArchive or class(RaidGUIControl)

-- Lines 3-26
function RaidGUIControlIntelControlArchive:init(parent, params)
	RaidGUIControlIntelControlArchive.super.init(self, parent, params)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._object = self._panel:panel(self._params)
	self._category_name = "control_archive"

	self:_layout()

	self._play_panel_inside = false
	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end

	self._disable_input_timer = 0
end

-- Lines 28-48
function RaidGUIControlIntelControlArchive:_layout()
	self._bg_image = self._object:bitmap({
		y = 0,
		visible = false,
		x = 0,
		w = tweak_data.gui.icons.intel_table_archive.texture_rect[3],
		h = tweak_data.gui.icons.intel_table_archive.texture_rect[4],
		texture = tweak_data.gui.icons.intel_table_archive.texture,
		texture_rect = tweak_data.gui.icons.intel_table_archive.texture_rect,
		layer = self._object:layer() + 1
	})
	self._image = self._object:bitmap({
		visible = false,
		h = 448,
		y = 128,
		w = 796,
		x = 112,
		layer = self._object:layer() + 2,
		texture = tweak_data.gui.icons.intel_table_archive.texture,
		texture_rect = tweak_data.gui.icons.intel_table_archive.texture_rect
	})
	self._play_panel = self._object:panel({
		visible = false,
		y = 0,
		x = 0,
		w = tweak_data.gui.icons.play_icon_outline.texture_rect[3],
		h = tweak_data.gui.icons.play_icon_outline.texture_rect[4],
		layer = self._object:layer() + 2
	})
	self._play_circle = self._play_panel:bitmap({
		visible = false,
		y = 0,
		x = 0,
		layer = self._object:layer() + 3,
		color = tweak_data.gui.colors.raid_dirty_white,
		texture = tweak_data.gui.icons.play_icon_outline.texture,
		texture_rect = tweak_data.gui.icons.play_icon_outline.texture_rect
	})
	self._play_icon = self._play_panel:bitmap({
		visible = false,
		y = 0,
		x = 0,
		layer = self._object:layer() + 4,
		texture = tweak_data.gui.icons.play_icon.texture,
		texture_rect = tweak_data.gui.icons.play_icon.texture_rect
	})
end

-- Lines 50-74
function RaidGUIControlIntelControlArchive:set_data(item_value)
	self._data = tweak_data.intel:get_item_data(self._category_name, item_value)

	self._bg_image:set_visible(true)
	self._image:set_image(self._data.texture)
	self._image:set_texture_rect(unpack(self._data.texture_rect))
	self._image:set_visible(true)
	self._play_panel:set_center_x(self._bg_image:w() / 2)
	self._play_panel:set_center_y(self._bg_image:h() / 2)
	self._play_panel:set_visible(true)
	self._play_circle:set_center_x(self._play_panel:w() / 2)
	self._play_circle:set_center_y(self._play_panel:h() / 2)
	self._play_circle:set_visible(true)
	self._play_icon:set_center_x(self._play_panel:w() / 2)
	self._play_icon:set_center_y(self._play_panel:h() / 2)
	self._play_icon:set_visible(true)
end

-- Lines 76-78
function RaidGUIControlIntelControlArchive:get_data()
	return self._data
end

-- Lines 80-85
function RaidGUIControlIntelControlArchive:mouse_released(o, button, x, y)
	if self._play_panel and self._play_panel:inside(x, y) and (not self._disable_input_timer or self._disable_input_timer and self._disable_input_timer == 0) then
		self:_play_video()
	end
end

-- Lines 87-105
function RaidGUIControlIntelControlArchive:mouse_moved(o, x, y)
	if self:inside(x, y) then
		if self._play_panel:inside(x, y) and not self._play_panel_inside then
			self._play_panel_inside = true

			self._play_panel:animate(callback(self, self, "_animate_play_button"))
			self._play_circle:set_color(tweak_data.gui.colors.raid_red)
		end

		if not self._play_panel:inside(x, y) and self._play_panel_inside then
			self._play_panel_inside = false

			self._play_panel:stop()
			self._play_circle:set_color(tweak_data.gui.colors.raid_dirty_white)
		end
	end

	return false
end

-- Lines 107-135
function RaidGUIControlIntelControlArchive:update(t, dt)
	if self._control_video and (self:is_playing() and self:is_skipped() or not self:is_playing()) then
		self._control_video:destroy()
		self._panel:remove(self._control_video)
		self._panel:remove_background()
		self._panel:remove(self._panel:child("disclaimer"))

		self._control_video = nil
		self._panel = nil

		self._safe_panel:child("press_any_key_prompt"):stop()
		self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))

		self._disable_input_timer = 0.5
	end

	if self._disable_input_timer and self._disable_input_timer > 0 then
		self._disable_input_timer = self._disable_input_timer - dt

		if self._disable_input_timer < 0 then
			self._disable_input_timer = 0
		end
	end
end

-- Lines 137-151
function RaidGUIControlIntelControlArchive:close()
	if self._control_video and self._panel then
		self._control_video:destroy()
		self._panel:remove(self._control_video)
		self._panel:remove_background()
		self._panel:remove(self._panel:child("disclaimer"))

		self._control_video = nil
		self._panel = nil

		self._safe_panel:child("press_any_key_prompt"):stop()
		self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))
	end
end

-- Lines 153-158
function RaidGUIControlIntelControlArchive:on_escape()
	if self:is_playing() then
		return true
	end
end

-- Lines 160-233
function RaidGUIControlIntelControlArchive:_animate_play_button()
	local duration = 0.1
	local t = 0
	local original_width = self._play_panel:w()
	local original_height = self._play_panel:h()
	local original_center_x = self._play_panel:center_x()
	local original_center_y = self._play_panel:center_y()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_size_modifier = Easing.quartic_in_out(t, 1, 0.1, duration)

		self._play_panel:set_w(original_width * current_size_modifier)
		self._play_panel:set_h(original_height * current_size_modifier)
		self._play_panel:set_center_x(original_center_x)
		self._play_panel:set_center_y(original_center_y)
		self._play_circle:set_w(original_width * current_size_modifier)
		self._play_circle:set_h(original_height * current_size_modifier)
		self._play_circle:set_center_x(original_width / 2 * current_size_modifier)
		self._play_circle:set_center_y(original_height / 2 * current_size_modifier)
		self._play_icon:set_w(original_width * current_size_modifier)
		self._play_icon:set_h(original_height * current_size_modifier)
		self._play_icon:set_center_x(original_width / 2 * current_size_modifier)
		self._play_icon:set_center_y(original_height / 2 * current_size_modifier)
	end

	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_size_modifier = Easing.quartic_in_out(t, 1.1, -0.1, duration)

		self._play_panel:set_w(original_width * current_size_modifier)
		self._play_panel:set_h(original_height * current_size_modifier)
		self._play_panel:set_center_x(original_center_x)
		self._play_panel:set_center_y(original_center_y)
		self._play_circle:set_w(original_width * current_size_modifier)
		self._play_circle:set_h(original_height * current_size_modifier)
		self._play_circle:set_center_x(original_width / 2 * current_size_modifier)
		self._play_circle:set_center_y(original_height / 2 * current_size_modifier)
		self._play_icon:set_w(original_width * current_size_modifier)
		self._play_icon:set_h(original_height * current_size_modifier)
		self._play_icon:set_center_x(original_width / 2 * current_size_modifier)
		self._play_icon:set_center_y(original_height / 2 * current_size_modifier)
	end

	self._play_panel:set_w(original_width)
	self._play_panel:set_h(original_height)
	self._play_panel:set_center_x(original_center_x)
	self._play_panel:set_center_y(original_center_y)
	self._play_circle:set_w(original_width)
	self._play_circle:set_h(original_height)
	self._play_circle:set_center_x(original_width / 2)
	self._play_circle:set_center_y(original_height / 2)
	self._play_icon:set_w(original_width)
	self._play_icon:set_h(original_height)
	self._play_icon:set_center_x(original_width / 2)
	self._play_icon:set_center_y(original_height / 2)
end

-- Lines 238-245
function RaidGUIControlIntelControlArchive:play_video()
	if not self:is_playing() then
		self._disable_input_timer = 0.1

		self:_play_video()
	end
end

-- Lines 247-302
function RaidGUIControlIntelControlArchive:_play_video()
	local gui = Overlay:gui()
	self._full_workspace = gui:create_screen_workspace()
	self._safe_rect_workspace = gui:create_screen_workspace()
	local full_panel = self._full_workspace:panel()
	local params_root_panel = {
		name = "control_video_root_panel",
		is_root_panel = true,
		x = full_panel:x(),
		y = full_panel:y(),
		h = full_panel:h(),
		w = full_panel:w(),
		layer = tweak_data.gui.DEBRIEF_VIDEO_LAYER + 10,
		background_color = Color.black
	}
	self._panel = RaidGUIPanel:new(full_panel, params_root_panel)
	local video = self._data.video_path
	local control_video_params = {
		name = "control_video",
		layer = self._panel:layer() + 1,
		video = video,
		width = self._panel:w()
	}
	self._control_video = self._panel:video(control_video_params)

	self._control_video:set_h(self._panel:w() * self._control_video:video_height() / self._control_video:video_width())
	self._control_video:set_center_y(self._panel:h() / 2)
	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	self._safe_panel = self._safe_rect_workspace:panel()
	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"
	local press_any_key_params = {
		name = "press_any_key_prompt",
		alpha = 0,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		text = utf8.to_upper(managers.localization:text(press_any_key_text)),
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._control_video:layer() + 100
	}
	local press_any_key_prompt = self._safe_panel:text(press_any_key_params)
	local _, _, w, h = press_any_key_prompt:text_rect()

	press_any_key_prompt:set_w(w)
	press_any_key_prompt:set_h(h)
	press_any_key_prompt:set_right(self._safe_panel:w() - 50)
	press_any_key_prompt:set_bottom(self._safe_panel:h() - 50)
	press_any_key_prompt:animate(callback(self, self, "_animate_show_press_any_key_prompt"))
end

-- Lines 304-306
function RaidGUIControlIntelControlArchive:is_playing()
	return self._control_video and self._control_video:loop_count() < 1
end

-- Lines 308-321
function RaidGUIControlIntelControlArchive:is_skipped()
	if self._disable_input_timer > 0 then
		return
	end

	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

-- Lines 323-338
function RaidGUIControlIntelControlArchive:_animate_show_press_any_key_prompt(prompt)
	local duration = 0.7
	local t = 0

	wait(6)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.75, duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.75)
end

-- Lines 340-373
function RaidGUIControlIntelControlArchive:_animate_change_press_any_key_prompt(prompt)
	local fade_out_duration = 0.25
	local t = (1 - prompt:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.75, -0.75, fade_out_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"

	prompt:set_text(utf8.to_upper(managers.localization:text(press_any_key_text)))

	local _, _, w, h = prompt:text_rect()

	prompt:set_w(w)
	prompt:set_h(h)
	prompt:set_right(self._safe_panel:w() - 50)

	local fade_in_duration = 0.25
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.75, fade_in_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.75)
end

-- Lines 375-382
function RaidGUIControlIntelControlArchive:on_controller_hotswap()
	local press_any_key_prompt = self._safe_panel:child("press_any_key_prompt")

	if press_any_key_prompt then
		press_any_key_prompt:stop()
		press_any_key_prompt:animate(callback(self, self, "_animate_change_press_any_key_prompt"))
	end
end

-- Lines 384-387
function RaidGUIControlIntelControlArchive:confirm_pressed()
	return true
end
