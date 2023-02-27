RaidMenuOptionsControls = RaidMenuOptionsControls or class(RaidGuiBase)

function RaidMenuOptionsControls:init(ws, fullscreen_ws, node, component_name)
	RaidMenuOptionsControls.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuOptionsControls:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_subtitle")
end

function RaidMenuOptionsControls:_layout()
	RaidMenuOptionsControls.super._layout(self)
	self:_layout_controls()
	self:_load_controls_values()
	self._progress_bar_menu_camera_sensitivity_horizontal:set_selected(true)
	self:bind_controller_inputs()
end

function RaidMenuOptionsControls:close()
	self:_save_controls_values()

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	RaidMenuOptionsControls.super.close(self)
end

function RaidMenuOptionsControls:_layout_controls()
	local start_x = 0
	local start_y = 320
	local default_width = 512
	local second_x = 704
	RaidMenuOptionsControls.SLIDER_PADDING = RaidGuiBase.PADDING + 24
	local previous_params = nil
	previous_params = {
		name = "btn_keybinding",
		x = start_x,
		y = start_y - 128,
		w = default_width,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_keybinds_button")),
		on_click_callback = callback(self, self, "on_click_options_controls_keybinds_button"),
		on_menu_move = {
			down = "slider_look_sensitivity_horizontal"
		}
	}
	self._btn_keybinding = self._root_panel:long_tertiary_button(previous_params)
	previous_params = {
		name = "slider_look_sensitivity_horizontal",
		value_step = 1,
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_controls_look_sensitivity_horizontal")),
		x = start_x,
		y = start_y,
		on_value_change_callback = callback(self, self, "on_value_change_camera_sensitivity_horizontal"),
		on_menu_move = {
			down = "slider_look_sensitivity_vertical",
			up = previous_params.name
		}
	}
	self._progress_bar_menu_camera_sensitivity_horizontal = self._root_panel:slider(previous_params)
	previous_params = {
		name = "slider_look_sensitivity_vertical",
		value_step = 1,
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_controls_look_sensitivity_vertical")),
		x = start_x,
		y = previous_params.y + (self._progress_bar_menu_camera_sensitivity_horizontal._double_height and RaidMenuOptionsControls.SLIDER_PADDING or RaidGuiBase.PADDING),
		on_value_change_callback = callback(self, self, "on_value_change_camera_sensitivity_vertical"),
		on_menu_move = {
			down = "slider_aiming_sensitivity_horizontal",
			up = previous_params.name
		}
	}
	self._progress_bar_menu_camera_sensitivity_vertical = self._root_panel:slider(previous_params)
	previous_params = {
		name = "slider_aiming_sensitivity_horizontal",
		value_step = 1,
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_controls_aiming_sensitivity_horizontal")),
		x = start_x,
		y = previous_params.y + (self._progress_bar_menu_camera_sensitivity_vertical._double_height and RaidMenuOptionsControls.SLIDER_PADDING or RaidGuiBase.PADDING),
		on_value_change_callback = callback(self, self, "on_value_change_camera_zoom_sensitivity_horizontal"),
		on_menu_move = {
			down = "slider_aiming_sensitivity_vertical",
			up = previous_params.name
		}
	}
	self._progress_bar_menu_camera_zoom_sensitivity_horizontal = self._root_panel:slider(previous_params)
	previous_params = {
		name = "slider_aiming_sensitivity_vertical",
		value_step = 1,
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_options_controls_aiming_sensitivity_vertical")),
		x = start_x,
		y = previous_params.y + (self._progress_bar_menu_camera_zoom_sensitivity_horizontal._double_height and RaidMenuOptionsControls.SLIDER_PADDING or RaidGuiBase.PADDING),
		on_value_change_callback = callback(self, self, "on_value_change_camera_zoom_sensitivity_vertical"),
		on_menu_move = {
			down = "separate_aiming_settings",
			up = previous_params.name
		}
	}
	self._progress_bar_menu_camera_zoom_sensitivity_vertical = self._root_panel:slider(previous_params)
	previous_params = {
		name = "separate_aiming_settings",
		description = utf8.to_upper(managers.localization:text("menu_options_separate_aiming_settings")),
		x = start_x,
		y = previous_params.y + (self._progress_bar_menu_camera_zoom_sensitivity_vertical._double_height and RaidMenuOptionsControls.SLIDER_PADDING or RaidGuiBase.PADDING),
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_zoom_sensitivity"),
		on_menu_move = {
			down = "inverted_y_axis",
			up = previous_params.name
		}
	}
	self._toggle_menu_toggle_zoom_sensitivity = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "inverted_y_axis",
		description = utf8.to_upper(managers.localization:text("menu_options_inverted_y_axis")),
		x = start_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_invert_camera_vertically"),
		on_menu_move = {
			down = "hold_to_aim",
			up = previous_params.name
		}
	}
	self._toggle_menu_invert_camera_vertically = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "hold_to_aim",
		description = utf8.to_upper(managers.localization:text("menu_options_hold_to_aim")),
		x = start_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_hold_to_steelsight"),
		on_menu_move = {
			down = "hold_to_run",
			up = previous_params.name
		}
	}
	self._toggle_menu_hold_to_steelsight = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "hold_to_run",
		description = utf8.to_upper(managers.localization:text("menu_options_hold_to_run")),
		x = start_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_hold_to_run"),
		on_menu_move = {
			down = "hold_to_crouch",
			up = previous_params.name
		}
	}
	self._toggle_menu_hold_to_run = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "hold_to_crouch",
		description = utf8.to_upper(managers.localization:text("menu_options_hold_to_crouch")),
		x = start_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_hold_to_duck"),
		on_menu_move = {
			down = "controller_sticky_aim",
			up = previous_params.name
		}
	}
	self._toggle_menu_hold_to_duck = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "controller_sticky_aim",
		description = utf8.to_upper(managers.localization:text("menu_options_controller_sticky_aim")),
		x = second_x,
		y = start_y,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_controller_sticky_aim"),
		on_menu_move = {
			down = "controller_vibration",
			up = previous_params.name
		}
	}
	self._toggle_menu_controller_sticky_aim = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "controller_vibration",
		description = utf8.to_upper(managers.localization:text("menu_options_controller_vibration")),
		x = second_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_controller_vibration"),
		on_menu_move = {
			down = "controller_aim_assist",
			up = previous_params.name
		}
	}
	self._toggle_menu_controller_vibration = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "controller_aim_assist",
		description = utf8.to_upper(managers.localization:text("menu_options_controller_aim_assist")),
		x = second_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_controller_aim_assist"),
		on_menu_move = {
			down = "controller_southpaw",
			up = previous_params.name
		}
	}
	self._toggle_menu_controller_aim_assist = self._root_panel:toggle_button(previous_params)
	previous_params = {
		name = "controller_southpaw",
		description = utf8.to_upper(managers.localization:text("menu_options_controller_southpaw")),
		x = second_x,
		y = previous_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_controller_southpaw"),
		on_menu_move = {
			up = previous_params.name
		}
	}
	self._toggle_menu_controller_southpaw = self._root_panel:toggle_button(previous_params)
	local default_controls_params = {
		name = "default_controls",
		y = 832,
		x = 1472,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_default")),
		on_click_callback = callback(self, self, "on_click_default_controls"),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_controls_button = self._root_panel:long_secondary_button(default_controls_params)

	self:_modify_controller_layout()

	if managers.raid_menu:is_pc_controller() then
		self._default_controls_button:show()
	else
		self._default_controls_button:hide()
	end
end

function RaidMenuOptionsControls:_modify_controller_layout()
	self._toggle_menu_controller_vibration:show()
	self._toggle_menu_controller_aim_assist:show()
	self._toggle_menu_controller_southpaw:show()
	self._toggle_menu_controller_sticky_aim:show()

	if not managers.raid_menu:is_pc_controller() then
		self._btn_keybinding:set_text(self:translate("menu_options_controls_controller_mapping", true))
	end
end

function RaidMenuOptionsControls:on_click_toggle_controller_vibration()
	local value = self._toggle_menu_controller_vibration:get_value()

	managers.menu:active_menu().callback_handler:toggle_rumble(value)
end

function RaidMenuOptionsControls:on_click_toggle_controller_aim_assist()
	local value = self._toggle_menu_controller_aim_assist:get_value()

	managers.menu:active_menu().callback_handler:toggle_aim_assist(value)
end

function RaidMenuOptionsControls:on_click_toggle_controller_sticky_aim(item)
	local value = self._toggle_menu_controller_sticky_aim:get_value()

	managers.menu:active_menu().callback_handler:toggle_sticky_aim(value)
end

function RaidMenuOptionsControls:on_click_toggle_controller_southpaw()
	local value = self._toggle_menu_controller_southpaw:get_value()

	managers.menu:active_menu().callback_handler:toggle_southpaw(value)
end

function RaidMenuOptionsControls:on_click_options_controls_keybinds_button()
	if managers.raid_menu:is_pc_controller() then
		managers.raid_menu:open_menu("raid_menu_options_controls_keybinds")
	else
		managers.raid_menu:open_menu("raid_menu_options_controller_mapping")
	end
end

function RaidMenuOptionsControls:on_value_change_camera_sensitivity_horizontal()
	local camera_sensitivity_percentage = math.clamp(self._progress_bar_menu_camera_sensitivity_horizontal:get_value(), 0, 100)
	local enable_camera_zoom_sensitivity = self._toggle_menu_toggle_zoom_sensitivity:get_value()
	local camera_sensitivity = camera_sensitivity_percentage / 100 * (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) + tweak_data.player.camera.MIN_SENSITIVITY

	managers.menu:active_menu().callback_handler:set_camera_sensitivity_x_raid(camera_sensitivity)

	if not enable_camera_zoom_sensitivity then
		self._progress_bar_menu_camera_sensitivity_vertical:set_value(camera_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_horizontal:set_value(camera_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_vertical:set_value(camera_sensitivity_percentage)
	end
end

function RaidMenuOptionsControls:on_value_change_camera_sensitivity_vertical()
	local camera_sensitivity_percentage = math.clamp(self._progress_bar_menu_camera_sensitivity_vertical:get_value(), 0, 100)
	local enable_camera_zoom_sensitivity = self._toggle_menu_toggle_zoom_sensitivity:get_value()
	local camera_sensitivity = camera_sensitivity_percentage / 100 * (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) + tweak_data.player.camera.MIN_SENSITIVITY

	managers.menu:active_menu().callback_handler:set_camera_sensitivity_y_raid(camera_sensitivity)

	if not enable_camera_zoom_sensitivity then
		self._progress_bar_menu_camera_sensitivity_horizontal:set_value(camera_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_horizontal:set_value(camera_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_vertical:set_value(camera_sensitivity_percentage)
	end
end

function RaidMenuOptionsControls:on_value_change_camera_zoom_sensitivity_horizontal()
	local camera_zoom_sensitivity_percentage = math.clamp(self._progress_bar_menu_camera_zoom_sensitivity_horizontal:get_value(), 0, 100)
	local enable_camera_zoom_sensitivity = self._toggle_menu_toggle_zoom_sensitivity:get_value()
	local camera_zoom_sensitivity = camera_zoom_sensitivity_percentage / 100 * (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) + tweak_data.player.camera.MIN_SENSITIVITY

	managers.menu:active_menu().callback_handler:set_camera_zoom_sensitivity_x_raid(camera_zoom_sensitivity)

	if not enable_camera_zoom_sensitivity then
		self._progress_bar_menu_camera_sensitivity_horizontal:set_value(camera_zoom_sensitivity_percentage)
		self._progress_bar_menu_camera_sensitivity_vertical:set_value(camera_zoom_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_vertical:set_value(camera_zoom_sensitivity_percentage)
	end
end

function RaidMenuOptionsControls:on_value_change_camera_zoom_sensitivity_vertical()
	local camera_zoom_sensitivity_percentage = math.clamp(self._progress_bar_menu_camera_zoom_sensitivity_vertical:get_value(), 0, 100)
	local enable_camera_zoom_sensitivity = self._toggle_menu_toggle_zoom_sensitivity:get_value()
	local camera_zoom_sensitivity = camera_zoom_sensitivity_percentage / 100 * (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) + tweak_data.player.camera.MIN_SENSITIVITY

	managers.menu:active_menu().callback_handler:set_camera_zoom_sensitivity_y_raid(camera_zoom_sensitivity)

	if not enable_camera_zoom_sensitivity then
		self._progress_bar_menu_camera_sensitivity_horizontal:set_value(camera_zoom_sensitivity_percentage)
		self._progress_bar_menu_camera_sensitivity_vertical:set_value(camera_zoom_sensitivity_percentage)
		self._progress_bar_menu_camera_zoom_sensitivity_horizontal:set_value(camera_zoom_sensitivity_percentage)
	end
end

function RaidMenuOptionsControls:on_click_toggle_zoom_sensitivity()
	local enable_camera_zoom_sensitivity = self._toggle_menu_toggle_zoom_sensitivity:get_value()

	managers.menu:active_menu().callback_handler:toggle_zoom_sensitivity_raid(enable_camera_zoom_sensitivity)
end

function RaidMenuOptionsControls:on_click_toggle_invert_camera_vertically()
	local invert_camera_y = self._toggle_menu_invert_camera_vertically:get_value()

	managers.menu:active_menu().callback_handler:invert_camera_vertically_raid(invert_camera_y)
end

function RaidMenuOptionsControls:on_click_toggle_hold_to_steelsight()
	local hold_to_steelsight = self._toggle_menu_hold_to_steelsight:get_value()

	managers.menu:active_menu().callback_handler:hold_to_steelsight_raid(hold_to_steelsight)
end

function RaidMenuOptionsControls:on_click_toggle_hold_to_run()
	local hold_to_run = self._toggle_menu_hold_to_run:get_value()

	managers.menu:active_menu().callback_handler:hold_to_run_raid(hold_to_run)
end

function RaidMenuOptionsControls:on_click_toggle_hold_to_duck()
	local hold_to_duck = self._toggle_menu_hold_to_duck:get_value()

	managers.menu:active_menu().callback_handler:hold_to_duck_raid(hold_to_duck)
end

function RaidMenuOptionsControls:on_click_default_controls()
	local params = {
		title = managers.localization:text("dialog_reset_controls_title"),
		message = managers.localization:text("dialog_reset_controls_message"),
		callback = function ()
			managers.user:reset_controls_setting_map()
			self:_load_controls_values()
		end
	}

	managers.menu:show_option_dialog(params)
end

function RaidMenuOptionsControls:_load_controls_values()
	local camera_sensitivity_x = math.clamp(managers.user:get_setting("camera_sensitivity_x"), 0, 100)
	local camera_sensitivity_y = math.clamp(managers.user:get_setting("camera_sensitivity_y"), 0, 100)
	local camera_zoom_sensitivity_x = math.clamp(managers.user:get_setting("camera_zoom_sensitivity_x"), 0, 100)
	local camera_zoom_sensitivity_y = math.clamp(managers.user:get_setting("camera_zoom_sensitivity_y"), 0, 100)
	local enable_camera_zoom_sensitivity = managers.user:get_setting("enable_camera_zoom_sensitivity")
	local invert_camera_y = managers.user:get_setting("invert_camera_y")
	local hold_to_steelsight = managers.user:get_setting("hold_to_steelsight")
	local hold_to_run = managers.user:get_setting("hold_to_run")
	local hold_to_duck = managers.user:get_setting("hold_to_duck")
	local rumble = managers.user:get_setting("rumble")
	local aim_assist = managers.user:get_setting("aim_assist")
	local southpaw = managers.user:get_setting("southpaw")
	local sticky_aim = managers.user:get_setting("sticky_aim")
	local set_camera_sensitivity_x = (camera_sensitivity_x - tweak_data.player.camera.MIN_SENSITIVITY) / (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 100
	local set_camera_sensitivity_y = (camera_sensitivity_y - tweak_data.player.camera.MIN_SENSITIVITY) / (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 100

	self._progress_bar_menu_camera_sensitivity_horizontal:set_value(set_camera_sensitivity_x)
	self._progress_bar_menu_camera_sensitivity_vertical:set_value(set_camera_sensitivity_y)

	local set_camera_zoom_sensitivity_x = (camera_zoom_sensitivity_x - tweak_data.player.camera.MIN_SENSITIVITY) / (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 100
	local set_camera_zoom_sensitivity_y = (camera_zoom_sensitivity_y - tweak_data.player.camera.MIN_SENSITIVITY) / (tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 100

	self._progress_bar_menu_camera_zoom_sensitivity_horizontal:set_value(set_camera_zoom_sensitivity_x)
	self._progress_bar_menu_camera_zoom_sensitivity_vertical:set_value(set_camera_zoom_sensitivity_y)
	self._toggle_menu_toggle_zoom_sensitivity:set_value_and_render(enable_camera_zoom_sensitivity)
	self._toggle_menu_invert_camera_vertically:set_value_and_render(invert_camera_y)
	self._toggle_menu_hold_to_steelsight:set_value_and_render(hold_to_steelsight)
	self._toggle_menu_hold_to_run:set_value_and_render(hold_to_run)
	self._toggle_menu_hold_to_duck:set_value_and_render(hold_to_duck)
	self._toggle_menu_controller_vibration:set_value_and_render(rumble)
	self._toggle_menu_controller_aim_assist:set_value_and_render(aim_assist)
	self._toggle_menu_controller_southpaw:set_value_and_render(southpaw)
	self._toggle_menu_controller_sticky_aim:set_value_and_render(sticky_aim)
end

function RaidMenuOptionsControls:_save_controls_values()
	self:on_value_change_camera_sensitivity_horizontal()
	self:on_value_change_camera_sensitivity_vertical()
	self:on_value_change_camera_zoom_sensitivity_horizontal()
	self:on_value_change_camera_zoom_sensitivity_vertical()
	self:on_click_toggle_zoom_sensitivity()
	self:on_click_toggle_invert_camera_vertically()
	self:on_click_toggle_hold_to_steelsight()
	self:on_click_toggle_hold_to_run()
	self:on_click_toggle_hold_to_duck()
	self:on_click_toggle_controller_vibration()
	self:on_click_toggle_controller_aim_assist()
	self:on_click_toggle_controller_southpaw()
	self:on_click_toggle_controller_sticky_aim()
end

function RaidMenuOptionsControls:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "on_click_default_controls")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
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
