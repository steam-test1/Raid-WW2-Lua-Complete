core:import("CoreAiLayer")
core:import("CoreHeatmapLayer")
require("lib/units/editor/SpawnEnemyGroupElement")
require("lib/units/editor/EnemyPreferedElement")
require("lib/units/editor/AIGraphElement")
require("lib/units/editor/WaypointElement")
require("lib/units/editor/SpawnCivilianElement")
require("lib/units/editor/SpawnCivilianGroupElement")
require("lib/units/editor/LookAtTrigger")
require("lib/units/editor/MissionEnd")
require("lib/units/editor/ObjectiveElement")
require("lib/units/editor/DialogueElement")
require("lib/units/editor/HintElement")
require("lib/units/editor/AiGlobalEventElement")
require("lib/units/editor/EquipmentElement")
require("lib/units/editor/PlayerStateUnitElement")
require("lib/units/editor/KillzoneElement")
require("lib/units/editor/SpecialObjectiveElement")
require("lib/units/editor/SpecialObjectiveTriggerElement")
require("lib/units/editor/SpecialObjectiveGroupElement")
require("lib/units/editor/PlayerStateTriggerUnitElement")
require("lib/units/editor/DifficultyElement")
require("lib/units/editor/BlurZoneElement")
require("lib/units/editor/AIRemoveElement")
require("lib/units/editor/TeammateCommentElement")
require("lib/units/editor/WhisperStateElement")
require("lib/units/editor/AwardAchievmentElement")
require("lib/units/editor/PointOfNoReturnElement")
require("lib/units/editor/FadeToBlackElement")
require("lib/units/editor/FeedbackElement")
require("lib/units/editor/ExplosionElement")
require("lib/units/editor/FilterElement")
require("lib/units/editor/DisableUnitElement")
require("lib/units/editor/EnableUnitElement")
require("lib/units/editor/SmokeGrenadeElement")
require("lib/units/editor/SetOutlineElement")
require("lib/units/editor/ExplosionDamageElement")
require("lib/units/editor/BlackscreenElement")
require("lib/units/editor/BlackscreenVariantElement")
require("lib/units/editor/AIAttentionElement")
require("lib/units/editor/AIAreaElement")
require("lib/units/editor/CarryElement")
require("lib/units/editor/LootBagElement")
require("lib/units/editor/JobValueElement")
require("lib/units/editor/NavObstacleElement")
require("lib/units/editor/SpawnDeployableElement")
require("lib/units/editor/FleePointElement")
require("lib/units/editor/InstigatorElement")
require("lib/units/editor/InstigatorRuleElement")
require("lib/units/editor/PickupElement")
require("lib/units/editor/LaserTriggerElement")
require("lib/units/editor/SpawnGrenadeElement")
require("lib/units/editor/SpotterElement")
require("lib/units/editor/CharacterTeamElement")
require("lib/units/editor/TeamRelationElement")
require("lib/units/editor/SlowMotionElement")
require("lib/units/editor/InteractionElement")
require("lib/units/editor/CharacterSequenceElement")
require("lib/units/editor/ExperienceElement")
require("lib/units/editor/ModifyPlayerElement")
require("lib/units/editor/AreaMinPoliceForceUnitElement")
require("lib/units/editor/TeleportPlayerElement")
require("lib/units/editor/StatisticsElement")
require("lib/units/editor/StatisticsJobsElement")
require("lib/units/editor/GameEventElement")
require("lib/units/editor/VariableElement")
require("lib/units/editor/TeamAICommandsElement")
require("lib/units/editor/EnableSoundEnvironmentElement")
require("lib/units/editor/SoundSwitchElement")
require("lib/units/editor/SpawnPlayerElement")
require("lib/units/editor/EnemyDummyTrigger")
require("lib/units/editor/SpawnEnemyElement")
require("lib/units/editor/MotionpathMarkerElement")
require("lib/units/editor/VehicleTriggerUnitElement")
require("lib/units/editor/VehicleOperatorUnitElement")
require("lib/units/editor/SpawnVehicleElement")
require("lib/units/editor/WorldOperatorUnitElement")
require("lib/units/editor/GlobalStateOperatorElement")
require("lib/units/editor/GlobalStateTriggerElement")
require("lib/units/editor/GlobalStateFilterElement")
require("lib/units/editor/ExecLuaOperatorElement")
require("lib/units/editor/NavLinkElement")
require("lib/units/editor/DropPointGroupElement")
require("lib/units/editor/DropPointElement")
require("lib/units/editor/MapChangeFloorElement")
require("lib/units/editor/MetalDetectorElement")
require("lib/units/editor/DropinStateElement")
require("lib/units/editor/EnvironmentOperatorElement")
require("lib/units/editor/EnvironmentEffectElement")
require("lib/units/editor/EnvironmentAreaOperatorElement")
require("lib/units/editor/NavigationStitcherUnitElement")
require("lib/units/editor/NavigationStitcherOperatorUnitElement")
require("lib/units/editor/BarrageElement")
require("lib/units/editor/InvulnerableElement")
require("lib/units/editor/CharacterDamageTriggerElement")
require("lib/units/editor/EscortElement")
require("lib/utils/dev/tools/InventoryIconCreator")

WorldEditor = WorldEditor or class(CoreEditor)

-- Lines 113-120
function WorldEditor:init(game_state_machine)
	WorldEditor.super.init(self, game_state_machine)
	Network:set_multiplayer(true)
	managers.network:host_game()

	self._tool_updators = {}
