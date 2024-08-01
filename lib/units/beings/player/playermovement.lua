require("lib/units/beings/player/states/PlayerMovementState")
require("lib/units/beings/player/states/PlayerEmpty")
require("lib/units/beings/player/states/PlayerStandard")
require("lib/units/beings/player/states/PlayerBleedOut")
require("lib/units/beings/player/states/PlayerFatal")
require("lib/units/beings/player/states/PlayerTased")
require("lib/units/beings/player/states/PlayerIncapacitated")
require("lib/units/beings/player/states/PlayerCarry")
require("lib/units/beings/player/states/PlayerCarryCorpse")
require("lib/units/beings/player/states/PlayerBipod")
require("lib/units/beings/player/states/PlayerDriving")
require("lib/units/beings/player/states/PlayerParachuting")
require("lib/units/beings/player/states/PlayerFreefall")
require("lib/units/beings/player/states/PlayerTurret")
require("lib/units/beings/player/states/PlayerFoxhole")
require("lib/units/beings/player/states/PlayerCharging")

PlayerMovement = PlayerMovement or class()
PlayerMovement._STATES = {
	empty = PlayerEmpty,
	standard = PlayerStandard,
	bleed_out = PlayerBleedOut,
	fatal = PlayerFatal,
	tased = PlayerTased,
	incapacitated = PlayerIncapacitated,
	carry = PlayerCarry,
	carry_corpse = PlayerCarryCorpse,
	bipod = PlayerBipod,
	driving = PlayerDriving,
	parachuting = PlayerParachuting,
	freefall = PlayerFreefall,
	turret = PlayerTurret,
	foxhole = PlayerFoxhole,
	charging = PlayerCharging
}
PlayerMovement.OUT_OF_WORLD_Z = -4000

-- Lines 41-108
function PlayerMovement:init(unit)
	self._unit = unit
	self._player_class = managers.skilltree:get_character_profile_class() or "recon"
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)

	unit:set_timer(managers.player:player_timer())
	unit:set_animation_timer(managers.player:player_timer())

	self._machine = self._unit:anim_state_machine()
	self._next_check_out_of_world_t = 1
	self._last_sent_remote_pos_t = 0
	self._nav_tracker = nil
	self._pos_rsrv_id = nil

	self:set_driving("script")

	self._m_pos = unit:position()
	self._m_stand_pos = mvector3.copy(self._m_pos)

	mvector3.set_z(self._m_stand_pos, self._m_pos.z + tweak_data.player.PLAYER_EYE_HEIGHT)

	self._m_com = math.lerp(self._m_pos, self._m_stand_pos, 0.5)
	self._kill_overlay_t = managers.player:player_timer():time() + 5
	self._state_data = {
		in_air = false,
		ducking = false
	}
	self._synced_suspicion = false
	self._suspicion_ratio = false
	self._SO_access = managers.navigation:convert_access_flag("teamAI1")
	self._regenerate_timer = nil
	self._stamina = self:_max_stamina()

	managers.hud:set_stamina_value(self._stamina)
	managers.hud:reset_player_state()

	self._underdog_skill_data = {
		max_dis_sq = 3240000,
		chk_t = 6,
		chk_interval_active = 6,
		nr_enemies = 2,
		chk_interval_inactive = 1,
		has_dmg_dampener = managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered") or managers.player:has_category_upgrade("temporary", "dmg_dampener_outnumbered_strong"),
		has_dmg_mul = managers.player:has_category_upgrade("temporary", "dmg_multiplier_outnumbered")
	}

	if managers.player:has_category_upgrade("player", "morale_boost") or managers.player:has_category_upgrade("player", "long_dis_revive") then
		self._rally_skill_data = {
			range_sq = 490000,
			morale_boost_delay_t = managers.player:has_category_upgrade("player", "morale_boost") and 0 or nil,
			long_dis_revive = managers.player:has_category_upgrade("player", "long_dis_revive"),
			revive_chance = managers.player:upgrade_value("player", "long_dis_revive", 0),
			morale_boost_cooldown_t = tweak_data.upgrades.morale_boost_base_cooldown
		}
	end

	self:set_friendly_fire(true)
end

