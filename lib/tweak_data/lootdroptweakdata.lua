LootDropTweakData = LootDropTweakData or class()
LootDropTweakData.LOOT_GROUP_PREFIX = "loot_group_"
LootDropTweakData.REWARD_XP = "xp"
LootDropTweakData.REWARD_CARD_PACK = "card_pack"
LootDropTweakData.REWARD_CUSTOMIZATION = "customization"
LootDropTweakData.REWARD_WEAPON_POINT = "weapon_point"
LootDropTweakData.REWARD_MELEE_WEAPON = "melee_weapon"
LootDropTweakData.REWARD_GOLD_BARS = "gold_bars"
LootDropTweakData.REWARD_HALLOWEEN_2017 = "halloween_2017"
LootDropTweakData.RARITY_ALL = "loot_rarity_all"
LootDropTweakData.RARITY_OTHER = "loot_rarity_other"
LootDropTweakData.RARITY_DEFAULT = "loot_rarity_default"
LootDropTweakData.RARITY_NONE = "loot_rarity_none"
LootDropTweakData.RARITY_COMMON = "loot_rarity_common"
LootDropTweakData.RARITY_UNCOMMON = "loot_rarity_uncommon"
LootDropTweakData.RARITY_RARE = "loot_rarity_rare"
LootDropTweakData.RARITY_HALLOWEEN_2017 = "loot_rarity_halloween"
LootDropTweakData.RARITY_LIST = {
	LootDropTweakData.RARITY_ALL,
	LootDropTweakData.RARITY_DEFAULT,
	LootDropTweakData.RARITY_COMMON,
	LootDropTweakData.RARITY_UNCOMMON,
	LootDropTweakData.RARITY_RARE,
	LootDropTweakData.RARITY_NONE,
	LootDropTweakData.RARITY_HALLOWEEN_2017
}
LootDropTweakData.LOOT_VALUE_TYPE_SMALL_AMOUNT = 1
LootDropTweakData.LOOT_VALUE_TYPE_MEDIUM_AMOUNT = 4
LootDropTweakData.LOOT_VALUE_TYPE_BIG_AMOUNT = 5
LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_AMOUNT = 1
LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_BIG_AMOUNT = 3
LootDropTweakData.TOTAL_LOOT_VALUE_DEFAULT = 35
LootDropTweakData.TOTAL_DOGTAGS_DEFAULT = 25
LootDropTweakData.BRONZE_POINT_REQUIREMENT = 0.2
LootDropTweakData.SILVER_POINT_REQUIREMENT = 0.6
LootDropTweakData.GOLD_POINT_REQUIREMENT = 0.85
LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL = "below_max_level"
LootDropTweakData.POINT_REQUIREMENTS = {
	LootDropTweakData.BRONZE_POINT_REQUIREMENT,
	LootDropTweakData.SILVER_POINT_REQUIREMENT,
	LootDropTweakData.GOLD_POINT_REQUIREMENT
}
LootDropTweakData.EVENT_MONTH_FOOLSDAY = "EVENT_MONTH_FOOLSDAY"
LootDropTweakData.EVENT_MONTH_HALLOWEEN = "EVENT_MONTH_HALLOWEEN"
LootDropTweakData.EVENT_MONTH_CHRISTMAS = "EVENT_MONTH_CHRISTMAS"
LootDropTweakData.EVENT_MONTHS = {
	[10] = LootDropTweakData.EVENT_MONTH_HALLOWEEN
}

function LootDropTweakData:init(tweak_data)
	self:_payday_init(tweak_data)
	self:_init_xp_packs()
	self:_init_card_packs()
	self:_init_customization_rewards()
	self:_init_gold_bar_rewards()
	self:_init_categories()
	self:_init_groups()
	self:_init_loot_values()
	self:_init_dog_tag_stats()

	self.difficulty_reward_multiplier = {
		1,
		2,
		3,
		4.5
	}
end

