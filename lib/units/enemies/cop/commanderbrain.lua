CommanderBrain = CommanderBrain or class(CopBrain)
CommanderBrain.INTENSITY_INCREASE = 0.2

-- Lines 5-7
function CommanderBrain:stealth_action_allowed()
	return false
end

-- Lines 9-17
function CommanderBrain:init(unit)
	CommanderBrain.super.init(self, unit)

	if Network:is_server() then
		managers.enemy:register_commander()

		self._registered = true
	end
end

-- Lines 19-26
function CommanderBrain:pre_destroy(unit)
	CommanderBrain.super.pre_destroy(self, unit)

	if Network:is_server() and self._registered then
		managers.enemy:unregister_commander()

		self._registered = false
	end
end

-- Lines 29-36
function CommanderBrain:clbk_death(my_unit, damage_info)
	CommanderBrain.super.clbk_death(self, my_unit, damage_info)

	if Network:is_server() and self._registered then
		managers.enemy:unregister_commander()

		self._registered = false
	end
end
