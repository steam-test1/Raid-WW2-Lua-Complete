PlayerDamage = PlayerDamage or class()
PlayerDamage._ARMOR_STEPS = tweak_data.player.damage.ARMOR_STEPS
PlayerDamage._ARMOR_DAMAGE_REDUCTION = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION
PlayerDamage._ARMOR_DAMAGE_REDUCTION_STEPS = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION_STEPS

function PlayerDamage:init(unit)
	self._unit = unit
	self._player_class = managers.skilltree:has_character_profile_class() and managers.skilltree:get_character_profile_class()
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)
	self._revives = 0
	self._bleed_out_health = tweak_data.player.damage.BLEED_OUT_HEALTH_INIT
	self._god_mode = Global.god_mode
	self._invulnerable = false
	self._mission_damage_blockers = {}
	self._focus_delay_mul = 1
	self._listener_holder = EventListenerHolder:new()
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = -100
	self._last_received_dmg = 0
	self._next_allowed_sup_t = -100
	self._last_received_sup = 0
	self._supperssion_data = {}
	self._inflict_damage_body = self._unit:body("inflict_reciever")

	self._inflict_damage_body:set_extension(self._inflict_damage_body:extension() or {})

	local body_ext = PlayerBodyDamage:new(self._unit, self, self._inflict_damage_body)
	self._inflict_damage_body:extension().damage = body_ext

	managers.sequence:add_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key(), self._inflict_damage_body:extension().damage)
	SoundDevice:set_rtpc("downed_state_progression", 0)
	SoundDevice:set_rtpc("downed_tank_progression", 0)
end

function PlayerDamage:post_init()
	self:setup_upgrades()
	self:replenish()

	if managers.raid_job:is_camp_loaded() then
		Application:debug("[PlayerDamage:init] Camp is loaded so player is immortal!")
		self:set_invulnerable(true)
	end

	self:send_set_status()
end

function PlayerDamage:send_set_status()
	self:_send_set_armor()
	self:_send_set_health()
end

function PlayerDamage:_update_self_administered_adrenaline()
	if self._bleed_out and self._player_revive_tweak_data then
		local controller = self._unit:base():controller()

		if controller and controller:get_input_pressed("jump") then
			local params = deep_clone(self._player_revive_tweak_data)
			params.target_unit = self._unit

			game_state_machine:change_state_by_name("ingame_special_interaction_revive", params)
		end
	end
end

function PlayerDamage:get_revives()
	return self._revives
end

function PlayerDamage:force_into_bleedout()
	self:set_health(0)
	self:_damage_screen()
	self:_check_bleed_out(true, true)
	self:_update_player_health_hud()
	self:_send_set_health()
	self:_set_health_effect()
end

function PlayerDamage:_force_kill()
	self._revives = 1

	self:set_health(0)
end

function PlayerDamage:_update_player_health_hud()
	managers.hud:set_player_health({
		total = nil,
		current = nil,
		current = self:get_real_health(),
		total = self:_max_health()
	})
end

function PlayerDamage:update(unit, t, dt)
	if self._perseverance then
		local meter = managers.warcry:current_meter_value()

		if meter <= 0 then
			self:disable_perseverance()
			self:force_into_bleedout()
		else
			local reduction = dt / self._perseverance

			managers.warcry:fill_meter_by_value(-reduction)
		end
	end

	if self._bleed_out_blocked_by_zipline and not self._unit:movement():zipline_unit() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_zipline = nil
	end

	if self._bleed_out_blocked_by_movement_state and not self._unit:movement():current_state():bleed_out_blocked() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_movement_state = nil
	end

	if self._regenerate_timer and not self:dead() and not self._bleed_out and not self._perseverance then
		if not self._perseverance and not self._bleed_out_blocked_by_zipline then
			self._regenerate_timer = self._regenerate_timer - dt * (self._regenerate_speed or 1)
			local top_fade = math.clamp(self._hurt_value - 0.8, 0, 1) / 0.2
			local hurt = self._hurt_value - (1 - top_fade) * (1 + math.sin(t * 500)) / 2 / 10

			managers.environment_controller:set_hurt_value(hurt)

			if self._regenerate_timer < 0 then
				self:_regenerate_armor()
			end
		end
	elseif self._hurt_value then
		if not self:dead() and not self._bleed_out and not self._perseverance then
			self._hurt_value = math.min(1, self._hurt_value + dt)
			local top_fade = math.clamp(self._hurt_value - 0.8, 0, 1) / 0.2
			local hurt = self._hurt_value - (1 - top_fade) * (1 + math.sin(t * 500)) / 2 / 10

			managers.environment_controller:set_hurt_value(hurt)

			local armor_value = math.max(self._armor_value or 0, self._hurt_value)

			managers.hud:set_player_armor({
				max = nil,
				total = nil,
				current = nil,
				current = self:get_real_armor() * armor_value,
				total = self:_max_armor(),
				max = self:_max_armor()
			})
			SoundDevice:set_rtpc("shield_status", self._hurt_value * 100)

			if self._hurt_value >= 1 then
				self._hurt_value = nil

				managers.environment_controller:set_hurt_value(1)
			end
		else
			local hurt = self._hurt_value - (1 + math.sin(t * 500)) / 2 / 10

			managers.environment_controller:set_hurt_value(hurt)
		end
	end

	if self._tinnitus_data then
		self._tinnitus_data.intensity = (self._tinnitus_data.end_t - t) / self._tinnitus_data.duration

		if self._tinnitus_data.intensity <= 0 then
			self:_stop_tinnitus()
		else
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))
		end
	end

	self:_update_self_administered_adrenaline()

	if not self._downed_timer and self._downed_progression then
		self._downed_progression = math.max(0, self._downed_progression - dt * 75)

		managers.environment_controller:set_downed_value(self._downed_progression)
		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._critical_state_heart_loop_instance = nil
			self._downed_progression = nil
		end
	end

	if self._revive_miss then
		self._revive_miss = self._revive_miss - dt

		if self._revive_miss <= 0 then
			self._revive_miss = nil
		end
	end

	if self._skill_updates then
		for i = 1, #self._skill_updates do
			self._skill_updates[i](self)
		end
	end

	self:_upd_suppression(t, dt)

	if not self:dead() and not self._bleed_out and not self._perseverance then
		self:_upd_health_regen(t, dt)
	end
