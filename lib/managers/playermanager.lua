PlayerManager = PlayerManager or class()
PlayerManager.WEAPON_SLOTS = 2
PlayerManager.EQUIPMENT_OBTAINED_MESSAGE_DURATION = 3
PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN = "PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN"
PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN = "PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN"

function PlayerManager:init()
	self._coroutine_mgr = CoroutineManager:new()
	self._message_system = MessageSystem:new()
	self._temporary_properties = TemporaryPropertyManager:new()
	self._player_name = Idstring("units/multiplayer/mp_fps_mover/mp_fps_mover")
	self._players = {}
	self._nr_players = Global.nr_players or 1
	self._last_id = 1
	self._viewport_configs = {
		{}
	}
	self._viewport_configs[1][1] = {
		dimensions = {
			w = 1,
			h = 1,
			x = 0,
			y = 0
		}
	}
	self._viewport_configs[2] = {
		{
			dimensions = {
				w = 1,
				h = 0.5,
				x = 0,
				y = 0
			}
		},
		{
			dimensions = {
				w = 1,
				h = 0.5,
				x = 0,
				y = 0.5
			}
		}
	}
	self._view_disabled = false

	self:_setup_rules()

	self._local_player_minions = 0
	self._local_player_body_bags = nil
	self._player_states = {
		incapacitated = "ingame_incapacitated",
		carry = "ingame_standard",
		carry_corpse = "ingame_standard",
		freefall = "ingame_freefall",
		parachuting = "ingame_parachuting",
		bleed_out = "ingame_bleed_out",
		foxhole = "ingame_standard",
		driving = "ingame_driving",
		turret = "ingame_standard",
		fatal = "ingame_fatal",
		standard = "ingame_standard",
		bipod = "ingame_standard",
		tased = "ingame_electrified"
	}
	self._DEFAULT_STATE = "standard"
	self._current_state = self._DEFAULT_STATE
	self._sync_states = {
		"standard"
	}
	self._current_sync_state = self._DEFAULT_STATE
	local ids_player = Idstring("player")
	self._player_timer = TimerManager:timer(ids_player) or TimerManager:make_timer(ids_player, TimerManager:pausable())
	self._hostage_close_to_local_t = 0

	self:_setup()
end

function PlayerManager:register_message(message, uid, func)
	self._message_system:register(message, uid, func)
end

function PlayerManager:unregister_message(message, uid)
	self._message_system:unregister(message, uid)
end

function PlayerManager:send_message(message, uid, ...)
	self._message_system:notify(message, uid, ...)
end

function PlayerManager:send_message_now(message, uid, ...)
	self._message_system:notify_now(message, uid, ...)
end

function PlayerManager:add_coroutine(name, func, ...)
	self._coroutine_mgr:add_coroutine(name, func, ...)
end

function PlayerManager:get_temporary_property(name, default)
	return self._temporary_properties:get_property(name, default)
end

function PlayerManager:activate_temporary_property(name, time, value)
	self._temporary_properties:activate_property(name, time, value)
end

function PlayerManager:add_to_temporary_property(name, time, value)
	self._temporary_properties:add_to_property(name, time, value)
end

function PlayerManager:has_active_temporary_property(name)
	return self._temporary_properties:has_active_property(name)
end

function PlayerManager:_setup()
	self._equipment = {
		selections = {},
		specials = {}
	}
	self._listener_holder = EventListenerHolder:new()
	self._player_mesh_suffix = ""
	self._temporary_upgrades = {}

	if not Global.player_manager then
		Global.player_manager = {
			upgrades = {},
			team_upgrades = {},
			weapons = {},
			equipment = {},
			grenades = {},
			kit = {
				weapon_slots = {
					BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID
				},
				equipment_slots = {},
				special_equipment_slots = {}
			},
			viewed_content_updates = {},
			character_profile_name = "",
			is_character_profile_hardcore = false,
			character_profile_nation = "",
			customization_equiped_head_name = "",
			customization_equiped_upper_name = "",
			customization_equiped_lower_name = "",
			game_settings_difficulty = Global.DEFAULT_DIFFICULTY,
			game_settings_permission = Global.DEFAULT_PERMISSION,
			game_settings_drop_in_allowed = true,
			game_settings_team_ai = true,
			game_settings_auto_kick = true
		}
	end

	Global.player_manager.default_kit = {
		weapon_slots = {
			BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID
		},
		equipment_slots = {},
		special_equipment_slots = {
			"cable_tie"
		}
	}
	Global.player_manager.synced_bonuses = {}
	Global.player_manager.synced_equipment_possession = {}
	Global.player_manager.synced_deployables = {}
	Global.player_manager.synced_grenades = {}
	Global.player_manager.synced_cable_ties = {}
	Global.player_manager.synced_ammo_info = {}
	Global.player_manager.synced_carry = {}
	Global.player_manager.synced_team_upgrades = {}
	Global.player_manager.synced_vehicle_data = {}
	Global.player_manager.synced_bipod = {}
	Global.player_manager.synced_turret = {}
	Global.player_manager.synced_drag_body = {}
	self._global = Global.player_manager
end

function PlayerManager:get_customization_equiped_head_name()
	local result = ""

	if Global.player_manager.customization_equiped_head_name and Global.player_manager.customization_equiped_head_name ~= "" then
		result = Global.player_manager.customization_equiped_head_name
	else
		result = self:get_character_profile_nation() .. "_default_head"
	end

	return result
end

function PlayerManager:set_customization_equiped_head_name(head_name)
	local owned_head_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_UPPER, head_name)
	Global.player_manager.customization_equiped_head_name = owned_head_name
end

function PlayerManager:get_customization_equiped_upper_name()
	local result = ""

	if Global.player_manager.customization_equiped_upper_name and Global.player_manager.customization_equiped_upper_name ~= "" then
		result = Global.player_manager.customization_equiped_upper_name
	else
		result = self:get_character_profile_nation() .. "_default_upper"
	end

	return result
end

function PlayerManager:set_customization_equiped_upper_name(upper_name)
	local owned_upper_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_UPPER, upper_name)
	Global.player_manager.customization_equiped_upper_name = owned_upper_name
end

function PlayerManager:get_customization_equiped_lower_name()
	local result = ""

	if Global.player_manager.customization_equiped_lower_name and Global.player_manager.customization_equiped_lower_name ~= "" then
		result = Global.player_manager.customization_equiped_lower_name
	else
		result = self:get_character_profile_nation() .. "_default_lower"
	end

	return result
end

function PlayerManager:set_customization_equiped_lower_name(lower_name)
	local owned_lower_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_LOWER, lower_name)
	Global.player_manager.customization_equiped_lower_name = owned_lower_name
end

function PlayerManager:set_character_class(class)
	if not self:player_unit() then
		return
	end

	self:player_unit():character_damage():set_player_class(class)
	self:player_unit():movement():set_player_class(class)

	self._need_to_send_player_status = true
end

function PlayerManager:get_character_profile_name()
	return Global.player_manager.character_profile_name
end

function PlayerManager:set_character_profile_name(character_profile_name)
	Global.player_manager.character_profile_name = character_profile_name
end

function PlayerManager:get_is_character_profile_hardcore()
	return Global.player_manager.is_character_profile_hardcore
end

function PlayerManager:set_is_character_profile_hardcore(is_character_profile_hardcore)
	Global.player_manager.is_character_profile_hardcore = is_character_profile_hardcore
end

function PlayerManager:get_character_profile_nation()
	return Global.player_manager.character_profile_nation
end

function PlayerManager:set_character_profile_nation(character_profile_nation)
	Global.player_manager.character_profile_nation = character_profile_nation
end

function PlayerManager:_setup_rules()
	self._rules = {
		no_run = 0
	}
end

function PlayerManager:aquire_default_upgrades()
	local default_upgrades = tweak_data.skilltree.default_upgrades or {}

	for _, upgrade in ipairs(default_upgrades) do
		if not managers.upgrades:aquired(upgrade, UpgradesManager.AQUIRE_STRINGS[1]) then
			managers.upgrades:aquire_default(upgrade, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end

	for i = 1, PlayerManager.WEAPON_SLOTS do
		if not managers.player:weapon_in_slot(i) then
			self._global.kit.weapon_slots[i] = managers.player:availible_weapons(i)[1]
		end
	end

	self:_verify_equipment_kit(true)
end

function PlayerManager:update(t, dt)
	self._message_system:update()

	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end

	self._sent_player_status_this_frame = nil
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and (not self._hostage_close_to_local_t or self._hostage_close_to_local_t <= t) then
		local local_player = self:local_player()
		self._is_local_close_to_hostage = alive(local_player) and managers.groupai and managers.groupai:state():is_a_hostage_within(local_player:movement():m_pos(), tweak_data.upgrades.hostage_near_player_radius)
		self._hostage_close_to_local_t = t + tweak_data.upgrades.hostage_near_player_check_t
	end

	self:_update_hostage_skills()
	self._coroutine_mgr:update(t, dt)
end

function PlayerManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function PlayerManager:remove_listener(key)
	self._listener_holder:remove(key)
end

function PlayerManager:preload()
end

function PlayerManager:need_send_player_status()
	local player = self:player_unit()
	local all_peers_spawned_world = managers.worldcollection:check_all_peers_synced_last_world(CoreWorldCollection.STAGE_LOAD)

	if not player or not all_peers_spawned_world or not managers.network:session():chk_all_peers_spawned() then
		self._need_to_send_player_status = true

		return
	elseif self._sent_player_status_this_frame then
		return
	end

	Application:debug("[PlayerManager:need_send_player_status()] Player status sent!")

	self._sent_player_status_this_frame = true

	player:character_damage():send_set_status()
	managers.raid_menu:set_pause_menu_enabled(true)
	managers.player:sync_upgrades()

	local current_player_level = managers.experience:current_level()

	player:send("set_player_level", current_player_level, player:id())

	local nationality = managers.player:get_character_profile_nation()

	player:send("set_player_nationality", nationality, player:id())

	local class = managers.skilltree:get_character_profile_class()

	player:send("set_player_class", class, player:id())

	local active_warcry = managers.warcry:get_active_warcry_name()
	local warcry_meter_percentage = managers.warcry:current_meter_percentage()

	player:send("set_active_warcry", active_warcry, warcry_meter_percentage, player:id())
	player:inventory():_send_equipped_weapon()
end

function PlayerManager:_internal_load()
	local player = self:player_unit()

	if not player then
		return
	end

	managers.weapon_skills:recreate_all_weapons_blueprints(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)

	local secondary = managers.blackmarket:equipped_secondary()

	if secondary then
		local secondary_slot = managers.blackmarket:equipped_weapon_slot("secondaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("secondaries", secondary_slot, secondary)

		player:inventory():add_unit_by_factory_name(secondary.factory_id, true, false, secondary.blueprint, secondary.cosmetics, texture_switches)
	end

	managers.weapon_skills:recreate_all_weapons_blueprints(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)

	local primary = managers.blackmarket:equipped_primary()

	if primary then
		local primary_slot = managers.blackmarket:equipped_weapon_slot("primaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("primaries", primary_slot, primary)

		player:inventory():add_unit_by_factory_name(primary.factory_id, true, false, primary.blueprint, primary.cosmetics, texture_switches)
	end

	player:inventory():set_melee_weapon(managers.blackmarket:equipped_melee_weapon())

	local peer_id = managers.network:session():local_peer():id()
	local grenade, amount = managers.blackmarket:equipped_grenade()

	if self:has_grenade(peer_id) then
		amount = self:get_grenade_amount(peer_id) or amount
	end

	self:_set_grenade({
		grenade = grenade,
		amount = math.min(amount, self:get_max_grenades())
	})
	self:refill_grenades()
	self:_set_body_bags_amount(self._local_player_body_bags or self:total_body_bags())

	if not self._respawn then
		self:_add_level_equipment(player)

		for i, name in ipairs(self._global.default_kit.special_equipment_slots) do
			local ok_name = self._global.equipment[name] and name

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < 2 or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id
					})
				end
			end
		end

		for i, name in ipairs(self._global.kit.equipment_slots) do
			local ok_name = self._global.equipment[name] and name or self._global.default_kit.equipment_slots[i]

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < 2 or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id
					})

					break
				end
			end

			if not upgrade.slot or upgrade.slot ~= 2 then
				break
			end
		end
	end
end

function PlayerManager:_add_level_equipment(player)
	local id = Global.running_simulation and managers.editor:layer("Level Settings"):get_setting("simulation_level_id")
	id = id ~= "none" and id or nil
	id = id or Global.level_data.level_id

	if not id then
		return
	end

	local equipment = tweak_data.levels[id] and tweak_data.levels[id].equipment

	if not equipment then
		return
	end

	for _, eq in ipairs(equipment) do
		self:add_equipment({
			silent = true,
			equipment = eq
		})
	end
end

function PlayerManager:spawn_dropin_penalty(dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)
	local player = self:player_unit()

	print("[PlayerManager:spawn_dropin_penalty]", dead, bleed_out, health, used_deployable, used_cable_ties, used_body_bags)

	if not alive(player) then
		return
	end

	if used_deployable then
		managers.player:clear_equipment()

		local equipped_deployable = Global.player_manager.kit.equipment_slots[1]
		local deployable_data = tweak_data.equipments[equipped_deployable]

		if deployable_data and deployable_data.dropin_penalty_function_name then
			local used_one, redirect = player:equipment()[deployable_data.dropin_penalty_function_name](player:equipment(), self._equipment.selected_index)

			if redirect then
				redirect(player)
			end
		end
	end

	for i = 1, used_cable_ties do
		self:remove_special("cable_tie")
	end

	self:_set_body_bags_amount(math.max(self:total_body_bags() - used_body_bags, 0))

	local min_health = nil

	if dead or bleed_out then
		min_health = 0
	else
		min_health = 0.25
	end

	player:character_damage():set_health(math.max(min_health, health) * player:character_damage():_max_health())

	if dead or bleed_out then
		print("[PlayerManager:spawn_dead] Killing")
		player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
		managers.groupai:state():on_player_criminal_death(managers.network:session():local_peer():id())
		player:base():set_enabled(false)
		game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
		player:character_damage():set_invulnerable(true)
		player:character_damage():set_health(0)
		player:base():_unregister()
		World:delete_unit(player)
	end

	if not managers.groupai:state():enemy_weapons_hot() then
		player:inventory():equip_selection(PlayerInventory.SLOT_4, true)
	end