-- Lines 112-139
function PlayerMovement:post_init()
	self._m_head_rot = self._unit:camera()._m_cam_rot
	self._m_head_pos = self._unit:camera()._m_cam_pos

	if managers.navigation:is_data_ready() and (not Global.running_simulation or Global.running_simulation_with_mission) then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._unit:position())
		self._pos_rsrv_id = managers.navigation:get_pos_reservation_id()
	end

	self._unit:inventory():add_listener("PlayerMovement" .. tostring(self._unit:key()), {
		"add",
		"equip"
	}, callback(self, self, "inventory_clbk_listener"))

	self._states = {}
	self._attention_handler = CharacterAttentionObject:new(self._unit, true)
	self._enemy_weapons_hot_listen_id = "PlayerMovement" .. tostring(self._unit:key())

	managers.groupai:state():add_listener(self._enemy_weapons_hot_listen_id, {
		"enemy_weapons_hot"
	}, callback(self, self, "clbk_enemy_weapons_hot"))

	if Network:is_client() then
		self._unit:network():send_to_host("sync_remote_position", self._m_head_pos, self._m_pos)
	end

	self._check_other_players_in_foxhole = true
end

-- Lines 143-145
function PlayerMovement:attention_handler()
	return self._attention_handler
end

-- Lines 149-151
function PlayerMovement:nav_tracker()
	return self._nav_tracker
end

-- Lines 155-157
function PlayerMovement:pos_rsrv_id()
	return self._pos_rsrv_id
end

-- Lines 161-167
function PlayerMovement:warp_to(pos, rot)
	self:set_m_pos(pos)
	mrotation.set_zero(self:m_head_rot())
	mrotation.multiply(self:m_head_rot(), rot)
	self._unit:warp_to(rot, pos)
	self._unit:network():send("sync_warp_position", pos, rot)
end

-- Lines 171-181
function PlayerMovement:_setup_state(name)
	if not PlayerMovement._STATES[name] then
		return
	end

	local new_state = self._states[name] or PlayerMovement._STATES[name]:new(self._unit)
	self._states[name] = new_state

	return new_state
end

-- Lines 185-192
function PlayerMovement:set_character_anim_variables()
	local camera_unit = self._unit:camera():camera_unit()

	if camera_unit:damage() then
		local char_name = managers.criminals:character_name_by_unit(self._unit)
		local sequence = managers.blackmarket:character_sequence_by_character_name(char_name)

		camera_unit:damage():has_then_run_sequence_simple(sequence)
	end
end

-- Lines 196-198
function PlayerMovement:set_driving(mode)
	self._unit:set_driving(mode)
end

-- Lines 201-219
function PlayerMovement:change_state(name)
	local exit_data = nil

	if self._current_state then
		exit_data = self._current_state:exit(self._state_data, name)
	end

	local new_state = self._states[name] or self:_setup_state(name)

	if not new_state then
		return
	end

	self._current_state = new_state
	self._current_state_name = name
	self._state_enter_t = managers.player:player_timer():time()

	new_state:enter(self._state_data, exit_data)
	self._unit:network():send("sync_player_movement_state", self._current_state_name, self._unit:character_damage():down_time(), self._unit:id())
end

-- Lines 223-281
function PlayerMovement:update(unit, t, dt)
	if self._check_other_players_in_foxhole then
		local ready = true

		for _, peer in pairs(managers.network:session():peers()) do
			if peer:unit() and peer:unit():movement()._wait_load then
				ready = false
			end
		end

		if ready then
			self._check_other_players_in_foxhole = nil

			if self:other_players_in_foxhole() then
				local units = World:find_units_quick("all", 39)

				for _, unit in ipairs(units) do
					if unit:foxhole() and not unit:foxhole():taken() then
						unit:interaction():interact(self._unit)

						break
					end
				end
			end
		end
	end

	self:_calculate_m_pose()

	if self:_check_out_of_world(t) then
		return
	end

	self:_upd_underdog_skill(t)

	if self._current_state then
		self._current_state:update(t, dt)
	end

	if self._kill_overlay_t and self._kill_overlay_t < t then
		self._kill_overlay_t = nil

		managers.overlay_effect:stop_effect()
	end

	self:update_stamina(t, dt)
end

