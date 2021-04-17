core:import("CoreMissionManager")
core:import("CoreClass")
require("lib/managers/mission/MissionScriptElement")
require("lib/managers/mission/ElementSpawnEnemyGroup")
require("lib/managers/mission/ElementEnemyPrefered")
require("lib/managers/mission/ElementAIGraph")
require("lib/managers/mission/ElementWaypoint")
require("lib/managers/mission/ElementSpawnCivilian")
require("lib/managers/mission/ElementLookAtTrigger")
require("lib/managers/mission/ElementMissionEnd")
require("lib/managers/mission/ElementObjective")
require("lib/managers/mission/ElementDialogue")
require("lib/managers/mission/ElementHint")
require("lib/managers/mission/ElementFleePoint")
require("lib/managers/mission/ElementAiGlobalEvent")
require("lib/managers/mission/ElementEquipment")
require("lib/managers/mission/ElementPlayerState")
require("lib/managers/mission/ElementKillZone")
require("lib/managers/mission/ElementSpecialObjective")
require("lib/managers/mission/ElementSpecialObjectiveTrigger")
require("lib/managers/mission/ElementSpecialObjectiveGroup")
require("lib/managers/mission/ElementDifficulty")
require("lib/managers/mission/ElementBlurZone")
require("lib/managers/mission/ElementAIRemove")
require("lib/managers/mission/ElementTeammateComment")
require("lib/managers/mission/ElementCharacterOutline")
require("lib/managers/mission/ElementWhisperState")
require("lib/managers/mission/ElementAwardAchievment")
require("lib/managers/mission/ElementPointOfNoReturn")
require("lib/managers/mission/ElementFeedback")
require("lib/managers/mission/ElementExplosion")
require("lib/managers/mission/ElementFilter")
require("lib/managers/mission/ElementDisableUnit")
require("lib/managers/mission/ElementEnableUnit")
require("lib/managers/mission/ElementSmokeGrenade")
require("lib/managers/mission/ElementSetOutline")
require("lib/managers/mission/ElementExplosionDamage")
require("lib/managers/mission/ElementBlackscreen")
require("lib/managers/mission/ElementBlackscreenVariant")
require("lib/managers/mission/ElementAccessCamera")
require("lib/managers/mission/ElementAIAttention")
require("lib/managers/mission/ElementAIArea")
require("lib/managers/mission/ElementCarry")
require("lib/managers/mission/ElementLootBag")
require("lib/managers/mission/ElementJobValue")
require("lib/managers/mission/ElementNavObstacle")
require("lib/managers/mission/ElementSpawnDeployable")
require("lib/managers/mission/ElementFleePoint")
require("lib/managers/mission/ElementInstigator")
require("lib/managers/mission/ElementInstigatorRule")
require("lib/managers/mission/ElementPickup")
require("lib/managers/mission/ElementLaserTrigger")
require("lib/managers/mission/ElementSpawnGrenade")
require("lib/managers/mission/ElementSpotter")
require("lib/managers/mission/ElementCharacterTeam")
require("lib/managers/mission/ElementTeamRelation")
require("lib/managers/mission/ElementSlowMotion")
require("lib/managers/mission/ElementInteraction")
require("lib/managers/mission/ElementCharacterSequence")
require("lib/managers/mission/ElementExperience")
require("lib/managers/mission/ElementModifyPlayer")
require("lib/managers/mission/ElementStatistics")
require("lib/managers/mission/ElementStatisticsJobs")
require("lib/managers/mission/ElementGameEventSet")
require("lib/managers/mission/ElementGameEventIsDone")
require("lib/managers/mission/ElementVariableSet")
require("lib/managers/mission/ElementVariableGet")
require("lib/managers/mission/ElementTeamAICommands")
require("lib/managers/mission/ElementEnableSoundEnvironment")
require("lib/managers/mission/ElementAreaMinPoliceForce")
require("lib/managers/mission/ElementTeleportPlayer")
require("lib/managers/mission/ElementSoundSwitch")
require("lib/managers/mission/ElementPlayerSpawner")
require("lib/managers/mission/ElementAreaTrigger")
require("lib/managers/mission/ElementSpawnEnemyDummy")
require("lib/managers/mission/ElementEnemyDummyTrigger")
require("lib/managers/mission/ElementMotionpathMarker")
require("lib/managers/mission/ElementVehicleTrigger")
require("lib/managers/mission/ElementVehicleOperator")
require("lib/managers/mission/ElementVehicleSpawner")
require("lib/managers/mission/ElementWorldOperator")
require("lib/managers/mission/ElementGlobalStateOperator")
require("lib/managers/mission/ElementGlobalStateTrigger")
require("lib/managers/mission/ElementGlobalStateFilter")
require("lib/managers/mission/ElementExecLuaOperator")
require("lib/managers/mission/ElementMetalDetector")
require("lib/managers/mission/ElementDropinState")
require("lib/managers/mission/ElementEnvironmentOperator")
require("lib/managers/mission/ElementEnvironmentEffect")
require("lib/managers/mission/ElementEnvironmentAreaOperator")
require("lib/managers/mission/ElementNavigationStitcher")
require("lib/managers/mission/ElementNavigationStitcherOperator")
require("lib/managers/mission/ElementBarrage")
require("lib/managers/mission/ElementNavLink")
require("lib/managers/mission/ElementDropPoint")
require("lib/managers/mission/ElementDropPointGroup")
require("lib/managers/mission/ElementMapChangeFloor")
require("lib/managers/mission/ElementInvulnerable")
require("lib/managers/mission/ElementCharacterDamage")
require("lib/managers/mission/ElementEscort")

