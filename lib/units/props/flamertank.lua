FlamerTank = FlamerTank or class()
FlamerTank.DETONATE_EVENT_ID = 1

function FlamerTank:init(unit)
	self._unit = unit
	self._kill_parent = self.kill_parent
	self._init_position = unit:position()
	self._init_rotation = unit:rotation()
	self.explosion_tweak_id = self.explosion_tweak_id
	self.fire_tweak_id = self.fire_tweak_id or "explosive_barrel"
	self._custom_params = {
		source_unit = self._unit
	}
end

function FlamerTank:detonate(in_pos, attacker_unit)
	if self._detonated then
		Application:warn("[FlamerTank:detonate] Attempting to explode after already detonated!", self._unit)

		return
	end

	attacker_unit = alive(attacker_unit) and attacker_unit or nil
	self._detonated = true
	local rot = self._unit:rotation()
	local pos = in_pos + rot:y() * -25

	if Network:is_server() and self._kill_parent and alive(self._unit:parent()) and self._unit:parent():character_damage() then
		local attack_data = {
			damage = self._unit:parent():character_damage():health() * 10
		}

		if attacker_unit then
			attack_data.attacker_unit = attacker_unit
			attack_data.weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		end

		self._unit:parent():character_damage():damage_mission(attack_data)
	end

	local player_unit = managers.player:player_unit()
	local player_attacker = attacker_unit and attacker_unit:base() and attacker_unit:base().is_player

	if player_attacker then
		self._custom_params.attacker_unit = attacker_unit
	end

	if player_attacker and alive(player_unit) and attacker_unit == player_unit or not player_attacker and Network:is_server() then
		self:_detonate_on_client(pos)
		managers.network:session():send_to_peers_synched("sync_detonate_molotov_grenade", self._unit, "base", self.DETONATE_EVENT_ID, pos)
	end
end

function FlamerTank:sync_detonate_molotov_grenade(event_id, position, peer)
	if event_id == self.DETONATE_EVENT_ID then
		local peer_unit = peer and peer:unit()

		if peer_unit then
			self._custom_params.attacker_unit = peer_unit
		end

		self:_detonate_on_client(position)
	end
end

function FlamerTank:_detonate_on_client(position)
	if not self._burning then
		if self.explosion_tweak_id then
			local slot_mask = managers.slot:get_mask("explosion_targets")
			local explosion_data = tweak_data.explosion[self.explosion_tweak_id]
			local user = self._custom_params.attacker_unit

			managers.explosion:play_sound_and_effects(position, math.UP, explosion_data.range, explosion_data.effect_params)
			managers.explosion:detect_and_give_dmg({
				ignite_character = true,
				no_raycast_check_characters = true,
				hit_pos = position,
				damage = explosion_data.damage,
				range = explosion_data.range,
				player_damage = explosion_data.player_damage,
				curve_pow = explosion_data.curve_pow,
				collision_slotmask = slot_mask,
				ignore_unit = self._unit,
				user = user
			})
		end

		managers.fire:propagate_fire(position, self.fire_tweak_id, self._custom_params)

		self._burning = true
	end
end

function FlamerTank:_respawn()
	self._unit:set_position(self._init_position)
	self._unit:set_rotation(self._init_rotation)

	self._detonated = false
	self._burning = false
end
