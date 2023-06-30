CharacterCustomizationTweakData = CharacterCustomizationTweakData or class()
CharacterCustomizationTweakData.NATIONALITY_AMERICAN = "american"
CharacterCustomizationTweakData.NATIONALITY_GERMAN = "german"
CharacterCustomizationTweakData.NATIONALITY_BRITISH = "british"
CharacterCustomizationTweakData.NATIONALITY_RUSSIAN = "russian"
CharacterCustomizationTweakData.SKILL_TRACK_RECON = "recon"
CharacterCustomizationTweakData.SKILL_TRACK_ASSAULT = "assault"
CharacterCustomizationTweakData.SKILL_TRACK_DEMOLITION = "demolition"
CharacterCustomizationTweakData.PART_TYPE_HEAD = "character_customization_type_head"
CharacterCustomizationTweakData.PART_TYPE_UPPER = "character_customization_type_upper"
CharacterCustomizationTweakData.PART_TYPE_LOWER = "character_customization_type_lower"
CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT = "units/vanilla/characters/players/criminal_empty/criminal_empty_menu"
CharacterCustomizationTweakData.PART_LENGTH_SHORT = "length_short"
CharacterCustomizationTweakData.PART_LENGTH_LONG = "length_long"

-- Lines 21-31
function CharacterCustomizationTweakData:init()
	self:initialization()

	self.nationality_index = {
		"american",
		"german",
		"british",
		"russian"
	}
	self.body_part_index = {
		"head",
		"upper",
		"lower"
	}
	self.customization_animation_idle_loop = "character_customization_standing_loop"
	self.customization_animations = {
		"character_customization_clap",
		"character_customization_posing",
		"character_customization_salut",
		"character_customization_shadowboxing",
		"character_customization_your_done",
		"character_customization_adjust_collar",
		"character_customization_adjust_sleves",
		"character_customization_polish_boots",
		"character_customization_stretch_arms",
		"character_customization_stretch_legs",
		"character_customization_brush",
		"character_customization_wave_camera"
	}
end

