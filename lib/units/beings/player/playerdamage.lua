PlayerDamage = PlayerDamage or class()
PlayerDamage._ARMOR_STEPS = tweak_data.player.damage.ARMOR_STEPS
PlayerDamage._ARMOR_DAMAGE_REDUCTION = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION
PlayerDamage._ARMOR_DAMAGE_REDUCTION_STEPS = tweak_data.player.damage.ARMOR_DAMAGE_REDUCTION_STEPS

-- Lines 15-68
function PlayerDamage:init(unit)
	self._unit = unit
	self._player_class = managers.skilltree:get_character_profile_class() or "recon"
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)
	self._revives = Application:digest_value(0, true)

	self:replenish()

	self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)
	self._god_mode = Global.god_mode
	self._invulnerable = false
	self._mission_damage_blockers = {}
	self._gui = Overlay:newgui()
	self._ws = self._gui:create_screen_workspace()
	self._focus_delay_mul = 1
	self._listener_holder = EventListenerHolder:new()
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = Application:digest_value(-100, true)
	self._last_received_dmg = 0
	self._next_allowed_sup_t = -100
	self._last_received_sup = 0
	self._supperssion_data = {}
	self._inflict_damage_body = self._unit:body("inflict_reciever")

	self._inflict_damage_body:set_extension(self._inflict_damage_body:extension() or {})

	local body_ext = PlayerBodyDamage:new(self._unit, self, self._inflict_damage_body)
	self._inflict_damage_body:extension().damage = body_ext

	managers.sequence:add_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key(), self._inflict_damage_body:extension().damage)

	self._doh_data = tweak_data.upgrades.damage_to_hot_data or {}
	self._damage_to_hot_stack = {}
	self._armor_stored_health = 0

	SoundDevice:set_rtpc("downed_state_progression", 0)
	Application:trace("set downed_state_progression to 0")
	SoundDevice:set_rtpc("downed_tank_progression", 0)
	Application:trace("set downed_tank_progression to 0")

	if managers.raid_job:is_camp_loaded() then
		self:set_invulnerable(true)
	end
end

-- Lines 70-72
function PlayerDamage:post_init()
	self:send_set_status()
end

-- Lines 74-82
function PlayerDamage:send_set_status()
	self:_send_set_armor()
	self:_send_set_health()
end

-- Lines 84-93
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

-- Lines 95-98
function PlayerDamage:get_revives()
	local revives = Application:digest_value(self._revives, false)

	return revives
end

-- Lines 101-110
function PlayerDamage:force_into_bleedout()
	self:set_health(0)
	self:_chk_cheat_death()
	self:_damage_screen()
	self:_check_bleed_out()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
end

