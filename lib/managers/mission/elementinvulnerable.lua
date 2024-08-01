core:import("CoreMissionScriptElement")

ElementInvulnerable = ElementInvulnerable or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInvulnerable:init(...)
	ElementInvulnerable.super.init(self, ...)
end

function ElementInvulnerable:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.apply_instigator then
		if alive(instigator) and instigator:character_damage() then
			local cd = instigator:character_damage()

			if cd.set_invulnerable then
				cd:set_invulnerable(self._values.invulnerable)
			end

			if cd.set_immortal then
				cd:set_immortal(self._values.immortal)
			end
		end
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			for _, unit in ipairs(element:units()) do
				if alive(unit) and unit:character_damage() then
					Application:debug("[ElementInvulnerable:on_executed] Unit", unit, "is set to Invuln/Immort", self._values.invulnerable, self._values.immortal)

					local cd = unit:character_damage()

					if cd.set_invulnerable then
						cd:set_invulnerable(self._values.invulnerable)
					end

					if cd.set_immortal then
						cd:set_immortal(self._values.immortal)
					end
				end
			end
		end
	end

	ElementInvulnerable.super.on_executed(self, instigator)
end