-- Lines 33-1765
function CharacterCustomizationTweakData:initialization()
	self.customizations = {
		american_default_head = {}
	}
	self.customizations.american_default_head.name = "character_customization_american_default_name_head"
	self.customizations.american_default_head.description = "character_customization_american_default_desc_head"
	self.customizations.american_default_head.part_type = CharacterCustomizationTweakData.PART_TYPE_HEAD
	self.customizations.american_default_head.nationalities = {
		CharacterCustomizationTweakData.NATIONALITY_AMERICAN
	}
	self.customizations.american_default_head.path = "units/vanilla/characters/players/usa/head/player_usa_head_002/player_usa_head_002"
	self.customizations.american_default_head.path_icon = "ui/temp/customization_temp_df"
	self.customizations.american_default_head.redeem_xp = 0
	self.customizations.american_default_head.rarity = LootDropTweakData.RARITY_COMMON
	self.customizations.american_default_head.default_clothing = true
	self.customizations.american_default_upper = {
		name = "character_customization_american_default_name_upper",
		description = "character_customization_american_default_desc_upper",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/tanker_001/npc_criminal_usa_tanker_001_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/tanker_001/player_usa_tanker_001_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/tanker_001/player_usa_tanker_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		default_clothing = true
	}
	self.customizations.american_default_lower = {
		name = "character_customization_american_default_name_lower",
		description = "character_customization_american_default_desc_lower",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/tanker_001/npc_criminal_usa_tanker_001_lower",
		path_short = "units/vanilla/characters/players/usa/lower/tanker_001/npc_criminal_usa_tanker_001_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/tanker_001/player_usa_tanker_001_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.german_default_head = {
		name = "character_customization_german_default_name_head",
		description = "character_customization_german_default_desc_head",
		part_type = CharacterCustomizationTweakData.PART_TYPE_HEAD,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/head/player_german_head_002/player_german_head_002",
		path_icon = "ui/temp/customization_temp_df",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.german_default_upper = {
		name = "character_customization_german_default_name_upper",
		description = "character_customization_german_default_desc_upper",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/default_002/player_german_default_002_upper",
		path_icon = "units/vanilla/characters/players/german/upper/default_002/player_german_default_002_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/default_002/player_german_default_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		default_clothing = true
	}
	self.customizations.german_default_lower = {
		name = "character_customization_german_default_name_lower",
		description = "character_customization_german_default_desc_lower",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/default_002/player_german_default_002_lower",
		path_short = "units/vanilla/characters/players/german/lower/default_002/player_german_default_002_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/default_002/player_german_default_002_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.british_default_head = {
		name = "character_customization_british_default_name_head",
		description = "character_customization_british_default_desc_head",
		part_type = CharacterCustomizationTweakData.PART_TYPE_HEAD,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/head/npc_criminal_uk_default_head",
		path_icon = "ui/temp/customization_temp_df",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.british_default_upper = {
		name = "character_customization_british_default_name_upper",
		description = "character_customization_british_default_desc_upper",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/default_002/player_british_default_002_upper",
		path_icon = "units/vanilla/characters/players/british/upper/default_002/player_uk_default_002_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/default_002/player_uk_default_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		default_clothing = true
	}
	self.customizations.british_default_lower = {
		name = "character_customization_british_default_name_lower",
		description = "character_customization_british_default_desc_lower",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/default_002/player_british_default_002_lower",
		path_short = "units/vanilla/characters/players/british/lower/default_002/player_british_default_002_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/default_002/player_uk_default_002_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.russian_default_head = {
		name = "character_customization_russian_default_name_head",
		description = "character_customization_russian_default_desc_head",
		part_type = CharacterCustomizationTweakData.PART_TYPE_HEAD,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/head/player_soviet_head_002/player_soviet_head_002",
		path_icon = "ui/temp/customization_temp_df",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.russian_default_upper = {
		name = "character_customization_russian_default_name_upper",
		description = "character_customization_russian_default_desc_upper",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/default_002/player_soviet_default_002_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/default_002/player_soviet_default_002_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/default_002/player_soviet_default_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		default_clothing = true
	}
	self.customizations.russian_default_lower = {
		name = "character_customization_russian_default_name_lower",
		description = "character_customization_russian_default_desc_lower",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/default_002/player_soviet_default_002_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/default_002/player_soviet_default_002_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/default_002/player_soviet_default_002_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		default_clothing = true
	}
	self.customizations.british_officer_001_upper = {
		name = "character_customization_british_officer_001_upper_name",
		description = "character_customization_british_officer_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/officer_001/npc_criminal_uk_officer_001_upper",
		path_icon = "units/vanilla/characters/players/british/upper/officer_001/player_uk_officer_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/officer_001/player_uk_officer_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/officer_001/player_uk_officer_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.british_officer_001_lower = {
		name = "character_customization_british_officer_001_lower_name",
		description = "character_customization_british_officer_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/officer_001/npc_criminal_uk_officer_001_lower",
		path_short = "units/vanilla/characters/players/british/lower/officer_001/npc_criminal_uk_officer_001_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/officer_001/player_uk_officer_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/officer_001/player_uk_officer_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.british_officer_002_upper = {
		name = "character_customization_british_officer_002_upper_name",
		description = "character_customization_british_officer_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/officer_002/player_british_officer_002_upper",
		path_icon = "units/vanilla/characters/players/british/upper/officer_002/player_british_officer_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/officer_002/player_british_officer_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/officer_002/player_uk_officer_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_officer_002_lower = {
		name = "character_customization_british_officer_002_lower_name",
		description = "character_customization_british_officer_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/officer_002/player_british_officer_002_lower",
		path_short = "units/vanilla/characters/players/british/lower/officer_002/player_british_officer_002_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/officer_002/player_british_officer_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/officer_002/player_british_officer_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.british_casual_001_upper = {
		name = "character_customization_british_casual_001_upper_name",
		description = "character_customization_british_casual_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/casual_001/player_british_casual_001_upper",
		path_icon = "units/vanilla/characters/players/british/upper/casual_001/player_uk_casual_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/casual_001/player_uk_casual_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/casual_001/player_uk_casual_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_casual_001_lower = {
		name = "character_customization_british_casual_001_lower_name",
		description = "character_customization_british_casual_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/casual_001/player_british_casual_001_lower",
		path_short = "units/vanilla/characters/players/british/lower/casual_001/player_british_casual_001_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/casual_001/player_uk_casual_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/casual_001/player_uk_casual_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.british_casual_002_upper = {
		name = "character_customization_british_casual_002_upper_name",
		description = "character_customization_british_casual_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/casual_002/player_british_casual_002_upper",
		path_icon = "units/vanilla/characters/players/british/upper/casual_002/player_british_casual_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/casual_002/player_british_casual_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/casual_002/player_uk_casual_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_casual_002_lower = {
		name = "character_customization_british_casual_002_lower_name",
		description = "character_customization_british_casual_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/casual_002/player_british_casual_002_lower",
		path_short = "units/vanilla/characters/players/british/lower/casual_002/player_british_casual_002_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/casual_002/player_british_casual_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/casual_002/player_british_casual_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.british_casual_003_upper = {
		name = "character_customization_british_casual_003_upper_name",
		description = "character_customization_british_casual_003_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/casual_003/player_british_casual_003_upper",
		path_icon = "units/vanilla/characters/players/british/upper/casual_003/player_british_casual_003_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/casual_003/player_british_casual_003_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/casual_003/player_uk_casual_003_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_casual_003_lower = {
		name = "character_customization_british_casual_003_lower_name",
		description = "character_customization_british_casual_003_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/casual_003/player_british_casual_003_lower",
		path_short = "units/vanilla/characters/players/british/lower/casual_003/player_british_casual_003_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/casual_003/player_british_casual_003_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/casual_003/player_british_casual_003_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.british_casual_004_upper = {
		name = "character_customization_british_casual_004_upper_name",
		description = "character_customization_british_casual_004_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/casual_004/player_british_casual_004_upper",
		path_icon = "units/vanilla/characters/players/british/upper/casual_004/player_british_casual_004_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/casual_004/player_british_casual_004_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/casual_004/player_uk_casual_004_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_casual_004_lower = {
		name = "character_customization_british_casual_004_lower_name",
		description = "character_customization_british_casual_004_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/casual_004/player_british_casual_004_lower",
		path_short = "units/vanilla/characters/players/british/lower/casual_004/player_british_casual_004_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/casual_004/player_british_casual_004_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/casual_004/player_british_casual_004_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.british_gangbanger_001_upper = {
		name = "character_customization_british_gangbanger_001_upper_name",
		description = "character_customization_british_gangbanger_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/gangbanger_001/player_british_gangbanger_001_upper",
		path_icon = "units/vanilla/characters/players/british/upper/gangbanger_001/player_uk_gangbanger_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/gangbanger_001/player_uk_gangbanger_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/gangbanger_001/player_uk_gangbanger_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_gangbanger_001_lower = {
		name = "character_customization_british_gangbanger_001_lower_name",
		description = "character_customization_british_gangbanger_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/gangbanger_001/player_british_gangbanger_001_lower",
		path_short = "units/vanilla/characters/players/british/lower/gangbanger_001/player_british_gangbanger_001_lower_short",
		path_icon = "units/vanilla/characters/players/british/lower/gangbanger_001/player_uk_gangbanger_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/british/lower/gangbanger_001/player_uk_gangbanger_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.british_gold_jacket_001_upper = {
		name = "character_customization_british_gold_jacket_001_upper_name",
		description = "character_customization_british_gold_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/gold_jacket/player_criminal_british_gold_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/golden_jacket/player_generic_gold_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.german_officer_001_upper = {
		name = "character_customization_german_officer_001_upper_name",
		description = "character_customization_german_officer_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/officer_001/npc_criminal_ger_officer_001_upper",
		path_icon = "units/vanilla/characters/players/german/upper/officer_001/player_german_officer_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/officer_001/player_german_officer_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/officer_001/player_german_officer_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_officer_001_lower = {
		name = "character_customization_german_officer_001_lower_name",
		description = "character_customization_german_officer_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/officer_001/npc_criminal_ger_officer_001_lower",
		path_short = "units/vanilla/characters/players/german/lower/officer_001/npc_criminal_ger_officer_001_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/officer_001/player_german_officer_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/officer_001/player_german_officer_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.german_gangbanger_001_upper = {
		name = "character_customization_german_gangbanger_001_upper_name",
		description = "character_customization_german_gangbanger_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/gangbanger_001/npc_criminal_ger_gangbanger_001_upper",
		path_icon = "units/vanilla/characters/players/german/upper/gangbanger_001/player_german_gangbanger_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/gangbanger_001/player_german_gangbanger_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/gangbanger_001/player_german_gangbanger_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.german_gangbanger_001_lower = {
		name = "character_customization_german_gangbanger_001_lower_name",
		description = "character_customization_german_gangbanger_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/gangbanger_001/npc_criminal_ger_gangbanger_001_lower",
		path_short = "units/vanilla/characters/players/german/lower/gangbanger_001/npc_criminal_ger_gangbanger_001_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/gangbanger_001/player_german_gangbanger_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/gangbanger_001/player_german_gangbanger_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.german_officer_002_upper = {
		name = "character_customization_german_officer_002_upper_name",
		description = "character_customization_german_officer_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/officer_002/npc_criminal_ger_officer_002_upper",
		path_icon = "units/vanilla/characters/players/german/upper/officer_002/player_german_officer_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/officer_002/player_german_officer_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/officer_002/player_german_officer_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_officer_002_lower = {
		name = "character_customization_german_officer_002_lower_name",
		description = "character_customization_german_officer_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/officer_002/npc_criminal_ger_officer_002_lower",
		path_short = "units/vanilla/characters/players/german/lower/officer_002/npc_criminal_ger_officer_002_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/officer_002/player_german_officer_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/officer_002/player_german_officer_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.german_grunt_001_upper = {
		name = "character_customization_german_grunt_001_upper_name",
		description = "character_customization_german_grunt_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/grunt_001/player_german_grunt_001_upper",
		path_icon = "units/vanilla/characters/players/german/upper/grunt_001/player_german_grunt_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/grunt_001/player_german_grunt_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/grunt_001/player_german_grunt_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_grunt_001_lower = {
		name = "character_customization_german_grunt_001_lower_name",
		description = "character_customization_german_grunt_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/grunt_002/player_german_grunt_002_lower",
		path_short = "units/vanilla/characters/players/german/lower/grunt_002/player_german_grunt_002_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/grunt_002/player_german_grunt_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/grunt_002/player_german_grunt_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.german_grunt_002_upper = {
		name = "character_customization_german_grunt_002_upper_name",
		description = "character_customization_german_grunt_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/grunt_002/player_german_grunt_002_upper",
		path_icon = "units/vanilla/characters/players/german/upper/grunt_002/player_german_grunt_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/grunt_002/player_german_grunt_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/grunt_002/player_german_grunt_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_grunt_002_lower = {
		name = "character_customization_german_grunt_002_lower_name",
		description = "character_customization_german_grunt_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/grunt_001/player_german_grunt_001_lower",
		path_short = "units/vanilla/characters/players/german/lower/grunt_001/player_german_grunt_001_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/grunt_001/player_german_grunt_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/grunt_001/player_german_grunt_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.german_grunt_003_upper = {
		name = "character_customization_german_grunt_003_upper_name",
		description = "character_customization_german_grunt_003_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/grunt_003/player_criminal_german_grunt_003_upper",
		path_icon = "units/vanilla/characters/players/german/upper/grunt_003/player_german_grunt_003_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/grunt_003/player_german_grunt_003_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/grunt_003/player_german_grunt_003_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_grunt_003_lower = {
		name = "character_customization_german_grunt_003_lower_name",
		description = "character_customization_german_grunt_003_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/grunt_003/player_criminal_german_grunt_003_lower",
		path_short = "units/vanilla/characters/players/german/lower/grunt_003/player_criminal_german_grunt_003_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/grunt_003/player_german_grunt_003_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/grunt_003/player_german_grunt_003_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.german_gold_jacket_002_upper = {
		name = "character_customization_german_gold_jacket_002_upper_name",
		description = "character_customization_german_gold_jacket_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/gold_jacket/player_criminal_german_gold_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/golden_jacket/player_generic_gold_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.german_gangbanger_002_upper = {
		name = "character_customization_german_gangbanger_002_upper_name",
		description = "character_customization_german_gangbanger_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/gangbanger_002/player_criminal_ger_gangbanger_002_upper",
		path_icon = "units/vanilla/characters/players/german/upper/gangbanger_002/player_german_gangbanger_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/gangbanger_002/player_german_gangbanger_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/gangbanger_002/player_german_default_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.german_gangbanger_002_lower = {
		name = "character_customization_german_gangbanger_002_lower_name",
		description = "character_customization_german_gangbanger_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/gangbanger_002/player_criminal_ger_gangbanger_002_lower",
		path_short = "units/vanilla/characters/players/german/lower/gangbanger_002/player_criminal_ger_gangbanger_002_lower_short",
		path_icon = "units/vanilla/characters/players/german/lower/gangbanger_002/player_german_gangbanger_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/german/lower/gangbanger_002/player_german_gangbanger_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.russian_commisar_001_upper = {
		name = "character_customization_russian_commisar_001_upper_name",
		description = "character_customization_russian_commisar_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/commisar_001/npc_criminal_soviet_commisar_001_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/commisar_001/player_soviet_commisar_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/commisar_001/player_soviet_commisar_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/commisar_001/player_soviet_commisar_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.russian_commisar_001_lower = {
		name = "character_customization_russian_commisar_001_lower_name",
		description = "character_customization_russian_commisar_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/commisar_001/npc_criminal_soviet_commisar_001_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/commisar_001/npc_criminal_soviet_commisar_001_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/commisar_001/player_soviet_commisar_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/commisar_001/player_soviet_commisar_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.russian_commisar_002_upper = {
		name = "character_customization_russian_commisar_002_upper_name",
		description = "character_customization_russian_commisar_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/commisar_002/npc_criminal_soviet_commisar_002_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/commisar_002/player_soviet_commisar_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/commisar_002/player_soviet_commisar_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/commisar_002/player_soviet_commisar_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.russian_commisar_002_lower = {
		name = "character_customization_russian_commisar_002_lower_name",
		description = "character_customization_russian_commisar_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/commisar_002/npc_criminal_soviet_commisar_002_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/commisar_002/npc_criminal_soviet_commisar_002_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/commisar_002/player_soviet_commisar_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/commisar_002/player_soviet_commisar_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.russian_casual_001_upper = {
		name = "character_customization_russian_casual_001_upper_name",
		description = "character_customization_russian_casual_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/casual_001/npc_criminal_soviet_casual_001_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/casual_001/player_soviet_casual_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/casual_001/player_soviet_casual_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/casual_001/player_soviet_casual_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.russian_casual_001_lower = {
		name = "character_customization_russian_casual_001_lower_name",
		description = "character_customization_russian_casual_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/casual_001/npc_criminal_soviet_casual_001_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/casual_001/npc_criminal_soviet_casual_001_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/casual_001/player_soviet_casual_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/casual_001/player_soviet_casual_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.russian_commisar_003_upper = {
		name = "character_customization_russian_commisar_003_upper_name",
		description = "character_customization_russian_commisar_003_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/commisar_003/player_soviet_commisar_003_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/commisar_003/player_soviet_commissar_003_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/commisar_003/player_soviet_commissar_003_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/commisar_003/player_soviet_commisar_003_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.russian_commisar_003_lower = {
		name = "character_customization_russian_commisar_003_lower_name",
		description = "character_customization_russian_commisar_003_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/commisar_003/player_soviet_commisar_003_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/commisar_003/player_soviet_commisar_003_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/commisar_003/player_soviet_commisar_003_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/commisar_003/player_soviet_commisar_003_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.russian_grunt_001_upper = {
		name = "character_customization_russian_grunt_001_upper_name",
		description = "character_customization_russian_grunt_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/grunt_001/player_soviet_grunt_001_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/grunt_001/player_soviet_grunt_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/grunt_001/player_soviet_grunt_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/grunt_001/player_soviet_grunt_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.russian_grunt_001_lower = {
		name = "character_customization_russian_grunt_001_lower_name",
		description = "character_customization_russian_grunt_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/grunt_001/player_soviet_grunt_001_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/grunt_001/player_soviet_grunt_001_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/grunt_001/player_soviet_grunt_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/grunt_001/player_soviet_grunt_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.russian_grunt_002_upper = {
		name = "character_customization_russian_grunt_002_upper_name",
		description = "character_customization_russian_grunt_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/grunt_002/player_soviet_grunt_002_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/grunt_002/player_soviet_grunt_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/grunt_002/player_soviet_grunt_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/grunt_002/player_soviet_grunt_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.russian_grunt_002_lower = {
		name = "character_customization_russian_grunt_002_lower_name",
		description = "character_customization_russian_grunt_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/grunt_002/player_soviet_grunt_002_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/grunt_002/player_soviet_grunt_002_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/grunt_002/player_soviet_grunt_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/grunt_002/player_soviet_grunt_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.russian_mech_001_upper = {
		name = "character_customization_russian_mech_001_upper_name",
		description = "character_customization_russian_mech_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/mech_001/player_soviet_mech_001_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/mech_001/player_soviet_mech_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/mech_001/player_soviet_mech_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/mech_001/player_soviet_mech_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.russian_mech_001_lower = {
		name = "character_customization_russian_mech_001_lower_name",
		description = "character_customization_russian_mech_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/mech_001/player_soviet_mech_001_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/mech_001/player_soviet_mech_001_lower_short",
		path_icon = "units/vanilla/characters/players/soviet/lower/mech_001/player_soviet_mech_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/lower/mech_001/player_soviet_mech_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.russian_gold_jacket_001_upper = {
		name = "character_customization_russian_gold_jacket_001_upper_name",
		description = "character_customization_russian_gold_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/gold_jacket/player_criminal_soviet_gold_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/golden_jacket/player_generic_gold_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.american_gangbanger_001_upper = {
		name = "character_customization_american_gangbanger_001_upper_name",
		description = "character_customization_american_gangbanger_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/gangbanger_001/npc_criminal_usa_gangbanger_001_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/gangbanger_001/player_usa_gangbanger_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/gangbanger_001/player_usa_gangbanger_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/gangbanger_001/player_usa_gangbanger_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG,
		droppable = true
	}
	self.customizations.american_gangbanger_001_lower = {
		name = "character_customization_american_gangbanger_001_lower_name",
		description = "character_customization_american_gangbanger_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/gangbanger_001/npc_criminal_usa_gangbanger_001_lower",
		path_short = "units/vanilla/characters/players/usa/lower/gangbanger_001/npc_criminal_usa_gangbanger_001_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/gangbanger_001/player_usa_gangbanger_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/gangbanger_001/player_usa_gangbanger_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.american_gangbanger_002_upper = {
		name = "character_customization_american_gangbanger_002_upper_name",
		description = "character_customization_american_gangbanger_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/gangbanger_002/npc_criminal_usa_gangbanger_002_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/gangbanger_002/player_usa_gangbanger_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/gangbanger_002/player_usa_gangbanger_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/gangbanger_002/player_usa_gangbanger_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_gangbanger_002_lower = {
		name = "character_customization_american_gangbanger_002_lower_name",
		description = "character_customization_american_gangbanger_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/gangbanger_002/npc_criminal_usa_gangbanger_002_lower",
		path_short = "units/vanilla/characters/players/usa/lower/gangbanger_002/npc_criminal_usa_gangbanger_002_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/gangbanger_002/player_usa_gangbanger_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/gangbanger_002/player_usa_gangbanger_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.american_gangbanger_003_upper = {
		name = "character_customization_american_gangbanger_003_upper_name",
		description = "character_customization_american_gangbanger_003_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/gangbanger_003/player_criminal_usa_gangbanger_003_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/gangbanger_003/player_usa_gangbanger_003_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/gangbanger_003/player_usa_gangbanger_003_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/gangbanger_003/player_usa_gangbanger_003_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_gangbanger_003_lower = {
		name = "character_customization_american_gangbanger_003_lower_name",
		description = "character_customization_american_gangbanger_003_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/gangbanger_003/player_criminal_usa_gangbanger_003_lower",
		path_short = "units/vanilla/characters/players/usa/lower/gangbanger_003/player_criminal_usa_gangbanger_003_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/gangbanger_003/player_usa_gangbanger_003_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/gangbanger_003/player_usa_gangbanger_003_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.american_casual_001_upper = {
		name = "character_customization_american_casual_001_upper_name",
		description = "character_customization_american_casual_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/casual_001/player_criminal_usa_casual_001_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/casual_001/player_usa_casual_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/casual_001/player_usa_casual_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/casual_001/player_usa_casual_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_casual_001_lower = {
		name = "character_customization_american_casual_001_lower_name",
		description = "character_customization_american_casual_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/casual_001/player_criminal_usa_casual_001_lower",
		path_short = "units/vanilla/characters/players/usa/lower/casual_001/player_criminal_usa_casual_001_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/casual_001/player_usa_casual_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/casual_001/player_usa_casual_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		droppable = true
	}
	self.customizations.american_officer_001_upper = {
		name = "character_customization_american_officer_001_upper_name",
		description = "character_customization_american_officer_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/officer_001/player_criminal_usa_officer_001_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/officer_001/player_usa_officer_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/officer_001/player_usa_officer_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/officer_001/player_usa_officer_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_officer_001_lower = {
		name = "character_customization_american_officer_001_lower_name",
		description = "character_customization_american_officer_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/officer_001/player_criminal_usa_officer_001_lower",
		path_short = "units/vanilla/characters/players/usa/lower/officer_001/player_criminal_usa_officer_001_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/officer_001/player_usa_officer_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/officer_001/player_usa_officer_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.american_officer_002_upper = {
		name = "character_customization_american_officer_002_upper_name",
		description = "character_customization_american_officer_002_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/officer_002/player_criminal_usa_officer_002_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/officer_002/player_usa_officer_002_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/officer_002/player_usa_officer_002_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/officer_002/player_usa_officer_002_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_officer_002_lower = {
		name = "character_customization_american_officer_002_lower_name",
		description = "character_customization_american_officer_002_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/officer_002/player_criminal_usa_officer_002_lower",
		path_short = "units/vanilla/characters/players/usa/lower/officer_002/player_criminal_usa_officer_002_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/officer_002/player_usa_officer_002_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/officer_002/player_usa_officer_002_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_COMMON,
		droppable = true
	}
	self.customizations.american_grunt_001_upper = {
		name = "character_customization_american_grunt_001_upper_name",
		description = "character_customization_american_grunt_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/grunt_001/player_criminal_usa_grunt_001_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/grunt_001/player_usa_grunt_001_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/grunt_001/player_usa_grunt_001_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/grunt_001/player_usa_grunt_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_grunt_001_lower = {
		name = "character_customization_american_grunt_001_lower_name",
		description = "character_customization_american_grunt_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/grunt_001/player_criminal_usa_grunt_001_lower",
		path_short = "units/vanilla/characters/players/usa/lower/grunt_001/player_criminal_usa_grunt_001_lower_short",
		path_icon = "units/vanilla/characters/players/usa/lower/grunt_001/player_usa_grunt_001_lower_hud",
		path_icon_large = "units/vanilla/characters/players/usa/lower/grunt_001/player_usa_grunt_001_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.american_gold_jacket_001_upper = {
		name = "character_customization_american_gold_jacket_001_upper_name",
		description = "character_customization_american_gold_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/gold_jacket/player_criminal_usa_gold_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/golden_jacket/player_gold_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/golden_jacket/player_generic_gold_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.american_gold_collector_jacket_001_upper = {
		name = "character_customization_american_gold_collector_jacket_001_upper_name",
		description = "character_customization_american_gold_collector_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/gold_collector_jacket/player_criminal_usa_gold_collector_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/gold_collector_jacket/player_generic_gold_collector_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG
	}
	self.customizations.british_gold_collector_jacket_001_upper = {
		name = "character_customization_british_gold_collector_jacket_001_upper_name",
		description = "character_customization_british_gold_collector_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/gold_collector_jacket/player_criminal_british_gold_collector_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/gold_collector_jacket/player_generic_gold_collector_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG
	}
	self.customizations.german_gold_collector_jacket_001_upper = {
		name = "character_customization_german_gold_collector_jacket_001_upper_name",
		description = "character_customization_german_gold_collector_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/gold_collector_jacket/player_criminal_german_gold_collector_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/gold_collector_jacket/player_generic_gold_collector_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG
	}
	self.customizations.russian_gold_collector_jacket_001_upper = {
		name = "character_customization_russian_gold_collector_jacket_001_upper_name",
		description = "character_customization_russian_gold_collector_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/gold_collector_jacket/player_criminal_soviet_gold_collector_jacket_001_upper",
		path_icon = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_hud",
		path_icon_large = "units/vanilla/characters/players/generic/gold_collector_jacket/player_gold_collector_jacket_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/gold_collector_jacket/player_generic_gold_collector_jacket_001_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_LONG
	}
	self.customizations.american_special_edition_001_upper = {
		name = "character_customization_generic_special_edition_001_upper_name",
		description = "character_customization_generic_special_edition_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/special_edition/player_usa_special_edition_upper",
		path_icon = "units/vanilla/characters/players/usa/upper/special_edition/player_usa_special_edition_upper_hud",
		path_icon_large = "units/vanilla/characters/players/usa/upper/special_edition/player_usa_special_edition_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/usa/fp/special_edition/player_usa_special_edition_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
		dlc_show_if_locked = false
	}
	self.customizations.british_special_edition_001_upper = {
		name = "character_customization_generic_special_edition_001_upper_name",
		description = "character_customization_generic_special_edition_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/special_edition/player_british_special_edition_upper",
		path_icon = "units/vanilla/characters/players/british/upper/special_edition/player_british_special_edition_upper_hud",
		path_icon_large = "units/vanilla/characters/players/british/upper/special_edition/player_british_special_edition_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/british/fp/special_edition/player_british_special_edition_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
		dlc_show_if_locked = false
	}
	self.customizations.german_special_edition_001_upper = {
		name = "character_customization_generic_special_edition_001_upper_name",
		description = "character_customization_generic_special_edition_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/special_edition/player_german_special_edition_upper",
		path_icon = "units/vanilla/characters/players/german/upper/special_edition/player_german_special_edition_upper_hud",
		path_icon_large = "units/vanilla/characters/players/german/upper/special_edition/player_german_special_edition_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/german/fp/special_edition/player_german_special_edition_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
		dlc_show_if_locked = false
	}
	self.customizations.russian_special_edition_001_upper = {
		name = "character_customization_generic_special_edition_001_upper_name",
		description = "character_customization_generic_special_edition_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/special_edition/player_soviet_special_edition_upper",
		path_icon = "units/vanilla/characters/players/soviet/upper/special_edition/player_soviet_special_edition_upper_hud",
		path_icon_large = "units/vanilla/characters/players/soviet/upper/special_edition/player_soviet_special_edition_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/soviet/fp/special_edition/player_soviet_special_edition_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
		dlc_show_if_locked = false
	}
	self.customizations.american_highlander_jacket_upper = {
		name = "character_customization_highlander_upper_name",
		description = "character_customization_highlander_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/highlander_jacket/player_usa_highlander_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highlander_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.american_highlander_jacket_lower = {
		name = "character_customization_highlander_lower_name",
		description = "character_customization_highlander_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/highlander_jacket/player_usa_highlander_jacket_lower",
		path_short = "units/vanilla/characters/players/usa/lower/highlander_jacket/player_usa_highlander_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.russian_highlander_jacket_upper = {
		name = "character_customization_highlander_upper_name",
		description = "character_customization_highlander_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/highlander_jacket/player_soviet_highlander_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highlander_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.russian_highlander_jacket_lower = {
		name = "character_customization_highlander_lower_name",
		description = "character_customization_highlander_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/highlander_jacket/player_soviet_highlander_jacket_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/highlander_jacket/player_soviet_highlander_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.german_highlander_jacket_upper = {
		name = "character_customization_highlander_upper_name",
		description = "character_customization_highlander_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/highlander_jacket/player_german_highlander_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highlander_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.german_highlander_jacket_lower = {
		name = "character_customization_highlander_lower_name",
		description = "character_customization_highlander_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/highlander_jacket/player_german_highlander_jacket_lower",
		path_short = "units/vanilla/characters/players/german/lower/highlander_jacket/player_german_highlander_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.british_highlander_jacket_upper = {
		name = "character_customization_highlander_upper_name",
		description = "character_customization_highlander_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/highlander_jacket/player_british_highlander_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highlander_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.british_highlander_jacket_lower = {
		name = "character_customization_highlander_lower_name",
		description = "character_customization_highlander_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/highlander_jacket/player_british_highlander_jacket_lower",
		path_short = "units/vanilla/characters/players/british/lower/highlander_jacket/player_british_highlander_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/highlander_jacket/player_generic_highland_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		dlc = DLCTweakData.DLC_NAME_PREORDER,
		dlc_show_if_locked = false
	}
	self.customizations.british_ace_jacket_001_upper = {
		name = "character_customization_british_ace_jacket_001_upper_name",
		description = "character_customization_british_ace_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/ace_jacket/player_criminal_british_ace_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/ace_jacket/player_generic_ace_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_ace_jacket_001_lower = {
		name = "character_customization_british_ace_jacket_001_lower_name",
		description = "character_customization_british_ace_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/ace_jacket/player_british_ace_jacket_lower",
		path_short = "units/vanilla/characters/players/british/lower/ace_jacket/player_british_ace_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		droppable = true
	}
	self.customizations.german_ace_jacket_001_upper = {
		name = "character_customization_german_ace_jacket_001_upper_name",
		description = "character_customization_german_ace_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/ace_jacket/player_criminal_german_ace_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/ace_jacket/player_generic_ace_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.german_ace_jacket_001_lower = {
		name = "character_customization_german_ace_jacket_001_lower_name",
		description = "character_customization_german_ace_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/ace_jacket/player_german_ace_jacket_lower",
		path_short = "units/vanilla/characters/players/german/lower/ace_jacket/player_german_ace_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		droppable = true
	}
	self.customizations.russian_ace_jacket_001_upper = {
		name = "character_customization_soviet_ace_jacket_001_upper_name",
		description = "character_customization_soviet_ace_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/ace_jacket/player_criminal_soviet_ace_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/ace_jacket/player_generic_ace_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.russian_ace_jacket_001_lower = {
		name = "character_customization_soviet_ace_jacket_001_lower_name",
		description = "character_customization_soviet_ace_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/ace_jacket/player_soviet_ace_jacket_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/ace_jacket/player_soviet_ace_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		droppable = true
	}
	self.customizations.american_ace_jacket_001_upper = {
		name = "character_customization_usa_ace_jacket_001_upper_name",
		description = "character_customization_usa_ace_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/ace_jacket/player_criminal_usa_ace_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/ace_jacket/player_generic_ace_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_ace_jacket_001_lower = {
		name = "character_customization_usa_ace_jacket_001_lower_name",
		description = "character_customization_usa_ace_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/ace_jacket/player_usa_ace_jacket_lower",
		path_short = "units/vanilla/characters/players/usa/lower/ace_jacket/player_usa_ace_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/ace_jacket/player_ace_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		droppable = true
	}
	self.customizations.british_bomber_jacket_001_upper = {
		name = "character_customization_british_bomber_jacket_001_upper_name",
		description = "character_customization_british_bomber_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/bomber_jacket/player_criminal_british_bomber_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/bomber_jacket/player_generic_bomber_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.british_bomber_jacket_001_lower = {
		name = "character_customization_british_bomber_jacket_001_lower_name",
		description = "character_customization_british_bomber_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/bomber_jacket/player_british_bomber_jacket_lower",
		path_short = "units/vanilla/characters/players/british/lower/bomber_jacket/player_british_bomber_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customizations.german_bomber_jacket_001_upper = {
		name = "character_customization_german_bomber_jacket_001_upper_name",
		description = "character_customization_german_bomber_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/bomber_jacket/player_criminal_german_bomber_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/bomber_jacket/player_generic_bomber_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.german_bomber_jacket_001_lower = {
		name = "character_customization_german_bomber_jacket_001_lower_name",
		description = "character_customization_german_bomber_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/bomber_jacket/player_german_bomber_jacket_lower",
		path_short = "units/vanilla/characters/players/german/lower/bomber_jacket/player_german_bomber_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customizations.russian_bomber_jacket_001_upper = {
		name = "character_customization_soviet_bomber_jacket_001_upper_name",
		description = "character_customization_soviet_bomber_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/bomber_jacket/player_criminal_soviet_bomber_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/bomber_jacket/player_generic_bomber_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.russian_bomber_jacket_001_lower = {
		name = "character_customization_soviet_bomber_jacket_001_lower_name",
		description = "character_customization_soviet_bomber_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/bomber_jacket/player_soviet_bomber_jacket_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/bomber_jacket/player_soviet_bomber_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customizations.american_bomber_jacket_001_upper = {
		name = "character_customization_usa_bomber_jacket_001_upper_name",
		description = "character_customization_usa_bomber_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/bomber_jacket/player_criminal_usa_bomber_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_upper_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/bomber_jacket/player_generic_bomber_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT
	}
	self.customizations.american_bomber_jacket_001_lower = {
		name = "character_customization_usa_bomber_jacket_001_lower_name",
		description = "character_customization_usa_bomber_jacket_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/bomber_jacket/player_usa_bomber_jacket_lower",
		path_short = "units/vanilla/characters/players/usa/lower/bomber_jacket/player_usa_bomber_jacket_lower_short",
		path_icon = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/bomber_jacket/player_bomber_jacket_large_lower_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customizations.british_eagle_jacket_001_upper = {
		name = "character_customization_british_eagle_jacket_001_upper_name",
		description = "character_customization_british_eagle_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path = "units/vanilla/characters/players/british/upper/eagle_jacket/player_british_eagle_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.british_eagle_pants_001_lower = {
		name = "character_customization_british_eagle_pants_001_lower_name",
		description = "character_customization_british_eagle_pants_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_BRITISH
		},
		path_long = "units/vanilla/characters/players/british/lower/eagle_pants/player_british_eagle_lower",
		path_short = "units/vanilla/characters/players/british/lower/eagle_pants/player_british_eagle_lower_short",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.german_eagle_jacket_001_upper = {
		name = "character_customization_german_eagle_jacket_001_upper_name",
		description = "character_customization_german_eagle_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path = "units/vanilla/characters/players/german/upper/eagle_jacket/player_german_eagle_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.german_eagle_pants_001_lower = {
		name = "character_customization_german_eagle_pants_001_lower_name",
		description = "character_customization_german_eagle_pants_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_GERMAN
		},
		path_long = "units/vanilla/characters/players/german/lower/eagle_pants/player_german_eagle_lower",
		path_short = "units/vanilla/characters/players/german/lower/eagle_pants/player_german_eagle_lower_short",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}
	self.customizations.russian_eagle_jacket_001_upper = {
		name = "character_customization_russian_eagle_jacket_001_upper_name",
		description = "character_customization_russian_eagle_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path = "units/vanilla/characters/players/soviet/upper/eagle_jacket/player_soviet_eagle_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.russian_eagle_pants_001_lower = {
		name = "character_customization_russian_eagle_pants_001_lower_name",
		description = "character_customization_russian_eagle_pants_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_RUSSIAN
		},
		path_long = "units/vanilla/characters/players/soviet/lower/eagle_pants/player_soviet_eagle_lower",
		path_short = "units/vanilla/characters/players/soviet/lower/eagle_pants/player_soviet_eagle_lower_short",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customizations.american_eagle_jacket_001_upper = {
		name = "character_customization_american_eagle_jacket_001_upper_name",
		description = "character_customization_american_eagle_jacket_001_upper_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_UPPER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path = "units/vanilla/characters/players/usa/upper/eagle_jacket/player_usa_eagle_jacket_upper",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_upper_large_hud",
		path_fps_hands = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_jacket_fp",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		length = CharacterCustomizationTweakData.PART_LENGTH_SHORT,
		droppable = true
	}
	self.customizations.american_eagle_pants_001_lower = {
		name = "character_customization_american_eagle_pants_001_lower_name",
		description = "character_customization_american_eagle_pants_001_lower_desc",
		part_type = CharacterCustomizationTweakData.PART_TYPE_LOWER,
		nationalities = {
			CharacterCustomizationTweakData.NATIONALITY_AMERICAN
		},
		path_long = "units/vanilla/characters/players/usa/lower/eagle_pants/player_usa_eagle_lower",
		path_short = "units/vanilla/characters/players/usa/lower/eagle_pants/player_usa_eagle_lower_short",
		path_icon = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_hud",
		path_icon_large = "units/vanilla/characters/players/generic/eagle_jacket/player_generic_eagle_lower_large_hud",
		redeem_xp = 0,
		rarity = LootDropTweakData.RARITY_RARE,
		droppable = true
	}

	for k, cosmetic in pairs(self.customizations) do
		if not cosmetic.default_clothing and not cosmetic.dlc and cosmetic.rarity then
			local gold = LootDropTweakData:get_gold_from_rarity(cosmetic.rarity)

			if gold then
				cosmetic.gold_price = gold
			end
		end
	end

	self._head_index = {
		"american_default_head",
		"german_default_head",
		"british_default_head",
		"russian_default_head"
	}
	self._upper_index = {
		"american_default_upper",
		"german_default_upper",
		"british_default_upper",
		"russian_default_upper",
		"american_gangbanger_001_upper",
		"russian_commisar_001_upper",
		"german_officer_001_upper",
		"british_officer_001_upper",
		"british_casual_001_upper",
		"british_casual_003_upper",
		"british_casual_004_upper",
		"british_gangbanger_001_upper",
		"russian_commisar_002_upper",
		"german_gangbanger_001_upper",
		"american_gangbanger_002_upper",
		"german_officer_002_upper",
		"russian_casual_001_upper",
		"american_casual_001_upper",
		"american_officer_001_upper",
		"american_officer_002_upper",
		"american_grunt_001_upper",
		"german_grunt_001_upper",
		"german_grunt_002_upper",
		"russian_commisar_003_upper",
		"russian_mech_001_upper",
		"russian_grunt_001_upper",
		"british_casual_002_upper",
		"american_gold_jacket_001_upper",
		"russian_gold_jacket_001_upper",
		"german_gold_jacket_002_upper",
		"british_gold_jacket_001_upper",
		"german_gangbanger_002_upper",
		"american_gangbanger_003_upper",
		"russian_grunt_002_upper",
		"german_grunt_003_upper",
		"british_officer_002_upper",
		"british_bomber_jacket_001_upper",
		"american_bomber_jacket_001_upper",
		"german_bomber_jacket_001_upper",
		"russian_bomber_jacket_001_upper",
		"british_eagle_jacket_001_upper",
		"german_eagle_jacket_001_upper",
		"russian_eagle_jacket_001_upper",
		"american_eagle_jacket_001_upper",
		"american_gold_collector_jacket_001_upper",
		"russian_gold_collector_jacket_001_upper",
		"german_gold_collector_jacket_001_upper",
		"british_gold_collector_jacket_001_upper",
		"american_special_edition_001_upper",
		"british_special_edition_001_upper",
		"russian_special_edition_001_upper",
		"german_special_edition_001_upper",
		"british_highlander_jacket_upper",
		"american_highlander_jacket_upper",
		"russian_highlander_jacket_upper",
		"german_highlander_jacket_upper",
		"british_ace_jacket_001_upper",
		"german_ace_jacket_001_upper",
		"american_ace_jacket_001_upper",
		"russian_ace_jacket_001_upper"
	}
	self._lower_index = {
		"american_default_lower",
		"german_default_lower",
		"british_default_lower",
		"russian_default_lower",
		"american_gangbanger_001_lower",
		"russian_commisar_001_lower",
		"german_officer_001_lower",
		"british_officer_001_lower",
		"british_casual_001_lower",
		"british_casual_003_lower",
		"british_casual_004_lower",
		"british_gangbanger_001_lower",
		"russian_commisar_002_lower",
		"german_gangbanger_001_lower",
		"american_gangbanger_002_lower",
		"german_officer_002_lower",
		"russian_casual_001_lower",
		"american_casual_001_lower",
		"american_officer_001_lower",
		"american_officer_002_lower",
		"american_grunt_001_lower",
		"german_grunt_001_lower",
		"german_grunt_002_lower",
		"russian_commisar_003_lower",
		"russian_mech_001_lower",
		"russian_grunt_001_lower",
		"british_casual_002_lower",
		"german_gangbanger_002_lower",
		"american_gangbanger_003_lower",
		"russian_grunt_002_lower",
		"german_grunt_003_lower",
		"british_officer_002_lower",
		"british_bomber_jacket_001_lower",
		"american_bomber_jacket_001_lower",
		"german_bomber_jacket_001_lower",
		"russian_bomber_jacket_001_lower",
		"british_eagle_pants_001_lower",
		"german_eagle_pants_001_lower",
		"russian_eagle_pants_001_lower",
		"american_eagle_pants_001_lower",
		"british_highlander_jacket_lower",
		"german_highlander_jacket_lower",
		"russian_highlander_jacket_lower",
		"american_highlander_jacket_lower",
		"british_ace_jacket_001_lower",
		"german_ace_jacket_001_lower",
		"american_ace_jacket_001_lower",
		"russian_ace_jacket_001_lower"
	}
end

-- Lines 1767-1777
function CharacterCustomizationTweakData:get_index_table(part_type)
	local source_table = {}

	if part_type == CharacterCustomizationTweakData.PART_TYPE_HEAD then
		source_table = clone(self._head_index)
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		source_table = clone(self._upper_index)
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		source_table = clone(self._lower_index)
	end

	return source_table
end

-- Lines 1779-1792
function CharacterCustomizationTweakData:get_all_parts_indexed(part_type, nationality, owned)
	local result = {}
	local source_table = self:get_index_table(part_type)

	for index, part_key in ipairs(source_table) do
		result[index] = {}
		local data_part = clone(self.customizations[part_key])
		data_part.key_name = part_key
		result[index] = data_part
	end

	return result
end

-- Lines 1794-1807
function CharacterCustomizationTweakData:get_all_parts(part_type)
	local result = {}
	local source_table = self:get_index_table(part_type)

	for index, part_key in ipairs(source_table) do
		result[part_key] = {}
		local data_part = clone(self.customizations[part_key])
		data_part.key_name = part_key
		result[part_key] = data_part
	end

	return result
end

-- Lines 1810-1822
function CharacterCustomizationTweakData:get_defaults()
	local customizations = {}

	for key, customization in pairs(self.customizations) do
		if self:_is_customization_default(key, customization) then
			customizations[key] = customization
		end
	end

	return customizations
end

-- Lines 1825-1835
function CharacterCustomizationTweakData:get_reward_loot_by_rarity(rarity)
	local customizations = {}

	for key, customization in pairs(self.customizations) do
		if customization.rarity == rarity and customization.droppable and self:_is_customization_droppable(customization) then
			table.insert(customizations, key)
		end
	end

	return customizations
end

-- Lines 1838-1846
function CharacterCustomizationTweakData:get_droppable_customizations()
	local customizations = {}

	for key, customization in pairs(self.customizations) do
		if self:_is_customization_droppable(customization) then
			table.insert(customizations, key)
		end
	end

	return customizations
end

-- Lines 1849-1868
function CharacterCustomizationTweakData:_is_customization_droppable(customization)
	if not customization.droppable then
		return false
	end

	if customization.dlc and not managers.dlc:is_dlc_unlocked(customization.dlc) then
		return false
	end

	return true
end

-- Lines 1871-1889
function CharacterCustomizationTweakData:_is_customization_default(key, customization)
	if customization.default_clothing then
		return true
	end

	if customization.droppable or customization.gold_price then
		return false
	end

	local unlocked_customizations = tweak_data.dlc:get_unlocked_customizations()

	if customization.dlc and not unlocked_customizations[key] then
		return false
	end

	return true
end
