core:register_module("lib/managers/RumbleManager")
core:import("CoreAiDataManager")
core:import("CoreSubtitlePresenter")
require("lib/setups/Setup")
require("lib/utils/ListenerHolder")
require("lib/managers/SlotManager")
require("lib/managers/MissionManager")
require("lib/utils/dev/editor/WorldDefinition")
require("lib/managers/ObjectInteractionManager")
require("lib/managers/LocalizationManager")
require("lib/managers/DialogManager")
require("lib/managers/EnemyManager")
require("lib/managers/SpawnManager")
require("lib/managers/HUDManager")
require("lib/managers/RumbleManager")
require("lib/managers/NavigationManager")
require("lib/managers/EnvironmentEffectsManager")
require("lib/managers/OverlayEffectManager")
require("lib/managers/ObjectivesManager")
require("lib/managers/GamePlayCentralManager")
require("lib/managers/MotionPathManager")
require("lib/managers/KillzoneManager")
require("lib/managers/GroupAIManager")
require("lib/managers/StatisticsManager")
require("lib/managers/OcclusionManager")
require("lib/managers/TradeManager")
require("lib/managers/CriminalsManager")
require("lib/managers/FeedBackManager")
require("lib/managers/TimeSpeedManager")
require("lib/managers/ExplosionManager")
require("lib/managers/DOTManager")
require("lib/managers/GlobalStateManager")
require("lib/managers/BarrageManager")
require("lib/managers/AirdropManager")
require("lib/managers/DropLootManager")
require("lib/managers/NotificationManager")
core:import("SequenceManager")

if Application:editor() then
	require("lib/utils/dev/tools/WorldEditor")
end

