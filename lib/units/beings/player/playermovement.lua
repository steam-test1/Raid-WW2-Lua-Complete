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

PlayerMovement = PlayerMovement or class()
PlayerMovement.OUT_OF_WORLD_Z = -4000

-- Lines 22-83
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
			morale_boost_cooldown_t = tweak_data.upgrades.morale_boost_base_cooldown * managers.player:upgrade_value("player", "morale_boost_cooldown_multiplier", 1)
		}
	end

	self:set_friendly_fire(true)
end

-- Lines 87-114
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
	self:_setup_states()

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

-- Lines 118-120
function PlayerMovement:attention_handler()
	return self._attention_handler
end

-- Lines 124-126
function PlayerMovement:nav_tracker()
	return self._nav_tracker
end

-- Lines 130-132
function PlayerMovement:pos_rsrv_id()
	return self._pos_rsrv_id
end

-- Lines 136-142
function PlayerMovement:warp_to(pos, rot)
	self:set_m_pos(pos)
	mrotation.set_zero(self:m_head_rot())
	mrotation.multiply(self:m_head_rot(), rot)
	self._unit:warp_to(rot, pos)
	self._unit:network():send("sync_warp_position", pos, rot)
end

-- Lines 146-164
function PlayerMovement:_setup_states()
	local unit = self._unit
	self._states = {
		empty = PlayerEmpty:new(unit),
		standard = PlayerStandard:new(unit),
		bleed_out = PlayerBleedOut:new(unit),
		fatal = PlayerFatal:new(unit),
		tased = PlayerTased:new(unit),
		incapacitated = PlayerIncapacitated:new(unit),
		carry = PlayerCarry:new(unit),
		carry_corpse = PlayerCarryCorpse:new(unit),
		bipod = PlayerBipod:new(unit),
		driving = PlayerDriving:new(unit),
		parachuting = PlayerParachuting:new(unit),
		freefall = PlayerFreefall:new(unit),
		turret = PlayerTurret:new(unit),
		foxhole = PlayerFoxhole:new(unit)
	}
end

-- Lines 168-230
function PlayerMovement:set_character_anim_variables()
	local char_name = managers.criminals:character_name_by_unit(self._unit)
	local mesh_names = nil
	local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local unit_suit = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"

	if not lvl_tweak_data then
		mesh_names = {
			british = "",
			russian = "",
			german = "",
			american = ""
		}
	elseif unit_suit == "cat_suit" then
		mesh_names = {
			british = "_chains",
			russian = "",
			german = "",
			american = ""
		}
	elseif managers.player._player_mesh_suffix == "_scrubs" then
		mesh_names = {
			british = "_chains",
			russian = "",
			german = "",
			american = ""
		}
	else
		mesh_names = {
			british = "_chains",
			russian = "_dallas",
			german = "",
			american = "_hoxton"
		}
	end

	local mesh_name = Idstring("g_fps_hand" .. (mesh_names[char_name] or "") .. managers.player._player_mesh_suffix)
	local mesh_obj = self._unit:camera():camera_unit():get_object(mesh_name)

	if mesh_obj then
		if self._plr_mesh_name then
			local old_mesh_obj = self._unit:camera():camera_unit():get_object(self._plr_mesh_name)

			if old_mesh_obj then
				old_mesh_obj:set_visibility(false)
			end
		end

		self._plr_mesh_name = mesh_name

		mesh_obj:set_visibility(true)
	end

	local camera_unit = self._unit:camera():camera_unit()

	if camera_unit:damage() then
		local sequence = managers.blackmarket:character_sequence_by_character_name(char_name)

		if camera_unit:damage():has_sequence(sequence) then
			camera_unit:damage():run_sequence_simple(sequence)
		end
	end
end

-- Lines 234-236
function PlayerMovement:set_driving(mode)
	self._unit:set_driving(mode)
end

-- Lines 239-256
function PlayerMovement:change_state(name)
	local exit_data = nil

	if self._current_state then
		exit_data = self._current_state:exit(self._state_data, name)
	end

	local new_state = self._states[name]
	self._current_state = new_state
	self._current_state_name = name
	self._state_enter_t = managers.player:player_timer():time()

	new_state:enter(self._state_data, exit_data)
	self._unit:network():send("sync_player_movement_state", self._current_state_name, self._unit:character_damage():down_time(), self._unit:id())
end

-- Lines 260-311
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

