core:register_module("lib/managers/PlatformManager")
core:register_module("lib/managers/SystemMenuManager")
core:register_module("lib/managers/UserManager")
core:register_module("lib/managers/SequenceManager")
core:register_module("lib/managers/ControllerManager")
core:register_module("lib/managers/SlotManager")
core:register_module("lib/managers/DebugManager")
core:register_module("lib/utils/game_state_machine/GameState")
core:register_module("lib/utils/dev/FreeFlight")

Global.DEBUG_MENU_ON = Application:debug_enabled()
Global.DEFAULT_DIFFICULTY = "difficulty_2"
Global.DEFAULT_PERMISSION = "friends_only"
Global.STREAM_ALL_PACKAGES = false

core:import("CoreSetup")
require("lib/managers/DLCManager")

managers.dlc = DLCManager:new()

require("lib/tweak_data/TweakData")
require("lib/utils/Utl")
require("lib/utils/CoroutineManager")
require("lib/utils/EventListenerHolder")
require("lib/utils/QueuedEventListenerHolder")
require("lib/utils/Easing")
require("lib/utils/UIAnimation")
require("lib/utils/TemporaryPropertyManager")
require("lib/utils/PlayerSkill")
require("lib/managers/UpgradesManager")
require("lib/managers/GoldEconomyManager")
require("lib/managers/RaidExperienceManager")
require("lib/managers/PlayerManager")
require("lib/managers/SavefileManager")
require("lib/managers/MenuManager")
require("lib/managers/AchievmentManager")
require("lib/managers/SkillTreeManager")
require("lib/managers/DynamicResourceManager")
require("lib/managers/VehicleManager")
require("lib/managers/FireManager")
require("lib/managers/menu/raid_menu/RaidMenuSceneManager")
require("lib/managers/CharacterCustomizationManager")
require("lib/managers/ChallengeCardsManager")
require("lib/managers/ConsumableMissionManager")
require("lib/managers/GreedManager")
require("lib/managers/EventSystemManager")
require("lib/managers/ProgressionManager")
require("lib/managers/WeaponSkillsManager")
require("lib/managers/QueuedTasksManager")
require("lib/managers/WeaponInventoryManager")
require("lib/managers/WarcryManager")
core:import("PlatformManager")
core:import("SystemMenuManager")
core:import("UserManager")
core:import("ControllerManager")
core:import("SlotManager")
core:import("FreeFlight")
core:import("CoreGuiDataManager")
require("lib/managers/ControllerWrapper")
require("lib/utils/game_state_machine/GameStateMachine")
require("lib/utils/LightLoadingScreenGuiScript")
require("lib/managers/LocalizationManager")
require("lib/managers/MousePointerManager")
require("lib/managers/VideoManager")
require("lib/managers/menu/TextBoxGui")
require("lib/managers/menu/BookBoxGui")
require("lib/managers/menu/CircleGuiObject")
require("lib/managers/menu/ArcGuiObject")
require("lib/managers/menu/ProgressBarGuiObject")
require("lib/managers/menu/BoxGuiObject")
require("lib/managers/menu/ImageBoxGui")
require("lib/managers/menu/SpecializationBoxGui")
require("lib/managers/menu/MenuBackdropGUI")
require("lib/managers/WeaponFactoryManager")
require("lib/managers/BlackMarketManager")
require("lib/managers/LootDropManager")
require("lib/managers/ChatManager")
require("lib/managers/LootManager")
require("lib/managers/RaidJobManager")
require("lib/managers/VoiceOverManager")
require("lib/managers/BreadcrumbManager")
require("lib/managers/ChallengeManager")
require("lib/managers/challenges/Challenge")
require("lib/managers/challenges/ChallengeTasks")
require("lib/managers/MusicManager")
require("lib/managers/VoteManager")
require("lib/managers/UnlockManager")
require("lib/units/UnitDamage")
require("lib/units/props/TextGui")
require("lib/units/props/MaterialControl")
require("lib/units/props/AlphaRefControl")
require("lib/units/props/TankTrackAnimation")
require("lib/units/props/WaypointExt")
require("lib/units/props/EscortExt")
require("lib/units/props/FoxholeExt")
require("lib/managers/hud/HUDLoadingScreen")
require("lib/managers/menu/raid_menu/controls/RaidGUIPanel")
require("lib/managers/menu/raid_menu/controls/RaidGUIControl")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlInputField")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLabel")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLabelNamedValue")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLabelNamedValueWithDelta")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLabelTitle")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLabelSubtitle")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBreadcrumb")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonSmall")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonShortPrimary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonShortPrimaryGold")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonShortPrimaryDisabled")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonShortSecondary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonShortTertiary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonLongPrimary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonLongPrimaryDisabled")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonLongSecondary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonLongTertiary")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonSubtitle")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlImage")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlInfoIcon")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlMenuBackground")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlThreeCutBitmap")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlNineCutBitmap")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlImageButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlNavigationButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlAnimatedBitmap")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemCharacterSelect")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemCharacterSelectButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemCharacterCreateClass")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemCharacterCreateNation")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCharacterDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlClassDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlNationalityDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemIconDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemIcon")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemMenu")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemRaids")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemOperations")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemSaveSlots")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemWeapons")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlButtonSkillProfiles")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemSkillProfile")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItemContextButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListItem")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlList")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListActive")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlListSeparated")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlStepper")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlStepperSimple")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlSlider")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlSliderSimple")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonToggle")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonToggleSmall")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlButtonSwitch")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTableRow")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTableCell")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTableCellButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTableCellImage")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTableCellImageButton")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTable")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTabs")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTab")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTabFilter")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlRotateUnit")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlProgressBar")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlProgressBarSimple")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingProgressBar")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingBarNode")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingBarSkilltreeNode")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingBarPath")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingBarLootScreenPath")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlBranchingBarSkilltreePath")
require("lib/managers/menu/raid_menu/controls/RaidGuiControlKeyBind")
require("lib/managers/menu/raid_menu/controls/RaidGuiControlDifficultyStars")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGrid")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGridActive")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGridItem")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGridItemActive")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlPagedGrid")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlScrollGrid")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlPagedGridCharacterCustomization")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCategorizedGrid")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlScrollableArea")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlScrollbar")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLegend")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlVideo")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGreedBarSmall")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlMissionUnlock")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLootCardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLootRewardCards")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlLootBreakdownItem")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardPeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCard")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardBase")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardWithSelector")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardSuggested")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCardSuggestedLarge")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlSuggestedCards")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlSuggestedCardsLarge")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCharacterCustomizationDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlCharacterCustomizationPeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlExperiencePeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGoldBarRewardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGoldBarPeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlMeleeWeaponPeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlPeerRewardCardPack")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlMeleeWeaponRewardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlWeaponPointPeerLoot")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlWeaponPointRewardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlXPRewardDetails")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlServerPlayerDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlReadyUpPlayerDescription")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlRewardCardPack")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlPlayerStats")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlSkillsBreakdown")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlXPUnlocks")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlXPBreakdown")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlStatsBreakdown")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlSkillDetails")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlRespec")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlTopStat")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlTopStatBig")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlTopStatSmall")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlWeaponSkills")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlWeaponSkillRow")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlWeaponSkillDesc")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlButtonWeaponSkill")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlXPCell")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlPeerDetails")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlOperationProgress")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlIntelImageGrid")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlIntelImage")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlIntelImageDetails")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlSaveInfo")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlXPProgressBar")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlSkilltreeProgressBar")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlLootProgressBar")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlLootBracket")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlKickMuteWidget")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlGridItemSkill")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlSkillProgression")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlButtonSkillTiny")
require("lib/managers/menu/raid_menu/controls/custom/RaidGUIControlEventDisplay")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlWeaponStats")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlMeleeWeaponStats")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlGrenadeWeaponStats")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlTabWeaponStats")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlIntelBulletin")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlIntelOperationalStatus")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlIntelRaidPersonel")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlIntelOppositeForces")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlIntelControlArchive")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlImageViewer")
require("lib/managers/hud/HUDSaveIcon")
require("lib/managers/menu/raid_menu/controls/RaidGUIControlDialogTest")
require("lib/utils/StatisticsGenerator")