end

function PlayerManager:nr_players()
	return self._nr_players
end

function PlayerManager:set_nr_players(nr)
	self._nr_players = nr
end

function PlayerManager:player_id(unit)
	local id = self._last_id

	for k, player in ipairs(self._players) do
		if player == unit then
			id = k
		end
	end

	return id
end

function PlayerManager:viewport_config()
	local configs = self._viewport_configs[self._last_id]

	if configs then
		return configs[1]
	end
end

function PlayerManager:setup_viewports()
	local configs = self._viewport_configs[self._last_id]

	if configs then
		for k, player in ipairs(self._players) do
			-- Nothing
		end
	else
		Application:error("Unsupported number of players: " .. tostring(self._last_id))
	end
end

function PlayerManager:player_states()
	local ret = {}

	for k, _ in pairs(self._player_states) do
		table.insert(ret, k)
	end

	return ret
end

function PlayerManager:current_state()
	return self._current_state
end

function PlayerManager:default_player_state()
	return self._DEFAULT_STATE
end

function PlayerManager:current_sync_state()
	return self._current_sync_state
end

function PlayerManager:set_player_state(state, state_data)
	state = state or self._current_state
	local carry_data = self:get_my_carry_data()

	if state == "standard" and carry_data then
		local carry_tweak = tweak_data.carry[carry_data.carry_id]
		state = carry_tweak.is_corpse and "carry_corpse" or "carry"
	end

	if state == self._current_state then
		return
	end

	if self._current_state == "foxhole" then
		local foxhole = self:player_unit() and self:player_unit():movement():foxhole_unit()

		if foxhole and foxhole:foxhole():locked() then
			return
		end
	end

	if self._current_state == "bleed_out" and (state == "parachuting" or state == "freefall") then
		return
	end

	if state ~= "standard" and state ~= "carry" and state ~= "carry_corpse" and state ~= "bipod" and state ~= "turret" and state ~= "freefall" and state ~= "parachuting" then
		local unit = self:player_unit()

		if unit then
			unit:character_damage():disable_berserker()
		end
	end

	if not self._player_states[state] then
		Application:error("State '" .. tostring(state) .. "' does not exist in list of available states.")

		state = self._DEFAULT_STATE
	end

	if table.contains(self._sync_states, state) then
		self._current_sync_state = state
	end

	self._current_state = state

	self:_change_player_state()
end

function PlayerManager:spawn_players(position, rotation, state)
	for var = 1, self._nr_players do
		self._last_id = var
	end

	self:spawned_player(self._last_id, safe_spawn_unit(self:player_unit_name(), position, rotation))

	return self._players[1]
end

function PlayerManager:spawned_player(id, unit)
	self._players[id] = unit

	self:setup_viewports()
	self:_internal_load()
	self:_change_player_state()
end

function PlayerManager:_change_player_state()
	local unit = self:player_unit()

	if not unit then
		return
	end

	self._listener_holder:call(self._current_state, unit)

	if game_state_machine:last_queued_state_name() ~= self._player_states[self._current_state] then
		Application:debug("[PlayerManager:_change_player_state()] Changing state to:", self._player_states[self._current_state])
		game_state_machine:change_state_by_name(self._player_states[self._current_state])
	end

	unit:movement():change_state(self._current_state)
end

function PlayerManager:player_destroyed(id)
	self._players[id] = nil
	self._respawn = true
end

function PlayerManager:players()
	return self._players
end

function PlayerManager:player_unit_name()
	return self._player_name
end

function PlayerManager:player_unit(id)
	local p_id = id or 1

	return self._players[p_id]
end

function PlayerManager:local_player()
	return self:player_unit()
end

function PlayerManager:warp_to(pos, rot, id)
	local player = self._players[id or 1]

	if alive(player) then
		player:movement():warp_to(pos, rot)
		player:camera():set_rotation(rot)
		player:camera():camera_unit():set_rotation(rot)
		player:camera():camera_unit():base():set_rotation(rot)
		player:camera():camera_unit():base():force_rot(rot)
	end
end

function PlayerManager:on_out_of_world()
	local player_unit = managers.player:player_unit()

	if not alive(player_unit) then
		return
	end

	local player_pos = player_unit:position()
	local closest_pos, closest_distance = nil

	for _, data in pairs(managers.groupai:state():all_player_criminals()) do
		if data.unit ~= player_unit then
			local pos = data.unit:position()
			local distance = mvector3.distance(player_pos, pos)

			if not closest_distance or distance < closest_distance then
				closest_distance = distance
				closest_pos = pos
			end
		end
	end

	if closest_pos then
		managers.player:warp_to(closest_pos, player_unit:rotation())

		return
	end

	local pos = player_unit:movement():nav_tracker():field_position()

	managers.player:warp_to(pos, player_unit:rotation())
end

function PlayerManager:aquire_weapon(upgrade, id)
	if self._global.weapons[id] then
		return
	end

	self._global.weapons[id] = upgrade
end

function PlayerManager:unaquire_weapon(upgrade, id)
	self._global.weapons[id] = upgrade
end

function PlayerManager:aquire_melee_weapon(upgrade, id)
end

function PlayerManager:unaquire_melee_weapon(upgrade, id)
end

function PlayerManager:aquire_grenade(upgrade, id)
end

function PlayerManager:unaquire_grenade(upgrade, id)
end

function PlayerManager:_verify_equipment_kit(loading)
	if not managers.player:equipment_in_slot(1) then
		if managers.blackmarket then
			managers.blackmarket:equip_deployable(managers.player:availible_equipment(1)[1], loading)
		else
			self._global.kit.equipment_slots[1] = managers.player:availible_equipment(1)[1]
		end
	end
end

function PlayerManager:aquire_equipment(upgrade, id, loading)
	if self._global.equipment[id] then
		return
	end

	self._global.equipment[id] = upgrade

	if upgrade.aquire then
		managers.upgrades:aquire_default(upgrade.aquire.upgrade, UpgradesManager.AQUIRE_STRINGS[1])
	end

	self:_verify_equipment_kit(loading)
end

function PlayerManager:on_killshot(killed_unit, variant)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if managers.player:has_category_upgrade("player", "kill_change_regenerate_speed") then
		local amount = managers.player:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
		local multiplier = managers.player:upgrade_value("player", "kill_change_regenerate_speed", 0)

		damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
	end

	if self._on_killshot_t and t < self._on_killshot_t then
		return
	end

	local regen_armor_bonus = managers.player:upgrade_value("player", "killshot_regen_armor_bonus", 0)
	local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
	local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

	if dist_sq <= close_combat_sq then
		regen_armor_bonus = regen_armor_bonus + managers.player:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
		local panic_chance = managers.player:upgrade_value("player", "killshot_close_panic_chance", 0)

		if panic_chance > 0 or panic_chance == -1 then
			local slotmask = managers.slot:get_mask("enemies")
			local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

			for e_key, unit in pairs(units) do
				if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
					unit:character_damage():build_suppression(0, panic_chance)
				end
			end
		end
	end

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end

	local regen_health_bonus = 0

	if variant == "melee" then
		regen_health_bonus = regen_health_bonus + managers.player:upgrade_value("player", "melee_kill_life_leech", 0)
	end

	if damage_ext and regen_health_bonus > 0 then
		damage_ext:restore_health(regen_health_bonus)
	end

	self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)
end

function PlayerManager:chk_store_armor_health_kill_counter(killed_unit, variant)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local damage_ext = player_unit:character_damage()

	if damage_ext and damage_ext:can_store_armor_health() and managers.player:has_category_upgrade("player", "armor_health_store_amount") then
		self._armor_health_store_kill_counter = self._armor_health_store_kill_counter or 0
		self._armor_health_store_kill_counter = self._armor_health_store_kill_counter + 1

		if tweak_data.upgrades.armor_health_store_kill_amount <= self._armor_health_store_kill_counter then
			self._armor_health_store_kill_counter = 0

			damage_ext:add_armor_stored_health(managers.player:upgrade_value("player", "armor_health_store_amount", 0))
		end
	end
end

function PlayerManager:on_damage_dealt(unit, damage_info)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local t = Application:time()

	self:_check_damage_to_hot(t, unit, damage_info)

	if self._on_damage_dealt_t and t < self._on_damage_dealt_t then
		return
	end

	self._on_damage_dealt_t = t + (tweak_data.upgrades.on_damage_dealt_cooldown or 0)
end

function PlayerManager:on_headshot_dealt(is_kill)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local t = Application:time()

	if self._on_headshot_dealt_t and t < self._on_headshot_dealt_t then
		return
	end

	self._on_headshot_dealt_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
	local damage_ext = player_unit:character_damage()
	local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end

	if is_kill then
		managers.dialog:queue_dialog("player_gen_critical_hit", {
			skip_idle_check = true,
			instigator = managers.player:local_player()
		})
	end
end

function PlayerManager:_check_damage_to_hot(t, unit, damage_info)
	local player_unit = self:player_unit()

	if not self:has_category_upgrade("player", "damage_to_hot") then
		return
	end

	if not alive(player_unit) or player_unit:character_damage():need_revive() or player_unit:character_damage():dead() then
		return
	end

	if not alive(unit) or not unit:base() or not damage_info then
		return
	end

	if damage_info.is_fire_dot_damage then
		return
	end

	local data = tweak_data.upgrades.damage_to_hot_data

	if not data then
		return
	end

	if self._next_allowed_doh_t and t < self._next_allowed_doh_t then
		return
	end

	local add_stack_sources = data.add_stack_sources or {}

	if not add_stack_sources.swat_van and unit:base().sentry_gun then
		return
	elseif not add_stack_sources.civilian and CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	if not add_stack_sources[damage_info.variant] then
		return
	end

	player_unit:character_damage():add_damage_to_hot()

	self._next_allowed_doh_t = t + data.stacking_cooldown
end

function PlayerManager:unaquire_equipment(upgrade, id)
	if not self._global.equipment[id] then
		return
	end

	local is_equipped = managers.player:equipment_in_slot(upgrade.slot) == id
	self._global.equipment[id] = nil

	if is_equipped then
		self._global.kit.equipment_slots[upgrade.slot] = nil

		self:_verify_equipment_kit(false)
	end

	if upgrade.aquire then
		managers.upgrades:unaquire(upgrade.aquire.upgrade, UpgradesManager.AQUIRE_STRINGS[1])
	end
end

function PlayerManager:aquire_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	self._global.upgrades[upgrade.category][upgrade.upgrade] = math.max(upgrade.value, self._global.upgrades[upgrade.category][upgrade.upgrade] or 0)
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][upgrade.value]

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

function PlayerManager:unaquire_upgrade(upgrade)
	if not self._global.upgrades[upgrade.category] then
		Application:error("[PlayerManager:unaquire_upgrade] Can't unaquire upgrade of category", upgrade.category)

		return
	end

	if not self._global.upgrades[upgrade.category][upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_upgrade] Can't unaquire upgrade", upgrade.upgrade)

		return
	end

	self._global.upgrades[upgrade.category][upgrade.upgrade] = nil
end

function PlayerManager:aquire_incremental_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	local val = self._global.upgrades[upgrade.category][upgrade.upgrade]
	self._global.upgrades[upgrade.category][upgrade.upgrade] = (val or 0) + 1
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]]

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

function PlayerManager:unaquire_incremental_upgrade(upgrade)
	if not self._global.upgrades[upgrade.category] then
		Application:error("[PlayerManager:unaquire_incremental_upgrade] Can't unaquire upgrade of category", upgrade.category)

		return
	end

	if not self._global.upgrades[upgrade.category][upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_incremental_upgrade] Can't unaquire upgrade", upgrade.upgrade)

		return
	end

	local val = self._global.upgrades[upgrade.category][upgrade.upgrade]
	val = val - 1
	self._global.upgrades[upgrade.category][upgrade.upgrade] = val > 0 and val or nil

	if self._global.upgrades[upgrade.category][upgrade.upgrade] then
		local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]]

		if self[upgrade.upgrade] then
			self[upgrade.upgrade](self, value)
		end
	end
end

function PlayerManager:sync_upgrades()
	local player = self:local_player()

	player:send("sync_upgrade", UpgradesTweakData.CLEAR_UPGRADES_FLAG, "", 1, player:id())

	for category, upgrades in pairs(self._global.upgrades) do
		for upgrade, level in pairs(upgrades) do
			player:send("sync_upgrade", category, upgrade, level, player:id())
		end
	end
end

function PlayerManager:upgrade_value(category, upgrade, default)
	if not self._global.upgrades[category] then
		return default or 0
	end

	if not self._global.upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.upgrades[category][upgrade]
	local value = tweak_data.upgrades.values[category][upgrade][level]

	return value
end

function PlayerManager:list_level_rewards(dlcs)
	return managers.upgrades:list_level_rewards(dlcs)
end

function PlayerManager:activate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._temporary_upgrades[category] = self._temporary_upgrades[category] or {}
	self._temporary_upgrades[category][upgrade] = {
		expire_time = Application:time() + time
	}
end

function PlayerManager:activate_temporary_upgrade_by_level(category, upgrade, level)
	local upgrade_level = self:upgrade_level(category, upgrade, 0) or 0

	if level > upgrade_level then
		return
	end

	local upgrade_value = self:upgrade_value_by_level(category, upgrade, level, 0)

	if upgrade_value == 0 then
		return
	end

	local time = upgrade_value[2]
	self._temporary_upgrades[category] = self._temporary_upgrades[category] or {}
	self._temporary_upgrades[category][upgrade] = {
		upgrade_value = upgrade_value[1],
		expire_time = Application:time() + time
	}
end

