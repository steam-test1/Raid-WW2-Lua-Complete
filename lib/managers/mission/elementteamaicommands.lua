core:import("CoreMissionScriptElement")

ElementTeamAICommands = ElementTeamAICommands or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementTeamAICommands:init(...)
	ElementTeamAICommands.super.init(self, ...)
end

-- Lines 9-49
function ElementTeamAICommands:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementTeamAICommands.super.on_executed(self, instigator)
end

-- Lines 51-53
function ElementTeamAICommands:client_on_executed(...)
	self:on_executed(...)
end