script_data = script_data or {}
game_state_machine = game_state_machine or nil
Setup = Setup or class(CoreSetup.CoreSetup)

function Setup:init_category_print()
	CoreSetup.CoreSetup.init_category_print(self)

	if Global.category_print_initialized.setup then
		return
	end

	if not Global.interface_sound then
		-- Nothing
	end

	local cat_list = {
		"dialog_manager",
		"user_manager",
		"exec_manager",
		"savefile_manager",
		"loading_environment",
		"player_intel",
		"player_damage",
		"player_action",
		"AI_action",
		"bt",
		"dummy_ai",
		"dummy_block_chance",
		"johan",
		"george",
		"qa",
		"bob",
		"jansve",
		"sound_placeholder",
		"spam"
	}

	for _, cat in ipairs(cat_list) do
		Global.category_print[cat] = false
	end

	catprint_load()
end

function Setup:set_resource_loaded_clbk(...)
	PackageManager:set_resource_loaded_clbk(...)
end

function Setup:load_packages()
	Application:debug("[Setup:load_packages()]")
	setup:set_resource_loaded_clbk(IDS_UNIT, nil)
	TextureCache:set_streaming_enabled(true)
	TextureCache:set_LOD_streaming_enabled(true)

	if not Application:editor() then
		PackageManager:set_streaming_enabled(true)
	end

	if not PackageManager:loaded("packages/base") then
		PackageManager:load("packages/base")
	end

	if not PackageManager:loaded("packages/dyn_resources") then
		PackageManager:load("packages/dyn_resources")
	end
