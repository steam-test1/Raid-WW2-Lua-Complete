TweakData = TweakData or class()
TweakData.RELOAD = true
TweakData.DIFFICULTY_1 = 1
TweakData.DIFFICULTY_2 = 2
TweakData.DIFFICULTY_3 = 3
TweakData.DIFFICULTY_4 = 4

require("lib/tweak_data/WeaponTweakData")
require("lib/tweak_data/EquipmentsTweakData")
require("lib/tweak_data/CharacterTweakData")
require("lib/tweak_data/PlayerTweakData")
require("lib/tweak_data/StatisticsTweakData")
require("lib/tweak_data/LevelsTweakData")
require("lib/tweak_data/GroupAITweakData")
require("lib/tweak_data/DramaTweakData")
require("lib/tweak_data/UpgradesTweakData")
require("lib/tweak_data/HudIconsTweakData")
require("lib/tweak_data/TipsTweakData")
require("lib/tweak_data/BlackMarketTweakData")
require("lib/tweak_data/CarryTweakData")
require("lib/tweak_data/AttentionTweakData")
require("lib/tweak_data/OperationsTweakData")
require("lib/tweak_data/SkillTreeTweakData")
require("lib/tweak_data/TimeSpeedEffectTweakData")
require("lib/tweak_data/SoundTweakData")
require("lib/tweak_data/EventsTweakData")
require("lib/tweak_data/LootDropTweakData")
require("lib/tweak_data/GuiTweakData")
require("lib/tweak_data/GreedTweakData")
require("lib/tweak_data/DLCTweakData")
require("lib/tweak_data/InteractionTweakData")
require("lib/tweak_data/VehicleTweakData")
require("lib/tweak_data/MountedWeaponTweakData")
require("lib/tweak_data/CommWheelTweakData")
require("lib/tweak_data/BarrageTweakData")
require("lib/tweak_data/AchievementTweakData")
require("lib/tweak_data/ProjectilesTweakData")
require("lib/tweak_data/DropLootTweakData")
require("lib/tweak_data/CharacterCustomizationTweakData")
require("lib/tweak_data/CampCustomizationTweakData")
require("lib/tweak_data/ChallengeCardsTweakData")
require("lib/tweak_data/ChallengeTweakData")
require("lib/tweak_data/WeaponSkillsTweakData")
require("lib/tweak_data/WarcryTweakData")
require("lib/tweak_data/WeaponInventoryTweakData")
require("lib/tweak_data/SubtitlesTweakData")
require("lib/tweak_data/InputTweakData")
require("lib/tweak_data/IntelTweakData")
require("lib/tweak_data/NetworkTweakData")
require("lib/tweak_data/LinkPrefabsTweakData")
require("lib/tweak_data/FireTweakData")
require("lib/tweak_data/ExplosionTweakData")

function TweakData:digest_tweak_data()
	self.digested_tables = {
		"experience_manager"
	}

	for i, digest_me in ipairs(self.digested_tables) do
		self:digest_recursive(self[digest_me])
	end
end

function TweakData:digest_recursive(key, parent)
	local value = parent and parent[key] or key

	if type(value) == "table" then
		for index, data in pairs(value) do
			self:digest_recursive(index, value)
		end
	elseif type(value) == "number" then
		parent[key] = Application:digest_value(value, true)
	end
end

function TweakData:get_value(...)
	local arg = {
		...
	}
	local value = self

	for _, v in ipairs(arg) do
		if not value[v] then
			return false
		end

		value = value[v]
	end

	if type(value) == "string" then
		return Application:digest_value(value, false)
	elseif type(value) == "table" then
		Application:debug("TweakData:get_value() value was a table, is this correct? returning false!", inspect(arg), inspect(value))

		return false
	end

	return value
end

function TweakData:get_raw_value(...)
	local arg = {
		...
	}
	local value = self
	local v = nil

	for i = 1, #arg do
		v = arg[i]

		if not value[v] then
			return nil, v, i
		end

		value = value[v]
	end

	return value
end

function TweakData:set_mode()
	if not Global.game_settings then
		return
	end

	if Global.game_settings.single_player then
		self:_set_singleplayer()
	else
		self:_set_multiplayer()
	end
end

function TweakData:_set_singleplayer()
	self.player:_set_singleplayer()
end

function TweakData:_set_multiplayer()
	self.player:_set_multiplayer()
end

function TweakData:set_difficulty(value)
	if not value then
		debug_pause("[TweakData:set_difficulty] is nil")

		return
	end

	Global.game_settings.difficulty = value

	if Global.game_settings.difficulty == "difficulty_1" then
		self:_set_difficulty_1()
	elseif Global.game_settings.difficulty == "difficulty_2" then
		self:_set_difficulty_2()
	elseif Global.game_settings.difficulty == "difficulty_3" then
		self:_set_difficulty_3()
	elseif Global.game_settings.difficulty == "difficulty_4" then
		self:_set_difficulty_4()
	else
		debug_pause("[TweakData][set_difficulty()] Setting invalid difficulty: ", value)
	end
end

function TweakData:_set_difficulty_1()
	self.player:_set_difficulty_1()
	self.character:set_difficulty(1)
	self.weapon:_set_difficulty_1()
	self.group_ai:init(self)
	self.barrage:init(self)

	self.difficulty_name_id = self.difficulty_name_ids.difficulty_1
	self.lootcrate_pattern_total = 24
end

function TweakData:_set_difficulty_2()
	self.player:_set_difficulty_2()
	self.character:set_difficulty(2)
	self.weapon:_set_difficulty_2()
	self.group_ai:init(self)
	self.barrage:init(self)

	self.difficulty_name_id = self.difficulty_name_ids.difficulty_2
	self.lootcrate_pattern_total = 24
end

function TweakData:_set_difficulty_3()
	self.player:_set_difficulty_3()
	self.character:set_difficulty(3)
	self.weapon:_set_difficulty_3()
	self.group_ai:init(self)
	self.barrage:init(self)

	self.difficulty_name_id = self.difficulty_name_ids.difficulty_3
	self.lootcrate_pattern_total = 26
end

function TweakData:_set_difficulty_4()
	self.player:_set_difficulty_4()
	self.character:set_difficulty(4)
	self.weapon:_set_difficulty_4()
	self.group_ai:init(self)
	self.barrage:init(self)

	self.difficulty_name_id = self.difficulty_name_ids.difficulty_4
	self.lootcrate_pattern_total = 28
end

function TweakData:number_of_difficulties()
	return #self.difficulties
end

function TweakData:difficulty_to_index(difficulty)
	return table.index_of(self.difficulties, difficulty)
end

function TweakData:index_to_difficulty(index)
	return self.difficulties[index]
end

function TweakData:get_difficulty_string_name_from_index(index)
	local difficulty_index_name = self:index_to_difficulty(index)

	return self.difficulty_name_ids[difficulty_index_name]
end

function TweakData:permission_to_index(permission)
	return table.index_of(self.permissions, permission)
end

function TweakData:index_to_permission(index)
	return self.permissions[index]
end

function TweakData:server_state_to_index(state)
	return table.index_of(self.server_states, state)
end

function TweakData:index_to_server_state(index)
	return self.server_states[index]
end

function TweakData:menu_sync_state_to_index(state)
	if not state then
		return false
	end

	for i, menu_sync in ipairs(self.menu_sync_states) do
		if menu_sync == state then
			return i
		end
	end
end

function TweakData:index_to_menu_sync_state(index)
	return self.menu_sync_states[index]
end

function TweakData:init_common_effects_physics()
	self.physics_effects = {
		body_explosion = Idstring("physic_effects/body_explosion"),
		shotgun_push = Idstring("physic_effects/shotgun_hit"),
		molotov_throw = Idstring("physic_effects/molotov_throw"),
		no_gravity = Idstring("physic_effects/anti_gravitate"),
		damp_rotation = Idstring("physic_effects/damp_rotation")
	}
	self.common_effects = {
		impact = Idstring("effects/vanilla/impacts/imp_fallback_001"),
		blood_impact_1 = Idstring("effects/vanilla/impacts/imp_blood_hit_001"),
		blood_impact_2 = Idstring("effects/vanilla/impacts/imp_blood_hit_002"),
		blood_impact_3 = Idstring("effects/vanilla/impacts/imp_blood_hit_003"),
		blood_screen = Idstring("effects/vanilla/dismemberment/dis_blood_screen_001"),
		taser_hit = Idstring("effects/vanilla/character/taser_hittarget_001"),
		taser_thread = Idstring("effects/vanilla/character/taser_thread"),
		taser_stop = Idstring("effects/vanilla/character/taser_stop"),
		fps_flashlight = Idstring("effects/vanilla/weapons/flashlight/fp_flashlight"),
		flamer_burst = Idstring("effects/vanilla/fire/fire_flame_burst_001"),
		flamer_nosel = Idstring("effects/vanilla/explosions/exp_flamer_nosel_001"),
		flamer_pilot = Idstring("effects/vanilla/fire/fire_flame_burst_pilot_001"),
		fire_gen_medium = Idstring("effects/vanilla/fire/fire_medium_001"),
		fire_molotov_grenade = Idstring("effects/vanilla/fire/fire_molotov_grenade_001"),
		flash_grenade_bang = Idstring("effects/particles/explosions/explosion_flash_grenade"),
		smoke_grenade_bang = Idstring("effects/vanilla/explosions/exp_smoke_grenade_001"),
		smoke_grenade = Idstring("effects/vanilla/weapons/smoke_grenade_smoke")
	}
