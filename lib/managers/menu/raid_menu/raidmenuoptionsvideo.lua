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
	managers.savefile:save_setting(true)
	RaidMenuOptionsVideo.super.close(self)
end

function RaidMenuOptionsVideo:_layout_video()
	local start_x = 0
	local start_y = 320
	local default_width = 512
	local previous_panel = nil
	local on_controller = managers.controller:is_controller_present()
	previous_panel = {
		name = "btn_advanced_options",
		x = start_x,
		y = start_y - 128,
		text = managers.localization:to_upper_text("menu_options_video_advanced_button"),
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
		description = managers.localization:to_upper_text("menu_options_video_resolution"),
		data_source_callback = callback(self, self, "data_source_stepper_menu_resolution"),
		on_item_selected_callback = callback(self, self, "on_item_selected_stepper_menu_resolution"),
		on_menu_move = {
			up = previous_panel.name,
			down = on_controller and "stepper_menu_refresh_rate" or "apply_resolution"
		}
	}
	self._stepper_menu_resolution = self._root_panel:stepper(previous_panel)

	self._stepper_menu_resolution:set_value_and_render({
		x = RenderSettings.resolution.x,
		y = RenderSettings.resolution.y,
		is_equal = function (self, check)
			return check.x == self.x and check.y == self.y
		end
	}, true)

	local apply_resolution = {
		name = "apply_resolution",
		x = self._stepper_menu_resolution:w() + RaidGuiBase.PADDING,
		y = self._stepper_menu_resolution:y(),
		text = managers.localization:to_upper_text("menu_button_apply_resolution_refresh_rate"),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "on_click_apply_resolution_refresh_rate"),
		visible = not on_controller,
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
		description = managers.localization:to_upper_text("menu_options_video_refresh_rate"),
		data_source_callback = callback(self, self, "data_source_stepper_menu_refresh_rate"),
		on_item_selected_callback = callback(self, self, "on_item_selected_refresh_rate"),
		on_menu_move = {
			down = "window_mode",
			up = on_controller and "stepper_menu_resolution" or previous_panel.name
		}
	}
	self._stepper_menu_refresh_rate = self._root_panel:stepper(previous_panel)

	table.insert(self._fullscreen_only_controls, self._stepper_menu_refresh_rate)

	previous_panel = {
		name = "window_mode",
		stepper_w = 280,
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		description = managers.localization:to_upper_text("menu_window_mode"),
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
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		description = managers.localization:to_upper_text("menu_options_video_effect_quality"),
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
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		description = managers.localization:to_upper_text("menu_options_video_brightness"),
		on_value_change_callback = callback(self, self, "on_value_change_brightness"),
		on_menu_move = {
			down = "use_headbob",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_brightness = self._root_panel:slider(previous_panel)

	table.insert(self._fullscreen_only_controls, self._progress_bar_menu_brightness)

	start_x = 704
	start_y = 320
	previous_panel = {
		name = "use_headbob",
		x = start_x,
		y = start_y,
		w = default_width,
		description = managers.localization:to_upper_text("menu_options_video_use_headbob"),
		on_click_callback = callback(self, self, "on_click_headbob"),
		on_menu_move = {
			down = "use_camera_accel",
			up = previous_panel.name
		}
	}
	self._toggle_menu_headbob = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		name = "use_camera_accel",
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		description = managers.localization:to_upper_text("menu_options_video_use_camera_accel"),
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
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		description = managers.localization:to_upper_text("menu_options_video_camera_shake"),
		on_value_change_callback = callback(self, self, "on_value_change_camera_shake"),
		on_menu_move = {
			down = "fov_adjustment",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_camera_shake = self._root_panel:slider(previous_panel)
	previous_panel = {
		name = "fov_adjustment",
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		description = managers.localization:to_upper_text("menu_fov_adjustment"),
		min_display_value = tweak_data.player.stances.default.standard.FOV,
		max_display_value = math.round(tweak_data.player.stances.default.standard.FOV * tweak_data.player.fov_multiplier.MAX),
		on_value_change_callback = callback(self, self, "on_value_change_fov_adjustment"),
		on_menu_move = {
			down = "default_video",
			up = previous_panel.name
		}
	}
	self._progress_bar_menu_fov_adjustment = self._root_panel:slider(previous_panel)
	local default_video_settings_button = {
		name = "default_video",
		y = 832,
		x = 1472,
		layer = RaidGuiBase.FOREGROUND_LAYER,
		text = managers.localization:to_upper_text("menu_options_controls_default"),
		on_click_callback = callback(self, self, "on_click_default_video"),
		on_menu_move = {
			down = "btn_advanced_options",
			up = previous_panel.name
		}
	}
	self._default_video_button = self._root_panel:long_secondary_button(default_video_settings_button)

	if managers.raid_menu:is_pc_controller() then
		self._default_video_button:show()
	else
		self._default_video_button:hide()
	end
end

function RaidMenuOptionsVideo:data_source_stepper_menu_resolution()
	local temp_resolutions = clone(RenderSettings.modes)

	table.sort(temp_resolutions)

	local resolutions = {}

	for _, resolution in ipairs(temp_resolutions) do
		self:_add_distinct_resolution(resolution, resolutions)
	end

	local result = {}

	for _, resolution in ipairs(resolutions) do
		local info_text = string.format("%d x %d", resolution.x, resolution.y)

		table.insert(result, {
			text = info_text,
			info = info_text,
			value = resolution
		})
	end

	return result
end

function RaidMenuOptionsVideo:data_source_stepper_menu_window_mode()
	local result = {}

	table.insert(result, {
		value = "WINDOWED",
		text = managers.localization:to_upper_text("menu_windowed"),
		info = managers.localization:to_upper_text("menu_windowed")
	})
	table.insert(result, {
		value = "WINDOWED_FULLSCREEN",
		selected = true,
		text = managers.localization:to_upper_text("menu_windowed_fullscreen"),
		info = managers.localization:to_upper_text("menu_windowed_fullscreen")
	})
	table.insert(result, {
		value = "FULLSCREEN",
		text = managers.localization:to_upper_text("menu_fullscreen"),
		info = managers.localization:to_upper_text("menu_fullscreen")
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
	local temp_resolutions = clone(RenderSettings.modes)

	table.sort(temp_resolutions)

	local result = {}

	for _, res in ipairs(temp_resolutions) do
		if res.x == resolution.x and res.y == resolution.y then
			local info_text = string.format("%d Hz", res.z)

			table.insert(result, {
				text = info_text,
				info = info_text,
				value = res.z
			})
		end
	end

	return result
end

function RaidMenuOptionsVideo:data_source_stepper_menu_refresh_rate()
	local current_resolution = self._stepper_menu_resolution:get_value()

	return self:_get_refresh_rates_for_resolution(current_resolution)
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

function RaidMenuOptionsVideo:on_value_change_fov_adjustment()
	local fov_multiplier = self._progress_bar_menu_fov_adjustment:get_value() / 100
	fov_multiplier = fov_multiplier * (tweak_data.player.fov_multiplier.MAX - 1) + 1

	managers.menu:active_menu().callback_handler:set_fov_multiplier_raid(fov_multiplier)
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
			is_equal = function (self, check)
				return check.x == self.x and check.y == self.y
			end
		}, true)
	end
end

function RaidMenuOptionsVideo:on_click_default_video()
	local params = {
		title = managers.localization:text("dialog_reset_video_title"),
		message = managers.localization:text("dialog_reset_video_message"),
		callback = callback(self, self, "_callback_default_video")
	}

	managers.menu:show_option_dialog(params)
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

function RaidMenuOptionsVideo:_callback_default_video()
	managers.user:reset_video_setting_map()
	self:_load_video_values()
	managers.menu:active_menu().callback_handler:set_fullscreen_default_raid_no_dialog()

	local resolution = self:_get_default_resolution()

	managers.menu:active_menu().callback_handler:set_resolution_default_raid_no_dialog(resolution)
	managers.menu:active_menu().callback_handler:_refresh_brightness()
	self._stepper_menu_resolution:set_value_and_render({
		x = resolution.x,
		y = resolution.y,
		is_equal = function (self, check)
			return check.x == self.x and check.y == self.y
		end
	}, true)
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
	local on_controller = managers.controller:is_controller_present()

	for _, control in ipairs(self._fullscreen_only_controls) do
		control:set_enabled(is_fullscreen)
	end

	self._stepper_menu_resolution:set_enabled(not is_borderless)
	self._button_apply_video_resolution:set_enabled(not is_borderless)

	if not is_fullscreen and not is_borderless then
		self._btn_advanced_options._on_menu_move.down = "stepper_menu_resolution"
		self._stepper_menu_resolution._on_menu_move.down = on_controller and "stepper_menu_refresh_rate" or "apply_resolution"
		self._button_apply_video_resolution._on_menu_move.down = "window_mode"
		self._stepper_menu_window_mode._on_menu_move.up = "apply_resolution"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "use_headbob"
		self._toggle_menu_headbob._on_menu_move.up = "effect_quality"
	elseif is_borderless then
		self._btn_advanced_options._on_menu_move.down = "window_mode"
		self._stepper_menu_window_mode._on_menu_move.up = "btn_advanced_options"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "use_headbob"
		self._toggle_menu_headbob._on_menu_move.up = "effect_quality"
	else
		self._btn_advanced_options._on_menu_move.down = "stepper_menu_resolution"
		self._stepper_menu_resolution._on_menu_move.down = on_controller and "stepper_menu_refresh_rate" or "apply_resolution"
		self._button_apply_video_resolution._on_menu_move.down = "stepper_menu_refresh_rate"
		self._stepper_menu_window_mode._on_menu_move.up = "stepper_menu_refresh_rate"
		self._progress_bar_menu_effect_quality._on_menu_move.down = "progress_bar_menu_brightness"
		self._toggle_menu_headbob._on_menu_move.up = "progress_bar_menu_brightness"
	end
end

function RaidMenuOptionsVideo:_reload_video_and_adv_video_options()
	self:_load_video_values()
end

function RaidMenuOptionsVideo:_load_video_values()
	local is_fullscreen = managers.viewport:is_fullscreen()
	local is_borderless = managers.viewport:is_borderless()
	local resolution = RenderSettings.resolution

	self._stepper_menu_refresh_rate:set_value_and_render(resolution.z, true)

	if is_borderless then
		local monitor_res = Application:monitor_resolution()
		resolution = Vector3(monitor_res.x, monitor_res.y, self._stepper_menu_refresh_rate:get_value())
	end

	self._stepper_menu_resolution:set_value_and_render({
		x = resolution.x,
		y = resolution.y,
		is_equal = function (self, check)
			return check.x == self.x and check.y == self.y
		end
	}, true)

	if is_fullscreen then
		self._stepper_menu_window_mode:set_value_and_render("FULLSCREEN", true)
	elseif is_borderless then
		self._stepper_menu_window_mode:set_value_and_render("WINDOWED_FULLSCREEN", true)
	else
		self._stepper_menu_window_mode:set_value_and_render("WINDOWED", true)
	end

	local use_headbob = managers.user:get_setting("use_headbob")

	self._toggle_menu_headbob:set_value_and_render(use_headbob)

	local use_camera_accel = managers.user:get_setting("use_camera_accel")

	self._toggle_menu_camera_accel:set_value_and_render(use_camera_accel)

	local camera_shake = managers.user:get_setting("camera_shake")

	self._progress_bar_menu_camera_shake:set_value(camera_shake * 100)

	local effect_quality = managers.user:get_setting("effect_quality")

	self._progress_bar_menu_effect_quality:set_value(effect_quality * 100)

	local brightness = managers.user:get_setting("brightness")

	self._progress_bar_menu_brightness:set_value((brightness - 0.5) * 100)

	local fov_multiplier = managers.user:get_setting("fov_multiplier")
	local fov_multiplier_value = (1 - fov_multiplier) / (1 - tweak_data.player.fov_multiplier.MAX)

	self._progress_bar_menu_fov_adjustment:set_value(fov_multiplier_value * 100, true)
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
				callback = callback(self, self, "_on_legend_pc_back")
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
