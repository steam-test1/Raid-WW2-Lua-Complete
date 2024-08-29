PlayerManager = PlayerManager or class()
PlayerManager.WEAPON_SLOTS = 2
PlayerManager.EQUIPMENT_OBTAINED_MESSAGE_DURATION = 2
PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN = "PlayerManager.EVENT_LOCAL_PLAYER_ENTER_RESPAWN"
PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN = "PlayerManager.EVENT_LOCAL_PLAYER_EXIT_RESPAWN"
local UpgradeAnatomist = require("lib/managers/upgrades/UpgradeAnatomist")
local UpgradePickpocket = require("lib/managers/upgrades/UpgradePickpocket")
local UpgradeBrutality = require("lib/managers/upgrades/UpgradeBrutality")
local UpgradeBlammFu = require("lib/managers/upgrades/UpgradeBlammFu")
local UpgradeBigGame = require("lib/managers/upgrades/UpgradeBigGame")
local UpgradeHelpCry = require("lib/managers/upgrades/UpgradeHelpCry")
local UpgradeToughness = require("lib/managers/upgrades/UpgradeToughness")
local UpgradeRevenant = require("lib/managers/upgrades/UpgradeRevenant")
local UpgradeLeaded = require("lib/managers/upgrades/UpgradeLeaded")
local UpgradeRally = require("lib/managers/upgrades/UpgradeRally")

-- Lines 23-74
function PlayerManager:init()
	self._coroutine_mgr = CoroutineManager:new()
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
		charging = "ingame_standard",
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

-- Lines 78-100
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
		game_settings_team_ai = Global.game_settings.team_ai
	}
	data.PlayerManager = state
end

-- Lines 104-134
function PlayerManager:load(data)
	self:reset()

	local state = data.PlayerManager

	if state then
		self._global.kit = state.kit or self._global.kit
		self._global.viewed_content_updates = state.viewed_content_updates or self._global.viewed_content_updates

		if not self._verify_load_callback then
			self._verify_load_callback = callback(self, self, "_verify_loaded_data")

			managers.savefile:add_load_done_callback(self._verify_load_callback)
		end

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
		Global.game_settings.permission = self._global.game_settings_permission
		Global.game_settings.drop_in_allowed = self._global.game_settings_drop_in_allowed
		Global.game_settings.team_ai = self._global.game_settings_team_ai
	end
end

-- Lines 138-148
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

-- Lines 152-162
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

-- Lines 166-168
function PlayerManager:on_simulation_started()
	self._respawn = false
end

-- Lines 172-189
function PlayerManager:reset()
	Application:info("[PlayerManager] RESET")

	if managers.hud then
		managers.hud:clear_player_special_equipments()
	end

	local player = self:local_player()
	Global.player_manager = nil

	self:_setup()
	self:_setup_rules()

	if alive(player) then
		self:_setup_upgrades()
		self:aquire_default_upgrades()
	end
end

-- Lines 194-201
function PlayerManager:soft_reset()
	self._listener_holder = EventListenerHolder:new()
	self._equipment = {
		selections = {},
		specials = {}
	}
	self._global.synced_grenades = {}

	self:clear_carry(true)
	managers.environment_controller:set_vignette(0)
end

-- Lines 205-207
function PlayerManager:on_peer_synch_request(peer)
	self:player_unit():network():synch_to_peer(peer)
end

-- Lines 211-264
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
			character_profile_nation = "",
			is_character_profile_hardcore = false,
			customization_equiped_head_name = "",
			customization_equiped_upper_name = "",
			customization_equiped_lower_name = "",
			game_settings_difficulty = Global.DEFAULT_DIFFICULTY,
			game_settings_permission = Global.DEFAULT_PERMISSION,
			game_settings_drop_in_allowed = true,
			game_settings_team_ai = true
		}
	end

	Global.player_manager.default_kit = {
		weapon_slots = {
			BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID
		},
		equipment_slots = {},
		special_equipment_slots = {}
	}
	Global.player_manager.synced_bonuses = {}
	Global.player_manager.synced_equipment_possession = {}
	Global.player_manager.synced_deployables = {}
	Global.player_manager.synced_grenades = {}
	Global.player_manager.synced_ammo_info = {}
	Global.player_manager.synced_carry = {}
	Global.player_manager.synced_team_upgrades = {}
	Global.player_manager.synced_vehicle_data = {}
	Global.player_manager.synced_bipod = {}
	Global.player_manager.synced_turret = {}
	Global.player_manager.synced_drag_body = {}
	Global.player_manager.local_carry_weight = 0
	self._global = Global.player_manager
end

-- Lines 268-299
function PlayerManager:_setup_upgrades()
	UpgradeAnatomist:check_activate()
	UpgradePickpocket:check_activate()
	UpgradeBrutality:check_activate()
	UpgradeBlammFu:check_activate()
	UpgradeBigGame:check_activate()
	UpgradeHelpCry:check_activate()
	UpgradeToughness:check_activate()
	UpgradeRevenant:check_activate()
	UpgradeLeaded:check_activate()
	UpgradeRally:check_activate()
end

-- Lines 303-311
function PlayerManager:get_customization_equiped_head_name()
	local result = ""

	if Global.player_manager.customization_equiped_head_name and Global.player_manager.customization_equiped_head_name ~= "" then
		result = Global.player_manager.customization_equiped_head_name
	else
		result = self:get_character_profile_nation() .. "_default_head"
	end

	return result
end

-- Lines 312-315
function PlayerManager:set_customization_equiped_head_name(head_name)
	local owned_head_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_UPPER, head_name)
	Global.player_manager.customization_equiped_head_name = owned_head_name
end

-- Lines 317-325
function PlayerManager:get_customization_equiped_upper_name()
	local result = ""

	if Global.player_manager.customization_equiped_upper_name and Global.player_manager.customization_equiped_upper_name ~= "" then
		result = Global.player_manager.customization_equiped_upper_name
	else
		result = self:get_character_profile_nation() .. "_default_upper"
	end

	return result
end

-- Lines 326-329
function PlayerManager:set_customization_equiped_upper_name(upper_name)
	local owned_upper_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_UPPER, upper_name)
	Global.player_manager.customization_equiped_upper_name = owned_upper_name
end

-- Lines 331-339
function PlayerManager:get_customization_equiped_lower_name()
	local result = ""

	if Global.player_manager.customization_equiped_lower_name and Global.player_manager.customization_equiped_lower_name ~= "" then
		result = Global.player_manager.customization_equiped_lower_name
	else
		result = self:get_character_profile_nation() .. "_default_lower"
	end

	return result
end

-- Lines 341-344
function PlayerManager:set_customization_equiped_lower_name(lower_name)
	local owned_lower_name = managers.character_customization:verify_customization_ownership(self:get_character_profile_nation(), CharacterCustomizationTweakData.PART_TYPE_LOWER, lower_name)
	Global.player_manager.customization_equiped_lower_name = owned_lower_name
end

-- Lines 347-392
function PlayerManager:get_customization_for_nationality(nationality)
	for i = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		local save_data = Global.savefile_manager.meta_data_list[i]

		if save_data and save_data.is_cached_slot and save_data.cache and save_data.cache.PlayerManager and nationality == save_data.cache.PlayerManager.character_profile_nation then
			local player_man = save_data.cache.PlayerManager
			local customization = {
				equiped_head_name = player_man.customization_equiped_head_name,
				equiped_upper_name = player_man.customization_equiped_upper_name,
				equiped_lower_name = player_man.customization_equiped_lower_name,
				nationality = nationality
			}

			return customization
		end
	end

	local cc = managers.character_customization
	local customization = {
		equiped_head_name = cc:get_default_part_key_name(nationality, CharacterCustomizationTweakData.PART_TYPE_HEAD),
		equiped_upper_name = cc:get_default_part_key_name(nationality, CharacterCustomizationTweakData.PART_TYPE_UPPER),
		equiped_lower_name = cc:get_default_part_key_name(nationality, CharacterCustomizationTweakData.PART_TYPE_LOWER),
		nationality = nationality
	}

	return customization
end

-- Lines 396-398
function PlayerManager:add_coroutine(name, func, ...)
	self._coroutine_mgr:add_coroutine(name, func, ...)
end

-- Lines 400-402
function PlayerManager:remove_coroutine(name)
	return self._coroutine_mgr:remove_coroutine(name)
end

-- Lines 404-406
function PlayerManager:get_temporary_property(name, default)
	return self._temporary_properties:get_property(name, default)
end

-- Lines 408-410
function PlayerManager:activate_temporary_property(name, time, value)
	self._temporary_properties:activate_property(name, time, value)
end

-- Lines 412-414
function PlayerManager:add_to_temporary_property(name, time, value)
	self._temporary_properties:add_to_property(name, time, value)
end

-- Lines 416-418
function PlayerManager:has_active_temporary_property(name)
	return self._temporary_properties:has_active_property(name)
end

-- Lines 422-431
function PlayerManager:set_character_class(class)
	if not self:player_unit() then
		return
	end

	self:player_unit():character_damage():set_player_class(class)
	self:player_unit():movement():set_player_class(class)

	self._need_to_send_player_status = true
end

-- Lines 433-435
function PlayerManager:get_character_profile_name()
	return Global.player_manager.character_profile_name
end

-- Lines 436-438
function PlayerManager:set_character_profile_name(character_profile_name)
	Global.player_manager.character_profile_name = character_profile_name
end

-- Lines 440-442
function PlayerManager:get_is_character_profile_hardcore()
	return Global.player_manager.is_character_profile_hardcore
end

-- Lines 443-445
function PlayerManager:set_is_character_profile_hardcore(is_character_profile_hardcore)
	Global.player_manager.is_character_profile_hardcore = is_character_profile_hardcore
end

-- Lines 447-449
function PlayerManager:get_character_profile_nation()
	return Global.player_manager.character_profile_nation
end

-- Lines 450-457
function PlayerManager:set_character_profile_nation(character_profile_nation)
	Global.player_manager.character_profile_nation = character_profile_nation

	self:set_customization_equiped_head_name("")
	self:set_customization_equiped_upper_name("")
	self:set_customization_equiped_lower_name("")
end

-- Lines 460-462
function PlayerManager:_setup_rules()
	self._rules = {
		no_run = 0
	}
end

-- Lines 465-483
function PlayerManager:aquire_default_upgrades()
	local default_upgrades = tweak_data.skilltree.default_upgrades or {}

	Application:debug("[PlayerManager] aquire_default_upgrades", inspect(default_upgrades))

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

-- Lines 485-493
function PlayerManager:update(t, dt)
	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end

	self._sent_player_status_this_frame = nil

	self._coroutine_mgr:update(t, dt)
end

-- Lines 495-497
function PlayerManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

-- Lines 499-501
function PlayerManager:remove_listener(key)
	self._listener_holder:remove(key)
end

-- Lines 503-504
function PlayerManager:preload()
end

-- Lines 506-535
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

	player:network():send("set_player_level", current_player_level, player:id())

	local nationality = managers.player:get_character_profile_nation()

	player:network():send("set_player_nationality", nationality, player:id())

	local class = managers.skilltree:get_character_profile_class()

	player:network():send("set_player_class", class, player:id())
	player:inventory():_send_equipped_weapon()
end

-- Lines 537-605
function PlayerManager:_internal_load()
	local player = self:player_unit()

	Application:debug("[PlayerManager:_internal_load] player", player)

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
	self:_setup_upgrades()

	local wheel_params = tweak_data.interaction:get_interaction("com_wheel")

	managers.hud:set_comm_wheel_options(wheel_params.options)

	if self._respawn then
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
				end
			end

			break
		end
	end
end

