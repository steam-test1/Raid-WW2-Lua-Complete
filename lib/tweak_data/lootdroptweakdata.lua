LootDropTweakData = LootDropTweakData or class()
LootDropTweakData.LOOT_GROUP_PREFIX = "loot_group_"
LootDropTweakData.REWARD_XP = "xp"
LootDropTweakData.REWARD_CARD_PACK = "card_pack"
LootDropTweakData.REWARD_CUSTOMIZATION = "customization"
LootDropTweakData.REWARD_WEAPON_POINT = "weapon_point"
LootDropTweakData.REWARD_WEAPON_SKIN = "weapon_skin"
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
	self:_init_rewards_xp_packs()
	self:_init_rewards_card_packs()
	self:_init_rewards_melee()
	self:_init_rewards_customization()
	self:_init_rewards_weapon_skin()
	self:_init_rewards_gold_bar()
	self:_init_categories()
	self:_init_groups()
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

function LootDropTweakData:_init_rewards_card_packs()
	self.rewards_card_packs = {
		regular = {
			reward_type = LootDropTweakData.REWARD_CARD_PACK,
			pack_type = ChallengeCardsTweakData.PACK_TYPE_REGULAR
		}
	}
end

function LootDropTweakData:_init_rewards_melee()
	self.rewards_melee = {
		reward_type = LootDropTweakData.REWARD_MELEE_WEAPON
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

function LootDropTweakData:_init_rewards_weapon_skin()
	self.rewards_weapon_skin = {
		common = {
			reward_type = LootDropTweakData.REWARD_WEAPON_SKIN,
			rarity = LootDropTweakData.RARITY_COMMON
		},
		uncommon = {
			reward_type = LootDropTweakData.REWARD_WEAPON_SKIN,
			rarity = LootDropTweakData.RARITY_UNCOMMON
		},
		rare = {
			reward_type = LootDropTweakData.REWARD_WEAPON_SKIN,
			rarity = LootDropTweakData.RARITY_RARE
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
		},
		bounty_common = {
			gold_bars_max = 15,
			gold_bars_min = 15,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		bounty_uncommon = {
			gold_bars_max = 30,
			gold_bars_min = 30,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		},
		bounty_rare = {
			gold_bars_max = 50,
			gold_bars_min = 50,
			reward_type = LootDropTweakData.REWARD_GOLD_BARS
		}
	}
end

function LootDropTweakData:_init_categories()
	self.loot_categories = {
		category_xp_min = {
			{
				chance = 1,
				value = self.rewards_xp_packs.tiny
			}
		},
		category_xp_low = {
			{
				chance = 1,
				value = self.rewards_xp_packs.small
			}
		},
		category_xp_mid = {
			{
				chance = 1,
				value = self.rewards_xp_packs.medium
			}
		},
		category_xp_high = {
			{
				chance = 1,
				value = self.rewards_xp_packs.large
			}
		},
		category_gold_tiny = {
			{
				chance = 1,
				value = self.rewards_gold_bars.tiny_raid
			}
		},
		category_gold_low = {
			{
				chance = 1,
				value = self.rewards_gold_bars.small_raid
			}
		},
		category_gold_mid = {
			{
				chance = 1,
				value = self.rewards_gold_bars.medium_raid
			}
		},
		category_gold_high = {
			{
				chance = 1,
				value = self.rewards_gold_bars.large_raid
			}
		},
		category_gold_tiny_operation = {
			{
				chance = 1,
				value = self.rewards_gold_bars.tiny_operation
			}
		},
		category_gold_low_operation = {
			{
				chance = 1,
				value = self.rewards_gold_bars.small_operation
			}
		},
		category_gold_mid_operation = {
			{
				chance = 1,
				value = self.rewards_gold_bars.medium_operation
			}
		},
		category_gold_high_operation = {
			{
				chance = 1,
				value = self.rewards_gold_bars.large_operation
			}
		},
		category_gold_bounty_common = {
			{
				chance = 1,
				value = self.rewards_gold_bars.bounty_common
			}
		},
		category_gold_bounty_uncommon = {
			{
				chance = 1,
				value = self.rewards_gold_bars.bounty_uncommon
			}
		},
		category_gold_bounty_rare = {
			{
				chance = 1,
				value = self.rewards_gold_bars.bounty_rare
			}
		},
		category_melee = {
			{
				chance = 1,
				value = self.rewards_melee
			}
		},
		category_cards_pack = {
			{
				chance = 1,
				value = self.rewards_card_packs.regular
			}
		},
		category_cosmetics = {
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
		},
		category_skins = {
			{
				chance = 5,
				value = self.rewards_weapon_skin.common
			},
			{
				chance = 3,
				value = self.rewards_weapon_skin.uncommon
			},
			{
				chance = 1,
				value = self.rewards_weapon_skin.rare
			}
		},
		category_halloween_2017 = {
			{
				chance = 1,
				value = {
					weapon_id = "lc14b",
					reward_type = LootDropTweakData.REWARD_HALLOWEEN_2017
				}
			}
		},
		category_halloween_customization = {
			{
				chance = 4,
				value = self.rewards_customization.halloween
			}
		}
	}
end

function LootDropTweakData:_init_groups()
	self.loot_groups = {}

	self:_init_conditions()
	self:_init_groups_basic()
	self:_init_groups_bronze()
	self:_init_groups_silver()
	self:_init_groups_gold()
	self:_init_groups_challenges()
end

function LootDropTweakData:_init_conditions()
	self.conditions = {
		below_max_level = function ()
			return not managers.experience:reached_level_cap()
		end,
		is_raid = function ()
			if game_state_machine:current_state_name() == "event_complete_screen" then
				local current_job = game_state_machine:current_state():job_data()

				return current_job.job_type == OperationsTweakData.JOB_TYPE_RAID
			end

			return true
		end,
		is_operation = function ()
			if game_state_machine:current_state_name() == "event_complete_screen" then
				local current_job = game_state_machine:current_state():job_data()

				return current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION
			end

			return false
		end,
		wants_cosmetic = function (group_data)
			return not managers.character_customization:is_customization_collection_complete(group_data.value.rarity)
		end,
		wants_weapon_skin = function (group_data)
			return not managers.weapon_inventory:is_drop_inventory_complete_skins(group_data.value.rarity)
		end,
		wants_melee_group = function ()
			return not managers.weapon_inventory:is_drop_inventory_complete_melee()
		end,
		wants_melee_weapon = function (group_data)
			return not managers.weapon_inventory:is_melee_weapon_owned(group_data.value.weapon_id)
		end,
		wants_card = function ()
			return not managers.raid_menu:is_offline_mode() and not managers.lootdrop:cards_already_rejected()
		end
	}
end

function LootDropTweakData:_init_groups_basic()
	self.loot_groups.loot_group_basic = {
		{
			chance = 1,
			value = self.loot_categories.category_xp_min,
			conditions = {
				self.conditions.below_max_level
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_tiny,
			conditions = {
				self.conditions.is_raid
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_tiny_operation,
			conditions = {
				self.conditions.is_operation
			}
		},
		min_loot_value = -1000000,
		max_loot_value = self.BRONZE_POINT_REQUIREMENT
	}
end

function LootDropTweakData:_init_groups_bronze()
	self.loot_groups.loot_group_bronze = {
		{
			chance = 2,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_xp_low,
			conditions = {
				self.conditions.below_max_level
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_low,
			conditions = {
				self.conditions.is_raid
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_gold_low_operation,
			conditions = {
				self.conditions.is_operation
			}
		},
		min_loot_value = LootDropTweakData.BRONZE_POINT_REQUIREMENT,
		max_loot_value = LootDropTweakData.SILVER_POINT_REQUIREMENT
	}
end

function LootDropTweakData:_init_groups_silver()
	self.loot_groups.loot_group_silver = {
		{
			chance = 3,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_xp_mid,
			conditions = {
				self.conditions.below_max_level
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_gold_mid,
			conditions = {
				self.conditions.is_raid
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_gold_mid_operation,
			conditions = {
				self.conditions.is_operation
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				self.conditions.wants_melee_group
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				self.conditions.wants_cosmetic
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_skins,
			conditions = {
				self.conditions.wants_weapon_skin
			}
		},
		min_loot_value = LootDropTweakData.SILVER_POINT_REQUIREMENT,
		max_loot_value = LootDropTweakData.GOLD_POINT_REQUIREMENT
	}
end

function LootDropTweakData:_init_groups_gold()
	self.loot_groups.loot_group_gold = {
		{
			chance = 5,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		{
			chance = 3,
			value = self.loot_categories.category_gold_high,
			conditions = {
				self.conditions.is_raid
			}
		},
		{
			chance = 3,
			value = self.loot_categories.category_gold_high_operation,
			conditions = {
				self.conditions.is_operation
			}
		},
		{
			chance = 2,
			value = self.loot_categories.category_xp_high,
			conditions = {
				self.conditions.below_max_level
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				self.conditions.wants_melee_group
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				self.conditions.wants_cosmetic
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_skins,
			conditions = {
				self.conditions.wants_weapon_skin
			}
		},
		max_loot_value = 1000000,
		min_loot_value = LootDropTweakData.GOLD_POINT_REQUIREMENT
	}
end

function LootDropTweakData:_init_groups_challenges()
	self.loot_groups.loot_group_halloween_2017 = {
		{
			chance = 1,
			value = self.loot_categories.category_halloween_2017,
			conditions = {
				self.conditions.wants_melee_weapon
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_halloween_customization,
			conditions = {
				self.conditions.wants_cosmetic
			}
		},
		{
			chance = 0,
			value = self.loot_categories.category_gold_bounty_uncommon
		},
		challenge_reward = true
	}
	self.loot_groups.loot_group_bounty_common = {
		{
			chance = 10,
			value = self.loot_categories.category_gold_bounty_common
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		challenge_reward = true
	}
	self.loot_groups.loot_group_bounty_uncommon = {
		{
			chance = 10,
			value = self.loot_categories.category_gold_bounty_uncommon
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				self.conditions.wants_melee_group
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				self.conditions.wants_cosmetic
			}
		},
		challenge_reward = true
	}
	self.loot_groups.loot_group_bounty_rare = {
		{
			chance = 5,
			value = self.loot_categories.category_gold_bounty_rare
		},
		{
			chance = 1,
			value = self.loot_categories.category_cards_pack,
			conditions = {
				self.conditions.wants_card
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_melee,
			conditions = {
				self.conditions.wants_melee_group
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_cosmetics,
			conditions = {
				self.conditions.wants_cosmetic
			}
		},
		{
			chance = 1,
			value = self.loot_categories.category_skins,
			conditions = {
				self.conditions.wants_weapon_skin
			}
		},
		challenge_reward = true
	}
end

function LootDropTweakData:_init_dog_tag_stats()
	self.dog_tag = {
		loot_value = 125
	}
end

function LootDropTweakData.get_gold_from_rarity(rarity)
	return LootDropTweakData.RARITY_PRICES[rarity]
end
