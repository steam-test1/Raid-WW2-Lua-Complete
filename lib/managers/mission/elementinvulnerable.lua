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
			self:_set_unit_invulnerable(instigator)
		end
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			for _, unit in ipairs(element:units()) do
				if alive(unit) and unit:character_damage() then
					self:_set_unit_invulnerable(unit)
					Application:debug("[ElementInvulnerable:on_executed] setting unit to invulnerable/immortal: ", unit, self._values.invulnerable, self._values.immortal)
				end
			end
		end
	end

	ElementInvulnerable.super.on_executed(self, instigator)
end

function ElementInvulnerable:client_on_executed(instigator)
end

function ElementInvulnerable:_set_unit_invulnerable(unit)
	local damage_ext = unit:character_damage()

	if damage_ext.set_invulnerable then
		damage_ext:set_invulnerable(self._values.invulnerable)
	end

	if damage_ext.set_immortal then
		damage_ext:set_immortal(self._values.immortal)
	end

	unit:network():send("set_unit_invulnerable", self._values.invulnerable, self._values.immortal)
end