end

function PlayerDamage:band_aid_health()
	if managers.platform:presence() == "Playing" and self:need_revive() then
		return
	end

	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()

	self._said_hurt = false
	self._said_hurt_half = false
end

function PlayerDamage:recover_health()
	if managers.platform:presence() == "Playing" and self:need_revive() then
		self:revive(true)
	end

	self:_regenerated()
	self:_update_player_health_hud()
end

function PlayerDamage:recover_down()
	self:_regenerated(1)
end

function PlayerDamage:replenish()
	if managers.platform:presence() == "Playing" and self:need_revive() then
		self:revive(true)
	end

	self:_regenerated()
	self:_regenerate_armor()
	SoundDevice:set_rtpc("shield_status", 100)
	SoundDevice:set_rtpc("downed_state_progression", 0)

	if managers.player:has_category_upgrade("player", "self_administered_adrenaline") then
		self._player_revive_tweak_data = tweak_data.interaction:get_interaction("si_revive")
	else
		self._player_revive_tweak_data = nil
	end
end

function PlayerDamage:debug_replenish()
end

function PlayerDamage:_regenerate_armor()
	self:set_armor(self:_max_armor())

	self._regenerate_timer = nil
	self._regenerate_speed = nil

	self:_send_set_armor()
	managers.hud:set_player_armor({
		max = nil,
		total = nil,
		current = nil,
		current = self:get_real_armor(),
		total = self:_max_armor(),
		max = self:_max_armor()
	})
end

function PlayerDamage:restore_health(health_restored, is_static)
	if not is_static then
		health_restored = health_restored * self:get_max_health()
	end

	return self:change_health(health_restored)
end

function PlayerDamage:restore_armor(armor_restored)
	if self:dead() or self._bleed_out or self._perseverance then
		return
	end

	local max_armor = self:_max_armor()
	local armor = self:get_real_armor()
	local new_armor = math.min(armor + armor_restored, max_armor)

	self:set_armor(new_armor)
	self:_send_set_armor()
	managers.hud:set_player_armor({
		max = nil,
		total = nil,
		no_hint = true,
		current = nil,
		current = self:get_real_armor(),
		total = self:_max_armor(),
		max = max_armor
	})
end

function PlayerDamage:change_regenerate_speed(value, percent)
	if self._regenerate_speed then
		self._regenerate_speed = percent and self._regenerate_speed * value or self._regenerate_speed + value
	end
end

function PlayerDamage:armor_ratio()
	return self:get_real_armor() / self:_max_armor()
end

function PlayerDamage:_regenerated(downs_regen)
	self:set_reserved_health(0)
	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()

	self._said_hurt = false
	self._said_hurt_half = false
	local max_lives = self:get_max_revives()
	local buff_effect = managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_FIRST_BLEEDOUT_IS_DISREGARDED) and 1 or 0

	if downs_regen and downs_regen > 0 then
		if self:_change_revives(downs_regen) then
			managers.hud:set_big_prompt({
				title = nil,
				description = nil,
				id = "hint_downs_remaining",
				duration = 3,
				title = managers.localization:to_upper_text("hud_hint_down_restored_title"),
				description = managers.localization:to_upper_text("hud_hint_downs_desc", {
					DOWNS = nil,
					DOWNSMAX = nil,
					DOWNS = self._revives - 1,
					DOWNSMAX = max_lives - 1
				})
			})
		end
	else
		self._revives = max_lives + buff_effect
	end

	managers.hud:set_player_downs(self._revives)
	managers.environment_controller:set_last_life(false)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER) then
		self._down_time = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER) or tweak_data.player.damage.DOWNED_TIME
	else
		local bleedout_multiplier = managers.player:upgrade_value("player", "revenant_bleedout_timer_reduction", 1)
		local bleedout_addition = 0

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER) then
			bleedout_addition = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER) or 0
		end

		self._down_time = math.round((tweak_data.player.damage.DOWNED_TIME + bleedout_addition) * bleedout_multiplier)
	end
end

function PlayerDamage:set_player_class(class)
	self._player_class = class
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)

	self:_regenerated()
end

function PlayerDamage:get_base_health_regen()
	return self._class_tweak_data.damage.HEALTH_REGEN
end

function PlayerDamage:get_real_health()
	return self._health
end

function PlayerDamage:get_base_health()
	return self._class_tweak_data.damage.BASE_HEALTH
end

function PlayerDamage:get_max_health()
	local max_health = self._current_max_health or self:_max_health()

	return max_health
end

function PlayerDamage:get_real_armor()
	return self._armor
end

function PlayerDamage:change_health(change_of_health)
	return self:set_health(self:get_real_health() + change_of_health)
end

function PlayerDamage:restore_health_percentage(percentage)
	self:set_health(self:get_real_health() * percentage)
end

function PlayerDamage:set_health(health)
	local max_health = self:_max_health()
	self._current_max_health = self._current_max_health or max_health
	local max_health_different = self._current_max_health ~= max_health

	if max_health_different then
		local prev_health_ratio = health / self._current_max_health
		local new_health_ratio = health / max_health
		local diff_health_ratio = prev_health_ratio - new_health_ratio
		health = health + math.max(0, diff_health_ratio * max_health)
		self._current_max_health = max_health
	end

	max_health = max_health - self._reserved_health
	local prev_health = self._health
	self._health = math.clamp(health, 0, max_health)

	self:_send_set_health()
	self:_set_health_effect()

	if self._said_hurt and self:get_real_health() / self:_max_health() > 0.2 then
		self._said_hurt = false
	end

	if self._said_hurt_half and self:get_real_health() / self:_max_health() >= 0.5 then
		self._said_hurt_half = false
	end

	local health_different = prev_health ~= self._health

	if health_different then
		self:_update_player_health_hud()
	end

	return health_different
end

function PlayerDamage:set_reserved_health(amount)
	self._reserved_health = amount
end

function PlayerDamage:set_armor(armor)
	self._armor = math.clamp(armor, 0, self:_max_armor())
end

function PlayerDamage:down_time()
	return self._down_time
end

function PlayerDamage:health_ratio()
	return self:get_real_health() / self:_max_health()
end