function PlayerManager:deactivate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return
	end

	if not self._temporary_upgrades[category] then
		return
	end

	self._temporary_upgrades[category][upgrade] = nil
end

function PlayerManager:has_activate_temporary_upgrade(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return false
	end

	if not self._temporary_upgrades[category] then
		return false
	end

	if not self._temporary_upgrades[category][upgrade] then
		return false
	end

	return Application:time() < self._temporary_upgrades[category][upgrade].expire_time
end

function PlayerManager:get_activate_temporary_expire_time(category, upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return 0
	end

	if not self._temporary_upgrades[category] then
		return 0
	end

	if not self._temporary_upgrades[category][upgrade] then
		return 0
	end

	return self._temporary_upgrades[category][upgrade].expire_time or 0
end

function PlayerManager:temporary_upgrade_value(category, upgrade, default)
	local upgrade_value = self:upgrade_value(category, upgrade)

	if upgrade_value == 0 then
		return default or 0
	end

	if not self._temporary_upgrades[category] then
		return default or 0
	end

	if not self._temporary_upgrades[category][upgrade] then
		return default or 0
	end

	if self._temporary_upgrades[category][upgrade].expire_time < Application:time() then
		return default or 0
	end

	if self._temporary_upgrades[category][upgrade].upgrade_value then
		return self._temporary_upgrades[category][upgrade].upgrade_value
	end

	return upgrade_value[1]
end

function PlayerManager:equiptment_upgrade_value(category, upgrade, default)
	if category == "trip_mine" and upgrade == "quantity" then
		return self:upgrade_value(category, "quantity_1", default) + self:upgrade_value(category, "quantity_2", default) + self:upgrade_value(category, "quantity_3", default)
	end

	return self:upgrade_value(category, upgrade, default)
end

function PlayerManager:upgrade_level(category, upgrade, default)
	if not self._global.upgrades[category] then
		return default or 0
	end

	if not self._global.upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.upgrades[category][upgrade]

	return level
end

function PlayerManager:upgrade_value_by_level(category, upgrade, level, default)
	return tweak_data.upgrades.values[category][upgrade][level] or default or 0
end

function PlayerManager:equipped_upgrade_value(equipped, category, upgrade)
	if not self:has_category_upgrade(category, upgrade) then
		return 0
	end

	if not table.contains(self._global.kit.equipment_slots, equipped) then
		return 0
	end

	return self:upgrade_value(category, upgrade)
end

function PlayerManager:has_category_upgrade(category, upgrade)
	if not self._global.upgrades[category] then
		return false
	end

	if not self._global.upgrades[category][upgrade] then
		return false
	end

	return true
end

function PlayerManager:body_armor_value(category, override_value, default)
	local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

	return self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
end

function PlayerManager:get_infamy_exp_multiplier()
	local multiplier = 1

	return multiplier
end

function PlayerManager:update_hostage_skills()
	self._hostage_skills_update = true
end

function PlayerManager:_update_hostage_skills()
	if self._hostage_skills_update then
		if self:get_hostage_bonus_multiplier("health") ~= 1 then
			local player_unit = self:player_unit()

			if alive(player_unit) then
				local damage_ext = player_unit:character_damage()

				if damage_ext then
					damage_ext:change_health(0)
				end
			end
		end

		self._hostage_skills_update = nil
	end
end

function PlayerManager:get_hostage_bonus_multiplier(category)
	local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
	local minions = self:num_local_minions() or 0
	local multiplier = 0
	hostages = hostages + minions
	local hostage_max_num = tweak_data:get_raw_value("upgrades", "hostage_max_num", category)

	if hostage_max_num then
		hostages = math.min(hostages, hostage_max_num)
	end

	multiplier = multiplier + self:team_upgrade_value(category, "hostage_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value(category, "passive_hostage_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "hostage_" .. category .. "_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_hostage_" .. category .. "_multiplier", 1) - 1
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and self._is_local_close_to_hostage then
		multiplier = multiplier * tweak_data.upgrades.hostage_near_player_multiplier
	end

	return 1 + multiplier * hostages
end

function PlayerManager:get_hostage_bonus_addend(category)
	local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
	local minions = self:num_local_minions() or 0
	local addend = 0
	hostages = hostages + minions
	local hostage_max_num = tweak_data:get_raw_value("upgrades", "hostage_max_num", category)

	if hostage_max_num then
		hostages = math.min(hostages, hostage_max_num)
	end

	addend = addend + self:team_upgrade_value(category, "hostage_addend", 0)
	addend = addend + self:team_upgrade_value(category, "passive_hostage_addend", 0)
	addend = addend + self:upgrade_value("player", "hostage_" .. category .. "_addend", 0)
	addend = addend + self:upgrade_value("player", "passive_hostage_" .. category .. "_addend", 0)
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and self._is_local_close_to_hostage then
		addend = addend * tweak_data.upgrades.hostage_near_player_multiplier
	end

	return addend * hostages
end

function PlayerManager:movement_speed_multiplier(is_running, is_climbing, is_crouching, in_steelsight)
	local multiplier = 1

	if is_running then
		multiplier = multiplier + self:upgrade_value("player", "run_speed_increase", 1) - 1
	end

	if is_climbing then
		multiplier = multiplier + self:upgrade_value("player", "climb_speed_increase", 1) - 1
	end

	if is_crouching then
		multiplier = multiplier + self:upgrade_value("player", "crouch_speed_increase", 1) - 1
	end

	if in_steelsight then
		multiplier = multiplier + self:upgrade_value("player", "steelsight_speed_increase", 1) - 1
	end

	multiplier = multiplier + self:upgrade_value("player", "all_movement_speed_increase", 1) - 1
	local warcry_multiplier = self:team_upgrade_value("player", "warcry_movement_speed_multiplier", 0) * self:team_upgrade_value("player", "warcry_team_movement_speed_bonus", 1)

	if warcry_multiplier > 0 then
		warcry_multiplier = warcry_multiplier - 1
	end

	multiplier = multiplier + warcry_multiplier

	return multiplier
end

function PlayerManager:mod_movement_penalty(movement_penalty)
	local skill_mods = self:upgrade_value("player", "passive_armor_movement_penalty_multiplier", 1)

	if skill_mods < 1 and movement_penalty < 1 then
		local penalty = 1 - movement_penalty
		penalty = penalty * skill_mods
		movement_penalty = 1 - penalty
	end

	return movement_penalty
end

function PlayerManager:body_armor_skill_multiplier(override_armor)
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("armor") - 1
	multiplier = multiplier + self:upgrade_value("player", "perk_armor_loss_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1

	return multiplier
end

function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = 1
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_tier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_passive", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "regen_time_multiplier", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "passive_regen_time_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "perk_armor_regen_timer_multiplier", 1)

	if not moving then
		multiplier = multiplier * managers.player:upgrade_value("player", "armor_regen_timer_stand_still_multiplier", 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_regen")
		multiplier = multiplier * (1 - managers.player:upgrade_value("player", "armor_regen_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	return multiplier
end

function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = 0
	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

	return addend
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "warcry_dodge", 0)

	return chance
end

function PlayerManager:stamina_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "stamina_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("player", "warcry_stamina_multiplier", 1) - 1

	return multiplier
end

function PlayerManager:critical_hit_chance()
	local multiplier = 0
	multiplier = multiplier + self:upgrade_value("player", "critical_hit_chance", 1) - 1

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE) then
		multiplier = multiplier * (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE) or 1)
	end

	return multiplier
end

function PlayerManager:get_value_from_risk_upgrade(risk_upgrade, detection_risk)
	local risk_value = 0

	if not detection_risk then
		detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection_risk = math.round(detection_risk * 100)
	end

	if risk_upgrade and type(risk_upgrade) == "table" then
		local value = risk_upgrade[1]
		local step = risk_upgrade[2]
		local operator = risk_upgrade[3]
		local threshold = risk_upgrade[4]
		local cap = risk_upgrade[5]
		local num_steps = 0

		if operator == "above" then
			num_steps = math.max(math.floor((detection_risk - threshold) / step), 0)
		elseif operator == "below" then
			num_steps = math.max(math.floor((threshold - detection_risk) / step), 0)
		end

		risk_value = num_steps * value

		if cap then
			risk_value = math.min(cap, risk_value) or risk_value
		end
	end

	return risk_value
end

function PlayerManager:health_skill_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "max_health_multiplier", 1) - 1

	return multiplier
end

function PlayerManager:health_regen(health_ratio)
	local health_regen = 0

	if self._unit then
		health_regen = self._unit:character_damage():get_base_health_regen()
	else
		local class_tweak_data = tweak_data.player:get_tweak_data_for_class(managers.skilltree:get_character_profile_class() or "recon")
		health_regen = health_regen + class_tweak_data.damage.HEALTH_REGEN

		if health_ratio and health_ratio > 0 and health_ratio < class_tweak_data.damage.LOW_HEALTH_REGEN_LIMIT then
			health_regen = health_regen + class_tweak_data.damage.LOW_HEALTH_REGEN
		end
	end

	health_regen = health_regen + self:team_upgrade_value("player", "warcry_health_regeneration", 0)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN) then
		health_regen = health_regen + managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN)
	end

	return health_regen
end

function PlayerManager:max_health()
	local base_health = self:player_unit():character_damage():get_base_health()
	local health = base_health * self:health_skill_multiplier()

	return health
end

function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state)
	local multiplier = 1

	if damage_type == "melee" then
		multiplier = multiplier * self:upgrade_value("player", "melee_damage_reduction", 1)
	end

	if damage_type == "bullet" then
		multiplier = multiplier * self:upgrade_value("player", "bullet_damage_reduction", 1)
	end

	if self:has_activate_temporary_upgrade("temporary", "on_revived_damage_reduction") then
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "on_revived_damage_reduction", 1)
	end

	if current_state then
		if current_state:_interacting() then
			multiplier = multiplier * self:upgrade_value("player", "interacting_damage_reduction", 1)
		end

		if current_state:running() then
			multiplier = multiplier * self:upgrade_value("player", "running_damage_reduction", 1)
		end

		if current_state:ducking() then
			multiplier = multiplier * self:upgrade_value("player", "crouching_damage_reduction", 1)
		end
	end

	multiplier = multiplier * self:team_upgrade_value("player", "warcry_damage_reduction_multiplier", 1) * self:team_upgrade_value("player", "warcry_team_damage_reduction_bonus", 1)

	return multiplier
end

function PlayerManager:thick_skin_value()
	if not self:has_category_upgrade("player", "thick_skin") then
		return 0
	end

	if not table.contains(self._global.kit.equipment_slots, "thick_skin") then
		return 0
	end

	return self:upgrade_value("player", "thick_skin")
end

function PlayerManager:toolset_value()
	if not self:has_category_upgrade("player", "toolset") then
		return 1
	end

	if not table.contains(self._global.kit.equipment_slots, "toolset") then
		return 1
	end

	return self:upgrade_value("player", "toolset")
end

function PlayerManager:inspect_current_upgrades()
	for name, upgrades in pairs(self._global.upgrades) do
		print("Weapon " .. name .. ":")

		for upgrade, level in pairs(upgrades) do
			print("Upgrade:", upgrade, "is at level", level, "and has value", string.format("%.2f", tweak_data.upgrades.values[name][upgrade][level]))
		end

		print("\n")
	end
end

function PlayerManager:spread_multiplier()
	if not alive(self:player_unit()) then
		return
	end

	self:player_unit():movement()._current_state:_update_crosshair_offset()
end

function PlayerManager:weapon_upgrade_progress(weapon_id)
	local current = 0
	local total = 0

	if self._global.upgrades[weapon_id] then
		for upgrade, value in pairs(self._global.upgrades[weapon_id]) do
			current = current + value
		end
	end

	if tweak_data.upgrades.values[weapon_id] then
		for _, values in pairs(tweak_data.upgrades.values[weapon_id]) do
			total = total + #values
		end
	end

	return current, total
end

function PlayerManager:equipment_upgrade_progress(equipment_id)
	local current = 0
	local total = 0

	if tweak_data.upgrades.values[equipment_id] then
		if self._global.upgrades[equipment_id] then
			for upgrade, value in pairs(self._global.upgrades[equipment_id]) do
				current = current + value
			end
		end

		for _, values in pairs(tweak_data.upgrades.values[equipment_id]) do
			total = total + #values
		end

		return current, total
	end

	if tweak_data.upgrades.values.player[equipment_id] then
		if self._global.upgrades.player and self._global.upgrades.player[equipment_id] then
			current = self._global.upgrades.player[equipment_id]
		end

		total = #tweak_data.upgrades.values.player[equipment_id]

		return current, total
	end

	if tweak_data.upgrades.definitions[equipment_id] and tweak_data.upgrades.definitions[equipment_id].aquire then
		local upgrade = tweak_data.upgrades.definitions[tweak_data.upgrades.definitions[equipment_id].aquire.upgrade]

		return self:equipment_upgrade_progress(upgrade.upgrade.upgrade)
	end

	return current, total
end

function PlayerManager:has_weapon(name)
	return managers.player._global.weapons[name]
end

function PlayerManager:has_aquired_equipment(name)
	return managers.player._global.equipment[name]
end

function PlayerManager:availible_weapons(slot)
	local weapons = {}

	for name, _ in pairs(managers.player._global.weapons) do
		if not slot or slot and tweak_data.weapon[name].use_data.selection_index == slot then
			table.insert(weapons, name)
		end
	end

	return weapons
end

function PlayerManager:weapon_in_slot(slot)
	local weapon = self._global.kit.weapon_slots[slot]

	if self._global.weapons[weapon] then
		return weapon
	end

	local weapon = self._global.default_kit.weapon_slots[slot]

	return self._global.weapons[weapon] and weapon
end

function PlayerManager:availible_equipment(slot)
	local equipment = {}

	for name, _ in pairs(self._global.equipment) do
		if not slot or slot and tweak_data.upgrades.definitions[name].slot == slot then
			table.insert(equipment, name)
		end
	end

	return equipment
end