-- Lines 607-635
function PlayerManager:_add_level_equipment(player)
	Application:debug("[PlayerManager:_add_level_equipment] Player", player)

	local id = Global.running_simulation and managers.editor:layer("Level Settings"):get_setting("simulation_level_id")
	id = id ~= "none" and id or nil
	id = id or Global.level_data.level_id

	if not id then
		return
	end

	local equipment = tweak_data.levels[id] and tweak_data.levels[id].equipment or {}

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_EQUIP_CROWBAR) and managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_EQUIP_CROWBAR) == true then
		table.insert(equipment, "crowbar")
	end

	if not equipment then
		return
	end

	for _, eq in ipairs(equipment) do
		Application:debug("[PlayerManager:_add_level_equipment] -- Giving equipment item:", eq)
		self:add_equipment({
			silent = true,
			equipment = eq
		})
	end
end

-- Lines 639-686
function PlayerManager:spawn_dropin_penalty(dead, bleed_out, health, used_deployable)
	local player = self:player_unit()

	print("[PlayerManager:spawn_dropin_penalty]", dead, bleed_out, health, used_deployable)

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

-- Lines 688-690
function PlayerManager:nr_players()
	return self._nr_players
end

-- Lines 692-694
function PlayerManager:set_nr_players(nr)
	self._nr_players = nr
end

-- Lines 696-705
function PlayerManager:player_id(unit)
	local id = self._last_id

	for k, player in ipairs(self._players) do
		if player == unit then
			id = k
		end
	end

	return id
end

-- Lines 707-712
function PlayerManager:viewport_config()
	local configs = self._viewport_configs[self._last_id]

	if configs then
		return configs[1]
	end
end

-- Lines 714-725
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

-- Lines 728-735
function PlayerManager:player_states()
	local ret = {}

	for k, _ in pairs(self._player_states) do
		table.insert(ret, k)
	end

	return ret
end

-- Lines 737-739
function PlayerManager:current_state()
	return self._current_state
end

-- Lines 741-743
function PlayerManager:default_player_state()
	return self._DEFAULT_STATE
end

-- Lines 745-747
function PlayerManager:current_sync_state()
	return self._current_sync_state
end

-- Lines 749-821
function PlayerManager:set_player_state(state, state_data)
	state = state or self._current_state

	if state == "bleed_out" or state == "fatal" then
		managers.hud:hide_carry_wheel(true)
	end

	if self:is_carrying() and (state == "standard" or state == "carry" or state == "carry_corpse") then
		if self:is_carrying_corpse() then
			state = "carry_corpse"
		else
			state = "carry"
		end
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
			unit:character_damage():disable_perseverance()
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

-- Lines 823-830
function PlayerManager:spawn_players(position, rotation, state)
	for var = 1, self._nr_players do
		self._last_id = var
	end

	self:spawned_player(self._last_id, safe_spawn_unit(self:player_unit_name(), position, rotation))

	return self._players[1]
end

-- Lines 832-846
function PlayerManager:spawned_player(id, unit)
	self._players[id] = unit

	self:setup_viewports()
	self:_internal_load()
	self:_change_player_state()
end

-- Lines 848-862
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

-- Lines 864-875
function PlayerManager:player_destroyed(id)
	self._players[id] = nil
	self._respawn = true
end

-- Lines 877-879
function PlayerManager:players()
	return self._players
end

-- Lines 881-883
function PlayerManager:player_unit_name()
	return self._player_name
end

-- Lines 885-888
function PlayerManager:player_unit(id)
	local p_id = id or 1

	return self._players[p_id]
end

-- Lines 890-892
function PlayerManager:local_player()
	return self:player_unit()
end

-- Lines 894-900
function PlayerManager:local_player_distance_from(pos)
	local player = self:local_player()

	if player then
		return mvector3.distance_sq(player:position(), pos)
	end

	return math.huge
end

-- Lines 902-911
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

-- Lines 913-944
function PlayerManager:on_out_of_world()
	local player_unit = self:player_unit()

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

	local pos = player_unit:movement():nav_tracker() and player_unit:movement():nav_tracker():field_position() or Vector3(0, 0, 25)

	managers.player:warp_to(pos, player_unit:rotation())
end

-- Lines 946-951
function PlayerManager:aquire_weapon(upgrade, id)
	if self._global.weapons[id] then
		return
	end

	self._global.weapons[id] = upgrade
end

-- Lines 953-955
function PlayerManager:unaquire_weapon(upgrade, id)
	self._global.weapons[id] = upgrade
end

-- Lines 958-960
function PlayerManager:aquire_melee_weapon(upgrade, id)
end

-- Lines 962-963
function PlayerManager:unaquire_melee_weapon(upgrade, id)
end

-- Lines 965-966
function PlayerManager:aquire_grenade(upgrade, id)
end

-- Lines 968-969
function PlayerManager:unaquire_grenade(upgrade, id)
end

-- Lines 972-980
function PlayerManager:_verify_equipment_kit(loading)
	if not managers.player:equipment_in_slot(1) then
		if managers.blackmarket then
			managers.blackmarket:equip_deployable(managers.player:availible_equipment(1)[1], loading)
		else
			self._global.kit.equipment_slots[1] = managers.player:availible_equipment(1)[1]
		end
	end
end

-- Lines 982-994
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

-- Lines 996-1041
function PlayerManager:on_killshot(killed_unit, variant)
	local player_unit = self:player_unit()

	if not alive(player_unit) or not alive(killed_unit) then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local t = Application:time()

	if self._on_killshot_t and t < self._on_killshot_t then
		return
	end

	if self:has_category_upgrade("player", "dac_stamina_regeneration_on_kill") then
		player_unit:movement():reset_stamina_regeneration(true)
	end

	if variant == "melee" and self:has_category_upgrade("temporary", "do_die_melee_speed_multiplier") then
		self:activate_temporary_upgrade("temporary", "do_die_melee_speed_multiplier")
	end

	local panic_chance = self:upgrade_value("player", "holdbarred_melee_kill_panic_chance", 1) - 1

	if panic_chance > 0 and variant == "melee" then
		local slotmask = managers.slot:get_mask("enemies")
		local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.holdbarred_melee_kill_panic_range, slotmask)

		for _, unit in pairs(units) do
			if alive(unit) and not unit:character_damage():dead() then
				unit:character_damage():build_suppression(0, panic_chance)
			end
		end
	end

	self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)
end

-- Lines 1043-1056
function PlayerManager:on_damage_dealt(unit, damage_info)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local t = Application:time()

	if self._on_damage_dealt_t and t < self._on_damage_dealt_t then
		return
	end

	self._on_damage_dealt_t = t + (tweak_data.upgrades.on_damage_dealt_cooldown or 0)
end

-- Lines 1059-1078
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

	if is_kill then
		managers.dialog:queue_dialog("player_gen_critical_hit", {
			skip_idle_check = true,
			instigator = player_unit
		})
	end
end

-- Lines 1080-1097
function PlayerManager:on_upgrades_changed()
	local player = self:local_player()

	if alive(player) then
		local current_state = player:movement():current_state()

		self:_setup_upgrades()
		player:character_damage():setup_upgrades()
		current_state:setup_upgrades()
		managers.warcry:setup_upgrades()
		self:replenish_player_weapons()
		self:replenish_player()
		self:sync_upgrades()
	end
end

-- Lines 1099-1114
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

-- Lines 1116-1129
function PlayerManager:aquire_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	self._global.upgrades[upgrade.category][upgrade.upgrade] = math.max(upgrade.value, self._global.upgrades[upgrade.category][upgrade.upgrade] or 0)
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][upgrade.value]

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

-- Lines 1131-1144
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

-- Lines 1147-1158
function PlayerManager:aquire_incremental_upgrade(upgrade)
	self._global.upgrades[upgrade.category] = self._global.upgrades[upgrade.category] or {}
	local val = self._global.upgrades[upgrade.category][upgrade.upgrade]
	self._global.upgrades[upgrade.category][upgrade.upgrade] = (val or 0) + 1
	local value = tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][self._global.upgrades[upgrade.category][upgrade.upgrade]]

	if self[upgrade.upgrade] then
		self[upgrade.upgrade](self, value)
	end
end

-- Lines 1160-1183
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

-- Lines 1186-1207
function PlayerManager:upgrade_value(category, upgrade, default)
	if not self._global.upgrades[category] then
		if default ~= nil then
			return default
		end

		return 0
	end

	if not self._global.upgrades[category][upgrade] then
		if default ~= nil then
			return default
		end

		return 0
	end

	local level = self._global.upgrades[category][upgrade]
	local value = tweak_data.upgrades.values[category][upgrade][level]

	return value
end

-- Lines 1209-1228
function PlayerManager:sync_upgrades()
	local player = self:local_player()

	if not player then
		Application:warn("[PlayerManager:sync_upgrades] If you are seeing this the player doesnt exist yet... That might be bad.")

		return
	end

	player:network():send("sync_upgrade", UpgradesTweakData.CLEAR_UPGRADES_FLAG, "", 1, player:id())

	for category, upgrades in pairs(self._global.upgrades) do
		for upgrade, level in pairs(upgrades) do
			player:network():send("sync_upgrade", category, upgrade, level, player:id())
		end
	end

	local active_warcry = managers.warcry:get_active_warcry_name()
	local warcry_meter_percentage = managers.warcry:current_meter_percentage()

	player:network():send("set_active_warcry", active_warcry, warcry_meter_percentage, player:id())
end

-- Lines 1232-1234
function PlayerManager:list_level_rewards(dlcs)
	return managers.upgrades:list_level_rewards(dlcs)
end

-- Lines 1238-1250
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

-- Lines 1252-1270
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

-- Lines 1272-1282
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

-- Lines 1284-1299
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

-- Lines 1301-1316
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

-- Lines 1318-1341
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

-- Lines 1343-1348
function PlayerManager:equiptment_upgrade_value(category, upgrade, default)
	if category == "trip_mine" and upgrade == "quantity" then
		return self:upgrade_value(category, "quantity_1", default) + self:upgrade_value(category, "quantity_2", default) + self:upgrade_value(category, "quantity_3", default)
	end

	return self:upgrade_value(category, upgrade, default)
end

-- Lines 1353-1364
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

-- Lines 1367-1369
function PlayerManager:upgrade_value_by_level(category, upgrade, level, default)
	return tweak_data.upgrades.values[category][upgrade][level] or default or 0
end

-- Lines 1372-1383
function PlayerManager:equipped_upgrade_value(equipped, category, upgrade)
	if not self:has_category_upgrade(category, upgrade) then
		return 0
	end

	if not table.contains(self._global.kit.equipment_slots, equipped) then
		return 0
	end

	return self:upgrade_value(category, upgrade)
end

-- Lines 1386-1394
function PlayerManager:has_category_upgrade(category, upgrade)
	if not self._global.upgrades[category] then
		return false
	end

	if not self._global.upgrades[category][upgrade] then
		return false
	end

	return true
end

-- Lines 1397-1400
function PlayerManager:body_armor_value(category, override_value, default)
	local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

	return self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
end

