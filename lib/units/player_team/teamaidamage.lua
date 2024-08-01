require("lib/units/beings/player/PlayerDamage")

TeamAIDamage = TeamAIDamage or class()
TeamAIDamage._all_event_types = {
	"bleedout",
	"death",
	"hurt",
	"light_hurt",
	"heavy_hurt",
	"fatal",
	"none"
}
TeamAIDamage._RESULT_INDEX_TABLE = {
	light_hurt = 4,
	hurt = 1,
	bleedout = 2,
	heavy_hurt = 5,
	death = 3,
	fatal = 6
}
TeamAIDamage._HEALTH_GRANULARITY = CopDamage._HEALTH_GRANULARITY
TeamAIDamage.set_invulnerable = CopDamage.set_invulnerable
TeamAIDamage._hurt_severities = CopDamage._hurt_severities
TeamAIDamage.get_damage_type = CopDamage.get_damage_type

-- Lines 13-43
function TeamAIDamage:init(unit)
	self._unit = unit
	self._char_tweak = tweak_data.character[unit:base()._tweak_table]
	local damage_tweak = self._char_tweak.damage
	self._HEALTH_INIT = damage_tweak.HEALTH_INIT
	self._HEALTH_BLEEDOUT_INIT = damage_tweak.BLEED_OUT_HEALTH_INIT
	self._HEALTH_TOTAL = self._HEALTH_INIT + self._HEALTH_BLEEDOUT_INIT
	self._HEALTH_TOTAL_PERCENT = self._HEALTH_TOTAL / 100
	self._health = self._HEALTH_INIT
	self._health_ratio = self._health / self._HEALTH_INIT
	self._invulnerable = false
	self._char_dmg_tweak = damage_tweak
	self._focus_delay_mul = 1
	self._listener_holder = EventListenerHolder:new()
	self._bleed_out_paused_count = 0
	self._dmg_interval = damage_tweak.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = -100
	self._last_received_dmg = 0
	self._spine2_obj = unit:get_object(Idstring("Spine2"))
	self._tase_effect_table = {
		effect = tweak_data.common_effects.taser_hit,
		parent = self._unit:get_object(Idstring("e_taser"))
	}
end

-- Lines 47-58
function TeamAIDamage:update(unit, t, dt)
	if self._regenerate_t and self._regenerate_t < t then
		self:_regenerated()
	end

	if self._revive_reminder_line_t and self._revive_reminder_line_t < t then
		managers.dialog:queue_dialog("player_gen_call_help", {
			skip_idle_check = true,
			instigator = self._unit
		})

		self._revive_reminder_line_t = nil
	end
end

-- Lines 62-88
function TeamAIDamage:damage_melee(attack_data)
	if self._invulnerable or self._dead or self._fatal then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return
	end

	local result = {
		variant = "melee"
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
	local t = TimerManager:game():time()
	self._next_allowed_dmg_t = t + self._dmg_interval
	self._last_received_dmg_t = t

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_melee_attack_result(attack_data)

	return result
end

-- Lines 92-112
function TeamAIDamage:force_bleedout()
	local attack_data = {
		damage = 100000,
		pos = Vector3(),
		col_ray = {
			position = Vector3()
		}
	}
	local result = {
		type = "none",
		variant = "bullet"
	}
	attack_data.result = result
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result, true)
	self._next_allowed_dmg_t = TimerManager:game():time() + self._dmg_interval
	self._last_received_dmg = health_subtracted

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_bullet_attack_result(attack_data)
end

-- Lines 116-147
function TeamAIDamage:damage_bullet(attack_data)
	local result = {
		type = "none",
		variant = "bullet"
	}
	attack_data.result = result

	if self:_cannot_take_damage() then
		self:_call_listeners(attack_data)

		return
	elseif PlayerDamage._chk_dmg_too_soon(self, attack_data.damage) then
		self:_call_listeners(attack_data)

		return
	elseif PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		self:friendly_fire_hit()

		return
	end

	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
	local t = TimerManager:game():time()
	self._next_allowed_dmg_t = t + self._dmg_interval
	self._last_received_dmg_t = t
	self._last_received_dmg = health_subtracted

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_bullet_attack_result(attack_data)

	return result