require("lib/units/ScriptUnitData")
require("lib/units/UnitBase")
require("lib/units/SyncUnitData")
require("lib/units/beings/player/PlayerBase")
require("lib/units/beings/player/PlayerCamera")
require("lib/units/beings/player/PlayerSound")
require("lib/units/beings/player/PlayerAnimationData")
require("lib/units/beings/player/PlayerDamage")
require("lib/units/beings/player/PlayerInventory")
require("lib/units/beings/player/PlayerEquipment")
require("lib/units/beings/player/PlayerMovement")
require("lib/network/base/extensions/NetworkBaseExtension")
require("lib/units/beings/player/HuskPlayerMovement")
require("lib/units/beings/player/HuskPlayerInventory")
require("lib/units/beings/player/HuskPlayerBase")
require("lib/units/beings/player/HuskPlayerDamage")
require("lib/units/cameras/FPCameraPlayerBase")
require("lib/units/cameras/VehicleCamera")
require("lib/units/characters/CharacterAttentionObject")
require("lib/units/enemies/cop/CopBase")
require("lib/units/enemies/cop/CopDamage")
require("lib/units/enemies/cop/CopBrain")
require("lib/units/enemies/cop/SpotterBrain")
require("lib/units/enemies/cop/CommanderBrain")
require("lib/units/enemies/cop/CopSound")
require("lib/units/enemies/cop/CopInventory")
require("lib/units/enemies/cop/CopMovement")
require("lib/units/enemies/flamer/FlamerBrain")
require("lib/units/enemies/tank/TankCopDamage")
require("lib/units/enemies/cop/HuskCopBase")
require("lib/units/enemies/cop/HuskCopInventory")
require("lib/units/enemies/cop/HuskCopDamage")
require("lib/units/enemies/cop/HuskCopBrain")
require("lib/units/enemies/cop/HuskCopMovement")
require("lib/units/enemies/tank/HuskTankCopDamage")
require("lib/units/characters/DummyCorpseBase")
require("lib/units/civilians/DummyCivilianBase")
require("lib/units/civilians/CivilianBase")
require("lib/units/civilians/CivilianBrain")
require("lib/units/civilians/CivilianDamage")
require("lib/units/civilians/CivilianEscortDamage")
require("lib/units/civilians/HuskCivilianBase")
require("lib/units/civilians/HuskCivilianDamage")
require("lib/units/civilians/HuskCivilianEscortDamage")
require("lib/units/player_team/TeamAIBase")
require("lib/units/player_team/TeamAIBrain")
require("lib/units/player_team/TeamAIDamage")
require("lib/units/player_team/HuskTeamAIDamage")
require("lib/units/player_team/TeamAIInventory")
require("lib/units/player_team/HuskTeamAIInventory")
require("lib/units/player_team/TeamAIMovement")
require("lib/units/player_team/HuskTeamAIMovement")
require("lib/units/player_team/TeamAISound")
require("lib/units/player_team/HuskTeamAIBase")
require("lib/units/characters/CharacterCustomization")
require("lib/units/characters/CharacterCustomizationFps")
require("lib/units/vehicles/AnimatedVehicleBase")
require("lib/units/vehicles/AirDropPlane")
require("lib/units/props/PowerupShelf")
require("lib/units/props/CarryAlignAnimator")
require("lib/units/props/SimpleAnimatorExt")
require("lib/units/vehicles/VehicleDrivingExt")
require("lib/units/vehicles/VehicleDamage")
require("lib/units/vehicles/npc/NpcVehicleDamage")
require("lib/units/vehicles/npc/NpcVehicleDrivingExt")
require("lib/units/interactions/InteractionExt")
require("lib/units/interactions/TurretInteractionExt")
require("lib/units/interactions/SpecialInteractionExt")
require("lib/units/interactions/ComicBookInteractionExt")
require("lib/units/DramaExt")
require("lib/units/DialogCharExt")
require("lib/units/pickups/Loot")
require("lib/units/pickups/GreedItem")
require("lib/units/pickups/GreedCacheItem")
require("lib/units/pickups/Pickup")
require("lib/units/pickups/AmmoClip")
require("lib/units/pickups/HealthPackPickup")
require("lib/units/pickups/GrenadePickup")
require("lib/units/pickups/GrenadePickupNew")
require("lib/units/pickups/SpecialEquipmentPickup")
require("lib/units/pickups/CandyPickup")
require("lib/units/equipment/ammo_bag/AmmoBagBase")
require("lib/units/equipment/doctor_bag/DoctorBagBase")
require("lib/units/equipment/sentry_gun/SentryGunBase")
require("lib/units/equipment/sentry_gun/SentryGunBrain")
require("lib/units/equipment/sentry_gun/SentryGunMovement")
require("lib/units/equipment/sentry_gun/SentryGunDamage")
require("lib/units/vehicles/TankTurretBrain")
require("lib/units/equipment/first_aid_kit/FirstAidKitBase")
require("lib/units/equipment/grenade_crate/GrenadeCrateBase")
require("lib/units/ContourExt")
require("lib/units/ContourModifier")
require("lib/units/DLCExt")
require("lib/units/BlinkExt")
require("lib/units/GoldAssetExt")
require("lib/units/GoldAssetAutomaticExt")
require("lib/units/weapons/RaycastWeaponBase")
require("lib/units/weapons/NewRaycastWeaponBase")
require("lib/units/weapons/NPCRaycastWeaponBase")
require("lib/units/weapons/NewNPCRaycastWeaponBase")
require("lib/units/weapons/NPCSniperRifleBase")
require("lib/units/weapons/NPCSpottingOpticsWeaponBase")
require("lib/units/weapons/SawWeaponBase")
require("lib/units/weapons/MeleeWeaponBase")
require("lib/units/weapons/NPCSawWeaponBase")
require("lib/units/weapons/shotgun/ShotgunBase")
require("lib/units/weapons/NewFlamethrowerBase")
require("lib/units/weapons/NewNPCFlamethrowerBase")
require("lib/units/weapons/shotgun/NewShotgunBase")
require("lib/units/weapons/shotgun/NPCShotgunBase")
require("lib/units/weapons/NewFlamethrowerBase")
require("lib/units/weapons/NewNPCFlamethrowerBase")
require("lib/units/weapons/NPCFlamethrowerBase")
require("lib/units/weapons/projectiles/ProjectileBase")
require("lib/units/weapons/projectiles/ImpactHurt")
require("lib/units/weapons/projectiles/ImpactDecoy")
require("lib/units/weapons/grenades/GrenadeBase")
require("lib/units/weapons/grenades/FragGrenade")
require("lib/units/weapons/grenades/MineGrenade")
require("lib/units/weapons/grenades/GrenadeCluster")
require("lib/units/weapons/grenades/NpcGrenade")
require("lib/units/weapons/grenades/MolotovGrenade")
require("lib/units/weapons/grenades/ThermiteGrenade")
require("lib/units/weapons/grenades/SmokeGrenade")
require("lib/units/equipment/repel_rope/RepelRopeBase")
require("lib/units/weapons/ProjectileWeaponBase")
require("lib/units/weapons/GrenadeLauncherBase")
require("lib/units/weapons/NPCGrenadeLauncherBase")
require("lib/units/weapons/BowWeaponBase")
require("lib/units/weapons/NPCBowWeaponBase")
require("lib/units/weapons/AkimboWeaponBase")
require("lib/units/weapons/AkimboShotgunBase")
require("lib/units/weapons/SentryGunWeapon")
require("lib/units/weapons/WeaponGadgetBase")
require("lib/units/weapons/WeaponLaser")
require("lib/units/weapons/WeaponSimpleAnim")
require("lib/units/weapons/WeaponLionGadget1")
require("lib/units/weapons/FlamethrowerEffectExtension")
require("lib/units/weapons/DP28RaycastWeaponBase")
require("lib/units/weapons/HybridReloadRaycastWeaponBase")
require("lib/units/weapons/LeeEnfieldRaycastWeaponBase")
require("lib/units/weapons/WelrodRaycastWeaponBase")
require("lib/units/weapons/MountedWeapon")
require("lib/units/weapons/TurretWeapon")
require("lib/units/weapons/TankTurretWeapon")
require("lib/network/NetworkSpawnPointExt")
require("lib/managers/test/TestManager")
require("lib/units/props/TvGui")
require("lib/units/props/CarryData")
require("lib/units/props/CorpseCarryData")
require("lib/units/props/AmmoPickup")
require("lib/units/props/ThrowableAmmoBag")
require("lib/units/props/AIAttentionObject")
require("lib/units/props/SmallLootBase")
require("lib/units/props/Ladder")
require("lib/units/vehicles/SimpleVehicle")
require("lib/units/props/ZipLine")
require("lib/units/props/TextTemplateBase")
require("lib/units/props/ExplodingProp")
require("lib/units/props/FlamerTank")
require("lib/units/props/MetalDetector")
require("lib/units/props/ManageSpawnedUnits")
require("lib/units/characters/CharacterManageSpawnedUnits")
require("lib/units/props/RevivePumpkinExt")
require("lib/units/props/FauxContainer")
require("lib/units/props/AccessoryGear")

