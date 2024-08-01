core:module("SystemMenuManager")
require("lib/managers/dialogs/KeyboardInputDialog")

XB1KeyboardInputDialog = XB1KeyboardInputDialog or class(KeyboardInputDialog)

function XB1KeyboardInputDialog:show()
	self._manager:event_dialog_shown(self)

	local end_parameter_list = {}

	table.insert(end_parameter_list, self:max_count())
	table.insert(end_parameter_list, callback(self, self, "done_callback"))
	XboxLive:show_keyboard_ui(self:get_platform_id(), self:input_type(), self:input_text(), self:title(), self:text(), unpack(end_parameter_list))

	return true
end

function XB1KeyboardInputDialog:done_callback(input_text)
	KeyboardInputDialog.done_callback(self, true, input_text)
end