-- Lines 336-391
function PlayerMovement:update_stamina(t, dt, ignore_running)
	local dt = self._last_stamina_regen_t and t - self._last_stamina_regen_t or dt
	self._last_stamina_regen_t = t

	if not ignore_running and self._is_running then
		local drain_multiplier = 1

		if managers.player:is_carrying() then
			local ratio = nil
			local carry_data = managers.player:get_my_carry_data()
			local carry_item = carry_data[1]
			local carry_type = tweak_data.carry[carry_item.carry_id].type
			ratio = (managers.player:has_category_upgrade("player", "bellhop_weight_penalty_removal_throwables") and managers.player:equipped_weapon_index() == tweak_data.WEAPON_SLOT_THROWABLE or managers.player:has_category_upgrade("player", "bellhop_weight_penalty_removal_melees") and managers.player:equipped_weapon_index() == tweak_data.WEAPON_SLOT_MELEE) and 0 or managers.player:get_my_carry_weight_ratio()
			drain_multiplier = tweak_data.carry:get_type_value_weighted(carry_type, "stamina_consume_multi", ratio) - 1
			local multiplier = managers.player:upgrade_value("player", "bellhop_carry_stamina_consume_slower", 1)
			multiplier = multiplier * managers.player:upgrade_value("carry", "dac_stamina_consumption_reduction", 1)
			drain_multiplier = drain_multiplier * multiplier + 1
		end

		self:subtract_stamina(dt * self._class_tweak_data.movement.stamina.BASE_STAMINA_DRAIN_RATE * drain_multiplier)
	elseif self._regenerate_timer then
		self._regenerate_timer = self._regenerate_timer - dt

		if self._regenerate_timer < 0 then
			self:add_stamina(dt * self._class_tweak_data.movement.stamina.BASE_STAMINA_REGENERATION_RATE)

			if self:_max_stamina() <= self._stamina then
				self._regenerate_timer = nil

				if self._exhausted then
					self._exhausted = nil

					managers.hud:set_stamina_value(self._stamina)
				end
			end
		end
	end
end

-- Lines 395-404
function PlayerMovement:set_position(pos)
	self._unit:set_position(pos)

	local now = TimerManager:game():time()

	if not Network:is_server() and now - self._last_sent_remote_pos_t > 0.5 then
		self._unit:network():send_to_host("sync_remote_position", self._m_head_pos, self._m_pos)

		self._last_sent_remote_pos_t = now
	end
end

-- Lines 408-412
function PlayerMovement:set_m_pos(pos)
	mvector3.set(self._m_pos, pos)
	mvector3.set(self._m_stand_pos, pos)
	mvector3.set_z(self._m_stand_pos, pos.z + tweak_data.player.PLAYER_EYE_HEIGHT)
end

-- Lines 416-418
function PlayerMovement:m_pos()
	return self._m_pos
end

-- Lines 422-424
function PlayerMovement:m_stand_pos()
	return self._m_stand_pos
end

-- Lines 428-430
function PlayerMovement:m_com()
	return self._m_com
end

-- Lines 434-436
function PlayerMovement:m_head_pos()
	return self._m_head_pos
end

-- Lines 440-442
function PlayerMovement:m_head_rot()
	return self._m_head_rot
end

-- Lines 446-448
function PlayerMovement:m_detect_pos()
	return self._m_head_pos
end

-- Lines 452-454
function PlayerMovement:m_newest_pos()
	return self._m_pos
end

-- Lines 458-460
function PlayerMovement:get_object(object_name)
	return self._unit:get_object(object_name)
end

-- Lines 469-473
function PlayerMovement:downed()
	return self._current_state_name == "bleed_out" or self._current_state_name == "fatal" or self._current_state_name == "incapacitated"
end

-- Lines 478-480
function PlayerMovement:current_state()
	return self._current_state
end

-- Lines 484-486
function PlayerMovement:_calculate_m_pose()
	mvector3.lerp(self._m_com, self._m_pos, self._m_head_pos, 0.5)
end

-- Lines 488-497
function PlayerMovement:_check_out_of_world(t)
	if self._next_check_out_of_world_t < t then
		self._next_check_out_of_world_t = t + 1

		if mvector3.z(self._m_pos) < PlayerMovement.OUT_OF_WORLD_Z then
			managers.player:on_out_of_world()

			return true
		end
	end

	return false
end

-- Lines 501-504
function PlayerMovement:play_redirect(redirect_name, at_time)
	local result = self._unit:play_redirect(Idstring(redirect_name), at_time)

	return result ~= Idstring("") and result
end

-- Lines 508-511
function PlayerMovement:play_state(state_name, at_time)
	local result = self._unit:play_state(Idstring(state_name), at_time)

	return result ~= Idstring("") and result
end

-- Lines 515-517
function PlayerMovement:chk_action_forbidden(action_type)
	return self._current_state.chk_action_forbidden and self._current_state:chk_action_forbidden(action_type)
end