end

-- Lines 151-177
function TeamAIDamage:damage_explosion(attack_data)
	if self:_cannot_take_damage() then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if PlayerDamage.is_friendly_fire(self, attacker_unit) then
		self:friendly_fire_hit()

		return
	end

	local result = {
		variant = attack_data.variant
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_explosion_attack_result(attack_data)

	return result
end

-- Lines 179-211
function TeamAIDamage:damage_fire(attack_data)
	if self:_cannot_take_damage() then
		return
	end

	if self._unit:brain():objective() and self._unit:brain():objective().type == "revive" then
		return false
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if PlayerDamage.is_friendly_fire(self, attacker_unit) then
		self:friendly_fire_hit()

		return
	end

	local result = {
		variant = attack_data.variant
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_fire_attack_result(attack_data)

	return result
end

-- Lines 215-237
function TeamAIDamage:damage_mission(attack_data)
	if self._dead or self._invulnerable and not attack_data.forced then
		return
	end

	local result = nil
	local damage_percent = self._HEALTH_GRANULARITY
	attack_data.damage = self._health
	attack_data.variant = "explosion"
	local result = {
		variant = attack_data.variant
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_explosion_attack_result(attack_data)

	return result
end

-- Lines 241-287
function TeamAIDamage:damage_tase(attack_data)
	if attack_data ~= nil and PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		self:friendly_fire_hit()

		return
	end

	if self:_cannot_take_damage() then
		return
	end

	self._regenerate_t = nil
	local damage_info = {
		variant = "tase",
		result = {
			type = "hurt"
		}
	}

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)

	if Network:is_server() then
		if math.random() < 0.25 then
			self._unit:sound():say("s07x_sin", true)
		end

		if not self._to_incapacitated_clbk_id then
			self._to_incapacitated_clbk_id = "TeamAIDamage_to_incapacitated" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._to_incapacitated_clbk_id, callback(self, self, "clbk_exit_to_incapacitated"), TimerManager:game():time() + self._char_dmg_tweak.TASED_TIME)
		end
	end

	self:_call_listeners(damage_info)

	if Network:is_server() then
		self:_send_tase_attack_result()
	end

	return damage_info
end

-- Lines 291-342
function TeamAIDamage:_apply_damage(attack_data, result, force)
	local damage = attack_data.damage * 0.8
	damage = math.clamp(damage, self._HEALTH_TOTAL_PERCENT, self._HEALTH_TOTAL)
	local damage_percent = math.ceil(damage / self._HEALTH_TOTAL_PERCENT)
	damage = damage_percent * self._HEALTH_TOTAL_PERCENT
	attack_data.damage = damage
	local dodged = nil

	if not force then
		dodged = self:inc_dodge_count(damage_percent / 2)
	end

	attack_data.pos = attack_data.pos or attack_data.col_ray.position
	attack_data.result = result

	if not force and (dodged or self._unit:anim_data().dodge) then
		result.type = "none"

		return 0, 0
	end

	local health_subtracted = nil

	if self._bleed_out then
		health_subtracted = self._bleed_out_health
		self._bleed_out_health = self._bleed_out_health - damage

		self:_check_fatal()

		if self._fatal then
			result.type = "fatal"
			self._health_ratio = 0
		else
			health_subtracted = damage
			result.type = "hurt"
			self._health_ratio = self._bleed_out_health / self._HEALTH_BLEEDOUT_INIT
		end
	else
		health_subtracted = self._health
		self._health = self._health - damage

		self:_check_bleed_out()

		if self._bleed_out then
			result.type = "bleedout"
			self._health_ratio = 1
		else
			health_subtracted = damage
			result.type = self:get_damage_type(damage_percent, "bullet") or "none"

			self:_on_hurt()

			self._health_ratio = self._health / self._HEALTH_INIT
		end
	end

	return damage_percent, health_subtracted
end

-- Lines 346-348
function TeamAIDamage:friendly_fire_hit()
	self:inc_dodge_count(2)
end

-- Lines 352-376
function TeamAIDamage:inc_dodge_count(n)
	local t = Application:time()

	if not self._to_dodge_t or self._to_dodge_t - t < 0 then
		self._to_dodge_t = t
	end

	self._to_dodge_t = self._to_dodge_t + n

	if self._to_dodge_t - t < 3 then
		return
	end

	if self._dodge_t and t - self._dodge_t < 5 then
		return
	end

	self._to_dodge_t = nil
	self._dodge_t = nil

	if CopLogicBase.chk_start_action_dodge(self._unit:brain()._logic_data, "hit") then
		self._dodge_t = t

		self:_on_hurt()

		return true
	end
end

-- Lines 380-382
function TeamAIDamage:down_time()
	return self._char_dmg_tweak.DOWNED_TIME
end

-- Lines 386-413
function TeamAIDamage:_check_bleed_out()
	if self._health <= 0 then
		self._bleed_out_health = self._HEALTH_BLEEDOUT_INIT
		self._health = 0
		self._bleed_out = true
		self._regenerate_t = nil
		self._bleed_out_paused_count = 0

		if Network:is_server() then
			if not self._to_dead_clbk_id then
				self._to_dead_clbk_id = "TeamAIDamage_to_dead" .. tostring(self._unit:key())
				self._to_dead_t = TimerManager:game():time() + self:down_time()

				managers.enemy:add_delayed_clbk(self._to_dead_clbk_id, callback(self, self, "clbk_exit_to_dead"), self._to_dead_t)
			end

			managers.dialog:queue_dialog("player_gen_downed", {
				skip_idle_check = true,
				instigator = self._unit
			})

			self._revive_reminder_line_t = self._to_dead_t - 10
		end

		managers.groupai:state():on_criminal_disabled(self._unit)

		if Network:is_server() then
			managers.groupai:state():report_criminal_downed(self._unit)
		end

		self._unit:interaction():set_tweak_data("revive")
		self._unit:interaction():set_active(true, false)
		managers.hud:on_teammate_downed(self._unit:unit_data().teammate_panel_id, self._unit:unit_data().name_label_id)
	end
end

-- Lines 417-431
function TeamAIDamage:_check_fatal()
	if self._bleed_out_health <= 0 then
		if not self._bleed_out then
			self._unit:interaction():set_tweak_data("revive")
			self._unit:interaction():set_active(true, false)
		end

		self._bleed_out = nil
		self._bleed_death_t = nil
		self._bleed_out_health = nil
		self._health_ratio = 0
		self._fatal = true

		managers.groupai:state():on_criminal_disabled(self._unit)
		PlayerMovement.set_attention_settings(self._unit:brain(), nil, "team_AI")
	end
end

TeamAIDamage.get_paused_counter_name_by_peer = PlayerDamage.get_paused_counter_name_by_peer

-- Lines 439-455
function TeamAIDamage:pause_bleed_out(peer_id)
	self._bleed_out_paused_count = self._bleed_out_paused_count + 1

	PlayerDamage.set_peer_paused_counter(self, peer_id, "bleed_out")

	if (self._bleed_out or self._fatal) and self._bleed_out_paused_count == 1 then
		self._to_dead_remaining_t = self._to_dead_t - TimerManager:game():time()

		if self._to_dead_remaining_t < 0 then
			return
		end

		if Network:is_server() then
			managers.enemy:remove_delayed_clbk(self._to_dead_clbk_id)

			self._to_dead_clbk_id = nil
		end

		self._to_dead_t = nil
	end
end

-- Lines 459-472
function TeamAIDamage:unpause_bleed_out(peer_id)
	self._bleed_out_paused_count = self._bleed_out_paused_count - 1

	PlayerDamage.set_peer_paused_counter(self, peer_id, nil)

	if (self._bleed_out or self._fatal) and self._bleed_out_paused_count == 0 then
		self._to_dead_t = TimerManager:game():time() + self._to_dead_remaining_t

		if Network:is_server() and not self._dead and not self._to_dead_clbk_id then
			self._to_dead_clbk_id = "TeamAIDamage_to_dead" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._to_dead_clbk_id, callback(self, self, "clbk_exit_to_dead"), self._to_dead_t)
		end

		self._to_dead_remaining_t = nil
	end