MissionManager = MissionManager or class(CoreMissionManager.MissionManager)

-- Lines 116-147
function MissionManager:init(...)
	MissionManager.super.init(self, ...)
	self:add_area_instigator_categories("player")
	self:add_area_instigator_categories("enemies")
	self:add_area_instigator_categories("civilians")
	self:add_area_instigator_categories("escorts")
	self:add_area_instigator_categories("persons")
	self:add_area_instigator_categories("local_criminals")
	self:add_area_instigator_categories("criminals")
	self:add_area_instigator_categories("ai_teammates")
	self:add_area_instigator_categories("loot")
	self:add_area_instigator_categories("unique_loot")
	self:add_area_instigator_categories("vehicle")
	self:add_area_instigator_categories("npc_vehicle")
	self:add_area_instigator_categories("vehicle_with_players")
	self:add_area_instigator_categories("player_not_in_vehicle")
	self:set_default_area_instigator("player")
	self:set_global_event_list({
		"bankmanager_key",
		"keycard",
		"start_assault",
		"end_assault",
		"police_called",
		"police_weapons_hot",
		"civilian_killed",
		"loot_lost",
		"loot_exploded",
		"pku_flak_shell",
		"pku_gold",
		"pku_money",
		"pku_jewelry",
		"pku_painting",
		"pku_meth",
		"pku_cocaine",
		"pku_weapons",
		"pku_toolbag",
		"pku_atm",
		"pku_folder",
		"pku_poster",
		"pku_artifact_statue",
		"pku_server",
		"pku_samurai",
		"bar_code",
		"equipment_evidence_lost",
		"pku_sandwich",
		"equipment_sandwich",
		"hotel_room_key",
		"pku_evidence_bag",
		"ecm_jammer_on",
		"ecm_jammer_off",
		"pku_warhead",
		"enemy_killed",
		"pku_rambo",
		"tank_destroyed",
		"criminal_detected",
		"pku_contraband_jewelry",
		"repair_tools",
		"safe_keychain",
		"barrage_started",
		"barrage_ended",
		"enigma_part_01",
		"pku_key_01",
		"pku_key_02",
		"pku_key_03",
		"pku_key_04",
		"enigma_part_02",
		"enigma_part_03",
		"enigma_part_04",
		"enigma_part_05",
		"code_book",
		"pku_dogtags",
		"officer_documents_01",
		"officer_documents_02",
		"officer_documents_03",
		"officer_documents_04",
		"officer_documents_05",
		"pku_gold_bar",
		"pku_cigar_crate",
		"pku_wine_crate",
		"pku_thermite",
		"pku_mine",
		"pku_door_key_01",
		"pku_chocolate_box",
		"pku_candelabrum",
		"pku_crucifix",
		"pku_baptismal_font",
		"pku_religious_figurine"
	})

	self._mission_filter = {}

	self:_setup()