-- Lines 112-252
function PlayerDamage:update(unit, t, dt)
	if not self._armor_stored_health_max_set then
		self._armor_stored_health_max_set = true

		self:update_armor_stored_health()
	end

	local is_berserker_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if self._check_berserker_done then
		if not is_berserker_active then
			self._check_berserker_done = nil

			managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
			self:force_into_bleedout()
		else
			local expire_time = managers.player:get_activate_temporary_expire_time("temporary", "berserker_damage_multiplier")
			local total_time = managers.player:upgrade_value("temporary", "berserker_damage_multiplier")
			total_time = total_time and total_time[2] or 0
			local delta = 0
			local max_health = self:_max_health()

			if total_time ~= 0 then
				delta = math.clamp((expire_time - Application:time()) / total_time, 0, 1)
			end
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

	if self._regenerate_timer and not self._dead and not self._bleed_out and not self._check_berserker_done then
		if not is_berserker_active and not self._bleed_out_blocked_by_zipline then
			self._regenerate_timer = self._regenerate_timer - dt * (self._regenerate_speed or 1)
			local top_fade = math.clamp(self._hurt_value - 0.8, 0, 1) / 0.2
			local hurt = self._hurt_value - (1 - top_fade) * (1 + math.sin(t * 500)) / 2 / 10

			managers.environment_controller:set_hurt_value(hurt)

			if self._regenerate_timer < 0 then
				self:_regenerate_armor()
			end
		end
	elseif self._hurt_value then
		if not self._dead and not self._bleed_out and not self._check_berserker_done then
			self._hurt_value = math.min(1, self._hurt_value + dt)
			local top_fade = math.clamp(self._hurt_value - 0.8, 0, 1) / 0.2
			local hurt = self._hurt_value - (1 - top_fade) * (1 + math.sin(t * 500)) / 2 / 10

			managers.environment_controller:set_hurt_value(hurt)

			local armor_value = math.max(self._armor_value or 0, self._hurt_value)

			managers.hud:set_player_armor({
				current = self:get_real_armor() * armor_value,
				total = self:_total_armor(),
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
		self._downed_progression = math.max(0, self._downed_progression - dt * 50)

		managers.environment_controller:set_downed_value(self._downed_progression)
		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._downed_progression = nil
		end
	end

	if self._auto_revive_timer then
		if not managers.platform:presence() == "Playing" or not self._bleed_out or self._dead or self:incapacitated() or self:arrested() or self._check_berserker_done then
			self._auto_revive_timer = nil
		else
			self._auto_revive_timer = self._auto_revive_timer - dt

			if self._auto_revive_timer <= 0 then
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")

				self._auto_revive_timer = nil
			end
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

	if not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:_upd_health_regen(t, dt)
	end
end

-- Lines 256-279
function PlayerDamage:band_aid_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		return
	end

	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()

	self._said_hurt = false
	self._said_hurt_half = false

	if math.rand(1) < managers.player:upgrade_value("first_aid_kit", "downs_restore_chance", 0) then
		self._revives = Application:digest_value(math.min(self._class_tweak_data.damage.BASE_LIVES + managers.player:upgrade_value("player", "additional_lives", 0), Application:digest_value(self._revives, false) + 1), true)
		self._revive_health_i = math.max(self._revive_health_i - 1, 1)

		managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)
	end
end

-- Lines 281-288
function PlayerDamage:recover_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		self:revive(true)
	end

	self:_regenerated(true)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
end

-- Lines 290-307
function PlayerDamage:replenish()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		self:revive(true)
	end

	self:_regenerated()
	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	managers.hud:set_player_armor({
		current = self:get_real_armor(),
		total = self:_total_armor(),
		max = self:_max_armor()
	})
	SoundDevice:set_rtpc("shield_status", 100)
	SoundDevice:set_rtpc("downed_state_progression", 0)

	if managers.player:has_category_upgrade("player", "self_administered_adrenaline") then
		self._player_revive_tweak_data = tweak_data.interaction.si_revive
	else
		self._player_revive_tweak_data = nil
	end
end

-- Lines 309-328
function PlayerDamage:debug_replenish()
end

-- Lines 332-343
function PlayerDamage:_regenerate_armor()
	if self._unit:sound() then
		-- Nothing
	end

	self:set_armor(self:_max_armor())

	self._regenerate_timer = nil
	self._regenerate_speed = nil

	self:_send_set_armor()
end

-- Lines 345-346
function PlayerDamage:_inline_RIP1()
end

-- Lines 348-360
function PlayerDamage:restore_health(health_restored, is_static, chk_health_ratio)
	if chk_health_ratio and managers.player:is_damage_health_ratio_active(self:health_ratio()) then
		return false
	end

	if is_static then
		return self:change_health(health_restored)
	else
		local max_health = self:_max_health()

		return self:change_health(max_health * health_restored)
	end
end

-- Lines 362-377
function PlayerDamage:restore_armor(armor_restored)
	if self._dead or self._bleed_out or self._check_berserker_done then
		return
	end

	local max_armor = self:_max_armor()
	local armor = self:get_real_armor()
	local new_armor = math.min(armor + armor_restored, max_armor)

	self:set_armor(new_armor)
	self:_send_set_armor()

	if self._unit:sound() and new_armor ~= armor and new_armor == max_armor then
		-- Nothing
	end

	managers.hud:set_player_armor({
		no_hint = true,
		current = self:get_real_armor(),
		total = self:_total_armor(),
		max = max_armor
	})
end

-- Lines 379-397
function PlayerDamage:update_armor_stored_health()
	if managers.hud then
		local max_health = self:_max_health()

		managers.hud:set_stored_health_max(math.min(self:max_armor_stored_health() / max_health, 1))

		if self._armor_stored_health then
			self._armor_stored_health = math.min(self._armor_stored_health, self:max_armor_stored_health())
			local stored_health_ratio = self._armor_stored_health / max_health

			managers.hud:set_stored_health(stored_health_ratio)
		end
	end
end

-- Lines 399-403
function PlayerDamage:change_regenerate_speed(value, percent)
	if self._regenerate_speed then
		self._regenerate_speed = percent and self._regenerate_speed * value or self._regenerate_speed + value
	end
end

-- Lines 405-416
function PlayerDamage:max_armor_stored_health()
	if not managers.player:has_category_upgrade("player", "armor_health_store_amount") then
		return 0
	end

	local amount = managers.player:body_armor_value("skill_max_health_store", nil, 1)
	local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
	local max = amount * multiplier

	return max
end

-- Lines 418-420
function PlayerDamage:can_store_armor_health()
	return self:get_real_armor() > 0 and not self._dead and not self._bleed_out and not self._check_berserker_done
end

-- Lines 422-424
function PlayerDamage:armor_stored_health(amount)
	return self._armor_stored_health
end

-- Lines 426-428
function PlayerDamage:armor_ratio()
	return self:get_real_armor() / self:_max_armor()
end

-- Lines 430-440
function PlayerDamage:add_armor_stored_health(amount)
	self._armor_stored_health = math.min(self._armor_stored_health + amount, self:max_armor_stored_health())

	if managers.hud and not self._check_berserker_done then
		local stored_health_ratio = self._armor_stored_health / self:_max_health()

		managers.hud:set_stored_health(stored_health_ratio)
	end
end

-- Lines 442-450
function PlayerDamage:clear_armor_stored_health()
	self._armor_stored_health = 0

	if managers.hud then
		managers.hud:set_stored_health(0)
	end
end

-- Lines 452-457
function PlayerDamage:consume_armor_stored_health(amount)
	if self._armor_stored_health and not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:change_health(self._armor_stored_health)
	end

	self:clear_armor_stored_health()
end

-- Lines 460-487
function PlayerDamage:_regenerated(no_messiah)
	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()

	self._said_hurt = false
	self._said_hurt_half = false
	self._revives = Application:digest_value(self._class_tweak_data.damage.BASE_LIVES + managers.player:upgrade_value("player", "additional_lives", 0) + (managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_FIRST_BLEEDOUT_IS_DISREGARDED) and 1 or 0), true)
	self._revive_health_i = 1

	managers.environment_controller:set_last_life(false)

	self._down_time = tweak_data.player.damage.DOWNED_TIME + managers.player:upgrade_value("player", "bleedout_timer_increase")

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER) then
		self._down_time = self._down_time + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER) or 0)
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER) then
		self._down_time = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER) or tweak_data.player.damage.DOWNED_TIME
	end

	if not no_messiah then
		self._messiah_charges = managers.player:upgrade_value("player", "revive_from_bleed_out", 0)
	end