function PlayerDamage:_max_health()
	local base_max_health = self:get_base_health()
	local skill_multiplier = managers.player:health_skill_multiplier()
	local add_health_on_top = managers.player:health_skill_addition_on_top()
	local buff_multiplier = 1

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_HEALTH) then
		buff_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_HEALTH)
	end

	return base_max_health * skill_multiplier * buff_multiplier + add_health_on_top
end

function PlayerDamage:_max_armor()
	local base_max_armor = self._class_tweak_data.damage.BASE_ARMOR + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
	local mul = managers.player:body_armor_skill_multiplier()

	return base_max_armor * mul
end

function PlayerDamage:_armor_steps()
	return self._ARMOR_STEPS
end

function PlayerDamage:_armor_damage_reduction()
	return 0
end

function PlayerDamage:full_health()
	return self:get_real_health() == self:_max_health()
end

function PlayerDamage:need_healing()
	return self:get_real_health() < self:_max_health() - self._reserved_health
end

function PlayerDamage:damage_tase(attack_data)
	if self._god_mode then
		return
	end

	local cur_state = self._unit:movement():current_state_name()

	if cur_state ~= "tased" and cur_state ~= "fatal" then
		self:on_tased(false)

		self._tase_data = attack_data

		managers.player:set_player_state("tased")

		local damage_info = {
			result = nil,
			result = {
				variant = "tase",
				type = "hurt"
			}
		}

		self:_call_listeners(damage_info)

		if attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
			attack_data.attacker_unit:sound():say("post_tasing_taunt")
		end
	end
end

function PlayerDamage:on_tased(non_lethal)
	if self:get_real_health() == 0 and self._perseverance then
		self:change_health(1)
	end
end

function PlayerDamage:tase_data()
	return self._tase_data
end

function PlayerDamage:erase_tase_data()
	self._tase_data = nil
end

local mvec1 = Vector3()

function PlayerDamage:damage_melee(attack_data)
	local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
	blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

	if blood_effect then
		local pos = mvec1

		mvector3.set(pos, self._unit:camera():forward())
		mvector3.multiply(pos, 20)
		mvector3.add(pos, self._unit:camera():position())

		local rot = self._unit:camera():rotation():z()

		World:effect_manager():spawn({
			normal = nil,
			position = nil,
			effect = nil,
			effect = tweak_data.common_effects.blood_impact_2,
			position = pos,
			normal = rot
		})
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("melee", self._unit:movement():current_state(), self:health_ratio())
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.armor_piercing = true

	self._unit:sound():play("melee_hit_body", nil, nil)

	local result = self:damage_bullet(attack_data)
	local vars = {
		"melee_hit",
		"melee_hit_var2"
	}

	self._unit:camera():play_shaker(table.random(vars), 1 * managers.player:upgrade_value("player", "on_hit_flinch_reduction", 1))

	if managers.player:current_state() == "bipod" or managers.player:current_state() == "turret" then
		managers.player:set_player_state("standard")
	end

	self._unit:movement():push(attack_data.push_vel)

	return result
end

function PlayerDamage:is_friendly_fire(unit)
	if not alive(unit) then
		return
	end

	if unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return
	end

	return not unit:movement():team().foes[self._unit:movement():team().id]
end

function PlayerDamage:play_whizby(position, is_turret)
	self._unit:sound():play_whizby({
		position = nil,
		position = position
	})

	if not is_turret then
		managers.rumble:play("bullet_whizby")
	end
end

function PlayerDamage:clbk_kill_taunt(attack_data)
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		self._kill_taunt_clbk_id = nil

		attack_data.attacker_unit:sound():say("post_kill_taunt")
	end
end

function PlayerDamage:damage_bullet(attack_data)
	local damage_info = {
		result = nil,
		attacker_unit = nil,
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local dmg_mul = managers.player:damage_reduction_skill_multiplier("bullet", self._unit:movement():current_state(), self:health_ratio())
	attack_data.damage = attack_data.damage * dmg_mul
	local dodge_roll = math.rand(1)
	local dodge_value = self._class_tweak_data.damage.DODGE_INIT or 0
	local armor_dodge_chance = managers.player:body_armor_value("dodge")
	local skill_dodge_chance = managers.player:skill_dodge_chance()
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if dodge_roll < dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position, attack_data.is_turret)
		self:_hit_unit(attack_data)

		self._next_allowed_dmg_t = managers.player:player_timer():time() + self._dmg_interval
		self._last_received_dmg = attack_data.damage

		return
	end

	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position, attack_data.is_turret)

		return
	end

	self._unit:sound():play("hit_bullet_1p")

	if self._bleed_out then
		return
	end

	local shake_amplitude = math.clamp(attack_data.damage, 0.2, 1.2)
	local shake_multiplier = managers.player:upgrade_value("player", "on_hit_flinch_reduction", 1)

	if self._unit:movement():in_steelsight() then
		local weapon = self._unit:inventory():equipped_unit()
		shake_multiplier = shake_multiplier * managers.player:upgrade_value(weapon:base():category(), "steelsight_hit_flinch_reduction", 1)
	end

	self._unit:camera():play_shaker("player_bullet_damage", shake_amplitude * shake_multiplier, 0.2)

	if attack_data.is_turret then
		managers.rumble:play("damage_bullet_turret")
	else
		managers.rumble:play("damage_bullet")
	end

	self:_hit_unit(attack_data)

	if not self:is_suppressed() then
		return
	end

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if attack_data.armor_piercing then
		attack_data.damage = attack_data.damage - health_subtracted
	else
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
	end

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGE_TAKEN, attack_data)

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	self._next_allowed_dmg_t = managers.player:player_timer():time() + self._dmg_interval
	self._last_received_dmg = health_subtracted

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
		managers.dialog:queue_dialog("player_gen_taking_fire", {
			skip_idle_check = true,
			instigator = nil,
			instigator = self._unit
		})
	end

	self:_call_listeners(damage_info)
end

function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0

	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		self:set_armor(self:get_real_armor() - attack_data.damage)

		health_subtracted = health_subtracted - self:get_real_armor()

		self:_damage_screen()
		managers.hud:set_player_armor({
			max = nil,
			total = nil,
			current = nil,
			current = self:get_real_armor(),
			total = self:_max_armor(),
			max = self:_max_armor()
		})
		SoundDevice:set_rtpc("shield_status", self:get_real_armor() / self:_max_armor() * 100)
		self:_send_set_armor()
	end

	return health_subtracted