function PlayerManager:equipment_in_slot(slot)
	return self._global.kit.equipment_slots[slot]
end

function PlayerManager:toggle_player_rule(rule)
	self._rules[rule] = not self._rules[rule]

	if rule == "no_run" and self._rules[rule] then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

function PlayerManager:set_player_rule(rule, value)
	self._rules[rule] = self._rules[rule] + (value and 1 or -1)

	if rule == "no_run" and self:get_player_rule(rule) then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

function PlayerManager:get_player_rule(rule)
	return self._rules[rule] > 0
end

function PlayerManager:has_deployable_been_used()
	return self._peer_used_deployable or false
end

function PlayerManager:update_deployable_equipment_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_deployables[peer_id] then
		local deployable = self._global.synced_deployables[peer_id].deployable
		local amount = self._global.synced_deployables[peer_id].amount

		peer:send_queued_sync("sync_deployable_equipment", deployable, amount)
	end
end

function PlayerManager:update_deployable_equipment_amount_to_peers(equipment, amount)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_deployable_equipment", equipment, amount)
	self:set_synced_deployable_equipment(peer, equipment, amount)
end

function PlayerManager:set_synced_deployable_equipment(peer, deployable, amount)
	local peer_id = peer:id()
	local only_update_amount = self._global.synced_deployables[peer_id] and self._global.synced_deployables[peer_id].deployable == deployable

	if not self._peer_used_deployable and self._global.synced_deployables[peer_id] and (self._global.synced_deployables[peer_id].deployable ~= deployable or self._global.synced_deployables[peer_id].amount ~= amount) then
		self._peer_used_deployable = true
	end

	self._global.synced_deployables[peer_id] = {
		deployable = deployable,
		amount = amount
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local icon = tweak_data.equipments[deployable].icon

		if only_update_amount then
			managers.hud:set_teammate_deployable_equipment_amount(character_data.panel_id, 1, {
				icon = icon,
				amount = amount
			})
		else
			managers.hud:set_deployable_equipment(character_data.panel_id, {
				icon = icon,
				amount = amount
			})
		end
	end

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_deployable_equipment(deployable, amount)
		end
	end
end

function PlayerManager:get_synced_deployable_equipment(peer_id)
	return self._global.synced_deployables[peer_id]
end

function PlayerManager:update_cable_ties_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_cable_ties[peer_id] then
		local amount = self._global.synced_cable_ties[peer_id].amount

		peer:send_queued_sync("sync_cable_ties", amount)
	end
end

function PlayerManager:update_synced_cable_ties_to_peers(amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_cable_ties", amount)
	self:set_synced_cable_ties(peer_id, amount)
end

function PlayerManager:set_synced_cable_ties(peer_id, amount)
	local only_update_amount = false

	if self._global.synced_cable_ties[peer_id] and amount < self._global.synced_cable_ties[peer_id].amount and managers.network:session() and managers.network:session():peer(peer_id) then
		local peer = managers.network:session():peer(peer_id)

		peer:on_used_cable_tie()
	end

	self._global.synced_cable_ties[peer_id] = {
		amount = amount
	}
end

function PlayerManager:get_synced_cable_ties(peer_id)
	return self._global.synced_cable_ties[peer_id]
end

function PlayerManager:update_ammo_info_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_ammo_info[peer_id] then
		for selection_index, ammo_info in pairs(self._global.synced_ammo_info[peer_id]) do
			peer:send_queued_sync("sync_ammo_amount", selection_index, unpack(ammo_info))
		end
	end
end

function PlayerManager:update_synced_ammo_info_to_peers(selection_index, max_clip, current_clip, current_left, max)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_ammo_amount", selection_index, max_clip, current_clip, current_left, max)
	self:set_synced_ammo_info(peer_id, selection_index, max_clip, current_clip, current_left, max)
end

function PlayerManager:set_synced_ammo_info(peer_id, selection_index, max_clip, current_clip, current_left, max)
	self._global.synced_ammo_info[peer_id] = self._global.synced_ammo_info[peer_id] or {}
	self._global.synced_ammo_info[peer_id][selection_index] = {
		max_clip,
		current_clip,
		current_left,
		max
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		-- Nothing
	end
end

function PlayerManager:get_synced_ammo_info(peer_id)
	return self._global.synced_ammo_info[peer_id]
end

function PlayerManager:update_carry_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_carry[peer_id] then
		local carry_id = self._global.synced_carry[peer_id].carry_id
		local multiplier = self._global.synced_carry[peer_id].multiplier
		local dye_initiated = self._global.synced_carry[peer_id].dye_initiated
		local has_dye_pack = self._global.synced_carry[peer_id].has_dye_pack
		local dye_value_multiplier = self._global.synced_carry[peer_id].dye_value_multiplier

		peer:send_queued_sync("sync_carry", carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	end
end

function PlayerManager:update_synced_carry_to_peers(carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_carry", carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	self:set_synced_carry(peer, carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
end

function PlayerManager:set_synced_carry(peer, carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local peer_id = peer:id()
	self._global.synced_carry[peer_id] = {
		carry_id = carry_id,
		multiplier = multiplier,
		dye_initiated = dye_initiated,
		has_dye_pack = has_dye_pack,
		dye_value_multiplier = dye_value_multiplier
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)
	local teammate_panel_id = nil

	if character_data and character_data.panel_id then
		teammate_panel_id = character_data.panel_id
	end

	local unit_data = managers.network:session():peer(peer_id):unit():unit_data()
	local name_label_id = nil

	if unit_data and unit_data.name_label_id then
		name_label_id = unit_data.name_label_id
	end

	managers.hud:set_teammate_carry_info(teammate_panel_id, name_label_id, carry_id)

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_carry(carry_id)
		end
	end
end

function PlayerManager:set_carry_approved(peer)
	self._global.synced_carry[peer:id()].approved = true
end

function PlayerManager:update_removed_synced_carry_to_peers()
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_remove_carry")
	self:remove_synced_carry(peer)
end

function PlayerManager:remove_synced_carry(peer)
	local peer_id = peer:id()

	if not self._global.synced_carry[peer_id] then
		return
	end

	self._global.synced_carry[peer_id] = nil
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)
	local teammate_panel_id = nil

	if character_data and character_data.panel_id then
		teammate_panel_id = character_data.panel_id
	end

	local name_label_id = nil

	if peer:unit() and peer:unit():unit_data() then
		local unit_data = peer:unit():unit_data()

		if unit_data and unit_data.name_label_id then
			name_label_id = unit_data.name_label_id
		end
	end

	managers.hud:remove_teammate_carry_info(teammate_panel_id, name_label_id)

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) then
			unit:movement():set_visual_carry(nil)
		end
	end
end

function PlayerManager:get_my_carry_data()
	local peer_id = managers.network:session():local_peer():id()

	return self._global.synced_carry[peer_id]
end

function PlayerManager:get_synced_carry(peer_id)
	return self._global.synced_carry[peer_id]
end

function PlayerManager:get_drag_body_data()
	local peer_id = managers.network:session():local_peer():id()

	return self._global.synced_drag_body[peer_id]
end

function PlayerManager:get_synced_drag_body(peer_id)
	return self._global.synced_drag_body[peer_id]
end

function PlayerManager:from_server_interaction_reply(status)
	self:player_unit():movement():set_carry_restriction(false)

	if not status then
		self:clear_carry()
	end
end

function PlayerManager:get_all_synced_carry()
	return self._global.synced_carry
end

function PlayerManager:aquire_team_upgrade(upgrade)
	self._global.team_upgrades[upgrade.category] = self._global.team_upgrades[upgrade.category] or {}
	self._global.team_upgrades[upgrade.category][upgrade.upgrade] = upgrade.value

	self:update_team_upgrades_to_peers()
end

function PlayerManager:unaquire_team_upgrade(upgrade_definition)
	if not self._global.team_upgrades[upgrade_definition.upgrade.category] then
		Application:error("[PlayerManager:unaquire_team_upgrade] Can't unaquire team upgrade of category", upgrade_definition.upgrade.category)

		return
	end

	if not self._global.team_upgrades[upgrade_definition.upgrade.category][upgrade_definition.upgrade.upgrade] then
		Application:error("[PlayerManager:unaquire_team_upgrade] Can't unaquire team upgrade", upgrade_definition.upgrade.upgrade)

		return
	end

	local val = nil

	if not upgrade_definition.incremental then
		val = 0
	else
		val = self._global.team_upgrades[upgrade_definition.upgrade.category][upgrade_definition.upgrade.upgrade]
		val = val - 1
	end

	if not val then
		Application:error("[PlayerManager:unaquire_team_upgrade] Can't unaquire team upgrade", upgrade_definition.upgrade)

		return
	end

	self._global.team_upgrades[upgrade_definition.upgrade.category][upgrade_definition.upgrade.upgrade] = val > 0 and val or nil

	self:update_team_upgrades_to_peers()
end

function PlayerManager:team_upgrade_value(category, upgrade, default)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			local level = categories[category][upgrade]

			return tweak_data.upgrades.values.team[category][upgrade][level]
		end
	end

	if not self._global.team_upgrades[category] then
		return default or 0
	end

	if not self._global.team_upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.team_upgrades[category][upgrade]
	local value = tweak_data.upgrades.values.team[category][upgrade][level]

	return value
end

function PlayerManager:has_team_category_upgrade(category, upgrade)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			return true
		end
	end

	if not self._global.team_upgrades[category] then
		return false
	end

	if not self._global.team_upgrades[category][upgrade] then
		return false
	end

	return true
end

function PlayerManager:update_team_upgrades_to_peers()
	if not managers.network or not managers.network:session() then
		return
	end

	managers.network:session():send_to_peers_synched("clear_synced_team_upgrades")

	for category, upgrades in pairs(self._global.team_upgrades) do
		for upgrade, level in pairs(upgrades) do
			managers.network:session():send_to_peers_synched("add_synced_team_upgrade", category, upgrade, level)
		end
	end
end

function PlayerManager:update_team_upgrades_to_peer(peer)
	for category, upgrades in pairs(self._global.team_upgrades) do
		for upgrade, level in pairs(upgrades) do
			peer:send_queued_sync("add_synced_team_upgrade", category, upgrade, level)
		end
	end
end

function PlayerManager:clear_synced_team_upgrades(peer_id)
	self._global.synced_team_upgrades[peer_id] = nil
end

function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, level)
	self._global.synced_team_upgrades[peer_id] = self._global.synced_team_upgrades[peer_id] or {}
	self._global.synced_team_upgrades[peer_id][category] = self._global.synced_team_upgrades[peer_id][category] or {}
	self._global.synced_team_upgrades[peer_id][category][upgrade] = level
end

function PlayerManager:remove_equipment_possession(peer_id, equipment)
	if not self._global.synced_equipment_possession[peer_id] then
		return
	end

	self._global.synced_equipment_possession[peer_id][equipment] = nil
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		managers.hud:remove_teammate_special_equipment(character_data.panel_id, equipment)
	end
end

function PlayerManager:get_synced_equipment_possession(peer_id)
	return self._global.synced_equipment_possession[peer_id]
end

function PlayerManager:update_equipment_possession_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_equipment_possession[peer_id] then
		for name, amount in pairs(self._global.synced_equipment_possession[peer_id]) do
			peer:send_queued_sync("sync_equipment_possession", peer_id, name, amount)
		end
	end
end

function PlayerManager:update_equipment_possession_to_peers(equipment, amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_equipment_possession", peer_id, equipment, amount or 1)
	self:set_synced_equipment_possession(peer_id, equipment, amount)
end

function PlayerManager:set_synced_equipment_possession(peer_id, equipment, amount)
	local only_update_amount = self._global.synced_equipment_possession[peer_id] and self._global.synced_equipment_possession[peer_id][equipment]
	self._global.synced_equipment_possession[peer_id] = self._global.synced_equipment_possession[peer_id] or {}
	self._global.synced_equipment_possession[peer_id][equipment] = amount or 1
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local equipment_data = tweak_data.equipments.specials[equipment]
		local icon = equipment_data.icon

		if only_update_amount then
			managers.hud:set_teammate_special_equipment_amount(character_data.panel_id, equipment, amount)
		else
			managers.hud:add_teammate_special_equipment(character_data.panel_id, {
				id = equipment,
				icon = icon,
				amount = amount
			})
		end
	end
end

function PlayerManager:transfer_special_equipment(peer_id, include_custody)
	if self._global.synced_equipment_possession[peer_id] then
		local local_peer = managers.network:session():local_peer()
		local local_peer_id = local_peer:id()
		local peers = {}
		local peers_loadout = {}
		local peers_custody = {}

		if local_peer_id ~= peer_id then
			if not local_peer:waiting_for_player_ready() then
				table.insert(peers_loadout, local_peer)
			elseif managers.trade:is_peer_in_custody(local_peer:id()) then
				if include_custody then
					table.insert(peers_custody, local_peer)
				end
			else
				table.insert(peers, local_peer)
			end
		end

		for _, peer in pairs(managers.network:session():peers()) do
			if peer:id() ~= peer_id then
				if not peer:waiting_for_player_ready() then
					table.insert(peers_loadout, peer)
				elseif managers.trade:is_peer_in_custody(peer:id()) then
					if include_custody then
						table.insert(peers_custody, peer)
					end
				elseif peer:is_host() then
					table.insert(peers, 1, peer)
				else
					table.insert(peers, peer)
				end
			end
		end

		peers = table.list_add(peers, peers_loadout)
		peers = table.list_add(peers, peers_custody)

		for name, amount in pairs(self._global.synced_equipment_possession[peer_id]) do
			local equipment_data = tweak_data.equipments.specials[name]

			if equipment_data and not equipment_data.avoid_tranfer then
				local equipment_lost = true
				local amount_to_transfer = amount
				local max_amount = equipment_data.transfer_quantity or 1

				for _, p in ipairs(peers) do
					local id = p:id()
					local peer_amount = self._global.synced_equipment_possession[id] and self._global.synced_equipment_possession[id][name] or 0

					if max_amount > peer_amount then
						local transfer_amount = math.min(amount_to_transfer, max_amount - peer_amount)
						amount_to_transfer = amount_to_transfer - transfer_amount

						if Network:is_server() then
							if id == local_peer_id then
								managers.player:add_special({
									transfer = true,
									name = name,
									amount = transfer_amount
								})
							else
								p:send("give_equipment", name, transfer_amount, true)
							end
						end

						if amount_to_transfer == 0 then
							equipment_lost = false

							break
						end
					end
				end

				if peer_id == local_peer_id then
					for i = 1, amount - amount_to_transfer do
						self:remove_special(name)
					end
				end

				if equipment_lost and name == "evidence" then
					managers.mission:call_global_event("equipment_evidence_lost")
				end
			end
		end
	end
end

function PlayerManager:peer_dropped_out(peer)
	local peer_id = peer:id()

	if Network:is_server() then
		self:transfer_special_equipment(peer_id, true)

		if self._global.synced_carry[peer_id] and self._global.synced_carry[peer_id].approved then
			local carry_id = self._global.synced_carry[peer_id].carry_id
			local carry_multiplier = self._global.synced_carry[peer_id].multiplier
			local dye_initiated = self._global.synced_carry[peer_id].dye_initiated
			local has_dye_pack = self._global.synced_carry[peer_id].has_dye_pack
			local dye_value_multiplier = self._global.synced_carry[peer_id].dye_value_multiplier
			local peer_unit = peer:unit()
			local position = Vector3()

			if alive(peer_unit) then
				if peer_unit:movement():zipline_unit() then
					position = peer_unit:movement():zipline_unit():position()
				else
					position = peer_unit:position()
				end
			end

			local dir = Vector3(0, 0, 0)

			self:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, Rotation(), dir, 0, nil, peer)
		end

		self:_turret_drop_out(peer)
	end

	self._global.synced_equipment_possession[peer_id] = nil
	self._global.synced_deployables[peer_id] = nil
	self._global.synced_cable_ties[peer_id] = nil
	self._global.synced_grenades[peer_id] = nil
	self._global.synced_ammo_info[peer_id] = nil
	self._global.synced_carry[peer_id] = nil
	self._global.synced_team_upgrades[peer_id] = nil
	self._global.synced_bipod[peer_id] = nil
	self._global.synced_turret[peer_id] = nil
	self._global.synced_drag_body[peer_id] = nil
	local peer_unit = peer:unit()

	managers.vehicle:remove_player_from_all_vehicles(peer_unit)
end

function PlayerManager:clear_synced_turret()
	self._global.synced_turret = {}
end

function PlayerManager:_turret_drop_out(peer)
	local peer_id = peer:id()
	local husk_data = self._global.synced_turret[peer_id]

	if husk_data and alive(husk_data.turret_unit) then
		local weapon = husk_data.turret_unit:weapon()

		weapon:on_player_exit()
		weapon:set_weapon_user(nil)
		husk_data.turret_unit:interaction():set_active(true, true)
		weapon:enable_automatic_SO(true)
	end
end

function PlayerManager:add_equipment(params)
	if tweak_data.equipments[params.equipment or params.name] then
		self:_add_equipment(params)

		return
	end

	if tweak_data.equipments.specials[params.equipment or params.name] then
		self:add_special(params)

		return
	end

	Application:error("No equipment or special equipment named", params.equipment or params.name)
end

function PlayerManager:_add_equipment(params)
	if self:has_equipment(params.equipment) then
		print("Allready have equipment", params.equipment)

		return
	end

	local equipment = params.equipment
	local tweak_data = tweak_data.equipments[equipment]
	local amount = params.amount or (tweak_data.quantity or 0) + self:equiptment_upgrade_value(equipment, "quantity")
	local icon = params.icon or tweak_data and tweak_data.icon
	local use_function_name = params.use_function_name or tweak_data and tweak_data.use_function_name
	local use_function = use_function_name or nil

	table.insert(self._equipment.selections, {
		equipment = equipment,
		amount = Application:digest_value(0, true),
		use_function = use_function,
		action_timer = tweak_data.action_timer
	})

	self._equipment.selected_index = self._equipment.selected_index or 1

	self:update_deployable_equipment_amount_to_peers(equipment, amount)
	managers.hud:add_item({
		amount = amount,
		icon = icon
	})
	self:add_equipment_amount(equipment, amount)
end

function PlayerManager:add_equipment_amount(equipment, amount)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = Application:digest_value(data.amount, false) + amount
		data.amount = Application:digest_value(new_amount, true)

		managers.hud:set_item_amount(index, new_amount)
	end
end

function PlayerManager:set_equipment_amount(equipment, amount)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = amount
		data.amount = Application:digest_value(new_amount, true)

		managers.hud:set_item_amount(index, new_amount)
	end
end

function PlayerManager:equipment_data_by_name(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return equipments, i
		end
	end

	return nil
end

function PlayerManager:get_equipment_amount(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return Application:digest_value(equipments.amount, false)
		end
	end

	return 0
end

function PlayerManager:has_equipment(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return true
		end
	end

	return false
end

function PlayerManager:has_deployable_left(equipment)
	return self:get_equipment_amount(equipment) > 0
end

function PlayerManager:select_next_item()
	if not self._equipment.selected_index then
		return
	end

	self._equipment.selected_index = self._equipment.selected_index + 1 <= #self._equipment.selections and self._equipment.selected_index + 1 or 1
end

function PlayerManager:select_previous_item()
	if not self._equipment.selected_index then
		return
	end

	self._equipment.selected_index = self._equipment.selected_index - 1 >= 1 and self._equipment.selected_index - 1 or #self._equipment.selections
end

function PlayerManager:clear_equipment()
	for i, equipment in ipairs(self._equipment.selections) do
		equipment.amount = Application:digest_value(0, true)

		managers.hud:set_item_amount(i, 0)
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, 0)
	end
end

function PlayerManager:from_server_equipment_place_result(selected_index, unit)
	if alive(unit) then
		unit:equipment():from_server_sentry_gun_place_result(selected_index ~= 0)
	end

	local equipment = self._equipment.selections[selected_index]

	if not equipment then
		return
	end

	local new_amount = Application:digest_value(equipment.amount, false) - 1
	equipment.amount = Application:digest_value(new_amount, true)
	local equipments_available = self._global.equipment or {}

	if managers.player:has_category_upgrade("player", "carry_sentry_and_trip") and equipments_available.sentry_gun and equipments_available.trip_mine and new_amount == 0 then
		if equipment.equipment == "trip_mine" and not self:has_equipment("sentry_gun") then
			self:add_equipment({
				equipment = "sentry_gun"
			})
			self:select_next_item()

			return
		elseif equipment.equipment == "sentry_gun" and not self:has_equipment("trip_mine") then
			self:add_equipment({
				equipment = "trip_mine"
			})
			self:select_next_item()

			return
		end
	end

	managers.hud:set_item_amount(self._equipment.selected_index, new_amount)
	self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
end

function PlayerManager:can_use_selected_equipment(unit)
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount, false) == 0 then
		return false
	end

	return true
end

function PlayerManager:selected_equipment()
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount, false) == 0 then
		return nil
	end

	return equipment
end

function PlayerManager:selected_equipment_id()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return nil
	end

	return equipment_data.equipment
end

function PlayerManager:selected_equipment_name()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return ""
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].text_id or "")
end

function PlayerManager:selected_equipment_limit_movement()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].limit_movement or false
end

