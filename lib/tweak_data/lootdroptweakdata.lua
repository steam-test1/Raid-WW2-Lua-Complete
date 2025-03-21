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
LootDropTweakData.RARITY_HALLOWEEN = "loot_rarity_halloween"
LootDropTweakData.RARITY_LIST = {
	LootDropTweakData.RARITY_ALL,
	LootDropTweakData.RARITY_DEFAULT,
	LootDropTweakData.RARITY_COMMON,
	LootDropTweakData.RARITY_UNCOMMON,
	LootDropTweakData.RARITY_RARE,
	LootDropTweakData.RARITY_NONE,
	LootDropTweakData.RARITY_HALLOWEEN
}
LootDropTweakData.LOOT_VALUE_TYPE_SMALL_AMOUNT = 1
LootDropTweakData.LOOT_VALUE_TYPE_MEDIUM_AMOUNT = 4
LootDropTweakData.LOOT_VALUE_TYPE_BIG_AMOUNT = 5
LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_AMOUNT = 1
LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_BIG_AMOUNT = 3
LootDropTweakData.TOTAL_LOOT_VALUE_DEFAULT = 35
LootDropTweakData.TOTAL_DOGTAGS_DEFAULT = 25
LootDropTweakData.BRONZE_POINT_REQUIREMENT = 0.1
LootDropTweakData.SILVER_POINT_REQUIREMENT = 0.5
LootDropTweakData.GOLD_POINT_REQUIREMENT = 0.8
LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL = "below_max_level"
LootDropTweakData.DROP_CONDITION_IS_RAID = "is_raid"
LootDropTweakData.DROP_CONDITION_IS_OPERATION = "is_operation"
LootDropTweakData.DROP_CONDITION_WANTS_MELEE = "wants_melee"
LootDropTweakData.DROP_CONDITION_WANTS_COSMETIC = "wants_cosmetic"
LootDropTweakData.DROP_CONDITION_CARDS_NOT_REJECTED = "cards_not_rejected"
LootDropTweakData.POINT_REQUIREMENTS = {
	LootDropTweakData.BRONZE_POINT_REQUIREMENT,
	LootDropTweakData.SILVER_POINT_REQUIREMENT,
	LootDropTweakData.GOLD_POINT_REQUIREMENT
}
LootDropTweakData.RARITY_PRICES = {
	[LootDropTweakData.RARITY_ALL] = 100,
	[LootDropTweakData.RARITY_DEFAULT] = 100,
	[LootDropTweakData.RARITY_COMMON] = 150,
	[LootDropTweakData.RARITY_UNCOMMON] = 200,
	[LootDropTweakData.RARITY_RARE] = 250,
	[LootDropTweakData.RARITY_HALLOWEEN] = 666
}

function LootDropTweakData:init(tweak_data)
	self:_payday_init(tweak_data)
	self:_init_rewards_xp_packs()
	self:_init_rewards_card_packs(tweak_data)
	self:_init_rewards_customization()
	self:_init_rewards_gold_bar()
	self:_init_categories()
	self:_init_groups()
	self:_init_loot_values()
	self:_init_dog_tag_stats()
end

function LootDropTweakData:_init_rewards_xp_packs()
	self.rewards_xp_packs = {}
	local multi = 4
	local xp = 200
	local xp2 = xp * multi
	self.rewards_xp_packs.tiny = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	multi = 2
	xp = xp2
	xp2 = xp * multi
	self.rewards_xp_packs.small = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	xp = xp2
	xp2 = xp * multi
	self.rewards_xp_packs.medium = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
	xp = xp2
	xp2 = xp * multi
	self.rewards_xp_packs.large = {
		reward_type = LootDropTweakData.REWARD_XP,
		xp_min = xp,
		xp_max = xp2
	}
end

function LootDropTweakData:_init_rewards_card_packs(tweak_data)
	self.rewards_card_packs = {
		regular = {
			reward_type = LootDropTweakData.REWARD_CARD_PACK,
			pack_type = ChallengeCardsTweakData.PACK_TYPE_REGULAR
		}
	}
end

function LootDropTweakData:_init_rewards_customization()
	self.rewards_customization = {
		common = {
			reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
			rarity = LootDropTweakData.RARITY_COMMON
		},
		uncommon = {
			reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
			rarity = LootDropTweakData.RARITY_UNCOMMON
		},
		rare = {
			reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
			rarity = LootDropTweakData.RARITY_RARE
		},
		halloween = {
			reward_type = LootDropTweakData.REWARD_CUSTOMIZATION,
			rarity = LootDropTweakData.RARITY_HALLOWEEN
		}
	}
end

