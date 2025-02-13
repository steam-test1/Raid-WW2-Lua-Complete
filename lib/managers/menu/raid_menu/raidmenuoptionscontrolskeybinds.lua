RaidMenuOptionsControlsKeybinds = RaidMenuOptionsControlsKeybinds or class(RaidGuiBase)
RaidMenuOptionsControlsKeybinds.CONTROLS = {
	"move",
	"primary_attack",
	"secondary_attack",
	"primary_choice2",
	"primary_choice1",
	"primary_choice3",
	"primary_choice4",
	"switch_weapon",
	"reload",
	"weapon_firemode",
	"run",
	"jump",
	"duck",
	"melee",
	"interact",
	"comm_wheel",
	"comm_wheel_yes",
	"comm_wheel_no",
	"comm_wheel_found_it",
	"comm_wheel_wait",
	"comm_wheel_not_here",
	"comm_wheel_follow_me",
	"comm_wheel_assistance",
	"comm_wheel_enemy",
	"activate_warcry",
	"use_item",
	"toggle_chat",
	"toggle_hud",
	"push_to_talk",
	"drive",
	"hand_brake",
	"vehicle_rear_camera",
	"vehicle_shooting_stance",
	"vehicle_exit",
	"vehicle_change_seat"
}
RaidMenuOptionsControlsKeybinds.AXIS_ORDERED = {
	move = {
		"up",
		"down",
		"left",
		"right"
	},
	drive = {
		"accelerate",
		"brake",
		"turn_left",
		"turn_right"
	}
}
RaidMenuOptionsControlsKeybinds.CONTROLS_INFO = {
	move = {
		hidden = true,
		type = "movement",
		category = "normal"
	},
	up = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_forward"
	},
	down = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_back"
	},
	left = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_left"
	},
	right = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_right"
	},
	run = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_sprint"
	},
	jump = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_jump"
	},
	duck = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_crouch"
	},
	primary_attack = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_fire_weapon"
	},
	secondary_attack = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_aim_down_sight"
	},
	primary_choice1 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot1"
	},
	primary_choice2 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot2"
	},
	primary_choice3 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot3"
	},
	primary_choice4 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot4"
	},
	switch_weapon = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_switch_weapon"
	},
	reload = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_reload"
	},
	weapon_firemode = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_firemode"
	},
	melee = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_melee"
	},
	interact = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_shout"
	},
	activate_warcry = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_activate_warcry"
	},
	use_item = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_deploy"
	},
	toggle_hud = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_toggle_hud"
	},
	toggle_chat = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_chat_message"
	},
	push_to_talk = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_push_to_talk"
	},
	comm_wheel = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel"
	},
	comm_wheel_yes = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_yes"
	},
	comm_wheel_no = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_no"
	},
	comm_wheel_found_it = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_found_it"
	},
	comm_wheel_wait = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_wait"
	},
	comm_wheel_not_here = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_not_here"
	},
	comm_wheel_follow_me = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_follow_me"
	},
	comm_wheel_assistance = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_assistance"
	},
	comm_wheel_enemy = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_enemy"
	},
	continue = {
		category = "normal",
		text_id = "menu_button_continue"
	},
	drive = {
		hidden = true,
		type = "movement",
		category = "vehicle"
	},
	accelerate = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_accelerate"
	},
	brake = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_brake"
	},
	turn_left = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_turn_left"
	},
	turn_right = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_turn_right"
	},
	hand_brake = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_handbrake"
	},
	vehicle_change_camera = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_change_camera"
	},
	vehicle_rear_camera = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_rear_camera"
	},
	vehicle_shooting_stance = {
		type = "usage",
		category = "vehicle",
		text_id = "menu_button_vehicle_shooting_stance",
		block = {
			"normal"
		}
	},
	vehicle_exit = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_exit"
	},
	vehicle_change_seat = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_change_seat"
	}
}

function RaidMenuOptionsControlsKeybinds:init(ws, fullscreen_ws, node, component_name)
	RaidMenuOptionsControlsKeybinds.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "_on_escape_callback"))
end

function RaidMenuOptionsControlsKeybinds:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_keybinds_subtitle")

	self._controller_category = "normal"
	self._keybind_controls_table = {}
end

