RaidMenuLeftOptions = RaidMenuLeftOptions or class(RaidGuiBase)

-- Lines 4-7
function RaidMenuLeftOptions:init(ws, fullscreen_ws, node, component_name)
	RaidMenuLeftOptions.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.menu:mark_main_menu(false)
end

-- Lines 9-11
function RaidMenuLeftOptions:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_main_screen_subtitle")
end

-- Lines 14-24
function RaidMenuLeftOptions:_layout()
	RaidMenuLeftOptions.super._layout(self)
	self:_layout_list_menu()

	if RaidMenuCallbackHandler:is_in_main_menu() then
		self:bind_controller_inputs_reset_progress()
	else
		self:bind_controller_inputs()
	end
end

-- Lines 26-28
function RaidMenuLeftOptions:close()
	RaidMenuLeftOptions.super.close(self)
end

-- Lines 30-64
function RaidMenuLeftOptions:_layout_list_menu()
	local list_menu_options_params = {
		selection_enabled = true,
		name = "list_menu_options",
		h = 640,
		w = 480,
		loop_items = true,
		y = 144,
		x = 0,
		on_item_clicked_callback = callback(self, self, "_on_list_menu_options_item_selected"),
		data_source_callback = callback(self, self, "_list_menu_options_data_source")
	}
	self.list_menu_options = self._root_panel:list(list_menu_options_params)

	self.list_menu_options:set_selected(true)

	local default_video_params = {
		name = "default_video",
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
		name = "reset_progress",
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

-- Lines 66-77
function RaidMenuLeftOptions:_list_menu_options_data_source()
	local _list_items = {}

	table.insert(_list_items, {
		callback = "menu_options_on_click_controls",
		text = utf8.to_upper(managers.localization:text("menu_controls"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_video",
		text = utf8.to_upper(managers.localization:text("menu_video"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_sound",
		text = utf8.to_upper(managers.localization:text("menu_sound"))
	})
	table.insert(_list_items, {
		callback = "menu_options_on_click_network",
		text = utf8.to_upper(managers.localization:text("menu_network"))
	})

	return _list_items
end

-- Lines 79-91
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

-- Lines 95-111
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

-- Lines 113-131
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
