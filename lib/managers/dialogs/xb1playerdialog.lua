core:module("SystemMenuManager")
require("lib/managers/dialogs/PlayerDialog")

XB1PlayerDialog = XB1PlayerDialog or class(PlayerDialog)

function XB1PlayerDialog:init(manager, data)
	PlayerDialog.init(self, manager, data)
end

function XB1PlayerDialog:show()
	self._manager:event_dialog_shown(self)

	local player_id = self:player_id()

	if player_id then
		XboxLive:show_gamer_card_ui(self:get_platform_id(), self:player_id())
	else
		Application:error("[SystemMenuManager] Unable to display player dialog since no player id was specified.")
	end

	self._show_time = TimerManager:main():time()

	return true
end

function XB1PlayerDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

function XB1PlayerDialog:done_callback()
	self._show_time = nil

	PlayerDialog.done_callback(self)
end