GameSetup = GameSetup or class(Setup)

function GameSetup:load_packages()
	Application:debug("[GameSetup:load_packages()]")
	Setup.load_packages(self)

	if not PackageManager:loaded("packages/game_base_init") then
		PackageManager:load("packages/game_base_init")
	end

	if not PackageManager:loaded("packages/game_base") and PackageManager:package_exists("packages/game_base") then
		PackageManager:load("packages/game_base")
	end

	if not PackageManager:loaded("packages/wip/game_base") and PackageManager:package_exists("packages/wip/game_base") then
		PackageManager:load("packages/wip/game_base")
	end

	local prefix = "packages/dlcs/"
	local sufix = "/game_base"
	local package = ""

	for dlc_package, bundled in pairs(tweak_data.BUNDLED_DLC_PACKAGES) do
		package = prefix .. tostring(dlc_package) .. sufix

		Application:debug("[MenuSetup:load_packages] DLC package: " .. package, "Is package OK to load?: " .. tostring(bundled))

		if bundled and (bundled == true or bundled == 2) and PackageManager:package_exists(package) and not PackageManager:loaded(package) then
			PackageManager:load(package)
		end
	end

	local level_package = nil

	if not Global.level_data or not Global.level_data.level_id then
		if not Application:editor() then
			-- Nothing
		end
	else
		local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
		level_package = lvl_tweak_data and lvl_tweak_data.package
	end

	Application:debug("[GameSetup:load_packages()] Loading level package exists?", level_package)

	if level_package then
		Application:debug("[GameSetup:load_packages()] Loading level package", inspect(level_package))

		if type(level_package) == "table" then
			self._loaded_level_package = level_package

			for _, package in ipairs(level_package) do
				if not PackageManager:loaded(package) then
					PackageManager:load(package)
					managers.sequence:preload_package(package)
				end
			end
		elseif not PackageManager:loaded(level_package) then
			self._loaded_level_package = level_package

			PackageManager:load(level_package)
			managers.sequence:preload_package(level_package)
		end
	end

	if not Application:editor() and Global.game_settings.packages_packed then
		managers.worldcollection:sync_loaded_packages(Global.game_settings.packages_packed)

		Global.game_settings.packages_packed = nil

		Application:debug("[GameSetup:load_packages()] PAUSING")
		Application:set_pause(true)
	end