-- Lines 520-527
function PlayerMovement:linked(state, physical, parent_unit)
	if state then
		self._link_data = {
			physical = physical,
			parent = parent_unit
		}

		parent_unit:base():add_destroy_listener("PlayerMovement" .. tostring(self._unit:key()), callback(self, self, "parent_clbk_unit_destroyed"))
	else
		self._link_data = nil
	end
end

-- Lines 531-534
function PlayerMovement:parent_clbk_unit_destroyed(parent_unit, key)
	self._link_data = nil

	parent_unit:base():remove_destroy_listener("PlayerMovement" .. tostring(self._unit:key()))
end

-- Lines 538-540
function PlayerMovement:is_physically_linked()
	return self._link_data and self._link_data.physical
end

-- Lines 544-548
function PlayerMovement:on_uncovered(enemy_unit)
	self._state_data.uncovered = true

	managers.player:set_player_state("standard")

	self._state_data.uncovered = nil
end

-- Lines 552-557
function PlayerMovement:on_non_lethal_electrocution()
	self._state_data.non_lethal_electrocution = true

	if alive(self._unit) then
		self._unit:character_damage():on_tased(true)
	end
end

-- Lines 561-566
function PlayerMovement:on_tase_ended()
	if self._current_state_name == "tased" then
		self._unit:character_damage():erase_tase_data()
		self._current_state:on_tase_ended()
	end
end

-- Lines 570-572
function PlayerMovement:tased()
	return self._current_state_name == "tased"
end

-- Lines 576-578
function PlayerMovement:current_state_name()
	return self._current_state_name
end

-- Lines 582-584
function PlayerMovement:state_enter_time()
	return self._state_enter_t
end

-- Lines 588-607
function PlayerMovement:_create_attention_setting_from_descriptor(setting_desc, setting_name)
	local setting = clone(setting_desc)
	setting.id = setting_name
	setting.filter = managers.groupai:state():get_unit_type_filter(setting.filter)
	setting.reaction = AIAttentionObject[setting.reaction]
	setting.team = self._team

	if setting.notice_clbk then
		if self[setting.notice_clbk] then
			setting.notice_clbk = callback(self, self, setting.notice_clbk)
		else
			debug_pause("[PlayerMovement:_create_attention_setting_from_descriptor] no notice_clbk defined in class", self._unit, setting.notice_clbk)
		end
	end

	if self._apply_attention_setting_modifications then
		self:_apply_attention_setting_modifications(setting)
	end

	return setting
end

-- Lines 611-613
function PlayerMovement:_apply_attention_setting_modifications(setting)
	setting.detection = self._unit:base():detection_settings()
end

-- Lines 617-672
function PlayerMovement:set_attention_settings(settings_list)
	if not self._attention_handler then
		return
	end

	local changes = self._attention_handler:chk_settings_diff(settings_list)

	if not changes then
		return
	end

	local all_attentions = nil

	-- Lines 633-645
	local function _add_attentions_to_all(names)
		for _, setting_name in ipairs(names) do
			local setting_desc = tweak_data.attention.settings[setting_name]

			if setting_desc then
				all_attentions = all_attentions or {}
				local setting = self:_create_attention_setting_from_descriptor(setting_desc, setting_name)
				all_attentions[setting_name] = setting
			else
				debug_pause_unit(self._unit, "[PlayerMovement:set_attention_settings] invalid setting", setting_name, self._unit)
			end
		end
	end

	if changes.added then
		_add_attentions_to_all(changes.added)
	end

	if changes.maintained then
		_add_attentions_to_all(changes.maintained)
	end

	self._attention_handler:set_settings_set(all_attentions)

	if Network:is_client() then
		if changes.added then
			for _, id in ipairs(changes.added) do
				local index = tweak_data.attention:get_attention_index(id)

				self._unit:network():send_to_host("set_attention_enabled", index, true)
			end
		end

		if changes.removed then
			for _, id in ipairs(changes.removed) do
				local index = tweak_data.attention:get_attention_index(id)

				self._unit:network():send_to_host("set_attention_enabled", index, false)
			end
		end
	end
end

-- Lines 676-681
function PlayerMovement:clbk_attention_notice_sneak(observer_unit, status)
	if alive(observer_unit) then
		self:on_suspicion(observer_unit, status)
	end
end