function PlayerManager:selected_equipment_deploying_text()
	local equipment_data = self:selected_equipment()

	if not equipment_data or not tweak_data.equipments[equipment_data.equipment].deploying_text_id then
		return false
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].deploying_text_id)
end

function PlayerManager:selected_equipment_sound_start()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_start or false
end

function PlayerManager:selected_equipment_sound_interupt()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_interupt or false
end

function PlayerManager:selected_equipment_sound_done()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_done or false
end

function PlayerManager:use_selected_equipment(unit)
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount, false) == 0 then
		return
	end

	local used_one = false
	local redirect = nil

	if equipment.use_function then
		used_one, redirect = unit:equipment()[equipment.use_function](unit:equipment(), self._equipment.selected_index)
	else
		used_one = true
	end

	if used_one then
		self:remove_equipment(equipment.equipment)

		if redirect then
			redirect(unit)
		end
	end

	return {
		expire_timer = equipment.action_timer,
		redirect = redirect
	}
end

function PlayerManager:check_selected_equipment_placement_valid(player)
	local equipment_data = managers.player:selected_equipment()

	if not equipment_data then
		return false
	end

	if equipment_data.equipment == "trip_mine" or equipment_data.equipment == "ecm_jammer" then
		return player:equipment():valid_look_at_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
	elseif equipment_data.equipment == "sentry_gun" or equipment_data.equipment == "ammo_bag" or equipment_data.equipment == "doctor_bag" or equipment_data.equipment == "first_aid_kit" or equipment_data.equipment == "bodybags_bag" then
		return player:equipment():valid_shape_placement(equipment_data.equipment, tweak_data.equipments[equipment_data.equipment]) and true or false
	elseif equipment_data.equipment == "armor_kit" then
		return true
	end

	return player:equipment():valid_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
end

function PlayerManager:selected_equipment_deploy_timer()
	local equipment_data = managers.player:selected_equipment()

	if not equipment_data then
		return 0
	end

	local equipment_tweak_data = tweak_data.equipments[equipment_data.equipment]
	local multiplier = 1

	if equipment_tweak_data.upgrade_deploy_time_multiplier then
		multiplier = managers.player:upgrade_value(equipment_tweak_data.upgrade_deploy_time_multiplier.category, equipment_tweak_data.upgrade_deploy_time_multiplier.upgrade, 1)
	end

	return (equipment_tweak_data.deploy_time or 1) * multiplier
end

function PlayerManager:remove_equipment(equipment_id)
	local equipment, index = self:equipment_data_by_name(equipment_id)
	local new_amount = Application:digest_value(equipment.amount, false) - 1
	equipment.amount = Application:digest_value(new_amount, true)
	local equipments_available = self._global.equipment or {}

	if managers.player:has_category_upgrade("player", "carry_sentry_and_trip") and equipments_available.sentry_gun and equipments_available.trip_mine and new_amount == 0 then
		if equipment.equipment == "trip_mine" and not self:has_equipment("sentry_gun") then
			self:add_equipment({
				equipment = "sentry_gun"
			})
			self:select_next_item()

			return
		elseif equipment.equipment == "sentry_gun" and not self:has_equipment("trip_mine") then
			self:add_equipment({
				equipment = "trip_mine"
			})
			self:select_next_item()

			return
		end
	end

	managers.hud:set_item_amount(index, new_amount)
	self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
end

function PlayerManager:verify_equipment(peer_id, equipment_id)
	if peer_id == 0 then
		local id = "asset_" .. tostring(equipment_id)
		self._asset_equipment = self._asset_equipment or {}

		if not tweak_data.equipments.max_amount[id] or self._asset_equipment[id] and tweak_data.equipments.max_amount[id] < self._asset_equipment[id] + 1 then
			local peer = managers.network:session():server_peer()

			peer:mark_cheater(VoteManager.REASON.many_assets)

			return false
		end

		self._asset_equipment[id] = (self._asset_equipment[id] or 0) + 1

		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_deployable(equipment_id)
end

function PlayerManager:verify_grenade(peer_id)
	if not managers.network:session() then
		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_grenade(1)
end

function PlayerManager:register_grenade(peer_id)
	if not managers.network:session() then
		return true
	end

	local peer = managers.network:session():peer(peer_id)

	if not peer then
		return false
	end

	return peer:verify_grenade(-1)
end

function PlayerManager:add_special(params)
	local name = params.equipment or params.name

	if not tweak_data.equipments.specials[name] then
		Application:error("Special equipment " .. name .. " doesn't exist!")

		return
	end

	local unit = self:player_unit()
	local respawn = params.amount and true or false
	local equipment = tweak_data.equipments.specials[name]
	local special_equipment = self._equipment.specials[name]
	local amount = params.amount or equipment.quantity
	local extra = self:_equipped_upgrade_value(equipment) + self:upgrade_value(name, "quantity")

	if name == "cable_tie" then
		extra = self:upgrade_value(name, "quantity_1") + self:upgrade_value(name, "quantity_2")
	end

	if special_equipment then
		if equipment.max_quantity or equipment.quantity or params.transfer and equipment.transfer_quantity then
			local dedigested_amount = special_equipment.amount and Application:digest_value(special_equipment.amount, false) or 1
			local new_amount = self:has_category_upgrade(name, "quantity_unlimited") and -1 or math.min(dedigested_amount + amount, (params.transfer and equipment.transfer_quantity or equipment.max_quantity or equipment.quantity) + extra)
			special_equipment.amount = Application:digest_value(new_amount, true)

			managers.hud:set_special_equipment_amount(name, new_amount)
			self:update_equipment_possession_to_peers(name, new_amount)
		end

		return
	end

	local icon = equipment.icon
	local dialog = equipment.dialog_id

	if not params.silent then
		local text = managers.localization:text(equipment.text_id)
		local interact_data = {
			id = "equipment_obtained",
			text = utf8.to_upper(managers.localization:text("present_obtained_mission_equipment_title", {
				EQUIPMENT = text
			})),
			duration = PlayerManager.EQUIPMENT_OBTAINED_MESSAGE_DURATION
		}

		managers.queued_tasks:queue("special_equipment_obtained_message", self._show_special_equipment_obtained_message, self, interact_data, 0.1, nil, true)

		if dialog then
			managers.dialog:queue_dialog(dialog, {})
		end
	end

	local quantity = nil

	if not params.transfer then
		quantity = self:has_category_upgrade(name, "quantity_unlimited") and -1 or equipment.quantity and (respawn and math.min(params.amount, (equipment.max_quantity or equipment.quantity or 1) + extra) or equipment.quantity and math.min(amount + extra, (equipment.max_quantity or equipment.quantity or 1) + extra))
	else
		quantity = params.amount
	end

	managers.hud:add_special_equipment({
		id = name,
		icon = icon,
		amount = quantity or equipment.transfer_quantity and 1 or nil
	})
	self:update_equipment_possession_to_peers(name, quantity)

	self._equipment.specials[name] = {
		amount = quantity and Application:digest_value(quantity, true) or nil
	}

	if equipment.player_rule then
		self:set_player_rule(equipment.player_rule, true)
	end
