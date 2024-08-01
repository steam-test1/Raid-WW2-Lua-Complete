core:module("SystemMenuManager")
require("lib/managers/dialogs/AchievementsDialog")

XB1AchievementsDialog = XB1AchievementsDialog or class(AchievementsDialog)

-- Lines 7-13
function XB1AchievementsDialog:init(manager, data)
	AchievementsDialog.init(self, manager, data)
end

-- Lines 15-22
function XB1AchievementsDialog:show()
	self._manager:event_dialog_shown(self)
	XboxLive:show_achievements_ui(self:get_platform_id())

	self._show_time = TimerManager:main():time()

	return true
end

-- Lines 24-28
function XB1AchievementsDialog:update(t, dt)
	if self._show_time and self._show_time ~= t and not Application:is_showing_system_dialog() then
		self:done_callback()
	end
end

-- Lines 30-34
function XB1AchievementsDialog:done_callback()
	self._show_time = nil

	AchievementsDialog.done_callback(self)
end
