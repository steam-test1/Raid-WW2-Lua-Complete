RaidMenuLeftOptions = RaidMenuLeftOptions or class(RaidGuiBase)

function RaidMenuLeftOptions:init(ws, fullscreen_ws, node, component_name)
	RaidMenuLeftOptions.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.menu:mark_main_menu(false)
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
		name = "list_menu_options",
		loop_items = true,
		selection_enabled = true,
		data_source_callback = nil,
		on_item_clicked_callback = nil,
		h = 640,
		w = 480,
		y = 144,
		x = 0,
		on_item_clicked_callback = callback(self, self, "_on_list_menu_options_item_selected"),
		data_source_callback = callback(self, self, "_list_menu_options_data_source")
	}
	self.list_menu_options = self._root_panel:list(list_menu_options_params)

	self.list_menu_options:set_selected(true)

	local default_video_params = {
		layer = nil,
		name = "default_video",
		on_click_callback = nil,
		text = nil,
		y = 832,
		x = 1472,
		text = utf8.to_upper(managers.localization:text("menu_option_default")),
		on_click_callback = callback(self, self, "_on_list_menu_options_item_selected", {
			callback = "menu_options_on_click_default"
		}),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_video_button = self._root_panel:long_secondary_button(default_video_params)
	local reset_progress_params = {
		layer = nil,
		name = "reset_progress",
		on_click_callback = nil,
		text = nil,
		y = 768,
		x = 1472,
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
	local _list_items = {}

	table.insert(_list_items, {
		callback = "menu_options_on_click_controls",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_controls"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_video",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_video"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_interface",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_interface"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_sound",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_sound"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_network",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_network"))
	})

	return _list_items
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

function RaidMenuLeftOptions:bind_controller_inputs()
	local bindings = {
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_default"
			})
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = nil,
		keyboard = nil,
		controller = {
			"menu_legend_back",
			"menu_legend_default_options"
		},
		keyboard = {
			{
				callback = nil,
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
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_reset_progress"
			})
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_list_menu_options_item_selected", {
				callback = "menu_options_on_click_default"
			})
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = nil,
		keyboard = nil,
		controller = {
			"menu_legend_back",
			"menu_legend_clear_progress",
			"menu_legend_default_options"
		},
		keyboard = {
			{
				callback = nil,
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end