end

-- Lines 476-478
function TeamAIDamage:stop_bleedout()
	self:_regenerated()
end

-- Lines 482-497
function TeamAIDamage:_on_hurt()
	if self._to_incapacitated_clbk_id then
		return
	end

	local regen_time = self._char_dmg_tweak.REGENERATE_TIME_AWAY
	local dis_limit = 6250000

	for _, crim in pairs(managers.groupai:state():all_player_criminals()) do
		if mvector3.distance_sq(self._unit:movement():m_pos(), crim.unit:movement():m_pos()) < 6250000 then
			regen_time = self._char_dmg_tweak.REGENERATE_TIME

			break
		end
	end

	self._regenerate_t = TimerManager:game():time() + regen_time
end

-- Lines 501-503
function TeamAIDamage:bleed_out()
	return self._bleed_out
end

-- Lines 507-509
function TeamAIDamage:fatal()
	return self._fatal
end

-- Lines 513-515
function TeamAIDamage:is_downed()
	return self._bleed_out or self._fatal
end

-- Lines 519-534
function TeamAIDamage:_regenerated()
	self._health = self._HEALTH_INIT
	self._health_ratio = 1

	if self._bleed_out then
		self._bleed_out = nil
		self._bleed_death_t = nil
		self._bleed_out_health = nil
	elseif self._fatal then
		self._fatal = nil
	end

	self._bleed_out_paused_count = 0
	self._to_dead_t = nil
	self._to_dead_remaining_t = nil

	self:_clear_damage_transition_callbacks()

	self._regenerate_t = nil
