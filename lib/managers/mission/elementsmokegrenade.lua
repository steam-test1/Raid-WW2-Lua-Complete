core:import("CoreMissionScriptElement")

ElementSmokeGrenade = ElementSmokeGrenade or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSmokeGrenade:init(...)
	ElementSmokeGrenade.super.init(self, ...)
end

function ElementSmokeGrenade:client_on_executed(...)
end

function ElementSmokeGrenade:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	debug_pause("[ElementSmokeGrenade] NO LONGER USED, REMOVE ME FROM LEVEL!", inspect(self))
	ElementSmokeGrenade.super.on_executed(self, instigator)
end
