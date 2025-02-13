PlayerBleedOut = PlayerBleedOut or class(PlayerStandard)
PlayerBleedOut.TARGET_TILT = 15
PlayerBleedOut.TILT_BLEND_TIME = 0.38

function PlayerBleedOut:init(unit)
	PlayerBleedOut.super.init(self, unit)
end

function PlayerBleedOut:enter(state_data, enter_data)
	PlayerBleedOut.super.enter(self, state_data, enter_data)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_BLEEDOUT) then
		managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYER_BLEEDOUT, managers.network:session():local_peer():id())
	end

	local t = managers.player:player_timer():time()
	self._revive_SO_data = {
		unit = self._unit
	}

	self:_start_action_bleedout(t)

	self._tilt_blend_t = t + self.TILT_BLEND_TIME
	self._steelsight_allowed = managers.player:has_category_upgrade("player", "revenant_steelsight_when_downed")
	local equipped_selection = self._ext_inventory:equipped_selection()
	local not_allowed_in_bleedout = self._equipped_unit:base():weapon_tweak_data().not_allowed_in_bleedout
	self._old_selection = equipped_selection
	local selection_wanted = equipped_selection

	if (self._ext_inventory:is_selection_blocked(equipped_selection) or not_allowed_in_bleedout) and not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			self:_interupt_action_throw_grenade(t)
		else
			self:_interupt_action_throw_projectile(t)
		end

		selection_wanted = PlayerInventory.SLOT_1
	end

	self:_start_action_unequip_weapon(t, {
		selection_wanted = selection_wanted,
		delay = self.TILT_BLEND_TIME
	})

	local weapon = self._ext_inventory:unit_by_selection(selection_wanted)

	if alive(weapon) and weapon:base().on_reload then
		weapon:base():on_reload()
		managers.hud:set_ammo_amount(selection_wanted, weapon:base():ammo_info())
	end

	local carry_data = managers.player:get_my_carry_data()

	if carry_data then
		for i, carry_item in ipairs(carry_data) do
			local carry_tweak = tweak_data.carry[carry_item.carry_id]

			if carry_tweak.is_corpse then
				managers.player:drop_carry(carry_item.carry_id)
			end
		end
	end

	self._unit:camera():play_shaker("player_bleedout_land")
	managers.groupai:state():on_criminal_disabled(self._unit)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		self._register_revive_SO(self._revive_SO_data, "revive")
	end

	if self._state_data.in_steelsight then
		self:_interupt_action_steelsight(t)
	end

	self:_interupt_action_throw_grenade(t)
	self:_interupt_action_melee(t)
	self:_interupt_action_ladder(t)
	managers.groupai:state():report_criminal_downed(self._unit)
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), true, 1, 1)
end

function PlayerBleedOut:_check_weapon_forbids()
	local block_slot_1 = false
	local block_slot_2 = true
	local block_slot_3 = true
	local block_slot_4 = true

	if block_slot_2 and managers.player:has_category_upgrade("player", "perseverance_primary_weapon_when_downed") then
		block_slot_2 = managers.player:is_carrying_over_full(true)
	end

	if block_slot_3 and managers.player:has_category_upgrade("player", "fragstone_grenades_when_downed") then
		block_slot_3 = false
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) then
		block_slot_1 = true
		block_slot_2 = true
		block_slot_3 = true
		block_slot_4 = false
	end

	if block_slot_1 and block_slot_2 and block_slot_3 then
		block_slot_4 = false
	end

	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_1, block_slot_1)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_2, block_slot_2)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_3, block_slot_3)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_4, block_slot_4)
end

function PlayerBleedOut:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end

	local preset = nil

	if managers.groupai:state():whisper_mode() then
		preset = {
			"pl_mask_on_friend_combatant_whisper_mode",
			"pl_mask_on_friend_non_combatant_whisper_mode",
			"pl_mask_on_foe_combatant_whisper_mode_crouch",
			"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
		}
	else
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_crouch",
			"pl_foe_non_combatant_cbt_crouch"
		}
	end

	self._ext_movement:set_attention_settings(preset)
end

