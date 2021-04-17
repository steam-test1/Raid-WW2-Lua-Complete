PlayerFatal = PlayerFatal or class(PlayerStandard)
PlayerFatal._update_movement = PlayerBleedOut._update_movement

-- Lines 5-7
function PlayerFatal:init(unit)
	PlayerFatal.super.init(self, unit)
end

-- Lines 11-52
function PlayerFatal:enter(state_data, enter_data)
	PlayerFatal.super.enter(self, state_data, enter_data)
	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade(managers.player:player_timer():time())
	else
		self:_interupt_action_throw_projectile(managers.player:player_timer():time())
	end

	self:_interupt_action_charging_weapon(managers.player:player_timer():time())
	self:_start_action_dead(managers.player:player_timer():time())
	self:_start_action_unequip_weapon(managers.player:player_timer():time(), {
		selection_wanted = 1
	})
	self._unit:base():set_slot(self._unit, 4)
	self._unit:camera():camera_unit():base():set_target_tilt(80)

	if self._ext_movement:nav_tracker() then
		managers.groupai:state():on_criminal_neutralized(self._unit)
	end

	self._unit:character_damage():on_fatal_state_enter()

	if Network:is_server() and enter_data then
		if enter_data.revive_SO_data then
			self._revive_SO_data = enter_data.revive_SO_data
		end

		self._deathguard_SO_id = enter_data.deathguard_SO_id
	end

	self._reequip_weapon = enter_data and enter_data.equip_weapon

	managers.hud:hide_comm_wheel(true)
	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), true, 1, 1)
end

-- Lines 56-68
function PlayerFatal:_enter(enter_data)
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
			"pl_friend_non_combatant_cbt"
		}
	end

	self._ext_movement:set_attention_settings(preset)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end
end

-- Lines 72-97
function PlayerFatal:exit(state_data, new_state_name)
	PlayerFatal.super.exit(self, state_data, new_state_name)
	self:_end_action_dead(managers.player:player_timer():time())

	if Network:is_server() then
		PlayerBleedOut._unregister_revive_SO(self)
	end

	self._revive_SO_data = nil

	if self._stats_screen then
		self._stats_screen = false

		managers.hud:hide_stats_screen()
	end

	local exit_data = {
		equip_weapon = self._reequip_weapon
	}

	if new_state_name == "standard" then
		exit_data.wants_crouch = true
	end

	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), false, 1, 1)

	return exit_data
end

-- Lines 101-103
function PlayerFatal:interaction_blocked()
	return true
end

-- Lines 107-109
function PlayerFatal:update(t, dt)
	PlayerFatal.super.update(self, t, dt)
end

-- Lines 115-154
function PlayerFatal:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_update_foley(t, input)

	local new_action = nil

	self:_check_stats_screen(t, dt, input)
	self:_check_action_interact(t, input)
end

-- Lines 160-169
function PlayerFatal:_check_action_interact(t, input)
	if input.btn_interact_press and (not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t) then
		self._intimidate_t = t

		if not self:call_teammate(self, "f11", t, true, true, true) then
			PlayerBleedOut.call_civilian(self, "f11", t, false, true, self._revive_SO_data)
		end
	end
end

-- Lines 172-180
function PlayerFatal:_start_action_dead(t)
	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("duck"))
end

-- Lines 184-195
function PlayerFatal:_end_action_dead(t)
	if not self:_can_stand() then
		return
	end

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("stand"))
end

-- Lines 199-203
function PlayerFatal:pre_destroy(unit)
	if Network:is_server() then
		PlayerBleedOut._unregister_revive_SO(self)
	end
end

-- Lines 207-211
function PlayerFatal:destroy()
	if Network:is_server() then
		PlayerBleedOut._unregister_revive_SO(self)
	end
end
