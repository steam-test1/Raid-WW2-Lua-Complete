FragGrenade = FragGrenade or class(GrenadeBase)
FragGrenade.MAX_CLUSTER_ATTEMPTS = 15

function FragGrenade:destroy()
	if self._delete_queue_id then
		managers.queued_tasks:unqueue(self._delete_queue_id)

		self._delete_queue_id = nil
	end
end

function FragGrenade:_setup_from_tweak_data()
	local grenade_entry = self.name_id
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._init_timer = self._tweak_data.init_timer or 2.5
	self._mass_look_up_modifier = self._tweak_data.mass_look_up_modifier
	self._range = self._tweak_data.range

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_GRENADE_RADIUS) then
		self._range = self._range + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_GRENADE_RADIUS) * 100 or 0)
	end

	self._effect_name = self._tweak_data.effect_name or "effects/vanilla/explosions/exp_hand_grenade_001"
	self._curve_pow = self._tweak_data.curve_pow or 3
	self._killzone_range = self._tweak_data.killzone_range or 0.5
	self._damage = self._tweak_data.damage

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_GRENADE_DAMAGE) then
		self._damage = self._damage * (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_GRENADE_DAMAGE) or 1)
	end

	self._alert_radius = self._tweak_data.alert_radius
	self._player_damage = self._tweak_data.player_damage
	self._targets_slotmask = managers.slot:get_mask("trip_mine_targets")
	local sound_event = self._tweak_data.sound_event or "grenade_explode"
	self._custom_params = {
		sound_muffle_effect = true,
		camera_shake_max_mul = 4,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}
end

function FragGrenade:set_thrower_unit(unit)
	FragGrenade.super.set_thrower_unit(self, unit)

	self._clusters_to_spawn = 0
	self._airburst_near_enemy = false
	local peer = managers.network:session():peer_by_unit(self._thrower_unit)
	self.cluster_range = self._range
	self.cluster_damage = self._damage

	if peer then
		local wpn_tweak = self:weapon_tweak_data()
		local client_player = peer:id() ~= managers.network:session():local_peer():id()
		local peer_id = client_player and peer:id() or nil
		local thrower_unit = client_player and self._thrower_unit or nil
		self._clusters_to_spawn = PlayerSkill.warcry_data("player", "warcry_grenade_clusters", 0, peer_id)
		self.cluster_range = self.cluster_range * (PlayerSkill.warcry_data("player", "warcry_grenade_cluster_range", 2, peer_id) - 1)
		self.cluster_damage = self.cluster_damage * (PlayerSkill.warcry_data("player", "warcry_grenade_cluster_damage", 2, peer_id) - 1)

		if wpn_tweak.can_airburst then
			self._airburst_near_enemy = PlayerSkill.warcry_data("player", "warcry_grenade_airburst", false, peer_id)
		end

		self._range = self._range * PlayerSkill.skill_data("player", "grenadier_grenade_radius_multiplier", 1, thrower_unit)
		local pdamage_mul = PlayerSkill.skill_data("player", "blammfu_grenade_player_damage_reduction", 1, thrower_unit)
		self._player_damage = self._player_damage * pdamage_mul
	end
end

function FragGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function FragGrenade:_on_collision(col_ray)
	self:_detonate()
end

function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	FragGrenade.super._detonate(self, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)

	local pos = self._unit:position() + GrenadeBase.DETONATE_UP_OFFSET
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	self._unit:set_enabled(false)
	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters, results = managers.explosion:detect_and_give_dmg({
		push_units = true,
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self._unit,
		owner = self._unit,
		killzone_range = self._killzone_range
	})
	local thrower_peer_id = self:get_thrower_peer_id()

	if thrower_peer_id and results then
		if results.count_cop_kills >= 5 then
			self:_award_achievement_multi_kill(thrower_peer_id)
		end

		if results.count_cop_kills > 0 then
			for _, hit_unit in pairs(hit_units) do
				if hit_unit:character_damage() and hit_unit:character_damage():dead() and hit_unit:base() and hit_unit:base().is_special_type and hit_unit:base():is_special_type(CharacterTweakData.SPECIAL_UNIT_TYPE_SPOTTER) then
					self:_award_achievement_spotter_grenade(thrower_peer_id)

					break
				end
			end
		end
	end

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self:_detonate_with_clusters()

	self._delete_queue_id = "delete_grenade_" .. tostring(self._unit:key())

	managers.queued_tasks:queue(self._delete_queue_id, self.delete_unit, self, nil, 0.1)
