RaidMenuOptionsControlsKeybinds = RaidMenuOptionsControlsKeybinds or class(RaidGuiBase)

-- Lines 3-7
function RaidMenuOptionsControlsKeybinds:init(ws, fullscreen_ws, node, component_name)
	RaidMenuOptionsControlsKeybinds.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "_on_escape_callback"))
end

-- Lines 9-15
function RaidMenuOptionsControlsKeybinds:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_controls_keybinds_subtitle")

	self._controller_category = "normal"
	self._keybind_controls_table = {}
end

-- Lines 17-51
function RaidMenuOptionsControlsKeybinds:_layout()
	RaidMenuOptionsControlsKeybinds.super._layout(self)

	self._keybind_panel = self._root_panel:panel({
		name = "keybind_panel",
		x = 0,
		y = 0
	})
	self._rarity_filters_tabs = self._root_panel:tabs({
		tab_align = "center",
		name = "tabs_keybind_types",
		tab_width = 160,
		initial_tab_idx = 1,
		tab_height = 64,
		y = 96,
		dont_trigger_special_buttons = true,
		x = 0,
		on_click_callback = callback(self, self, "on_click_tabs_keybind_types"),
		tabs_params = {
			{
				name = "tab_on_foot",
				callback_param = "normal",
				text = self:translate("menu_options_binding_type_on_foot", true)
			},
			{
				name = "tab_in_vehicle",
				callback_param = "vehicle",
				text = self:translate("menu_options_binding_type_in_vehicle", true)
			}
		}
	})
	local default_controls_keybinds_params = {
		name = "default_controls_keybinds",
		y = 832,
		x = 1472,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_default")),
		on_click_callback = callback(self, self, "on_click_default_controls_keybinds"),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_controls_button = self._root_panel:long_secondary_button(default_controls_keybinds_params)

	self:_layout_controls_keybinds()
	self:bind_controller_inputs()
end

-- Lines 55-60
function RaidMenuOptionsControlsKeybinds:on_click_tabs_keybind_types(controller_category)
	self._controller_category = controller_category

	self._keybind_panel:clear()
	self:_layout_controls_keybinds()
end

-- Lines 64-77
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

-- Lines 79-88
function RaidMenuOptionsControlsKeybinds:close()
	self:_save_controls_keybinds_values()

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	managers.raid_menu:register_on_escape_callback(nil)
	RaidMenuOptionsControlsKeybinds.super.close(self)
end

-- Lines 90-91
function RaidMenuOptionsControlsKeybinds:_save_controls_keybinds_values()
end

-- Lines 93-148
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

-- Lines 150-169
function RaidMenuOptionsControlsKeybinds.controls_info_by_category(category, keybind_type)
	local t = {}

	for _, name in ipairs(MenuCustomizeControllerCreator.CONTROLS) do
		if MenuCustomizeControllerCreator.CONTROLS_INFO[name].category == category and MenuCustomizeControllerCreator.CONTROLS_INFO[name].type == keybind_type then
			table.insert(t, name)
		end
	end

	return t
end

-- Lines 171-212
function RaidMenuOptionsControlsKeybinds:_keybinds_per_type(keybind_type)
	local controller_category = self._controller_category
	self._keybinds[keybind_type] = {}
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(self.controls_info_by_category(controller_category, keybind_type)) do
		local name_id = name
		local connection = connections[name]

		if connection._btn_connections then
			local ordered = MenuCustomizeControllerCreator.AXIS_ORDERED[name]

			for _, btn_name in ipairs(ordered) do
				local btn_connection = connection._btn_connections[btn_name]

				if btn_connection then
					local name_id = name
					local params = {
						localize = "false",
						name = btn_name,
						connection_name = name,
						text_id = utf8.to_upper(managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[btn_name].text_id)),
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
				text_id = utf8.to_upper(managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)),
				binding = connection:get_input_name_list()[1],
				button = name
			}

			table.insert(self._keybinds[keybind_type], params)
		end
	end
end

-- Lines 214-227
function RaidMenuOptionsControlsKeybinds:on_click_default_controls_keybinds()
	local params = {
		title = managers.localization:text("dialog_reset_controls_keybinds_title"),
		message = managers.localization:text("dialog_reset_controls_keybinds_message"),
		callback = function ()
			managers.controller:load_settings("settings/controller_settings")
			managers.controller:clear_user_mod("all", MenuCustomizeControllerCreator.CONTROLS_INFO)
			self:refresh_keybinds()
		end
	}

	managers.menu:show_option_dialog(params)
end

-- Lines 229-232
function RaidMenuOptionsControlsKeybinds:refresh_keybinds()
	self._keybind_panel:clear()
	self:_layout_controls_keybinds()
end

-- Lines 238-249
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