-- Lines 313-330
function PlayerMovement:update_stamina(t, dt, ignore_running)
	local dt = self._last_stamina_regen_t and t - self._last_stamina_regen_t or dt
	self._last_stamina_regen_t = t

	if not ignore_running and self._is_running then
		self:subtract_stamina(dt * self._class_tweak_data.movement.stamina.BASE_STAMINA_DRAIN_RATE)
	elseif self._regenerate_timer then
		self._regenerate_timer = self._regenerate_timer - dt

		if self._regenerate_timer < 0 then
			self:add_stamina(dt * self._class_tweak_data.movement.stamina.BASE_STAMINA_REGENERATION_RATE)

			if self:_max_stamina() <= self._stamina then
				self._regenerate_timer = nil
			end
		end
	end
end

-- Lines 334-343
function PlayerMovement:set_position(pos)
	self._unit:set_position(pos)

	local now = TimerManager:game():time()

	if not Network:is_server() and now - self._last_sent_remote_pos_t > 0.5 then
		self._unit:network():send_to_host("sync_remote_position", self._m_head_pos, self._m_pos)

		self._last_sent_remote_pos_t = now
	end
end

-- Lines 347-351
function PlayerMovement:set_m_pos(pos)
	mvector3.set(self._m_pos, pos)
	mvector3.set(self._m_stand_pos, pos)
	mvector3.set_z(self._m_stand_pos, pos.z + tweak_data.player.PLAYER_EYE_HEIGHT)
end

-- Lines 355-357
function PlayerMovement:m_pos()
	return self._m_pos
end

-- Lines 361-363
function PlayerMovement:m_stand_pos()
	return self._m_stand_pos
end

-- Lines 367-369
function PlayerMovement:m_com()
	return self._m_com
end

-- Lines 373-375
function PlayerMovement:m_head_pos()
	return self._m_head_pos
end

-- Lines 379-381
function PlayerMovement:m_head_rot()
	return self._m_head_rot
end

-- Lines 385-387
function PlayerMovement:m_detect_pos()
	return self._m_head_pos
end

-- Lines 391-393
function PlayerMovement:m_newest_pos()
	return self._m_pos
end

-- Lines 397-399
function PlayerMovement:get_object(object_name)
	return self._unit:get_object(object_name)
end

-- Lines 408-413
function PlayerMovement:downed()
	return self._current_state_name == "bleed_out" or self._current_state_name == "fatal" or self._current_state_name == "arrested" or self._current_state_name == "incapacitated"
end

-- Lines 418-420
function PlayerMovement:current_state()
	return self._current_state
end

-- Lines 424-426
function PlayerMovement:_calculate_m_pose()
	mvector3.lerp(self._m_com, self._m_pos, self._m_head_pos, 0.5)
end

-- Lines 428-437
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

-- Lines 441-444
function PlayerMovement:play_redirect(redirect_name, at_time)
	local result = self._unit:play_redirect(Idstring(redirect_name), at_time)

	return result ~= Idstring("") and result
end

-- Lines 448-451
function PlayerMovement:play_state(state_name, at_time)
	local result = self._unit:play_state(Idstring(state_name), at_time)

	return result ~= Idstring("") and result
end

-- Lines 455-457
function PlayerMovement:chk_action_forbidden(action_type)
	return self._current_state.chk_action_forbidden and self._current_state:chk_action_forbidden(action_type)
end

-- Lines 461-463
function PlayerMovement:get_melee_damage_result(...)
	return self._current_state.get_melee_damage_result and self._current_state:get_melee_damage_result(...)
end

-- Lines 467-474
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

-- Lines 478-481
function PlayerMovement:parent_clbk_unit_destroyed(parent_unit, key)
	self._link_data = nil

	parent_unit:base():remove_destroy_listener("PlayerMovement" .. tostring(self._unit:key()))
end

-- Lines 485-487
function PlayerMovement:is_physically_linked()
	return self._link_data and self._link_data.physical
end

-- Lines 491-502
function PlayerMovement:on_cuffed()
	if self._unit:character_damage()._god_mode then
		return
	end

	if self._current_state_name == "standard" or self._current_state_name == "bipod" or self._current_state_name == "bleed_out" or self._current_state_name == "carry" or _current_state_name._state == "carry_corpse" or self._current_state_name == "turret" then
		managers.player:set_player_state("arrested")
	else
		debug_pause("[PlayerMovement:on_cuffed] transition failed", self._current_state_name)
	end
end

-- Lines 506-510
function PlayerMovement:on_uncovered(enemy_unit)
	self._state_data.uncovered = true

	managers.player:set_player_state("standard")

	self._state_data.uncovered = nil
end

-- Lines 514-519
function PlayerMovement:on_non_lethal_electrocution()
	self._state_data.non_lethal_electrocution = true

	if alive(self._unit) then
		self._unit:character_damage():on_tased(true)
	end
end

-- Lines 523-528
function PlayerMovement:on_tase_ended()
	if self._current_state_name == "tased" then
		self._unit:character_damage():erase_tase_data()
		self._current_state:on_tase_ended()
	end
