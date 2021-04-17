core:import("CoreMissionScriptElement")
core:import("CoreClass")

MissionScriptElement = MissionScriptElement or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-8
function MissionScriptElement:init(...)
	MissionScriptElement.super.init(self, ...)
end

-- Lines 10-12
function MissionScriptElement:client_on_executed()
end

-- Lines 14-19
function MissionScriptElement:on_executed(...)
	if Network:is_client() then
		return
	end

	MissionScriptElement.super.on_executed(self, ...)
end

CoreClass.override_class(CoreMissionScriptElement.MissionScriptElement, MissionScriptElement)
