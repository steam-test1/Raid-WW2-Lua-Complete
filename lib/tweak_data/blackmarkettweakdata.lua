BlackMarketTweakData = BlackMarketTweakData or class()

require("lib/tweak_data/blackmarket/ColorsTweakData")
require("lib/tweak_data/blackmarket/MaterialsTweakData")
require("lib/tweak_data/blackmarket/TexturesTweakData")
require("lib/tweak_data/blackmarket/MasksTweakData")
require("lib/tweak_data/blackmarket/MeleeWeaponsTweakData")
require("lib/tweak_data/blackmarket/WeaponSkinsTweakData")

local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")

-- Lines 23-43
function BlackMarketTweakData:init(tweak_data)
	self:_init_colors()
	self:_init_materials()
	self:_init_textures()
	self:_init_masks()
	self:_init_characters()
	self:_init_cash()
	self:_init_xp()
	self:_init_armors()
	self:_init_deployables(tweak_data)
	self:_init_melee_weapons()
	self:_init_weapon_skins()
	self:_init_weapon_mods(tweak_data)
end

-- Lines 47-77
function BlackMarketTweakData:print_missing_strings(skip_print_id)
end

-- Lines 79-88
function BlackMarketTweakData:_add_desc_from_name_macro(tweak_data)
	for id, data in pairs(tweak_data) do
		if data.name_id and not data.desc_id then
			data.desc_id = tostring(data.name_id) .. "_desc"
		end

		if not data.name_id then
			-- Nothing
		end
	end
end

-- Lines 92-111
function BlackMarketTweakData:_init_weapon_mods(tweak_data)
	self.weapon_mods = {}

	for id, data in pairs(tweak_data.weapon.factory.parts) do
		if is_nextgen_console then
			data.is_a_unlockable = nil
		end

		self.weapon_mods[id] = {
			max_in_inventory = data.is_a_unlockable and 1 or 2,
			pc = data.pc,
			pcs = data.pcs,
			dlc = data.dlc,
			dlcs = data.dlcs,
			name_id = data.name_id,
			desc_id = data.desc_id,
			infamous = data.infamous,
			value = data.stats and data.stats.value or 1,
			weight = data.weight,
			texture_bundle_folder = data.texture_bundle_folder,
			is_a_unlockable = data.is_a_unlockable,
			unatainable = data.unatainable
		}
	end

	self:_add_desc_from_name_macro(self.weapon_mods)
end

-- Lines 115-169
function BlackMarketTweakData:_init_characters()
	self.characters = {
		american = {}
	}
	self.characters.american.fps_unit = "units/vanilla/characters/players/fps_mover/fps_mover"
	self.characters.american.npc_unit = "units/vanilla/characters/players/players_default/npc_players_default"
	self.characters.american.sequence = "american"
	self.characters.american.name_id = "bm_character_american"
	self.characters.german = {
		fps_unit = "units/vanilla/characters/players/fps_mover/fps_mover",
		npc_unit = "units/vanilla/characters/players/players_default/npc_players_default",
		sequence = "german",
		name_id = "bm_character_german"
	}
	self.characters.british = {
		fps_unit = "units/vanilla/characters/players/fps_mover/fps_mover",
		npc_unit = "units/vanilla/characters/players/players_default/npc_players_default",
		sequence = "british",
		name_id = "bm_character_british"
	}
	self.characters.russian = {
		fps_unit = "units/vanilla/characters/players/fps_mover/fps_mover",
		npc_unit = "units/vanilla/characters/players/players_default/npc_players_default",
		sequence = "russian",
		name_id = "bm_character_russian"
	}
	self.characters.ai_german = {
		fps_unit = "units/temp/characters/fps_mover_ger/fps_mover",
		npc_unit = "units/vanilla/characters/players/german/npc_criminal_ger",
		sequence = "var_mtr_german",
		name_id = "bm_character_ai_german"
	}
	self.characters.ai_british = {
		fps_unit = "units/temp/characters/fps_mover_uk/fps_mover",
		npc_unit = "units/vanilla/characters/players/british/npc_criminal_uk",
		sequence = "var_mtr_brit",
		name_id = "bm_character_ai_brit"
	}
	self.characters.ai_american = {
		npc_unit = "units/vanilla/characters/players/usa/npc_criminal_usa",
		sequence = "var_mtr_amer",
		name_id = "bm_character_ai_amer"
	}
	self.characters.ai_russian = {
		fps_unit = "units/temp/characters/fps_mover_ru/fps_mover",
		npc_unit = "units/vanilla/characters/players/soviet/npc_criminal_ru",
		sequence = "var_mtr_rus",
		name_id = "bm_character_ai_rus"
	}
end