end

function GameSetup:gather_packages_to_unload()
	Setup.unload_packages(self)

	self._started_unloading_packages = true
	self._packages_to_unload = self._packages_to_unload or {}

	if not Global.load_level then
		local prefix = "packages/dlcs/"
		local sufix = "/game_base"
		local package = ""

		for dlc_package, bundled in pairs(tweak_data.BUNDLED_DLC_PACKAGES) do
			package = prefix .. tostring(dlc_package) .. sufix

			if bundled and (bundled == true or bundled == 2) and PackageManager:package_exists(package) and PackageManager:loaded(package) then
				table.insert(self._packages_to_unload, package)
			end
		end
	end

	if self._loaded_level_package then
		if type(self._loaded_level_package) == "table" then
			for _, package in ipairs(self._loaded_level_package) do
				if PackageManager:loaded(package) then
					table.insert(self._packages_to_unload, package)
				end
			end
		elseif PackageManager:loaded(self._loaded_level_package) then
			table.insert(self._packages_to_unload, self._loaded_level_package)
		end

		self._loaded_level_package = nil
	end
end

function GameSetup:unload_packages()
	Setup.unload_packages(self)
end

function GameSetup:init_managers(managers)
	Setup.init_managers(self, managers)

	managers.interaction = ObjectInteractionManager:new()
	managers.dialog = DialogManager:new()
	managers.enemy = EnemyManager:new()
	managers.spawn = SpawnManager:new()
	managers.hud = HUDManager:new()
	managers.navigation = NavigationManager:new()
	managers.objectives = ObjectivesManager:new()
	managers.killzone = KillzoneManager:new()
	managers.groupai = GroupAIManager:new()
	managers.statistics = StatisticsManager:new()
	managers.ai_data = CoreAiDataManager.AiDataManager:new()
	managers.occlusion = _OcclusionManager:new()
	managers.criminals = CriminalsManager:new()
	managers.trade = TradeManager:new()
	managers.feedback = FeedBackManager:new()
	managers.time_speed = TimeSpeedManager:new()
	managers.explosion = ExplosionManager:new()
	managers.game_play_central = GamePlayCentralManager:new()
	managers.motion_path = MotionPathManager:new()
	managers.dot = DOTManager:new()
	managers.global_state = GlobalStateManager:new()
	managers.barrage = BarrageManager:new()
	managers.airdrop = AirdropManager:new()
	managers.drop_loot = DropLootManager:new()
	managers.notification = NotificationManager:new()
	managers.test = TestManager:new()
end

function GameSetup:init_game()
	local gsm = Setup.init_game(self)

	if not Application:editor() then
		local engine_package = PackageManager:package("engine-package")

		engine_package:unload_all_temp()
		managers.mission:set_mission_filter({})

		local level = Global.level_data.level
		local world_setting = Global.level_data.world_setting

		if level then
			local level_path = "levels/" .. tostring(level)
			local t = {
				file_type = "world",
				file_path = level_path .. "/world",
				world_setting = world_setting
			}

			assert(WorldHolder:new(t):create_world("world", "all", Vector3()), "Cant load the level!")
			managers.mission:start_root_level_script()
		else
			error("No level loaded! Use -level 'levelname'")
		end
	end

	return gsm
end

