core:import("CoreMissionScriptElement")

ElementMetalDetector = ElementMetalDetector or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMetalDetector:init(...)
	ElementMetalDetector.super.init(self, ...)
end

function ElementMetalDetector:client_on_executed(...)
	return
end

function ElementMetalDetector:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementMetalDetector.super.on_executed(self, instigator)
end