-- Lines 685-729
function PlayerMovement:on_suspicion(observer_unit, status)
	if status == true then
		managers.voice_over:guard_saw_enemy(observer_unit)
	end

	if Network:is_server() then
		self._suspicion_debug = self._suspicion_debug or {}
		self._suspicion_debug[observer_unit:key()] = {
			unit = observer_unit,
			name = observer_unit:name(),
			status = status
		}
		local visible_status = nil

		if managers.groupai:state():whisper_mode() then
			visible_status = status
		else
			visible_status = false
		end

		self._suspicion = self._suspicion or {}

		if visible_status == false or visible_status == true then
			self._suspicion[observer_unit:key()] = nil

			if not next(self._suspicion) then
				self._suspicion = nil
			end

			if visible_status and observer_unit:movement() and not observer_unit:movement():cool() and TimerManager:game():time() - observer_unit:movement():not_cool_t() > 1 then
				return
			end
		elseif type(visible_status) == "number" and (not observer_unit:movement() or observer_unit:movement():cool()) then
			self._suspicion[observer_unit:key()] = visible_status
		else
			return
		end

		self:_calc_suspicion_ratio_and_sync(observer_unit, visible_status)
	else
		self._suspicion_ratio = status
	end

	self:_feed_suspicion_to_hud()
end

-- Lines 733-740
function PlayerMovement:_feed_suspicion_to_hud()
	local susp_ratio = self._suspicion_ratio

	if type(susp_ratio) == "number" then
		local offset = self._unit:base():suspicion_settings().hud_offset
		susp_ratio = susp_ratio * (1 - offset) + offset
	end

	managers.hud:set_suspicion(susp_ratio)
end

-- Lines 744-782
function PlayerMovement:_calc_suspicion_ratio_and_sync(observer_unit, status)
	local suspicion_sync = nil

	if self._suspicion and status ~= true then
		local max_suspicion = nil

		for u_key, val in pairs(self._suspicion) do
			if not max_suspicion or max_suspicion < val then
				max_suspicion = val
			end
		end

		if max_suspicion then
			self._suspicion_ratio = math.clamp(max_suspicion, 0, 1)
			suspicion_sync = math.ceil(self._suspicion_ratio * 254)
		else
			self._suspicion_ratio = false
			suspicion_sync = false
		end
	elseif type(status) == "boolean" then
		self._suspicion_ratio = status
		suspicion_sync = status and 255 or 0
	else
		self._suspicion_ratio = false
		suspicion_sync = 0
	end

	if suspicion_sync < 0 then
		suspicion_sync = 0
	end

	if suspicion_sync ~= self._synced_suspicion then
		self._synced_suspicion = suspicion_sync
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			managers.network:session():send_to_peers_synched("suspicion", peer:id(), suspicion_sync)
		end
	end
end

-- Lines 786-800
function PlayerMovement.clbk_msg_overwrite_suspicion(overwrite_data, msg_queue, msg_name, suspect_peer_id, suspicion)
	if msg_queue then
		if overwrite_data.indexes[suspect_peer_id] then
			local index = overwrite_data.indexes[suspect_peer_id]
			local old_msg = msg_queue[index]
			old_msg[3] = suspicion
		else
			table.insert(msg_queue, {
				msg_name,
				suspect_peer_id,
				suspicion
			})

			overwrite_data.indexes[suspect_peer_id] = #msg_queue
		end
	else
		overwrite_data.indexes = {}
	end
end

-- Lines 804-820
function PlayerMovement:clbk_enemy_weapons_hot()
	self._suspicion_ratio = false
	self._suspicion = false

	if Network:is_server() and self._synced_suspicion ~= 0 then
		self._synced_suspicion = 0
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			managers.network:session():send_to_peers_synched("suspicion", peer:id(), 0)
		end
	end

	self:_feed_suspicion_to_hud()
end

-- Lines 824-833
function PlayerMovement:inventory_clbk_listener(unit, event)
	if event == "add" then
		local data = self._unit:inventory():get_latest_addition_hud_data()

		managers.hud:add_weapon(data)
	end

	if self._current_state and self._current_state.inventory_clbk_listener then
		self._current_state:inventory_clbk_listener(unit, event)
	end
end

-- Lines 837-839
function PlayerMovement:SO_access()
	return self._SO_access
end

-- Lines 843-845
function PlayerMovement:rally_skill_data()
	return self._rally_skill_data
end