-- Lines 1403-1452
function PlayerManager:movement_speed_multiplier(is_running, is_climbing, is_crouching, in_steelsight, health_ratio)
	local multiplier = 1

	if is_running then
		multiplier = multiplier + self:upgrade_value("player", "sprinter_run_speed_increase", 1) - 1
	end

	if is_climbing then
		multiplier = multiplier + self:upgrade_value("player", "fasthand_climb_speed_increase", 1) - 1
	end

	if is_crouching then
		multiplier = multiplier + self:upgrade_value("player", "scuttler_crouch_speed_increase", 1) - 1
	end

	if in_steelsight then
		local equipped_weapon = self:equipped_weapon_unit()

		if alive(equipped_weapon) then
			multiplier = multiplier + self:upgrade_value(equipped_weapon:base():category(), "steelsight_movement_speed_multiplier", 1) - 1
		end

		multiplier = multiplier + self:upgrade_value("player", "steelsight_movement_speed_multiplier", 1) - 1
	end

	if math.in_range(health_ratio, 0, self._low_health_regen_limit) then
		multiplier = multiplier + self:upgrade_value("player", "fleetfoot_critical_movement_speed_multiplier", 1) - 1
	else
		multiplier = multiplier + self:upgrade_value("player", "fleetfoot_movement_speed_multiplier", 1) - 1
	end

	local warcry_multiplier = self:team_upgrade_value("player", "warcry_movement_speed_multiplier", 0)

	if warcry_multiplier > 0 then
		warcry_multiplier = warcry_multiplier - 1
	end

	multiplier = multiplier + warcry_multiplier

	if self:has_activate_temporary_upgrade("temporary", "warcry_sentry_shooting") then
		multiplier = multiplier * self:upgrade_value("player", "warcry_shooting_movement_speed_reduction", 1)
	end

	return multiplier
end

-- Lines 1455-1466
function PlayerManager:body_armor_skill_multiplier(override_armor)
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1

	return multiplier
end

-- Lines 1469-1471
function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	return 1
end

-- Lines 1474-1480
function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = 0
	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

	return addend
end

-- Lines 1483-1487
function PlayerManager:skill_dodge_chance()
	local chance = self:upgrade_value("player", "warcry_dodge", 1) - 1

	return chance
end

-- Lines 1490-1496
function PlayerManager:stamina_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "fitness_stamina_multiplier", 1) - 1

	return multiplier
end

-- Lines 1498-1508
function PlayerManager:stamina_regen_multiplier(crouching, in_steelsight)
	local multiplier = 1
	multiplier = multiplier + managers.player:upgrade_value("player", "fitness_stamina_regeneration_increase", 1) - 1

	if crouching then
		multiplier = multiplier + self:upgrade_value("player", "scuttler_stamina_regeneration_increase", 1) - 1
	end

	return multiplier
end

-- Lines 1510-1516
function PlayerManager:stamina_regen_delay_multiplier()
	local multiplier = 1
	multiplier = multiplier * managers.player:upgrade_value("player", "dac_stamina_regen_delay_multiplier", 1)

	return multiplier
end

-- Lines 1519-1556
function PlayerManager:critical_hit_chance(distance)
	local equipped_weapon = self:equipped_weapon_unit()
	local multiplier = 0
	multiplier = multiplier + self:team_upgrade_value("player", "warcry_critical_hit_chance", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "critbrain_critical_hit_chance", 1) - 1

	if self:has_activate_temporary_upgrade("temporary", "brutality_dismember_critical_hit_chance") then
		multiplier = multiplier + self:temporary_upgrade_value("temporary", "brutality_dismember_critical_hit_chance", 1) - 1
	end

	if self:has_activate_temporary_upgrade("temporary", "revenant_revived_critical_hit_chance") then
		multiplier = multiplier + self:temporary_upgrade_value("temporary", "revenant_revived_critical_hit_chance", 1) - 1
	end

	if self:current_state() == "bleed_out" then
		multiplier = multiplier + self:upgrade_value("player", "revenant_downed_critical_hit_chance", 1) - 1
	end

	if alive(equipped_weapon) and equipped_weapon:base().critical_hit_chance then
		multiplier = multiplier + equipped_weapon:base():critical_hit_chance()
	end

	if distance and tweak_data.upgrades.farsighted_activation_distance < distance then
		multiplier = multiplier + self:upgrade_value("player", "farsighted_long_range_critical_hit_chance", 1) - 1
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE) then
		multiplier = multiplier * (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE) or 1)
	end

	return multiplier
end

-- Lines 1559-1586
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

-- Lines 1590-1596
function PlayerManager:health_skill_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "max_health_multiplier", 1) - 1

	return multiplier
end

-- Lines 1600-1604
function PlayerManager:health_skill_addition_on_top()
	local add_amount = 0

	return add_amount
end

-- Lines 1608-1627
function PlayerManager:health_regen(health_ratio, real_armor)
	local health_regen = 0

	if real_armor and real_armor > 0 then
		health_regen = health_regen + self._health_regen

		if math.in_range(health_ratio, 0, self._low_health_regen_limit) then
			health_regen = health_regen + self._low_health_regen
		end
	end

	health_regen = health_regen + self:team_upgrade_value("player", "warcry_health_regeneration", 1) - 1
	health_regen = health_regen + self:temporary_upgrade_value("temporary", "big_game_special_health_regen", 1) - 1

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN) then
		health_regen = health_regen + managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN)
	end

	return health_regen
end

-- Lines 1629-1642
function PlayerManager:update_health_regen_values()
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(managers.skilltree:has_character_profile_class() and managers.skilltree:get_character_profile_class())
	self._health_regen = class_tweak_data.damage.HEALTH_REGEN
	local low_regen_limit_multiplier = self:upgrade_value("player", "toughness_low_health_regen_limit_multiplier", 1)
	self._low_health_regen_limit = class_tweak_data.damage.LOW_HEALTH_REGEN_LIMIT * low_regen_limit_multiplier
	local low_regen_multiplier = self:upgrade_value("player", "box_o_choc_low_health_regen_multiplier", 1)
	low_regen_multiplier = low_regen_multiplier * self:upgrade_value("player", "rally_low_health_regen_multiplier", 1)
	self._low_health_regen = class_tweak_data.damage.LOW_HEALTH_REGEN * low_regen_multiplier
end

-- Lines 1644-1651
function PlayerManager:get_low_health_regen_limit()
	return self._low_health_regen_limit
end

