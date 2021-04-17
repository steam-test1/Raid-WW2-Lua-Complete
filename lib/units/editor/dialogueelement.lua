DialogueUnitElement = DialogueUnitElement or class(MissionElement)
DialogueUnitElement.SAVE_UNIT_POSITION = false
DialogueUnitElement.SAVE_UNIT_ROTATION = false

-- Lines 5-19
function DialogueUnitElement:init(unit)
	DialogueUnitElement.super.init(self, unit)

	self._hed.dialogue = "none"
	self._hed.random = "none"
	self._hed.execute_on_executed_when_done = false
	self._hed.use_position = false

	table.insert(self._save_values, "dialogue")
	table.insert(self._save_values, "random")
	table.insert(self._save_values, "execute_on_executed_when_done")
	table.insert(self._save_values, "use_position")
	table.insert(self._save_values, "use_instigator")
end

-- Lines 21-26
function DialogueUnitElement:new_save_values(...)
	local t = DialogueUnitElement.super.new_save_values(self, ...)
	t.position = self._hed.use_position and self._unit:position() or nil

	return t
end

-- Lines 28-36
function DialogueUnitElement:test_element()
	if self._hed.dialogue == "none" then
		return
	end

	managers.dialog:quit_dialog()
	managers.dialog:queue_dialog(self._hed.dialogue, {
		skip_idle_check = true,
		on_unit = managers.dialog._ventrilo_unit
	}, true)
	managers.editor:set_wanted_mute(false)
	managers.editor:set_listener_enabled(true)
end

-- Lines 38-42
function DialogueUnitElement:stop_test_element()
	managers.dialog:quit_dialog()
	managers.editor:set_wanted_mute(true)
	managers.editor:set_listener_enabled(false)
end

-- Lines 44-56
function DialogueUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "dialogue", table.list_add({
		"none"
	}, managers.dialog:conversation_names()), "Select a dialogue from the combobox")
	self:_build_value_combobox(panel, panel_sizer, "random", table.list_add({
		"none"
	}, managers.dialog:random_names()), "Select a random container from the combobox")
	self:_build_value_checkbox(panel, panel_sizer, "execute_on_executed_when_done", "Execute on executed when done")
	self:_build_value_checkbox(panel, panel_sizer, "use_position")
	self:_build_value_checkbox(panel, panel_sizer, "use_instigator")
end