-- Lines 849-889
function PlayerMovement:_upd_underdog_skill(t)
	local data = self._underdog_skill_data

	if not self._attackers or not data.has_dmg_dampener and not data.has_dmg_mul or t < self._underdog_skill_data.chk_t then
		return
	end

	local my_pos = self._m_pos
	local nr_guys = 0
	local activated = nil

	for u_key, attacker_unit in pairs(self._attackers) do
		if not alive(attacker_unit) then
			self._attackers[u_key] = nil

			return
		end

		local attacker_pos = attacker_unit:movement():m_pos()
		local dis_sq = mvector3.distance_sq(attacker_pos, my_pos)

		if dis_sq < data.max_dis_sq and math.abs(attacker_pos.z - my_pos.z) < 250 then
			nr_guys = nr_guys + 1

			if data.nr_enemies <= nr_guys then
				activated = true

				if data.has_dmg_mul then
					managers.player:activate_temporary_upgrade("temporary", "dmg_multiplier_outnumbered")
				end

				if data.has_dmg_dampener then
					managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_outnumbered")
					managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_outnumbered_strong")
				end

				break
			end
		end
	end

	if nr_guys >= 1 then
		managers.player:activate_temporary_upgrade("temporary", "dmg_dampener_close_contact")
	end

	data.chk_t = t + (activated and data.chk_interval_active or data.chk_interval_inactive)
end

-- Lines 893-903
function PlayerMovement:on_targetted_for_attack(state, attacker_unit)
	if state then
		self._attackers = self._attackers or {}
		self._attackers[attacker_unit:key()] = attacker_unit
	elseif self._attackers then
		self._attackers[attacker_unit:key()] = nil

		if not next(self._attackers) then
			self._attackers = nil
		end
	end
end

-- Lines 907-909
function PlayerMovement:set_carry_restriction(state)
	self._carry_restricted = state
end

-- Lines 913-915
function PlayerMovement:has_carry_restriction()
	return self._carry_restricted
end

-- Lines 919-927
function PlayerMovement:object_interaction_blocked()
	if not self._current_state then
		Application:error("[PlayerMovement:object_interaction_blocked()] Somehow you have no current state!")

		return true
	end

	return self._current_state:interaction_blocked()
end

-- Lines 929-931
function PlayerMovement:interupt_interact()
	self._current_state:interupt_interact()
end

-- Lines 935-947
function PlayerMovement:on_morale_boost(benefactor_unit)
	if self._morale_boost then
		managers.enemy:reschedule_delayed_clbk(self._morale_boost.expire_clbk_id, TimerManager:game():time() + tweak_data.upgrades.morale_boost_time)
	else
		self._morale_boost = {
			expire_clbk_id = "PlayerMovement_morale_boost" .. tostring(self._unit:key()),
			move_speed_bonus = tweak_data.upgrades.morale_boost_speed_bonus,
			suppression_resistance = tweak_data.upgrades.morale_boost_suppression_resistance,
			reload_speed_bonus = tweak_data.upgrades.morale_boost_reload_speed_bonus
		}

		managers.enemy:add_delayed_clbk(self._morale_boost.expire_clbk_id, callback(self, self, "clbk_morale_boost_expire"), TimerManager:game():time() + tweak_data.upgrades.morale_boost_time)
	end
end

-- Lines 951-953
function PlayerMovement:morale_boost()
	return self._morale_boost
end

-- Lines 957-959
function PlayerMovement:clbk_morale_boost_expire()
	self._morale_boost = nil
end

-- Lines 963-967
function PlayerMovement:push(vel)
	if self._current_state.push then
		self._current_state:push(vel)
	end
end

-- Lines 971-983
function PlayerMovement:set_team(team_data)
	self._team = team_data

	self._attention_handler:set_team(team_data)

	if Network:is_server() and self._unit:id() ~= -1 then
		local team_index = tweak_data.levels:get_team_index(team_data.id)

		if team_index <= 16 then
			self._unit:network():send("sync_unit_event_id_16", "movement", team_index)
		else
			debug_pause_unit(self._unit, "[PlayerMovement:set_team] team limit reached!", team_data.id)
		end
	end
end

-- Lines 987-989
function PlayerMovement:team()
	return self._team
end

-- Lines 993-997
function PlayerMovement:sync_net_event(event_id, peer)
	local team_id = tweak_data.levels:get_team_names_indexed()[event_id]
	local team_data = managers.groupai:state():team_data(team_id)

	self:set_team(team_data)
end

-- Lines 1001-1013
function PlayerMovement:set_friendly_fire(state)
	if state then
		if self._friendly_fire then
			self._friendly_fire = self._friendly_fire + 1
		else
			self._friendly_fire = 1
		end
	elseif self._friendly_fire == 1 then
		self._friendly_fire = nil
	else
		self._friendly_fire = self._friendly_fire - 1
	end
end

-- Lines 1017-1019
function PlayerMovement:friendly_fire(unit)
	return self._friendly_fire and true or false