function LootDropTweakData:_init_xp_packs()
	self.xp_packs = {}

	local multi = 2
	local xp = 500
	local xp2 = xp * multi

	self.xp_packs.tiny = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	xp = xp2
	xp2 = xp * multi
	self.xp_packs.small = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	xp = xp2
	xp2 = xp * multi
	self.xp_packs.medium = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	xp = xp2
	xp2 = xp * multi
	self.xp_packs.large = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
end

function LootDropTweakData:_init_card_packs()
	self.card_packs = {}
	self.card_packs.regular = {
		reward_type = LootDropTweakData.REWARD_CARD_PACK,
		pack_type = ChallengeCardsTweakData.PACK_TYPE_REGULAR
	}
end

function LootDropTweakData:_init_customization_rewards()
	self.customization_rewards = {}
	self.customization_rewards.common = {
		reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
		rarity = LootDropTweakData.RARITY_COMMON
	}
	self.customization_rewards.uncommon = {
		reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
		rarity = LootDropTweakData.RARITY_UNCOMMON
	}
	self.customization_rewards.rare = {
		reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
		rarity = LootDropTweakData.RARITY_RARE
	}
	self.customization_rewards.halloween = {
		reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017
	}
end

function LootDropTweakData:_init_gold_bar_rewards()
	self.gold_bar_rewards = {}
	self.gold_bar_rewards.tiny = {
		gold_bars_max = 1,
		gold_bars_min = 1,
		reward_type = LootDropTweakData.REWARD_GOLD_BARS
	}
	self.gold_bar_rewards.small = {
		gold_bars_max = 4,
		gold_bars_min = 2,
		reward_type = LootDropTweakData.REWARD_GOLD_BARS
	}
	self.gold_bar_rewards.medium = {
		gold_bars_max = 10,
		gold_bars_min = 5,
		reward_type = LootDropTweakData.REWARD_GOLD_BARS
	}
	self.gold_bar_rewards.large = {
		gold_bars_max = 15,
		gold_bars_min = 11,
		reward_type = LootDropTweakData.REWARD_GOLD_BARS
	}
end

function LootDropTweakData:_init_categories()
	self.loot_categories = {}
	self.loot_categories.category_xp_min = {}
	self.loot_categories.category_xp_min[1] = {
		chance = 100,
		value = self.xp_packs.tiny
	}
	self.loot_categories.category_xp_low = {}
	self.loot_categories.category_xp_low[1] = {
		chance = 100,
		value = self.xp_packs.small
	}
	self.loot_categories.category_xp_mid = {}
	self.loot_categories.category_xp_mid[1] = {
		chance = 100,
		value = self.xp_packs.medium
	}
	self.loot_categories.category_xp_high = {}
	self.loot_categories.category_xp_high[1] = {
		chance = 100,
		value = self.xp_packs.large
	}
	self.loot_categories.category_gold_tiny = {}
	self.loot_categories.category_gold_tiny[1] = {
		chance = 100,
		value = self.gold_bar_rewards.tiny
	}
	self.loot_categories.category_gold_low = {}
	self.loot_categories.category_gold_low[1] = {
		chance = 100,
		value = self.gold_bar_rewards.small
	}
	self.loot_categories.category_gold_mid = {}
	self.loot_categories.category_gold_mid[1] = {
		chance = 100,
		value = self.gold_bar_rewards.medium
	}
	self.loot_categories.category_gold_high = {}
	self.loot_categories.category_gold_high[1] = {
		chance = 100,
		value = self.gold_bar_rewards.large
	}
	self.loot_categories.category_melee = {}
	self.loot_categories.category_melee[1] = {
		chance = 100,
		value = {
			reward_type = LootDropTweakData.REWARD_MELEE_WEAPON
		}
	}
	self.loot_categories.category_cards_pack = {}
	self.loot_categories.category_cards_pack[1] = {
		chance = 100,
		value = self.card_packs.regular
	}
	self.loot_categories.category_cosmetics = {}
	self.loot_categories.category_cosmetics[1] = {
		chance = 50,
		value = self.customization_rewards.common
	}
	self.loot_categories.category_cosmetics[2] = {
		chance = 30,
		value = self.customization_rewards.uncommon
	}
	self.loot_categories.category_cosmetics[3] = {
		chance = 15,
		value = self.customization_rewards.rare
	}
	self.loot_categories.category_halloween_2017 = {}
	self.loot_categories.category_halloween_2017[1] = {
		chance = 20,
		value = {
			weapon_id = "lc14b",
			reward_type = LootDropTweakData.REWARD_HALLOWEEN_2017
		}
	}
	self.loot_categories.category_halloween_2017[2] = {
		chance = 80,
		value = self.customization_rewards.halloween
	}