function RaidMenuOptionsControlsKeybinds:_layout()
	RaidMenuOptionsControlsKeybinds.super._layout(self)

	self._keybind_panel = self._root_panel:panel({
		x = 0,
		name = "keybind_panel",
		y = 0
	})
	self._rarity_filters_tabs = self._root_panel:tabs({
		tab_align = "center",
		tab_height = 64,
		tab_width = 160,
		name = "tabs_keybind_types",
		y = 96,
		x = 0,
		dont_trigger_special_buttons = true,
		initial_tab_idx = 1,
		on_click_callback = callback(self, self, "on_click_tabs_keybind_types"),
		tabs_params = {
			{
				callback_param = "normal",
				name = "tab_on_foot",
				text = self:translate("menu_options_binding_type_on_foot", true)
			},
			{
				callback_param = "vehicle",
				name = "tab_in_vehicle",
				text = self:translate("menu_options_binding_type_in_vehicle", true)
			}
		}
	})
	local default_controls_keybinds_params = {
		x = 1472,
		name = "default_controls_keybinds",
		y = 832,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_default")),
		on_click_callback = callback(self, self, "on_click_default_controls_keybinds"),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_controls_button = self._root_panel:long_secondary_button(default_controls_keybinds_params)

	self:_layout_controls_keybinds()
	self:bind_controller_inputs()
end

function RaidMenuOptionsControlsKeybinds:on_click_tabs_keybind_types(controller_category)
	self._controller_category = controller_category

	self._keybind_panel:clear()
	self:_layout_controls_keybinds()
end

function RaidMenuOptionsControlsKeybinds:_on_escape_callback()
	local result = false

	for _, control in ipairs(self._keybind_controls_table) do
		local control_result = control:is_listening_to_input()

		if control_result then
			result = true
		end
	end

	return result
end

function RaidMenuOptionsControlsKeybinds:close()
	self:_save_controls_keybinds_values()

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	managers.raid_menu:register_on_escape_callback(nil)
	RaidMenuOptionsControlsKeybinds.super.close(self)
end

function RaidMenuOptionsControlsKeybinds:_save_controls_keybinds_values()
end

function RaidMenuOptionsControlsKeybinds:_layout_controls_keybinds()
	self._keybind_controls_table = {}
	local default_controller_type = managers.controller:get_default_wrapper_type()

	if default_controller_type ~= "pc" then
		return
	end

	self._keybinds = {}
	local keybind_types = {
		"movement",
		"usage",
		"communication"
	}

	for _, keybind_type in ipairs(keybind_types) do
		self:_keybinds_per_type(keybind_type)
	end

	local keybind_controls = {}
	local start_x = 0
	local start_y = 224
	local keybind_width = 512
	local column_padding = 608
	local column_title_y = start_y - 32

	for type_no, keybind_type in ipairs(keybind_types) do
		start_x = (type_no - 1) * column_padding

		self._keybind_panel:text({
			align = "left",
			name = "column_title" .. keybind_type,
			x = start_x,
			y = column_title_y,
			text = utf8.to_upper(managers.localization:text("menu_options_controls_edit_keybinds_" .. keybind_type)),
			color = RaidGuiControlKeyBind.TEXT_COLOR_NORMAL,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.small
		})

		for row, keybind_params in ipairs(self._keybinds[keybind_type]) do
			local keybind_control = self._keybind_panel:keybind({
				keybind_w = 120,
				name = "keybind_" .. keybind_params.button,
				x = start_x,
				y = start_y + row * RaidGuiBase.PADDING,
				w = keybind_width,
				h = MenuManager.MENU_ITEM_HEIGHT,
				text = utf8.to_upper(keybind_params.button),
				ws = self._ws,
				keybind_params = keybind_params
			})

			table.insert(self._keybind_controls_table, keybind_control)
		end
	end
end

function RaidMenuOptionsControlsKeybinds.controls_info_by_category(category, keybind_type)
	local t = {}

	for _, name in ipairs(RaidMenuOptionsControlsKeybinds.CONTROLS) do
		local control = RaidMenuOptionsControlsKeybinds.CONTROLS_INFO[name]

		if control and control.category == category and (not keybind_type or keybind_type == control.type) then
			table.insert(t, name)
		end
	end

	return t
end

function RaidMenuOptionsControlsKeybinds:_keybinds_per_type(keybind_type)
	local controller_category = self._controller_category
	self._keybinds[keybind_type] = {}
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(self.controls_info_by_category(controller_category, keybind_type)) do
		local name_id = name
		local connection = connections[name]

		if connection._btn_connections then
			local ordered = self.AXIS_ORDERED[name]

			for _, btn_name in ipairs(ordered) do
				local btn_connection = connection._btn_connections[btn_name]

				if btn_connection then
					local name_id = name
					local params = {
						localize = "false",
						name = btn_name,
						connection_name = name,
						text_id = utf8.to_upper(managers.localization:text(self.CONTROLS_INFO[btn_name].text_id)),
						binding = btn_connection.name,
						axis = connection._name,
						button = btn_name
					}

					table.insert(self._keybinds[keybind_type], params)
				end
			end
		else
			local params = {
				localize = "false",
				name = name_id,
				connection_name = name,
				text_id = utf8.to_upper(managers.localization:text(self.CONTROLS_INFO[name].text_id)),
				binding = connection:get_input_name_list()[1],
				button = name
			}

			table.insert(self._keybinds[keybind_type], params)
		end
	end
end

function RaidMenuOptionsControlsKeybinds:on_click_default_controls_keybinds()
	local params = {
		title = managers.localization:text("dialog_reset_controls_keybinds_title"),
		message = managers.localization:text("dialog_reset_controls_keybinds_message"),
		callback = function ()
			managers.controller:load_settings("settings/controller_settings")
			managers.controller:clear_user_mod("all", self.CONTROLS_INFO)
			self:refresh_keybinds()
		end
	}

	managers.menu:show_option_dialog(params)
end

function RaidMenuOptionsControlsKeybinds:refresh_keybinds()
	self._keybind_panel:clear()
	self:_layout_controls_keybinds()
end

function RaidMenuOptionsControlsKeybinds:bind_controller_inputs()
	local legend = {
		controller = {
			"menu_legend_back"
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