end

function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)

	health_subtracted = health_subtracted - self:get_real_health()
	local bullet_or_explosion_or_melee = attack_data.variant and (attack_data.variant == "bullet" or attack_data.variant == "explosion" or attack_data.variant == "melee")

	self:_damage_screen()
	self:_check_bleed_out(not bullet_or_explosion_or_melee)
	managers.statistics:health_subtracted(health_subtracted)

	return health_subtracted
end

function PlayerDamage:_send_damage_drama(attack_data, health_subtracted)
	local dmg_percent = health_subtracted / self:get_base_health()
	local attacker = nil

	if not attacker or attack_data.attacker_unit:id() == -1 then
		attacker = self._unit
	end

	self._unit:network():send("criminal_hurt", attacker, math.clamp(math.ceil(dmg_percent * 100), 1, 100))

	if Network:is_server() then
		attacker = attack_data.attacker_unit

		if attacker and not attack_data.attacker_unit:movement() then
			attacker = nil
		end

		managers.groupai:state():criminal_hurt_drama(self._unit, attacker, dmg_percent)
	else
		self._unit:network():send_to_host("damage_bullet", attacker, 1, 1, 1, false)
	end
end

function PlayerDamage:damage_killzone(attack_data)
	local damage_info = {
		result = nil,
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	end

	if self:incapacitated() or self._bleed_out then
		return
	end

	self._unit:sound():play("player_gen_pain_impact")
	self:_hit_direction(attack_data.col_ray)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage * armor_reduction_multiplier
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if attack_data.death_on_down and self._health < health_subtracted then
		self:_force_kill()
	end

	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fall(data)
	local damage_info = {
		result = nil,
		result = {
			variant = "fall",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._mission_damage_blockers.damage_fall_disabled then
		return
	end

	local height_limit = self._class_tweak_data.damage.FALL_DAMAGE_MIN_HEIGHT

	if data.height < height_limit then
		return
	end

	local fall_damage_state = nil
	local fatal_limit = self._class_tweak_data.damage.FALL_DAMAGE_FATAL_HEIGHT
	local death_limit = self._class_tweak_data.damage.FALL_DAMAGE_DEATH_HEIGHT
	local fatal_fall = false
	local deadly_fall = false

	if death_limit < data.height then
		deadly_fall = true
	elseif fatal_limit < data.height then
		fatal_fall = true
	end

	managers.environment_controller:hit_feedback_down()
	managers.hud:on_hit_direction("down")

	if self._bleed_out and self._unit:movement():current_state_name() ~= "freefall" then
		return
	end

	if deadly_fall or self._unit:movement():current_state_name() == "freefall" then
		self:disable_perseverance()
		self:_force_kill()
	else
		local fall_damage = 0

		if fatal_fall then
			self:disable_perseverance()

			fall_damage = self:get_real_health()

			if data.negate_fatal then
				fall_damage = fall_damage - 1
			end
		else
			local min_damage = self._class_tweak_data.damage.FALL_DAMAGE_MIN
			local max_damage = self._class_tweak_data.damage.FALL_DAMAGE_MAX
			local base_damage = math.lerp(min_damage, max_damage, (data.height - height_limit) / (fatal_limit - height_limit))
			base_damage = math.clamp(base_damage, min_damage, max_damage)
			local damage_multiplier = managers.player:upgrade_value("player", "fleetfoot_fall_damage_reduction", 1)
			fall_damage = base_damage * damage_multiplier
		end

		if fatal_fall or not data.negate_damage then
			self:change_health(-fall_damage)
		end

		if data.negate_damage then
			self._unit:movement():subtract_stamina(fall_damage * tweak_data.upgrades.high_dive_health_to_stamina_mul)
			self._unit:movement():reset_stamina_regeneration()
		end

		self._unit:sound():say("player_gen_pain_impact", nil, true)
	end

	local silent_fall = managers.player:upgrade_value("player", "fleetfoot_silent_fall", false)

	if not silent_fall and self._class_tweak_data.stealth.FALL_ALERT_MIN_HEIGHT < data.height then
		local alert_radius = math.lerp(self._class_tweak_data.stealth.FALL_ALERT_MIN_RADIUS, self._class_tweak_data.stealth.FALL_ALERT_MAX_RADIUS, (data.height - self._class_tweak_data.stealth.FALL_ALERT_MIN_HEIGHT) / (self._class_tweak_data.stealth.FALL_ALERT_MAX_HEIGHT - self._class_tweak_data.stealth.FALL_ALERT_MIN_HEIGHT))
		alert_radius = math.clamp(alert_radius, self._class_tweak_data.stealth.FALL_ALERT_MIN_RADIUS, self._class_tweak_data.stealth.FALL_ALERT_MAX_RADIUS)
		local new_alert = {
			"vo_cbt",
			self._unit:movement():m_head_pos(),
			alert_radius,
			self._unit:movement():SO_access(),
			self._unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end

	local max_armor = self:_max_armor()

	if fatal_fall or deadly_fall then
		self:set_armor(0)
	end

	managers.hud:set_player_armor({
		max = nil,
		total = nil,
		no_hint = true,
		current = nil,
		current = self:get_real_armor(),
		total = self:_max_armor(),
		max = max_armor
	})
	SoundDevice:set_rtpc("shield_status", 0)
	self:_send_set_armor()

	self._bleed_out_blocked_by_movement_state = nil

	self:_update_player_health_hud()
	self:_send_set_health()
	self:_set_health_effect()
	self:_damage_screen()
	self:_check_bleed_out(true, true)
	self:_call_listeners(damage_info)

	return true
end

function PlayerDamage:damage_explosion(attack_data)
	local damage_info = {
		result = nil,
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	end

	local distance = mvector3.distance(attack_data.position, self._unit:position())

	if attack_data.range < distance then
		return
	end

	local damage = (attack_data.damage or 1) * (1 - distance / attack_data.range)

	if self._bleed_out then
		return
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("explosion", self._unit:movement():current_state(), self:health_ratio())
	attack_data.damage = damage * dmg_mul
	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGE_TAKEN, attack_data)

	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fire(attack_data)
	local damage_info = {
		result = nil,
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	end

	local damage = attack_data.damage or 1

	if self._bleed_out then
		return
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("fire", self._unit:movement():current_state(), self:health_ratio())
	attack_data.damage = damage * dmg_mul
	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGE_TAKEN, attack_data)

	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

function PlayerDamage:update_downed(t, dt)
	if self._downed_timer and self._downed_paused_counter == 0 then
		self._downed_timer = self._downed_timer - dt

		if self._bleedout_timer then
			self._bleedout_timer = self._bleedout_timer - dt
		end

		local bleedout_progression = 0

		if self._downed_start_time == 0 then
			self._downed_progression = 100
		else
			self._downed_progression = math.clamp(1 - self._downed_timer / self._downed_start_time, 0, 1) * 100
			bleedout_progression = math.clamp(1 - self._bleedout_timer / self._downed_start_time, 0, 1) * 100
		end

		managers.environment_controller:set_downed_value(bleedout_progression)
		SoundDevice:set_rtpc("downed_state_progression", bleedout_progression)

		return self._downed_timer <= 0
	end

	return false
end

function PlayerDamage:is_perseverating()
	return self._perseverance and true or false
end

function PlayerDamage:_check_bleed_out(ignore_upgrades, ignore_movement_state)
	if self:get_real_health() == 0 and not self._perseverance then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		local event_params = {
			bleed_out_blocked = false,
			revives = nil,
			revives = self._revives
		}

		if not ignore_upgrades then
			managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_CHECK_BLEEDOUT, event_params)
			self:_check_activate_perseverance(event_params)
		end

		self._hurt_value = 0.2

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not event_params.bleed_out_blocked then
			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_ROULETTE) and math.random(6) > 5 then
				self:force_set_revives(0)
			else
				self:_change_revives(-1)
			end

			self:disable_perseverance()
			managers.environment_controller:set_last_life(self._revives <= 1)

			if self._revives == 0 then
				self._down_time = 0
			else
				local max_lives = self:get_max_revives()

				managers.hud:set_big_prompt({
					title = nil,
					text_color = nil,
					id = "hint_downed",
					background = "backgrounds_detected_msg",
					description = nil,
					priority = true,
					duration = 4,
					title = managers.localization:to_upper_text("hud_hint_downs_title"),
					description = managers.localization:to_upper_text("hud_hint_downs_desc", {
						DOWNS = nil,
						DOWNSMAX = nil,
						DOWNS = self._revives - 1,
						DOWNSMAX = max_lives - 1
					}),
					text_color = tweak_data.gui.colors.raid_red
				})
				managers.dialog:queue_dialog("player_gen_downed", {
					skip_idle_check = true,
					instigator = nil,
					instigator = self._unit
				})
			end

			self._bleed_out = true

			managers.player:set_player_state("bleed_out")

			if not alive(self._critical_state_heart_loop_instance) then
				self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			end

			self._bleed_out_health = tweak_data.player.damage.BLEED_OUT_HEALTH_INIT

			self:on_downed()
		end
	elseif not self._said_hurt and self:health_ratio() < 0.2 then
		self._said_hurt = true

		self._unit:sound():say("player_nearly_dead", nil, true)
	elseif not self._said_hurt_half and self:health_ratio() < 0.5 then
		self._said_hurt_half = true

		self._unit:sound():say("player_on_half_health", nil, true)
	end
end

function PlayerDamage:_check_activate_perseverance(params)
	if not managers.player:has_category_upgrade("player", "perseverance_prolong_life") then
		return
	end

	if params.bleed_out_blocked then
		return
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_WARCRIES_DISABLED) then
		return
	end

	local max_duration = managers.player:upgrade_value("player", "perseverance_prolong_life", 0)
	local multiplier = managers.warcry:current_meter_value()
	self._perseverance = max_duration * multiplier
	params.bleed_out_blocked = true

	managers.warcry:on_enter_perseverance()

	self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
	local interaction_unit = managers.interaction:active_unit()

	if alive(interaction_unit) and not interaction_unit:interaction():allowed_while_perservating() then
		self._unit:movement():interupt_interact()
	end

	managers.system_event_listener:remove_listener("upgrade_perseverance")

	if managers.player:has_category_upgrade("player", "perseverance_killshot_timer_increase") then
		local timer_increase = managers.player:upgrade_value("player", "perseverance_killshot_timer_increase", 0)
		local params = {
			timer_increase = nil,
			max_duration = nil,
			max_duration = max_duration,
			timer_increase = timer_increase
		}

		managers.system_event_listener:add_listener("upgrade_perseverance", {
			CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
		}, callback(self, self, "_perseverance_increase_timer", params))
	end
end

function PlayerDamage:disable_perseverance()
	managers.system_event_listener:remove_listener("upgrade_perseverance")

	self._perseverance = nil
end

function PlayerDamage:on_downed()
	if managers.player:has_category_upgrade("player", "self_administered_adrenaline") then
		managers.hud:show_interact({
			text = nil,
			text = managers.localization:text("skill_interaction_revive_prompt", {
				BTN_JUMP = nil,
				BTN_JUMP = managers.localization:btn_macro("jump")
			})
		})
	end

	managers.player:set_death_location_rotation(self._unit:position(), self._unit:rotation())

	self._downed_timer = self:down_time()
	self._downed_start_time = self._downed_timer
	self._downed_paused_counter = 0
	self._bleedout_timer = self:down_time()

	self:disable_perseverance()
	managers.hud:start_player_timer(self._downed_timer)
	managers.hud:on_teammate_downed(HUDManager.PLAYER_PANEL)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_ENTER_BLEEDOUT)
	self:_stop_tinnitus()
	self:_check_martyrdom()
	self:set_health_effects_blocked(true)