-- Lines 1656-1746
function PlayerManager:damage_reduction_skill_multiplier(damage_type, current_state, health_ratio)
	local multiplier = 1
	local is_bullet = damage_type == "bullet"
	local is_melee = damage_type == "melee"
	local is_explosion = damage_type == "explosion"
	local is_fire = damage_type == "fire"
	local state_name = self:current_state()

	if is_bullet then
		-- Nothing
	elseif is_melee then
		multiplier = multiplier * self:upgrade_value("player", "boxer_melee_damage_reduction", 1)
	elseif is_explosion then
		multiplier = multiplier * self:upgrade_value("player", "grenadier_explosive_damage_reduction", 1)
		multiplier = multiplier * self:upgrade_value("player", "painkiller_explosive_damage_reduction", 1)
	elseif is_fire then
		multiplier = multiplier * self:upgrade_value("player", "painkiller_fire_damage_reduction", 1)
	end

	if self:has_activate_temporary_upgrade("temporary", "revenant_revived_damage_reduction") then
		multiplier = multiplier * self:temporary_upgrade_value("temporary", "revenant_revived_damage_reduction", 1)
	end

	if self:has_activate_temporary_upgrade("temporary", "warcry_sentry_shooting") then
		multiplier = multiplier * self:upgrade_value("player", "warcry_shooting_damage_reduction", 1)
	end

	if math.in_range(health_ratio, 0, self._low_health_regen_limit) then
		multiplier = multiplier * self:upgrade_value("player", "toughness_critical_damage_reduction", 1)
	end

	if current_state then
		if current_state:_interacting() then
			multiplier = multiplier * self:upgrade_value("player", "focus_interaction_damage_reduction", 1)
		end

		if current_state:in_steelsight() then
			multiplier = multiplier * self:upgrade_value("player", "focus_steelsight_damage_reduction", 1)
		end

		if current_state:running() then
			multiplier = multiplier * self:upgrade_value("player", "agile_running_damage_reduction", 1)
		end

		if state_name == "driving" then
			multiplier = multiplier * self:upgrade_value("player", "focus_vehicle_damage_reduction", 1)
		elseif state_name == "turret" then
			local max_reduction = self:upgrade_value("player", "gunner_damage_reduction", 1)
			local current_heat = current_state.get_current_heat and current_state:get_current_heat() or 0
			multiplier = multiplier * (1 - max_reduction * current_heat)
		end
	end

	local gsm = game_state_machine

	if gsm:current_state_name() == "ingame_special_interaction" then
		local minigame = gsm:current_state():minigame_type()

		if minigame == tweak_data.interaction.MINIGAME_PICK_LOCK then
			multiplier = multiplier * self:upgrade_value("player", "locksmith_lockpicking_damage_reduction", 1)
		end
	end

	multiplier = multiplier * self:team_upgrade_value("player", "warcry_damage_reduction_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "warcry_charge_damage_reduction", 1)

	return multiplier
end

-- Lines 1750-1757
function PlayerManager:upgrade_minigame_params(params)
	params.minigame_type = params.minigame_type or tweak_data.interaction.MINIGAME_PICK_LOCK
	local upgrade_func = self["_upgrade_minigame_" .. params.minigame_type]

	if upgrade_func then
		upgrade_func(self, params)
	end
end

-- Lines 1759-1786
function PlayerManager:_upgrade_minigame_pick_lock(params)
	local wheel_decrease = self:upgrade_value(UpgradesTweakData.UPG_CAT_INTERACT, "locksmith_wheel_amount_decrease", 0)

	if wheel_decrease > 0 then
		params.number_of_circles = math.max(params.number_of_circles - wheel_decrease, 1)

		for i = 1, #params.circle_difficulty - 1 do
			params.circle_difficulty[i] = params.circle_difficulty[i + 1]
		end

		for i = 1, #params.circle_rotation_speed - 1 do
			params.circle_rotation_speed[i] = params.circle_rotation_speed[i + 1]
		end
	end

	local hospot_increase = self:upgrade_value(UpgradesTweakData.UPG_CAT_INTERACT, "locksmith_wheel_hotspot_increase", 1)

	for i = 1, #params.circle_difficulty do
		params.circle_difficulty[i] = params.circle_difficulty[i] * hospot_increase
	end

	local rotation_speed_increase = self:upgrade_value(UpgradesTweakData.UPG_CAT_INTERACT, "locksmith_wheel_rotation_speed_increase", 1)

	for i = 1, #params.circle_rotation_speed do
		params.circle_rotation_speed[i] = params.circle_rotation_speed[i] * rotation_speed_increase
	end
end

-- Lines 1788-1800
function PlayerManager:_upgrade_minigame_cut_fuse(params)
	local hospot_increase = self:upgrade_value(UpgradesTweakData.UPG_CAT_INTERACT, "saboteur_fuse_hotspot_increase", 1)
	params.circle_difficulty = params.circle_difficulty * hospot_increase

	if params.circle_difficulty_deviation then
		params.circle_difficulty_deviation[1] = params.circle_difficulty_deviation[1] * hospot_increase
		params.circle_difficulty_deviation[2] = params.circle_difficulty_deviation[2] * hospot_increase
	end
end

-- Lines 1804-1808
function PlayerManager:_upgrade_minigame_roulette(params)
	local rotation_speed_increase = self:upgrade_value(UpgradesTweakData.UPG_CAT_INTERACT, "locksmith_wheel_rotation_speed_increase", 1)
	params.circle_rotation_speed = (params.circle_rotation_speed or 100) * rotation_speed_increase
end

-- Lines 1813-1823
function PlayerManager:toolset_value()
	if not self:has_category_upgrade("player", "toolset") then
		return 1
	end

	if not table.contains(self._global.kit.equipment_slots, "toolset") then
		return 1
	end

	return self:upgrade_value("player", "toolset")
end

-- Lines 1826-1834
function PlayerManager:inspect_current_upgrades()
	for name, upgrades in pairs(self._global.upgrades) do
		print("Weapon " .. name .. ":")

		for upgrade, level in pairs(upgrades) do
			print("Upgrade:", upgrade, "is at level", level, "and has value", string.format("%.2f", tweak_data.upgrades.values[name][upgrade][level]))
		end

		print("\n")
	end
end

-- Lines 1836-1842
function PlayerManager:spread_multiplier()
	if not alive(self:player_unit()) then
		return
	end

	self:player_unit():movement()._current_state:_update_crosshair_offset()
end

-- Lines 1845-1862
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

-- Lines 1865-1901
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

-- Lines 1905-1907
function PlayerManager:has_weapon(name)
	return managers.player._global.weapons[name]
end

-- Lines 1909-1911
function PlayerManager:has_aquired_equipment(name)
	return managers.player._global.equipment[name]
end

-- Lines 1913-1921
function PlayerManager:availible_weapons(slot)
	local weapons = {}

	for name, _ in pairs(managers.player._global.weapons) do
		if not slot or slot and tweak_data.weapon[name].use_data.selection_index == slot then
			table.insert(weapons, name)
		end
	end

	return weapons
end

-- Lines 1923-1931
function PlayerManager:weapon_in_slot(slot)
	local weapon = self._global.kit.weapon_slots[slot]

	if self._global.weapons[weapon] then
		return weapon
	end

	local weapon = self._global.default_kit.weapon_slots[slot]

	return self._global.weapons[weapon] and weapon
end

-- Lines 1933-1941
function PlayerManager:availible_equipment(slot)
	local equipment = {}

	for name, _ in pairs(self._global.equipment) do
		if not slot or slot and tweak_data.upgrades.definitions[name].slot == slot then
			table.insert(equipment, name)
		end
	end

	return equipment
end

-- Lines 1943-1945
function PlayerManager:equipment_in_slot(slot)
	return self._global.kit.equipment_slots[slot]
end

-- Lines 1950-1958
function PlayerManager:toggle_player_rule(rule)
	self._rules[rule] = not self._rules[rule]

	if rule == "no_run" and self._rules[rule] then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

-- Lines 1960-1969
function PlayerManager:set_player_rule(rule, value)
	self._rules[rule] = self._rules[rule] + (value and 1 or -1)

	if rule == "no_run" and self:get_player_rule(rule) then
		local player = self:player_unit()

		if player:movement():current_state()._interupt_action_running then
			player:movement():current_state():_interupt_action_running(Application:time())
		end
	end
end

-- Lines 1971-1973
function PlayerManager:get_player_rule(rule)
	return self._rules[rule] > 0
end

-- Lines 1977-1979
function PlayerManager:has_deployable_been_used()
	return self._peer_used_deployable or false
end

-- Lines 1982-1989
function PlayerManager:update_deployable_equipment_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_deployables[peer_id] then
		local deployable = self._global.synced_deployables[peer_id].deployable
		local amount = self._global.synced_deployables[peer_id].amount

		peer:send_queued_sync("sync_deployable_equipment", deployable, amount)
	end
end

-- Lines 1991-1995
function PlayerManager:update_deployable_equipment_amount_to_peers(equipment, amount)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_deployable_equipment", equipment, amount)
	self:set_synced_deployable_equipment(peer, equipment, amount)
end

-- Lines 1997-2026
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

-- Lines 2028-2030
function PlayerManager:get_synced_deployable_equipment(peer_id)
	return self._global.synced_deployables[peer_id]
end

-- Lines 2036-2043
function PlayerManager:update_ammo_info_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_ammo_info[peer_id] then
		for selection_index, ammo_info in pairs(self._global.synced_ammo_info[peer_id]) do
			peer:send_queued_sync("sync_ammo_amount", selection_index, unpack(ammo_info))
		end
	end
end

-- Lines 2045-2049
function PlayerManager:update_synced_ammo_info_to_peers(selection_index, max_clip, current_clip, current_left, max)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_ammo_amount", selection_index, max_clip, current_clip, current_left, max)
	self:set_synced_ammo_info(peer_id, selection_index, max_clip, current_clip, current_left, max)
end

-- Lines 2051-2062
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

-- Lines 2064-2066
function PlayerManager:get_synced_ammo_info(peer_id)
	return self._global.synced_ammo_info[peer_id]
end

-- Lines 2073-2083
function PlayerManager:update_carry_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()
	local carry_data = self:get_synced_carry(peer_id)

	if carry_data then
		for i, carry_item in ipairs(carry_data) do
			local carry_id = carry_item.carry_id
			local multiplier = carry_item.multiplier

			peer:send_queued_sync("sync_add_carry", carry_id, multiplier)
		end
	end
end

-- Lines 2087-2092
function PlayerManager:update_synced_carry_to_peers(carry_id, multiplier)
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_add_carry", carry_id, multiplier)
	self:add_synced_carry(peer, carry_id, multiplier)
end

-- Lines 2097-2131
function PlayerManager:add_synced_carry(peer, carry_id, multiplier)
	local peer_id = peer:id()
	local peer_carry_data = self:get_synced_carry(peer_id)

	if not peer_carry_data then
		peer_carry_data = {}
		self._global.synced_carry[peer_id] = peer_carry_data
	end

	table.insert(peer_carry_data, {
		carry_id = carry_id,
		multiplier = multiplier
	})

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

-- Lines 2135-2148
function PlayerManager:set_carry_approved(carry_id, peer)
	local peer_id = peer:id()
	local peer_carry_data = self:get_synced_carry(peer_id)

	for i, carry_item in ipairs(peer_carry_data) do
		if carry_item.carry_id == carry_id and not carry_item.approved then
			carry_item.approved = true

			break
		end
	end
end

-- Lines 2152-2160
function PlayerManager:update_removed_synced_carry_to_peers(carry_id)
	if carry_id then
		local peer = managers.network:session():local_peer()

		managers.network:session():send_to_peers_synched("sync_remove_carry", carry_id)
		self:remove_synced_carry(carry_id, peer)
	else
		debug_pause("[PlayerManager:update_removed_synced_carry_to_peers] No carry ID!!!")
	end
end

-- Lines 2164-2169
function PlayerManager:update_removed_all_synced_carry_to_peers()
	local peer = managers.network:session():local_peer()

	managers.network:session():send_to_peers_synched("sync_remove_all_carry")
	self:remove_synced_carry(nil, peer)
end

-- Lines 2174-2244
function PlayerManager:remove_synced_carry(carry_id, peer)
	local peer_id = peer:id()

	Application:debug("[PlayerManager:remove_synced_carry] carry_id, peer_id", carry_id, peer_id)

	local peer_carry_data = self:get_synced_carry(peer_id)

	if not peer_carry_data then
		Application:warn("[PlayerManager:remove_synced_carry] Could not remove carry item from peer as peer did not have any carry items synced " .. tostring(peer_id))

		return
	end

	local player_empty = nil
	local remove_all_items = carry_id == nil

	if remove_all_items then
		Application:debug("[PlayerManager:remove_synced_carry] Clearing all carry data...")
		self:clear_synced_carry(peer_id)

		player_empty = true
	else
		local success = nil

		for index, carry_item in ipairs(peer_carry_data) do
			if carry_item.carry_id == carry_id then
				local removed_carry_item = table.remove(peer_carry_data, index)
				success = true

				Application:debug("[PlayerManager:remove_synced_carry] Removed carry item " .. tostring(removed_carry_item) .. " : " .. removed_carry_item.carry_id)

				break
			end
		end

		player_empty = table.empty(peer_carry_data)

		if not success then
			Application:warn("[PlayerManager:remove_synced_carry] Could not remove carry item '" .. carry_id .. "' there was no approved items for it from peer_id: " .. tostring(peer_id))

			return
		end
	end

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

	if player_empty then
		managers.hud:remove_teammate_carry_info(teammate_panel_id, name_label_id)
	else
		local carry_id = peer_carry_data[1].carry_id

		managers.hud:set_teammate_carry_info(teammate_panel_id, name_label_id, carry_id)
	end

	local local_peer_id = managers.network:session():local_peer():id()

	if peer_id ~= local_peer_id then
		local unit = peer:unit()

		if alive(unit) and player_empty then
			unit:movement():set_visual_carry(nil)
		end
	end
end

-- Lines 2248-2254
function PlayerManager:get_my_carry_data()
	if managers.network:session() and managers.network:session():local_peer() then
		local peer_id = managers.network:session():local_peer():id()

		return self:get_synced_carry(peer_id)
	end

	return nil
end

-- Lines 2257-2263
function PlayerManager:get_my_carry_weight()
	if managers.network:session() and managers.network:session():local_peer() then
		local peer_id = managers.network:session():local_peer():id()

		return self._global.local_carry_weight
	end

	return 0
end

-- Lines 2266-2273
function PlayerManager:get_my_carry_weight_ratio()
	if self:is_carrying() then
		return self:get_my_carry_weight() / self:get_my_carry_weight_limit()
	else
		return 0
	end
end

-- Lines 2276-2282
function PlayerManager:is_carrying_full(ignore_dynamic_upgrades)
	if self:is_carrying() then
		return self:get_my_carry_weight_limit(ignore_dynamic_upgrades) <= self:get_my_carry_weight()
	else
		return false
	end
end

-- Lines 2285-2291
function PlayerManager:is_carrying_over_full(ignore_dynamic_upgrades)
	if self:is_carrying() then
		return self:get_my_carry_weight_limit(ignore_dynamic_upgrades) < self:get_my_carry_weight()
	else
		return false
	end
end

-- Lines 2294-2296
function PlayerManager:reset_local_peer_carry_weight()
	self:modify_local_peer_carry_weight(0)
end

-- Lines 2299-2356
function PlayerManager:modify_local_peer_carry_weight(amount)
	local ratio = nil
	local player = self:player_unit()

	if not player then
		return
	end

	if self:is_carrying() then
		self._global.local_carry_weight = math.round(self._global.local_carry_weight + amount)
		ratio = self:get_my_carry_weight_ratio()
		local is_carrying_corpse = self:is_carrying_corpse()
		local is_carrying_cannot_stack = self:is_carrying_cannot_stack()

		if self._current_state == "carry" or self._current_state == "carry_corpse" or self._current_state == "standard" then
			self:set_player_state("carry")
		end

		local carry_type = is_carrying_corpse and "being" or "normal"

		player:movement():current_state():set_tweak_data(carry_type)
		player:movement():current_state():update_tilt()
	else
		self._global.local_carry_weight = 0
		ratio = 0

		if self._current_state == "carry" or self._current_state == "carry_corpse" then
			self:set_player_state("standard")
		end
	end

	local overweight = self:is_carrying_over_full(true)

	managers.hud:set_carry_weight(ratio, overweight)

	if player:inventory() and self:has_category_upgrade("player", "bellhop_weight_increase_off_primary") then
		player:inventory():set_selection_blocked(tweak_data.WEAPON_SLOT_PRIMARY, overweight)
		Application:debug("[PlayerManager:modify_local_peer_carry_weight] Overweight, blocking primary weapon", player:inventory():is_selection_blocked(tweak_data.WEAPON_SLOT_PRIMARY))
	end

	Application:debug("[PlayerManager:modify_local_peer_carry_weight] Current carry weight is:", ratio, ":", self._global.local_carry_weight, "/", self:get_my_carry_weight_limit())
end

-- Lines 2362-2388
function PlayerManager:get_my_carry_weight_limit(ignore_dynamic_upgrades, class)
	class = class or managers.skilltree:get_character_profile_class()
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(class)
	local base = class_tweak_data.movement.carry.CARRY_WEIGHT_MAX or 5
	local skill = managers.player:upgrade_value("player", "carry_weight_increase", 0)
	skill = skill + managers.player:upgrade_value("carry", "strongback_weight_increase", 0)
	skill = skill + managers.player:upgrade_value("carry", "pack_mule_weight_increase", 0)

	if not ignore_dynamic_upgrades and self:has_category_upgrade("player", "bellhop_weight_increase_off_primary") and self:equipped_weapon_index() ~= WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		skill = skill + managers.player:upgrade_value("player", "bellhop_weight_increase_off_primary", 0)
	end

	return base + skill
end

-- Lines 2391-2418
function PlayerManager:local_can_carry_weight(carry_id)
	local carry_tweak = tweak_data.carry[carry_id]

	if not carry_tweak then
		return false
	end

	local weight_cur = self:get_my_carry_weight()
	local weight_max = self:get_my_carry_weight_limit(true)
	local weight_bag = carry_tweak.weight or tweak_data.carry.default_bag_weight

	if carry_tweak.upgrade_weight_multiplier then
		local multiplier = carry_tweak.upgrade_weight_multiplier
		weight_bag = weight_bag * self:upgrade_value(multiplier.category, multiplier.upgrade, 1)
	end

	if managers.player:has_category_upgrade("player", "bellhop_weight_increase_off_primary") and weight_cur + weight_bag <= weight_max + managers.player:upgrade_value("player", "bellhop_weight_increase_off_primary", 0) then
		return true
	elseif weight_max >= weight_cur + weight_bag then
		return true
	end

	return false
end

-- Lines 2422-2425
function PlayerManager:get_synced_carry(peer_id)
	local all_synced_carry = self:get_all_synced_carry()

	return all_synced_carry[peer_id]
end

-- Lines 2429-2435
function PlayerManager:clear_synced_carry(peer_id)
	if peer_id == managers.network:session():local_peer():id() then
		self._global.local_carry_weight = 0
	end

	self._global.synced_carry[peer_id] = nil
end

-- Lines 2438-2440
function PlayerManager:get_all_synced_carry()
	return self._global.synced_carry
end

-- Lines 2463-2468
function PlayerManager:from_server_interaction_reply(status)
	self:player_unit():movement():set_carry_restriction(false)

	if not status then
		self:clear_carry()
	end
end

-- Lines 2474-2479
function PlayerManager:aquire_team_upgrade(upgrade)
	self._global.team_upgrades[upgrade.category] = self._global.team_upgrades[upgrade.category] or {}
	self._global.team_upgrades[upgrade.category][upgrade.upgrade] = upgrade.value

	self:update_team_upgrades_to_peers()
end

-- Lines 2482-2509
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

-- Lines 2512-2533
function PlayerManager:team_upgrade_value(category, upgrade, default)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			local level = categories[category][upgrade]

			return tweak_data.upgrades.values[UpgradesTweakData.DEF_CAT_TEAM][category][upgrade][level]
		end
	end

	if not self._global.team_upgrades[category] then
		return default or 0
	end

	if not self._global.team_upgrades[category][upgrade] then
		return default or 0
	end

	local level = self._global.team_upgrades[category][upgrade]
	local value = tweak_data.upgrades.values[UpgradesTweakData.DEF_CAT_TEAM][category][upgrade][level]

	return value
end

-- Lines 2535-2551
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

-- Lines 2554-2567
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

-- Lines 2570-2577
function PlayerManager:update_team_upgrades_to_peer(peer)
	for category, upgrades in pairs(self._global.team_upgrades) do
		for upgrade, level in pairs(upgrades) do
			peer:send_queued_sync("add_synced_team_upgrade", category, upgrade, level)
		end
	end
end

-- Lines 2580-2582
function PlayerManager:clear_synced_team_upgrades(peer_id)
	self._global.synced_team_upgrades[peer_id] = nil
end

-- Lines 2585-2590
function PlayerManager:add_synced_team_upgrade(peer_id, category, upgrade, level)
	self._global.synced_team_upgrades[peer_id] = self._global.synced_team_upgrades[peer_id] or {}
	self._global.synced_team_upgrades[peer_id][category] = self._global.synced_team_upgrades[peer_id][category] or {}
	self._global.synced_team_upgrades[peer_id][category][upgrade] = level
end

-- Lines 2596-2605
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

-- Lines 2607-2609
function PlayerManager:get_synced_equipment_possession(peer_id)
	return self._global.synced_equipment_possession[peer_id]
end

-- Lines 2612-2620
function PlayerManager:update_equipment_possession_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_equipment_possession[peer_id] then
		for name, amount in pairs(self._global.synced_equipment_possession[peer_id]) do
			peer:send_queued_sync("sync_equipment_possession", peer_id, name, amount)
		end
	end
end

-- Lines 2622-2626
function PlayerManager:update_equipment_possession_to_peers(equipment, amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_equipment_possession", peer_id, equipment, amount or 1)
	self:set_synced_equipment_possession(peer_id, equipment, amount)
end

-- Lines 2628-2644
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

-- Lines 2646-2729
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

-- Lines 2733-2790
function PlayerManager:peer_dropped_out(peer)
	local peer_id = peer:id()

	if Network:is_server() then
		self:transfer_special_equipment(peer_id, true)

		-- Lines 2739-2739
		local function rand_dir()
			return Vector3(math.random(-2, 2), math.random(-2, 2), math.random(0, 1)):normalized()
		end

		-- Lines 2740-2740
		local function rand_rot()
			return Rotation(math.random(), math.random(), 0)
		end

		local synced_carry = self:get_synced_carry(peer_id)

		for i, carry_item in ipairs(synced_carry or {}) do
			if carry_item and carry_item.approved then
				local carry_id = carry_item.carry_id
				local carry_multiplier = carry_item.multiplier
				local peer_unit = peer:unit()
				local position = Vector3()

				if alive(peer_unit) then
					if peer_unit:movement():zipline_unit() then
						position = peer_unit:movement():zipline_unit():position()
					else
						position = peer_unit:position()
					end
				end

				self:server_drop_carry(carry_id, carry_multiplier, position, rand_rot(), rand_dir(), 0, nil, peer)
			end
		end

		self:_turret_drop_out(peer)
	end

	self._global.synced_equipment_possession[peer_id] = nil
	self._global.synced_deployables[peer_id] = nil
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

-- Lines 2792-2794
function PlayerManager:clear_synced_turret()
	self._global.synced_turret = {}
end

-- Lines 2796-2807
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

-- Lines 2813-2824
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

-- Lines 2826-2846
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

-- Lines 2848-2855
function PlayerManager:add_equipment_amount(equipment, amount)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = Application:digest_value(data.amount, false) + amount
		data.amount = Application:digest_value(new_amount, true)

		managers.hud:set_item_amount(index, new_amount)
	end
end

-- Lines 2857-2864
function PlayerManager:set_equipment_amount(equipment, amount)
	local data, index = self:equipment_data_by_name(equipment)

	if data then
		local new_amount = amount
		data.amount = Application:digest_value(new_amount, true)

		managers.hud:set_item_amount(index, new_amount)
	end
end

-- Lines 2866-2873
function PlayerManager:equipment_data_by_name(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return equipments, i
		end
	end

	return nil
end

-- Lines 2875-2882
function PlayerManager:get_equipment_amount(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return Application:digest_value(equipments.amount, false)
		end
	end

	return 0
end

-- Lines 2884-2891
function PlayerManager:has_equipment(equipment)
	for i, equipments in ipairs(self._equipment.selections) do
		if equipments.equipment == equipment then
			return true
		end
	end

	return false
end

-- Lines 2893-2895
function PlayerManager:has_deployable_left(equipment)
	return self:get_equipment_amount(equipment) > 0
end

-- Lines 2897-2902
function PlayerManager:select_next_item()
	if not self._equipment.selected_index then
		return
	end

	self._equipment.selected_index = self._equipment.selected_index + 1 <= #self._equipment.selections and self._equipment.selected_index + 1 or 1
end

-- Lines 2904-2909
function PlayerManager:select_previous_item()
	if not self._equipment.selected_index then
		return
	end

	self._equipment.selected_index = self._equipment.selected_index - 1 >= 1 and self._equipment.selected_index - 1 or #self._equipment.selections
end

-- Lines 2911-2918
function PlayerManager:clear_equipment()
	for i, equipment in ipairs(self._equipment.selections) do
		equipment.amount = Application:digest_value(0, true)

		managers.hud:set_item_amount(i, 0)
		self:update_deployable_equipment_amount_to_peers(equipment.equipment, 0)
	end
end

-- Lines 2920-2945
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

	managers.hud:set_item_amount(self._equipment.selected_index, new_amount)
	self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
end

-- Lines 2947-2953
function PlayerManager:can_use_selected_equipment(unit)
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount, false) == 0 then
		return false
	end

	return true
end

-- Lines 2955-2961
function PlayerManager:selected_equipment()
	local equipment = self._equipment.selections[self._equipment.selected_index]

	if not equipment or Application:digest_value(equipment.amount, false) == 0 then
		return nil
	end

	return equipment
end

-- Lines 2963-2969
function PlayerManager:selected_equipment_id()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return nil
	end

	return equipment_data.equipment
end

-- Lines 2971-2977
function PlayerManager:selected_equipment_name()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return ""
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].text_id or "")
end

-- Lines 2979-2985
function PlayerManager:selected_equipment_limit_movement()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].limit_movement or false
end