end

function Setup:init_managers(managers)
	Global.game_settings = Global.game_settings or {
		is_playing = false,
		search_appropriate_jobs = true,
		job_plan = -1,
		kick_option = 1,
		drop_in_allowed = true,
		reputation_permission = 0,
		team_ai = true,
		selected_team_ai = true,
		permission = "public",
		level_id = OperationsTweakData.ENTRY_POINT_LEVEL,
		difficulty = Global.DEFAULT_DIFFICULTY
	}

	managers.dlc:setup()

	managers.dyn_resource = DynamicResourceManager:new()
	managers.gui_data = CoreGuiDataManager.GuiDataManager:new()
	managers.platform = PlatformManager.PlatformManager:new()
	managers.music = MusicManager:new()
	managers.system_menu = SystemMenuManager.SystemMenuManager:new()
	managers.achievment = AchievmentManager:new()
	managers.savefile = SavefileManager:new()
	managers.user = UserManager.UserManager:new()
	managers.upgrades = UpgradesManager:new()
	managers.experience = RaidExperienceManager:new()
	managers.gold_economy = GoldEconomyManager:new()
	managers.skilltree = SkillTreeManager:new()
	managers.player = PlayerManager:new()
	managers.video = VideoManager:new()
	managers.menu = MenuManager:new(self.IS_START_MENU)
	managers.raid_menu = RaidMenuSceneManager:new()

	managers.subtitle:set_presenter(CoreSubtitlePresenter.OverlayPresenter:new(tweak_data.gui.fonts.din_compressed_outlined_22, 22))

	managers.mouse_pointer = MousePointerManager:new()
	managers.weapon_factory = WeaponFactoryManager:new()
	managers.blackmarket = BlackMarketManager:new()
	managers.lootdrop = LootDropManager:new()
	managers.chat = ChatManager:new()
	managers.menu_component = MenuComponentManager:new()
	managers.loot = LootManager:new()
	managers.raid_job = RaidJobManager.get_instance()
	managers.voice_over = VoiceOverManager:new()
	managers.breadcrumb = BreadcrumbManager.get_instance()
	managers.challenge = ChallengeManager.get_instance()
	managers.greed = GreedManager.get_instance()
	managers.event_system = EventSystemManager.get_instance()
	managers.vote = VoteManager:new()
	managers.vehicle = VehicleManager:new()
	managers.fire = FireManager:new()
	managers.character_customization = CharacterCustomizationManager:new()
	managers.buff_effect = BuffEffectManager:new()
	managers.challenge_cards = ChallengeCardsManager:new()
	managers.consumable_missions = ConsumableMissionManager:new()
	managers.weapon_skills = WeaponSkillsManager:new()
	managers.queued_tasks = QueuedTasksManager:new()
	managers.warcry = WarcryManager.get_instance()
	managers.weapon_inventory = WeaponInventoryManager.get_instance()
	managers.progression = ProgressionManager.get_instance()
	managers.unlock = UnlockManager.get_instance()
	game_state_machine = GameStateMachine:new()