function GameSetup:init_finalize()
	Application:debug("[GameSetup:init_finalize()] Finalizing now...")

	if Global.current_load_package then
		PackageManager:unload(Global.current_load_package)

		Global.current_load_package = nil
	end

	Setup.init_finalize(self)
	managers.hud:init_finalize()
	managers.dialog:init_finalize()

	if not Application:editor() then
		managers.navigation:on_game_started()
		game_state_machine:change_state_by_name("ingame_waiting_for_players")
	end

	if managers.music then
		managers.music:init_finalize()
	end

	if managers.savefile and not Application:editor() then
		managers.savefile:precache_data()
	end

	managers.dyn_resource:post_init()

	self._keyboard = Input:keyboard()

	managers.network.account:set_playing(true)
	Application:debug("[GameSetup:init_finalize()] Finalizing done!")
end

function GameSetup:update(t, dt)
	Setup.update(self, t, dt)

	if managers.worldcollection then
		managers.worldcollection:update(t, dt)
	end

	managers.interaction:update(t, dt)
	managers.dialog:update(t, dt)
	managers.enemy:update(t, dt)
	managers.groupai:update(t, dt)
	managers.spawn:update(t, dt)
	managers.navigation:update(t, dt)
	managers.hud:update(t, dt)
	managers.killzone:update(t, dt)
	managers.game_play_central:update(t, dt)
	managers.trade:update(t, dt)
	managers.statistics:update(t, dt)
	managers.objectives:update(t, dt)
	managers.explosion:update(t, dt)
	managers.fire:update(t, dt)
	managers.dot:update(t, dt)
	managers.motion_path:update(t, dt)
	managers.voice_over:update(t, dt)
	managers.barrage:update(t, dt)
	managers.queued_tasks:update(t, dt)
	managers.test:update(t, dt)
	managers.warcry:update(t, dt)
	self:_update_debug_input()
	managers.buff_effect:update(t, dt)
end

function GameSetup:paused_update(t, dt)
	Setup.paused_update(self, t, dt)
	managers.groupai:paused_update(t, dt)

	if managers.worldcollection then
		managers.worldcollection:update(t, dt, true)
	end

	self:_update_debug_input()
end

function GameSetup:destroy()
	Setup.destroy(self)
	managers.navigation:destroy()
	managers.time_speed:destroy()
	managers.network.account:set_playing(false)
end

function GameSetup:end_update(t, dt)
	Setup.end_update(self, t, dt)
	managers.game_play_central:end_update(t, dt)
end

function GameSetup:save(data)
	Setup.save(self, data)
	managers.game_play_central:save(data)
	managers.hud:save(data)
	managers.music:save(data)
	managers.environment_effects:save(data)
	managers.mission:save(data)
	managers.worldcollection:sync_save(data)
	managers.viewport:save(data)
	managers.groupai:state():save(data)
	managers.player:sync_save(data)
	managers.trade:save(data)
	managers.groupai:state():save(data)
	managers.loot:sync_save(data)
	managers.enemy:save(data)
	managers.sequence:save(data)
	managers.world_instance:sync_save(data)
	managers.motion_path:save(data)
	managers.global_state:sync_save(data)
	managers.challenge_cards:save_dropin(data)
	managers.buff_effect:save_dropin(data)
	managers.lootdrop:sync_save(data)
	managers.raid_job:sync_save(data)
	managers.objectives:save(data)
	managers.statistics:sync_save(data)
	managers.fire:sync_save(data)
end

function GameSetup:load(data)
	Setup.load(self, data)
	managers.hud:load(data)
	managers.music:load(data)
	managers.environment_effects:load(data)
	managers.mission:load(data)
	managers.worldcollection:sync_load(data)
	managers.viewport:load(data)
	managers.game_play_central:load(data)
	managers.player:sync_load(data)
	managers.trade:load(data)
	managers.groupai:state():load(data)
	managers.loot:sync_load(data)
	managers.enemy:load(data)
	managers.sequence:load(data)
	managers.world_instance:sync_load(data)
	managers.motion_path:load(data)
	managers.global_state:sync_load(data)
	managers.challenge_cards:load_dropin(data)
	managers.buff_effect:load_dropin(data)
	managers.lootdrop:sync_load(data)
	managers.raid_job:sync_load(data)
	managers.objectives:load(data)
	managers.statistics:sync_load(data)
	managers.fire:sync_load(data)
end

function GameSetup:_update_debug_input()
end

return GameSetup