end

-- Lines 538-539
function TeamAIDamage:_convert_to_health_percentage(health_abs)
end

-- Lines 543-548
function TeamAIDamage:_clamp_health_percentage(health_abs)
	health_abs = math.clamp(health_abs, self._HEALTH_TOTAL_PERCENT, self._HEALTH_TOTAL)
	local health_percent = math.ceil(health_abs / self._HEALTH_TOTAL_PERCENT)
	health_abs = health_percent * self._HEALTH_TOTAL_PERCENT

	return health_abs, health_percent
end

-- Lines 552-564
function TeamAIDamage:_die()
	self._dead = true
	self._revive_reminder_line_t = nil

	if self._bleed_out or self._fatal then
		self._unit:interaction():set_active(false, false)

		self._bleed_out = nil
		self._bleed_out_health = nil
	end

	self._regenerate_t = nil
	self._health_ratio = 0

	self._unit:base():set_slot(self._unit, 17)
	self:_clear_damage_transition_callbacks()
end

-- Lines 568-576
function TeamAIDamage:_unregister_unit()
	local char_name = managers.criminals:character_name_by_unit(self._unit)

	managers.groupai:state():on_AI_criminal_death(char_name, self._unit)
	managers.groupai:state():on_criminal_neutralized(self._unit)
	self._unit:base():unregister()
	self:_clear_damage_transition_callbacks()
	Network:detach_unit(self._unit)
end

-- Lines 580-582
function TeamAIDamage:_send_damage_drama(attack_data, health_subtracted)
	PlayerDamage._send_damage_drama(self, attack_data, health_subtracted)
end

-- Lines 586-588
function TeamAIDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

-- Lines 592-594
function TeamAIDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

-- Lines 598-600
function TeamAIDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

-- Lines 604-606
function TeamAIDamage:get_base_health()
	return self._HEALTH_INIT
end

-- Lines 608-610
function TeamAIDamage:health_ratio()
	return self._health_ratio
end

-- Lines 614-616
function TeamAIDamage:focus_delay_mul()
	return 1
end

-- Lines 620-622
function TeamAIDamage:dead()
	return self._dead
end