end

function PlayerManager:_show_special_equipment_obtained_message(interact_data)
	managers.hud:set_big_prompt(interact_data)
end

function PlayerManager:_equipped_upgrade_value(equipment)
	if not equipment.extra_quantity then
		return 0
	end

	local equipped_upgrade = equipment.extra_quantity.equipped_upgrade
	local category = equipment.extra_quantity.category
	local upgrade = equipment.extra_quantity.upgrade

	return self:equipped_upgrade_value(equipped_upgrade, category, upgrade)
end

function PlayerManager:has_special_equipment(name)
	local equipment = tweak_data.equipments.specials[name]

	return self._equipment.specials[name]
end

function PlayerManager:_can_pickup_special_equipment(special_equipment, name)
	if special_equipment.amount then
		local equipment = tweak_data.equipments.specials[name]
		local extra = self:_equipped_upgrade_value(equipment)

		return Application:digest_value(special_equipment.amount, false) < (equipment.max_quantity or equipment.quantity or 1) + extra, not not equipment.max_quantity
	end

	return false
end

function PlayerManager:can_pickup_equipment(name)
	local special_equipment = self._equipment.specials[name]

	if special_equipment then
		return self:_can_pickup_special_equipment(special_equipment, name)
	else
		local equipment = tweak_data.equipments.specials[name]

		if equipment and equipment.shares_pickup_with then
			for i, special_equipment_name in ipairs(equipment.shares_pickup_with) do
				if special_equipment_name ~= name then
					special_equipment = self._equipment.specials[special_equipment_name]

					if special_equipment and not self:_can_pickup_special_equipment(special_equipment, name) then
						return false
					end
				end
			end
		end
	end

	return true
end

function PlayerManager:remove_all_specials()
	for key, value in pairs(self._equipment.specials) do
		self:remove_special(key, true)
	end
end

function PlayerManager:remove_special(name, all)
	local special_equipment = self._equipment.specials[name]

	if not special_equipment then
		return
	end

	local special_amount = special_equipment.amount and Application:digest_value(special_equipment.amount, false)

	if special_amount and special_amount ~= -1 then
		if all then
			special_amount = 0
		else
			special_amount = math.max(0, special_amount - 1)
		end

		managers.hud:set_special_equipment_amount(name, special_amount)
		self:update_equipment_possession_to_peers(name, special_amount)

		special_equipment.amount = Application:digest_value(special_amount, true)
	end

	if not special_amount or special_amount == 0 then
		managers.hud:remove_special_equipment(name)
		managers.network:session():send_to_peers_loaded("sync_remove_equipment_possession", managers.network:session():local_peer():id(), name)
		self:remove_equipment_possession(managers.network:session():local_peer():id(), name)

		self._equipment.specials[name] = nil
		local equipment = tweak_data.equipments.specials[name]

		if equipment.player_rule then
			self:set_player_rule(equipment.player_rule, false)
		end
	end
end

function PlayerManager:_set_grenade(params)
	local grenade = params.grenade
	local tweak_data = tweak_data.projectiles[grenade]
	local amount = params.amount
	local icon = tweak_data.icon
	local player = self:player_unit()

	self:update_grenades_amount_to_peers(grenade, amount)
	player:inventory():set_grenade(grenade)
	managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {
		amount = amount,
		icon = icon
	})
end

function PlayerManager:add_grenade_amount(amount)
	local peer_id = managers.network:session():local_peer():id()

	if not alive(self:player_unit()) then
		return 0
	end

	local grenade = self:player_unit():inventory().equipped_grenade
	local gained_grenades = amount

	if self._global.synced_grenades[peer_id] then
		local icon = tweak_data.projectiles[grenade].icon
		gained_grenades = Application:digest_value(self._global.synced_grenades[peer_id].amount, false)
		amount = math.clamp(Application:digest_value(self._global.synced_grenades[peer_id].amount, false) + amount, 0, self:get_max_grenades_by_peer_id(peer_id))
		gained_grenades = amount - gained_grenades

		managers.hud:set_teammate_grenades_amount(HUDManager.PLAYER_PANEL, {
			icon = icon,
			amount = amount
		})
	end

	self:update_grenades_amount_to_peers(grenade, amount)

	return gained_grenades
end

function PlayerManager:refill_grenades(amount)
	local fill_amount = amount or self:get_max_grenades()

	self:add_grenade_amount(fill_amount)
end

function PlayerManager:update_grenades_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_grenades[peer_id] then
		local grenade = self._global.synced_grenades[peer_id].grenade
		local amount = self._global.synced_grenades[peer_id].amount

		peer:send_queued_sync("sync_grenades", grenade, Application:digest_value(amount, false))
	end
end

function PlayerManager:update_grenades_amount_to_peers(grenade, amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_grenades", grenade, amount)
	self:set_synced_grenades(peer_id, grenade, amount)
end

function PlayerManager:set_synced_grenades(peer_id, grenade, amount)
	Application:debug("[PlayerManager:set_synced_grenades]", peer_id, grenade, amount)

	local only_update_amount = self._global.synced_grenades[peer_id] and self._global.synced_grenades[peer_id].grenade == grenade
	local digested_amount = Application:digest_value(amount, true)
	self._global.synced_grenades[peer_id] = {
		grenade = grenade,
		amount = digested_amount
	}
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)

	if character_data and character_data.panel_id then
		local icon = tweak_data.projectiles[grenade].icon

		if only_update_amount then
			-- Nothing
		end
	end

	managers.network:session():all_peers()[peer_id]._grenades = 0
end

function PlayerManager:get_grenade_amount(peer_id)
	return Application:digest_value(self._global.synced_grenades[peer_id].amount, false)
end

function PlayerManager:get_grenade_amount_missing(peer_id)
	local gren_has = self:get_grenade_amount(peer_id)
	local gren_max = self:get_max_grenades_by_peer_id(peer_id)

	return gren_max - gren_has
end

function PlayerManager:get_synced_grenades(peer_id)
	return self._global.synced_grenades[peer_id]
end

function PlayerManager:can_throw_grenade()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_grenade_amount(peer_id) > 0
end

function PlayerManager:get_max_grenades_by_peer_id(peer_id)
	local peer = managers.network:session() and managers.network:session():peer(peer_id)

	return peer and self:get_max_grenades(peer:grenade_id()) or 0
end

function PlayerManager:get_max_grenades(grenade_id)
	grenade_id = grenade_id or managers.blackmarket:equipped_grenade()
	local upgrade_amount = self:upgrade_value("player", "grenade_quantity", 0)

	return tweak_data.projectiles[grenade_id] and (tweak_data.projectiles[grenade_id].max_amount or 0) + upgrade_amount
end

function PlayerManager:got_max_grenades()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_max_grenades_by_peer_id(peer_id) <= self:get_grenade_amount(peer_id)
end

function PlayerManager:has_grenade(peer_id)
	peer_id = peer_id or managers.network:session():local_peer():id()
	local synced_grenade = self:get_synced_grenades(peer_id)

	return synced_grenade and synced_grenade.grenade and true or false
end

function PlayerManager:on_throw_grenade()
	self:add_grenade_amount(-1)
end

function PlayerManager:set_drag_body_data(dragged_unit, dragged_body)
end

function PlayerManager:set_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local carry_tweak = tweak_data.carry[carry_id]
	local carry_type = carry_tweak.type

	if carry_tweak.is_corpse then
		self:set_player_state("carry_corpse")
	else
		self:set_player_state("carry")
	end

	local title = managers.localization:text("hud_carrying_announcement_title")
	local type_text = carry_tweak.name_id and managers.localization:text(carry_tweak.name_id)
	local text = managers.localization:text("hud_carrying_announcement", {
		CARRY_TYPE = type_text
	})
	local icon = nil

	if not dye_initiated then
		dye_initiated = true

		if carry_tweak.dye then
			local chance = tweak_data.carry.dye.chance * managers.player:upgrade_value("player", "dye_pack_chance_multiplier", 1)

			if false then
				has_dye_pack = true
				dye_value_multiplier = math.round(tweak_data.carry.dye.value_multiplier * managers.player:upgrade_value("player", "dye_pack_cash_loss_multiplier", 1))
			end
		end
	end

	self:update_synced_carry_to_peers(carry_id, carry_multiplier or 1, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, nil, carry_id)
	managers.hud:show_carry_item(carry_id)

	local player = self:player_unit()

	if not player then
		return
	end

	player:movement():current_state():set_tweak_data(carry_type)
end

function PlayerManager:bank_carry()
	local carry_data = self:get_my_carry_data()

	managers.loot:secure(carry_data.carry_id, carry_data.multiplier)
	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:hide_carry_item()
	self:update_removed_synced_carry_to_peers()
	managers.player:set_player_state("standard")
end

function PlayerManager:drop_carry(zipline_unit)
	Application:debug("[PlayerManager:drop_carry]")

	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local carry_needs_headroom = tweak_data.carry[carry_data.carry_id].needs_headroom_to_drop
	local player = self:player_unit()

	if carry_needs_headroom and not player:movement():current_state():_can_stand() then
		managers.notification:add_notification({
			duration = 2,
			shelf_life = 5,
			id = "cant_throw_body",
			text = managers.localization:text("cant_throw_body")
		})

		return
	end

	self._carry_blocked_cooldown_t = Application:time() + tweak_data.carry.default_bag_delay
	local player = self:player_unit()

	if player then
		local carry_tweak = tweak_data.carry[carry_data.carry_id]

		if carry_tweak and carry_tweak.throw_sound then
			player:sound():play(carry_tweak.throw_sound, nil, false)
		end
	end

	local camera_ext = player:camera()
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local position = mvector3.copy(camera_ext:position())
	local rotation = camera_ext:rotation()

	if carry_needs_headroom then
		position = position - Vector3(0, 0, 75)
		rotation = Rotation(math.mod(camera_ext:rotation():yaw() + 180, 360), 0, 0)
	end

	local throw_distance_multiplier_upgrade_level = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, player:camera():forward(), throw_distance_multiplier_upgrade_level, zipline_unit)
	else
		self:server_drop_carry(carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, player:camera():forward(), throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer())
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:hide_carry_item()
	self:update_removed_synced_carry_to_peers()

	if self._current_state == "carry" or self._current_state == "carry_corpse" then
		managers.player:set_player_state("standard")
	end
end

function PlayerManager:switch_carry_to_ragdoll(unit)
	Application:debug("[PlayerManager:switch_carry_to_ragdoll]")

	if not unit:damage() or not unit:damage():has_sequence("switch_to_ragdoll") then
		return
	end

	unit:set_driving("orientation_object")
	unit:set_animations_enabled(false)
	unit:damage():run_sequence_simple("switch_to_ragdoll")

	self._root_act_tags = {}
	local hips_body = unit:body("rag_Hips")
	local tag = hips_body:activate_tag()

	if tag == Idstring("") then
		tag = Idstring("root_follow")

		hips_body:set_activate_tag(tag)
	end

	self._root_act_tags[tag:key()] = true
	tag = hips_body:deactivate_tag()

	if tag == Idstring("") then
		tag = Idstring("root_follow")

		hips_body:set_deactivate_tag(tag)
	end

	self._root_act_tags[tag:key()] = true
	self._hips_obj = unit:get_object(Idstring("Hips"))
	local hips_pos = self._hips_obj:position()
	self._rag_pos = hips_pos
	self._ragdoll_freeze_clbk_id = "freeze_rag" .. tostring(unit:key())
end

function PlayerManager:server_drop_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
	local unit_name = tweak_data.carry[carry_id].unit or tweak_data.carry.default_lootbag
	local unit = World:spawn_unit(Idstring(unit_name), position, rotation)
	local world = managers.worldcollection:get_world_from_pos(position)

	if world then
		world:register_spawned_unit(unit)
	end

	managers.network:session():send_to_peers_synched("sync_carry_data", unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer and peer:id() or 0)
	self:sync_carry_data(unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer and peer:id() or 0)

	return unit
end

function PlayerManager:sync_carry_data(unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	local throw_distance_multiplier = self:upgrade_value_by_level("carry", "throw_distance_multiplier", throw_distance_multiplier_upgrade_level, 1)
	local carry_type = tweak_data.carry[carry_id].type
	throw_distance_multiplier = throw_distance_multiplier * tweak_data.carry.types[carry_type].throw_distance_multiplier

	unit:carry_data():set_carry_id(carry_id)
	unit:carry_data():set_multiplier(carry_multiplier)
	unit:carry_data():set_value(0)
	unit:carry_data():set_dye_pack_data(dye_initiated, has_dye_pack, dye_value_multiplier)
	unit:carry_data():set_latest_peer_id(peer_id)

	if alive(zipline_unit) then
		zipline_unit:zipline():attach_bag(unit)
	else
		local throw_power = tweak_data.carry[carry_id].throw_power or tweak_data.carry.default_throw_power

		self:switch_carry_to_ragdoll(unit)
		unit:push(100, dir * throw_power * throw_distance_multiplier)
	end

	unit:carry_data():on_thrown()
	unit:interaction():register_collision_callbacks()
end

function PlayerManager:force_drop_carry()
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local player = self:player_unit()

	if not alive(player) then
		print("COULDN'T FORCE DROP! DIDN'T HAVE A UNIT")

		return
	end

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local camera_ext = player:camera()

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), Vector3(0, 0, 0), 0, nil)
	else
		self:server_drop_carry(carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, camera_ext:position(), camera_ext:rotation(), Vector3(0, 0, 0), 0, nil, managers.network:session():local_peer())
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:hide_carry_item()
	self:update_removed_synced_carry_to_peers()
end

