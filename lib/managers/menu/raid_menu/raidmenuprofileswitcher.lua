RaidMenuProfileSwitcher = RaidMenuProfileSwitcher or class(RaidGuiBase)
RaidMenuProfileSwitcher.PROFILE_NAME_W = 550

function RaidMenuProfileSwitcher:init(ws, fullscreen_ws, node, component_name)
	RaidMenuProfileSwitcher.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuProfileSwitcher:_layout()
	self._object = self._root_panel:panel({
		x = 0,
		name = "profile_switcher_object_panel",
		h = nil,
		w = nil,
		y = 0,
		w = self._root_panel:w(),
		h = self._root_panel:h()
	})

	if IS_XB1 then
		self:_bind_raid_controller_inputs()
	end
end

function RaidMenuProfileSwitcher:_bind_raid_controller_inputs()
	local bindings = {
		{
			callback = nil,
			label = "",
			key = nil,
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_show_account_picker")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = nil,
		controller = {
			"menu_legend_switch_profile"
		}
	}

	self:set_legend(legend)
end

function RaidMenuProfileSwitcher:_show_account_picker()
	managers.user:confirm_select_user_callback(nil, true)
end

function RaidMenuProfileSwitcher:_setup_properties()
	self._panel_x = 0
	self._panel_y = self._ws:height() - RaidGuiBase.PADDING
	self._panel_w = self._ws:width()
	self._panel_h = RaidGuiBase.PADDING
	self._panel_layer = RaidGuiBase.FOREGROUND_LAYER
	self._panel_is_root_panel = true
end
