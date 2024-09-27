SentryGunDamage = SentryGunDamage or class()
SentryGunDamage._HEALTH_GRANULARITY = CopDamage._HEALTH_GRANULARITY
SentryGunDamage._ATTACK_VARIANTS = CopDamage._ATTACK_VARIANTS

function SentryGunDamage:init(unit)
	self._unit = unit
	self._ext_movement = unit:movement()

	unit:base():post_init()
	unit:brain():post_init()
	unit:movement():post_init()

	self._HEALTH_INIT = 10000

	if self._bag_body_name then
		self._bag_body_name_ids = Idstring(self._bag_body_name)
	end

	if self._invulnerable_body_names then
		self._invulnerable_bodies = {}
		local names_split = string.split(self._invulnerable_body_names, " ")

		for _, name_ids in ipairs(names_split) do
			self._invulnerable_bodies[name_ids:key()] = true
		end
	end

	self._health = self._HEALTH_INIT
	self._sync_dmg_leftover = 0

	if self._ignore_client_damage then
		if Network:is_server() then
			self._HEALTH_GRANULARITY = 5
		else
			self._health_ratio = 1
		end
	end

	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._invulnerable = true
	self._no_blood = true
end

function SentryGunDamage:set_health(amount)
	self._health = amount
	self._HEALTH_INIT = amount
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
end

function SentryGunDamage:sync_health(health_ratio)
	self._health_ratio = health_ratio / self._HEALTH_GRANULARITY

	if health_ratio == 0 then
		self:die()
	end
end

function SentryGunDamage:shoot_pos_mid(m_pos)
	mvector3.set(m_pos, self._ext_movement:m_head_pos())
end

function SentryGunDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return
	end

	local hit_body = attack_data.col_ray.body
	local hit_body_name = hit_body:name()

	if self._invulnerable_bodies and self._invulnerable_bodies[hit_body_name:key()] then
		return
	end

	local hit_bag = attack_data.col_ray.body and hit_body_name == self._bag_body_name_ids
	local dmg_adjusted = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
		local critical_hit, damage = CopDamage.roll_critical_hit(self, dmg_adjusted)
		dmg_adjusted = damage

		managers.hud:on_hit_confirmed({
			is_crit = nil,
			hit_type = nil,
			is_killshot = nil,
			hit_type = HUDHitConfirm.HIT_NORMAL,
			is_killshot = self._dead and true or false,
			is_crit = critical_hit
		})
	end

	if hit_bag then
		dmg_adjusted = dmg_adjusted * tweak_data.weapon[self._unit:base():get_name_id()].BAG_DMG_MUL

		if self._bag_hit_snd_event then
			self._unit:sound_source():post_event(self._bag_hit_snd_event)
		end
	end

	dmg_adjusted = dmg_adjusted + self._sync_dmg_leftover
	local result = {
		variant = "bullet",
		type = "dmg_rcv"
	}
	local damage_sync = self:_apply_damage(dmg_adjusted, true)

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local body_index = self._unit:get_body_index(hit_body_name)

		self._unit:network():send("damage_bullet", attacker, damage_sync, body_index, 0, self._dead and true or false)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end

	return result
end

function SentryGunDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" or not tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL
	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true)

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_fire", attacker, damage_sync, false, self._dead and true or false, attack_data.col_ray.ray, nil, nil)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end

function SentryGunDamage:damage_explosion(attack_data)
	if self._unit:brain():is_tank() and not self._dead and not Network:is_client() and not self._sabotaged then
		self:_check_tank_sabotage(attack_data.attacker_unit)
	end

	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" or not tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL

	if attacker_unit and attacker_unit == managers.player:player_unit() then
		self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
		local critical_hit, crit_damage = CopDamage.roll_critical_hit(self, damage)
		damage = crit_damage

		managers.hud:on_hit_confirmed({
			is_crit = nil,
			hit_type = nil,
			is_killshot = nil,
			hit_type = HUDHitConfirm.HIT_NORMAL,
			is_killshot = self._dead and true or false,
			is_crit = critical_hit
		})
	end

	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true)

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_explosion_fire", attacker, damage_sync, i_attack_variant, self._dead and true or false, attack_data.col_ray.ray)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end

function SentryGunDamage:_check_tank_sabotage(attacker_unit)
	if self._sabotage_allow_t and TimerManager:game():time() < self._sabotage_allow_t then
		Application:debug("[SentryGunDamage:_check_tank_sabotage]", "Tank sabotage still on cooldown")

		return
	end

	if not alive(attacker_unit) or not attacker_unit:base() or not attacker_unit:base().thrower_unit then
		return
	end

	attacker_unit = attacker_unit:base():thrower_unit()
	self._sabotage_allow_t = nil

	if alive(attacker_unit) then
		local husk_player = attacker_unit:base().is_husk_player and attacker_unit
		local can_sabotage = PlayerSkill.has_skill("player", "sapper_tank_disabler", husk_player)

		print("TANK SABOTAGE ATTEMPT", can_sabotage)

		if can_sabotage then
			self._unit:network():send("turret_sabotaged")
			self:sync_sabotaged()
		end
	end