function PlayerManager:set_carry_temporary_data(carry_id, data)
	self._temporary_carry_data = self._temporary_carry_data or {}
	self._temporary_carry_data[carry_id] = data
end

function PlayerManager:carry_temporary_data(carry_id)
	if self._temporary_carry_data then
		return self._temporary_carry_data[carry_id]
	end

	return nil
end

function PlayerManager:clear_carry_temporary_data(carry_id)
	if self._temporary_carry_data then
		self._temporary_carry_data[carry_id] = nil
	end
end

function PlayerManager:clear_carry(soft_reset)
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local player = self:player_unit()

	if not soft_reset and not alive(player) then
		print("COULDN'T FORCE DROP! DIDN'T HAVE A UNIT")

		return
	end

	managers.network:session():local_peer()._carry_id = nil

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:hide_carry_item()

	self._total_bags = nil
	self._temporary_carry_data = {}

	self:update_removed_synced_carry_to_peers()

	if self._current_state == "carry" or self._current_state == "carry_corpse" then
		managers.player:set_player_state("standard")
	end
end

function PlayerManager:is_berserker()
	local player_unit = self:player_unit()

	return alive(player_unit) and player_unit:character_damage() and player_unit:character_damage():is_berserker() or false
end

function PlayerManager:get_damage_health_ratio(health_ratio, category)
	local damage_ratio = 1 - health_ratio / math.max(0.01, self:_get_damage_health_ratio_threshold(category))

	return math.max(damage_ratio, 0)
end

function PlayerManager:_get_damage_health_ratio_threshold(category)
	local threshold = tweak_data.upgrades.player_damage_health_ratio_threshold

	if category then
		threshold = threshold * self:upgrade_value("player", category .. "_damage_health_ratio_threshold_multiplier", 1)
	end

	return threshold
end

function PlayerManager:is_damage_health_ratio_active(health_ratio)
	return self:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "melee") > 0 or self:has_category_upgrade("player", "armor_regen_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "armor_regen") > 0 or self:has_category_upgrade("player", "damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "damage") > 0 or self:has_category_upgrade("player", "movement_speed_damage_health_ratio_multiplier") and self:get_damage_health_ratio(health_ratio, "movement_speed") > 0
end

function PlayerManager:get_current_state()
	local player = self:player_unit()

	return player:movement()._current_state
end

function PlayerManager:is_carrying()
	return self:get_my_carry_data() and true or false
end

function PlayerManager:current_carry_id()
	local my_carry_data = self:get_my_carry_data()

	return my_carry_data and my_carry_data.carry_id or nil
end

function PlayerManager:carry_blocked_by_cooldown()
	return self._carry_blocked_cooldown_t and Application:time() < self._carry_blocked_cooldown_t or false
end

function PlayerManager:can_carry(carry_id)
	return true
end

function PlayerManager:check_damage_carry(attack_data)
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local carry_id = carry_data.carry_id
	local type = tweak_data.carry[carry_id].type

	if not tweak_data.carry.types[type].looses_value then
		return
	end

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local value = math.max(carry_data.value - tweak_data.carry.types[type].looses_value_per_hit * attack_data.damage, 0)

	self:update_synced_carry_to_peers(carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, nil, carry_id)
end

function PlayerManager:dye_pack_exploded()
	local carry_data = self:get_my_carry_data()

	if not carry_data then
		return
	end

	local carry_id = carry_data.carry_id
	local type = tweak_data.carry[carry_id].type
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local value = carry_data.value * (1 - dye_value_multiplier / 100)
	value = math.round(value)
	has_dye_pack = false

	self:update_synced_carry_to_peers(carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, nil, carry_id)
end

function PlayerManager:count_up_player_minions()
	self._local_player_minions = math.min(self._local_player_minions + 1, self:upgrade_value("player", "convert_enemies_max_minions", 0))

	self:update_hostage_skills()
end

function PlayerManager:count_down_player_minions()
	self._local_player_minions = math.max(self._local_player_minions - 1, 0)

	self:update_hostage_skills()
end

function PlayerManager:reset_minions()
	self._local_player_minions = 0
end

function PlayerManager:num_local_minions()
	return self._local_player_minions
end

function PlayerManager:chk_minion_limit_reached()
	return self:upgrade_value("player", "convert_enemies_max_minions", 0) <= self._local_player_minions
end

function PlayerManager:on_used_body_bag()
	self:_set_body_bags_amount(self._local_player_body_bags - 1)
end

function PlayerManager:reset_used_body_bag()
	self:_set_body_bags_amount(self:total_body_bags())
end

function PlayerManager:chk_body_bags_depleted()
	return self._local_player_body_bags <= 0
end

function PlayerManager:_set_body_bags_amount(body_bags_amount)
	self._local_player_body_bags = math.clamp(body_bags_amount, 0, self:max_body_bags())
end

function PlayerManager:add_body_bags_amount(body_bags_amount)
	self:_set_body_bags_amount(self._local_player_body_bags + body_bags_amount)
end

function PlayerManager:get_body_bags_amount()
	return self._local_player_body_bags
end

function PlayerManager:has_total_body_bags()
	return self._local_player_body_bags == self:total_body_bags()
end

function PlayerManager:total_body_bags()
	return self:upgrade_value("player", "corpse_dispose_amount", 0)
end

function PlayerManager:has_max_body_bags()
	return self._local_player_body_bags == self:max_body_bags()
end

function PlayerManager:max_body_bags()
	return self:total_body_bags() + self:upgrade_value("player", "extra_corpse_dispose_amount", 0)
end

function PlayerManager:change_player_look(new_look)
	self._player_mesh_suffix = new_look

	for _, unit in pairs(managers.groupai:state():all_char_criminals()) do
		unit.unit:movement():set_character_anim_variables()
	end
end

function PlayerManager:player_timer()
	return self._player_timer
end

function PlayerManager:add_weapon_ammo_gain(name_id, amount)
	if Application:production_build() then
		self._debug_weapon_ammo_gains = self._debug_weapon_ammo_gains or {}
		self._debug_weapon_ammo_gains[name_id] = self._debug_weapon_ammo_gains[name_id] or {
			total = 0,
			index = 0
		}
		self._debug_weapon_ammo_gains[name_id].total = self._debug_weapon_ammo_gains[name_id].total + amount
		self._debug_weapon_ammo_gains[name_id].index = self._debug_weapon_ammo_gains[name_id].index + 1
	end
end

function PlayerManager:report_weapon_ammo_gains()
	if Application:production_build() then
		self._debug_weapon_ammo_gains = self._debug_weapon_ammo_gains or {}

		for name_id, data in pairs(self._debug_weapon_ammo_gains) do
			print("WEAPON: " .. tostring(name_id), "AVERAGE AMMO PICKUP: " .. string.format("%3.2f%%", data.total / data.index * 100))
		end
	end
end

function PlayerManager:save(data)
	local state = {
		kit = self._global.kit,
		viewed_content_updates = self._global.viewed_content_updates,
		character_profile_name = self:get_character_profile_name(),
		is_character_profile_hardcore = self:get_is_character_profile_hardcore(),
		character_profile_nation = self:get_character_profile_nation(),
		customization_equiped_head_name = self:get_customization_equiped_head_name(),
		customization_equiped_upper_name = self:get_customization_equiped_upper_name(),
		customization_equiped_lower_name = self:get_customization_equiped_lower_name(),
		game_settings_difficulty = Global.game_settings.difficulty,
		game_settings_permission = Global.game_settings.permission,
		game_settings_drop_in_allowed = Global.game_settings.drop_in_allowed,
		game_settings_team_ai = Global.game_settings.team_ai,
		game_settings_auto_kick = Global.game_settings.auto_kick
	}
	data.PlayerManager = state
end

function PlayerManager:load(data)
	self:reset()
	self:aquire_default_upgrades()

	local state = data.PlayerManager

	if state then
		self._global.kit = state.kit or self._global.kit
		self._global.viewed_content_updates = state.viewed_content_updates or self._global.viewed_content_updates

		managers.savefile:add_load_done_callback(callback(self, self, "_verify_loaded_data"))
		self:set_character_profile_name(state.character_profile_name)
		self:set_is_character_profile_hardcore(state.is_character_profile_hardcore)
		self:set_character_profile_nation(state.character_profile_nation)
		self:set_customization_equiped_head_name(state.customization_equiped_head_name)
		self:set_customization_equiped_upper_name(state.customization_equiped_upper_name)
		self:set_customization_equiped_lower_name(state.customization_equiped_lower_name)

		self._global.game_settings_difficulty = state.game_settings_difficulty or Global.DEFAULT_DIFFICULTY
		self._global.game_settings_permission = state.game_settings_permission or Global.DEFAULT_PERMISSION
		self._global.game_settings_drop_in_allowed = state.game_settings_drop_in_allowed or true
		self._global.game_settings_team_ai = state.game_settings_team_ai or true
		self._global.game_settings_auto_kick = state.game_settings_auto_kick or true
		Global.game_settings.permission = self._global.game_settings_permission
		Global.game_settings.drop_in_allowed = self._global.game_settings_drop_in_allowed
		Global.game_settings.team_ai = self._global.game_settings_team_ai
		Global.game_settings.auto_kick = self._global.game_settings_auto_kick
	end
end

function PlayerManager:set_content_update_viewed(content_update)
	self._global.viewed_content_updates[content_update] = true
end

function PlayerManager:get_content_update_viewed(content_update)
	return self._global.viewed_content_updates[content_update] or false
end

function PlayerManager:_verify_loaded_data()
	local id = self._global.kit.equipment_slots[1]

	if id and not self._global.equipment[id] then
		print("PlayerManager:_verify_loaded_data()", inspect(self._global.equipment))

		self._global.kit.equipment_slots[1] = nil

		self:_verify_equipment_kit(true)
	end
end

function PlayerManager:sync_save(data)
	local state = {
		current_sync_state = self._current_sync_state,
		player_mesh_suffix = self._player_mesh_suffix,
		husk_bipod_data = self._global.synced_bipod,
		husk_turret_data = self._global.synced_turret,
		local_player_in_camp = self._local_player_in_camp
	}
	data.PlayerManager = state
end

function PlayerManager:sync_load(data)
	local state = data.PlayerManager

	if state then
		self:set_player_state(state.current_sync_state)
		self:change_player_look(state.player_mesh_suffix)
		self:set_husk_bipod_data(state.husk_bipod_data)
		self:set_husk_turret_data(state.husk_turret_data)
		self:set_local_player_in_camp(state.local_player_in_camp)
	end

	self.dropin = true
end

function PlayerManager:on_simulation_started()
	self._respawn = false
end

function PlayerManager:reset()
	if managers.hud then
		managers.hud:clear_player_special_equipments()
	end

	Global.player_manager = nil

	self:_setup()
	self:_setup_rules()
	self:aquire_default_upgrades()
end

function PlayerManager:soft_reset()
	self._listener_holder = EventListenerHolder:new()

	self:reset_used_body_bag()

	self._equipment = {
		selections = {},
		specials = {}
	}
	self._global.synced_grenades = {}

	self:clear_carry(true)
end

function PlayerManager:on_peer_synch_request(peer)
	self:player_unit():network():synch_to_peer(peer)
end

function PlayerManager:update_husk_bipod_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_bipod[peer_id] then
		local bipod_pos = self._global.synced_bipod[peer_id].bipod_pos
		local body_pos = self._global.synced_bipod[peer_id].body_pos

		peer:send_queued_sync("sync_bipod", bipod_pos, body_pos)
	end
end

function PlayerManager:set_husk_bipod_data(data)
	self._global.synced_bipod = data
end

function PlayerManager:set_bipod_data_for_peer(data)
	if not self._global.synced_bipod then
		self._global.synced_bipod = {}
	end

	self._global.synced_bipod[data.peer_id] = {
		bipod_pos = data.bipod_pos,
		body_pos = data.body_pos
	}
end

function PlayerManager:get_bipod_data_for_peer(peer_id)
	return self._global.synced_bipod[peer_id]
end

function PlayerManager:set_synced_bipod(peer, bipod_pos, body_pos)
	local peer_id = peer:id()
	self._global.synced_bipod[peer_id] = {
		bipod_pos = bipod_pos,
		body_pos = body_pos
	}
end

function PlayerManager:update_husk_turret_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_turret[peer_id] then
		local husk_pos = self._global.synced_turret[peer_id].husk_pos
		local turret_rot = self._global.synced_turret[peer_id].turret_rot
		local enter_animation = self._global.synced_turret[peer_id].enter_animation
		local exit_animation = self._global.synced_turret[peer_id].exit_animation
		local turret_unit = self._global.synced_turret[peer_id].turret_unit

		peer:send_queued_sync("sync_ground_turret_husk", husk_pos, turret_rot, enter_animation, exit_animation, turret_unit)
	end
end

function PlayerManager:set_husk_turret_data(data)
	self._global.synced_turret = data
end

function PlayerManager:set_turret_data_for_peer(data)
	if not self._global.synced_turret then
		self._global.synced_turret = {}
	end

	self._global.synced_turret[data.peer_id] = {
		husk_pos = data.husk_pos,
		turret_rot = data.turret_rot,
		enter_animation = data.enter_animation,
		exit_animation = data.exit_animation,
		turret_unit = data.turret_unit
	}
end

function PlayerManager:get_turret_data_for_peer(peer_id)
	return self._global.synced_turret[peer_id]
end

function PlayerManager:set_synced_turret(peer, husk_pos, turret_rot, enter_animation, exit_animation, turret_unit)
	local peer_id = peer:id()
	self._global.synced_turret[peer_id] = {
		husk_pos = husk_pos,
		turret_rot = turret_rot,
		enter_animation = enter_animation,
		exit_animation = exit_animation,
		turret_unit = turret_unit
	}
end

function PlayerManager:enter_vehicle(vehicle, locator)
	local peer_id = managers.network:session():local_peer():id()
	local player = self:local_player()
	local seat = vehicle:vehicle_driving():get_available_seat(locator:position())

	if not seat then
		return
	end

	if Network:is_server() then
		self:server_enter_vehicle(vehicle, peer_id, player, seat.name)
	else
		managers.network:session():send_to_host("sync_enter_vehicle_host", vehicle, seat.name, peer_id, player)
	end

	managers.hud:remove_comm_wheel_option("warcry")
