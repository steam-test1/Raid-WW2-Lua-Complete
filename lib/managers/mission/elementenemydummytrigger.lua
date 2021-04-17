core:import("CoreMissionScriptElement")

ElementEnemyDummyTrigger = ElementEnemyDummyTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementEnemyDummyTrigger:init(...)
	ElementEnemyDummyTrigger.super.init(self, ...)
end

-- Lines 9-16
function ElementEnemyDummyTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element.add_event_callback then
			element:add_event_callback(self._values.event, callback(self, self, "on_executed"))
		end
	end
end

-- Lines 18-24
function ElementEnemyDummyTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementEnemyDummyTrigger.super.on_executed(self, instigator)
end
