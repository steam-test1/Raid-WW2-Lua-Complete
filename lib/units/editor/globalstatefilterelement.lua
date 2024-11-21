GlobalStateFilterElement = GlobalStateFilterElement or class(MissionElement)
GlobalStateFilterElement.STATES = {
	"set",
	"cleared",
	"value"
}

function GlobalStateFilterElement:init(unit)
	GlobalStateFilterElement.super.init(self, unit)

	self._hed.flag = ""
	self._hed.state = ""
	self._hed.check_type = ""

	table.insert(self._save_values, "flag")
	table.insert(self._save_values, "state")
	table.insert(self._save_values, "check_type")
	table.insert(self._save_values, "value")

	self._flags = managers.global_state:flag_names()

	table.sort(self._flags)
end

function GlobalStateFilterElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "flag", self._flags, "Select a flag to test")
	self:_build_value_combobox(panel, panel_sizer, "state", GlobalStateFilterElement.STATES, "What state of the flag to test")
	self:_build_value_combobox(panel, panel_sizer, "check_type", {
		"equal",
		"less_than",
		"greater_than",
		"less_or_equal",
		"greater_or_equal"
	}, "Select which check operation to perform")

	local value_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(value_sizer, 0, 0, "EXPAND")

	local value_name = EWS:StaticText(panel, "Value:", 0, "")

	value_sizer:add(value_name, 1, 0, "ALIGN_CENTER_VERTICAL")

	local value = EWS:TextCtrl(panel, self._hed.value, "", "TE_PROCESS_ENTER")

	value_sizer:add(value, 2, 0, "ALIGN_CENTER_VERTICAL")
	value:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "value",
		ctrlr = value
	})
	value:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "value",
		ctrlr = value
	})

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self:_add_help_text("Filter will execute depending filter condition and global state flags. Check type is applicable only on value global states.")
end