function LootDropTweakData:_init_rewards_gold_bar()
	self.rewards_gold_bars = {
		tiny_raid = {
			gold_bars_max = 1,
			gold_bars_min = 1,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		small_raid = {
			gold_bars_max = 10,
			gold_bars_min = 2,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		medium_raid = {
			gold_bars_max = 15,
			gold_bars_min = 11,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		large_raid = {
			gold_bars_max = 20,
			gold_bars_min = 16,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		tiny_operation = {
			gold_bars_max = 50,
			gold_bars_min = 25,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		small_operation = {
			gold_bars_max = 75,
			gold_bars_min = 51,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		medium_operation = {
			gold_bars_max = 100,
			gold_bars_min = 76,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		large_operation = {
			gold_bars_max = 200,
			gold_bars_min = 101,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		}
	}
end

function LootDropTweakData:_init_categories()
	self.loot_categories = {
		category_xp_min = {}
	}
	self.loot_categories.category_xp_min[1] = {
		chance = 1,
		value = self.rewards_xp_packs.tiny
	}
	self.loot_categories.category_xp_low = {
		{
			chance = 1,
			value = self.rewards_xp_packs.small
		}
	}
	self.loot_categories.category_xp_mid = {
		{
			chance = 1,
			value = self.rewards_xp_packs.medium
		}
	}
	self.loot_categories.category_xp_high = {
		{
			chance = 1,
			value = self.rewards_xp_packs.large
		}
	}
	self.loot_categories.category_gold_tiny = {
		{
			chance = 1,
			value = self.rewards_gold_bars.tiny_raid
		}
	}
	self.loot_categories.category_gold_low = {
		{
			chance = 1,
			value = self.rewards_gold_bars.small_raid
		}
	}
	self.loot_categories.category_gold_mid = {
		{
			chance = 1,
			value = self.rewards_gold_bars.medium_raid
		}
	}
	self.loot_categories.category_gold_high = {
		{
			chance = 1,
			value = self.rewards_gold_bars.large_raid
		}
	}
	self.loot_categories.category_gold_tiny_operation = {
		{
			chance = 1,
			value = self.rewards_gold_bars.tiny_operation
		}
	}
	self.loot_categories.category_gold_low_operation = {
		{
			chance = 1,
			value = self.rewards_gold_bars.small_operation
		}
	}
	self.loot_categories.category_gold_mid_operation = {
		{
			chance = 1,
			value = self.rewards_gold_bars.medium_operation
		}
	}
	self.loot_categories.category_gold_high_operation = {
		{
			chance = 1,
			value = self.rewards_gold_bars.large_operation
		}
	}
	self.loot_categories.category_melee = {
		{
			chance = 1,
			value = {
				reward_type = LootDropTweakData.REWARD_MELEE_WEAPON
			}
		}
	}
	self.loot_categories.category_cards_pack = {
		{
			chance = 1,
			value = self.rewards_card_packs.regular
		}
	}
	self.loot_categories.category_cosmetics = {
		{
			chance = 3,
			value = self.rewards_customization.common
		},
		{
			chance = 2,
			value = self.rewards_customization.uncommon
		},
		{
			chance = 1,
			value = self.rewards_customization.rare
		}
	}
	self.loot_categories.category_halloween_2017 = {
		{
			chance = 1,
			value = {
				weapon_id = "lc14b",
				reward_type = LootDropTweakData.REWARD_HALLOWEEN_2017
			}
		},
		{
			chance = 4,
			value = self.rewards_customization.halloween
		}
	}
end

function LootDropTweakData:_init_groups()
	self.loot_groups = {}

	self:_init_groups_basic()
	self:_init_groups_bronze()
	self:_init_groups_silver()
	self:_init_groups_gold()
	self:_init_groups_challenges()
end

function LootDropTweakData:_init_groups_basic()
	self.loot_groups.loot_group_basic = {
		{
			chance = 2,
			value = self.loot_categories.category_xp_min,
			conditions = {
				LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_tiny,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_RAID
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_tiny_operation,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_OPERATION
			}
		}
	}
end

function LootDropTweakData:_init_groups_bronze()
	self.loot_groups.loot_group_bronze = {
		{
			chance = 3,
			value = self.loot_categories.category_xp_low,
			conditions = {
				LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
			}
		},
		{
			chance = 3,
			value = self.loot_categories.category_gold_low,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_RAID
			}
		},
		{
			chance = 3,
			value = self.loot_categories.category_gold_low_operation,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_OPERATION
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				LootDropTweakData.DROP_CONDITION_CARDS_NOT_REJECTED
			}
		}
	}
end

function LootDropTweakData:_init_groups_silver()
	self.loot_groups.loot_group_silver = {
		{
			chance = 2,
			value = self.loot_categories.category_xp_mid,
			conditions = {
				LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_gold_mid,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_RAID
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_gold_mid_operation,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_OPERATION
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				LootDropTweakData.DROP_CONDITION_CARDS_NOT_REJECTED
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				LootDropTweakData.DROP_CONDITION_WANTS_MELEE
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				LootDropTweakData.DROP_CONDITION_WANTS_COSMETIC
			}
		}
	}
end

function LootDropTweakData:_init_groups_gold()
	self.loot_groups.loot_group_gold = {
		{
			chance = 1,
			value = self.loot_categories.category_xp_high,
			conditions = {
				LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_high,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_RAID
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_high_operation,
			conditions = {
				LootDropTweakData.DROP_CONDITION_IS_OPERATION
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				LootDropTweakData.DROP_CONDITION_CARDS_NOT_REJECTED
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				LootDropTweakData.DROP_CONDITION_WANTS_MELEE
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				LootDropTweakData.DROP_CONDITION_WANTS_COSMETIC
			}
		}
	}
end

function LootDropTweakData:_init_groups_challenges()
	self.loot_groups.loot_group_halloween_2017 = {
		{
			chance = 100,
			value = self.loot_categories.category_halloween_2017
		},
		challenge_reward = true
	}
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
end

function LootDropTweakData:_init_dog_tag_stats()
	self.dog_tag = {
		loot_value = 125
	}
end

function LootDropTweakData:_payday_init(tweak_data)
	self.PC_STEP = 10
	self.no_drop = {
		BASE = 35,
		HUMAN_STEP_MODIFIER = 10
	}
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
	self.PC_CHANCE = {
		0.7,
		0.7,
		0.7,
		0.7,
		0.9,
		0.91,
		0.92,
		0.93,
		0.94,
		0.95
	}
	self.STARS = {
		{
			pcs = {
				10,
				10
			}
		},
		{
			pcs = {
				20,
				20
			}
		},
		{
			pcs = {
				30,
				30
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
		},
		{
			pcs = {
				40,
				40
			}
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
	self.type_weight_mod_funcs = {
		weapon_mods = function (global_value, category, id)
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
	}
	self.global_value_category = {
		normal = {}
	}
	self.global_value_category.normal.name_id = "bm_global_value_normal"
	self.global_value_category.normal.sort_number = 0
	self.global_value_category.dlc = {
		name_id = "bm_menu_dlc",
		sort_number = 10
	}
	self.global_value_category.global_event = {
		name_id = "bm_menu_global_event",
		sort_number = 20
	}
	self.global_value_category.infamous = {
		name_id = "bm_global_value_infamous",
		sort_number = 30
	}
	self.global_value_category.collaboration = {
		name_id = "bm_global_value_collaboration",
		sort_number = 25
	}
	self.global_values = {
		normal = {}
	}
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
	self.global_values.superior = {
		name_id = "bm_global_value_superior",
		desc_id = "menu_l_global_value_superior",
		color = Color.blue,
		dlc = false,
		chance = 0.1,
		value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "superior"),
		durability_multiplier = 1.5,
		drops = false,
		track = false,
		sort_number = 25,
		category = nil
	}
	self.global_values.exceptional = {
		name_id = "bm_global_value_exceptional",
		desc_id = "menu_l_global_value_exceptional",
		color = Color.yellow,
		dlc = false,
		chance = 0.05,
		value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "exceptional"),
		durability_multiplier = 2.25,
		drops = false,
		track = false,
		sort_number = 26,
		category = nil
	}
	self.global_values.infamous = {
		name_id = "bm_global_value_infamous",
		desc_id = "menu_l_global_value_infamous",
		color = Color(1, 0.1, 1),
		dlc = false,
		chance = 0.05,
		value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "infamous"),
		durability_multiplier = 3,
		drops = true,
		track = false,
		sort_number = 30,
		category = "infamous"
	}
	self.global_values.infamy = {
		name_id = "bm_global_value_infamous",
		desc_id = "menu_l_global_value_infamous",
		color = Color(1, 0.1, 1),
		dlc = false,
		chance = 0.05,
		value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "infamous"),
		durability_multiplier = 3,
		drops = false,
		track = false,
		sort_number = 35,
		hide_unavailable = true,
		category = "infamous"
	}
	self.global_values.preorder = {
		name_id = "bm_global_value_preorder",
		desc_id = "menu_l_global_value_preorder",
		color = Color(255, 255, 212, 0) / 255,
		dlc = true,
		chance = 1,
		value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "preorder"),
		durability_multiplier = 1,
		drops = false,
		track = true,
		sort_number = -10,
		hide_unavailable = true
	}
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
	return self.RARITY_PRICES[rarity]
end
