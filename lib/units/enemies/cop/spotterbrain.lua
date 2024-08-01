SpotterBrain = SpotterBrain or class(CopBrain)

function SpotterBrain:stealth_action_allowed()
	return false
end

function SpotterBrain:reset_spotter()
	Application:debug("[SpotterBrain:reset_spotter()]")
	CopLogicBase._set_attention_obj(self._logic_data, nil)

	self._logic_data.internal_data.shooting = nil

	CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)
	managers.groupai:state():_clear_character_criminal_suspicion_data(self._unit:key())

	self.on_cooldown = false
end

function SpotterBrain:schedule_spotter_reset(delay)
	Application:debug("[SpotterBrain:schedule_spotter_reset()] delay", delay)

	self.on_cooldown = true

	managers.queued_tasks:queue(nil, self.reset_spotter, self, nil, delay, nil)
end

function SpotterBrain:action_request(action)
	if action.type == "shoot" then
		return
	end

	return SpotterBrain.super.action_request(self, action)
end

function SpotterBrain:anim_clbk_throw_flare()
	self._unit:sound():say("spotter_flare_thrown", true, true)
	managers.barrage:spawn_flare(self._unit, self._spotted_unit)
end

function SpotterBrain:destroy()
	managers.queued_tasks:unqueue_all(nil, self)
end