-- Lines 2987-2993
function PlayerManager:selected_equipment_deploying_text()
	local equipment_data = self:selected_equipment()

	if not equipment_data or not tweak_data.equipments[equipment_data.equipment].deploying_text_id then
		return false
	end

	return managers.localization:text(tweak_data.equipments[equipment_data.equipment].deploying_text_id)
end

-- Lines 2995-3001
function PlayerManager:selected_equipment_sound_start()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_start or false
end

-- Lines 3003-3009
function PlayerManager:selected_equipment_sound_interupt()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_interupt or false
end

-- Lines 3011-3017
function PlayerManager:selected_equipment_sound_done()
	local equipment_data = self:selected_equipment()

	if not equipment_data then
		return false
	end

	return tweak_data.equipments[equipment_data.equipment].sound_done or false
end

-- Lines 3020-3044
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

-- Lines 3046-3061
function PlayerManager:check_selected_equipment_placement_valid(player)
	local equipment_data = managers.player:selected_equipment()

	if not equipment_data then
		return false
	end

	if equipment_data.equipment == "trip_mine" or equipment_data.equipment == "ecm_jammer" then
		return player:equipment():valid_look_at_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
	elseif equipment_data.equipment == "sentry_gun" or equipment_data.equipment == "ammo_bag" or equipment_data.equipment == "doctor_bag" or equipment_data.equipment == "first_aid_kit" then
		return player:equipment():valid_shape_placement(equipment_data.equipment, tweak_data.equipments[equipment_data.equipment]) and true or false
	end

	return player:equipment():valid_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
end

-- Lines 3063-3075
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

-- Lines 3077-3086
function PlayerManager:remove_equipment(equipment_id)
	local equipment, index = self:equipment_data_by_name(equipment_id)
	local new_amount = Application:digest_value(equipment.amount, false) - 1
	equipment.amount = Application:digest_value(new_amount, true)
	local equipments_available = self._global.equipment or {}

	managers.hud:set_item_amount(index, new_amount)
	self:update_deployable_equipment_amount_to_peers(equipment.equipment, new_amount)
end

-- Lines 3088-3110
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

-- Lines 3112-3123
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

-- Lines 3125-3136
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

