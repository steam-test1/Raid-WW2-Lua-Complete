GrenadeCluster = GrenadeCluster or class(GrenadeBase)

function GrenadeCluster:init(unit)
	GrenadeCluster.super.init(self, unit)
end

function GrenadeCluster:_setup_from_tweak_data()
	local grenade_entry = self.name_id
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._mass_look_up_modifier = self._tweak_data.mass_look_up_modifier
	self._range = self._tweak_data.range
	self._effect_name = self._tweak_data.effect_name or "effects/vanilla/explosions/exp_cluster_001"
	self._curve_pow = self._tweak_data.curve_pow or 3
	self._damage = self._tweak_data.damage
	self._killzone_range = self._tweak_data.killzone_range or 0.1
	self._alert_radius = self._tweak_data.alert_radius
	self._player_damage = self._tweak_data.player_damage
	local sound_event = self._tweak_data.sound_event or "grenade_explode"
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}
end

function GrenadeCluster:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function GrenadeCluster:_on_collision(col_ray)
	self:_detonate()
end

function GrenadeCluster:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local thrower_peer_id = self:get_thrower_peer_id()

	if thrower_peer_id then
		local client_player = thrower_peer_id ~= managers.network:session():local_peer():id()
		local peer_id = client_player and thrower_peer_id or nil
		self._range = self._range * (PlayerSkill.warcry_data("player", "warcry_grenade_cluster_range", 2, peer_id) - 1)
		self._damage = self._damage * (PlayerSkill.warcry_data("player", "warcry_grenade_cluster_damage", 2, peer_id) - 1)
	end

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self._unit,
		killzone_range = self._killzone_range
	})

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self._unit:set_slot(0)
end

function GrenadeCluster:set_range(range)
	self._range = range
end

function GrenadeCluster:set_damage(damage)
	self._damage = damage
end

function GrenadeCluster:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range
	local thrower_peer_id = self:get_thrower_peer_id()
	local parent_projectile_id = self:get_parent_projectile_id()

	if thrower_peer_id and parent_projectile_id then
		self._range = tweak_data.projectiles[parent_projectile_id].range
		self._damage = tweak_data.projectiles[parent_projectile_id].damage

		if thrower_peer_id == managers.network:session():local_peer():id() then
			self._range = self._range * managers.player:upgrade_value("player", "warcry_grenade_cluster_range", 1)
			self._damage = self._damage * managers.player:upgrade_value("player", "warcry_grenade_cluster_damage", 1)
		else
			self._range = self._range * managers.warcry:peer_warcry_upgrade_value(thrower_peer_id, "player", "warcry_grenade_cluster_range", 1)
			self._damage = self._damage * managers.warcry:peer_warcry_upgrade_value(thrower_peer_id, "player", "warcry_grenade_cluster_damage", 1)
		end
	end

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end

function GrenadeCluster:bullet_hit()
	if not Network:is_server() then
		return
	end

	print("GrenadeCluster:bullet_hit()")

	self._timer = nil

	self:_detonate()
end