end

function LootDropTweakData:_init_groups()
	self.loot_groups = {}
	self.loot_groups_doubles_fallback = {}

	self:_init_groups_basic()
	self:_init_groups_bronze()
	self:_init_groups_silver()
	self:_init_groups_gold()
	self:_init_groups_challenges()
end

function LootDropTweakData:_init_groups_basic()
	self.loot_groups_doubles_fallback.loot_group_basic = {}

	table.insert(self.loot_groups_doubles_fallback.loot_group_basic, {
		chance = 30,
		conditions = {
			LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
		},
		value = self.loot_categories.category_xp_min
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_basic, {
		chance = 15,
		value = self.loot_categories.category_gold_tiny
	})

	self.loot_groups.loot_group_basic = deep_clone(self.loot_groups_doubles_fallback.loot_group_basic)
end

function LootDropTweakData:_init_groups_bronze()
	self.loot_groups_doubles_fallback.loot_group_bronze = {}

	table.insert(self.loot_groups_doubles_fallback.loot_group_bronze, {
		chance = 20,
		conditions = {
			LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
		},
		value = self.loot_categories.category_xp_min
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_bronze, {
		chance = 20,
		conditions = {
			LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
		},
		value = self.loot_categories.category_xp_low
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_bronze, {
		chance = 60,
		value = self.loot_categories.category_gold_low
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_bronze, {
		chance = 60,
		value = self.loot_categories.category_gold_mid
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_bronze, {
		chance = 15,
		value = self.loot_categories.category_cards_pack
	})

	self.loot_groups.loot_group_bronze = deep_clone(self.loot_groups_doubles_fallback.loot_group_bronze)
end

function LootDropTweakData:_init_groups_silver()
	self.loot_groups_doubles_fallback.loot_group_silver = {}

	table.insert(self.loot_groups_doubles_fallback.loot_group_silver, {
		chance = 40,
		conditions = {
			LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
		},
		value = self.loot_categories.category_xp_mid
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_silver, {
		chance = 60,
		value = self.loot_categories.category_gold_low
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_silver, {
		chance = 30,
		value = self.loot_categories.category_gold_mid
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_silver, {
		chance = 15,
		value = self.loot_categories.category_cards_pack
	})

	self.loot_groups.loot_group_silver = deep_clone(self.loot_groups_doubles_fallback.loot_group_silver)

	table.insert(self.loot_groups.loot_group_silver, {
		chance = 20,
		value = self.loot_categories.category_melee
	})
	table.insert(self.loot_groups.loot_group_silver, {
		chance = 10,
		value = self.loot_categories.category_cosmetics
	})
end

function LootDropTweakData:_init_groups_gold()
	self.loot_groups_doubles_fallback.loot_group_gold = {}

	table.insert(self.loot_groups_doubles_fallback.loot_group_gold, {
		chance = 40,
		conditions = {
			LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
		},
		value = self.loot_categories.category_xp_high
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_gold, {
		chance = 90,
		value = self.loot_categories.category_gold_high
	})
	table.insert(self.loot_groups_doubles_fallback.loot_group_gold, {
		chance = 15,
		value = self.loot_categories.category_cards_pack
	})

	self.loot_groups.loot_group_gold = deep_clone(self.loot_groups_doubles_fallback.loot_group_gold)

	table.insert(self.loot_groups.loot_group_gold, {
		chance = 30,
		value = self.loot_categories.category_melee
	})
	table.insert(self.loot_groups.loot_group_gold, {
		chance = 20,
		value = self.loot_categories.category_cosmetics
	})
end

function LootDropTweakData:_init_groups_challenges()
	self.loot_groups.loot_group_halloween_2017 = {}
	self.loot_groups.loot_group_halloween_2017[1] = {
		chance = 100,
		value = self.loot_categories.category_halloween_2017
	}
	self.loot_groups.loot_group_halloween_2017.min_loot_value = 9999998
	self.loot_groups.loot_group_halloween_2017.max_loot_value = 9999999
end

function LootDropTweakData:_init_loot_values()
	self.loot_groups.loot_group_basic.min_loot_value = -1000000
	self.loot_groups.loot_group_basic.max_loot_value = LootDropTweakData.BRONZE_POINT_REQUIREMENT
	self.loot_groups.loot_group_bronze.min_loot_value = LootDropTweakData.BRONZE_POINT_REQUIREMENT
	self.loot_groups.loot_group_bronze.max_loot_value = LootDropTweakData.SILVER_POINT_REQUIREMENT
	self.loot_groups.loot_group_silver.min_loot_value = LootDropTweakData.SILVER_POINT_REQUIREMENT
	self.loot_groups.loot_group_silver.max_loot_value = LootDropTweakData.GOLD_POINT_REQUIREMENT
	self.loot_groups.loot_group_gold.min_loot_value = LootDropTweakData.GOLD_POINT_REQUIREMENT
	self.loot_groups.loot_group_gold.max_loot_value = 1000000
	self.loot_groups_doubles_fallback.loot_group_basic.min_loot_value = self.loot_groups.loot_group_basic.min_loot_value
	self.loot_groups_doubles_fallback.loot_group_basic.max_loot_value = self.loot_groups.loot_group_basic.max_loot_value
	self.loot_groups_doubles_fallback.loot_group_bronze.min_loot_value = self.loot_groups.loot_group_bronze.min_loot_value
	self.loot_groups_doubles_fallback.loot_group_bronze.max_loot_value = self.loot_groups.loot_group_bronze.max_loot_value
	self.loot_groups_doubles_fallback.loot_group_silver.min_loot_value = self.loot_groups.loot_group_silver.min_loot_value
	self.loot_groups_doubles_fallback.loot_group_silver.max_loot_value = self.loot_groups.loot_group_silver.max_loot_value
	self.loot_groups_doubles_fallback.loot_group_gold.min_loot_value = self.loot_groups.loot_group_gold.min_loot_value
	self.loot_groups_doubles_fallback.loot_group_gold.max_loot_value = self.loot_groups.loot_group_gold.max_loot_value
end

function LootDropTweakData:_init_dog_tag_stats()
	self.dog_tag = {}
	self.dog_tag.loot_value = 125
end

function LootDropTweakData:_payday_init(tweak_data)
	self.PC_STEP = 10
	self.no_drop = {}
	self.no_drop.BASE = 35
	self.no_drop.HUMAN_STEP_MODIFIER = 10
	self.joker_chance = 0
	self.level_limit = 1
	self.risk_pc_multiplier = {
		0,
		0,
		0,
		0
	}
	self.risk_infamous_multiplier = {
		1,
		2,
		3,
		5
	}
	self.PC_CHANCE = {}
	self.PC_CHANCE[1] = 0.7
	self.PC_CHANCE[2] = 0.7
	self.PC_CHANCE[3] = 0.7
	self.PC_CHANCE[4] = 0.7
	self.PC_CHANCE[5] = 0.9
	self.PC_CHANCE[6] = 0.91
	self.PC_CHANCE[7] = 0.92
	self.PC_CHANCE[8] = 0.93
	self.PC_CHANCE[9] = 0.94
	self.PC_CHANCE[10] = 0.95
	self.STARS = {}
	self.STARS[1] = {
		pcs = {
			10,
			10
		}
	}
	self.STARS[2] = {
		pcs = {
			20,
			20
		}
	}
	self.STARS[3] = {
		pcs = {
			30,
			30
		}
	}
	self.STARS[4] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[5] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[6] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[7] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[8] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[9] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS[10] = {
		pcs = {
			40,
			40
		}
	}
	self.STARS_CURVES = {
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1
	}
	self.WEIGHTED_TYPE_CHANCE = {}

	local min = 10
	local max = 100
	local range = {
		cash = {
			20,
			5
		},
		weapon_mods = {
			50,
			45
		},
		colors = {
			6,
			11
		},
		textures = {
			7,
			12
		},
		materials = {
			7,
			12
		},
		masks = {
			10,
			15
		},
		xp = {
			8,
			0
		}
	}

	for i = min, max, 10 do
		local cash = math.lerp(range.cash[1], range.cash[2], i / max)
		local weapon_mods = math.lerp(range.weapon_mods[1], range.weapon_mods[2], i / max)
		local colors = math.lerp(range.colors[1], range.colors[2], i / max)
		local textures = math.lerp(range.textures[1], range.textures[2], i / max)
		local materials = math.lerp(range.materials[1], range.materials[2], i / max)
		local masks = math.lerp(range.masks[1], range.masks[2], i / max)
		local xp = math.lerp(range.xp[1], range.xp[2], i / max)

		self.WEIGHTED_TYPE_CHANCE[i] = {
			cash = cash,
			weapon_mods = weapon_mods,
			colors = colors,
			textures = textures,
			materials = materials,
			masks = masks,
			xp = xp
		}
	end

	self.DEFAULT_WEIGHT = 1
	self.got_item_weight_mod = 0.5
	self.type_weight_mod_funcs = {}

	function self.type_weight_mod_funcs.weapon_mods(global_value, category, id)
		local weapons = managers.weapon_factory:get_weapons_uses_part(id) or {}
		local primaries = managers.blackmarket:get_crafted_category("primaries") or {}
		local secondaries = managers.blackmarket:get_crafted_category("secondaries") or {}
		local crafted_weapons = {}

		for _, weapon in pairs(primaries) do
			table.insert(crafted_weapons, weapon.factory_id)
		end

		for _, weapon in pairs(secondaries) do
			table.insert(crafted_weapons, weapon.factory_id)
		end

		table.list_union(crafted_weapons)

		for _, factory_id in pairs(weapons) do
			if table.contains(crafted_weapons, factory_id) then
				return 2
			end
		end

		return 1
	end

	self.global_value_category = {}
	self.global_value_category.normal = {}
	self.global_value_category.normal.name_id = "bm_global_value_normal"
	self.global_value_category.normal.sort_number = 0
	self.global_value_category.dlc = {}
	self.global_value_category.dlc.name_id = "bm_menu_dlc"
	self.global_value_category.dlc.sort_number = 10
	self.global_value_category.global_event = {}
	self.global_value_category.global_event.name_id = "bm_menu_global_event"
	self.global_value_category.global_event.sort_number = 20
	self.global_value_category.infamous = {}
	self.global_value_category.infamous.name_id = "bm_global_value_infamous"
	self.global_value_category.infamous.sort_number = 30
	self.global_value_category.collaboration = {}
	self.global_value_category.collaboration.name_id = "bm_global_value_collaboration"
	self.global_value_category.collaboration.sort_number = 25
	self.global_values = {}
	self.global_values.normal = {}
	self.global_values.normal.name_id = "bm_global_value_normal"
	self.global_values.normal.desc_id = "menu_l_global_value_normal"
	self.global_values.normal.color = Color.white
	self.global_values.normal.dlc = false
	self.global_values.normal.chance = 0.84
	self.global_values.normal.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
	self.global_values.normal.durability_multiplier = 1
	self.global_values.normal.drops = true
	self.global_values.normal.track = false
	self.global_values.normal.sort_number = 0
	self.global_values.normal.category = "normal"
	self.global_values.superior = {}
	self.global_values.superior.name_id = "bm_global_value_superior"
	self.global_values.superior.desc_id = "menu_l_global_value_superior"
	self.global_values.superior.color = Color.blue
	self.global_values.superior.dlc = false
	self.global_values.superior.chance = 0.1
	self.global_values.superior.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "superior")
	self.global_values.superior.durability_multiplier = 1.5
	self.global_values.superior.drops = false
	self.global_values.superior.track = false
	self.global_values.superior.sort_number = 25
	self.global_values.superior.category = nil
	self.global_values.exceptional = {}
	self.global_values.exceptional.name_id = "bm_global_value_exceptional"
	self.global_values.exceptional.desc_id = "menu_l_global_value_exceptional"
	self.global_values.exceptional.color = Color.yellow
	self.global_values.exceptional.dlc = false
	self.global_values.exceptional.chance = 0.05
	self.global_values.exceptional.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "exceptional")
	self.global_values.exceptional.durability_multiplier = 2.25
	self.global_values.exceptional.drops = false
	self.global_values.exceptional.track = false
	self.global_values.exceptional.sort_number = 26
	self.global_values.exceptional.category = nil
	self.global_values.infamous = {}
	self.global_values.infamous.name_id = "bm_global_value_infamous"
	self.global_values.infamous.desc_id = "menu_l_global_value_infamous"
	self.global_values.infamous.color = Color(1, 0.1, 1)
	self.global_values.infamous.dlc = false
	self.global_values.infamous.chance = 0.05
	self.global_values.infamous.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "infamous")
	self.global_values.infamous.durability_multiplier = 3
	self.global_values.infamous.drops = true
	self.global_values.infamous.track = false
	self.global_values.infamous.sort_number = 30
	self.global_values.infamous.category = "infamous"
	self.global_values.infamy = {}
	self.global_values.infamy.name_id = "bm_global_value_infamous"
	self.global_values.infamy.desc_id = "menu_l_global_value_infamous"
	self.global_values.infamy.color = Color(1, 0.1, 1)
	self.global_values.infamy.dlc = false
	self.global_values.infamy.chance = 0.05
	self.global_values.infamy.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "infamous")
	self.global_values.infamy.durability_multiplier = 3
	self.global_values.infamy.drops = false
	self.global_values.infamy.track = false
	self.global_values.infamy.sort_number = 35
	self.global_values.infamy.hide_unavailable = true
	self.global_values.infamy.category = "infamous"
	self.global_values.preorder = {}
	self.global_values.preorder.name_id = "bm_global_value_preorder"
	self.global_values.preorder.desc_id = "menu_l_global_value_preorder"
	self.global_values.preorder.color = Color(255, 255, 212, 0) / 255
	self.global_values.preorder.dlc = true
	self.global_values.preorder.chance = 1
	self.global_values.preorder.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "preorder")
	self.global_values.preorder.durability_multiplier = 1
	self.global_values.preorder.drops = false
	self.global_values.preorder.track = true
	self.global_values.preorder.sort_number = -10
	self.global_values.preorder.hide_unavailable = true
	self.global_value_list_index = {
		"normal"
	}

	self:_create_global_value_list_map()
end

function LootDropTweakData:_create_global_value_list_map()
	self.global_value_list_map = {}

	for i, d in ipairs(self.global_value_list_index) do
		self.global_value_list_map[d] = i
	end
end

function LootDropTweakData:get_gold_from_rarity(rarity)
	if LootDropTweakData.RARITY_ALL == rarity then
		return 100
	elseif LootDropTweakData.RARITY_DEFAULT == rarity then
		return 100
	elseif LootDropTweakData.RARITY_COMMON == rarity then
		return 150
	elseif LootDropTweakData.RARITY_UNCOMMON == rarity then
		return 200
	elseif LootDropTweakData.RARITY_RARE == rarity then
		return 250
	elseif LootDropTweakData.RARITY_HALLOWEEN_2017 == rarity then
		return 666
	else
		return nil
	end
end

function LootDropTweakData:get_month_event()
	local tdate = os.date("*t")

	return LootDropTweakData.EVENT_MONTHS[tdate.month]
end