-- Lines 3138-3199
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
		local icon = equipment.icon
		local interact_data = {
			id = "equipment_obtained_" .. name,
			title = utf8.to_upper(managers.localization:text("hud_hint_obtained_equipment_title", {
				EQUIPMENT = text
			})),
			icon = icon,
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

-- Lines 3201-3204
function PlayerManager:_show_special_equipment_obtained_message(interact_data)
	managers.hud:set_big_prompt(interact_data)
end

-- Lines 3206-3215
function PlayerManager:_equipped_upgrade_value(equipment)
	if not equipment.extra_quantity then
		return 0
	end

	local equipped_upgrade = equipment.extra_quantity.equipped_upgrade
	local category = equipment.extra_quantity.category
	local upgrade = equipment.extra_quantity.upgrade

	return self:equipped_upgrade_value(equipped_upgrade, category, upgrade)
end

-- Lines 3217-3231
function PlayerManager:has_special_equipment(name)
	local equipment = tweak_data.equipments.specials[name]

	return self._equipment.specials[name]
end

-- Lines 3233-3240
function PlayerManager:_can_pickup_special_equipment(special_equipment, name)
	if special_equipment.amount then
		local equipment = tweak_data.equipments.specials[name]
		local extra = self:_equipped_upgrade_value(equipment)

		return Application:digest_value(special_equipment.amount, false) < (equipment.max_quantity or equipment.quantity or 1) + extra, not not equipment.max_quantity
	end

	return false
end

-- Lines 3242-3261
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

-- Lines 3263-3267
function PlayerManager:remove_all_specials()
	for key, value in pairs(self._equipment.specials) do
		self:remove_special(key, true)
	end
end

-- Lines 3269-3313
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

-- Lines 3320-3331
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

-- Lines 3333-3352
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

-- Lines 3354-3357
function PlayerManager:refill_grenades(amount)
	local fill_amount = amount or self:get_max_grenades()

	self:add_grenade_amount(fill_amount)
end

-- Lines 3359-3366
function PlayerManager:update_grenades_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_grenades[peer_id] then
		local grenade = self._global.synced_grenades[peer_id].grenade
		local amount = self._global.synced_grenades[peer_id].amount

		peer:send_queued_sync("sync_grenades", grenade, Application:digest_value(amount, false))
	end
end

-- Lines 3368-3372
function PlayerManager:update_grenades_amount_to_peers(grenade, amount)
	local peer_id = managers.network:session():local_peer():id()

	managers.network:session():send_to_peers_synched("sync_grenades", grenade, amount)
	self:set_synced_grenades(peer_id, grenade, amount)
end

-- Lines 3374-3393
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

-- Lines 3395-3401
function PlayerManager:get_grenade_amount(peer_id)
	if self._global.synced_grenades[peer_id] then
		return Application:digest_value(self._global.synced_grenades[peer_id].amount, false)
	end

	return 0
end

-- Lines 3403-3407
function PlayerManager:get_grenade_amount_missing(peer_id)
	local gren_has = self:get_grenade_amount(peer_id)
	local gren_max = self:get_max_grenades_by_peer_id(peer_id)

	return gren_max - gren_has
end

-- Lines 3409-3411
function PlayerManager:get_synced_grenades(peer_id)
	return self._global.synced_grenades[peer_id]
end

-- Lines 3413-3416
function PlayerManager:can_throw_grenade()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_grenade_amount(peer_id) > 0
end

-- Lines 3418-3421
function PlayerManager:get_max_grenades_by_peer_id(peer_id)
	local peer = managers.network:session() and managers.network:session():peer(peer_id)

	return peer and self:get_max_grenades(peer:grenade_id()) or 0
end

-- Lines 3423-3434
function PlayerManager:get_max_grenades(grenade_id)
	grenade_id = grenade_id or managers.blackmarket:equipped_grenade()
	local projectile_tweak = tweak_data.projectiles[grenade_id]
	local upgrade = projectile_tweak and projectile_tweak.upgrade_amount
	local upgrade_amount = 0

	if upgrade then
		upgrade_amount = self:upgrade_value(upgrade.category, upgrade.upgrade, 0)
	end

	return projectile_tweak and (projectile_tweak.max_amount or 0) + upgrade_amount
end

-- Lines 3436-3440
function PlayerManager:got_max_grenades()
	local peer_id = managers.network:session():local_peer():id()

	return self:get_max_grenades_by_peer_id(peer_id) <= self:get_grenade_amount(peer_id)
end

-- Lines 3442-3446
function PlayerManager:has_grenade(peer_id)
	peer_id = peer_id or managers.network:session():local_peer():id()
	local synced_grenade = self:get_synced_grenades(peer_id)

	return synced_grenade and synced_grenade.grenade and true or false
end

-- Lines 3448-3456
function PlayerManager:on_throw_grenade()
	self:add_grenade_amount(-1)
end

-- Lines 3460-3495
function PlayerManager:add_carry(carry_id, carry_multiplier)
	local carry_tweak = tweak_data.carry[carry_id]

	if not carry_tweak then
		debug_pause("[PlayerManager:add_carry] NO TWEAKDATA", carry_id, carry_multiplier)

		return
	end

	local title = managers.localization:text("hud_carrying_announcement_title")
	local type_text = carry_tweak.name_id and managers.localization:text(carry_tweak.name_id)
	local text = managers.localization:text("hud_carrying_announcement", {
		CARRY_TYPE = type_text
	})
	local icon = nil
	local weight = carry_tweak.weight

	if carry_tweak.cannot_stack then
		weight = self:get_my_carry_weight_limit()
	end

	if carry_tweak.upgrade_weight_multiplier then
		local multiplier = carry_tweak.upgrade_weight_multiplier
		weight = weight * self:upgrade_value(multiplier.category, multiplier.upgrade, 1)
	end

	self:update_synced_carry_to_peers(carry_id, carry_multiplier or 1)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, nil, carry_id)
	managers.hud:show_carry_item(carry_id)
	self:modify_local_peer_carry_weight(weight or tweak_data.carry.default_bag_weight)
	self:refresh_carry_elements()
end

-- Lines 3497-3517
function PlayerManager:remove_carry_id(carry_id)
	if self:is_carrying() then
		local my_carry_data = self:get_my_carry_data()
		local carry_index = 1
		local t = type(carry_id)

		if t == "table" then
			for _, lists_carry_id in ipairs(carry_id) do
				local i = self.get_index_carry_id(my_carry_data, lists_carry_id)

				if i then
					carry_index = i

					break
				end
			end
		elseif t == "string" then
			carry_index = self.get_index_carry_id(my_carry_data, carry_id)
		end

		Application:debug("[PlayerManager:remove_carry_id] carry_id:", carry_id, inspect(my_carry_data))
		self:remove_carry(carry_index)
	end
end

