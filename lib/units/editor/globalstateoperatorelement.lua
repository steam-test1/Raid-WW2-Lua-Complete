GlobalStateOperatorElement = GlobalStateOperatorElement or class(MissionElement)
GlobalStateOperatorElement.ACTIONS = {
	"set",
	"set_value",
	"clear",
	"default",
	"event"
}

function GlobalStateOperatorElement:init(unit)
	GlobalStateOperatorElement.super.init(self, unit)

	self._hed.action = "set"
	self._hed.flag = ""

	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "action")
	table.insert(self._save_values, "flag")
	table.insert(self._save_values, "value")

	self._actions = GlobalStateOperatorElement.ACTIONS
	self._flags = managers.global_state:flag_names()

	table.sort(self._flags)
end

function GlobalStateOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "flag", self._flags, "Select an flag")
	self:_build_value_combobox(panel, panel_sizer, "action", self._actions, "Select an action for the selected flag")

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
	self:_add_help_text("Changes the global state flags")
end