end

function FragGrenade:delete_unit()
	if Network:is_server() and alive(self._unit) then
		self._unit:set_slot(0)
	end
end

function FragGrenade:_detonate_with_clusters()
	if not self._thrower_unit then
		return
	end

	local spawn_attempts = 0

	if self._clusters_to_spawn > 0 then
		local index = tweak_data.blackmarket:get_index_from_projectile_id("cluster")
		local unit_position = self._unit:position()
		unit_position = Vector3(unit_position.x, unit_position.y, unit_position.z + 2)
		local clusters_spawned = 0

		while clusters_spawned < self._clusters_to_spawn do
			local spawn_position = Vector3(unit_position.x + math.random(-25, 25), unit_position.y + math.random(-25, 25), unit_position.z + math.random(20, 40))
			local collision = World:raycast("ray", unit_position, spawn_position, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

			if not collision then
				local direction = (spawn_position - unit_position):normalized()
				local cluster = ProjectileBase.throw_projectile(index, spawn_position, direction, managers.network:session():local_peer():id(), nil, self.name_id)

				cluster:base():set_range(self.cluster_range)
				cluster:base():set_damage(self.cluster_damage)

				clusters_spawned = clusters_spawned + 1
			elseif FragGrenade.MAX_CLUSTER_ATTEMPTS < spawn_attempts then
				return
			end

			spawn_attempts = spawn_attempts + 1
		end
	end
end

function FragGrenade:_award_achievement_multi_kill(thrower_peer_id)
	Application:info("[FragGrenade:achievements] ach_kill_enemies_with_single_grenade_5")

	local achievement_id = "ach_kill_enemies_with_single_grenade_5"

	if thrower_peer_id == 1 then
		managers.achievment:award(achievement_id)
	else
		local thrower_peer = managers.network:session():peer(thrower_peer_id)

		if thrower_peer then
			managers.network:session():send_to_peer(thrower_peer, "sync_award_achievement", achievement_id)
		end
	end
end

function FragGrenade:_award_achievement_spotter_grenade(thrower_peer_id)
	Application:info("[FragGrenade:achievements] ach_grenade_kill_spotter")

	local achievement_id = "ach_grenade_kill_spotter"

	if thrower_peer_id == 1 then
		managers.achievment:award(achievement_id)
	else
		local thrower_peer = managers.network:session():peer(thrower_peer_id)

		managers.network:session():send_to_peer(thrower_peer, "sync_award_achievement", achievement_id)
	end
end

function FragGrenade:_detonate_on_client()
	local pos = self._unit:position() + GrenadeBase.DETONATE_UP_OFFSET
	local range = self._range

	self._unit:set_enabled(false)
	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end

function FragGrenade:bullet_hit()
	if not Network:is_server() then
		return
	end

	self._timer = nil

	self:_detonate()
end

function FragGrenade:_check_targets()
	local units = World:find_units_quick("sphere", self._ray_from_pos or self._unit:position(), self._tweak_data.enemy_proximity_range or self._tweak_data.range, self._targets_slotmask)

	return units
end

function FragGrenade:_filtered_check_targets()
	if not managers.network:session() then
		return
	end

	local ray = self:_check_targets()

	if not ray then
		return
	end

	for _, unit in ipairs(ray) do
		if alive(unit) then
			local valid = tweak_data.character[unit:base()._tweak_table] and not tweak_data.character[unit:base()._tweak_table].is_escort or unit:brain() and unit:brain().is_tank and unit:brain():is_tank()

			if valid and unit:movement() and unit:movement():team() then
				local team_id_player = tweak_data.levels:get_default_team_ID("player")
				local team_id_ray = unit:movement():team().id

				Application:debug("[GrenadeBase:DemoAirbust] filtering check targets", managers.groupai:state():team_data(team_id_player).foes[team_id_ray])

				if managers.groupai:state():team_data(team_id_player).foes[team_id_ray] then
					return true
				end
			end
		end
	end

	return false
end