end

-- Lines 532-534
function PlayerMovement:tased()
	return self._current_state_name == "tased"
end

-- Lines 538-540
function PlayerMovement:current_state_name()
	return self._current_state_name
end

-- Lines 544-546
function PlayerMovement:state_enter_time()
	return self._state_enter_t
end

-- Lines 550-569
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

-- Lines 573-584
function PlayerMovement:_apply_attention_setting_modifications(setting)
	setting.detection = self._unit:base():detection_settings()

	if managers.player:has_category_upgrade("player", "camouflage_bonus") then
		setting.weight_mul = (setting.weight_mul or 1) * managers.player:upgrade_value("player", "camouflage_bonus", 1)
	end

	if managers.player:has_category_upgrade("player", "camouflage_multiplier") then
		setting.weight_mul = (setting.weight_mul or 1) * managers.player:upgrade_value("player", "camouflage_multiplier", 1)
	end

	if managers.player:has_category_upgrade("player", "uncover_multiplier") then
		setting.weight_mul = (setting.weight_mul or 1) * managers.player:upgrade_value("player", "uncover_multiplier", 1)
	end
end

-- Lines 588-643
function PlayerMovement:set_attention_settings(settings_list)
	if not self._attention_handler then
		return
	end

	local changes = self._attention_handler:chk_settings_diff(settings_list)

	if not changes then
		return
	end

	local all_attentions = nil

	-- Lines 604-616
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

-- Lines 647-652
function PlayerMovement:clbk_attention_notice_sneak(observer_unit, status)
	if alive(observer_unit) then
		self:on_suspicion(observer_unit, status)
	end
end

-- Lines 656-700
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

-- Lines 704-711
function PlayerMovement:_feed_suspicion_to_hud()
	local susp_ratio = self._suspicion_ratio

	if type(susp_ratio) == "number" then
		local offset = self._unit:base():suspicion_settings().hud_offset
		susp_ratio = susp_ratio * (1 - offset) + offset
	end

	managers.hud:set_suspicion(susp_ratio)
end

-- Lines 715-753
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

-- Lines 757-771
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

-- Lines 775-791
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

-- Lines 795-804
function PlayerMovement:inventory_clbk_listener(unit, event)
	if event == "add" then
		local data = self._unit:inventory():get_latest_addition_hud_data()

		managers.hud:add_weapon(data)
	end

	if self._current_state and self._current_state.inventory_clbk_listener then
		self._current_state:inventory_clbk_listener(unit, event)
	end
end

-- Lines 808-818
function PlayerMovement:chk_play_mask_on_slow_mo(state_data)
	if not state_data.uncovered and managers.enemy:chk_any_unit_in_slotmask_visible(managers.slot:get_mask("enemies"), self._unit:camera():position(), self._nav_trakcer) then
		local effect_id_world = "world_MaskOn_Peer" .. tostring(managers.network:session():local_peer():id())

		managers.time_speed:play_effect(effect_id_world, tweak_data.timespeed.mask_on)

		local effect_id_player = "player_MaskOn_Peer" .. tostring(managers.network:session():local_peer():id())

		managers.time_speed:play_effect(effect_id_player, tweak_data.timespeed.mask_on_player)
	end
end

-- Lines 822-824
function PlayerMovement:SO_access()
	return self._SO_access
end

-- Lines 828-830
function PlayerMovement:rally_skill_data()
	return self._rally_skill_data
end

-- Lines 834-874
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

-- Lines 878-888
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

-- Lines 892-894
function PlayerMovement:set_carry_restriction(state)
	self._carry_restricted = state
end

-- Lines 898-900
function PlayerMovement:has_carry_restriction()
	return self._carry_restricted
end

-- Lines 904-907
function PlayerMovement:object_interaction_blocked()
	return self._current_state:interaction_blocked()
end

-- Lines 909-911
function PlayerMovement:interupt_interact()
	self._current_state:interupt_interact()
end

-- Lines 915-927
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

-- Lines 931-933
function PlayerMovement:morale_boost()
	return self._morale_boost
end

-- Lines 937-939
function PlayerMovement:clbk_morale_boost_expire()
	self._morale_boost = nil
end

-- Lines 943-947
function PlayerMovement:push(vel)
	if self._current_state.push then
		self._current_state:push(vel)
	end
end

-- Lines 951-963
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

-- Lines 967-969
function PlayerMovement:team()
	return self._team
end

-- Lines 973-977
function PlayerMovement:sync_net_event(event_id, peer)
	local team_id = tweak_data.levels:get_team_names_indexed()[event_id]
	local team_data = managers.groupai:state():team_data(team_id)

	self:set_team(team_data)
end

-- Lines 981-993
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