end

function PlayerDamage:get_paused_counter_name_by_peer(peer_id)
	return self._paused_counter_name_by_peer_map and self._paused_counter_name_by_peer_map[peer_id]
end

function PlayerDamage:set_peer_paused_counter(peer_id, counter_name)
	if peer_id then
		self._paused_counter_name_by_peer_map = self._paused_counter_name_by_peer_map or {}
		self._paused_counter_name_by_peer_map[peer_id] = counter_name

		if not next(self._paused_counter_name_by_peer_map) then
			self._paused_counter_name_by_peer_map = nil
		end
	end
end

function PlayerDamage:pause_downed_timer(timer, peer_id)
	self._downed_paused_counter = (self._downed_paused_counter or 0) + 1

	self:set_peer_paused_counter(peer_id, "downed")

	if self._downed_paused_counter == 1 then
		managers.hud:pause_player_timer(true)

		if Network:is_server() then
			managers.network:session():send_to_peers_synched("pause_downed_teammate_timer", 1, true)
		end

		managers.hud:pd_start_progress(0, timer or tweak_data.interaction:get_interaction("revive").timer, "debug_interact_being_revived", "interaction_help")
	end
end

function PlayerDamage:unpause_downed_timer(peer_id)
	self._downed_paused_counter = self._downed_paused_counter - 1

	self:set_peer_paused_counter(peer_id, nil)

	if self._downed_paused_counter == 0 then
		managers.hud:pause_player_timer(false)

		if Network:is_server() then
			managers.network:session():send_to_peers_synched("pause_downed_teammate_timer", 1, false)
		end

		managers.hud:pd_cancel_progress()
	end