end

function TweakData:init()
	self.difficulties = {
		"difficulty_1",
		"difficulty_2",
		"difficulty_3",
		"difficulty_4"
	}
	self.hardest_difficulty = {
		id = 4
	}
	self.difficulty_name_ids = {}

	for i, v in ipairs(self.difficulties) do
		self.difficulty_name_ids[v] = "menu_" .. v
	end

	self.lootcrate_pattern_total = 999
	self.lootcrate_tiers = {
		4,
		6,
		3
	}
	self.permissions = {
		"public",
		"friends_only",
		"private"
	}
	self.server_states = {
		"in_lobby",
		"loading",
		"in_game"
	}
	self.menu_sync_states = {
		"crimenet",
		"skilltree",
		"options",
		"lobby",
		"blackmarket",
		"blackmarket_weapon",
		"blackmarket_mask",
		"payday"
	}

	self:init_common_effects_physics()

	self.WEAPON_SLOT_SECONDARY = 1
	self.WEAPON_SLOT_PRIMARY = 2
	self.WEAPON_SLOT_GRENADE = 3
	self.WEAPON_SLOT_MELEE = 4
	self.weapon = WeaponTweakData:new(self)
	self.hud_icons = HudIconsTweakData:new()
	self.equipments = EquipmentsTweakData:new()
	self.player = PlayerTweakData:new()
	self.character = CharacterTweakData:new(self)
	self.greed = GreedTweakData:new()
	self.carry = CarryTweakData:new(self)
	self.character_customization = CharacterCustomizationTweakData:new()
	self.camp_customization = CampCustomizationTweakData:new()
	self.statistics = StatisticsTweakData:new()
	self.levels = LevelsTweakData:new()
	self.operations = OperationsTweakData:new()
	self.group_ai = GroupAITweakData:new(self)
	self.drama = DramaTweakData:new()
	self.upgrades = UpgradesTweakData:new()
	self.gui = GuiTweakData:new()
	self.skilltree = SkillTreeTweakData:new(self)
	self.tips = TipsTweakData:new()
	self.blackmarket = BlackMarketTweakData:new(self)
	self.attention = AttentionTweakData:new()
	self.timespeed = TimeSpeedEffectTweakData:new()
	self.sound = SoundTweakData:new()
	self.events = EventsTweakData:new(self)
	self.lootdrop = LootDropTweakData:new(self)
	self.drop_loot = DropLootTweakData:new(self)
	self.dlc = DLCTweakData:new(self)
	self.interaction = InteractionTweakData:new(self)
	self.vehicle = VehicleTweakData:new(self)
	self.mounted_weapon = MountedWeaponTweakData:new(self)
	self.comm_wheel = CommWheelTweakData:new(self)
	self.barrage = BarrageTweakData:new(self)
	self.achievement = AchievementTweakData:new(self)
	self.projectiles = ProjectilesTweakData:new(self)
	self.challenge = ChallengeTweakData:new(self)
	self.weapon_skills = WeaponSkillsTweakData:new(self)
	self.warcry = WarcryTweakData:new(self)
	self.challenge_cards = ChallengeCardsTweakData:new(self)
	self.weapon_inventory = WeaponInventoryTweakData:new(self)
	self.subtitles = SubtitlesTweakData:new(self)
	self.input = InputTweakData:new(self)
	self.intel = IntelTweakData:new(self)
	self.network = NetworkTweakData:new(self)
	self.link_prefabs = LinkPrefabsTweakData:new()
	self.fire = FireTweakData:new(self)
	self.explosion = ExplosionTweakData:new(self)
	self.criminals = {
		character_names = {
			"russian",
			"german",
			"british",
			"american"
		},
		character_nations = {
			"british",
			"russian",
			"american",
			"german"
		},
		character_nation_name = {}
	}
	self.criminals.character_nation_name.russian = {
		char_name = "Kurgan",
		flag_name = "ico_flag_russian"
	}
	self.criminals.character_nation_name.german = {
		char_name = "Wolfgang",
		flag_name = "ico_flag_german"
	}
	self.criminals.character_nation_name.british = {
		char_name = "Sterling",
		flag_name = "ico_flag_british"
	}
	self.criminals.character_nation_name.american = {
		char_name = "Rivet",
		flag_name = "ico_flag_american"
	}
	self.criminals.characters = {
		{
			name = "german",
			static_data = {
				voice = "germ",
				color_id = 1,
				ssuffix = "l",
				ai_character_id = "ai_german",
				mask_id = 1
			}
		},
		{
			name = "russian",
			static_data = {
				voice = "russ",
				color_id = 2,
				ssuffix = "c",
				ai_character_id = "ai_russian",
				mask_id = 2
			}
		},
		{
			name = "american",
			static_data = {
				voice = "amer",
				color_id = 3,
				ssuffix = "a",
				ai_character_id = "ai_american",
				mask_id = 3
			}
		},
		{
			name = "british",
			static_data = {
				voice = "brit",
				color_id = 4,
				ssuffix = "b",
				ai_character_id = "ai_british",
				mask_id = 4
			}
		}
	}
	self.criminals.loud_teleport_distance_treshold = 9000000
	self.EFFECT_QUALITY = 0.5

	self:set_scale()

	self.states = {}
	self.menu = {
		BRIGHTNESS_CHANGE = 0.05,
		MIN_BRIGHTNESS = 0.5,
		MAX_BRIGHTNESS = 1.5,
		MUSIC_CHANGE = 10,
		MIN_MUSIC_VOLUME = 0,
		MAX_MUSIC_VOLUME = 100,
		VOICE_OVER_CHANGE = 10,
		MIN_VOICE_OVER_VOLUME = 0,
		MAX_VOICE_OVER_VOLUME = 100,
		SFX_CHANGE = 10,
		MIN_SFX_VOLUME = 0,
		MAX_SFX_VOLUME = 100,
		VOICE_CHANGE = 0.05,
		MIN_VOICE_VOLUME = 0,
		MAX_VOICE_VOLUME = 1
	}

	self:set_menu_scale()

	local orange = Vector3(204, 161, 102) / 255
	local green = Vector3(194, 252, 151) / 255
	local brown = Vector3(178, 104, 89) / 255
	local blue = Vector3(120, 183, 204) / 255
	local team_ai = Vector3(0.2, 0.8, 1)
	self.peer_vector_colors = {
		green,
		blue,
		brown,
		orange,
		team_ai
	}
	self.peer_colors = {
		"mrgreen",
		"mrblue",
		"mrbrown",
		"mrorange",
		"mrai"
	}
	self.chat_colors = {
		Color(self.peer_vector_colors[1]:unpack()),
		Color(self.peer_vector_colors[2]:unpack()),
		Color(self.peer_vector_colors[3]:unpack()),
		Color(self.peer_vector_colors[4]:unpack()),
		Color(self.peer_vector_colors[5]:unpack())
	}
	self.screen_colors = {
		text = Color(255, 255, 255, 255) / 255,
		resource = Color(255, 77, 198, 255) / 255,
		important_1 = Color(255, 255, 51, 51) / 255,
		important_2 = Color(125, 255, 51, 51) / 255,
		item_stage_1 = Color(255, 255, 255, 255) / 255,
		item_stage_2 = Color(255, 89, 115, 128) / 255,
		item_stage_3 = Color(255, 23, 33, 38) / 255,
		button_stage_1 = Color(255, 0, 0, 0) / 255,
		button_stage_2 = Color(255, 255, 50, 50) / 255,
		button_stage_3 = Color(240, 240, 240, 240) / 255,
		risk = Color(255, 255, 204, 0) / 255,
		friend_color = Color(255, 41, 204, 122) / 255,
		regular_color = Color(255, 41, 150, 240) / 255,
		pro_color = Color(255, 255, 51, 51) / 255,
		dlc_color = Color(255, 255, 212, 0) / 255,
		skill_color = Color(255, 77, 198, 255) / 255,
		ghost_color = Color("4ca6ff"),
		extra_bonus_color = Color(255, 255, 255, 255) / 255,
		community_color = Color(255, 59, 174, 254) / 255,
		challenge_completed_color = Color(255, 255, 168, 0) / 255,
		stats_positive = Color(255, 191, 221, 125) / 255,
		stats_negative = Color(255, 254, 93, 99) / 255,
		stats_mods = Color(255, 229, 229, 76) / 255
	}

	if Global.test_new_colors then
		for i, d in pairs(self.screen_colors) do
			self.screen_colors[i] = Color.purple
		end
	end

	if Global.old_colors_purple then
		self.screen_color_white = Color.purple
		self.screen_color_red = Color.purple
		self.screen_color_green = Color.purple
		self.screen_color_grey = Color.purple
		self.screen_color_light_grey = Color.purple
		self.screen_color_blue = Color.purple
		self.screen_color_blue_selected = Color.purple
		self.screen_color_blue_highlighted = Color.purple
		self.screen_color_blue_noselected = Color.purple
		self.screen_color_yellow = Color.purple
		self.screen_color_yellow_selected = Color.purple
		self.screen_color_yellow_noselected = Color.purple
	else
		self.screen_color_white = Color(1, 1, 1)
		self.screen_color_red = Color(0.7137254901960784, 0.24705882352941178, 0.21176470588235294)
		self.screen_color_green = Color(0.12549019607843137, 1, 0.5176470588235295)
		self.screen_color_grey = Color(0.39215686274509803, 0.39215686274509803, 0.39215686274509803)
		self.screen_color_light_grey = Color(0.7843137254901961, 0.7843137254901961, 0.7843137254901961)
		self.screen_color_blue = Color(0.30196078431372547, 0.7764705882352941, 1)
		self.screen_color_blue_selected = Color(0.30196078431372547, 0.7764705882352941, 1)
		self.screen_color_blue_highlighted = self.screen_color_blue_selected:with_alpha(0.75)
		self.screen_color_blue_noselected = self.screen_color_blue_selected:with_alpha(0.5)
		self.screen_color_yellow = Color(0.8627450980392157, 0.6745098039215687, 0.17647058823529413)
		self.screen_color_yellow_selected = Color(1, 0.8, 0)
		self.screen_color_yellow_noselected = Color(0.7333333333333333, 0.42745098039215684, 0.0784313725490196)
	end

	self.dialog = {
		WIDTH = 400,
		HEIGHT = 300,
		PADDING = 30,
		BUTTON_PADDING = 5,
		BUTTON_SPACING = 10,
		FONT = self.menu.default_font,
		BG_COLOR = self.menu.default_menu_background_color,
		TITLE_TEXT_COLOR = Color(1, 1, 1, 1),
		TEXT_COLOR = self.menu.default_font_row_item_color,
		BUTTON_BG_COLOR = Color(0, 0.5, 0.5, 0.5),
		BUTTON_TEXT_COLOR = self.menu.default_font_row_item_color,
		SELECTED_BUTTON_BG_COLOR = self.menu.default_font_row_item_color,
		SELECTED_BUTTON_TEXT_COLOR = self.menu.default_hightlight_row_item_color,
		TITLE_SIZE = self.menu.topic_font_size,
		TEXT_SIZE = self.menu.dialog_text_font_size,
		BUTTON_SIZE = self.menu.dialog_title_font_size,
		TITLE_TEXT_SPACING = 20,
		BUTTON_TEXT_SPACING = 3,
		DEFAULT_PRIORITY = 1,
		MINIMUM_DURATION = 2,
		DURATION_PER_CHAR = 0.07
	}
	self.motion_dot_modes = {
		"off",
		"single",
		"double_hor",
		"double_ver",
		"quad_diag",
		"quad_plus"
	}
	self.motion_dot_modes_ads_hides = {
		false,
		true,
		false,
		false,
		false,
		false
	}
	self.motion_dot_sizes = {
		"tiny",
		"small",
		"medium",
		"large",
		"huge"
	}
	self.hit_indicator_modes = {
		"off",
		"min",
		"on",
		"track"
	}
	self.corpse_limit = {
		max = 250,
		min = 5
	}
	self.hud = {}

	self:set_hud_values()

	self.gui = self.gui or {}
	self.gui.BOOT_SCREEN_LAYER = 1
	self.gui.TITLE_SCREEN_LAYER = 1
	self.gui.MENU_LAYER = 200
	self.gui.MENU_COMPONENT_LAYER = 300
	self.gui.ATTRACT_SCREEN_LAYER = 400
	self.gui.LOADING_SCREEN_LAYER = 3000
	self.gui.CRIMENET_CHAT_LAYER = 3000
	self.gui.DIALOG_LAYER = 3100
	self.gui.MOUSE_LAYER = 3200
	self.overlay_effects = {
		spectator = {
			fade_out = 2,
			fade_in = 3,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		level_fade_in = {
			fade_out = 3,
			fade_in = 0,
			sustain = 1,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:game()
		},
		fade_in = {
			fade_out = 3,
			fade_in = 0,
			sustain = 0,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out = {
			fade_out = 0,
			fade_in = 3,
			sustain = 30,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out_permanent = {
			fade_out = 0,
			fade_in = 1,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		fade_out_in = {
			fade_out = 1,
			fade_in = 1,
			sustain = 1,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		element_fade_in = {
			fade_out = 3,
			fade_in = 0,
			sustain = 0,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		},
		element_fade_out = {
			fade_out = 0,
			fade_in = 3,
			sustain = 0,
			play_paused = true,
			blend_mode = "normal",
			color = Color(1, 0, 0, 0),
			timer = TimerManager:main()
		}
	}
	local d_color = Color(0.75, 1, 1, 1)
	local d_sustain = 0.1
	local d_fade_out = 0.9
	self.overlay_effects.damage = {
		fade_in = 0,
		blend_mode = "add",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color
	}
	self.overlay_effects.damage_left = {
		fade_in = 0,
		blend_mode = "add",
		orientation = "horizontal",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			0,
			d_color,
			0.1,
			d_color,
			0.15,
			Color():with_alpha(0),
			1,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_right = {
		fade_in = 0,
		blend_mode = "add",
		orientation = "horizontal",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			1,
			d_color,
			0.9,
			d_color,
			0.85,
			Color():with_alpha(0),
			0,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_up = {
		fade_in = 0,
		blend_mode = "add",
		orientation = "vertical",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			0,
			d_color,
			0.1,
			d_color,
			0.15,
			Color():with_alpha(0),
			1,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.damage_down = {
		fade_in = 0,
		blend_mode = "add",
		orientation = "vertical",
		sustain = d_sustain,
		fade_out = d_fade_out,
		color = d_color,
		gradient_points = {
			1,
			d_color,
			0.9,
			d_color,
			0.85,
			Color():with_alpha(0),
			0,
			Color():with_alpha(0)
		}
	}
	self.overlay_effects.maingun_zoomed = {
		fade_out = 0.4,
		fade_in = 0,
		sustain = 0,
		blend_mode = "add",
		color = Color(0.1, 1, 1, 1)
	}
	self.overlay_effects.fade_out_e3_demo = {
		text_blend_mode = "add",
		font = "fonts/font_large_mf",
		font_size = 44,
		play_paused = true,
		fade_out = 0,
		fade_in = 3,
		sustain = 20,
		text_to_upper = true,
		blend_mode = "normal",
		text = [[
Great job, Raid gang!

You've reached the end of our PAX EAST demo.
]],
		color = Color(1, 0, 0, 0),
		timer = TimerManager:main(),
		text_color = Color(255, 255, 204, 0) / 255
	}
	self.materials = {
		[Idstring("concrete"):key()] = "concrete",
		[Idstring("ceramic"):key()] = "ceramic",
		[Idstring("marble"):key()] = "marble",
		[Idstring("flesh"):key()] = "flesh",
		[Idstring("parket"):key()] = "parket",
		[Idstring("sheet_metal"):key()] = "sheet_metal",
		[Idstring("iron"):key()] = "iron",
		[Idstring("wood"):key()] = "wood",
		[Idstring("gravel"):key()] = "gravel",
		[Idstring("cloth"):key()] = "cloth",
		[Idstring("cloth_no_decal"):key()] = "cloth",
		[Idstring("cloth_stuffed"):key()] = "cloth_stuffed",
		[Idstring("dirt"):key()] = "dirt",
		[Idstring("grass"):key()] = "grass",
		[Idstring("carpet"):key()] = "carpet",
		[Idstring("metal"):key()] = "metal",
		[Idstring("glass_breakable"):key()] = "glass_breakable",
		[Idstring("glass_unbreakable"):key()] = "glass_unbreakable",
		[Idstring("glass_no_decal"):key()] = "glass_unbreakable",
		[Idstring("rubber"):key()] = "rubber",
		[Idstring("plastic"):key()] = "plastic",
		[Idstring("asphalt"):key()] = "asphalt",
		[Idstring("foliage"):key()] = "foliage",
		[Idstring("stone"):key()] = "stone",
		[Idstring("sand"):key()] = "sand",
		[Idstring("thin_layer"):key()] = "thin_layer",
		[Idstring("no_decal"):key()] = "silent_material",
		[Idstring("plaster"):key()] = "plaster",
		[Idstring("no_material"):key()] = "no_material",
		[Idstring("paper"):key()] = "paper",
		[Idstring("metal_hollow"):key()] = "metal_hollow",
		[Idstring("metal_chassis"):key()] = "metal_chassis",
		[Idstring("metal_catwalk"):key()] = "metal_catwalk",
		[Idstring("hardwood"):key()] = "hardwood",
		[Idstring("fence"):key()] = "fence",
		[Idstring("steel"):key()] = "steel",
		[Idstring("steel_no_decal"):key()] = "steel",
		[Idstring("tile"):key()] = "tile",
		[Idstring("water_deep"):key()] = "water_deep",
		[Idstring("water_puddle"):key()] = "water_puddle",
		[Idstring("water_shallow"):key()] = "water_shallow",
		[Idstring("shield"):key()] = "shield",
		[Idstring("heavy_swat_steel_no_decal"):key()] = "shield",
		[Idstring("glass"):key()] = "glass",
		[Idstring("metalsheet"):key()] = "metalsheet",
		[Idstring("mud"):key()] = "mud",
		[Idstring("puddle"):key()] = "puddle",
		[Idstring("water"):key()] = "water",
		[Idstring("car"):key()] = "car",
		[Idstring("brick"):key()] = "brick",
		[Idstring("helmet"):key()] = "metalsheet",
		[Idstring("snow"):key()] = "snow",
		[Idstring("ice"):key()] = "ice_thick",
		[Idstring("flamer_metal"):key()] = "flamer_metal"
	}
	self.materials_effects = {
		[Idstring(""):key()] = {},
		[Idstring("water_deep"):key()] = {
			land = Idstring("effects/vanilla/character/step_water_shallow")
		},
		[Idstring("water_puddle"):key()] = {
			step = Idstring("effects/vanilla/character/step_water_shallow"),
			sprint = Idstring("effects/vanilla/character/sprint_water_shallow"),
			land = Idstring("effects/vanilla/character/sprint_water_shallow")
		},
		[Idstring("water_shallow"):key()] = {
			step = Idstring("effects/vanilla/character/step_water_shallow"),
			sprint = Idstring("effects/vanilla/character/sprint_water_shallow"),
			land = Idstring("effects/vanilla/character/sprint_water_shallow")
		}
	}
	self.screen = {
		fadein_delay = 1
	}
	self.experience_manager = {
		level_failed_multiplier = 0.01,
		human_player_multiplier = {
			1,
			1.25,
			1.35,
			1.5
		},
		level_diff_max_multiplier = 2,
		difficulty_multiplier = {}
	}
	self.experience_manager.difficulty_multiplier[TweakData.DIFFICULTY_1] = 1
	self.experience_manager.difficulty_multiplier[TweakData.DIFFICULTY_2] = 1.5
	self.experience_manager.difficulty_multiplier[TweakData.DIFFICULTY_3] = 2.5
	self.experience_manager.difficulty_multiplier[TweakData.DIFFICULTY_4] = 4
	self.experience_manager.stealth_bonus = 1.5
	self.experience_manager.escort_survived_bonus = 1.3
	self.experience_manager.side_quest_bonus = 1.5
	self.experience_manager.extra_objectives_bonus = 1.25
	self.experience_manager.tiny_objectives_bonus = 1.01
	self.experience_manager.tiny_loot_bonus = 1.01
	self.experience_manager.sugar_high_bonus = 1.5
	local level_xp_requirements = {
		0,
		1200,
		1440,
		1728,
		2074,
		2488,
		2986,
		3583,
		4300,
		5160,
		6192,
		7430,
		8916,
		10254,
		11381,
		12520,
		13771,
		15149,
		16664,
		18330,
		20163,
		22179,
		24397,
		26837,
		29520,
		32472,
		35720,
		39292,
		43221,
		47543,
		52297,
		57527,
		63280,
		69608,
		80049,
		92056,
		105864,
		121744,
		140006,
		161007
	}
	local multiplier = 1
	self.experience_manager.levels = {}

	for i = 1, #level_xp_requirements do
		self.experience_manager.levels[i] = {
			points = level_xp_requirements[i] * multiplier
		}
	end

	local exp_step_start = 5
	local exp_step_end = 193
	local exp_step = 1 / (exp_step_end - exp_step_start)

	for i = 146, exp_step_end do
		self.experience_manager.levels[i] = {
			points = math.round(22000 * exp_step * (i - exp_step_start) - 6000) * multiplier
		}
	end

	self.pickups = {
		equip_safe_key_chain = {
			unit = Idstring("units/vanilla/equipment/equip_safe_key_chain/equip_safe_key_chain_dropped")
		},
		health_big = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_big")
		},
		health_medium = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_medium")
		},
		health_small = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_small")
		},
		health_small_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_small_drop")
		},
		health_medium_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_medium_drop")
		},
		health_big_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/health/pku_health_big_drop")
		},
		ammo_small = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_small")
		},
		ammo_medium = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_medium")
		},
		ammo_big = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_big")
		},
		ammo_small_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_small_drop")
		},
		ammo_medium_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_medium_drop")
		},
		ammo_big_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/ammo/pku_ammo_big_drop")
		},
		grenade_big = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_big")
		},
		grenade_big_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_big_drop")
		},
		grenade_medium = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_medium")
		},
		grenade_medium_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_medium_drop")
		},
		grenade_small = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_small")
		},
		grenade_small_beam = {
			unit = Idstring("units/vanilla/pickups/pku_new_munitions/grenades/pku_grenade_stack_small_drop")
		},
		gold_bar_small = {
			unit = Idstring("units/vanilla/pickups/pku_gold_bars/pku_gold_bar")
		},
		gold_bar_medium = {
			unit = Idstring("units/vanilla/pickups/pku_gold_bars/pku_gold_bars")
		},
		scrap = {
			unit = Idstring("units/vanilla/props/props_wooden_crate_01/props_wooden_crate_scrap_parts")
		},
		candy_simple = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/simple/pku_candy_simple")
		},
		candy_simple_drop = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/simple/pku_candy_simple_drop")
		},
		candy_unlimited_ammo = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/unlimited_ammo/pku_candy_unlimited_ammo_drop")
		},
		candy_armor_pen = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/armor_pen/pku_candy_armor_pen_drop")
		},
		candy_sprint_speed = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/sprint_speed/pku_candy_sprint_speed_drop")
		},
		candy_jump_boost = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/jump_boost/pku_candy_jump_boost_drop")
		},
		candy_atk_dmg = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/atk_dmg/pku_candy_atk_dmg_drop")
		},
		candy_crit_chance = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/crit_chance/pku_candy_crit_chance_drop")
		},
		candy_health_regen = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/health_regen/pku_candy_health_regen_drop")
		},
		candy_god_mode = {
			unit = Idstring("units/upd_candy/pickups/pku_candy/god_mode/pku_candy_god_mode_drop")
		},
		enigma_part_01 = {
			unit = Idstring("units/vanilla/props/props_enigma_machine_part/props_enigma_machine_part_01")
		},
		enigma_part_02 = {
			unit = Idstring("units/vanilla/props/props_enigma_machine_part/props_enigma_machine_part_02")
		},
		enigma_part_03 = {
			unit = Idstring("units/vanilla/props/props_enigma_machine_part/props_enigma_machine_part_03")
		},
		enigma_part_04 = {
			unit = Idstring("units/vanilla/props/props_enigma_machine_part/props_enigma_machine_part_04")
		},
		enigma_part_05 = {
			unit = Idstring("units/vanilla/props/props_enigma_machine_part/props_enigma_machine_part_05")
		},
		officer_documents_01 = {
			unit = Idstring("units/vanilla/equipment/equip_officer_documents/equip_officer_documents_01")
		},
		officer_documents_02 = {
			unit = Idstring("units/vanilla/equipment/equip_officer_documents/equip_officer_documents_02")
		},
		officer_documents_03 = {
			unit = Idstring("units/vanilla/equipment/equip_officer_documents/equip_officer_documents_03")
		},
		officer_documents_04 = {
			unit = Idstring("units/vanilla/equipment/equip_officer_documents/equip_officer_documents_04")
		},
		officer_documents_05 = {
			unit = Idstring("units/vanilla/equipment/equip_officer_documents/equip_officer_documents_05")
		},
		car_key_01 = {
			unit = Idstring("units/vanilla/props/props_car_keys/props_car_keys_01")
		},
		car_key_02 = {
			unit = Idstring("units/vanilla/props/props_car_keys/props_car_keys_02")
		},
		car_key_03 = {
			unit = Idstring("units/vanilla/props/props_car_keys/props_car_keys_03")
		},
		bank_door_key = {
			unit = Idstring("units/vanilla/props/props_bank_door_keys_01/props_bank_door_keys_01")
		},
		code_book = {
			unit = Idstring("units/vanilla/equipment/equip_code_book/equip_code_book_active")
		}
	}
	self.warcry_units = {
		hold_the_line_flag = {
			drop_to_ground = true,
			unit = Idstring("units/upd_022/warcry/wc_flagpole/wc_flagpole"),
			level_seq = {
				"level_1",
				"level_2",
				"level_3",
				"level_4"
			}
		}
	}
	self.danger_zones = {
		0.6,
		0.5,
		0.35,
		0.1
	}
	self.contour = {
		character = {}
	}
	self.contour.character.standard_color = Vector3(0.1, 1, 0.5)
	self.contour.character.friendly_color = Vector3(0.2, 0.8, 1)
	self.contour.character.downed_color = Vector3(1, 0.5, 0)
	self.contour.character.dead_color = Vector3(1, 0.1, 0.1)
	self.contour.character.dangerous_color = Vector3(0.6, 0.2, 0.2)
	self.contour.character.more_dangerous_color = Vector3(1, 0.1, 0.1)
	self.contour.character.ghost_warcry = Vector3(0.3, 0.1, 0.1)
	self.contour.character.sharpshooter_warcry = Vector3(0.15, 0.45, 0.7)
	self.contour.character.silver_bullet_warcry = Vector3(0.592156862745098, 0.8392156862745098, 0.7529411764705882)
	self.contour.character_interactable = {
		standard_color = Vector3(1, 0.5, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.interactable = {
		standard_color = Vector3(1, 0.5, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.contour_off = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(0, 0, 0)
	}
	self.contour.deployable = {
		standard_color = Vector3(0.1, 1, 0.5),
		selected_color = Vector3(1, 1, 1),
		active_color = Vector3(0.1, 0.5, 1),
		interact_color = Vector3(0.1, 1, 0.1),
		disabled_color = Vector3(1, 0.1, 0.1)
	}
	self.contour.upgradable = {
		standard_color = Vector3(0.1, 0.5, 1),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.pickup = {
		standard_color = Vector3(0.1, 1, 0.5),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.interactable_icon = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(0, 1, 0)
	}
	self.contour.interactable_danger = {
		standard_color = Vector3(1, 0.33, 0.04),
		selected_color = Vector3(1, 1, 1)
	}
	self.contour.interactable_look_at = {
		standard_color = Vector3(0, 0, 0),
		selected_color = Vector3(1, 1, 1)
	}
	self.music = {
		camp = {}
	}
	self.music.camp.start = "music_camp"
	self.music.flakturm = {
		start = "music_level_flakturm",
		include_in_shuffle = true
	}
	self.music.train_yard = {
		start = "music_level_trainyard",
		include_in_shuffle = true
	}
	self.music.reichsbank = {
		start = "music_level_treasury",
		include_in_shuffle = true
	}
	self.music.radio_defense = {
		start = "music_radio_defense",
		include_in_shuffle = true
	}
	self.music.ger_bridge = {
		start = "music_level_bridge",
		include_in_shuffle = true
	}
	self.music.castle = {
		start = "music_level_castle",
		include_in_shuffle = true
	}
	self.music.forest_gumpy = {
		start = "consumable_level_music_one",
		include_in_shuffle = true
	}
	self.music.default = deep_clone(self.music.flakturm)
	self.voiceover = {
		idle_delay = 10,
		idle_rnd_delay = 15,
		idle_cooldown = 15
	}
	self.voting = {
		timeout = 30,
		cooldown = 50,
		restart_delay = 3
	}
	self.dot_types = {
		poison = {
			dot_damage = 2,
			dot_length = 10,
			hurt_animation_chance = 0.5,
			damage_class = "PoisonBulletBase"
		}
	}

	self:set_mode()

	if Global.game_settings and Global.game_settings.difficulty then
		self:set_difficulty(Global.game_settings.difficulty)
	end

	self:digest_tweak_data()
end

function TweakData:get_dot_type_data(type)
	return self.dot_types[type]
end

function TweakData:_execute_reload_clbks()
	if self._reload_clbks then
		for key, clbk_data in pairs(self._reload_clbks) do
			if clbk_data.func then
				clbk_data.func(clbk_data.clbk_object)
			end
		end
	end
end

function TweakData:add_reload_callback(object, func)
	self._reload_clbks = self._reload_clbks or {}

	table.insert(self._reload_clbks, {
		clbk_object = object,
		func = func
	})
end

function TweakData:remove_reload_callback(object)
	if self._reload_clbks then
		for i, k in ipairs(self._reload_clbks) do
			if k.clbk_object == object then
				table.remove(self._reload_clbks, i)

				return
			end
		end
	end
end

function TweakData:set_scale()
	local lang_key = SystemInfo:language():key()
	local lang_mods = {
		[Idstring("german"):key()] = {
			large = 0.9,
			small = 1,
			w_interact_multiplier = 1.65,
			sd_w_interact_multiplier = 1.55,
			kit_desc_large = 0.9,
			menu_logo_multiplier = 0.9,
			objectives_text_kern = -1,
			level_up_text_kern = -1.5,
			stats_upgrade_kern = -1,
			sd_menu_border_multiplier = 0.9,
			sd_small = 0.9,
			sd_large = 0.9
		},
		[Idstring("french"):key()] = {
			large = 0.9,
			subtitle_multiplier = 0.85,
			sd_level_up_font_multiplier = 0.9,
			victory_screen_kern = -0.5,
			small = 1,
			w_interact_multiplier = 1.4,
			sd_w_interact_multiplier = 1.3,
			kit_desc_large = 0.9,
			objectives_text_kern = -0.8,
			level_up_text_kern = -1.5,
			stats_upgrade_kern = -1,
			sd_small = 0.95,
			sd_large = 0.9
		},
		[Idstring("italian"):key()] = {
			sd_w_interact_multiplier = 1.5,
			objectives_text_kern = -0.8,
			large = 1,
			w_interact_multiplier = 1.35,
			small = 1,
			sd_small = 1,
			sd_large = 1,
			kit_desc_large = 0.9
		},
		[Idstring("spanish"):key()] = {
			large = 1,
			victory_title_multiplier = 0.9,
			server_list_font_multiplier = 0.9,
			objectives_desc_text_kern = 0,
			upgrade_menu_kern = -1.25,
			sd_level_up_font_multiplier = 0.9,
			small = 1,
			w_interact_multiplier = 1.6,
			sd_w_interact_multiplier = 1.5,
			kit_desc_large = 0.9,
			menu_logo_multiplier = 0.9,
			objectives_text_kern = -0.8,
			level_up_text_kern = -1.5,
			stats_upgrade_kern = -1,
			sd_menu_border_multiplier = 0.85,
			sd_small = 0.9,
			sd_large = 1
		}
	}
	local lang_l_mod = lang_mods[lang_key] and lang_mods[lang_key].large or 1
	local lang_s_mod = lang_mods[lang_key] and lang_mods[lang_key].small or 1
	local lang_lsd_mod = lang_mods[lang_key] and lang_mods[lang_key].sd_large or 1
	local lang_ssd_mod = lang_mods[lang_key] and lang_mods[lang_key].sd_large or 1
	local sd_menu_border_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_menu_border_multiplier or 1
	local stats_upgrade_kern = lang_mods[lang_key] and lang_mods[lang_key].stats_upgrade_kern or 0
	local level_up_text_kern = lang_mods[lang_key] and lang_mods[lang_key].level_up_text_kern or 0
	local victory_screen_kern = lang_mods[lang_key] and lang_mods[lang_key].victory_screen_kern
	local upgrade_menu_kern = lang_mods[lang_key] and lang_mods[lang_key].upgrade_menu_kern
	local mugshot_name_kern = lang_mods[lang_key] and lang_mods[lang_key].mugshot_name_kern
	local menu_logo_multiplier = lang_mods[lang_key] and lang_mods[lang_key].menu_logo_multiplier or 1
	local objectives_text_kern = lang_mods[lang_key] and lang_mods[lang_key].objectives_text_kern
	local objectives_desc_text_kern = lang_mods[lang_key] and lang_mods[lang_key].objectives_desc_text_kern
	local kit_desc_large = lang_mods[lang_key] and lang_mods[lang_key].kit_desc_large or 1
	local sd_level_up_font_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_level_up_font_multiplier or 1
	local sd_w_interact_multiplier = lang_mods[lang_key] and lang_mods[lang_key].sd_w_interact_multiplier or 1
	local w_interact_multiplier = lang_mods[lang_key] and lang_mods[lang_key].w_interact_multiplier or 1
	local server_list_font_multiplier = lang_mods[lang_key] and lang_mods[lang_key].server_list_font_multiplier or 1
	local victory_title_multiplier = lang_mods[lang_key] and lang_mods[lang_key].victory_title_multiplier
	local subtitle_multiplier = lang_mods[lang_key] and lang_mods[lang_key].subtitle_multiplier or 1
	local res = RenderSettings.resolution
	self.sd_scale = {
		is_sd = true,
		title_image_multiplier = 0.6,
		menu_logo_multiplier = 0.575 * menu_logo_multiplier,
		menu_border_multiplier = 0.6 * sd_menu_border_multiplier,
		default_font_multiplier = 0.6 * lang_lsd_mod,
		small_font_multiplier = 0.8 * lang_ssd_mod,
		lobby_info_font_size_scale_multiplier = 0.65,
		lobby_name_font_size_scale_multiplier = 0.6,
		server_list_font_size_multiplier = 0.55,
		multichoice_arrow_multiplier = 0.7,
		align_line_padding_multiplier = 0.4,
		menu_arrow_padding_multiplier = 0.5,
		briefing_text_h_multiplier = 0.5,
		experience_bar_multiplier = 0.825,
		hud_equipment_icon_multiplier = 0.65,
		hud_default_font_multiplier = 0.7,
		hud_ammo_clip_multiplier = 0.75,
		hud_ammo_clip_large_multiplier = 0.5,
		hud_health_multiplier = 0.75,
		hud_mugshot_multiplier = 0.75,
		hud_assault_image_multiplier = 0.5,
		hud_crosshair_offset_multiplier = 0.75,
		hud_objectives_pad_multiplier = 0.65,
		experience_upgrade_multiplier = 0.75,
		level_up_multiplier = 0.7,
		next_upgrade_font_multiplier = 0.75,
		level_up_font_multiplier = 0.51 * sd_level_up_font_multiplier,
		present_multiplier = 0.75,
		lobby_info_offset_multiplier = 0.7,
		info_padding_multiplier = 0.4,
		loading_challenge_bar_scale = 0.8,
		button_layout_multiplier = 0.7,
		subtitle_pos_multiplier = 0.7,
		subtitle_font_multiplier = 0.65,
		subtitle_lang_multiplier = subtitle_multiplier,
		default_font_kern = 0,
		stats_upgrade_kern = stats_upgrade_kern or 0,
		level_up_text_kern = level_up_text_kern or 0,
		victory_screen_kern = victory_screen_kern or -0.5,
		upgrade_menu_kern = upgrade_menu_kern or 0,
		mugshot_name_kern = mugshot_name_kern or -1,
		objectives_text_kern = objectives_text_kern or 0,
		objectives_desc_text_kern = objectives_desc_text_kern or 0,
		kit_description_multiplier = 0.8 * lang_ssd_mod,
		chat_multiplier = 0.68,
		chat_menu_h_multiplier = 0.34,
		w_interact_multiplier = 0.8 * sd_w_interact_multiplier,
		victory_title_multiplier = victory_title_multiplier and victory_title_multiplier * 0.95 or 1
	}
	self.scale = {
		is_sd = false,
		title_image_multiplier = 1,
		menu_logo_multiplier = 1,
		menu_border_multiplier = 1,
		default_font_multiplier = 1 * lang_l_mod,
		small_font_multiplier = 1 * lang_s_mod,
		lobby_info_font_size_scale_multiplier = 1 * lang_l_mod,
		lobby_name_font_size_scale_multiplier = 1 * lang_l_mod,
		server_list_font_size_multiplier = 1 * lang_l_mod * server_list_font_multiplier,
		multichoice_arrow_multiplier = 1,
		align_line_padding_multiplier = 1,
		menu_arrow_padding_multiplier = 1,
		briefing_text_h_multiplier = 1 * lang_s_mod,
		experience_bar_multiplier = 1,
		hud_equipment_icon_multiplier = 1,
		hud_default_font_multiplier = 1 * lang_l_mod,
		hud_ammo_clip_multiplier = 1,
		hud_health_multiplier = 1,
		hud_mugshot_multiplier = 1,
		hud_assault_image_multiplier = 1,
		hud_crosshair_offset_multiplier = 1,
		hud_objectives_pad_multiplier = 1,
		experience_upgrade_multiplier = 1,
		level_up_multiplier = 1,
		next_upgrade_font_multiplier = 1 * lang_l_mod,
		level_up_font_multiplier = 1 * lang_l_mod,
		present_multiplier = 1,
		lobby_info_offset_multiplier = 1,
		info_padding_multiplier = 1,
		loading_challenge_bar_scale = 1,
		button_layout_multiplier = 1,
		subtitle_pos_multiplier = 1,
		subtitle_font_multiplier = 1 * lang_l_mod,
		subtitle_lang_multiplier = subtitle_multiplier,
		default_font_kern = 0,
		stats_upgrade_kern = stats_upgrade_kern or 0,
		level_up_text_kern = 0,
		victory_screen_kern = victory_screen_kern or 0,
		upgrade_menu_kern = 0,
		mugshot_name_kern = 0,
		objectives_text_kern = objectives_text_kern or 0,
		objectives_desc_text_kern = objectives_desc_text_kern or 0,
		kit_description_multiplier = 1 * kit_desc_large,
		chat_multiplier = 1,
		chat_menu_h_multiplier = 1,
		w_interact_multiplier = 1 * w_interact_multiplier,
		victory_title_multiplier = victory_title_multiplier or 1
	}
end

function TweakData:set_menu_scale()
	local lang_mods_def = {
		[Idstring("german"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 0.8,
			mission_end_font_size = 1,
			upgrades_font_size = 1
		},
		[Idstring("french"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 1,
			mission_end_font_size = 1,
			upgrades_font_size = 1
		},
		[Idstring("italian"):key()] = {
			challenges_font_size = 1,
			topic_font_size = 1,
			mission_end_font_size = 0.95,
			upgrades_font_size = 1
		},
		[Idstring("spanish"):key()] = {
			challenges_font_size = 0.95,
			topic_font_size = 0.95,
			mission_end_font_size = 1,
			upgrades_font_size = 1
		}
	}
	local lang_mods = lang_mods_def[SystemInfo:language():key()] or {
		challenges_font_size = 1,
		topic_font_size = 1,
		mission_end_font_size = 1,
		upgrades_font_size = 1
	}
	local scale_multiplier = self.scale.default_font_multiplier
	local small_scale_multiplier = self.scale.small_font_multiplier
	self.menu.default_font = "fonts/font_medium_shadow_mf"
	self.menu.default_font_no_outline = "fonts/font_medium_noshadow_mf"
	self.menu.default_font_id = Idstring(self.menu.default_font)
	self.menu.default_font_no_outline_id = Idstring(self.menu.default_font_no_outline)
	self.menu.small_font = "fonts/font_small_shadow_mf"
	self.menu.small_font_size = 14 * small_scale_multiplier
	self.menu.small_font_noshadow = "fonts/font_small_noshadow_mf"
	self.menu.medium_font = "fonts/font_medium_shadow_mf"
	self.menu.medium_font_no_outline = "fonts/font_medium_noshadow_mf"
	self.menu.meidum_font_size = 24 * scale_multiplier
	self.menu.pd2_massive_font = "fonts/font_large_mf"
	self.menu.pd2_massive_font_id = Idstring(self.menu.pd2_massive_font)
	self.menu.pd2_massive_font_size = 80
	self.menu.pd2_large_font = "fonts/font_large_mf"
	self.menu.pd2_large_font_id = Idstring(self.menu.pd2_large_font)
	self.menu.pd2_large_font_size = 44
	self.menu.pd2_medium_large_font = "fonts/font_large_mf"
	self.menu.pd2_medium_large_font_id = Idstring(self.menu.pd2_large_font)
	self.menu.pd2_medium_large_font_size = 30
	self.menu.pd2_medium_font = "fonts/font_medium_mf"
	self.menu.pd2_medium_font_id = Idstring(self.menu.pd2_medium_font)
	self.menu.pd2_medium_font_size = 24
	self.menu.pd2_small_font = "fonts/font_small_mf"
	self.menu.pd2_small_font_id = Idstring(self.menu.pd2_small_font)
	self.menu.pd2_small_font_size = 20
	self.menu.pd2_smaller_font = "fonts/font_smaller_mf"
	self.menu.pd2_smaller_font_id = Idstring(self.menu.pd2_smaller_font)
	self.menu.pd2_smaller_font_size = 10
	self.menu.default_font_size = 24 * scale_multiplier
	self.menu.default_font_row_item_color = Color.black
	self.menu.default_hightlight_row_item_color = Color.white
	self.menu.default_menu_background_color = Color(1, 0.3254901960784314, 0.37254901960784315, 0.396078431372549)
	self.menu.highlight_background_color_left = Color(1, 1, 0.6588235294117647, 0)
	self.menu.highlight_background_color_right = Color(1, 1, 0.6588235294117647, 0)
	self.menu.default_disabled_text_color = Color(1, 0.5, 0.5, 0.5)
	self.menu.arrow_available = Color(1, 1, 0.6588235294117647, 0)
	self.menu.arrow_unavailable = Color(1, 0.5, 0.5, 0.5)
	self.menu.arrow_unavailable = Color(1, 0.5, 0.5, 0.5)
	self.menu.upgrade_locked_color = Color(0.75, 0, 0)
	self.menu.upgrade_not_aquired_color = Color(0.5, 0.5, 0.5)
	self.menu.awarded_challenge_color = self.menu.default_font_row_item_color
	self.menu.raid_red = Color(1, 0.7843137254901961, 0, 0)
	self.menu.dialog_title_font_size = 28 * self.scale.small_font_multiplier
	self.menu.dialog_text_font_size = 24 * self.scale.small_font_multiplier
	self.menu.info_padding = 10 * self.scale.info_padding_multiplier
	self.menu.topic_font_size = 32 * scale_multiplier * lang_mods.topic_font_size
	self.menu.main_menu_background_color = Color(1, 0, 0, 0)
	self.menu.stats_font_size = 24 * scale_multiplier
	self.menu.customize_controller_size = 21 * scale_multiplier
	self.menu.server_list_font_size = 22 * self.scale.server_list_font_size_multiplier
	self.menu.challenges_font_size = 24 * scale_multiplier * lang_mods.challenges_font_size
	self.menu.upgrades_font_size = 24 * scale_multiplier * lang_mods.upgrades_font_size
	self.menu.multichoice_font_size = 24 * scale_multiplier
	self.menu.mission_end_font_size = 20 * scale_multiplier * lang_mods.mission_end_font_size
	self.menu.sd_mission_end_font_size = 14 * small_scale_multiplier * lang_mods.mission_end_font_size
	self.menu.lobby_info_font_size = 22 * self.scale.lobby_info_font_size_scale_multiplier
	self.menu.lobby_name_font_size = 22 * self.scale.lobby_name_font_size_scale_multiplier
	self.menu.loading_challenge_progress_font_size = 22 * small_scale_multiplier
	self.menu.loading_challenge_name_font_size = 22 * small_scale_multiplier
	self.menu.upper_saferect_border = 64 * self.scale.menu_border_multiplier
	self.menu.border_pad = 8 * self.scale.menu_border_multiplier
	self.menu.kit_description_font_size = 14 * self.scale.kit_description_multiplier
	self.load_level = {
		briefing_text = {
			h = 192 * self.scale.briefing_text_h_multiplier
		},
		upper_saferect_border = self.menu.upper_saferect_border,
		border_pad = self.menu.border_pad,
		stonecold_small_logo = "guis/textures/game_small_logo"
	}
end

function TweakData:set_hud_values()
	local lang_mods_def = {
		[Idstring("german"):key()] = {
			active_objective_title_font_size = 0.9,
			stats_challenges_font_size = 0.7,
			hint_font_size = 0.9,
			location_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 0.8
		},
		[Idstring("french"):key()] = {
			active_objective_title_font_size = 1,
			stats_challenges_font_size = 1,
			hint_font_size = 0.825,
			location_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1
		},
		[Idstring("italian"):key()] = {
			active_objective_title_font_size = 1,
			stats_challenges_font_size = 1,
			hint_font_size = 1,
			location_font_size = 1,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1
		},
		[Idstring("spanish"):key()] = {
			active_objective_title_font_size = 1,
			stats_challenges_font_size = 1,
			hint_font_size = 1,
			location_font_size = 0.7,
			next_player_font_size = 0.85,
			present_mid_text_font_size = 1
		}
	}
	local lang_mods = lang_mods_def[SystemInfo:language():key()] or {
		active_objective_title_font_size = 1,
		stats_challenges_font_size = 1,
		hint_font_size = 1,
		location_font_size = 1,
		next_player_font_size = 1,
		present_mid_text_font_size = 1
	}
	self.hud.large_font = "fonts/font_large"
	self.hud.medium_kern = 1.7
	self.hud.medium_font = "fonts/font_medium_mf"
	self.hud.medium_font_noshadow = "fonts/font_medium_mf"
	self.hud.small_font = "fonts/font_small_mf"
	self.hud.font_pf_handbook_small_shadow = "fonts/pf_handbook_small_shadow"
	self.hud.font_pf_handbook_medium_shadow = "fonts/pf_handbook_medium_shadow"
	self.hud.font_stratum_medium = "fonts/stratum_medium"
	self.hud.font_pf_fuel_pro_32 = "fonts/pf_fuel_pro_32"
	self.hud.font_pf_fuel_pro_64 = "fonts/pf_fuel_pro_64"
	self.hud.font_pf_fuel_pro_32_shadow = "fonts/pf_fuel_pro_32_shadow"
	self.hud.small_font_size = 14 * self.scale.small_font_multiplier
	self.hud.location_font_size = 28 * self.scale.hud_default_font_multiplier * lang_mods.location_font_size
	self.hud.assault_title_font_size = 30 * self.scale.hud_default_font_multiplier
	self.hud.default_font_size = 32 * self.scale.hud_default_font_multiplier
	self.hud.present_mid_text_font_size = 32 * self.scale.hud_default_font_multiplier * lang_mods.present_mid_text_font_size
	self.hud.timer_font_size = 40 * self.scale.hud_default_font_multiplier
	self.hud.medium_deafult_font_size = 28 * self.scale.hud_default_font_multiplier
	self.hud.ammo_font_size = 30 * self.scale.hud_default_font_multiplier
	self.hud.weapon_ammo_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.name_label_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.small_name_label_font_size = 17 * self.scale.hud_default_font_multiplier
	self.hud.equipment_font_size = 24 * self.scale.hud_default_font_multiplier
	self.hud.hint_font_size = 28 * self.scale.hud_default_font_multiplier * lang_mods.hint_font_size
	self.hud.active_objective_title_font_size = 24 * self.scale.hud_default_font_multiplier * lang_mods.active_objective_title_font_size
	self.hud.completed_objective_title_font_size = 20 * self.scale.hud_default_font_multiplier
	self.hud.upgrade_awarded_font_size = 26 * self.scale.hud_default_font_multiplier
	self.hud.next_upgrade_font_size = 14 * self.scale.next_upgrade_font_multiplier
	self.hud.level_up_font_size = 32 * self.scale.level_up_font_multiplier
	self.hud.next_player_font_size = 24 * self.scale.hud_default_font_multiplier * lang_mods.next_player_font_size
	self.hud.stats_challenges_font_size = 32 * self.scale.hud_default_font_multiplier * lang_mods.stats_challenges_font_size
	self.hud.chatinput_size = 22 * self.scale.hud_default_font_multiplier
	self.hud.chatoutput_size = 14 * self.scale.small_font_multiplier
	self.hud.prime_color = Color(1, 1, 0.6588235294117647, 0)
	self.hud.suspicion_color = Color(1, 0.7137254901960784, 0, 0)
	self.hud.detected_color = Color(1, 0.7137254901960784, 0, 0)
	self.hud.accent_orange = Color(0.7843137254901961, 0.5098039215686274, 0)
	self.menu.default_changeable_text_color = self.hud.accent_orange
end

function TweakData:resolution_changed()
	self:set_scale()
	self:set_menu_scale()
	self:set_hud_values()
end

if (not tweak_data or tweak_data.RELOAD) and managers.dlc then
	local reload = tweak_data and tweak_data.RELOAD
	local reload_clbks = tweak_data and tweak_data._reload_clbks
	tweak_data = TweakData:new()
	tweak_data._reload_clbks = reload_clbks

	if reload then
		tweak_data:_execute_reload_clbks()
	end
end

function TweakData:get_controller_help_coords()
	if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
		return false
	end

	local coords = {
		normal = {},
		vehicle = {}
	}

	if IS_PS4 then
		coords.normal.left_thumb = {
			x = 199,
			align = "right",
			y = 255,
			id = "menu_button_sprint",
			vertical = "top"
		}
		coords.normal.left = {
			x = 199,
			align = "right",
			y = 280,
			id = "menu_button_move",
			vertical = "top"
		}
		coords.normal.right_thumb = {
			x = 313,
			align = "left",
			y = 255,
			id = "menu_button_melee",
			vertical = "top"
		}
		coords.normal.right = {
			x = 313,
			align = "left",
			y = 280,
			id = "menu_button_look",
			vertical = "top"
		}
		coords.normal.triangle = {
			x = 511,
			align = "left",
			y = 104,
			id = "menu_button_switch_weapon"
		}
		coords.normal.circle = {
			x = 511,
			align = "left",
			y = 128,
			id = "menu_button_crouch"
		}
		coords.normal.cross = {
			x = 511,
			align = "left",
			y = 153,
			id = "menu_button_jump"
		}
		coords.normal.square = {
			x = 511,
			align = "left",
			y = 181,
			id = "menu_button_reload"
		}
		coords.normal.r1_trigger = {
			x = 511,
			align = "left",
			y = 10,
			id = "menu_button_fire_weapon"
		}
		coords.normal.r2_trigger = {
			x = 511,
			align = "left",
			y = 55,
			id = "menu_button_shout"
		}
		coords.normal.l1_trigger = {
			x = 0,
			align = "right",
			y = 10,
			id = "menu_button_aim_down_sight"
		}
		coords.normal.l2_trigger = {
			x = 0,
			align = "right",
			y = 55,
			id = "menu_button_deploy"
		}
		coords.normal.start = {
			x = 219,
			align = "right",
			y = 0,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.normal.back = {
			x = 328,
			align = "left",
			y = 0,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.normal.d_left = {
			x = 0,
			align = "right",
			y = 128,
			id = "menu_button_throw_grenade",
			vertical = "center"
		}
		coords.normal.d_down = {
			x = 0,
			align = "right",
			y = 153,
			id = "menu_button_weapon_gadget_bipod",
			vertical = "center"
		}
		coords.normal.d_right = {
			x = 0,
			align = "right",
			y = 181,
			id = "menu_button_weapon_firemode",
			vertical = "center"
		}
		coords.vehicle.left_thumb = {
			x = 199,
			align = "right",
			y = 255,
			id = "menu_button_unassigned",
			vertical = "top"
		}
		coords.vehicle.left = {
			x = 199,
			align = "right",
			y = 280,
			id = "menu_button_steering",
			vertical = "top"
		}
		coords.vehicle.right_thumb = {
			x = 313,
			align = "left",
			y = 255,
			id = "menu_button_vehicle_rear_camera",
			vertical = "top"
		}
		coords.vehicle.right = {
			x = 313,
			align = "left",
			y = 280,
			id = "menu_button_unassigned",
			vertical = "top"
		}
		coords.vehicle.triangle = {
			x = 511,
			align = "left",
			y = 104,
			id = "menu_button_unassigned"
		}
		coords.vehicle.circle = {
			x = 511,
			align = "left",
			y = 128,
			id = "menu_button_vehicle_shooting_stance"
		}
		coords.vehicle.cross = {
			x = 511,
			align = "left",
			y = 153,
			id = "menu_button_handbrake"
		}
		coords.vehicle.square = {
			x = 511,
			align = "left",
			y = 181,
			id = "menu_button_vehicle_change_camera"
		}
		coords.vehicle.r1_trigger = {
			x = 511,
			align = "left",
			y = 10,
			id = "menu_button_accelerate"
		}
		coords.vehicle.r2_trigger = {
			x = 511,
			align = "left",
			y = 55,
			id = "menu_button_unassigned"
		}
		coords.vehicle.l1_trigger = {
			x = 0,
			align = "right",
			y = 10,
			id = "menu_button_brake"
		}
		coords.vehicle.l2_trigger = {
			x = 0,
			align = "right",
			y = 55,
			id = "menu_button_unassigned"
		}
		coords.vehicle.start = {
			x = 219,
			align = "right",
			y = 0,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.vehicle.back = {
			x = 328,
			align = "left",
			y = 0,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.vehicle.d_left = {
			x = 0,
			align = "right",
			y = 128,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_down = {
			x = 0,
			align = "right",
			y = 153,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_right = {
			x = 0,
			align = "right",
			y = 181,
			id = "menu_button_unassigned",
			vertical = "center"
		}
	elseif IS_XB1 then
		coords.normal.left_thumb = {
			x = 0,
			align = "right",
			y = 78,
			id = "menu_button_sprint",
			vertical = "bottom"
		}
		coords.normal.left = {
			x = 0,
			align = "right",
			y = 78,
			id = "menu_button_move",
			vertical = "top"
		}
		coords.normal.right_thumb = {
			x = 302,
			align = "center",
			y = 276,
			id = "menu_button_melee",
			vertical = "top"
		}
		coords.normal.right = {
			x = 302,
			align = "center",
			y = 301,
			id = "menu_button_look",
			vertical = "top"
		}
		coords.normal.y = {
			x = 512,
			align = "left",
			y = 57,
			id = "menu_button_switch_weapon"
		}
		coords.normal.x = {
			x = 512,
			align = "left",
			y = 140,
			id = "menu_button_reload"
		}
		coords.normal.b = {
			x = 512,
			align = "left",
			y = 85,
			id = "menu_button_crouch"
		}
		coords.normal.a = {
			x = 512,
			align = "left",
			y = 113,
			id = "menu_button_jump"
		}
		coords.normal.right_shoulder = {
			x = 390,
			align = "center",
			y = -10,
			id = "menu_button_shout"
		}
		coords.normal.right_trigger = {
			x = 512,
			align = "left",
			y = 18,
			id = "menu_button_fire_weapon"
		}
		coords.normal.left_shoulder = {
			x = 180,
			align = "right",
			y = -10,
			id = "menu_button_deploy"
		}
		coords.normal.left_trigger = {
			x = 0,
			align = "right",
			y = 18,
			id = "menu_button_aim_down_sight"
		}
		coords.normal.start = {
			x = 288,
			align = "left",
			y = -25,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.normal.back = {
			x = 235,
			align = "right",
			y = -25,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.normal.d_down = {
			x = 0,
			align = "right",
			y = 193,
			id = "menu_button_weapon_gadget_bipod",
			vertical = "center"
		}
		coords.normal.d_left = {
			x = 0,
			align = "right",
			y = 158,
			id = "menu_button_throw_grenade",
			vertical = "center"
		}
		coords.normal.d_right = {
			x = 270,
			align = "right",
			y = 266,
			id = "menu_button_weapon_firemode",
			vertical = "center"
		}
		coords.vehicle.left_thumb = {
			x = 0,
			align = "right",
			y = 78,
			id = "menu_button_unassigned",
			vertical = "bottom"
		}
		coords.vehicle.left = {
			x = 0,
			align = "right",
			y = 78,
			id = "menu_button_steering",
			vertical = "top"
		}
		coords.vehicle.right_thumb = {
			x = 302,
			align = "center",
			y = 276,
			id = "menu_button_vehicle_rear_camera",
			vertical = "top"
		}
		coords.vehicle.right = {
			x = 302,
			align = "center",
			y = 301,
			id = "menu_button_unassigned",
			vertical = "top"
		}
		coords.vehicle.y = {
			x = 512,
			align = "left",
			y = 57,
			id = "menu_button_unassigned"
		}
		coords.vehicle.x = {
			x = 512,
			align = "left",
			y = 140,
			id = "menu_button_vehicle_change_camera"
		}
		coords.vehicle.b = {
			x = 512,
			align = "left",
			y = 85,
			id = "menu_button_vehicle_shooting_stance"
		}
		coords.vehicle.a = {
			x = 512,
			align = "left",
			y = 113,
			id = "menu_button_handbrake"
		}
		coords.vehicle.right_shoulder = {
			x = 390,
			align = "center",
			y = -10,
			id = "menu_button_unassigned"
		}
		coords.vehicle.right_trigger = {
			x = 512,
			align = "left",
			y = 18,
			id = "menu_button_accelerate"
		}
		coords.vehicle.left_shoulder = {
			x = 180,
			align = "right",
			y = -10,
			id = "menu_button_unassigned"
		}
		coords.vehicle.left_trigger = {
			x = 0,
			align = "right",
			y = 18,
			id = "menu_button_brake"
		}
		coords.vehicle.start = {
			x = 288,
			align = "left",
			y = -25,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.vehicle.back = {
			x = 235,
			align = "right",
			y = -25,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.vehicle.d_down = {
			x = 0,
			align = "right",
			y = 193,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_left = {
			x = 0,
			align = "right",
			y = 158,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_right = {
			x = 270,
			align = "right",
			y = 266,
			id = "menu_button_unassigned",
			vertical = "center"
		}
	else
		coords.normal.left_thumb = {
			x = 0,
			align = "right",
			y = 138,
			id = "menu_button_sprint",
			vertical = "bottom"
		}
		coords.normal.left = {
			x = 0,
			align = "right",
			y = 138,
			id = "menu_button_move",
			vertical = "top"
		}
		coords.normal.right_thumb = {
			x = 302,
			align = "left",
			y = 256,
			id = "menu_button_melee",
			vertical = "top"
		}
		coords.normal.right = {
			x = 302,
			align = "left",
			y = 281,
			id = "menu_button_look",
			vertical = "top"
		}
		coords.normal.y = {
			x = 512,
			align = "left",
			y = 97,
			id = "menu_button_switch_weapon"
		}
		coords.normal.x = {
			x = 512,
			align = "left",
			y = 180,
			id = "menu_button_reload"
		}
		coords.normal.b = {
			x = 512,
			align = "left",
			y = 125,
			id = "menu_button_crouch"
		}
		coords.normal.a = {
			x = 512,
			align = "left",
			y = 153,
			id = "menu_button_jump"
		}
		coords.normal.right_shoulder = {
			x = 512,
			align = "left",
			y = 49,
			id = "menu_button_shout"
		}
		coords.normal.right_trigger = {
			x = 512,
			align = "left",
			y = 19,
			id = "menu_button_fire_weapon"
		}
		coords.normal.left_shoulder = {
			x = 0,
			align = "right",
			y = 49,
			id = "menu_button_deploy"
		}
		coords.normal.left_trigger = {
			x = 0,
			align = "right",
			y = 19,
			id = "menu_button_aim_down_sight"
		}
		coords.normal.start = {
			x = 288,
			align = "left",
			y = 0,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.normal.back = {
			x = 223,
			align = "right",
			y = 0,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.normal.d_down = {
			x = 0,
			align = "right",
			y = 243,
			id = "menu_button_weapon_gadget_bipod",
			vertical = "center"
		}
		coords.normal.d_left = {
			x = 0,
			align = "right",
			y = 208,
			id = "menu_button_throw_grenade",
			vertical = "center"
		}
		coords.normal.d_right = {
			x = 226,
			align = "right",
			y = 256,
			id = "menu_button_weapon_firemode",
			vertical = "top"
		}

		if IS_PC then
			coords.normal.d_up = {
				x = 0,
				align = "right",
				y = 174,
				id = "menu_button_push_to_talk",
				vertical = "center"
			}
		end

		coords.vehicle.left_thumb = {
			x = 0,
			align = "right",
			y = 138,
			id = "menu_button_unassigned",
			vertical = "bottom"
		}
		coords.vehicle.left = {
			x = 0,
			align = "right",
			y = 138,
			id = "menu_button_steering",
			vertical = "top"
		}
		coords.vehicle.right_thumb = {
			x = 302,
			align = "left",
			y = 256,
			id = "menu_button_vehicle_rear_camera",
			vertical = "top"
		}
		coords.vehicle.right = {
			x = 302,
			align = "left",
			y = 281,
			id = "menu_button_unassigned",
			vertical = "top"
		}
		coords.vehicle.y = {
			x = 512,
			align = "left",
			y = 97,
			id = "menu_button_unassigned"
		}
		coords.vehicle.x = {
			x = 512,
			align = "left",
			y = 180,
			id = "menu_button_vehicle_change_camera"
		}
		coords.vehicle.b = {
			x = 512,
			align = "left",
			y = 125,
			id = "menu_button_vehicle_shooting_stance"
		}
		coords.vehicle.a = {
			x = 512,
			align = "left",
			y = 153,
			id = "menu_button_handbrake"
		}
		coords.vehicle.right_shoulder = {
			x = 512,
			align = "left",
			y = 49,
			id = "menu_button_unassigned"
		}
		coords.vehicle.right_trigger = {
			x = 512,
			align = "left",
			y = 19,
			id = "menu_button_accelerate"
		}
		coords.vehicle.left_shoulder = {
			x = 0,
			align = "right",
			y = 49,
			id = "menu_button_unassigned"
		}
		coords.vehicle.left_trigger = {
			x = 0,
			align = "right",
			y = 19,
			id = "menu_button_brake"
		}
		coords.vehicle.start = {
			x = 288,
			align = "left",
			y = 0,
			id = "menu_button_ingame_menu",
			vertical = "bottom"
		}
		coords.vehicle.back = {
			x = 223,
			align = "right",
			y = 0,
			id = "menu_button_stats_screen",
			vertical = "bottom"
		}
		coords.vehicle.d_down = {
			x = 0,
			align = "right",
			y = 243,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_left = {
			x = 0,
			align = "right",
			y = 208,
			id = "menu_button_unassigned",
			vertical = "center"
		}
		coords.vehicle.d_right = {
			x = 226,
			align = "right",
			y = 256,
			id = "menu_button_unassigned",
			vertical = "top"
		}

		if IS_PC then
			coords.vehicle.d_up = {
				x = 0,
				align = "right",
				y = 174,
				id = "menu_button_unassigned",
				vertical = "center"
			}
		end
	end

	if managers.user and managers.user:get_setting("southpaw") then
		local tmp = coords.normal.menu_button_move
		coords.normal.menu_button_move = coords.normal.menu_button_look
		coords.normal.menu_button_look = tmp
	end

	return coords
end