end

-- Lines 149-158
function MissionManager:_setup()
	if not Global.mission_manager then
		Global.mission_manager = {
			stage_job_values = {},
			job_values = {},
			saved_job_values = {},
			has_played_tutorial = false
		}
	end
end

-- Lines 160-162
function MissionManager:set_saved_job_value(key, value)
	Global.mission_manager.saved_job_values[key] = value
end

-- Lines 164-166
function MissionManager:get_saved_job_value(key)
	return Global.mission_manager.saved_job_values[key]
end

-- Lines 173-175
function MissionManager:on_reset_profile()
	Global.mission_manager.saved_job_values.playedSafeHouseBefore = nil
end

-- Lines 177-180
function MissionManager:set_job_value(key, value)
	Global.mission_manager.stage_job_values[key] = value
end

-- Lines 182-184
function MissionManager:get_job_value(key)
	return Global.mission_manager.job_values[key] or Global.mission_manager.stage_job_values[key]
end

-- Lines 186-189
function MissionManager:on_job_deactivated()
	Global.mission_manager.job_values = {}
	Global.mission_manager.stage_job_values = {}
end

-- Lines 191-194
function MissionManager:on_restart_to_camp()
	Global.mission_manager.stage_job_values = {}
end

-- Lines 196-202
function MissionManager:on_stage_success()
	for key, value in pairs(Global.mission_manager.stage_job_values) do
		Global.mission_manager.job_values[key] = value
	end

	Global.mission_manager.stage_job_values = {}
end

-- Lines 204-206
function MissionManager:set_mission_filter(mission_filter)
	self._mission_filter = mission_filter
end

-- Lines 208-210
function MissionManager:check_mission_filter(value)
	return table.contains(self._mission_filter, value)
end

-- Lines 212-214
function MissionManager:default_instigator()
	return managers.player:player_unit()
end

-- Lines 216-221
function MissionManager:activate_script(...)
	MissionManager.super.activate_script(self, ...)
end

-- Lines 223-234
function MissionManager:_get_mission_manager(mission_id)
	local mission = nil

	if mission_id > 0 then
		mission = managers.worldcollection and managers.worldcollection:mission_by_id(mission_id)

		if not mission then
			Application:error("[MissionManager:_get_mission_manager] Mission manager not found!!!!", mission_id)
		end
	else
		mission = self
	end

	return mission
end

-- Lines 236-254
function MissionManager:client_run_mission_element(mission_id, id, unit, orientation_element_index)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:client_run_mission_element] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		if data:element(id) then
			if data:element(id).client_on_executed then
				data:element(id):set_synced_orientation_element_index(orientation_element_index)
				data:element(id):client_on_executed(unit)
			else
				debug_pause("[MissionManager:client_run_mission_element] Trying to run client_on_executed on an element that doesn't implement it: ", data:element(id):editor_name(), mission_id, id, inspect(unit), orientation_element_index)
			end

			return
		end
	end

	table.insert(managers.worldcollection.queued_client_mission_executions, {
		mission_id = mission_id,
		id = id,
		unit = unit,
		orientation_element_index = orientation_element_index
	})
end

-- Lines 256-272
function MissionManager:sync_client_hud_timer_command(mission_id, id, orientation_element_index, command, command_value)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:sync_client_hud_timer_command] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		if data:element(id) then
			data:element(id):sync_client_hud_timer_command(command, command_value)

			return
		end
	end
end

-- Lines 275-291
function MissionManager:client_run_mission_element_end_screen(mission_id, id, unit, orientation_element_index)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:client_run_mission_element_end_screen] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		if data:element(id) then
			if data:element(id).client_on_executed_end_screen then
				data:element(id):set_synced_orientation_element_index(orientation_element_index)
				data:element(id):client_on_executed_end_screen(unit)
			end

			return
		end
	end
end