end

function PlayerDamage:update_incapacitated(t, dt)
	return self:update_downed(t, dt)
end

function PlayerDamage:on_incapacitated()
	self:on_downed()

	self._incapacitated = true
end

function PlayerDamage:bleed_out()
	return self._bleed_out
end

function PlayerDamage:incapacitated()
	return self._incapacitated
end

function PlayerDamage:_hit_direction(col_ray)
	if col_ray then
		local dir = col_ray.ray
		local infront = math.dot(self._unit:camera():forward(), dir)

		if infront < -0.9 then
			managers.environment_controller:hit_feedback_front()
		elseif infront > 0.9 then
			managers.environment_controller:hit_feedback_back()
			managers.hud:on_hit_direction("right")
		else
			local polar = self._unit:camera():forward():to_polar_with_reference(-dir, Vector3(0, 0, 1))
			local direction = Vector3(polar.spin, polar.pitch, 0):normalized()

			if math.abs(direction.y) < math.abs(direction.x) then
				if direction.x < 0 then
					managers.environment_controller:hit_feedback_left()
					managers.hud:on_hit_direction("left")
				else
					managers.environment_controller:hit_feedback_right()
					managers.hud:on_hit_direction("right")
				end
			elseif direction.y < 0 then
				managers.environment_controller:hit_feedback_up()
				managers.hud:on_hit_direction("up")
			else
				managers.environment_controller:hit_feedback_down()
				managers.hud:on_hit_direction("down")
			end
		end
	end
end

function PlayerDamage:_hit_unit(attack_data)
	managers.hud:on_hit_unit(attack_data)
end

function PlayerDamage:_damage_screen()
	self:set_regenerate_timer_to_max()

	self._hurt_value = 1 - math.clamp(0.8 - math.pow(self:get_real_armor() / self:_max_armor(), 2), 0, 1)
	self._armor_value = math.clamp(self:get_real_armor() / self:_max_armor(), 0, 1)

	managers.environment_controller:set_hurt_value(self._hurt_value)
end

function PlayerDamage:revive(helped_self)
	local revives = self:get_revives()

	if revives == 0 then
		return
	end

	managers.player:set_player_state("standard")

	if not helped_self then
		local callout = revives <= 1 and "player_gen_last_life" or "player_gen_revive_thanks"

		managers.dialog:queue_dialog(callout, {
			skip_idle_check = true,
			instigator = nil,
			instigator = self._unit
		})
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil
	self._bleedout_timer = nil

	self:set_health(self:_max_health())
	self:set_armor(self:_max_armor())

	self._revive_miss = 2

	self:set_health_effects_blocked(false)
	self:_regenerate_armor()
	managers.hud:stop_player_timer()
	managers.hud:on_teammate_revived(HUDManager.PLAYER_PANEL)
	self:_update_player_health_hud()
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_complete_progress()
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_REVIVED)
end

function PlayerDamage:need_revive()
	return self._bleed_out or self._incapacitated
end

function PlayerDamage:is_downed()
	return self._bleed_out or self._incapacitated
end

function PlayerDamage:dead()
	return self._dead
end

function PlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

function PlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

function PlayerDamage:set_god_mode(state)
	Global.god_mode = state
	self._god_mode = state

	self:print("PlayerDamage god mode " .. (state and "ON" or "OFF"))
end

function PlayerDamage:god_mode()
	return self._god_mode
end

function PlayerDamage:print(...)
	cat_print("player_damage", ...)
end

function PlayerDamage:set_invulnerable(state)
	self._invulnerable = state
end

function PlayerDamage:set_danger_level(danger_level)
	self._danger_level = self._danger_level ~= danger_level and danger_level or nil
	self._focus_delay_mul = danger_level and tweak_data.danger_zones[self._danger_level] or 1
end

function PlayerDamage:focus_delay_mul()
	return self._focus_delay_mul
end

function PlayerDamage:shoot_pos_mid(m_pos)
	mvector3.set(m_pos, self._unit:movement():m_head_pos())
end

function PlayerDamage:set_regenerate_timer_to_max()
	self._regenerate_timer = tweak_data.player.damage.REGENERATE_TIME
	self._regenerate_speed = self._regenerate_speed or 1
end

function PlayerDamage:_send_set_health()
	if self._unit:network() then
		local hp = math.round(self:get_real_health() / self:_max_health() * 100)

		self._unit:network():send("set_health", math.clamp(hp, 0, 100))

		if hp ~= 100 then
			managers.mission:call_global_event("player_damaged")
		end
	end
end

function PlayerDamage:_set_health_effect()
	local hp = self:get_real_health() / self:_max_health()

	math.clamp(hp, 0, 1)
	managers.environment_controller:set_health_effect_value(hp)
end

function PlayerDamage:_send_set_armor()
	if self._unit:network() then
		local armor = math.round(self:armor_ratio() * 100)

		self._unit:network():send("set_armor", math.clamp(armor, 0, 100))
	end
end