end

-- Lines 489-496
function PlayerDamage:consume_messiah_charge()
	if self:got_messiah_charges() then
		self._messiah_charges = self._messiah_charges - 1

		return true
	end

	return false
end

-- Lines 498-500
function PlayerDamage:got_messiah_charges()
	return self._messiah_charges and self._messiah_charges > 0
end

-- Lines 504-509
function PlayerDamage:set_player_class(class)
	self._player_class = class
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)

	self:_regenerated()
end

-- Lines 511-513
function PlayerDamage:get_base_health_regen()
	return self._class_tweak_data.damage.HEALTH_REGEN
end

-- Lines 515-517
function PlayerDamage:get_real_health()
	return Application:digest_value(self._health, false)
end

-- Lines 519-521
function PlayerDamage:get_base_health()
	return self._class_tweak_data.damage.BASE_HEALTH
end

-- Lines 523-526
function PlayerDamage:get_max_health()
	local max_health = self:_max_health() or self._current_max_health

	return max_health
end

-- Lines 528-530
function PlayerDamage:get_real_armor()
	return Application:digest_value(self._armor, false)
end

-- Lines 532-534
function PlayerDamage:change_health(change_of_health)
	return self:set_health(self:get_real_health() + change_of_health)
end

-- Lines 536-538
function PlayerDamage:restore_health_percentage(percentage)
	self:set_health(self:get_real_health() * percentage)
end

-- Lines 540-571
function PlayerDamage:set_health(health)
	local max_health = self:_max_health()
	self._current_max_health = self._current_max_health or max_health

	if self._current_max_health ~= max_health then
		local prev_health_ratio = health / self._current_max_health
		local new_health_ratio = health / max_health
		local diff_health_ratio = prev_health_ratio - new_health_ratio
		health = health + math.max(0, diff_health_ratio * max_health)
		self._current_max_health = max_health

		self:update_armor_stored_health()
	end

	local prev_health = self._health and Application:digest_value(self._health, false) or health
	self._health = Application:digest_value(math.clamp(health, 0, max_health), true)

	self:_send_set_health()
	self:_set_health_effect()

	if self._said_hurt and self:get_real_health() / self:_max_health() > 0.2 then
		self._said_hurt = false
	end

	if self._said_hurt_half and self:get_real_health() / self:_max_health() >= 0.5 then
		self._said_hurt_half = false
	end

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = max_health,
		revives = Application:digest_value(self._revives, false)
	})

	return prev_health ~= Application:digest_value(self._health, false)
end

-- Lines 573-596
function PlayerDamage:set_armor(armor)
	if self._armor and self:get_real_armor() == 0 and armor ~= 0 then
		self:consume_armor_stored_health()
	end

	self._armor = Application:digest_value(math.clamp(armor, 0, self:_max_armor()), true)
end

-- Lines 599-601
function PlayerDamage:down_time()
	return self._down_time
end

-- Lines 603-605
function PlayerDamage:health_ratio()
	return self:get_real_health() / self:_max_health()
end

-- Lines 607-618
function PlayerDamage:_max_health()
	local base_max_health = self:get_base_health()
	local skill_multiplier = managers.player:health_skill_multiplier()
	local buff_multiplier = 1

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_HEALTH) then
		buff_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_HEALTH)
	end

	return base_max_health * skill_multiplier * buff_multiplier
end

-- Lines 620-635
function PlayerDamage:_total_armor()
	local base_max_armor = self._class_tweak_data.damage.BASE_ARMOR + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
	local mul = managers.player:body_armor_skill_multiplier()

	return base_max_armor * mul
end

-- Lines 637-639
function PlayerDamage:_max_armor()
	return self:_total_armor()
end

-- Lines 641-643
function PlayerDamage:_armor_steps()
	return self._ARMOR_STEPS
end

-- Lines 645-647
function PlayerDamage:_armor_damage_reduction()
	return 0
end

-- Lines 649-655
function PlayerDamage:full_health()
	local diff = math.abs(self:get_real_health() - self:_max_health())

	return diff < 0.001
end

-- Lines 659-683
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

-- Lines 686-690
function PlayerDamage:on_tased(non_lethal)
	if self:get_real_health() == 0 and self._check_berserker_done then
		self:change_health(1)
	end
end

-- Lines 694-696
function PlayerDamage:tase_data()
	return self._tase_data
end

-- Lines 700-702
function PlayerDamage:erase_tase_data()
	self._tase_data = nil
end

local mvec1 = Vector3()