function PlayerBleedOut:exit(state_data, new_state_name)
	PlayerBleedOut.super.exit(self, state_data, new_state_name)

	local t = managers.player:player_timer():time()

	self:_end_action_bleedout(t)
	self:_interupt_action_reload(t)
	self._camera_unit:base():set_target_tilt(0)

	self._tilt_blend_t = nil
	local exit_data = {
		equip_weapon_expire_t = self._equip_weapon_expire_t,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t,
		change_weapon_data = self._change_weapon_data,
		equip_weapon = self._old_selection
	}

	if Network:is_server() then
		if new_state_name == "fatal" then
			exit_data.revive_SO_data = self._revive_SO_data
			self._revive_SO_data = nil
		else
			self:_unregister_revive_SO()
		end
	end

	self._unit:camera():play_shaker("player_bleedout_stand")
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), false, 1, 1)

	return exit_data
end

function PlayerBleedOut:interaction_blocked()
	return true
end

function PlayerBleedOut:update(t, dt)
	PlayerBleedOut.super.update(self, t, dt)

	if self._tilt_blend_t then
		local current_tilt = math.lerp(self.TARGET_TILT, 0, self._tilt_blend_t - t)

		self._camera_unit:base():set_target_tilt(current_tilt)

		if self._tilt_blend_t < t then
			self._tilt_blend_t = nil

			self._camera_unit:base():set_target_tilt(self.TARGET_TILT)
		end
	end
end

