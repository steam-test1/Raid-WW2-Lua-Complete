RaidMenuOptionsInterface = RaidMenuOptionsInterface or class(RaidGuiBase)

function RaidMenuOptionsInterface:init(ws, fullscreen_ws, node, component_name)
	RaidMenuOptionsInterface.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuOptionsInterface:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_interface_subtitle")
end

function RaidMenuOptionsInterface:_layout()
	RaidMenuOptionsInterface.super._layout(self)
	self:_layout_menu()
	self:_load_menu_values()
	self:bind_controller_inputs()
end

function RaidMenuOptionsInterface:close()
	managers.savefile:save_setting(true)
	RaidMenuOptionsInterface.super.close(self)
end

function RaidMenuOptionsInterface:_layout_menu()
	local start_x = 0
	local start_y = 320
	local default_width = 576
	local previous_panel = nil
	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "subtitle",
		description = managers.localization:to_upper_text("menu_options_video_subtitle"),
		x = start_x,
		y = start_y,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_subtitle"),
		on_menu_move = {
			up = "default_interface",
			down = "objective_reminder"
		}
	}
	self._toggle_menu_subtitle = self._root_panel:toggle_button(previous_panel)

	self._toggle_menu_subtitle:set_selected(true)

	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "objective_reminder",
		description = managers.localization:to_upper_text("menu_objective_reminder"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_objective_reminders"),
		on_menu_move = {
			up = nil,
			down = "warcry_ready_indicator",
			up = previous_panel.name
		}
	}
	self._toggle_objective_reminders = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "warcry_ready_indicator",
		description = managers.localization:to_upper_text("menu_warcry_ready_indicator"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_warcry_ready_indicator"),
		on_menu_move = {
			up = nil,
			down = "skip_cinematics",
			up = previous_panel.name
		}
	}
	self._toggle_warcry_ready_indicator = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "skip_cinematics",
		description = managers.localization:to_upper_text("menu_skip_cinematics"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_skip_cinematics"),
		on_menu_move = {
			up = nil,
			down = "hud_special_weapon_panels",
			up = previous_panel.name
		}
	}
	self._toggle_skip_cinematics = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "hud_special_weapon_panels",
		description = managers.localization:to_upper_text("menu_options_video_hud_special_weapon_panels"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING * 2,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_hud_special_weapon_panels"),
		on_menu_move = {
			up = nil,
			down = "hud_crosshairs",
			up = previous_panel.name
		}
	}
	self._toggle_menu_hud_special_weapon_panels = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		w = nil,
		on_menu_move = nil,
		description = nil,
		on_click_callback = nil,
		name = "hud_crosshairs",
		description = managers.localization:to_upper_text("menu_options_video_hud_crosshairs"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_hud_crosshairs"),
		on_menu_move = {
			up = nil,
			down = "hit_confirm_indicator",
			up = previous_panel.name
		}
	}
	self._toggle_menu_hud_crosshairs = self._root_panel:toggle_button(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		on_item_selected_callback = nil,
		on_menu_move = nil,
		data_source_callback = nil,
		description = nil,
		w = nil,
		name = "hit_confirm_indicator",
		description = managers.localization:to_upper_text("menu_options_video_hit_confirm_indicator"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_hit_confirm_indicator"),
		on_item_selected_callback = callback(self, self, "on_click_hit_indicator"),
		on_menu_move = {
			up = nil,
			down = "motion_dot",
			up = previous_panel.name
		}
	}
	self._stepper_menu_hit_indicator = self._root_panel:stepper(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		stepper_w = 280,
		description = nil,
		name = "motion_dot",
		on_item_selected_callback = nil,
		on_menu_move = nil,
		data_source_callback = nil,
		w = nil,
		description = managers.localization:to_upper_text("menu_options_video_motion_dot"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING * 2,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_motion_dot"),
		on_item_selected_callback = callback(self, self, "on_click_motion_dot"),
		on_menu_move = {
			up = nil,
			down = "motion_dot_size",
			up = previous_panel.name
		}
	}
	self._stepper_menu_motion_dot = self._root_panel:stepper(previous_panel)
	previous_panel = {
		y = nil,
		x = nil,
		stepper_w = 280,
		description = nil,
		name = "motion_dot_size",
		on_item_selected_callback = nil,
		on_menu_move = nil,
		data_source_callback = nil,
		w = nil,
		description = managers.localization:to_upper_text("menu_options_video_motion_dot_size"),
		x = start_x,
		y = previous_panel.y + RaidGuiBase.PADDING,
		w = default_width,
		data_source_callback = callback(self, self, "data_source_stepper_menu_motion_dot_size"),
		on_item_selected_callback = callback(self, self, "on_click_motion_dot_size"),
		on_menu_move = {
			up = nil,
			down = "default_interface",
			up = previous_panel.name
		}
	}
	self._stepper_menu_motion_dot_size = self._root_panel:stepper(previous_panel)
	self._default_settings_button = self._root_panel:long_secondary_button({
		y = 832,
		text = nil,
		x = 1472,
		on_menu_move = nil,
		layer = nil,
		on_click_callback = nil,
		name = "default_interface",
		text = managers.localization:to_upper_text("menu_options_controls_default"),
		on_click_callback = callback(self, self, "on_click_default_interface"),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_menu_move = {
			up = nil,
			down = "subtitle",
			up = previous_panel.name
		}
	})

	if managers.raid_menu:is_pc_controller() then
		self._default_settings_button:show()
	else
		self._default_settings_button:hide()
	end
end

function RaidMenuOptionsInterface:data_source_stepper_menu_hit_confirm_indicator()
	local tb = {}

	for i = 1, #tweak_data.hit_indicator_modes do
		table.insert(tb, {
			value = nil,
			text_id = nil,
			info = nil,
			text_id = "menu_options_video_hit_indicator_mode_" .. tostring(i),
			info = "menu_options_video_hit_indicator_mode_" .. tostring(i),
			value = i
		})
	end

	return tb
end

function RaidMenuOptionsInterface:data_source_toggle_menu_hud_crosshairs()
	local tb = {}

	for i, v in {
		"on",
		"off"
	} do
		table.insert(tb, {
			value = nil,
			text_id = nil,
			info = nil,
			text_id = "menu_options_video_hud_crosshairs_mode_" .. tostring(v),
			info = "menu_options_video_hud_crosshairs_mode_" .. tostring(v),
			value = i
		})
	end

	return tb
end

function RaidMenuOptionsInterface:data_source_stepper_menu_motion_dot()
	local tb = {}

	for i = 1, #tweak_data.motion_dot_modes do
		table.insert(tb, {
			value = nil,
			text_id = nil,
			info = nil,
			text_id = "menu_options_video_motion_dot_mode_" .. tostring(i),
			info = "menu_options_video_motion_dot_mode_" .. tostring(i),
			value = i
		})
	end

	return tb
end

function RaidMenuOptionsInterface:data_source_stepper_menu_motion_dot_size()
	local tb = {}

	for i = 1, #tweak_data.motion_dot_modes do
		table.insert(tb, {
			value = nil,
			text_id = nil,
			info = nil,
			text_id = "menu_options_video_motion_dot_size_" .. tostring(i),
			info = "menu_options_video_motion_dot_size_" .. tostring(i),
			value = i
		})
	end

	return tb
end

function RaidMenuOptionsInterface:_load_menu_values()
	local objective_reminder = managers.user:get_setting("objective_reminder")

	self._toggle_objective_reminders:set_value_and_render(objective_reminder, true)

	local skip_cinematics = managers.user:get_setting("skip_cinematics")

	self._toggle_skip_cinematics:set_value_and_render(skip_cinematics, true)

	local warcry_ready_indicator = managers.user:get_setting("warcry_ready_indicator")

	self._toggle_warcry_ready_indicator:set_value_and_render(warcry_ready_indicator, true)

	local subtitle = managers.user:get_setting("subtitle")

	self._toggle_menu_subtitle:set_value_and_render(subtitle, true)

	local hud_special_weapon_panels = managers.user:get_setting("hud_special_weapon_panels")

	self._toggle_menu_hud_special_weapon_panels:set_value_and_render(hud_special_weapon_panels, true)

	local hud_crosshairs = managers.user:get_setting("hud_crosshairs")

	self._toggle_menu_hud_crosshairs:set_value_and_render(hud_crosshairs, true)

	local motion_dot = managers.user:get_setting("motion_dot")

	self._stepper_menu_motion_dot:set_value_and_render(motion_dot, true)

	local motion_dot_size = managers.user:get_setting("motion_dot_size")

	self._stepper_menu_motion_dot_size:set_value_and_render(motion_dot_size, true)
	self._stepper_menu_motion_dot_size:set_enabled(motion_dot > 1)

	local hit_indicator = managers.user:get_setting("hit_indicator")

	if type(hit_indicator) == "boolean" and HUDHitConfirm then
		hit_indicator = hit_indicator and HUDHitConfirm.MODE_ON or HUDHitConfirm.MODE_OFF
	end

	self._stepper_menu_hit_indicator:set_value_and_render(hit_indicator, true)
end

function RaidMenuOptionsInterface:on_click_subtitle()
	local subtitle = self._toggle_menu_subtitle:get_value()

	managers.menu:active_menu().callback_handler:toggle_subtitle_raid(subtitle)
end

function RaidMenuOptionsInterface:on_click_objective_reminders()
	local reminders = self._toggle_objective_reminders:get_value()

	managers.menu:active_menu().callback_handler:toggle_objective_reminder_raid(reminders)
end

function RaidMenuOptionsInterface:on_click_warcry_ready_indicator()
	local warcry_ready_indicator = self._toggle_warcry_ready_indicator:get_value()

	managers.menu:active_menu().callback_handler:toggle_warcry_ready_indicator_raid(warcry_ready_indicator)
end

function RaidMenuOptionsInterface:on_click_skip_cinematics()
	local skip_cinematics = self._toggle_skip_cinematics:get_value()

	managers.menu:active_menu().callback_handler:toggle_skip_cinematics_raid(skip_cinematics)
end

function RaidMenuOptionsInterface:on_click_hit_indicator()
	local hit_indicator = self._stepper_menu_hit_indicator:get_value()

	managers.menu:active_menu().callback_handler:set_hit_indicator_raid(hit_indicator)
end

function RaidMenuOptionsInterface:on_click_hud_crosshairs()
	local value = self._toggle_menu_hud_crosshairs:get_value()

	managers.menu:active_menu().callback_handler:set_hud_crosshairs_raid(value)
end

function RaidMenuOptionsInterface:on_click_hud_special_weapon_panels()
	local value = self._toggle_menu_hud_special_weapon_panels:get_value()

	managers.menu:active_menu().callback_handler:toggle_hud_special_weapon_panels(value)
end

function RaidMenuOptionsInterface:on_click_motion_dot()
	local value = self._stepper_menu_motion_dot:get_value()

	self._stepper_menu_motion_dot_size:set_enabled(value > 1)
	managers.menu:active_menu().callback_handler:set_motion_dot_raid(value)
end

function RaidMenuOptionsInterface:on_click_motion_dot_size()
	local value = self._stepper_menu_motion_dot_size:get_value()

	managers.menu:active_menu().callback_handler:set_motion_dot_size_raid(value)
end

function RaidMenuOptionsInterface:on_click_default_interface()
	local params = {
		title = nil,
		callback = nil,
		message = nil,
		title = managers.localization:text("dialog_reset_interface_title"),
		message = managers.localization:text("dialog_reset_interface_message"),
		callback = callback(self, self, "_callback_default_settings")
	}

	managers.menu:show_option_dialog(params)
end

function RaidMenuOptionsInterface:_callback_default_settings()
	managers.user:reset_interface_setting_map()
	self:_load_menu_values()
end

function RaidMenuOptionsInterface:bind_controller_inputs()
	local bindings = {
		{
			key = nil,
			callback = nil,
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "on_click_default_interface")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		keyboard = nil,
		controller = nil,
		controller = {
			"menu_legend_back",
			"menu_options_controls_default_controller"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = nil,
				callback = callback(self, self, "_on_legend_pc_back")
			}
		}
	}

	self:set_legend(legend)
end