-- Lines 626-662
function TeamAIDamage:sync_damage_bullet(attacker_unit, damage, i_body, hit_offset_height)
	if self:_cannot_take_damage() then
		return
	end

	local body = self._unit:body(i_body)
	damage = damage * self._HEALTH_TOTAL_PERCENT
	local result = {
		variant = "bullet"
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "bullet",
		attacker_unit = attacker_unit,
		damage = damage,
		attack_dir = attack_dir,
		pos = hit_pos
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	self:_send_damage_drama(attack_data, health_subtracted)
	self:_send_bullet_attack_result(attack_data, hit_offset_height)
	self:_call_listeners(attack_data)
end

-- Lines 666-700
function TeamAIDamage:sync_damage_explosion(attacker_unit, damage, i_attack_variant)
	if self:_cannot_take_damage() then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	damage = damage * self._HEALTH_TOTAL_PERCENT
	local result = {
		variant = variant
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_com())
	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		damage = damage,
		attack_dir = attack_dir,
		pos = hit_pos
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	self:_send_damage_drama(attack_data, health_subtracted)
	self:_send_explosion_attack_result(attack_data)
	self:_call_listeners(attack_data)
end

-- Lines 704-738
function TeamAIDamage:sync_damage_fire(attacker_unit, damage, i_attack_variant)
	if self:_cannot_take_damage() then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	damage = damage * self._HEALTH_TOTAL_PERCENT
	local result = {
		variant = variant
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_com())
	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		damage = damage,
		attack_dir = attack_dir,
		pos = hit_pos
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	self:_send_damage_drama(attack_data, health_subtracted)
	self:_send_fire_attack_result(attack_data)
	self:_call_listeners(attack_data)
end

-- Lines 742-779
function TeamAIDamage:sync_damage_melee(attacker_unit, damage, damage_effect_percent, i_body, hit_offset_height)
	if self:_cannot_take_damage() then
		return
	end

	local body = self._unit:body(i_body)
	damage = damage * self._HEALTH_TOTAL_PERCENT
	local result = {
		variant = "melee"
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()

		mvector3.negate(attack_dir)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit,
		damage = damage,
		attack_dir = attack_dir,
		pos = hit_pos
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)

	self:_send_damage_drama(attack_data, health_subtracted)
	self:_send_melee_attack_result(attack_data, hit_offset_height)
	self:_call_listeners(attack_data)
end

-- Lines 783-785
function TeamAIDamage:shoot_pos_mid(m_pos)
	self._spine2_obj:m_position(m_pos)
end

-- Lines 789-791
function TeamAIDamage:need_revive()
	return (self._bleed_out or self._fatal) and not self._dead
end

-- Lines 795-829
function TeamAIDamage:revive(reviving_unit)
	if self._dead then
		return
	end

	self._revive_reminder_line_t = nil

	if self._bleed_out or self._fatal then
		self:_regenerated()

		local action_data = {
			variant = "stand",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				aim = -1,
				walk = -1
			}
		}
		local res = self._unit:movement():action_request(action_data)

		self._unit:interaction():set_active(false, false)
		self._unit:brain():on_recovered(reviving_unit)
		PlayerMovement.set_attention_settings(self._unit:brain(), {
			"team_enemy_cbt"
		}, "team_AI")
		self._unit:network():send("from_server_unit_recovered")
		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	managers.hud:on_teammate_revived(self._unit:unit_data().teammate_panel_id, self._unit:unit_data().name_label_id)
	managers.dialog:queue_dialog("player_gen_revive_thanks", {
		skip_idle_check = true,
		instigator = self._unit
	})
end

-- Lines 833-841
function TeamAIDamage:_send_bullet_attack_result(attack_data, hit_offset_height)
	hit_offset_height = hit_offset_height or math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local result_index = self._RESULT_INDEX_TABLE[attack_data.result.type] or 0

	self._unit:network():send("from_server_damage_bullet", attacker, hit_offset_height, result_index)
end

-- Lines 845-852
function TeamAIDamage:_send_explosion_attack_result(attack_data)
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local result_index = self._RESULT_INDEX_TABLE[attack_data.result.type] or 0

	self._unit:network():send("from_server_damage_explosion_fire", attacker, result_index, CopDamage._get_attack_variant_index(self, attack_data.variant))
end

-- Lines 854-861
function TeamAIDamage:_send_fire_attack_result(attack_data)
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local result_index = self._RESULT_INDEX_TABLE[attack_data.result.type] or 0

	self._unit:network():send("from_server_damage_explosion_fire", attacker, result_index, CopDamage._get_attack_variant_index(self, attack_data.variant))
end

-- Lines 865-873
function TeamAIDamage:_send_melee_attack_result(attack_data, hit_offset_height)
	hit_offset_height = hit_offset_height or math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local result_index = self._RESULT_INDEX_TABLE[attack_data.result.type] or 0

	self._unit:network():send("from_server_damage_melee", attacker, hit_offset_height, result_index)
