core:import("CoreMissionScriptElement")

ElementAIRemove = ElementAIRemove or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementAIRemove:init(...)
	ElementAIRemove.super.init(self, ...)
end

-- Lines 9-33
function ElementAIRemove:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.use_instigator then
		if self._values.true_death then
			instigator:character_damage():damage_mission({
				damage = 1000,
				col_ray = {},
				drop_loot = self._values.drop_loot
			})
		else
			instigator:brain():set_active(false)
			instigator:base():set_slot(instigator, 0)
		end
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			if self._values.true_death then
				element:kill_all_units()
			else
				element:unspawn_all_units()
			end
		end
	end

	ElementAIRemove.super.on_executed(self, instigator)
end