function PlayerDamage:stop_heartbeat()
	if self._critical_state_heart_loop_instance then
		self._critical_state_heart_loop_instance:stop()

		self._critical_state_heart_loop_instance = nil
	end

	if self._slomo_sound_instance then
		self._slomo_sound_instance:stop()

		self._slomo_sound_instance = nil
	end

	managers.environment_controller:set_downed_value(0)
	SoundDevice:set_rtpc("downed_state_progression", 0)
	SoundDevice:set_rtpc("stamina", 100)
end

function PlayerDamage:pre_destroy()
	if self._critical_state_heart_loop_instance then
		self._critical_state_heart_loop_instance:stop()
	end

	if self._slomo_sound_instance then
		self._slomo_sound_instance:stop()

		self._slomo_sound_instance = nil
	end

	managers.environment_controller:set_last_life(false)
	managers.environment_controller:set_downed_value(0)
	SoundDevice:set_rtpc("downed_state_progression", 0)
	SoundDevice:set_rtpc("shield_status", 100)
	managers.environment_controller:set_hurt_value(1)
	managers.environment_controller:set_health_effect_value(1)
	managers.environment_controller:set_suppression_value(0)
	managers.sequence:remove_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key())
end

function PlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

function PlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

function PlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

function PlayerDamage:on_fatal_state_enter()
	local dmg_info = {
		result = nil,
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

function PlayerDamage:on_incapacitated_state_enter()
	local dmg_info = {
		result = nil,
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

function PlayerDamage:_chk_dmg_too_soon(damage)
	if managers.player:player_timer():time() < self._next_allowed_dmg_t then
		return true
	end
end

function PlayerDamage:_chk_suppression_too_soon(amount)
	if amount <= self._last_received_sup and managers.player:player_timer():time() < self._next_allowed_sup_t then
		return true
	end
end

function PlayerDamage.clbk_msg_overwrite_criminal_hurt(overwrite_data, msg_queue, msg_name, crim_unit, attacker_unit, dmg)
	if msg_queue then
		local crim_key = crim_unit:key()
		local attacker_key = attacker_unit:key()

		if overwrite_data.indexes[crim_key] and overwrite_data.indexes[crim_key][attacker_key] then
			local index = overwrite_data.indexes[crim_key][attacker_key]
			local old_msg = msg_queue[index]
			old_msg[4] = math.clamp(dmg + old_msg[4], 1, 100)
		else
			table.insert(msg_queue, {
				msg_name,
				crim_unit,
				attacker_unit,
				dmg
			})

			overwrite_data.indexes[crim_key] = {
				[attacker_key] = #msg_queue
			}
		end
	else
		overwrite_data.indexes = {}
	end
end

function PlayerDamage:build_suppression(amount)
	if self:_chk_suppression_too_soon(amount) then
		return
	end

	local data = self._supperssion_data
	amount = amount * managers.player:upgrade_value("player", "suppressed_multiplier", 1)
	local morale_boost_bonus = self._unit:movement():morale_boost()

	if morale_boost_bonus then
		amount = amount * morale_boost_bonus.suppression_resistance
	end

	amount = amount * tweak_data.player.suppression.receive_mul
	data.value = math.min(tweak_data.player.suppression.max_value, (data.value or 0) + amount * tweak_data.player.suppression.receive_mul)
	self._last_received_sup = amount
	self._next_allowed_sup_t = managers.player:player_timer():time() + self._dmg_interval
	data.decay_start_t = managers.player:player_timer():time() + tweak_data.player.suppression.decay_start_delay
end

function PlayerDamage:_upd_suppression(t, dt)
	local data = self._supperssion_data

	if data.value then
		if data.decay_start_t < t then
			data.value = data.value - dt

			if data.value <= 0 then
				data.value = nil
				data.decay_start_t = nil

				managers.environment_controller:set_suppression_value(0, 0)
			end
		elseif data.value == tweak_data.player.suppression.max_value and self._regenerate_timer then
			self:set_regenerate_timer_to_max()
		end

		if data.value then
			managers.environment_controller:set_suppression_value(self:effective_suppression_ratio(), self:suppression_ratio())
		end
	end
end

function PlayerDamage:_upd_health_regen(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end

	if not self._health_regen_update_timer then
		local health_ratio = self:health_ratio()
		local real_armor = self:get_real_armor()
		local max_health = self:_max_health()
		local regen_rate = managers.player:health_regen(health_ratio, real_armor)

		if regen_rate < 0 then
			local health_change = regen_rate * max_health

			self:_calc_health_damage({
				damage = nil,
				variant = "bullet",
				damage = math.abs(health_change)
			})
		elseif regen_rate > 0 and self:get_real_health() < max_health then
			self:restore_health(regen_rate, false)
		end

		self._health_regen_update_timer = 1

		managers.player:upgrade_value("player", "box_o_choc_health_regen_timer_multiplier", 1)
	end
end

function PlayerDamage:suppression_ratio()
	return (self._supperssion_data.value or 0) / tweak_data.player.suppression.max_value
end

function PlayerDamage:effective_suppression_ratio()
	local effective_ratio = math.max(0, (self._supperssion_data.value or 0) - tweak_data.player.suppression.tolerance) / (tweak_data.player.suppression.max_value - tweak_data.player.suppression.tolerance)

	return effective_ratio
end

function PlayerDamage:is_suppressed()
	return self:effective_suppression_ratio() > 0
end

function PlayerDamage:reset_suppression()
	self._supperssion_data.value = nil
	self._supperssion_data.decay_start_t = nil
end

function PlayerDamage:on_flashbanged(sound_eff_mul)
	if self._downed_timer then
		return
	end

	self:_start_tinnitus(sound_eff_mul)
end

function PlayerDamage:_start_tinnitus(sound_eff_mul)
	local tinnitus_sound_enabled = managers.user:get_setting("tinnitus_sound_enabled")

	if not tinnitus_sound_enabled then
		return
	end

	if self._tinnitus_data then
		if sound_eff_mul < self._tinnitus_data.intensity then
			return
		end

		self._tinnitus_data.intensity = sound_eff_mul
		self._tinnitus_data.duration = 4 + sound_eff_mul * math.lerp(8, 12, math.random())
		self._tinnitus_data.end_t = managers.player:player_timer():time() + self._tinnitus_data.duration

		if self._tinnitus_data.snd_event then
			self._tinnitus_data.snd_event:stop()
		end

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))

		self._tinnitus_data.snd_event = self._unit:sound():play("tinnitus_beep")
	else
		local duration = 4 + sound_eff_mul * math.lerp(8, 12, math.random())

		SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, sound_eff_mul * 100))

		self._tinnitus_data = {
			duration = nil,
			end_t = nil,
			intensity = nil,
			snd_event = nil,
			intensity = sound_eff_mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration,
			snd_event = self._unit:sound():play("tinnitus_beep")
		}
	end
