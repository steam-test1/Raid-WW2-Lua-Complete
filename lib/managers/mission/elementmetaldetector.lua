core:import("CoreMissionScriptElement")

ElementMetalDetector = ElementMetalDetector or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementMetalDetector:init(...)
	ElementMetalDetector.super.init(self, ...)
end

-- Lines 9-10
function ElementMetalDetector:client_on_executed(...)
end

-- Lines 12-18
function ElementMetalDetector:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementMetalDetector.super.on_executed(self, instigator)
end