-- Lines 173-249
function BlackMarketTweakData:_init_cash()
	self.cash = {
		cash10 = {}
	}
	self.cash.cash10.name_id = "bm_csh_cash10"
	self.cash.cash10.value_id = "cash10"
	self.cash.cash10.multiplier = 1
	self.cash.cash10.pcs = {
		10,
		40
	}
	self.cash.cash20 = {
		name_id = "bm_csh_cash20",
		value_id = "cash20",
		multiplier = 1,
		pcs = {
			20,
			40
		}
	}
	self.cash.cash30 = {
		name_id = "bm_csh_cash30",
		multiplier = 1,
		value_id = "cash30",
		pcs = {
			30,
			40
		}
	}
	self.cash.cash40 = {
		name_id = "bm_csh_cash40",
		multiplier = 1,
		value_id = "cash40",
		pcs = {
			20,
			30,
			40
		}
	}
	self.cash.cash50 = {
		name_id = "bm_csh_cash50",
		multiplier = 1,
		value_id = "cash50",
		pcs = {
			30,
			40,
			50
		}
	}
	self.cash.cash60 = {
		name_id = "bm_csh_cash60",
		value_id = "cash60",
		multiplier = 1,
		pcs = {
			40,
			50,
			60
		}
	}
	self.cash.cash70 = {
		name_id = "bm_csh_cash70",
		value_id = "cash70",
		multiplier = 1,
		pcs = {
			50,
			60,
			70
		}
	}
	self.cash.cash80 = {
		name_id = "bm_csh_cash80",
		value_id = "cash80",
		multiplier = 1,
		pcs = {
			60,
			70,
			80
		}
	}
	self.cash.cash90 = {
		name_id = "bm_csh_cash90",
		value_id = "cash90",
		multiplier = 1,
		pcs = {
			70,
			80,
			90
		}
	}
	self.cash.cash100 = {
		name_id = "bm_csh_cash100",
		value_id = "cash100",
		multiplier = 1,
		pcs = {
			80,
			90,
			100
		}
	}
	self.cash.cash_preorder = {
		name_id = "bm_csh_cash_preorder",
		value_id = "cash_preorder",
		multiplier = 1.2
	}

	if SystemInfo:platform() == Idstring("XB1") then
		self.cash.xone_bonus = {
			name_id = "bm_csh_cash_xone",
			value_id = "xone_bonus",
			multiplier = 1
		}
	end
end

-- Lines 253-315
function BlackMarketTweakData:_init_xp()
	self.xp = {
		xp10 = {}
	}
	self.xp.xp10.name_id = "bm_exp_xp10"
	self.xp.xp10.value_id = "xp10"
	self.xp.xp10.multiplier = 1
	self.xp.xp10.pcs = {
		10,
		40
	}
	self.xp.xp20 = {
		name_id = "bm_exp_xp20",
		value_id = "xp20",
		multiplier = 1,
		pcs = {
			20,
			40
		}
	}
	self.xp.xp30 = {
		name_id = "bm_exp_xp30",
		multiplier = 1,
		value_id = "xp30",
		pcs = {
			30,
			40
		}
	}
	self.xp.xp40 = {
		name_id = "bm_exp_xp40",
		multiplier = 1,
		value_id = "xp40",
		pcs = {
			20,
			30,
			40
		}
	}
	self.xp.xp50 = {
		name_id = "bm_exp_xp50",
		multiplier = 1,
		value_id = "xp50",
		pcs = {
			30,
			40,
			50
		}
	}
	self.xp.xp60 = {
		name_id = "bm_exp_xp60",
		value_id = "xp60",
		multiplier = 1,
		pcs = {
			40,
			50,
			60
		}
	}
	self.xp.xp70 = {
		name_id = "bm_exp_xp70",
		value_id = "xp70",
		multiplier = 1,
		pcs = {
			50,
			60,
			70
		}
	}
	self.xp.xp80 = {
		name_id = "bm_exp_xp80",
		value_id = "xp80",
		multiplier = 1,
		pcs = {
			60,
			70,
			80
		}
	}
	self.xp.xp90 = {
		name_id = "bm_exp_xp90",
		value_id = "xp90",
		multiplier = 1,
		pcs = {
			70,
			80,
			90
		}
	}
	self.xp.xp100 = {
		name_id = "bm_exp_xp100",
		value_id = "xp100",
		multiplier = 1,
		pcs = {
			80,
			90,
			100
		}
	}
end

-- Lines 319-358
function BlackMarketTweakData:_init_armors()
	self.armors = {
		level_1 = {}
	}
	self.armors.level_1.name_id = "bm_armor_level_1"
	self.armors.level_1.sequence = "var_model_01"
	self.armors.level_1.upgrade_level = 1
	self.armors.level_2 = {
		name_id = "bm_armor_level_2",
		sequence = "var_model_02",
		upgrade_level = 2
	}
	self.armors.level_3 = {
		name_id = "bm_armor_level_3",
		sequence = "var_model_03",
		upgrade_level = 3
	}
	self.armors.level_4 = {
		name_id = "bm_armor_level_4",
		sequence = "var_model_04",
		upgrade_level = 4
	}
	self.armors.level_5 = {
		name_id = "bm_armor_level_5",
		sequence = "var_model_05",
		upgrade_level = 5
	}
	self.armors.level_6 = {
		name_id = "bm_armor_level_6",
		sequence = "var_model_06",
		upgrade_level = 6
	}
	self.armors.level_7 = {
		name_id = "bm_armor_level_7",
		sequence = "var_model_07",
		upgrade_level = 7
	}

	self:_add_desc_from_name_macro(self.armors)
end

-- Lines 362-385
function BlackMarketTweakData:_init_deployables(tweak_data)
	self.deployables = {
		doctor_bag = {}
	}
	self.deployables.doctor_bag.name_id = "bm_equipment_doctor_bag"
	self.deployables.ammo_bag = {
		name_id = "bm_equipment_ammo_bag"
	}
	self.deployables.trip_mine = {
		name_id = "bm_equipment_trip_mine"
	}
	self.deployables.armor_kit = {
		name_id = "bm_equipment_armor_kit"
	}
	self.deployables.first_aid_kit = {
		name_id = "bm_equipment_first_aid_kit"
	}
	self.deployables.bodybags_bag = {
		name_id = "bm_equipment_bodybags_bag"
	}

	self:_add_desc_from_name_macro(self.deployables)
end