end

function PlayerDamage:_stop_tinnitus()
	if not self._tinnitus_data then
		return
	end

	self._unit:sound():play("tinnitus_beep_stop")

	self._tinnitus_data = nil
end

function PlayerDamage:get_armor_regenerate_timer()
	return self._regenerate_timer or 0
end

function PlayerDamage:get_armor_regenerate_speed()
	return self._regenerate_speed or 1
end

function PlayerDamage:get_max_revives()
	local add_lives = managers.player:upgrade_value("player", "revenant_additional_life", 0)
	local max_lives = self._class_tweak_data.damage.BASE_LIVES + add_lives

	return max_lives
end

function PlayerDamage:is_max_revives()
	local max_lives = self:get_max_revives()

	return max_lives == self._revives
end

function PlayerDamage:force_set_revives(revives)
	self._revives = math.clamp(revives, 0, self:get_max_revives())

	managers.hud:set_player_downs(self._revives)
end

function PlayerDamage:_change_revives(change)
	local prev_revives = self._revives
	self._revives = math.clamp(self._revives + change, 0, self:get_max_revives())

	managers.hud:set_player_downs(self._revives)

	return self._revives ~= prev_revives
end

function PlayerDamage:set_health_effects_blocked(value)
	self._health_effects_blocked = value

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_SET_HEALTH_EFFECTS, value)
end

function PlayerDamage:health_effects_blocked()
	return self._health_effects_blocked == true
end

function PlayerDamage:run_queued_teammate_panel_update()
end

function PlayerDamage:set_damage_fall_disabled()
	Application:warn("[PlayerDamage:set_damage_fall_disabled] This has not been programmed yet!")
end

function PlayerDamage:setup_upgrades()
	local interval_multiplier = managers.player:upgrade_value("player", "painkiller_damage_interval_multiplier", 1)
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL * interval_multiplier

	managers.player:update_health_regen_values()
end

function PlayerDamage:_perseverance_increase_timer(params)
	if not self._perseverance then
		self:disable_perseverance()

		return
	end

	local meter = managers.warcry:current_meter_value()
	local current_duration = meter * params.max_duration
	local new_duration = math.min(current_duration + params.timer_increase, params.max_duration)
	local value = new_duration / params.max_duration - meter

	managers.warcry:fill_meter_by_value(value)

	params.timer_increase = params.timer_increase * tweak_data.upgrades.perseverance_timer_diminish
end

function PlayerDamage:_check_martyrdom()
	if not managers.player:has_category_upgrade("player", "fragstone_downed_martyrdom") then
		return
	end

	local consume_grenade = not managers.player:upgrade_value("player", "fragstone_martyrdom_no_consumption", false)

	if consume_grenade and not managers.player:can_throw_grenade() then
		return
	end

	local equipped_grenade = managers.blackmarket:equipped_grenade()
	local projectile_data = tweak_data.projectiles[equipped_grenade]

	if not projectile_data.damage or not projectile_data.is_a_grenade or not projectile_data.max_amount then
		equipped_grenade = managers.blackmarket:get_category_default("grenade")
	end

	if Network:is_server() then
		self:on_martyrdom(equipped_grenade)
	else
		local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(equipped_grenade)

		managers.network:session():send_to_host("sync_martyrdom", self._unit, projectile_index)
	end

	if consume_grenade then
		managers.player:on_throw_grenade()
	end
end

function PlayerDamage:on_martyrdom(projectile_entry)
	if Network:is_client() or not alive(self._unit) then
		return
	end

	local husk_player = self._unit:base().is_husk_player and self._unit

	if not PlayerSkill.has_skill("player", "fragstone_downed_martyrdom", husk_player) then
		return
	end

	local index = tweak_data.blackmarket:get_index_from_projectile_id("cluster")
	local unit_position = self._unit:position() + math.UP * tweak_data.player.PLAYER_EYE_HEIGHT
	local projectile_data = tweak_data.projectiles[projectile_entry]
	local clusters_to_spawn = projectile_data.max_amount
	local upgraded = PlayerSkill.skill_data("player", "fragstone_downed_martyrdom", husk_player)

	if upgraded then
		if projectile_data.upgrade_amount then
			local upgrade = projectile_data.upgrade_amount
			clusters_to_spawn = clusters_to_spawn + PlayerSkill.skill_data(upgrade.category, upgrade.upgrade, 0, husk_player)
		end

		if projectile_data.upgrade_amounts then
			for _, upgrade in pairs(projectile_data.upgrade_amounts) do
				clusters_to_spawn = clusters_to_spawn + PlayerSkill.skill_data(upgrade.category, upgrade.upgrade, 0, husk_player)
			end
		end
	end

	for i = 1, clusters_to_spawn do
		local spawn_position = Vector3(unit_position.x + math.random(-10, 10), unit_position.y + math.random(-10, 10), unit_position.z + math.random(-6, 4))
		local direction = (spawn_position - unit_position):normalized()
		local cluster = ProjectileBase.throw_projectile(index, spawn_position, direction, managers.network:session():local_peer():id(), nil, projectile_entry)

		cluster:base():set_range(projectile_data.range)
		cluster:base():set_damage(projectile_data.damage)
	end
end

PlayerBodyDamage = PlayerBodyDamage or class()

function PlayerBodyDamage:init(unit, unit_extension, body)
	self._unit = unit
	self._unit_extension = unit_extension
	self._body = body
end

function PlayerBodyDamage:get_body()
	return self._body
end

function PlayerBodyDamage:damage_fire(attack_unit, normal, position, direction, damage, velocity)
	print("PlayerBodyDamage:damage_fire", damage)

	local attack_data = {
		col_ray = nil,
		damage = nil,
		damage = damage,
		col_ray = {
			ray = nil,
			ray = -direction
		}
	}

	self._unit_extension:damage_killzone(attack_data)
end
