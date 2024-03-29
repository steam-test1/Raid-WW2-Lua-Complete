RaidMenuOptionsVideo = RaidMenuOptionsVideo or class(RaidGuiBase)

function RaidMenuOptionsVideo:init(ws, fullscreen_ws, node, component_name)
	RaidMenuOptionsVideo.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuOptionsVideo:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_video_subtitle")
end

function RaidMenuOptionsVideo:_layout()
	RaidMenuOptionsVideo.super._layout(self)

	self._fullscreen_only_controls = {}

	self:_layout_video()
	self:_load_video_values()
	self:_setup_control_visibility()
	self._stepper_menu_resolution:set_selected(true)
	self:bind_controller_inputs()
end

function RaidMenuOptionsVideo:close()
	self:_save_video_values()

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	RaidMenuOptionsVideo.super.close(self)
end

function RaidMenuOptionsVideo:_layout_video()
	local start_x = 0
	local start_y = 320
	local default_width = 512
	local previous_panel = nil
	local first_panel = "btn_advanced_options"
	previous_panel = {
		name = first_panel,
		x = start_x,
		y = start_y - 128,
		text = utf8.to_upper(managers.localization:text("menu_options_video_advanced_button")),
		on_click_callback = callback(self, self, "on_click_options_video_advanced_button"),
		on_menu_move = {
			down = "stepper_menu_resolution",
			up = "default_video"
		}
	}
	self._btn_advanced_options = self._root_panel:long_tertiary_button(previous_panel)
	previous_panel = {
		name = "stepper_menu_resolution",
		x = start_x,
		y = start_y,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_options_video_resolution")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_resolution"),
		on_item_selected_callback = callback(self, self, "on_item_selected_stepper_menu_resolution"),
		on_menu_move = {
			down = "apply_resolution",
			up = previous_panel.name
		}
	}
	self._stepper_menu_resolution = self._root_panel:stepper(previous_panel)

	self._stepper_menu_resolution:set_value_and_render({
		x = RenderSettings.resolution.x,
		y = RenderSettings.resolution.y,
		is_equal = function (self, check_x_y)
			if check_x_y.x == self.x and check_x_y.y == self.y then
				return true
			else
				return false
			end
		end
	}, true)

	local apply_resolution = {
		name = "apply_resolution",
		x = self._stepper_menu_resolution:w() + RaidGuiBase.PADDING,
		y = self._stepper_menu_resolution:y(),
		text = utf8.to_upper(managers.localization:text("menu_button_apply_resolution_refresh_rate")),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "on_click_apply_resolution_refresh_rate"),
		on_menu_move = {
			down = "stepper_menu_refresh_rate",
			up = previous_panel.name
		}
	}
	previous_panel.name = apply_resolution.name
	self._button_apply_video_resolution = self._root_panel:small_button(apply_resolution)
	previous_panel = {
		name = "stepper_menu_refresh_rate",
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_options_video_refresh_rate")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_refresh_rate"),
		on_item_selected_callback = callback(self, self, "on_item_selected_refresh_rate"),
		on_menu_move = {
			down = "window_mode",
			up = previous_panel.name
		}
	}
	self._stepper_menu_refresh_rate = self._root_panel:stepper(previous_panel)

	table.insert(self._fullscreen_only_controls, self._stepper_menu_refresh_rate)

	previous_panel = {
		name = "window_mode",
		stepper_w = 280,
		description = utf8.to_upper(managers.localization:text("menu_window_mode")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_window_mode"),
		on_item_selected_callback = callback(self, self, "on_item_selected_window_mode"),
		on_menu_move = {
			down = "effect_quality",
			up = previous_panel.name
		}
	}
	self._stepper_menu_window_mode = self._root_panel:stepper(previous_panel)
	previous_panel = {
		name = "effect_quality",
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_video_effect_quality")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		on_value_change_callback = callback(self, self, "on_value_change_effect_quality"),
		on_menu_move = {
			down = "progress_bar_menu_brightness",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_effect_quality = self._root_panel:slider(previous_panel)
	previous_panel = {
		name = "progress_bar_menu_brightness",
		value = 0,
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_video_brightness")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		on_value_change_callback = callback(self, self, "on_value_change_brightness"),
		on_menu_move = {
			down = "subtitle",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_brightness = self._root_panel:slider(previous_panel)

	table.insert(self._fullscreen_only_controls, self._progress_bar_menu_brightness)

	start_x = 704
	start_y = 320
	previous_panel = {
		name = "subtitle",
		description = utf8.to_upper(managers.localization:text("menu_options_video_subtitle")),
		x = start_x,
		y = start_y,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_subtitle"),
		on_menu_move = {
			down = "hit_confirm_indicator",
			up = previous_panel.name
		}
	}
	self._toggle_menu_subtitle = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		name = "hit_confirm_indicator",
		description = utf8.to_upper(managers.localization:text("menu_options_video_hit_confirm_indicator")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_hit_confirm_indicator"),
		on_click_callback = callback(self, self, "on_click_hit_indicator"),
		on_menu_move = {
			down = "hud_special_weapon_panels",
			up = previous_panel.name
		}
	}
	self._stepper_menu_hit_indicator = self._root_panel:stepper(previous_panel)
	previous_panel = {
		name = "hud_special_weapon_panels",
		description = utf8.to_upper(managers.localization:text("menu_options_video_hud_special_weapon_panels")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_hud_special_weapon_panels"),
		on_menu_move = {
			down = "motion_dot",
			up = previous_panel.name
		}
	}
	self._toggle_menu_hud_special_weapon_panels = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		name = "motion_dot",
		stepper_w = 280,
		description = utf8.to_upper(managers.localization:text("menu_options_video_motion_dot")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_motion_dot"),
		on_item_selected_callback = callback(self, self, "on_click_motion_dot"),
		on_menu_move = {
			down = "motion_dot_size",
			up = previous_panel.name
		}
	}
	self._stepper_menu_motion_dot = self._root_panel:stepper(previous_panel)
	previous_panel = {
		name = "motion_dot_size",
		stepper_w = 280,
		description = utf8.to_upper(managers.localization:text("menu_options_video_motion_dot_size")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_motion_dot_size"),
		on_item_selected_callback = callback(self, self, "on_click_motion_dot_size"),
		on_menu_move = {
			down = "use_headbob",
			up = previous_panel.name
		}
	}
	self._stepper_menu_motion_dot_size = self._root_panel:stepper(previous_panel)
	previous_panel = {
		name = "use_headbob",
		description = utf8.to_upper(managers.localization:text("menu_options_video_use_headbob")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_headbob"),
		on_menu_move = {
			down = "use_camera_accel",
			up = previous_panel.name
		}
	}
	self._toggle_menu_headbob = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		name = "use_camera_accel",
		description = utf8.to_upper(managers.localization:text("menu_options_video_use_camera_accel")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_camera_accel"),
		on_menu_move = {
			down = "camera_shake",
			up = previous_panel.name
		}
	}
	self._toggle_menu_camera_accel = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		name = "camera_shake",
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_video_camera_shake")),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		on_value_change_callback = callback(self, self, "on_value_change_camera_shake"),
		on_menu_move = {
			down = "default_video",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_camera_shake = self._root_panel:slider(previous_panel)
	local default_video_settings_button = {
		name = "default_video",
		y = 832,
		x = 1472,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_default")),
		on_click_callback = callback(self, self, "on_click_default_video"),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_menu_move = {
			up = previous_panel.name,
			down = first_panel
		}
	}
	self._default_video_button = self._root_panel:long_secondary_button(default_video_settings_button)

	if managers.raid_menu:is_pc_controller() then
		self._default_video_button:show()
	else
		self._default_video_button:hide()
	end
end

function gcd(a, b)
	if b == 0 then
		return a
	end

	return gcd(b, a % b)
end

function RaidMenuOptionsVideo:data_source_stepper_menu_resolution()
	local temp_resolutions = {}

	for _, res in ipairs(RenderSettings.modes) do
		table.insert(temp_resolutions, res)
	end

	table.sort(temp_resolutions)

	local resolutions = {}

	for _, resolution in ipairs(temp_resolutions) do
		self:_add_distinct_resolution(resolution, resolutions)
	end

	local result = {}

	for _, resolution in ipairs(resolutions) do
		table.insert(result, {
			text = resolution.x .. " x " .. resolution.y,
			value = resolution,
			info = resolution.x .. " x " .. resolution.y
		})
	end

	return result
end

function RaidMenuOptionsVideo:data_source_stepper_menu_window_mode()
	local result = {}

	table.insert(result, {
		value = "WINDOWED",
		text = utf8.to_upper(managers.localization:text("menu_windowed")),
		info = utf8.to_upper(managers.localization:text("menu_windowed"))
	})
	table.insert(result, {
		value = "WINDOWED_FULLSCREEN",
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_windowed_fullscreen")),
		info = utf8.to_upper(managers.localization:text("menu_windowed_fullscreen"))
	})
	table.insert(result, {
		value = "FULLSCREEN",
		text = utf8.to_upper(managers.localization:text("menu_fullscreen")),
		info = utf8.to_upper(managers.localization:text("menu_fullscreen"))
	})

	return result
end

function RaidMenuOptionsVideo:on_item_selected_options_video_advanced_button()
end

function RaidMenuOptionsVideo:on_item_selected_stepper_menu_resolution()
	self._stepper_menu_refresh_rate:refresh_data(true)
	self:_setup_control_visibility()
end

function RaidMenuOptionsVideo:_add_distinct_resolution(res, resolutions)
	if #resolutions == 0 then
		table.insert(resolutions, {
			x = res.x,
			y = res.y
		})
	else
		local last_added_resolution = resolutions[#resolutions]

		if last_added_resolution.x ~= res.x or last_added_resolution.y ~= res.y then
			table.insert(resolutions, {
				x = res.x,
				y = res.y
			})
		end
	end
end

function RaidMenuOptionsVideo:_get_refresh_rates_for_resolution(resolution)
	local temp_resolutions = {}

	for _, res in ipairs(RenderSettings.modes) do
		table.insert(temp_resolutions, res)
	end

	table.sort(temp_resolutions)

	local result = {}

	for _, res in ipairs(temp_resolutions) do
		if res.x == resolution.x and res.y == resolution.y then
			table.insert(result, {
				text = res.z .. " Hz",
				value = res.z,
				info = res.z .. " Hz"
			})
		end
	end

	return result
end

function RaidMenuOptionsVideo:data_source_stepper_menu_refresh_rate()
	local current_resolution = self._stepper_menu_resolution:get_value()

	return self:_get_refresh_rates_for_resolution(current_resolution)
end

function RaidMenuOptionsVideo:data_source_stepper_menu_hit_confirm_indicator()
	local tb = {}

	for i = 1, #tweak_data.hit_indicator_modes do
		table.insert(tb, {
			text_id = "menu_options_video_hit_indicator_mode_" .. tostring(i),
			value = i,
			info = "menu_options_video_hit_indicator_mode_" .. tostring(i)
		})
	end

	return tb
end

function RaidMenuOptionsVideo:data_source_stepper_menu_motion_dot()
	local tb = {}

	for i = 1, #tweak_data.motion_dot_modes do
		table.insert(tb, {
			text_id = "menu_options_video_motion_dot_mode_" .. tostring(i),
			value = i,
			info = "menu_options_video_motion_dot_mode_" .. tostring(i)
		})
	end

	return tb
end

function RaidMenuOptionsVideo:data_source_stepper_menu_motion_dot_size()
	local tb = {}

	for i = 1, #tweak_data.motion_dot_modes do
		table.insert(tb, {
			text_id = "menu_options_video_motion_dot_size_" .. tostring(i),
			value = i,
			info = "menu_options_video_motion_dot_size_" .. tostring(i)
		})
	end

	return tb
end

function RaidMenuOptionsVideo:on_item_selected_refresh_rate()
end

function RaidMenuOptionsVideo:on_click_apply_resolution_refresh_rate()
	local selected_resolution = self._stepper_menu_resolution:get_value()
	local selected_refresh_rate = self._stepper_menu_refresh_rate:get_value()
	local resolution = Vector3(selected_resolution.x, selected_resolution.y, selected_refresh_rate)

	managers.menu:active_menu().callback_handler:change_resolution_raid(resolution)
end

function RaidMenuOptionsVideo:on_value_change_effect_quality()
	local effect_quality = self._progress_bar_menu_effect_quality:get_value() / 100

	managers.menu:active_menu().callback_handler:set_effect_quality_raid(effect_quality)
end

function RaidMenuOptionsVideo:on_value_change_brightness()
	local brightness = self._progress_bar_menu_brightness:get_value() / 100 + 0.5

	managers.menu:active_menu().callback_handler:set_brightness_raid(brightness)
end

function RaidMenuOptionsVideo:on_item_selected_window_mode()
	local mode = self._stepper_menu_window_mode:get_value()

	if mode == "WINDOWED" then
		self:set_fullscreen(false, managers.viewport:is_fullscreen(), false, managers.viewport:is_borderless())
	elseif mode == "WINDOWED_FULLSCREEN" then
		self:set_fullscreen(false, managers.viewport:is_fullscreen(), true, managers.viewport:is_borderless())
	else
		self:set_fullscreen(true, managers.viewport:is_fullscreen(), false, managers.viewport:is_borderless())
	end

	self:_setup_control_visibility()
end

function RaidMenuOptionsVideo:set_fullscreen(fullscreen, is_fullscreen, borderless, is_borderless)
	managers.menu:active_menu().callback_handler:toggle_fullscreen_raid(fullscreen, is_fullscreen, borderless, is_borderless, callback(self, self, "fullscreen_toggled_callback"))
	self:on_value_change_brightness()

	if borderless then
		local res = Application:monitor_resolution()

		self._stepper_menu_resolution:set_value_and_render({
			x = res.x,
			y = res.y,
			is_equal = function (self, check_x_y)
				if check_x_y.x == self.x and check_x_y.y == self.y then
					return true
				else
					return false
				end
			end
		}, true)
	end
end

function RaidMenuOptionsVideo:on_click_default_video()
	local callback_function = callback(self, self, "callback_default_video")
	local params = {
		title = managers.localization:text("dialog_reset_video_title"),
		message = managers.localization:text("dialog_reset_video_message"),
		callback = function ()
			managers.user:reset_video_setting_map()
			self:_load_video_values()
			callback_function()
		end
	}

	managers.menu:show_option_dialog(params)
end

function RaidMenuOptionsVideo:_get_default_resolution()
	local default_resolution = Vector3(tweak_data.gui.base_resolution.x, tweak_data.gui.base_resolution.y, tweak_data.gui.base_resolution.z)
	local supported_resolutions = self:data_source_stepper_menu_resolution()
	local resolution = supported_resolutions[1]

	for _, res in ipairs(supported_resolutions) do
		if res.value.x < default_resolution.x or res.value.x == default_resolution.x and res.value.y == default_resolution.y then
			local refresh_rates = self:_get_refresh_rates_for_resolution({
				x = res.value.x,
				y = res.value.y
			})
			resolution = Vector3(res.value.x, res.value.y, refresh_rates[#refresh_rates].value)
		end
	end

	return resolution
end

function RaidMenuOptionsVideo:callback_default_video()
	managers.menu:active_menu().callback_handler:set_fullscreen_default_raid_no_dialog()

	local resolution = self:_get_default_resolution()

	managers.menu:active_menu().callback_handler:set_resolution_default_raid_no_dialog(resolution)
	managers.menu:active_menu().callback_handler:_refresh_brightness()
	self._stepper_menu_resolution:set_value_and_render({
		x = resolution.x,
		y = resolution.y,
		is_equal = function (self, check_x_y)
			if check_x_y.x == self.x and check_x_y.y == self.y then
				return true
			else
				return false
			end
		end
	})
	self._stepper_menu_refresh_rate:set_value_and_render(resolution.z)
	self._stepper_menu_window_mode:set_value_and_render("FULLSCREEN")
	self:_setup_control_visibility()
end

function RaidMenuOptionsVideo:fullscreen_toggled_callback()
	self:_reload_video_and_adv_video_options()
	self:_setup_control_visibility()
end

function RaidMenuOptionsVideo:_setup_control_visibility()
	local is_fullscreen = self._stepper_menu_window_mode:get_value() == "FULLSCREEN"
	local is_borderless = self._stepper_menu_window_mode:get_value() == "WINDOWED_FULLSCREEN"

	for _, control in ipairs(self._fullscreen_only_controls) do
		control:set_enabled(is_fullscreen)
	end

	self._stepper_menu_resolution:set_enabled(not is_borderless)
	self._button_apply_video_resolution:set_enabled(not is_borderless)

	if not is_fullscreen and not is_borderless then
		self._btn_advanced_options._on_menu_move.down = "stepper_menu_resolution"
		self._stepper_menu_resolution._on_menu_move.down = "window_mode"
		self._stepper_menu_window_mode._on_menu_move.up = "stepper_menu_resolution"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "subtitle"
		self._toggle_menu_subtitle._on_menu_move.up = "effect_quality"
	elseif is_borderless then
		self._btn_advanced_options._on_menu_move.down = "window_mode"
		self._stepper_menu_window_mode._on_menu_move.up = "btn_advanced_options"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "subtitle"
		self._toggle_menu_subtitle._on_menu_move.up = "effect_quality"
	else
		self._btn_advanced_options._on_menu_move.down = "stepper_menu_resolution"
		self._stepper_menu_resolution._on_menu_move.down = "stepper_menu_refresh_rate"
		self._stepper_menu_window_mode._on_menu_move.up = "stepper_menu_refresh_rate"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "progress_bar_menu_brightness"
		self._toggle_menu_subtitle._on_menu_move.up = "progress_bar_menu_brightness"
	end
end

function RaidMenuOptionsVideo:_reload_video_and_adv_video_options()
	self:_load_video_values()
end

function RaidMenuOptionsVideo:_load_video_values()
	local is_fullscreen = managers.viewport:is_fullscreen()
	local is_borderless = managers.viewport:is_borderless()
	local subtitle = managers.user:get_setting("subtitle")
	local hud_special_weapon_panels = managers.user:get_setting("hud_special_weapon_panels")
	local objective_reminder = managers.user:get_setting("objective_reminder")
	local use_headbob = managers.user:get_setting("use_headbob")
	local use_camera_accel = managers.user:get_setting("use_camera_accel")
	local camera_shake = managers.user:get_setting("camera_shake")
	local effect_quality = managers.user:get_setting("effect_quality")
	local brightness = managers.user:get_setting("brightness")
	local resolution = RenderSettings.resolution

	self._stepper_menu_refresh_rate:set_value_and_render(resolution.z, true)

	if is_borderless then
		local monitor_res = Application:monitor_resolution()
		resolution = Vector3(monitor_res.x, monitor_res.y, self._stepper_menu_refresh_rate:get_value())
	end

	self._stepper_menu_resolution:set_value_and_render({
		x = resolution.x,
		y = resolution.y,
		is_equal = function (self, check_x_y)
			if check_x_y.x == self.x and check_x_y.y == self.y then
				return true
			else
				return false
			end
		end
	}, true)

	if is_fullscreen then
		self._stepper_menu_window_mode:set_value_and_render("FULLSCREEN", true)
	elseif is_borderless then
		self._stepper_menu_window_mode:set_value_and_render("WINDOWED_FULLSCREEN", true)
	else
		self._stepper_menu_window_mode:set_value_and_render("WINDOWED", true)
	end

	self._toggle_menu_subtitle:set_value_and_render(subtitle)
	self._toggle_menu_hud_special_weapon_panels:set_value_and_render(hud_special_weapon_panels)
	self._toggle_menu_headbob:set_value_and_render(use_headbob)
	self._toggle_menu_camera_accel:set_value_and_render(use_camera_accel)
	self._progress_bar_menu_camera_shake:set_value(camera_shake * 100)
	self._progress_bar_menu_effect_quality:set_value(effect_quality * 100)
	self._progress_bar_menu_brightness:set_value((brightness - 0.5) * 100)

	local motion_dot = managers.user:get_setting("motion_dot")

	self._stepper_menu_motion_dot:set_value_and_render(motion_dot)

	local motion_dot_size = managers.user:get_setting("motion_dot_size")

	self._stepper_menu_motion_dot_size:set_value_and_render(motion_dot_size)

	local hit_indicator = managers.user:get_setting("hit_indicator")

	if hit_indicator == true then
		hit_indicator = 2
	elseif hit_indicator == false then
		hit_indicator = 1
	end

	self._stepper_menu_hit_indicator:set_value_and_render(hit_indicator)
end

function RaidMenuOptionsVideo:_save_video_values()
	self:on_click_subtitle()
	self:on_click_hit_indicator()
	self:on_click_hud_special_weapon_panels()
	self:on_click_headbob()
	self:on_click_camera_accel()
	self:on_value_change_camera_shake()
	self:on_value_change_brightness()
end

function RaidMenuOptionsVideo:on_click_subtitle()
	local subtitle = self._toggle_menu_subtitle:get_value()

	managers.menu:active_menu().callback_handler:toggle_subtitle_raid(subtitle)
end

function RaidMenuOptionsVideo:on_click_hit_indicator()
	local hit_indicator = self._stepper_menu_hit_indicator:get_value()

	managers.menu:active_menu().callback_handler:set_hit_indicator_raid(hit_indicator)
end

function RaidMenuOptionsVideo:on_click_hud_special_weapon_panels()
	local value = self._toggle_menu_hud_special_weapon_panels:get_value()

	managers.menu:active_menu().callback_handler:toggle_hud_special_weapon_panels(value)
end

function RaidMenuOptionsVideo:on_click_motion_dot()
	local value = self._stepper_menu_motion_dot:get_value()

	managers.menu:active_menu().callback_handler:set_motion_dot_raid(value)
end

function RaidMenuOptionsVideo:on_click_motion_dot_size()
	local value = self._stepper_menu_motion_dot_size:get_value()

	managers.menu:active_menu().callback_handler:set_motion_dot_size_raid(value)
end

function RaidMenuOptionsVideo:on_click_headbob()
	local use_headbob = self._toggle_menu_headbob:get_value()

	managers.menu:active_menu().callback_handler:toggle_headbob_raid(use_headbob)
end

function RaidMenuOptionsVideo:on_click_camera_accel()
	local value = self._toggle_menu_camera_accel:get_value()

	managers.user:set_setting("use_camera_accel", value)
end

function RaidMenuOptionsVideo:on_value_change_camera_shake()
	local value = self._progress_bar_menu_camera_shake:get_value() / 100

	managers.user:set_setting("camera_shake", value)
end

function RaidMenuOptionsVideo:on_click_options_video_advanced_button()
	managers.raid_menu:open_menu("raid_menu_options_video_advanced")
end

function RaidMenuOptionsVideo:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "on_click_default_video")
		},
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "on_click_apply_resolution_refresh_rate")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_options_video_resolution",
			"menu_options_controls_default_controller"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function RaidMenuOptionsVideo:_apply_video_resolution()
	Application:trace("RaidMenuOptionsVideo:_apply_vidoe_resolution")
	self:on_click_apply_resolution_refresh_rate()

	return true, nil
end