-- Lines 293-308
function MissionManager:server_run_mission_element_trigger(mission_id, id, unit)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:server_run_mission_element_trigger] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		local element = data:element(id)

		if element then
			element:on_executed(unit)

			return
		end
	end

	Application:debug("[MissionManager:server_run_mission_element_trigger] MISSED server misssion execution!")
	table.insert(managers.worldcollection.queued_server_mission_executions, {
		mission_id = mission_id,
		id = id,
		unit = unit
	})
end

-- Lines 311-331
function MissionManager:to_server_area_event(event_id, mission_id, id, unit)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:to_server_area_event] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		local element = data:element(id)

		if element then
			if event_id == 1 then
				element:sync_enter_area(unit)
			elseif event_id == 2 then
				element:sync_exit_area(unit)
			elseif event_id == 3 then
				element:sync_while_in_area(unit)
			elseif event_id == 4 then
				element:sync_rule_failed(unit)
			end
		end
	end
end

-- Lines 334-365
function MissionManager:start_root_level_script()
	self._root_level_script_started = self._root_level_script_started or false

	if self._root_level_script_started then
		return
	end

	self._root_level_script_started = true
	local level = Global.level_data.level
	local mission = Global.level_data.mission
	local world_setting = Global.level_data.world_setting
	local level_class_name = Global.level_data.level_class_name
	local level_class = level_class_name and rawget(_G, level_class_name)

	print("[MissionManager:start_root_level_script()]", level, mission, level_class_name)

	if level then
		local level_path = "levels/" .. tostring(level)
		local mission_params = {
			stage_name = "stage1",
			file_path = level_path .. "/mission",
			activate_mission = mission
		}

		managers.mission:parse(mission_params)
		Application:debug("[MissionManager:start_root_level_script()] dropin?", Global.mision_load_state_dropin)

		if Global.mision_load_state_dropin then
			local data = {
				MissionManager = Global.mision_load_state_dropin
			}

			managers.mission:load(data)

			Global.mision_load_state_dropin = nil
		end

		managers.worldcollection:on_world_loaded(0)
	end
end

-- Lines 389-401
function MissionManager:to_server_access_camera_trigger(mission_id, id, trigger, instigator)
	local mission = self:_get_mission_manager(mission_id)

	if not mission then
		Application:error("[MissionManager:to_server_access_camera_trigger] skip mission execution (missionId, id)", mission_id, id)

		return
	end

	for name, data in pairs(mission._scripts) do
		local element = data:element(id)

		if element then
			element:check_triggers(trigger, instigator)
		end
	end
end

-- Lines 403-409
function MissionManager:save_job_values(data)
	local state = {
		saved_job_values = Global.mission_manager.saved_job_values,
		has_played_tutorial = Global.mission_manager.has_played_tutorial
	}
	data.ProductMissionManager = state
end

-- Lines 411-417
function MissionManager:load_job_values(data)
	local state = data.ProductMissionManager

	if state then
		Global.mission_manager.saved_job_values = state.saved_job_values
		Global.mission_manager.has_played_tutorial = state.has_played_tutorial
	end
end

-- Lines 420-425
function MissionManager:stop_simulation(...)
	MissionManager.super.stop_simulation(self, ...)

	Global.mission_manager.saved_job_values = {}

	self:on_job_deactivated()
	managers.loot:reset()
end

-- Lines 428-438
function MissionManager:execute_mission_element_by_name(name)
	for _, data in pairs(self._scripts) do
		for id, element in pairs(data:elements()) do
			if element:editor_name() == name then
				element:on_executed()

				return
			end
		end
	end
end

CoreClass.override_class(CoreMissionManager.MissionManager, MissionManager)

MissionScript = MissionScript or class(CoreMissionManager.MissionScript)

-- Lines 444-455
function MissionScript:activate(...)
	if Network:is_server() then
		MissionScript.super.activate(self, ...)

		return
	end

	managers.mission:add_persistent_debug_output("")
	managers.mission:add_persistent_debug_output("Activate mission " .. self._name, Color(1, 0, 1, 0))

	for _, element in pairs(self._elements) do
		element:on_script_activated()
	end
end

CoreClass.override_class(CoreMissionManager.MissionScript, MissionScript)