-- Lines 706-763
function PlayerDamage:damage_melee(attack_data)
	local can_counter_strike = managers.player:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		self._unit:movement():current_state():discharge_melee()

		return "countered"
	end

	local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
	blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

	if blood_effect then
		local pos = mvec1

		mvector3.set(pos, self._unit:camera():forward())
		mvector3.multiply(pos, 20)
		mvector3.add(pos, self._unit:camera():position())

		local rot = self._unit:camera():rotation():z()

		World:effect_manager():spawn({
			effect = Idstring("effects/vanilla/impacts/imp_blood_hit_002"),
			position = pos,
			normal = rot
		})
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("melee", self._unit:movement()._current_state)
	attack_data.damage = attack_data.damage * dmg_mul

	self._unit:sound():play("melee_hit_body", nil, nil)

	local result = self:damage_bullet(attack_data)
	local vars = {
		"melee_hit",
		"melee_hit_var2"
	}

	self._unit:camera():play_shaker(vars[math.random(#vars)], 1 * managers.player:upgrade_value("player", "on_hit_flinch_reduction", 1))

	if managers.player:current_state() == "bipod" then
		managers.player:set_player_state("standard")
	end

	if managers.player:current_state() == "turret" then
		managers.player:set_player_state("standard")
	end

	self._unit:movement():push(attack_data.push_vel)

	return result
end

-- Lines 767-777
function PlayerDamage:is_friendly_fire(unit)
	if not unit then
		return
	end

	if unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return
	end

	return not unit:movement():team().foes[self._unit:movement():team().id]
end

-- Lines 781-788
function PlayerDamage:play_whizby(position, is_turret)
	self._unit:sound():play_whizby({
		position = position
	})

	if not is_turret then
		managers.rumble:play("bullet_whizby")
	end
end

-- Lines 792-797
function PlayerDamage:clbk_kill_taunt(attack_data)
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		self._kill_taunt_clbk_id = nil

		attack_data.attacker_unit:sound():say("post_kill_taunt")
	end
end

-- Lines 811-941
function PlayerDamage:damage_bullet(attack_data)
	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}
	local dmg_mul = managers.player:damage_reduction_skill_multiplier("bullet", self._unit:movement()._current_state)

	managers.dialog:queue_dialog("player_gen_taking_fire", {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

	attack_data.damage = attack_data.damage * dmg_mul
	local dodge_roll = math.rand(1)
	local dodge_value = self._class_tweak_data.damage.DODGE_INIT or 0
	local armor_dodge_chance = managers.player:body_armor_value("dodge")
	local skill_dodge_chance = managers.player:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if dodge_roll < dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position, attack_data.is_turret)
		self:_hit_unit(attack_data)

		self._next_allowed_dmg_t = Application:digest_value(managers.player:player_timer():time() + self._dmg_interval, true)
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

	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end

	if self:get_real_armor() > 0 then
		self._unit:sound():play("hit_bullet_1p")
	else
		self._unit:sound():play("hit_bullet_1p")
	end

	local shake_armor_multiplier = managers.player:body_armor_value("damage_shake", nil, 1) * managers.player:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + managers.player:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier

	self._unit:camera():play_shaker("player_bullet_damage", shake_multiplier * managers.player:upgrade_value("player", "on_hit_flinch_reduction", 1))

	if attack_data.is_turret then
		managers.rumble:play("damage_bullet_turret")
	else
		managers.rumble:play("damage_bullet")
	end

	self:_hit_unit(attack_data)
	managers.player:check_damage_carry(attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

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

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	managers.player:activate_temporary_upgrade("temporary", "wolverine_health_regen")

	self._next_allowed_dmg_t = Application:digest_value(managers.player:player_timer():time() + self._dmg_interval, true)
	self._last_received_dmg = health_subtracted

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "tank" then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt", attack_data), TimerManager:game():time() + tweak_data.timespeed.downed.fade_in + tweak_data.timespeed.downed.sustain + tweak_data.timespeed.downed.fade_out)
	end

	self:_call_listeners(damage_info)
end

-- Lines 943-963
function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0

	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		self:set_armor(self:get_real_armor() - attack_data.damage)

		health_subtracted = health_subtracted - self:get_real_armor()

		self:_damage_screen()
		managers.hud:set_player_armor({
			current = self:get_real_armor(),
			total = self:_total_armor(),
			max = self:_max_armor()
		})
		SoundDevice:set_rtpc("shield_status", self:get_real_armor() / self:_total_armor() * 100)
		self:_send_set_armor()

		if self:get_real_armor() <= 0 and attack_data.armor_piercing then
			-- Nothing
		end
	end

	return health_subtracted
end

-- Lines 965-973
function PlayerDamage:_chk_cheat_death()
	if Application:digest_value(self._revives, false) > 1 and not self._check_berserker_done and managers.player:has_category_upgrade("player", "cheat_death_chance") then
		local r = math.rand(1)

		if r <= managers.player:upgrade_value("player", "cheat_death_chance", 0) then
			self._auto_revive_timer = 1
		end
	end
end

-- Lines 975-997
function PlayerDamage:_calc_health_damage(attack_data)
	local health_subtracted = 0
	health_subtracted = self:get_real_health()

	self:change_health(-attack_data.damage)

	health_subtracted = health_subtracted - self:get_real_health()
	local bullet_or_explosion_or_melee = attack_data.variant and (attack_data.variant == "bullet" or attack_data.variant == "explosion" or attack_data.variant == "melee")

	if self:get_real_health() == 0 and bullet_or_explosion_or_melee then
		self:_chk_cheat_death()
	end

	self:_damage_screen()
	self:_check_bleed_out(bullet_or_explosion_or_melee)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)

	return health_subtracted
end

-- Lines 1001-1020
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
	end

	if Network:is_client() then
		self._unit:network():send_to_host("damage_bullet", attacker, 1, 1, 1, false)
	end
end

-- Lines 1024-1055
function PlayerDamage:damage_killzone(attack_data)
	local damage_info = {
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	end

	self._unit:sound():play("player_gen_pain_impact")
	self:_hit_direction(attack_data.col_ray)

	if self._bleed_out then
		return
	end

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage * armor_reduction_multiplier
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

-- Lines 1059-1143
function PlayerDamage:damage_fall(data)
	local damage_info = {
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
	local death_limit = self._class_tweak_data.damage.FALL_DAMAGE_FATAL_HEIGHT

	if data.height < height_limit then
		return
	end

	local die = death_limit < data.height

	self._unit:sound():play("player_gen_pain_impact")
	managers.environment_controller:hit_feedback_down()
	managers.hud:on_hit_direction("down")

	if self._bleed_out and self._unit:movement():current_state_name() ~= "freefall" then
		return
	end

	local health_damage_multiplier = 0

	if die then
		self._check_berserker_done = false

		self:set_health(0)

		if self._unit:movement():current_state_name() == "freefall" then
			self._revives = Application:digest_value(1, true)
		end
	else
		local base_fall_damage = math.lerp(self._class_tweak_data.damage.FALL_DAMAGE_MIN, self._class_tweak_data.damage.FALL_DAMAGE_MAX, (data.height - height_limit) / (death_limit - height_limit))
		base_fall_damage = math.clamp(base_fall_damage, self._class_tweak_data.damage.FALL_DAMAGE_MIN, self._class_tweak_data.damage.FALL_DAMAGE_MAX)
		health_damage_multiplier = managers.player:upgrade_value("player", "fall_damage_multiplier", 1) * managers.player:upgrade_value("player", "fall_health_damage_multiplier", 1)

		self:change_health(-(base_fall_damage * health_damage_multiplier))
	end

	if self._class_tweak_data.stealth.FALL_ALERT_MIN_HEIGHT < data.height then
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

	if die then
		self:set_armor(0)
	else
		self:set_armor(self:get_real_armor() - max_armor * managers.player:upgrade_value("player", "fall_damage_multiplier", 1))
	end

	managers.hud:set_player_armor({
		no_hint = true,
		current = self:get_real_armor(),
		total = self:_total_armor(),
		max = max_armor
	})
	SoundDevice:set_rtpc("shield_status", 0)
	self:_send_set_armor()

	self._bleed_out_blocked_by_movement_state = nil

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	self:_damage_screen()
	self:_check_bleed_out(nil, true)
	self:_call_listeners(damage_info)

	return true
end

-- Lines 1145-1183
function PlayerDamage:damage_explosion(attack_data)
	local damage_info = {
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

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("explosion", self._unit:movement()._current_state)
	attack_data.damage = damage * dmg_mul
	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)
	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

-- Lines 1185-1220
function PlayerDamage:damage_fire(attack_data)
	local damage_info = {
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

	if self:get_real_armor() > 0 then
		-- Nothing
	end

	if self._bleed_out then
		return
	end

	local dmg_mul = managers.player:damage_reduction_skill_multiplier("fire", self._unit:movement()._current_state)
	attack_data.damage = damage * dmg_mul
	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)
	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end

-- Lines 1225-1248
function PlayerDamage:update_downed(t, dt)
	if self._downed_timer and self._downed_paused_counter == 0 then
		self._downed_timer = self._downed_timer - dt

		if self._bleedout_timer then
			self._bleedout_timer = self._bleedout_timer - dt * 30
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

-- Lines 1250-1252
function PlayerDamage:is_berserker()
	return not not self._check_berserker_done
end

-- Lines 1254-1330
function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state)
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		if can_activate_berserker and not self._check_berserker_done then
			local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

			if has_berserker_skill then
				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
				managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				self._check_berserker_done = true

				if alive(managers.interaction:active_unit()) and not managers.interaction:active_unit():interaction():can_interact(self._unit) then
					self._unit:movement():interupt_interact()
				end
			end
		end

		self._hurt_value = 0.2
		self._damage_to_hot_stack = {}

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not self._check_berserker_done or not can_activate_berserker then
			managers.dialog:queue_dialog("player_gen_downed", {
				skip_idle_check = true,
				instigator = managers.player:local_player()
			})

			self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)
			self._check_berserker_done = nil

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

			if Application:digest_value(self._revives, false) == 0 then
				self._down_time = 0
			end

			self._bleed_out = true

			managers.player:set_player_state("bleed_out")

			self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

			if managers.player:has_category_upgrade("temporary", "pistol_revive_from_bleed_out") then
				local upgrade_value = managers.player:upgrade_value("temporary", "pistol_revive_from_bleed_out")

				if upgrade_value ~= 0 then
					local time = upgrade_value[2]

					managers.player:activate_temporary_upgrade("temporary", "pistol_revive_from_bleed_out")
				end
			end

			self:_drop_blood_sample()
			self:on_downed()
		end
	elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.2 then
		self._said_hurt = true

		PlayerStandard.say_line(self, "player_nearly_dead")
	elseif not self._said_hurt_half and self:get_real_health() / self:_max_health() < 0.5 then
		self._said_hurt_half = true

		PlayerStandard.say_line(self, "player_on_half_health")
	end
end

-- Lines 1332-1366
function PlayerDamage:_drop_blood_sample()
	local remove = math.rand(1) < 0.5

	if not remove then
		return
	end

	local removed = false

	if managers.player:has_special_equipment("blood_sample") then
		removed = true

		managers.player:remove_special("blood_sample")
	end

	if managers.player:has_special_equipment("blood_sample_verified") then
		removed = true

		managers.player:remove_special("blood_sample_verified")
	end

	if removed then
		self._unit:sound():play("vial_break_2d")
		self._unit:sound():say("g29", false)

		if managers.groupai:state():bain_state() then
			managers.dialog:queue_dialog("hos_ban_139", {})
		end

		local splatter_from = self._unit:position() + math.UP * 5
		local splatter_to = self._unit:position() - math.UP * 45
		local splatter_ray = World:raycast("ray", splatter_from, splatter_to, "slot_mask", managers.game_play_central._slotmask_world_geometry)

		if splatter_ray then
			World:project_decal(Idstring("blood_spatter"), splatter_ray.position, splatter_ray.ray, splatter_ray.unit, nil, splatter_ray.normal)
		end
	end
end

-- Lines 1368-1372
function PlayerDamage:disable_berserker()
	managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")

	self._check_berserker_done = false
end

-- Lines 1374-1394
function PlayerDamage:on_downed()
	if managers.player:has_category_upgrade("player", "self_administered_adrenaline") then
		managers.hud:show_interact({
			text = managers.localization:text("skill_interaction_revive_prompt", {
				BTN_JUMP = managers.localization:btn_macro("jump")
			})
		})
	end

	self._downed_timer = self:down_time()
	self._downed_start_time = self._downed_timer
	self._downed_paused_counter = 0
	self._bleedout_timer = self:down_time()
	self._damage_to_hot_stack = {}

	self:disable_berserker()
	managers.hud:start_player_timer(self._downed_timer)
	managers.hud:on_teammate_downed(HUDManager.PLAYER_PANEL)
	self:_stop_tinnitus()
	self:clear_armor_stored_health()
end

-- Lines 1398-1400
function PlayerDamage:get_paused_counter_name_by_peer(peer_id)
	return self._paused_counter_name_by_peer_map and self._paused_counter_name_by_peer_map[peer_id]
end

-- Lines 1402-1411
function PlayerDamage:set_peer_paused_counter(peer_id, counter_name)
	if peer_id then
		self._paused_counter_name_by_peer_map = self._paused_counter_name_by_peer_map or {}
		self._paused_counter_name_by_peer_map[peer_id] = counter_name

		if not next(self._paused_counter_name_by_peer_map) then
			self._paused_counter_name_by_peer_map = nil
		end
	end
end

-- Lines 1415-1428
function PlayerDamage:pause_downed_timer(timer, peer_id)
	self._downed_paused_counter = self._downed_paused_counter + 1

	self:set_peer_paused_counter(peer_id, "downed")

	if self._downed_paused_counter == 1 then
		managers.hud:pause_player_timer(true)

		if Network:is_server() then
			managers.network:session():send_to_peers_synched("pause_downed_teammate_timer", 1, true)
		end

		managers.hud:pd_start_progress(0, timer or tweak_data.interaction.revive.timer, "debug_interact_being_revived", "interaction_help")
	end
end

-- Lines 1430-1443
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

-- Lines 1448-1454
function PlayerDamage:update_arrested(t, dt)
	if self._arrested_timer and self._arrested_paused_counter == 0 then
		self._arrested_timer = self._arrested_timer - dt

		return not self:arrested()
	end

	return false
end

-- Lines 1458-1461
function PlayerDamage:on_freed()
	self._arrested_timer = nil
	self._arrested = nil
end

-- Lines 1463-1467
function PlayerDamage:on_arrested()
	self._bleed_out = false
	self._arrested_timer = tweak_data.player.damage.ARRESTED_TIME
	self._arrested_paused_counter = 0
end

-- Lines 1469-1476
function PlayerDamage:pause_arrested_timer(peer_id)
	if not self._arrested_timer or self._arrested_timer <= 0 then
		return
	end

	self._arrested_paused_counter = self._arrested_paused_counter + 1

	self:set_peer_paused_counter(peer_id, "arrested")
end

-- Lines 1478-1485
function PlayerDamage:unpause_arrested_timer(peer_id)
	if not self._arrested_timer or self._arrested_timer <= 0 then
		return
	end

	self._arrested_paused_counter = self._arrested_paused_counter - 1

	self:set_peer_paused_counter(peer_id, nil)
end

-- Lines 1490-1497
function PlayerDamage:update_incapacitated(t, dt)
	return self:update_downed(t, dt)
end

-- Lines 1499-1502
function PlayerDamage:on_incapacitated()
	self:on_downed()

	self._incapacitated = true
end

-- Lines 1506-1508
function PlayerDamage:bleed_out()
	return self._bleed_out
end

-- Lines 1512-1514
function PlayerDamage:incapacitated()
	return self._incapacitated
end

-- Lines 1518-1520
function PlayerDamage:arrested()
	return self._arrested_timer or self._arrested
end

-- Lines 1524-1544
function PlayerDamage:_bleed_out_damage(attack_data)
	return

	local health_subtracted = Application:digest_value(self._bleed_out_health, false)
	self._bleed_out_health = Application:digest_value(math.max(0, health_subtracted - attack_data.damage), true)
	health_subtracted = health_subtracted - Application:digest_value(self._bleed_out_health, false)
	self._next_allowed_dmg_t = Application:digest_value(managers.player:player_timer():time() + self._dmg_interval, true)
	self._last_received_dmg = health_subtracted

	if Application:digest_value(self._bleed_out_health, false) <= 0 then
		managers.player:set_player_state("fatal")
	end

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end
end

-- Lines 1548-1590
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

-- Lines 1592-1594
function PlayerDamage:_hit_unit(attack_data)
	managers.hud:on_hit_unit(attack_data)
end

-- Lines 1598-1605
function PlayerDamage:_damage_screen()
	self:set_regenerate_timer_to_max()

	self._hurt_value = 1 - math.clamp(0.8 - math.pow(self:get_real_armor() / self:_max_armor(), 2), 0, 1)
	self._armor_value = math.clamp(self:get_real_armor() / self:_max_armor(), 0, 1)

	managers.environment_controller:set_hurt_value(self._hurt_value)
end

-- Lines 1609-1612
function PlayerDamage:set_revive_boost(revive_health_level)
	self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level]

	print("PlayerDamage:set_revive_boost", "revive_health_level", revive_health_level, "revive_health_multiplier", tostring(self._revive_health_multiplier))
end

-- Lines 1616-1678
function PlayerDamage:revive(helped_self)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:set_player_state("standard")

	if not helped_self then
		managers.dialog:queue_dialog("player_gen_thanks", {
			skip_idle_check = true,
			instigator = managers.player:local_player()
		})
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil
	self._bleedout_timer = nil

	if not arrested then
		self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * (self._revive_health_multiplier or 1))
		self:set_armor(self:_total_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:stop_player_timer()
	managers.hud:on_teammate_revived(HUDManager.PLAYER_PANEL)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_complete_progress()

	self._revive_health_multiplier = nil

	if managers.player:has_category_upgrade("temporary", "revived_damage_bonus") then
		managers.player:activate_temporary_upgrade("temporary", "revived_damage_bonus")
	end

	if managers.player:has_category_upgrade("temporary", "revived_melee_damage_bonus") then
		managers.player:activate_temporary_upgrade("temporary", "revived_melee_damage_bonus")
	end

	if managers.player:has_category_upgrade("temporary", "on_revived_damage_reduction") then
		managers.player:activate_temporary_upgrade("temporary", "on_revived_damage_reduction")
	end
end

-- Lines 1682-1684
function PlayerDamage:need_revive()
	return self._bleed_out or self._incapacitated
end

-- Lines 1688-1690
function PlayerDamage:is_downed()
	return self._bleed_out or self._incapacitated
end

-- Lines 1694-1696
function PlayerDamage:dead()
	return self._dead
end

-- Lines 1700-1702
function PlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

-- Lines 1704-1706
function PlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

-- Lines 1710-1714
function PlayerDamage:set_god_mode(state)
	Global.god_mode = state
	self._god_mode = state

	self:print("PlayerDamage god mode " .. (state and "ON" or "OFF"))
end

-- Lines 1718-1720
function PlayerDamage:god_mode()
	return self._god_mode
end

-- Lines 1724-1726
function PlayerDamage:print(...)
	cat_print("player_damage", ...)
end

-- Lines 1730-1732
function PlayerDamage:set_invulnerable(state)
	self._invulnerable = state
end

-- Lines 1736-1739
function PlayerDamage:set_danger_level(danger_level)
	self._danger_level = self._danger_level ~= danger_level and danger_level or nil
	self._focus_delay_mul = danger_level and tweak_data.danger_zones[self._danger_level] or 1
end

-- Lines 1743-1745
function PlayerDamage:focus_delay_mul()
	return self._focus_delay_mul
end

-- Lines 1749-1751
function PlayerDamage:shoot_pos_mid(m_pos)
	mvector3.set(m_pos, self._unit:movement():m_head_pos())
end

-- Lines 1755-1757
function PlayerDamage:got_max_doh_stacks()
	return self._doh_data.max_stacks and #self._damage_to_hot_stack >= (tonumber(self._doh_data.max_stacks) or 1)
end

-- Lines 1760-1770
function PlayerDamage:add_damage_to_hot()
	if self:got_max_doh_stacks() then
		return
	end

	if self:need_revive() or self:dead() or self._check_berserker_done then
		return
	end

	table.insert(self._damage_to_hot_stack, {
		next_tick = TimerManager:game():time() + (self._doh_data.tick_time or 1),
		ticks_left = (self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0)
	})
	table.sort(self._damage_to_hot_stack, function (x, y)
		return x.next_tick < y.next_tick
	end)
end

-- Lines 1774-1779
function PlayerDamage:set_regenerate_timer_to_max()
	local mul = managers.player:body_armor_regen_multiplier(alive(self._unit) and self._unit:movement():current_state()._moving, self:health_ratio())
	self._regenerate_timer = tweak_data.player.damage.REGENERATE_TIME * mul
	self._regenerate_speed = self._regenerate_speed or 1
end

-- Lines 1783-1796
function PlayerDamage:_send_set_health()
	if self._unit:network() then
		local hp = math.round(self:get_real_health() / self:_max_health() * 100)

		self._unit:network():send("set_health", math.clamp(hp, 0, 100))

		if hp ~= 100 then
			managers.mission:call_global_event("player_damaged")
		end
	end
end

-- Lines 1798-1802
function PlayerDamage:_set_health_effect()
	local hp = self:get_real_health() / self:_max_health()

	math.clamp(hp, 0, 1)
	managers.environment_controller:set_health_effect_value(hp)
end

-- Lines 1806-1815
function PlayerDamage:_send_set_armor()
	if self._unit:network() then
		local armor = math.round(self:get_real_armor() / self:_total_armor() * 100)

		self._unit:network():send("set_armor", math.clamp(armor, 0, 100))
	end
end

-- Lines 1839-1851
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

-- Lines 1853-1874
function PlayerDamage:pre_destroy()
	if alive(self._gui) and alive(self._ws) then
		self._gui:destroy_workspace(self._ws)
	end

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

-- Lines 1878-1880
function PlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

-- Lines 1884-1886
function PlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

-- Lines 1890-1892
function PlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

-- Lines 1896-1901
function PlayerDamage:on_fatal_state_enter()
	local dmg_info = {
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

-- Lines 1905-1910
function PlayerDamage:on_incapacitated_state_enter()
	local dmg_info = {
		result = {
			type = "death"
		}
	}

	self:_call_listeners(dmg_info)
end

-- Lines 1914-1919
function PlayerDamage:_chk_dmg_too_soon(damage)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)

	if damage <= self._last_received_dmg + 0.01 and managers.player:player_timer():time() < next_allowed_dmg_t then
		return true
	end
end

-- Lines 1923-1927
function PlayerDamage:_chk_suppression_too_soon(amount)
	if amount <= self._last_received_sup and managers.player:player_timer():time() < self._next_allowed_sup_t then
		return true
	end
end

-- Lines 1931-1946
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

-- Lines 1950-1971
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

-- Lines 1975-1996
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

-- Lines 2000-2043
function PlayerDamage:_upd_health_regen(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end

	if not self._health_regen_update_timer then
		local regen_rate = managers.player:health_regen()
		local max_health = self:_max_health()

		if regen_rate < 0 then
			local health_change = regen_rate * max_health

			self:_calc_health_damage({
				variant = "bullet",
				damage = math.abs(health_change)
			})
		elseif regen_rate > 0 and self:get_real_health() < max_health then
			self:restore_health(regen_rate, false)
		end

		self._health_regen_update_timer = 1
	end

	if #self._damage_to_hot_stack > 0 then
		repeat
			local next_doh = self._damage_to_hot_stack[1]
			local done = not next_doh or TimerManager:game():time() < next_doh.next_tick

			if not done then
				local regen_rate = managers.player:upgrade_value("player", "damage_to_hot", 0)

				self:restore_health(regen_rate, true)

				next_doh.ticks_left = next_doh.ticks_left - 1

				if next_doh.ticks_left == 0 then
					table.remove(self._damage_to_hot_stack, 1)
				else
					next_doh.next_tick = next_doh.next_tick + (self._doh_data.tick_time or 1)
				end

				table.sort(self._damage_to_hot_stack, function (x, y)
					return x.next_tick < y.next_tick
				end)
			end
		until done
	end
end

-- Lines 2047-2049
function PlayerDamage:suppression_ratio()
	return (self._supperssion_data.value or 0) / tweak_data.player.suppression.max_value
end

-- Lines 2053-2056
function PlayerDamage:effective_suppression_ratio()
	local effective_ratio = math.max(0, (self._supperssion_data.value or 0) - tweak_data.player.suppression.tolerance) / (tweak_data.player.suppression.max_value - tweak_data.player.suppression.tolerance)

	return effective_ratio
end

-- Lines 2060-2062
function PlayerDamage:is_suppressed()
	return self:effective_suppression_ratio() > 0
end

-- Lines 2066-2069
function PlayerDamage:reset_suppression()
	self._supperssion_data.value = nil
	self._supperssion_data.decay_start_t = nil
end

-- Lines 2073-2078
function PlayerDamage:on_flashbanged(sound_eff_mul)
	if self._downed_timer then
		return
	end

	self:_start_tinnitus(sound_eff_mul)
end

-- Lines 2082-2106
function PlayerDamage:_start_tinnitus(sound_eff_mul)
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
			intensity = sound_eff_mul,
			duration = duration,
			end_t = managers.player:player_timer():time() + duration,
			snd_event = self._unit:sound():play("tinnitus_beep")
		}
	end
end

-- Lines 2110-2118
function PlayerDamage:_stop_tinnitus()
	if not self._tinnitus_data then
		return
	end

	self._unit:sound():play("tinnitus_beep_stop")

	self._tinnitus_data = nil
end

-- Lines 2120-2122
function PlayerDamage:get_armor_regenerate_timer()
	return self._regenerate_timer or 0
end

-- Lines 2124-2126
function PlayerDamage:get_armor_regenerate_speed()
	return self._regenerate_speed or 1
end

-- Lines 2128-2130
function PlayerDamage:force_set_revives(revives)
	self._revives = Application:digest_value(0, true)
end

-- Lines 2132-2133
function PlayerDamage:run_queued_teammate_panel_update()
end

PlayerBodyDamage = PlayerBodyDamage or class()

-- Lines 2139-2143
function PlayerBodyDamage:init(unit, unit_extension, body)
	self._unit = unit
	self._unit_extension = unit_extension
	self._body = body
end

-- Lines 2145-2147
function PlayerBodyDamage:get_body()
	return self._body
end

-- Lines 2149-2157
function PlayerBodyDamage:damage_fire(attack_unit, normal, position, direction, damage, velocity)
	print("PlayerBodyDamage:damage_fire", damage)

	local attack_data = {
		damage = damage,
		col_ray = {
			ray = -direction
		}
	}

	self._unit_extension:damage_killzone(attack_data)
end