end

-- Lines 1023-1057
function PlayerMovement:save(data)
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	data.movement = {
		state_name = self._current_state_name,
		look_fwd = self._m_head_rot:y(),
		peer_id = peer_id,
		character_name = managers.criminals:character_name_by_unit(self._unit),
		attentions = {},
		outfit = managers.network:session():peer(peer_id):profile("outfit_string"),
		outfit_version = managers.network:session():peer(peer_id):outfit_version()
	}

	if self._state_data.in_steelsight then
		data.movement.stance = 3
	else
		data.movement.stance = 2
	end

	data.movement.pose = self._state_data.ducking and 2 or 1

	if Network:is_client() then
		for _, settings in ipairs(self._attention_handler:attention_data()) do
			local index = tweak_data.player:get_attention_index("player", settings.id)

			table.insert(data.movement.attentions, index)
		end
	end

	data.zip_line_unit_id = self:zipline_unit() and self:zipline_unit():editor_id()
	data.down_time = self._unit:character_damage():down_time()

	self._current_state:save(data.movement)

	data.movement.team_id = self._team.id
	data.movement.foxhole_unit = self._foxhole_unit
end

-- Lines 1061-1078
function PlayerMovement:pre_destroy(unit)
	self._attention_handler:set_attention(nil)

	if self._current_state then
		self._current_state:pre_destroy(unit)
	end

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil
	end
end

-- Lines 1082-1094
function PlayerMovement:destroy(unit)
	if self._link_data then
		self._link_data.parent:base():remove_destroy_listener("PlayerMovement" .. tostring(self._unit:key()))
	end

	if self._current_state then
		self._current_state:destroy(unit)
	end

	managers.hud:set_suspicion(false)
	SoundDevice:set_rtpc("suspicion", 0)
	SoundDevice:set_rtpc("stamina", 100)
end

-- Lines 1098-1106
function PlayerMovement:set_player_class(class)
	self._player_class = class
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)

	self:_change_stamina(self:_max_stamina())

	if self._current_state then
		self._current_state:set_class_tweak_data(class)
	end
end

-- Lines 1112-1129
function PlayerMovement:_change_stamina(value)
	local max_stamina = self:_max_stamina()
	local stamina_maxed = self._stamina == max_stamina
	self._stamina = math.clamp(self._stamina + value, 0, max_stamina)

	managers.hud:set_stamina_value(self._stamina)

	if stamina_maxed and self._stamina < max_stamina then
		self._unit:sound():play("fatigue_breath")
	elseif not stamina_maxed and max_stamina <= self._stamina then
		self._unit:sound():play("fatigue_breath_stop")
	end

	local stamina_threshold = self._exhausted and max_stamina or self:get_stamina_threshold()
	local stamina_to_threshold = max_stamina - stamina_threshold
	local stamina_breath = math.clamp((self._stamina - stamina_threshold) / stamina_to_threshold, 0, 1) * 100

	SoundDevice:set_rtpc("stamina", stamina_breath)
end

-- Lines 1131-1135
function PlayerMovement:_max_stamina()
	local max_stamina = self:get_base_stamina() * managers.player:stamina_multiplier()

	managers.hud:set_max_stamina(max_stamina)

	return max_stamina
end

-- Lines 1137-1139
function PlayerMovement:get_base_stamina()
	return self._class_tweak_data.movement.stamina.BASE_STAMINA
end

-- Lines 1141-1144
function PlayerMovement:get_jump_stamina_drain()
	local multiplier = managers.player:upgrade_value("player", "dac_jump_stamina_drain_reduction", 1)

	return self._class_tweak_data.movement.stamina.JUMP_STAMINA_DRAIN * multiplier
end

-- Lines 1146-1149
function PlayerMovement:get_stamina_threshold()
	local multiplier = managers.player:upgrade_value("player", "fitness_stamina_threshold_decrease", 1)

	return self._class_tweak_data.movement.stamina.MIN_STAMINA_THRESHOLD * multiplier
end

-- Lines 1151-1153
function PlayerMovement:get_stamina()
	return self._stamina
end

-- Lines 1155-1157
function PlayerMovement:subtract_stamina(value)
	self:_change_stamina(-math.abs(value))
end

-- Lines 1159-1163
function PlayerMovement:add_stamina(value)
	local multiplier = managers.player:stamina_regen_multiplier(self._state_data.ducking, self._state_data.in_steelsight)

	self:_change_stamina(math.abs(value) * multiplier)
end