end

function SentryGunDamage:dead()
	return self._dead
end

function SentryGunDamage:sync_sabotaged()
	self._sabotaged = true

	if self._sabotaged_sequence_name then
		self._unit:damage():run_sequence_simple(self._sabotaged_sequence_name)
	end
end

function SentryGunDamage:sabotaged()
	return self._sabotaged
end

function SentryGunDamage:repair_sabotage()
	self._sabotaged = nil

	if self._repaired_sequence_name then
		self._unit:damage():run_sequence_simple(self._repaired_sequence_name)
	end

	if Network:is_server() then
		self._unit:network():send("turret_repair_sabotage")

		if not self._sabotage_allow_t then
			self._sabotage_allow_t = TimerManager:game():time() + managers.player:upgrade_value_by_level("player", "sapper_tank_disabler_cooldown", 1, 60)
		end
	end
end

function SentryGunDamage:health_ratio()
	return self._health / self._HEALTH_INIT
end

function SentryGunDamage:shield_health_ratio()
	return 1
end

function SentryGunDamage:focus_delay_mul()
	return 1
end

function SentryGunDamage:die()
	self._health = 0
	self._dead = true

	self._unit:set_slot(26)
	self._unit:brain():set_active(false)
	self._unit:movement():set_active(false)
	self._unit:movement():on_death()
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:base():on_death()
	self._unit:sound_source():post_event(self._breakdown_snd_event)

	if self._death_sequence_name then
		self._unit:damage():run_sequence_simple(self._death_sequence_name)
	end

	if self._unit:interaction() then
		self._unit:interaction():set_tweak_data("sentry_gun_revive")
	end

	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
		self._unit:contour():remove("mark_unit_friendly", true)
		self._unit:contour():remove("mark_unit_dangerous", true)
		managers.groupai:state():unregister_turret(self._unit)
	end

	managers.mission:call_global_event("tank_destroyed")
end

function SentryGunDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, death)
	if self._dead then
		return
	end

	if death then
		self:die()

		return
	end

	local damage = death and "death" or damage_percent * self._HEALTH_INIT_PERCENT

	self:_apply_damage(damage, false)

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:sync_damage_fire(attacker_unit, damage_percent, death, direction)
	if self._dead then
		return
	end

	if death then
		self:die()

		return
	end

	local damage = death and "death" or damage_percent * self._HEALTH_INIT_PERCENT

	self:_apply_damage(damage, false)

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	if death then
		self:die()

		return
	end

	local variant = self._ATTACK_VARIANTS[i_attack_variant]
	local damage = death and "death" or damage_percent * self._HEALTH_INIT_PERCENT

	self:_apply_damage(damage, false)

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:_apply_damage(damage, is_local)
	local damage_percent = nil
	local body_damage = damage ~= "death" and damage or self._HEALTH_INIT

	if is_local then
		local health_init_percent = self._HEALTH_INIT_PERCENT
		damage_percent = math.clamp(body_damage / health_init_percent, 0, self._HEALTH_GRANULARITY)
		local leftover_percent = damage_percent - math.floor(damage_percent)
		self._sync_dmg_leftover = self._sync_dmg_leftover + leftover_percent * health_init_percent
		damage_percent = math.floor(damage_percent)
		body_damage = damage_percent * health_init_percent
	end

	if body_damage == 0 then
		return
	end

	local previous_health_ratio = self:health_ratio()

	if self._health <= body_damage then
		self:die()
	else
		self._health = self._health - body_damage
	end

	if not tweak_data.weapon[self._unit:base():get_name_id()].AUTO_REPAIR and not self._dead and previous_health_ratio >= 0.75 and self:health_ratio() < 0.75 and self._damaged_sequence_name then
		self._unit:damage():run_sequence_simple(self._damaged_sequence_name)
	end

	return damage_percent
end

function SentryGunDamage:update_shield_smoke_level(ratio, up)
end

function SentryGunDamage:save(save_data)
	local my_save_data = {}
	save_data.char_damage = my_save_data
	my_save_data.ignore_client_damage = self._ignore_client_damage
	my_save_data.health = self._health
	my_save_data.HEALTH_INIT = self._HEALTH_INIT
end

function SentryGunDamage:load(save_data)
	if not save_data or not save_data.char_damage then
		return
	end

	local my_save_data = save_data.char_damage
	self._ignore_client_damage = my_save_data.ignore_client_damage
	self._health = my_save_data.health
	self._HEALTH_INIT = my_save_data.HEALTH_INIT
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY

	if self._health == 0 then
		self:die()
	end
end

function SentryGunDamage:destroy(unit)
end

function SentryGunDamage:shield_smoke_level()
	return 0
end
