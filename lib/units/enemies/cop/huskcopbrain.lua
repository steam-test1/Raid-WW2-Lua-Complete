HuskCopBrain = HuskCopBrain or class()
HuskCopBrain._NET_EVENTS = {
	weapon_laser_off = 2,
	weapon_laser_on = 1
}

-- Lines 9-13
function HuskCopBrain:init(unit)
	self._unit = unit
end

-- Lines 17-33
function HuskCopBrain:post_init()
	self._alert_listen_key = "HuskCopBrain" .. tostring(self._unit:key())
	local alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminal")

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, {
		aggression = true,
		bullet = true,
		vo_intimidate = true,
		explosion = true,
		footstep = true,
		vo_cbt = true
	}, self._unit:movement():m_head_pos())

	self._last_alert_t = 0
	self._distance_to_target = 100000

	self._unit:character_damage():add_listener("HuskCopBrain_death" .. tostring(self._unit:key()), {
		"death"
	}, callback(self, self, "clbk_death"))

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR) and self._unit:damage() then
		self._unit:damage():has_then_run_sequence_simple("halloween_2017")
	end
end

-- Lines 37-39
function HuskCopBrain:interaction_voice()
	return self._interaction_voice
end

-- Lines 43-48
function HuskCopBrain:on_intimidated(amount, aggressor_unit)
	amount = math.clamp(math.ceil(amount * 10), 0, 10)

	self._unit:network():send_to_host("long_dis_interaction", amount, aggressor_unit)

	return self._interaction_voice
end

-- Lines 52-66
function HuskCopBrain:clbk_death(my_unit, damage_info)
	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	if self._unit:inventory():equipped_unit() then
		self._unit:inventory():equipped_unit():base():set_laser_enabled(false)
	end

	if self._following_hostage_contour_id then
		self._unit:contour():remove_by_id(self._following_hostage_contour_id)

		self._following_hostage_contour_id = nil
	end
end

-- Lines 70-72
function HuskCopBrain:set_interaction_voice(voice)
	self._interaction_voice = voice
end

-- Lines 76-91
function HuskCopBrain:load(load_data)
	local my_load_data = load_data.brain

	self:set_interaction_voice(my_load_data.interaction_voice)

	if my_load_data.weapon_laser_on then
		self:sync_net_event(self._NET_EVENTS.weapon_laser_on)
	end

	if my_load_data.trade_flee_contour then
		self._unit:contour():add("hostage_trade", nil, nil)
	end

	if my_load_data.following_hostage_contour then
		self._unit:contour():add("friendly", nil, nil)
	end
end

-- Lines 95-97
function HuskCopBrain:on_tied(aggressor_unit)
	self._unit:network():send_to_host("unit_tied", aggressor_unit)
end

-- Lines 101-103
function HuskCopBrain:on_trade(trading_unit)
	self._unit:network():send_to_host("unit_traded", trading_unit)
end

-- Lines 107-108
function HuskCopBrain:on_cool_state_changed(state)
end

-- Lines 112-113
function HuskCopBrain:on_action_completed(action)
end

-- Lines 117-131
function HuskCopBrain:on_alert(alert_data)
	if self._unit:id() == -1 then
		return
	end

	if TimerManager:game():time() - self._last_alert_t < 5 then
		return
	end

	if CopLogicBase._chk_alert_obstructed(self._unit:movement():m_head_pos(), alert_data) then
		return
	end

	self._unit:network():send_to_host("alert", alert_data[5])

	self._last_alert_t = TimerManager:game():time()
end

-- Lines 135-138
function HuskCopBrain:on_long_dis_interacted(amount, aggressor_unit)
	amount = math.clamp(math.ceil(amount * 10), 0, 10)

	self._unit:network():send_to_host("long_dis_interaction", amount, aggressor_unit)
end

-- Lines 142-142
function HuskCopBrain:on_team_set(team_data)
end

-- Lines 146-170
function HuskCopBrain:sync_net_event(event_id)
	if event_id == self._NET_EVENTS.weapon_laser_on then
		self._weapon_laser_on = true

		if self._unit:inventory() and self._unit:inventory():equipped_unit() and self._unit:inventory():equipped_unit():base() and self._unit:inventory():equipped_unit():base().set_laser_enabled then
			self._unit:inventory():equipped_unit():base():set_laser_enabled(true)
		end

		managers.enemy:_destroy_unit_gfx_lod_data(self._unit:key())
	elseif event_id == self._NET_EVENTS.weapon_laser_off then
		self._weapon_laser_on = nil

		if self._unit:inventory() and self._unit:inventory():equipped_unit() and self._unit:inventory():equipped_unit():base() and self._unit:inventory():equipped_unit():base().set_laser_enabled then
			self._unit:inventory():equipped_unit():base():set_laser_enabled(false)
		end

		if not self._unit:character_damage():dead() then
			managers.enemy:_create_unit_gfx_lod_data(self._unit)
		end
	end
end

-- Lines 174-190
function HuskCopBrain:pre_destroy()
	if Network:is_server() then
		self._unit:movement():set_attention()
	else
		self._unit:movement():synch_attention()
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	if self._weapon_laser_on then
		self:sync_net_event(self._NET_EVENTS.weapon_laser_off)
	end

	managers.enemy:_destroy_unit_gfx_lod_data(self._unit:key())
end

-- Lines 194-196
function HuskCopBrain:distance_to_target()
	return self._distance_to_target
end

-- Lines 198-200
function HuskCopBrain:set_distance_to_target(distance)
	self._distance_to_target = distance
end

-- Lines 202-203
function HuskCopBrain:anim_clbk_throw_flare(unit)
end
