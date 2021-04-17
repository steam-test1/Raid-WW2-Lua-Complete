core:import("CoreMissionScriptElement")

ElementMissionEnd = ElementMissionEnd or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementMissionEnd:init(...)
	ElementMissionEnd.super.init(self, ...)
end

-- Lines 9-11
function ElementMissionEnd:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 13-48
function ElementMissionEnd:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not managers.raid_job:current_job() then
		debug_pause("[ElementMissionEnd] Triggered element " .. tostring(self._editor_name) .. " but not currently in a job!")

		return
	end

	if game_state_machine:current_state_name() == "event_complete_screen" then
		Application:debug("Mission end element triggered even though the game is already in that state! Element name: " .. tostring(self._editor_name), "Element id: " .. tostring(self._id))
	end

	game_state_machine:change_state_by_name("event_complete_screen")
	ElementMissionEnd.super.on_executed(self, instigator)
end