function PlayerBleedOut:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self._unit:camera():set_shaker_parameter("headbob", "amplitude", 0)

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		self:_update_throw_grenade_timers(t, dt, input)
	else
		self:_update_throw_projectile_timers(t, input)
	end

	self:_update_reload_timers(t, dt, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_primary_attack(t, input)
	new_action = new_action or self:_check_action_next_weapon(t, input)
	new_action = new_action or self:_check_action_previous_weapon(t, input)
	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or PlayerCarry._check_use_item(self, t, input)

	if not new_action then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			new_action = self:_check_action_throw_grenade(t, input)
		else
			new_action = self:_check_action_throw_projectile(t, input)
		end
	end

	new_action = new_action or self:_check_action_interact(t, input)

	self:_check_action_steelsight(t, input)
	self:_check_stats_screen(t, dt, input)
	self:_check_comm_wheel(t, input)
end

function PlayerBleedOut:_check_action_interact(t, input)
	if input.btn_interact_press and (not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t) then
		self._intimidate_t = t

		self:call_teammate("f11", t, false, true)
	end
end

function PlayerBleedOut:_check_change_weapon(t, input)
	local action_wanted = input.btn_switch_weapon_press

	if action_wanted then
		local equipped_selection = self._ext_inventory:equipped_selection()
		local selection_wanted = equipped_selection == PlayerInventory.SLOT_1 and PlayerInventory.SLOT_2 or PlayerInventory.SLOT_1
		local weapon_wanted = self._ext_inventory:unit_by_selection(selection_wanted)

		if weapon_wanted and not weapon_wanted:base():weapon_tweak_data().not_allowed_in_bleedout then
			return PlayerBleedOut.super._check_change_weapon(self, t, input)
		end
	end

	return false
end

function PlayerBleedOut:_check_action_next_weapon(t, input)
	local action_wanted = input.btn_next_weapon_press

	if action_wanted then
		local equipped_selection = self._ext_inventory:equipped_selection()
		local selection_wanted = self._ext_inventory:next_selection()
		local weapon_wanted = self._ext_inventory:unit_by_selection(selection_wanted)

		if weapon_wanted and not weapon_wanted:base():weapon_tweak_data().not_allowed_in_bleedout then
			return PlayerBleedOut.super._check_action_next_weapon(self, t, input)
		end
	end

	return false
end

function PlayerBleedOut:_check_action_previous_weapon(t, input)
	local action_wanted = input.btn_previous_weapon_press

	if action_wanted then
		local equipped_selection = self._ext_inventory:equipped_selection()
		local selection_wanted = self._ext_inventory:previous_selection()
		local weapon_wanted = self._ext_inventory:unit_by_selection(selection_wanted)

		if weapon_wanted and not weapon_wanted:base():weapon_tweak_data().not_allowed_in_bleedout then
			return PlayerBleedOut.super._check_action_previous_weapon(self, t, input)
		end
	end

	return false
end

function PlayerBleedOut:_check_action_equip(t, input)
	local selection_wanted = input.btn_primary_choice or self._weapon_selection_wanted

	if selection_wanted then
		local weapon_wanted = self._ext_inventory:unit_by_selection(selection_wanted)

		if not weapon_wanted:base():weapon_tweak_data().not_allowed_in_bleedout then
			return PlayerBleedOut.super._check_action_equip(self, t, input)
		end
	end

	return false
end

function PlayerBleedOut:_check_action_steelsight(...)
	if self._steelsight_allowed then
		return PlayerBleedOut.super._check_action_steelsight(self, ...)
	end

	return false
end

function PlayerBleedOut:_start_action_state_standard(t)
	managers.player:set_player_state("standard")
end

function PlayerBleedOut._register_revive_SO(revive_SO_data, variant)
	if revive_SO_data.SO_id or not managers.navigation:is_data_ready() then
		return
	end

	local followup_objective = {
		type = "act",
		scan = true,
		action = {
			body_part = 1,
			variant = "crouch",
			type = "act",
			blocks = {
				action = -1,
				aim = -1,
				heavy_hurt = -1,
				hurt = -1,
				walk = -1
			}
		}
	}
	local objective = {
		called = true,
		scan = true,
		pose = "stand",
		type = "revive",
		haste = "run",
		destroy_clbk_key = false,
		follow_unit = revive_SO_data.unit,
		nav_seg = revive_SO_data.unit:movement():nav_tracker():nav_segment(),
		action_duration = tweak_data.interaction[variant].timer,
		fail_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_failed", revive_SO_data),
		complete_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_completed", revive_SO_data),
		action_start_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_started", revive_SO_data),
		followup_objective = followup_objective,
		action = {
			body_part = 1,
			variant = "revive",
			align_sync = true,
			type = "act",
			blocks = {
				action = -1,
				aim = -1,
				heavy_hurt = -1,
				hurt = -1,
				walk = -1,
				light_hurt = -1
			}
		}
	}
	local so_descriptor = {
		AI_group = "friendlies",
		usage_amount = 1,
		chance_inc = 0,
		base_chance = 1,
		interval = 0,
		objective = objective,
		search_pos = revive_SO_data.unit:position(),
		admin_clbk = callback(PlayerBleedOut, PlayerBleedOut, "on_rescue_SO_administered", revive_SO_data),
		verification_clbk = callback(PlayerBleedOut, PlayerBleedOut, "rescue_SO_verification", revive_SO_data.unit)
	}
	revive_SO_data.variant = variant
	local so_id = "PlayerBleedOut_revive"
	revive_SO_data.SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	if not revive_SO_data.deathguard_SO_id then
		revive_SO_data.deathguard_SO_id = PlayerBleedOut._register_deathguard_SO(revive_SO_data.unit)
	end
end

function PlayerBleedOut:_unregister_revive_SO()
	if not self._revive_SO_data then
		return
	end

	if self._revive_SO_data.deathguard_SO_id then
		PlayerBleedOut._unregister_deathguard_SO(self._revive_SO_data.deathguard_SO_id)

		self._revive_SO_data.deathguard_SO_id = nil
	end

	if self._revive_SO_data.SO_id then
		managers.groupai:state():remove_special_objective(self._revive_SO_data.SO_id)

		self._revive_SO_data.SO_id = nil
	elseif self._revive_SO_data.rescuer then
		local rescuer = self._revive_SO_data.rescuer
		self._revive_SO_data.rescuer = nil

		if alive(rescuer) then
			rescuer:brain():set_objective(nil)
		end
	end

	if self._revive_SO_data.sympathy_civ then
		local sympathy_civ = self._revive_SO_data.sympathy_civ
		self._revive_SO_data.sympathy_civ = nil

		sympathy_civ:brain():set_objective(nil)
	end
end

function PlayerBleedOut._register_deathguard_SO(my_unit)
end

function PlayerBleedOut._unregister_deathguard_SO(so_id)
	managers.groupai:state():remove_special_objective(so_id)
end

function PlayerBleedOut:_start_action_bleedout(t)
	self:interupt_all_actions()

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK)
end