-- Lines 1165-1167
function PlayerMovement:is_above_stamina_threshold()
	return not self._exhausted and self:get_stamina_threshold() < self._stamina
end

-- Lines 1169-1171
function PlayerMovement:is_stamina_drained()
	return self._stamina <= 0
end

-- Lines 1173-1177
function PlayerMovement:set_running(running)
	self._is_running = running

	self:_reset_stamina_regeneration()
end

-- Lines 1179-1185
function PlayerMovement:reset_stamina_regeneration(instant)
	if instant then
		self._regenerate_timer = 0
	else
		self:_reset_stamina_regeneration()
	end
end

-- Lines 1187-1190
function PlayerMovement:_reset_stamina_regeneration()
	local multiplier = managers.player:stamina_regen_delay_multiplier()
	self._regenerate_timer = (self._class_tweak_data.movement.stamina.STAMINA_REGENERATION_DELAY or 5) * multiplier
end

-- Lines 1192-1194
function PlayerMovement:running()
	return self._is_running
end

-- Lines 1196-1198
function PlayerMovement:crouching()
	return self._state_data.ducking
end

-- Lines 1200-1202
function PlayerMovement:in_air()
	return self._state_data.in_air
end

-- Lines 1204-1206
function PlayerMovement:on_ladder()
	return self._state_data.on_ladder
end

-- Lines 1208-1210
function PlayerMovement:in_steelsight()
	return self._state_data.in_steelsight
end

-- Lines 1214-1219
function PlayerMovement:apply_exhaustion(stamina_change)
	self._exhausted = true

	self:subtract_stamina(stamina_change)
	self:_reset_stamina_regeneration()
end

-- Lines 1221-1223
function PlayerMovement:exhausted()
	return self._exhausted
end

-- Lines 1227-1229
function PlayerMovement:on_enter_ladder(ladder_unit)
	self._ladder_unit = ladder_unit
end

-- Lines 1231-1233
function PlayerMovement:on_exit_ladder()
	self._ladder_unit = nil
end

-- Lines 1235-1237
function PlayerMovement:ladder_unit()
	return self._ladder_unit
end

-- Lines 1241-1243
function PlayerMovement:on_enter_zipline(zipline_unit)
	self._zipline_unit = zipline_unit
end

-- Lines 1245-1250
function PlayerMovement:on_exit_zipline()
	if alive(self._zipline_unit) then
		self._zipline_unit:zipline():set_user(nil)
	end

	self._zipline_unit = nil
end

-- Lines 1252-1254
function PlayerMovement:zipline_unit()
	return self._zipline_unit
end

-- Lines 1258-1274
function PlayerMovement:set_foxhole_unit(unit)
	if alive(unit) then
		self._unit:set_position(unit:position())
		self._unit:set_rotation(unit:rotation())
		self._unit:camera():camera_unit():base():set_spin(unit:rotation():yaw())
		self._unit:camera():camera_unit():base():set_pitch(0)
		self._unit:network():send("sync_warp_position", unit:position(), unit:rotation())
	end

	self._foxhole_unit = unit

	managers.network:session():send_to_peers_synched("sync_foxhole_state", self._unit, self._foxhole_unit, alive(unit))

	if Network:is_server() then
		self.check_players_in_foxhole()
	end
end

-- Lines 1276-1278
function PlayerMovement:foxhole_unit()
	return self._foxhole_unit
end

-- Lines 1281-1283
function PlayerMovement:is_in_foxhole()
	return alive(self._foxhole_unit)
end

-- Lines 1285-1300
function PlayerMovement:other_players_in_foxhole()
	local all_in_foxhole = false

	for _, peer in pairs(managers.network:session():peers()) do
		local peer_unit = managers.criminals:character_unit_by_peer_id(peer:id())

		if alive(peer_unit) then
			if not peer_unit:movement():is_in_foxhole() then
				all_in_foxhole = false

				break
			else
				all_in_foxhole = true
			end
		end
	end

	return all_in_foxhole
end

-- Lines 1302-1322
function PlayerMovement.check_players_in_foxhole()
	if not managers.network:session() then
		return
	end

	local all_in_foxhole = true

	for _, peer in pairs(managers.network:session():all_peers()) do
		local peer_unit = managers.criminals:character_unit_by_peer_id(peer:id())

		if alive(peer_unit) and not peer_unit:movement():is_in_foxhole() then
			all_in_foxhole = false

			break
		end
	end

	if all_in_foxhole then
		managers.global_state:fire_event("special_foxhole")
	end
end
