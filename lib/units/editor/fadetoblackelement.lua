FadeToBlackElement = FadeToBlackElement or class(MissionElement)

function FadeToBlackElement:init(unit)
	FadeToBlackElement.super.init(self, unit)

	self._hed.state = false

	table.insert(self._save_values, "state")
end

function FadeToBlackElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local state = EWS:CheckBox(panel, "Fade in/out", "")

	state:set_value(self._hed.state)
	state:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "state",
		ctrlr = nil,
		ctrlr = state
	})
	panel_sizer:add(state, 0, 0, "EXPAND")

	local help = {
		text = "Fade in or out, takes 3 seconds. Hardcore.",
		panel = panel,
		sizer = panel_sizer
	}

	self:add_help_text(help)
end