function PlayerBleedOut:_end_action_bleedout(t)
	if not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND)
end

function PlayerBleedOut:_update_movement(t, dt)
	if self._ext_network then
		local cur_pos = self._pos
		local move_dis = mvector3.distance_sq(cur_pos, self._last_sent_pos)

		if move_dis > 22500 or move_dis > 400 and t - self._last_sent_pos_t > 1.5 then
			self._ext_network:send("action_walk_nav_point", cur_pos)
			mvector3.set(self._last_sent_pos, cur_pos)

			self._last_sent_pos_t = t
		end
	end
end

function PlayerBleedOut:on_rescue_SO_administered(revive_SO_data, receiver_unit)
	if revive_SO_data.rescuer then
		debug_pause("[PlayerBleedOut:on_rescue_SO_administered] Already had a rescuer!!!!", receiver_unit, revive_SO_data.rescuer)
	end

	revive_SO_data.rescuer = receiver_unit
	revive_SO_data.SO_id = nil
end

function PlayerBleedOut:on_rescue_SO_failed(revive_SO_data, rescuer)
	if revive_SO_data.rescuer then
		revive_SO_data.rescuer = nil

		PlayerBleedOut._register_revive_SO(revive_SO_data, revive_SO_data.variant)
	end
end

function PlayerBleedOut:on_rescue_SO_completed(revive_SO_data, rescuer)
	revive_SO_data.rescuer = nil
end

function PlayerBleedOut:on_rescue_SO_started(revive_SO_data, rescuer)
	for c_key, criminal in pairs(managers.groupai:state():all_AI_criminals()) do
		if c_key ~= rescuer:key() then
			local obj = criminal.unit:brain():objective()

			if obj and obj.type == "revive" and obj.follow_unit:key() == revive_SO_data.unit:key() then
				criminal.unit:brain():set_objective(nil)
			end
		end
	end
end

function PlayerBleedOut.rescue_SO_verification(ignore_this, my_unit, unit)
	return not unit:movement():cool() and not my_unit:movement():team().foes[unit:movement():team().id]
end

function PlayerBleedOut:on_civ_revive_completed(revive_SO_data, sympathy_civ)
end

function PlayerBleedOut:on_civ_revive_started(revive_SO_data, sympathy_civ)
	if sympathy_civ ~= revive_SO_data.sympathy_civ then
		debug_pause_unit(sympathy_civ, "[PlayerBleedOut:on_civ_revive_started] idiot thinks he is reviving", sympathy_civ)

		return
	end

	revive_SO_data.unit:character_damage():pause_downed_timer()

	if revive_SO_data.SO_id then
		managers.groupai:state():remove_special_objective(revive_SO_data.SO_id)

		revive_SO_data.SO_id = nil
	elseif revive_SO_data.rescuer then
		local rescuer = revive_SO_data.rescuer
		revive_SO_data.rescuer = nil

		if alive(rescuer) then
			rescuer:brain():set_objective(nil)
		end
	end
end

function PlayerBleedOut:on_civ_revive_failed(revive_SO_data, sympathy_civ)
	if revive_SO_data.sympathy_civ then
		if sympathy_civ ~= revive_SO_data.sympathy_civ then
			debug_pause_unit(sympathy_civ, "[PlayerBleedOut:on_civ_revive_failed] idiot thinks he is reviving", sympathy_civ)

			return
		end

		revive_SO_data.unit:character_damage():unpause_downed_timer()

		revive_SO_data.sympathy_civ = nil
	end
end

function PlayerBleedOut:verif_clbk_is_unit_deathguard(enemy_unit)
	local char_tweak = tweak_data.character[enemy_unit:base()._tweak_table]

	return char_tweak.deathguard
end

function PlayerBleedOut:clbk_deathguard_administered(unit)
	unit:movement():set_cool(false)
end

function PlayerBleedOut:pre_destroy(unit)
	if Network:is_server() then
		self:_unregister_revive_SO()
	end
end

function PlayerBleedOut:destroy()
	if Network:is_server() then
		self:_unregister_revive_SO()
	end
end
