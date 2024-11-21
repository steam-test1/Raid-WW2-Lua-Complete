core:import("CoreMissionScriptElement")

ElementAIRemove = ElementAIRemove or class(CoreMissionScriptElement.MissionScriptElement)

function ElementAIRemove:init(...)
	ElementAIRemove.super.init(self, ...)
end

function ElementAIRemove:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.use_instigator then
		if instigator then
			if self._values.true_death then
				if instigator:character_damage() and instigator:character_damage().damage_mission then
					instigator:character_damage():damage_mission({
						damage = 9001,
						col_ray = {},
						drop_loot = self._values.drop_loot
					})
				else
					debug_pause_unit(instigator, "[ElementAIRemove:on_executed] instigator lacks 'damage_mission' method.", instigator:character_damage() and instigator:character_damage().damage_mission)
				end
			else
				instigator:brain():set_active(false)
				instigator:base():set_slot(instigator, 0)
			end
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