end

-- Lines 122-127
function WorldEditor:update(...)
	WorldEditor.super.update(self, ...)

	for name, updator in pairs(self._tool_updators) do
		updator(...)
	end
end

-- Lines 129-131
function WorldEditor:add_tool_updator(name, updator)
	self._tool_updators[name] = updator
end

-- Lines 133-135
function WorldEditor:remove_tool_updator(name)
	self._tool_updators[name] = nil
end

-- Lines 137-140
function WorldEditor:_init_mission_difficulties()
	self._mission_difficulties = {
		{
			"difficulty_1",
			"Normal"
		},
		{
			"difficulty_2",
			"Hard"
		},
		{
			"difficulty_3",
			"Very Hard"
		},
		{
			"difficulty_4",
			"Overkill"
		}
	}
	self._mission_difficulty = Global.DEFAULT_DIFFICULTY
end

-- Lines 142-145
function WorldEditor:_init_mission_players()
	self._mission_players = {
		1,
		2,
		3,
		4
	}
	self._mission_player = 1
end

-- Lines 148-152
function WorldEditor:_project_init_layer_classes()
	self:add_layer("Ai", CoreAiLayer.AiLayer)
	self:add_layer("Heatmap", CoreHeatmapLayer.HeatmapLayer)
end

-- Lines 155-157
function WorldEditor:_project_init_slot_masks()
	self._go_through_units_before_simulaton_mask = self._go_through_units_before_simulaton_mask + 15
end

-- Lines 159-163
function WorldEditor:project_prestart_up(with_mission)
	managers.navigation:on_simulation_started()
	managers.groupai:on_simulation_started()
	managers.enemy:on_simulation_started()
end

-- Lines 167-194
function WorldEditor:project_run_simulation(with_mission)
	tweak_data:set_difficulty(self._mission_difficulty or Global.DEFAULT_DIFFICULTY)
	managers.network:host_game()
	managers.player:on_simulation_started()
	managers.vehicle:on_simulation_started()
	managers.motion_path:on_simulation_started()
	managers.music:post_event(tweak_data.music.default.start)
	managers.mission:on_simulation_started()

	if not with_mission then
		managers.player:set_player_state("standard")
		managers.groupai:state():set_AI_enabled(false)
		managers.network:register_spawn_point(-1, {
			position = self._vp:camera():position(),
			rotation = Rotation:yaw_pitch_roll(self._vp:camera():rotation():yaw(), 0, 0)
		})
	end

	managers.network:session():on_load_complete(true)
	managers.network:session():spawn_players()
	managers.mission:set_mission_filter(self:layer("Level Settings"):get_mission_filter())

	local level_id = self:layer("Level Settings"):get_setting("simulation_level_id")

	managers.game_play_central:setup_effects(level_id)
	managers.game_play_central:start_heist_timer()
end

-- Lines 196-198
function WorldEditor:_project_check_unit(unit)
end

-- Lines 202-239
function WorldEditor:project_stop_simulation()
	managers.hud:on_simulation_ended()
	managers.hud:clear_waypoints()
	managers.network:unregister_all_spawn_points()
	managers.menu:close_menu("menu_pause")
	managers.objectives:reset()
	setup:freeflight():disable()
	managers.groupai:on_simulation_ended()
	managers.enemy:on_simulation_ended()
	managers.navigation:on_simulation_ended()
	managers.dialog:on_simulation_ended()
	managers.player:soft_reset()
	managers.vehicle:on_simulation_ended()
	managers.statistics:stop_session()
	managers.environment_controller:set_all_blurzones(0)
	managers.music:stop()
	managers.game_play_central:on_simulation_ended()
	managers.criminals:on_simulation_ended()
	managers.loot:on_simulation_ended()
	managers.motion_path:on_simulation_ended()
	managers.fire:on_simulation_ended()
	managers.dot:on_simulation_ended()
	managers.global_state:on_simulation_ended()
	managers.voice_over:on_simulation_ended()
	managers.barrage:on_simulation_ended()
	managers.queued_tasks:on_simulation_ended()
	managers.drop_loot:on_simulation_ended()
	managers.raid_job:on_simulation_ended()
	managers.notification:on_simulation_ended()
	managers.lootdrop:on_simulation_ended()
end

-- Lines 243-255
function WorldEditor:project_clear_units()
	managers.groupai:state():set_AI_enabled(false)

	local units = World:find_units_quick("all", World:make_slot_mask(0, 2, 4, 5, 6, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25))

	for _, unit in ipairs(units) do
		local layer = self:unit_in_layer(unit)

		if layer then
			layer:delete_unit(unit)
		else
			World:delete_unit(unit)
		end
	end
end

-- Lines 260-261
function WorldEditor:project_clear_layers()
end

-- Lines 266-267
function WorldEditor:project_recreate_layers()
end

-- Lines 270-273
function WorldEditor:_project_add_left_upper_toolbar_tool()
	self._left_upper_toolbar:add_tool("TB_INVENTORY_ICON_CREATOR", "Icon Creator", CoreEWS.image_path("world_editor/icon_creator_16x16.png"), "Material Editor")
	self._left_upper_toolbar:connect("TB_INVENTORY_ICON_CREATOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_open_inventory_icon_creator"), nil)
end

-- Lines 275-278
function WorldEditor:_open_inventory_icon_creator()
	self._inventory_icon_creator = self._inventory_icon_creator or InventoryIconCreator:new()

	self._inventory_icon_creator:show_ews()
end