-- Lines 997-999
function PlayerMovement:friendly_fire(unit)
	return self._friendly_fire and true or false
end

-- Lines 1003-1037
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

-- Lines 1041-1056
function PlayerMovement:pre_destroy(unit)
	self._attention_handler:set_attention(nil)
	self._current_state:pre_destroy(unit)

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil
	end
end

-- Lines 1060-1068
function PlayerMovement:destroy(unit)
	if self._link_data then
		self._link_data.parent:base():remove_destroy_listener("PlayerMovement" .. tostring(self._unit:key()))
	end

	self._current_state:destroy(unit)
	managers.hud:set_suspicion(false)
	SoundDevice:set_rtpc("suspicion", 0)
	SoundDevice:set_rtpc("stamina", 100)
end

-- Lines 1072-1080
function PlayerMovement:set_player_class(class)
	self._player_class = class
	self._class_tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)

	self:_change_stamina(self:_max_stamina())

	if self._current_state then
		self._current_state:set_class_tweak_data(class)
	end
end

-- Lines 1086-1090
function PlayerMovement:_max_stamina()
	local max_stamina = self:get_base_stamina() * managers.player:stamina_multiplier()

	managers.hud:set_max_stamina(max_stamina)

	return max_stamina
end

-- Lines 1092-1108
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

	local stamina_to_threshold = max_stamina - self._class_tweak_data.movement.stamina.MIN_STAMINA_THRESHOLD
	local stamina_breath = math.clamp((self._stamina - self._class_tweak_data.movement.stamina.MIN_STAMINA_THRESHOLD) / stamina_to_threshold, 0, 1) * 100

	SoundDevice:set_rtpc("stamina", stamina_breath)
end

-- Lines 1110-1112
function PlayerMovement:get_base_stamina()
	return self._class_tweak_data.movement.stamina.BASE_STAMINA
end

-- Lines 1114-1116
function PlayerMovement:get_jump_stamina_drain()
	return self._class_tweak_data.movement.stamina.JUMP_STAMINA_DRAIN
end

-- Lines 1118-1120
function PlayerMovement:get_stamina()
	return self._stamina
end

-- Lines 1122-1124
function PlayerMovement:subtract_stamina(value)
	self:_change_stamina(-math.abs(value * managers.player:upgrade_value("player", "stamina_decay_decrease", 1)))
end

-- Lines 1126-1128
function PlayerMovement:add_stamina(value)
	self:_change_stamina(math.abs(value) * managers.player:upgrade_value("player", "stamina_regeneration_increase", 1))
end

-- Lines 1130-1132
function PlayerMovement:is_above_stamina_threshold()
	return self._class_tweak_data.movement.stamina.MIN_STAMINA_THRESHOLD < self._stamina
end

-- Lines 1134-1136
function PlayerMovement:is_stamina_drained()
	return self._stamina <= 0
end

-- Lines 1138-1141
function PlayerMovement:set_running(running)
	self._is_running = running
	self._regenerate_timer = (self._class_tweak_data.movement.stamina.STAMINA_REGENERATION_DELAY or 5) * managers.player:upgrade_value("player", "stamina_regen_timer_multiplier", 1)
end

-- Lines 1143-1145
function PlayerMovement:running()
	return self._is_running
end

-- Lines 1147-1149
function PlayerMovement:crouching()
	return self._state_data.ducking
end

-- Lines 1151-1153
function PlayerMovement:in_air()
	return self._state_data.in_air
end

-- Lines 1155-1157
function PlayerMovement:on_ladder()
	return self._state_data.on_ladder
end

-- Lines 1161-1163
function PlayerMovement:on_enter_ladder(ladder_unit)
	self._ladder_unit = ladder_unit
end

-- Lines 1165-1167
function PlayerMovement:on_exit_ladder()
	self._ladder_unit = nil
end

-- Lines 1169-1171
function PlayerMovement:ladder_unit()
	return self._ladder_unit
end

-- Lines 1175-1177
function PlayerMovement:on_enter_zipline(zipline_unit)
	self._zipline_unit = zipline_unit
end

-- Lines 1179-1184
function PlayerMovement:on_exit_zipline()
	if alive(self._zipline_unit) then
		self._zipline_unit:zipline():set_user(nil)
	end

	self._zipline_unit = nil
end

-- Lines 1186-1188
function PlayerMovement:zipline_unit()
	return self._zipline_unit
end

-- Lines 1192-1208
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

-- Lines 1210-1212
function PlayerMovement:foxhole_unit()
	return self._foxhole_unit
end

-- Lines 1215-1217
function PlayerMovement:is_in_foxhole()
	return alive(self._foxhole_unit)
end

-- Lines 1219-1234
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

-- Lines 1236-1256
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
