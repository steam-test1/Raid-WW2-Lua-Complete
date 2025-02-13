ThermiteGrenade = ThermiteGrenade or class(GrenadeBase)
ThermiteGrenade.EVENT_IDS = {
	burn = 1,
	detonate = 2
}

function ThermiteGrenade:destroy()
	if self._fire_data then
		managers.fire:extinguish_fire(self._fire_data, true)
	end
end

function ThermiteGrenade:_setup_from_tweak_data()
	local grenade_entry = self.name_id or "thermite"
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._fire_entry = self._tweak_data.fire_tweak_id
	local fire_tweak = tweak_data.fire[self._fire_entry]
	self._burn_duration = fire_tweak.duration
	local root_point = self._unit:orientation_object()
	self._custom_params = {
		source_unit = self._unit,
		weapon_unit = self._unit,
		parent_object = root_point
	}
	self._burning = false
	self._detonated = false
end

function ThermiteGrenade:set_thrower_unit(unit)
	ThermiteGrenade.super.set_thrower_unit(self, unit)

	local peer = managers.network:session():peer_by_unit(self._thrower_unit)

	if not peer then
		return
	end

	local client_player = peer:id() ~= managers.network:session():local_peer():id()
	local peer_id = client_player and peer:id() or nil
	self._shot_detonate = PlayerSkill.warcry_data("player", "warcry_thermite_shot_detonation", false, peer_id)
	self._finale_detonate = PlayerSkill.warcry_data("player", "warcry_thermite_finale_detonation", false, peer_id)
end

function ThermiteGrenade:update(unit, t, dt)
	if self._hand_held then
		return
	end

	ThermiteGrenade.super.update(self, unit, t, dt)

	if not self._burning then
		return
	end

	if self._burn_duration > 0 then
		self._burn_duration = self._burn_duration - dt
	else
		if self._finale_detonate then
			self:detonate()
		end

		self._burning = false

		if Network:is_server() then
			self._unit:set_slot(0)
		else
			self._unit:set_enabled(false)
		end
	end
end

function ThermiteGrenade:clbk_impact(...)
	if self._collided then
		return
	end

	self._timer = self._tweak_data.init_timer
	self._collided = true
end

function ThermiteGrenade:_detonate(normal)
	if not self._burning then
		self:start_burning(normal)
		managers.network:session():send_to_peers_synched("sync_detonate_molotov_grenade", self._unit, "base", self.EVENT_IDS.burn, normal)
	end
end

function ThermiteGrenade:start_burning(normal)
	local position = self._unit:position()
	self._fire_data = managers.fire:propagate_fire(position, self._fire_entry, self._custom_params)
	self._burning = true

	if not self._shot_detonate then
		return
	end

	local local_player = managers.player:local_player()

	if alive(self._thrower_unit) and alive(local_player) and self._thrower_unit == local_player then
		self._unit:damage():has_then_run_sequence_simple("enable_bullet_hitbox")
	end
end

function ThermiteGrenade:detonate(normal)
	normal = math.UP
	local position = self._unit:position() + normal
	local explosion_data = tweak_data.explosion.thermite_detonate

	managers.fire:propagate_fire(position, "thermite_detonate")
	managers.explosion:play_sound_and_effects(position, normal, explosion_data.range, explosion_data.effect_params)
	managers.explosion:detect_and_give_dmg({
		push_units = false,
		hit_pos = position,
		range = explosion_data.range,
		damage = explosion_data.damage,
		player_damage = explosion_data.player_damage,
		curve_pow = explosion_data.curve_pow,
		collision_slotmask = managers.slot:get_mask("explosion_targets"),
		alert_radius = explosion_data.range,
		user = self._unit,
		ignore_unit = self._unit
	})

	self._burn_duration = self._burn_duration * 0.6
	self._detonated = true

	self._unit:damage():has_then_run_sequence_simple("disable_bullet_hitbox")
end

function ThermiteGrenade:bullet_hit(attacker_unit)
	if self._detonated or not alive(self._thrower_unit) or not self._burning then
		return
	end

	if not alive(attacker_unit) or attacker_unit ~= self._thrower_unit then
		return
	end

	self:detonate()
	managers.network:session():send_to_peers_synched("sync_detonate_molotov_grenade", self._unit, "base", self.EVENT_IDS.detonate, Vector3())
end

function ThermiteGrenade:sync_detonate_molotov_grenade(event_id, normal)
	if event_id == self.EVENT_IDS.burn then
		self:_burn_on_client(normal)
	elseif event_id == self.EVENT_IDS.detonate then
		self:_detonate_on_client(normal)
	end
end

function ThermiteGrenade:sync_fire_data(fire_data)
	self._fire_data = fire_data
end

function ThermiteGrenade:_burn_on_client(normal)
	if not self._burning then
		self:start_burning(normal)
	end
end

function ThermiteGrenade:_detonate_on_client(normal)
	if not self._detonated then
		self:detonate(normal)
	end
end