end

function Setup:start_boot_loading_screen()
	if not PackageManager:loaded("packages/boot_screen") then
		PackageManager:load("packages/boot_screen")
	end

	self:_start_loading_screen()
end

function Setup:start_loading_screen()
	self:_start_loading_screen()
end

function Setup:stop_loading_screen()
	Application:debug("[Setup:stop_loading_screen()]")

	if Global.is_loading then
		Application:debug("[LoadingEnvironment] Stop.")
		self:set_main_thread_loading_screen_visible(false)

		Global.is_loading = nil
	else
		Application:stack_dump_error("[LoadingEnvironment] Tried to stop loading screen when it wasn't started.")
	end
end

function Setup:_start_loading_screen()
	Application:debug("[Setup:_start_loading_screen()]")
	Application:stack_dump()

	if Global.is_loading then
		Application:stack_dump_error("[LoadingEnvironment] Tried to start loading screen when it was already started.")

		return
	elseif not SystemInfo:threaded_renderer() then
		cat_print("loading_environment", "[LoadingEnvironment] Skipped (renderer is not threaded).")

		Global.is_loading = true

		return
	end

	cat_print("loading_environment", "[LoadingEnvironment] Start.")

	local setup = nil

	if not LoadingEnvironmentScene:loaded() then
		LoadingEnvironmentScene:load("levels/zone", false)
	end

	local load_level_data = nil

	if Global.load_level then
		if not PackageManager:loaded("packages/load_level") then
			PackageManager:load("packages/load_level")
		end

		setup = "lib/setups/LevelLoadingSetup"
		load_level_data = {
			level_data = Global.level_data,
			level_tweak_data = tweak_data.levels[Global.level_data.level_id] or {}
		}
		load_level_data.level_tweak_data.name = load_level_data.level_tweak_data.name_id and managers.localization:text(load_level_data.level_tweak_data.name_id)
		load_level_data.gui_tweak_data = tweak_data.load_level
		load_level_data.menu_tweak_data = tweak_data.menu
		load_level_data.scale_tweak_data = tweak_data.scale
		load_level_data.tip_id = tweak_data.tips:get_a_tip()
		local packages_to_load = load_level_data.level_tweak_data.package

		if packages_to_load then
			Application:debug("[Setup:_start_loading_screen()] Load coded level packages: #" .. tostring(#packages_to_load))

			for _, v in ipairs(packages_to_load) do
				PackageManager:load(v)
			end
		end

		local coords = tweak_data:get_controller_help_coords()
		load_level_data.controller_coords = coords and coords[table.random({
			"normal",
			"vehicle"
		})]
		load_level_data.controller_image = "guis/textures/controller"
		load_level_data.controller_shapes = {
			{
				position = {
					cx = 0.5,
					cy = 0.5
				},
				texture_rect = {
					0,
					0,
					512,
					256
				}
			}
		}

		if load_level_data.controller_coords then
			for id, data in pairs(load_level_data.controller_coords) do
				data.string = data.localize == false and data.id or managers.localization:to_upper_text(data.id)
				data.color = (data.id == "menu_button_unassigned" or data.localize == false) and Color(0.5, 0.5, 0.5) or Color.white
			end
		end

		local load_data = load_level_data.level_tweak_data.load_data
		local safe_rect_pixels = managers.viewport:get_safe_rect_pixels()
		local safe_rect = managers.viewport:get_safe_rect()
		local aspect_ratio = managers.viewport:aspect_ratio()
		local res = RenderSettings.resolution
		load_level_data.gui_data = {
			safe_rect_pixels = safe_rect_pixels,
			safe_rect = safe_rect,
			aspect_ratio = aspect_ratio,
			res = res,
			workspace_size = {
				y = 0,
				x = 0,
				w = res.x,
				h = res.y
			},
			saferect_size = {
				x = safe_rect.x,
				y = safe_rect.y,
				w = safe_rect.width,
				h = safe_rect.height
			},
			bg_texture = load_data and load_data.image or "ui/loading_screens/loading_flak"
		}
	elseif not Global.boot_loading_environment_done then
		setup = "lib/setups/LightLoadingSetup"
	else
		setup = "lib/setups/HeavyLoadingSetup"
	end

	local data = {
		res = RenderSettings.resolution,
		layer = tweak_data.gui.LOADING_SCREEN_LAYER,
		load_level_data = load_level_data,
		is_win32 = IS_PC
	}
	Global.is_loading = true
end

function Setup:_setup_loading_environment()
	local env_map = {
		deferred = {
			shadow = {
				shadow_slice_depths = Vector3(800, 1600, 5500),
				shadow_slice_overlap = Vector3(150, 300, 400),
				slice0 = Vector3(0, 800, 0),
				slice1 = Vector3(650, 1600, 0),
				slice2 = Vector3(1300, 5500, 0),
				slice3 = Vector3(5100, 17500, 0)
			},
			apply_ambient = {
				effect_light_scale = 1,
				ambient_falloff_scale = 0,
				ambient_scale = 1,
				ambient_color_scale = 0.31999999284744,
				ambient_color = Vector3(1, 1, 1),
				sky_top_color = Vector3(0, 0, 0),
				sky_bottom_color = Vector3(0, 0, 0)
			}
		},
		shadow_processor = {
			shadow_modifier = {
				slice0 = Vector3(0, 800, 0),
				slice1 = Vector3(650, 1600, 0),
				slice2 = Vector3(1300, 5500, 0),
				slice3 = Vector3(5100, 17500, 0),
				shadow_slice_depths = Vector3(800, 1600, 5500),
				shadow_slice_overlap = Vector3(150, 300, 400)
			}
		}
	}
	local dummy_vp = Application:create_world_viewport(0, 0, 1, 1)

	LoadingEnvironment:viewport():set_post_processor_effect("World", Idstring("dof_prepare_post_processor"), Idstring("empty"))
	LoadingEnvironment:viewport():set_post_processor_effect("World", Idstring("bloom_combine_post_processor"), Idstring("bloom_combine_empty"))
	Application:destroy_viewport(dummy_vp)
end

function Setup:init_game()
	if not Global.initialized then
		Global.level_data = {}
		Global.initialized = true
	end

	self._end_frame_clbks = {}
	local scene_gui = Overlay:gui()
	self._main_thread_loading_screen_gui_script = LightLoadingScreenGuiScript:new(scene_gui, RenderSettings.resolution, -1, tweak_data.gui.LOADING_SCREEN_LAYER, IS_PC)
	self._main_thread_loading_screen_gui_visible = true

	return game_state_machine
end

function Setup:init_finalize()
	Setup.super.init_finalize(self)
	game_state_machine:init_finilize()
	managers.dlc:init_finalize()
	managers.achievment:init_finalize()
	managers.system_menu:init_finalize()
	managers.controller:init_finalize()

	if Application:editor() then
		managers.user:init_finalize()
	end

	managers.blackmarket:init_finalize()

	if IS_PC then
		AnimationManager:set_anim_cache_size(10485760, 0)
	end

	tweak_data:add_reload_callback(self, self.on_tweak_data_reloaded)
end

function Setup:update(t, dt)
	local main_t = TimerManager:main():time()
	local main_dt = TimerManager:main():delta_time()

	managers.weapon_factory:update(t, dt)
	managers.platform:update(t, dt)
	managers.user:update(t, dt)
	managers.dyn_resource:update()
	managers.system_menu:update(main_t, main_dt)
	managers.savefile:update(t, dt)
	managers.menu:update(main_t, main_dt)
	managers.player:update(t, dt)
	managers.blackmarket:update(t, dt)
	managers.vote:update(t, dt)
	managers.vehicle:update(t, dt)
	managers.progression:update(t, dt)
	managers.video:update(t, dt)
	game_state_machine:update(t, dt)
	managers.challenge_cards:update(t, dt)

	if self._main_thread_loading_screen_gui_visible then
		self._main_thread_loading_screen_gui_script:update(-1, dt)
	end
end

function Setup:paused_update(t, dt)
	managers.platform:paused_update(t, dt)
	managers.user:paused_update(t, dt)
	managers.dyn_resource:update()
	managers.system_menu:paused_update(t, dt)
	managers.savefile:paused_update(t, dt)
	managers.menu:update(t, dt)
	managers.blackmarket:update(t, dt)
	game_state_machine:paused_update(t, dt)
end

function Setup:end_update(t, dt)
	game_state_machine:end_update(t, dt)

	while #self._end_frame_clbks > 0 do
		table.remove(self._end_frame_clbks, 1)()
	end
end

function Setup:paused_end_update(t, dt)
	game_state_machine:end_update(t, dt)

	while #self._end_frame_clbks > 0 do
		table.remove(self._end_frame_clbks, 1)()
	end
end

function Setup:end_frame(t, dt)
	while self._end_frame_callbacks and #self._end_frame_callbacks > 0 do
		table.remove(self._end_frame_callbacks)()
	end

	self:_upd_unload_packages()
end

function Setup:add_end_frame_callback(callback)
	self._end_frame_callbacks = self._end_frame_callbacks or {}

	table.insert(self._end_frame_callbacks, callback)
end

function Setup:add_end_frame_clbk(func)
	table.insert(self._end_frame_clbks, func)
end

function Setup:on_tweak_data_reloaded()
	managers.dlc:on_tweak_data_reloaded()
	managers.voice_over:on_tweak_data_reloaded()
end

function Setup:destroy()
	managers.system_menu:destroy()
	managers.menu:destroy()

	if self._main_thread_loading_screen_gui_script then
		self._main_thread_loading_screen_gui_script:destroy()

		self._main_thread_loading_screen_gui_script = nil
	end
end

function Setup:load_level(level, mission, world_setting, level_class_name, level_id)
	managers.menu:close_all_menus()
	managers.platform:destroy_context()

	Global.load_level = true
	Global.load_start_menu = false
	Global.load_start_menu_lobby = false
	Global.level_data.level = level
	Global.level_data.mission = mission
	Global.level_data.world_setting = world_setting
	Global.level_data.level_class_name = level_class_name
	Global.level_data.level_id = level_id

	self:exec(level)
end

function Setup:load_start_menu_lobby()
	self:load_start_menu()

	Global.load_start_menu_lobby = true
end

function Setup:load_start_menu(save_progress)
	Application:trace("[Setup:load_start_menu()]")
	managers.platform:set_playing(false)
	managers.raid_job:deactivate_current_job()
	managers.menu:close_all_menus()
	managers.mission:pre_destroy()
	managers.platform:destroy_context()

	Global.load_level = false
	Global.load_start_menu = true
	Global.load_start_menu_lobby = false
	Global.level_data.level = nil
	Global.level_data.mission = nil
	Global.level_data.world_setting = nil
	Global.level_data.level_class_name = nil
	Global.level_data.level_id = nil

	if save_progress then
		Global.savefile_manager.setting_changed = true

		managers.savefile:save_setting(true)
		managers.savefile:save_progress()
	end

	self:exec(nil)
end

function Setup:exec(context)
	if managers.network then
		if IS_PS4 then
			PSN:set_matchmaking_callback("session_destroyed", function ()
			end)
		end

		print("SETTING BLACK LOADING SCREEN")

		self._black_loading_screen = true

		if Network.set_loading_state then
			Network:set_loading_state(true)
		end
	end

	if IS_PC then
		self:set_fps_cap(30)
	end

	managers.music:stop()
	managers.vote:stop()
	SoundDevice:stop()

	if not managers.system_menu:is_active() then
		self:set_main_thread_loading_screen_visible(true)
	end

	CoreSetup.CoreSetup.exec(self, context)
end

function Setup:quit()
	CoreSetup.CoreSetup.quit(self)

	if not managers.system_menu:is_active() then
		self:set_main_thread_loading_screen_visible(true)
		self._main_thread_loading_screen_gui_script:set_text("Exiting")
	end
end

function Setup:return_to_camp_client()
	if Network:is_client() then
		game_state_machine:change_state_by_name("ingame_standard")
		managers.hud:set_disabled()
		managers.statistics:stop_session({
			quit = true
		})
		managers.raid_job:deactivate_current_job()
		managers.raid_job:cleanup()
		managers.queued_tasks:unqueue_all()
		managers.lootdrop:reset_loot_value_counters()
		managers.consumable_missions:on_level_exited(false)
		managers.greed:on_level_exited(false)
		managers.network:session():send_to_peers("set_peer_left")
		managers.network:stop_network()
		managers.network.matchmake:destroy_game()
		managers.network.voice_chat:destroy_voice()
		managers.network:host_game()
		managers.network:session():load_level(Global.level_data.level, nil, nil, nil, Global.game_settings.level_id)
	end
end

function Setup:quit_to_main_menu()
	game_state_machine:change_state_by_name("ingame_standard")
	managers.platform:set_playing(false)
	managers.statistics:stop_session({
		quit = true
	})
	managers.raid_job:deactivate_current_job()
	managers.raid_job:cleanup()
	managers.lootdrop:reset_loot_value_counters()
	managers.consumable_missions:on_level_exited(false)
	managers.greed:on_level_exited(false)
	managers.worldcollection:on_simulation_ended()
	managers.queued_tasks:unqueue_all()

	if Network:multiplayer() then
		Network:set_multiplayer(false)
		managers.network:session():send_to_peers("set_peer_left")
		managers.network:queue_stop_network()
	end

	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	if setup.exit_to_main_menu then
		setup.exit_to_main_menu = false

		managers.menu:post_event("menu_exit")
		managers.raid_menu:close_all_menus()
		setup:load_start_menu(true)
	end
end

function Setup:restart()
	local data = Global.level_data

	if data.level then
		self:load_level(data.level, data.mission, data.world_setting, data.level_class_name)
	else
		self:load_start_menu()
	end
end

function Setup:block_exec()
	if not self._main_thread_loading_screen_gui_visible then
		self:set_main_thread_loading_screen_visible(true)

		return true
	end

	local result = false

	if self._packages_to_unload then
		print("BLOCKED BY UNLOADING PACKAGES")

		result = true
	elseif not self._packages_to_unload_gathered then
		self._packages_to_unload_gathered = true

		self:gather_packages_to_unload()

		result = true
	end

	if managers.worldcollection and managers.worldcollection:has_queued_unloads() then
		print("BLOCKED BY WORLD IN WORLD UNLOADING PACKAGES")

		result = true
	end

	if not managers.network:is_ready_to_load() then
		print("BLOCKED BY STOPPING NETWORK")

		result = true
	end

	if not managers.dyn_resource:is_ready_to_close() then
		if not self._blocked_by_msg then
			print("BLOCKED BY DYNAMIC RESOURCE MANAGER")

			self._blocked_by_msg = true
		end

		result = true
	end

	if managers.system_menu:block_exec() then
		result = true
	end

	if managers.savefile:is_active() then
		result = true
	end

	return result
end

function Setup:block_quit()
	return self:block_exec()
end

function Setup:set_main_thread_loading_screen_visible(visible)
	if not self._main_thread_loading_screen_gui_visible ~= not visible then
		cat_print("loading_environment", "[LoadingEnvironment] Main thread loading screen visible: " .. tostring(visible))
		self._main_thread_loading_screen_gui_script:set_visible(visible, RenderSettings.resolution)

		self._main_thread_loading_screen_gui_visible = visible
	end
end

function Setup:set_fps_cap(value)
	if not self._framerate_low then
		Application:cap_framerate(value)
	end
end

function Setup:_unload_pkg_with_init(pkg)
	Application:debug("[Setup:_unload_pkg_with_init] Unloading...", pkg)

	local init_pkg = pkg .. "_init"

	if PackageManager:loaded(init_pkg) then
		PackageManager:unload(init_pkg)
	end

	if PackageManager:loaded(pkg) then
		PackageManager:unload(pkg)
	end
end

function Setup:_upd_unload_packages()
	if self._packages_to_unload then
		local package_name = table.remove(self._packages_to_unload)

		if package_name then
			PackageManager:unload(package_name)
		end

		if not next(self._packages_to_unload) then
			self._packages_to_unload = nil
		end
	end

	if Global.package_ref_counter then
		for package, count in pairs(Global.package_ref_counter) do
			if count == 0 or Global.unload_all_level_packages then
				if PackageManager:loaded(package) then
					Application:debug("[Setup:_upd_unload_packages()] Unloading package:", package)
					PackageManager:unload(package)
				end

				Global.package_ref_counter[package] = nil
			end
		end

		if Global.unload_all_level_packages then
			Global.unload_all_level_packages = false
		end
	end

	if self._unload_async_camp then
		self._unload_async_camp = false

		if Global.STREAM_ALL_PACKAGES then
			self:unload_camp_packages()
		end
	end
end

function Setup:is_unloading()
	return self._started_unloading_packages and true
end