-- Lines 3519-3567
function PlayerManager:remove_carry(carry_index)
	Application:debug("[PlayerManager:remove_carry] carry_index:", carry_index)

	if not carry_index then
		debug_pause("[PlayerManager:remove_carry] Tried to use nil index!")

		return
	end

	local carry_data = self:get_my_carry_data()
	local carry_id = carry_data[carry_index].carry_id

	if carry_index > #carry_data then
		Application:error("[PlayerManager:remove_carry] Tried to use an index that was too high!", carry_index, "/", #carry_data)

		return
	end

	local carry_tweak = tweak_data.carry[carry_id]

	if not carry_tweak then
		debug_pause("[PlayerManager:add_carry] NO TWEAKDATA", carry_id, carry_multiplier)

		return
	end

	if carry_id then
		self:update_removed_synced_carry_to_peers(carry_id)
	else
		Application:error("[PlayerManager:remove_carry] Tried to remove a nil carry item! (That would remove the whole carry inventory)")
	end

	local weight = carry_tweak.weight or tweak_data.carry.default_bag_weight

	if carry_tweak.upgrade_weight_multiplier then
		local multiplier = carry_tweak.upgrade_weight_multiplier
		weight = weight * self:upgrade_value(multiplier.category, multiplier.upgrade, 1)
	end

	self:_update_carry_wheel()

	if not self:is_carrying() then
		managers.hud:hide_carry_item()
		managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
		self:reset_local_peer_carry_weight()
	else
		self:modify_local_peer_carry_weight(-weight)
	end
end

-- Lines 3569-3578
function PlayerManager:bank_carry()
	local carry_data = self:get_my_carry_data()

	if carry_data then
		local index = 1
		local carry_item = carry_data[index]
		local silent = false

		managers.loot:secure(carry_item.carry_id, carry_item.multiplier, silent)
		self:remove_carry(index)
	end
end

-- Lines 3581-3584
function PlayerManager:refresh_carry_elements()
	self:_update_carry_wheel()
	managers.hud:set_carry_weight(self:get_my_carry_weight_ratio(), self:is_carrying_over_full(true))
end

-- Lines 3586-3621
function PlayerManager:_update_carry_wheel()
	local carry_data = self:get_my_carry_data()
	local carry_max = self:get_my_carry_weight_limit()
	local options = deep_clone(tweak_data.interaction.carry_wheel.options)
	local i = 1

	while carry_max >= i do
		local option = {
			icon = "comm_wheel_no",
			disabled = true,
			text_id = "",
			id = "carry_" .. i
		}

		if carry_data and carry_data[i] then
			local carry_tweak = tweak_data.carry[carry_data[i].carry_id]
			local weight = carry_tweak.weight or tweak_data.carry.default_bag_weight

			if carry_tweak.upgrade_weight_multiplier then
				local multiplier = carry_tweak.upgrade_weight_multiplier
				weight = weight * self:upgrade_value(multiplier.category, multiplier.upgrade, 1)
			end

			option.text_id = carry_tweak.name_id
			option.icon = carry_tweak.hud_icon or tweak_data.carry.default_bag_icon
			option.multiplier = weight
			option.clbk = callback(self, self, "drop_carry")
			option.clbk_data = {
				carry_data[i].carry_id
			}
			option.disabled = nil
			carry_max = carry_max - (weight - 1)
		end

		table.insert(options, option)

		i = i + 1
	end

	managers.hud:set_carry_wheel_options(options)
end

-- Lines 3625-3632
function PlayerManager.get_index_carry_id(carry_data, carry_id)
	for i, item_data in ipairs(carry_data) do
		if item_data.carry_id == carry_id then
			return i
		end
	end

	return nil
end

-- Lines 3638-3734
function PlayerManager:drop_carry(carry_id, zipline_unit, skip_cooldown)
	Application:debug("[PlayerManager:drop_carry]", carry_id, "- Zipline Unit:", zipline_unit)

	if self:carry_blocked_by_cooldown() or self:current_state() == "bleed_out" or self:current_state() == "fatal" then
		Application:warn("[PlayerManager:drop_carry] In a state that prevents dropping!", self:current_state(), "cooldown", self:carry_blocked_by_cooldown())

		return
	end

	if not self:is_carrying() then
		Application:warn("[PlayerManager:drop_carry] Not carrying anything!")

		return
	end

	local carry_data = self:get_my_carry_data()
	local drop_carry_index = 1

	if carry_id ~= nil then
		drop_carry_index = self.get_index_carry_id(carry_data, carry_id)
	end

	local drop_carry_item = carry_data[drop_carry_index]

	if not drop_carry_index or not drop_carry_item then
		Application:error("[PlayerManager:drop_carry] Could not drop carry item index '" .. tostring(drop_carry_index) .. "'")

		return
	end

	local carry_tweak = tweak_data.carry[drop_carry_item.carry_id]
	local carry_needs_headroom = carry_tweak.needs_headroom_to_drop
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

	if not skip_cooldown then
		self._carry_blocked_cooldown_t = Application:time() + tweak_data.carry.default_bag_delay
	end

	local player = self:player_unit()

	if player and carry_tweak and carry_tweak.throw_sound then
		player:sound():play(carry_tweak.throw_sound, nil, false)
	end

	local camera_ext = player:camera()
	local position, rotation = self:carry_align_throw()

	if carry_tweak and carry_tweak.throw_rotations then
		rotation = Rotation(rotation:yaw() + carry_tweak.throw_rotations:yaw(), rotation:pitch() + carry_tweak.throw_rotations:pitch(), rotation:roll() + carry_tweak.throw_rotations:roll())
	end

	if carry_needs_headroom then
		position = position - Vector3(0, 0, 70)
		rotation = Rotation(math.mod(camera_ext:rotation():yaw() + 180, 360), 9, 0)
	end

	local throw_distance_multiplier_upgrade_level = 0

	if carry_tweak and carry_tweak.upgrade_throw_multiplier then
		local throw_multiplier = carry_tweak.upgrade_throw_multiplier
		throw_distance_multiplier_upgrade_level = self:upgrade_level(throw_multiplier.category, throw_multiplier.upgrade, 0)
	end

	local direction = (player:camera():forward() + Vector3(0, 0, 0.33)):normalized()

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", drop_carry_item.carry_id, drop_carry_item.multiplier, position, rotation, direction, throw_distance_multiplier_upgrade_level, zipline_unit)
	else
		self:server_drop_carry(drop_carry_item.carry_id, drop_carry_item.multiplier, position, rotation, direction, throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer())
	end

	self:remove_carry(drop_carry_index)
end

-- Lines 3737-3744
function PlayerManager:drop_all_carry()
	local carry_data = deep_clone(self:get_my_carry_data())

	if carry_data then
		for i, carry_item in ipairs(carry_data) do
			self:drop_carry(carry_item.carry_id, nil, true)
		end
	end
end

-- Lines 3746-3752
function PlayerManager:carry_align_throw()
	local camera_ext = self:player_unit():camera()
	local pos = mvector3.copy(camera_ext:position())
	local rot = camera_ext:rotation()
	pos = pos:with_z(pos.z - 28)
	rot = Rotation(rot:yaw(), rot:pitch(), 0)

	return pos, rot
end

-- Lines 3756-3815
function PlayerManager:server_drop_carry(carry_id, carry_multiplier, position, rotation, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer)
	local tweak = tweak_data.carry[carry_id]
	local unit_idstr = Idstring(tweak.unit or tweak_data.carry.default_lootbag)
	local unit = World:spawn_unit(unit_idstr, position, rotation)
	local world = managers.worldcollection:get_world_from_pos(position)

	if world then
		world:register_spawned_unit(unit)
	else
		Application:warn("[PlayerManager:server_drop_carry] Could not get a world for carry item")
	end

	if tweak.is_corpse then
		managers.enemy:add_corpse_lootbag(unit)
	end

	local peer_id = peer and peer:id() or 0

	managers.network:session():send_to_peers_synched("sync_carry_data", unit, carry_id, carry_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	self:sync_carry_data(unit, carry_id, carry_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)

	return unit
end

-- Lines 3817-3846
function PlayerManager:sync_carry_data(unit, carry_id, carry_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	local throw_multiplier = tweak_data.carry[carry_id].upgrade_throw_multiplier
	local throw_distance_multiplier = 1

	if throw_multiplier then
		throw_distance_multiplier = self:upgrade_value_by_level(throw_multiplier.category, throw_multiplier.upgrade, throw_distance_multiplier_upgrade_level, 1)
	end

	local carry_type = tweak_data.carry[carry_id].type
	local ratio = self:get_my_carry_weight_ratio()
	local carry_throw_distance_multiplier = tweak_data.carry:get_type_value_weighted(carry_type, "throw_distance_multiplier", ratio)
	throw_distance_multiplier = carry_throw_distance_multiplier * throw_distance_multiplier

	unit:carry_data():set_carry_id(carry_id)
	unit:carry_data():set_multiplier(carry_multiplier)
	unit:carry_data():set_value(0)
	unit:carry_data():set_latest_peer_id(peer_id)
	unit:carry_data():on_thrown()

	if alive(zipline_unit) then
		zipline_unit:zipline():attach_bag(unit)
	else
		local throw_power = tweak_data.carry[carry_id].throw_power or tweak_data.carry.default_throw_power

		unit:push(100, dir * throw_power * throw_distance_multiplier)
	end

	unit:interaction():register_collision_callbacks()
end

-- Lines 3849-3893
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

	local camera_ext = player:camera()

	-- Lines 3863-3863
	local function rand_dir()
		return Vector3(math.random(-2, 2), math.random(-2, 2), math.random(0, 3)):normalized()
	end

	-- Lines 3864-3864
	local function rand_rot()
		return Rotation(math.random(), math.random(), 0)
	end

	for i, carry_item in ipairs(carry_data) do
		if Network:is_client() then
			managers.network:session():send_to_host("server_drop_carry", carry_item.carry_id, carry_item.multiplier, camera_ext:position(), rand_rot(), rand_dir(), 0, nil)
		else
			self:server_drop_carry(carry_item.carry_id, carry_item.multiplier, camera_ext:position(), rand_rot(), rand_dir(), 0, nil, managers.network:session():local_peer())
		end
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:hide_carry_item()
	self:update_removed_all_synced_carry_to_peers()
end

-- Lines 3897-3900
function PlayerManager:set_carry_temporary_data(carry_id, data)
	self._temporary_carry_data = self._temporary_carry_data or {}
	self._temporary_carry_data[carry_id] = data
end

-- Lines 3904-3909
function PlayerManager:carry_temporary_data(carry_id)
	if self._temporary_carry_data then
		return self._temporary_carry_data[carry_id]
	end

	return nil
end

-- Lines 3913-3917
function PlayerManager:clear_carry_temporary_data(carry_id)
	if self._temporary_carry_data then
		self._temporary_carry_data[carry_id] = nil
	end
end

-- Lines 3919-3942
function PlayerManager:clear_carry(soft_reset)
	local player = self:player_unit()

	if not soft_reset and not alive(player) then
		Application:warn("[PlayerManager:clear_carry] COULDN'T FORCE DROP! DIDN'T HAVE A PLAYER UNIT!")

		return
	end

	if self:is_carrying() then
		Application:debug("[PlayerManager:clear_carry] Clearing carry data...")
		managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
		managers.hud:hide_carry_item()

		self._temporary_carry_data = {}

		self:reset_local_peer_carry_weight()
		self:update_removed_all_synced_carry_to_peers()

		if self._current_state == "carry" or self._current_state == "carry_corpse" then
			self:set_player_state("standard")
		end
	end
end

-- Lines 3944-3947
function PlayerManager:is_perseverating()
	local player_unit = self:player_unit()

	return alive(player_unit) and player_unit:character_damage() and player_unit:character_damage():is_perseverating() or false
end

-- Lines 3949-3952
function PlayerManager:get_current_state()
	local player = self:player_unit()

	return alive(player) and player:movement():current_state()
end

-- Lines 3956-3962
function PlayerManager:is_carrying()
	local cd = self:get_my_carry_data()

	if cd and not table.empty(cd) then
		return true
	end

	return false
end

-- Lines 3967-3977
function PlayerManager:is_carrying_cannot_stack()
	if self:is_carrying() then
		local carry_data = self:get_my_carry_data()

		for _, carry_item in ipairs(carry_data) do
			if tweak_data.carry[carry_item.carry_id].cannot_stack then
				return true
			end
		end
	end

	return false
end

-- Lines 3982-3992
function PlayerManager:is_carrying_corpse()
	if self:is_carrying() then
		local carry_data = self:get_my_carry_data()

		for _, carry_item in ipairs(carry_data) do
			if tweak_data.carry[carry_item.carry_id].is_corpse then
				return true
			end
		end
	end

	return false
end

-- Lines 3996-4017
function PlayerManager:is_carrying_carry_id(carry_id)
	if self:is_carrying() then
		local my_carry_data = self:get_my_carry_data()
		local t = type(carry_id)

		if t == "table" then
			for _, lists_carry_id in ipairs(carry_id) do
				for _, my_carry_item in ipairs(my_carry_data) do
					if my_carry_item.carry_id == lists_carry_id then
						return true
					end
				end
			end
		elseif t == "string" then
			for _, carry_item in ipairs(my_carry_data) do
				if carry_item.carry_id == carry_id then
					return true
				end
			end
		end
	end

	return false
end

-- Lines 4021-4023
function PlayerManager:carry_blocked_by_cooldown()
	return self._carry_blocked_cooldown_t and Application:time() < self._carry_blocked_cooldown_t or false
end

-- Lines 4027-4052
function PlayerManager:local_can_carry(carry_id)
	if not self:is_carrying() then
		return true
	end

	if self._current_state == "carry_corpse" then
		return false
	end

	if not self:local_can_carry_weight(carry_id) then
		return false
	end

	if self:is_carrying() then
		local my_carry_data = self:get_my_carry_data()

		if tweak_data.carry[carry_id].cannot_stack or tweak_data.carry[carry_id].is_corpse or tweak_data.carry[my_carry_data[1].carry_id].cannot_stack or tweak_data.carry[my_carry_data[1].carry_id].is_corpse then
			return false
		end
	end

	return true
end

-- Lines 4056-4058
function PlayerManager:count_up_player_minions()
	self._local_player_minions = math.min(self._local_player_minions + 1, self:upgrade_value("player", "convert_enemies_max_minions", 0))
end

-- Lines 4060-4062
function PlayerManager:count_down_player_minions()
	self._local_player_minions = math.max(self._local_player_minions - 1, 0)
end

-- Lines 4064-4066
function PlayerManager:reset_minions()
	self._local_player_minions = 0
end

-- Lines 4068-4070
function PlayerManager:num_local_minions()
	return self._local_player_minions
end

-- Lines 4072-4074
function PlayerManager:chk_minion_limit_reached()
	return self:upgrade_value("player", "convert_enemies_max_minions", 0) <= self._local_player_minions
end

-- Lines 4078-4084
function PlayerManager:change_player_look(new_look)
	self._player_mesh_suffix = new_look

	for _, unit in pairs(managers.groupai:state():all_char_criminals()) do
		unit.unit:movement():set_character_anim_variables()
	end
end

-- Lines 4088-4090
function PlayerManager:player_timer()
	return self._player_timer
end

-- Lines 4094-4102
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

-- Lines 4104-4111
function PlayerManager:report_weapon_ammo_gains()
	if Application:production_build() then
		self._debug_weapon_ammo_gains = self._debug_weapon_ammo_gains or {}

		for name_id, data in pairs(self._debug_weapon_ammo_gains) do
			print("WEAPON: " .. tostring(name_id), "AVERAGE AMMO PICKUP: " .. string.format("%3.2f%%", data.total / data.index * 100))
		end
	end
end

-- Lines 4113-4115
function PlayerManager:set_content_update_viewed(content_update)
	self._global.viewed_content_updates[content_update] = true
end

-- Lines 4117-4119
function PlayerManager:get_content_update_viewed(content_update)
	return self._global.viewed_content_updates[content_update] or false
end

-- Lines 4121-4134
function PlayerManager:_verify_loaded_data()
	local id = self._global.kit.equipment_slots[1]

	if id and not self._global.equipment[id] then
		print("PlayerManager:_verify_loaded_data()", inspect(self._global.equipment))

		self._global.kit.equipment_slots[1] = nil

		self:_verify_equipment_kit(true)
	end

	managers.savefile:remove_load_done_callback(self._verify_load_callback)

	self._verify_load_callback = nil
end

-- Lines 4139-4146
function PlayerManager:update_husk_bipod_to_peer(peer)
	local peer_id = managers.network:session():local_peer():id()

	if self._global.synced_bipod[peer_id] then
		local bipod_pos = self._global.synced_bipod[peer_id].bipod_pos
		local body_pos = self._global.synced_bipod[peer_id].body_pos

		peer:send_queued_sync("sync_bipod", bipod_pos, body_pos)
	end
end

-- Lines 4148-4152
function PlayerManager:set_husk_bipod_data(data)
	self._global.synced_bipod = data
end

-- Lines 4154-4160
function PlayerManager:set_bipod_data_for_peer(data)
	if not self._global.synced_bipod then
		self._global.synced_bipod = {}
	end

	self._global.synced_bipod[data.peer_id] = {
		bipod_pos = data.bipod_pos,
		body_pos = data.body_pos
	}
end

-- Lines 4162-4164
function PlayerManager:get_bipod_data_for_peer(peer_id)
	return self._global.synced_bipod[peer_id]
end

-- Lines 4166-4169
function PlayerManager:set_synced_bipod(peer, bipod_pos, body_pos)
	local peer_id = peer:id()
	self._global.synced_bipod[peer_id] = {
		bipod_pos = bipod_pos,
		body_pos = body_pos
	}
end

-- Lines 4174-4184
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

-- Lines 4186-4188
function PlayerManager:set_husk_turret_data(data)
	self._global.synced_turret = data
end

-- Lines 4190-4195
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

-- Lines 4197-4199
function PlayerManager:get_turret_data_for_peer(peer_id)
	return self._global.synced_turret[peer_id]
end

-- Lines 4201-4204
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

-- Lines 4209-4221
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
end

-- Lines 4225-4241
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

-- Lines 4243-4245
function PlayerManager:sync_enter_vehicle(vehicle, peer_id, player, seat_name)
	self:_enter_vehicle(vehicle, peer_id, player, seat_name)
end

-- Lines 4248-4265
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
end

-- Lines 4267-4275
function PlayerManager:get_vehicle()
	if managers.network:session() then
		local peer_id = managers.network:session():local_peer():id()
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

-- Lines 4277-4284
function PlayerManager:get_vehicle_for_peer(peer_id)
	if managers.network:session() then
		local vehicle = self._global.synced_vehicle_data[peer_id]

		return vehicle
	else
		return nil
	end
end

-- Lines 4286-4297
function PlayerManager:exit_vehicle()
	local peer_id = managers.network:session():local_peer():id()
	local vehicle_data = self._global.synced_vehicle_data[peer_id]

	if vehicle_data == nil then
		return
	end

	local player = self:local_player()

	managers.network:session():send_to_peers_synched("sync_vehicle_player", "exit", nil, peer_id, player, nil, nil)
	self:_exit_vehicle(peer_id, player)
end

-- Lines 4299-4301
function PlayerManager:sync_exit_vehicle(peer_id, player)
	self:_exit_vehicle(peer_id, player)
end

-- Lines 4303-4323
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

-- Lines 4325-4347
function PlayerManager:move_to_next_seat(vehicle)
	local vehicle_ext = vehicle:vehicle_driving()

	if not vehicle_ext then
		return
	end

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

-- Lines 4349-4373
function PlayerManager:server_move_to_next_seat(vehicle, peer_id, player, seat_name)
	local vehicle_ext = vehicle:vehicle_driving()

	if not vehicle_ext then
		return
	end

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

-- Lines 4375-4380
function PlayerManager:sync_move_to_next_seat(vehicle, peer_id, player, seat_name, previous_seat_name, previous_occupant)
	local vehicle_ext = vehicle:vehicle_driving()
	local seat = vehicle_ext._seats[seat_name]
	local previous_seat = previous_seat_name and vehicle_ext._seats[previous_seat_name] or nil

	self:_move_to_next_seat(vehicle, peer_id, player, seat, previous_seat, previous_occupant)
end

-- Lines 4383-4405
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
end

-- Lines 4407-4410
function PlayerManager:disable_view_movement()
	self:player_unit():camera():camera_unit():base():set_limits(0.01, 0.01)

	self._view_disabled = true
end

-- Lines 4412-4418
function PlayerManager:enable_view_movement()
	local player_unit = self:player_unit()

	if player_unit and alive(player_unit) then
		player_unit:camera():camera_unit():base():remove_limits()

		self._view_disabled = false
	end
end

-- Lines 4420-4422
function PlayerManager:is_view_disabled()
	return self._view_disabled
end

-- Lines 4426-4428
function PlayerManager:use_turret(turret_unit)
	self._turret_unit = turret_unit
end

-- Lines 4430-4432
function PlayerManager:leave_turret()
	self._turret_unit = nil
end

-- Lines 4435-4437
function PlayerManager:get_turret_unit()
	return self._turret_unit
end

-- Lines 4442-4451
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

-- Lines 4453-4461
function PlayerManager:debug_print_player_status()
	local count = 0

	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		print("Player: ", i, ", health: ", p.health, " , unit: ", p.unit)

		count = count + 1
	end

	print("num players: ", count)
end

-- Lines 4463-4471
function PlayerManager:remove_from_player_list(unit)
	for i in pairs(self._player_list) do
		local p = self._player_list[i]

		if p.unit == unit then
			table.remove(self._player_list, i)

			return
		end
	end
end

-- Lines 4473-4480
function PlayerManager:add_ammo_to_weapons(ammo)
	local player = self:local_player()

	if not alive(player) then
		return
	end

	player:inventory():add_ammo(ammo)
end

-- Lines 4482-4489
function PlayerManager:add_ammo_to_equipped_weapon(ratio, ammo)
	local player = self:local_player()

	if not alive(player) then
		return
	end

	return player:inventory():add_ammo_to_equipped(ratio, ammo)
end

-- Lines 4491-4498
function PlayerManager:equipped_weapon_index()
	local player = self:local_player()

	if not alive(player) then
		return 1
	end

	return player:inventory():equipped_selection()
end

-- Lines 4500-4507
function PlayerManager:equipped_weapon_unit()
	local player = self:local_player()

	if not alive(player) then
		return
	end

	return player:inventory():equipped_unit()
end

-- Lines 4510-4542
function PlayerManager:kill()
	local player = self:player_unit()

	if not alive(player) then
		return
	end

	managers.player:force_drop_carry()
	managers.vehicle:remove_player_from_all_vehicles(player)
	managers.statistics:downed({
		death = true
	})
	IngameFatalState.on_local_player_dead()
	managers.warcry:deactivate_warcry(true)
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
	managers.groupai:state():on_player_criminal_death(managers.network:session():local_peer():id())
	player:base():_unregister()
	player:base():set_slot(player, 0)
	World:delete_unit(player)
end

-- Lines 4544-4546
function PlayerManager:get_death_location_rotation()
	return self._player_death_position, self._player_death_rotation
end

-- Lines 4548-4552
function PlayerManager:set_death_location_rotation(p, r)
	Application:debug("[PlayerManager:set_death_location_rotation]", p, r)

	self._player_death_position = p
	self._player_death_rotation = r
end

-- Lines 4554-4559
function PlayerManager:destroy()
	local player = self:player_unit()

	player:base():_unregister()
	player:base():set_slot(player, 0)
end

-- Lines 4561-4584
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

-- Lines 4586-4592
function PlayerManager:replenish_player()
	local player = self:local_player()

	if alive(player) and player:character_damage() then
		player:character_damage():replenish()
	end
end

-- Lines 4594-4610
function PlayerManager:replenish_player_weapons()
	local player = self:local_player()

	if alive(player) and player:inventory() and player:inventory():available_selections() then
		for id, weapon in pairs(player:inventory():available_selections()) do
			if alive(weapon.unit) and weapon.unit:base():uses_ammo() then
				weapon.unit:base():replenish()
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end

		local name, amount = managers.blackmarket:equipped_grenade()

		self:add_grenade_amount(amount)
		managers.hud:hide_prompt("hud_reload_prompt")
		managers.hud:hide_prompt("hud_no_ammo_prompt")
	end
end

-- Lines 4612-4618
function PlayerManager:stop_all_speaking_except_dialog()
	local local_player = self:player_unit()

	local_player:sound():stop_speaking()
end

-- Lines 4620-4640
function PlayerManager:set_local_player_in_camp(value)
	self._local_player_in_camp = value

	self:_on_camp_presence_changed()

	if Global.game_settings.single_player then
		managers.platform:set_rich_presence("SPPlaying")
	elseif not value then
		managers.platform:set_rich_presence("MPPlaying")
	else
		managers.platform:set_rich_presence("MPLobby")
	end

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CAMP_PRESENCE_CHANGED)
end

-- Lines 4642-4644
function PlayerManager:local_player_in_camp()
	return self._local_player_in_camp
end

-- Lines 4646-4662
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

-- Lines 4669-4677
function PlayerManager:tutorial_make_invulnerable()
	managers.raid_job:revert_temp_play_flag()

	local player = managers.player:local_player()

	if not player then
		return
	end

	player:character_damage():set_invulnerable(true)
end

-- Lines 4679-4686
function PlayerManager:tutorial_set_health(value)
	local player = managers.player:local_player()

	if not player then
		return
	end

	player:character_damage():set_invulnerable(false)
	player:character_damage():set_health(value)
end

-- Lines 4689-4706
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

-- Lines 4708-4719
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

-- Lines 4721-4729
function PlayerManager:tutorial_set_ammo(value)
	local player = managers.player:local_player()

	if not player then
		return
	end

	player:inventory():set_ammo_with_empty_clip(value)
	self:add_grenade_amount(3)
end

-- Lines 4732-4740
function PlayerManager:tutorial_remove_AI()
	local player = managers.player:local_player()

	if not player then
		return
	end

	Global.game_settings.team_ai = false

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()

	Global.game_settings.team_ai = true
end

-- Lines 4743-4752
function PlayerManager:tutorial_prompt_jump()
	local text = utf8.to_upper(managers.localization:text("hud_hint_tutorial_jump", {
		BTN_JUMP = managers.localization:btn_macro("jump")
	}))

	managers.hud:set_big_prompt({
		duration = 3,
		id = "prompt_hint_tutorial_jump",
		text = text
	})
end

-- Lines 4755-4764
function PlayerManager:tutorial_prompt_duck()
	local text = utf8.to_upper(managers.localization:text("hud_hint_tutorial_crouch", {
		BTN_CROUCH = managers.localization:btn_macro("duck")
	}))

	managers.hud:set_big_prompt({
		duration = 3,
		id = "prompt_hint_tutorial_crouch",
		text = text
	})
end

-- Lines 4767-4776
function PlayerManager:tutorial_prompt_detection()
	local text = utf8.to_upper(managers.localization:text("hud_hint_tutorial_detection", {
		BTN_CROUCH = managers.localization:btn_macro("duck")
	}))

	managers.hud:set_big_prompt({
		duration = 3,
		id = "prompt_hint_tutorial_detection",
		text = text
	})
end

-- Lines 4779-4787
function PlayerManager:tutorial_prompt_ammo()
	local text = utf8.to_upper(managers.localization:text("hud_hint_tutorial_ammo"))

	managers.hud:set_big_prompt({
		duration = 3,
		id = "prompt_hint_tutorial_ammo",
		text = text
	})
end

-- Lines 4790-4799
function PlayerManager:tutorial_prompt_weapons()
	local text = utf8.to_upper(managers.localization:text("hud_hint_tutorial_switch_weapon", {
		BTN_SWITCH_WEAPON = managers.localization:btn_macro("primary_choice2")
	}))

	managers.hud:set_big_prompt({
		duration = 3,
		id = "prompt_hint_tutorial_switch_weapon",
		text = text
	})
end
