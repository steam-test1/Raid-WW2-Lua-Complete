RaidMenuLeftOptions = RaidMenuLeftOptions or class(RaidGuiBase)

function RaidMenuLeftOptions:init(ws, fullscreen_ws, node, component_name)
	RaidMenuLeftOptions.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.menu:mark_main_menu(false)
	self.list_menu_options:show()
end

function RaidMenuLeftOptions:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_main_screen_subtitle")
end

function RaidMenuLeftOptions:_layout()
	RaidMenuLeftOptions.super._layout(self)
	self:_layout_list_menu()

	if RaidMenuCallbackHandler:is_in_main_menu() then
		self:bind_controller_inputs_reset_progress()
	else
		self:bind_controller_inputs()
	end
end

function RaidMenuLeftOptions:close()
	RaidMenuLeftOptions.super.close(self)
end

function RaidMenuLeftOptions:_layout_list_menu()
	local list_menu_options_params = {
		loop_items = true,
		h = 640,
		w = 480,
		y = 144,
		x = 0,
		name = "list_menu_options",
		selection_enabled = true,
		vertical_spacing = 2,
		on_item_clicked_callback = callback(self, self, "_on_list_menu_options_item_selected"),
		data_source_callback = callback(self, self, "_list_menu_options_data_source"),
		item_class = RaidGUIControlListItemMenu
	}
	self.list_menu_options = self._root_panel:create_custom_control(RaidGUIControlSingleSelectList, list_menu_options_params)

	self.list_menu_options:set_selected(true)

	local default_video_params = {
		y = 832,
		x = 1472,
		name = "default_video",
		text = utf8.to_upper(managers.localization:text("menu_option_default")),
		on_click_callback = callback(self, self, "_on_list_menu_options_item_selected", {
			callback = "menu_options_on_click_default"
		}),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_video_button = self._root_panel:long_secondary_button(default_video_params)
	local reset_progress_params = {
		y = 768,
		x = 1472,
		name = "reset_progress",
		text = utf8.to_upper(managers.localization:text("menu_clear_progress")),
		on_click_callback = callback(self, self, "_on_list_menu_options_item_selected", {
			callback = "menu_options_on_click_reset_progress"
		}),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._reset_progress_button = self._root_panel:long_secondary_button(reset_progress_params)

	self._reset_progress_button:set_visible(RaidMenuCallbackHandler:is_in_main_menu())
end

function RaidMenuLeftOptions:_list_menu_options_data_source()
	local list_items = {
		{
			callback = "menu_options_on_click_controls",
			icon = "menu_item_controls",
			text = managers.localization:to_upper_text("menu_controls")
		},
		{
			callback = "menu_options_on_click_video",
			icon = "menu_item_video",
			text = managers.localization:to_upper_text("menu_video")
		},
		{
			callback = "menu_options_on_click_interface",
			icon = "menu_item_interface",
			text = managers.localization:to_upper_text("menu_interface")
		},
		{
			callback = "menu_options_on_click_sound",
			icon = "menu_item_sound",
			text = managers.localization:to_upper_text("menu_sound")
		}
	}

	table.insert(list_items, {
		callback = "menu_options_on_click_network",
		icon = "menu_item_network",
		text = managers.localization:to_upper_text("menu_network")
	})

	return list_items
end

function RaidMenuLeftOptions:_on_list_menu_options_item_selected(data)
	if not data.callback then
		return
	end

	self._callback_handler = self._callback_handler or RaidMenuCallbackHandler:new()
	local on_click_callback = callback(self._callback_handler, self._callback_handler, data.callback)

	if on_click_callback then
		on_click_callback()
	end
end

function RaidMenuLeftOptions:_animate_close()
	local duration = 0.22
	local t = 0

	self.list_menu_options:animate_hide()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._ws_panel:set_alpha(current_alpha)
	end

	self:_close()
end

function RaidMenuLeftOptions:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_default"
			})
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_default_options"
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

function RaidMenuLeftOptions:bind_controller_inputs_reset_progress()
	local bindings = {
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_reset_progress"
			})
		},
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_default"
			})
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_clear_progress",
			"menu_legend_default_options"
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
