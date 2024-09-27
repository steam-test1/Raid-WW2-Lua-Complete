CommanderBrain = CommanderBrain or class(CopBrain)
CommanderBrain.INTENSITY_INCREASE = 0.2

function CommanderBrain:stealth_action_allowed()
	return false
end

function CommanderBrain:post_init(unit)
	CommanderBrain.super.post_init(self, unit)

	if Network:is_server() then
		managers.enemy:register_commander()

		self._registered = true
	end

	if self._unit:damage() then
		self._unit:damage():has_then_run_sequence_simple("spawn_radio_pack")
	end
end

function CommanderBrain:pre_destroy(unit)
	CommanderBrain.super.pre_destroy(self, unit)

	if Network:is_server() and self._registered then
		managers.enemy:unregister_commander()

		self._registered = false
	end
end

function CommanderBrain:clbk_death(unit, damage_info)
	CommanderBrain.super.clbk_death(self, unit, damage_info)

	if Network:is_server() and self._registered then
		managers.enemy:unregister_commander()

		self._registered = false
	end
end
