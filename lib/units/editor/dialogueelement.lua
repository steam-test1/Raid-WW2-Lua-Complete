DialogueUnitElement = DialogueUnitElement or class(MissionElement)
DialogueUnitElement.SAVE_UNIT_POSITION = false
DialogueUnitElement.SAVE_UNIT_ROTATION = false

function DialogueUnitElement:init(unit)
	DialogueUnitElement.super.init(self, unit)

	self._hed.dialogue = "none"
	self._hed.random = "none"
	self._hed.execute_on_executed_when_done = false
	self._hed.use_position = false
	self._hed.repeat_interval = 35

	table.insert(self._save_values, "dialogue")
	table.insert(self._save_values, "random")
	table.insert(self._save_values, "execute_on_executed_when_done")
	table.insert(self._save_values, "use_position")
	table.insert(self._save_values, "use_instigator")
	table.insert(self._save_values, "repeating")
	table.insert(self._save_values, "repeat_interval")
end

function DialogueUnitElement:new_save_values(...)
	local t = DialogueUnitElement.super.new_save_values(self, ...)
	t.position = self._hed.use_position and self._unit:position() or nil

	return t
end

function DialogueUnitElement:test_element()
	if self._hed.dialogue == "none" and self._hed.random == "none" then
		return
	end

	managers.dialog:quit_dialog()

	local queue_dialog_unit = {
		skip_idle_check = true,
		on_unit = managers.dialog._ventrilo_unit,
		done_cbk = callback(self, self, "stop_test_element")
	}

	managers.dialog._ventrilo_unit:set_position(managers.viewport:get_current_camera_position())

	if self._hed.dialogue and self._hed.dialogue ~= "none" then
		managers.dialog:queue_dialog(self._hed.dialogue, queue_dialog_unit, true)
	end

	if self._hed.random and self._hed.random ~= "none" then
		local line = managers.dialog:get_random_queue_dialogue(self._hed.random)

		managers.dialog:queue_dialog(line, queue_dialog_unit, true)
	end

	managers.editor:set_wanted_mute(false)
	managers.editor:set_listener_enabled(true)
end

function DialogueUnitElement:stop_test_element()
	managers.dialog:quit_dialog(true)
	managers.editor:set_wanted_mute(true)
	managers.editor:set_listener_enabled(false)
end

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
	self:_build_value_checkbox(panel, panel_sizer, "repeating", "Automatically repeat the dialogue on a set interval")
	self:_build_value_number(panel, panel_sizer, "repeat_interval", {
		max = 900,
		min = 1,
		floats = 2
	}, "The interval to repeat the dialog on, in seconds")
end