end

function PlayerManager:server_enter_vehicle(vehicle, peer_id, player, seat_name)
	local vehicle_ext = vehicle:vehicle_driving()
	local seat = nil

	if seat_name == nil then
		local pos = player:position()
		seat = vehicle_ext:reserve_seat(player, pos, nil)
	else
		seat = vehicle_ext:reserve_seat(player, nil, seat_name)
	end

	if seat ~= nil then
		managers.network:session():send_to_peers_synched("sync_vehicle_player", "enter", vehicle, peer_id, player, seat.name, nil)
		self:_enter_vehicle(vehicle, peer_id, player, seat.name)
	end
end

function PlayerManager:sync_enter_vehicle(vehicle, peer_id, player, seat_name)
	self:_enter_vehicle(vehicle, peer_id, player, seat_name)
end

function PlayerManager:_enter_vehicle(vehicle, peer_id, player, seat_name)
	self._global.synced_vehicle_data[peer_id] = {
		vehicle_unit = vehicle,
		seat = seat_name
	}
	local vehicle_ext = vehicle:vehicle_driving()

	vehicle_ext:place_player_on_seat(player, seat_name)
	player:kill_mover()
	vehicle:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat_name), player)

	if self:local_player() == player then
		self:set_player_state("driving")
	end

	managers.hud:update_vehicle_label_by_id(vehicle:unit_data().name_label_id, vehicle_ext:_number_in_the_vehicle())
	managers.hud:peer_enter_vehicle(peer_id, vehicle)
	managers.vehicle:on_player_entered_vehicle(vehicle, player)

	local seat_data = vehicle_ext:get_seat_data_by_seat_name(seat_name)

	if self:local_player() == player and vehicle_ext:shooting_stance_mandatory() and managers.player:current_state() == "driving" and seat_data.shooting_pos and seat_data.has_shooting_mode then
		managers.player:get_current_state():enter_shooting_stance()
	end
end

function PlayerManager:get_vehicle()
	if managers.network:session() then
		local peer_id = managers.network:session():local_peer():id()
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

function PlayerManager:get_vehicle_for_peer(peer_id)
	if managers.network:session() then
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

function PlayerManager:exit_vehicle()
	local peer_id = managers.network:session():local_peer():id()
	local vehicle_data = self._global.synced_vehicle_data[peer_id]

	if vehicle_data == nil then
		return
	end

	local player = self:local_player()

	managers.network:session():send_to_peers_synched("sync_vehicle_player", "exit", nil, peer_id, player, nil, nil)

	if managers.warcry:current_meter_percentage() >= 100 then
		managers.warcry:add_warcry_comm_wheel_option(1)
	end

	self:_exit_vehicle(peer_id, player)
end

function PlayerManager:sync_exit_vehicle(peer_id, player)
	self:_exit_vehicle(peer_id, player)
end

function PlayerManager:_exit_vehicle(peer_id, player)
	local vehicle_data = self._global.synced_vehicle_data[peer_id]

	if vehicle_data == nil then
		return
	end

	player:unlink()

	if alive(vehicle_data.vehicle_unit) then
		local vehicle_ext = vehicle_data.vehicle_unit:vehicle_driving()

		vehicle_ext:exit_vehicle(player)
		managers.hud:update_vehicle_label_by_id(vehicle_data.vehicle_unit:unit_data().name_label_id, vehicle_ext:_number_in_the_vehicle())
	else
		Application:info("[PlayerManager:_exit_vehicle] Vehicle unit already destroyed!")
	end

	self._global.synced_vehicle_data[peer_id] = nil

	managers.hud:peer_exit_vehicle(peer_id)
	managers.vehicle:on_player_exited_vehicle(vehicle_data.vehicle, player)
end

function PlayerManager:move_to_next_seat(vehicle)
	local vehicle_ext = vehicle:vehicle_driving()
	local peer_id = managers.network:session():local_peer():id()
	local player = self:local_player()
	local next_seat = vehicle_ext:get_next_seat(player)
	local player_seat = vehicle_ext:find_seat_for_player(player)

	if not next_seat or next_seat == player_seat then
		Application:debug("[PlayerManager:move_to_next_seat] unable to move to next seat: current: ", inspect(player_seat), ",  next: ", next_seat)

		return
	end

	if Network:is_server() then
		self:server_move_to_next_seat(vehicle, peer_id, player, next_seat.name)
	else
		managers.network:session():send_to_host("sync_move_to_next_seat", vehicle, peer_id, player, next_seat.name)
	end
end

function PlayerManager:server_move_to_next_seat(vehicle, peer_id, player, seat_name)
	local vehicle_ext = vehicle:vehicle_driving()
	local seat = nil

	if seat_name == nil then
		Application:error("[PlayerManager:move_to_next_seat] unable to move to next seat, seat name is nil")

		return
	end

	local previous_seat = vehicle:vehicle_driving():find_seat_for_player(player)
	seat = vehicle_ext:reserve_seat(player, nil, seat_name, true)

	if seat ~= nil then
		if seat.previous_occupant then
			managers.network:session():send_to_peers_synched("sync_vehicle_player_swithc_seat", "next_seat", vehicle, peer_id, player, seat.name, previous_seat.name, seat.previous_occupant)
		else
			managers.network:session():send_to_peers_synched("sync_vehicle_player", "next_seat", vehicle, peer_id, player, seat.name, previous_seat.name)
		end

		self:_move_to_next_seat(vehicle, peer_id, player, seat, previous_seat, seat.previous_occupant)
	end
end

function PlayerManager:sync_move_to_next_seat(vehicle, peer_id, player, seat_name, previous_seat_name, previous_occupant)
	local vehicle_ext = vehicle:vehicle_driving()
	local seat = vehicle_ext._seats[seat_name]
	local previous_seat = previous_seat_name and vehicle_ext._seats[previous_seat_name] or nil

	self:_move_to_next_seat(vehicle, peer_id, player, seat, previous_seat, previous_occupant)
end

function PlayerManager:_move_to_next_seat(vehicle, peer_id, player, seat, previous_seat, previous_occupant)
	self._global.synced_vehicle_data[peer_id] = {
		vehicle_unit = vehicle,
		seat = seat.name
	}
	local vehicle_ext = vehicle:vehicle_driving()

	vehicle_ext:move_player_to_seat(player, seat, previous_seat, previous_occupant)
	player:movement():current_state():sync_move_to_next_seat()

	local rot = seat.object:rotation()
	local pos = seat.object:position() + VehicleDrivingExt.PLAYER_CAPSULE_OFFSET

	player:set_rotation(rot)
	player:set_position(pos)
	vehicle:link(Idstring(VehicleDrivingExt.SEAT_PREFIX .. seat.name), player)
	managers.hud:update_vehicle_label_by_id(vehicle:unit_data().name_label_id, vehicle_ext:_number_in_the_vehicle())

	local fov = seat.fov or vehicle_ext._tweak_data.fov

	if fov and player == self:local_player() then
		player:camera()._camera_unit:base():animate_fov(fov, 0.33)
	end

	local seat_data = seat

	if self:local_player() == player and vehicle_ext:shooting_stance_mandatory() and managers.player:current_state() == "driving" and seat_data.shooting_pos and seat_data.has_shooting_mode then
		managers.player:get_current_state():enter_shooting_stance()
	end
end

function PlayerManager:disable_view_movement()
	self:player_unit():camera():camera_unit():base():set_limits(0.01, 0.01)

	self._view_disabled = true
end

function PlayerManager:enable_view_movement()
	local player_unit = self:player_unit()

	if player_unit and alive(player_unit) then
		player_unit:camera():camera_unit():base():remove_limits()

		self._view_disabled = false
	end
end

function PlayerManager:is_view_disabled()
	return self._view_disabled
end

function PlayerManager:use_turret(turret_unit)
	self._turret_unit = turret_unit
end

function PlayerManager:leave_turret()
	self._turret_unit = nil
end

function PlayerManager:get_turret_unit()
	return self._turret_unit
end

function PlayerManager:update_player_list(unit, health)
	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		if p.unit == unit then
			p.health = health

			return
		end
	end

	table.insert(self._player_list, {
		unit = unit,
		health = health
	})
end

function PlayerManager:debug_print_player_status()
	local count = 0

	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		print("Player: ", i, ", health: ", p.health, " , unit: ", p.unit)

		count = count + 1
	end

	print("num players: ", count)
end

function PlayerManager:remove_from_player_list(unit)
	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		if p.unit == unit then
			table.remove(self._player_list, i)

			return
		end
	end
end

function PlayerManager:on_ammo_increase(ammo)
	local equipped_unit = self:get_current_state()._equipped_unit:base()
	local equipped_selection = self:get_current_state()._ext_inventory:equipped_selection()

	if equipped_unit and not equipped_unit:ammo_full() then
		local index = self:equipped_weapon_index()

		equipped_unit:add_ammo_to_pool(ammo, index)
	end
end

function PlayerManager:equipped_weapon_index()
	local current_state = self:get_current_state()
	local equipped_unit = current_state._equipped_unit:base()._unit
	local available_selections = current_state._ext_inventory:available_selections()

	for id, weapon in pairs(available_selections) do
		if equipped_unit == weapon.unit then
			return id
		end
	end

	return 1
end

function PlayerManager:equipped_weapon_unit()
	local current_state = self:get_current_state()

	if current_state then
		local weapon_unit = current_state._equipped_unit:base()._unit

		return weapon_unit
	end

	return nil
end

function PlayerManager:kill()
	local player = self:player_unit()

	if not alive(player) then
		return
	end

	managers.player:force_drop_carry()
	managers.statistics:downed({
		death = true
	})
	IngameFatalState.on_local_player_dead()
	managers.warcry:deactivate_warcry()
	player:base():set_enabled(false)
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
	managers.groupai:state():on_player_criminal_death(managers.network:session():local_peer():id())
	player:base():_unregister()
	player:base():set_slot(player, 0)
	World:delete_unit(player)
end

function PlayerManager:get_death_location_rotation()
	return self._player_death_position, self._player_death_rotation
end

function PlayerManager:set_death_location_rotation(p, r)
	Application:debug("[PlayerManager:set_death_location_rotation]", p, r)

	self._player_death_position = p
	self._player_death_rotation = r
end

function PlayerManager:destroy()
	local player = self:player_unit()

	player:base():_unregister()
	player:base():set_slot(player, 0)
end

function PlayerManager:debug_goto_custody()
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if managers.player:current_state() ~= "bleed_out" then
		managers.player:set_player_state("bleed_out")
	end

	if managers.player:current_state() ~= "fatal" then
		managers.player:set_player_state("fatal")
	end

	managers.player:force_drop_carry()
	managers.statistics:downed({
		death = true
	})
	IngameFatalState.on_local_player_dead()
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:base():_unregister()
	player:base():set_slot(player, 0)
end

function PlayerManager:replenish_player()
	local unit = managers.player:player_unit()

	if alive(unit) and unit:character_damage() then
		unit:character_damage():replenish()
	end
end

function PlayerManager:replenish_player_weapons()
	if managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():available_selections() then
		for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
			if alive(weapon.unit) and weapon.unit:base():uses_ammo() then
				weapon.unit:base():replenish()
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end

		local name, amount = managers.blackmarket:equipped_grenade()

		managers.player:add_grenade_amount(amount)
	end
end

function PlayerManager:stop_all_speaking_except_dialog()
	local local_player = self:player_unit()

	local_player:sound():stop_speaking()
end

function PlayerManager:set_local_player_in_camp(value)
	self._local_player_in_camp = value

	self:_on_camp_presence_changed()
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CAMP_PRESENCE_CHANGED)
end

function PlayerManager:local_player_in_camp()
	return self._local_player_in_camp
end

function PlayerManager:_on_camp_presence_changed()
	local player = self:local_player()

	if not player then
		return
	end

	if self._local_player_in_camp then
		player:character_damage():set_invulnerable(true)
	else
		player:character_damage():set_invulnerable(false)
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_camp_presence", self._local_player_in_camp)
	end
end

function PlayerManager:tutorial_make_invulnerable()
	managers.raid_job:revert_temp_play_flag()

	local player = managers.player:local_player()

	if not player then
		return
	end

	player:character_damage():set_invulnerable(true)
end

function PlayerManager:tutorial_set_health(value)
	local player = managers.player:local_player()

	if not player then
		return
	end

	player:character_damage():set_invulnerable(false)
	player:character_damage():set_health(value)
end

function PlayerManager:tutorial_clear_all_ammo()
	Application:debug("[PlayerManager:tutorial_clear_all_ammo()]")

	local player = managers.player:local_player()

	if not player then
		return
	end

	player:inventory():set_ammo(0)

	local _grenade, amount = managers.blackmarket:equipped_grenade()
	local peer_id = managers.network:session():local_peer():id()

	if self:has_grenade(peer_id) then
		amount = self:get_grenade_amount(peer_id) or amount
	end

	if amount > 0 then
		self:add_grenade_amount(-amount)
	end
end

function PlayerManager:tutorial_replenish_all_ammo()
	managers.raid_job._tutorial_spawned = false

	if managers.player:player_unit() and managers.player:player_unit():inventory() and managers.player:player_unit():inventory():available_selections() then
		for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
			if alive(weapon.unit) and weapon.unit:base():uses_ammo() then
				weapon.unit:base():replenish()
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end
	end

	managers.raid_job._tutorial_spawned = true
end

function PlayerManager:tutorial_set_ammo(value)
	local player = managers.player:local_player()

	if not player then
		return
	end

	player:inventory():set_ammo_with_empty_clip(value)
	self:add_grenade_amount(3)
end

function PlayerManager:tutorial_remove_AI()
	local player = managers.player:local_player()

	if not player then
		return
	end

	Global.game_settings.team_ai = false

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()

	Global.game_settings.team_ai = true
end
