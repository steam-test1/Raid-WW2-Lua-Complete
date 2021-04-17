core:import("CoreMissionScriptElement")

ElementVariableGet = ElementVariableGet or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementVariableGet:init(...)
	ElementVariableGet.super.init(self, ...)
end

-- Lines 9-21
function ElementVariableGet:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementVariableGet.super.on_executed(self, instigator)
end

-- Lines 23-25
function ElementVariableGet:client_on_executed(...)
	self:on_executed(...)
end
