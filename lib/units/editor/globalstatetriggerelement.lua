GlobalStateTriggerElement = GlobalStateTriggerElement or class(MissionElement)
GlobalStateTriggerElement.ACTIONS = {
	"on_set",
	"on_clear",
	"on_event",
	"on_value"
}

function GlobalStateTriggerElement:init(unit)
	GlobalStateTriggerElement.super.init(self, unit)

	self._hed.flag = ""
	self._hed.on_set = false
	self._hed.on_clear = false

	table.insert(self._save_values, "flag")
	table.insert(self._save_values, "on_set")
	table.insert(self._save_values, "on_clear")
	table.insert(self._save_values, "on_event")
	table.insert(self._save_values, "on_value")
	table.insert(self._save_values, "check_type")
	table.insert(self._save_values, "value")

	self._flags = managers.global_state:flag_names()

	table.sort(self._flags)
end

function GlobalStateTriggerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local flag_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Flag options")
	local flag_element_sizer = EWS:BoxSizer("HORIZONTAL")

	flag_sizer:add(flag_element_sizer, 0, 1, "EXPAND,LEFT")
	self:_build_value_combobox(panel, flag_sizer, "flag", self._flags, "Select a flag")
	self:_build_value_checkbox(panel, flag_sizer, "on_set", "On Flag Set")
	self:_build_value_checkbox(panel, flag_sizer, "on_clear", "On Flag Clear")
	self:_build_value_checkbox(panel, flag_sizer, "on_event", "On Event")
	self:_build_value_checkbox(panel, flag_sizer, "on_value", "On Value")
	panel_sizer:add(flag_sizer, 0, 0, "EXPAND,LEFT")
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

	local additional_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Adittional options")
	local additional_element_sizer = EWS:BoxSizer("HORIZONTAL")

	additional_sizer:add(additional_element_sizer, 0, 1, "EXPAND,LEFT")

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self:_add_help_text("Trigger depending on global state flags. Check type is only applicable on value elements.")
end