end

-- Lines 877-879
function TeamAIDamage:_send_tase_attack_result()
	self._unit:network():send("from_server_damage_tase")
end

-- Lines 883-911
function TeamAIDamage:on_tase_ended()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if self._to_incapacitated_clbk_id then
		self._regenerate_t = TimerManager:game():time() + self._char_dmg_tweak.REGENERATE_TIME

		managers.enemy:remove_delayed_clbk(self._to_incapacitated_clbk_id)

		self._to_incapacitated_clbk_id = nil
		local action_data = {
			variant = "stand",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt = -1,
				action = -1,
				walk = -1
			}
		}
		local res = self._unit:movement():action_request(action_data)

		self._unit:network():send("from_server_unit_recovered")
		managers.groupai:state():on_criminal_recovered(self._unit)
		self._unit:brain():on_recovered()
	end
end

-- Lines 915-918
function TeamAIDamage:clbk_exit_to_incapacitated()
	self._to_incapacitated_clbk_id = nil

	self:_on_incapacitated()
end

-- Lines 922-927
function TeamAIDamage:on_incapacitated()
	if self:_cannot_take_damage() then
		return
	end

	self:_on_incapacitated()
end

-- Lines 931-957
function TeamAIDamage:_on_incapacitated()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)

		self._tase_effect = nil
	end

	if self._to_incapacitated_clbk_id then
		managers.enemy:remove_delayed_clbk(self._to_incapacitated_clbk_id)

		self._to_incapacitated_clbk_id = nil
	end

	self._regenerate_t = nil
	local dmg_info = {
		variant = "bleeding",
		result = {
			type = "fatal"
		}
	}
	self._bleed_out_health = 0

	self:_check_fatal()

	if not self._to_dead_clbk_id then
		self._to_dead_clbk_id = "TeamAIDamage_to_dead" .. tostring(self._unit:key())
		self._to_dead_t = TimerManager:game():time() + self._char_dmg_tweak.INCAPACITATED_TIME

		managers.enemy:add_delayed_clbk(self._to_dead_clbk_id, callback(self, self, "clbk_exit_to_dead"), self._to_dead_t)
	end

	self:_call_listeners(dmg_info)
	self._unit:network():send("from_server_damage_incapacitated")
end

-- Lines 961-970
function TeamAIDamage:clbk_exit_to_dead(from_client_join)
	self._to_dead_clbk_id = nil

	self:_die()

	if not from_client_join then
		self._unit:network():send("from_server_damage_bleeding")
	end

	local dmg_info = {
		variant = "bleeding",
		result = {
			type = "death"
		},
		join_game = from_client_join
	}

	self:_call_listeners(dmg_info)
	self:_unregister_unit()
end

-- Lines 974-976
function TeamAIDamage:pre_destroy()
	self:_clear_damage_transition_callbacks()
end

-- Lines 980-988
function TeamAIDamage:_cannot_take_damage()
	return self._invulnerable or self._dead or self._fatal
end

-- Lines 992-994
function TeamAIDamage:disable()
	self:_clear_damage_transition_callbacks()
end

-- Lines 998-1007
function TeamAIDamage:_clear_damage_transition_callbacks()
	if self._to_incapacitated_clbk_id then
		managers.enemy:remove_delayed_clbk(self._to_incapacitated_clbk_id)

		self._to_incapacitated_clbk_id = nil
	end

	if self._to_dead_clbk_id then
		managers.enemy:remove_delayed_clbk(self._to_dead_clbk_id)

		self._to_dead_clbk_id = nil
	end
end

-- Lines 1011-1013
function TeamAIDamage:last_suppression_t()
	return self._last_received_dmg_t
end

-- Lines 1017-1019
function TeamAIDamage:can_attach_projectiles()
	return false
end

-- Lines 1023-1033
function TeamAIDamage:save(data)
	if self._bleed_out then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.bleedout = true
	end

	if self._fatal then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.fatal = true
	end
end

-- Lines 1035-1036
function TeamAIDamage:run_queued_teammate_panel_update()
end
