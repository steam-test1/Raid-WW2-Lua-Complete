require("lib/managers/BuffEffectManager")
require("lib/tweak_data/WeaponTweakData")

ChallengeCardsTweakData = ChallengeCardsTweakData or class()
ChallengeCardsTweakData.CARD_TYPE_RAID = "card_type_raid"
ChallengeCardsTweakData.CARD_TYPE_OPERATION = "card_type_operation"
ChallengeCardsTweakData.CARD_TYPE_NONE = "card_type_none"
ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD = "card_category_challenge_card"
ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER = "card_category_booster"
ChallengeCardsTweakData.KEY_NAME_FIELD = "key_name"
ChallengeCardsTweakData.FILTER_ALL_ITEMS = "filter_all_items"
ChallengeCardsTweakData.CARDS_TEXTURE_PATH = "ui/atlas/raid_atlas_cards"
ChallengeCardsTweakData.TEXTURE_RECT_PATH_COMMON_THUMB = ""
ChallengeCardsTweakData.TEXTURE_RECT_PATH_UNCOMMON_THUMB = ""
ChallengeCardsTweakData.TEXTURE_RECT_PATH_RARE_THUMB = ""
ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE = "positive_effect"
ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE = "negative_effect"
ChallengeCardsTweakData.CARD_SELECTION_TIMER = 60
ChallengeCardsTweakData.PACK_TYPE_REGULAR = 1
ChallengeCardsTweakData.STACKABLE_AREA = {
	width = 500,
	height = 680
}

function ChallengeCardsTweakData:init(tweak_data)
	local function setup_card(id)
		local card = {
			name = "card_" .. id .. "_name_id",
			description = "card_" .. id .. "_desc_id"
		}
		local gui_id = "cc_" .. id .. "_hud"

		if tweak_data.gui[gui_id] then
			card.texture = gui_id
		else
			Application:error("[ChallengeCardsTweakData] card " .. id .. " was generated without a valid texture, using temporary texture.")

			card.texture = "cc_debug_card_hud"
		end

		return card
	end

	self.challenge_card_texture_path = "ui/challenge_cards/"
	self.challenge_card_texture_rect = {
		0,
		0,
		512,
		512
	}
	self.card_back_challenge_cards = {
		texture = self.challenge_card_texture_path .. "cc_back_hud",
		texture_rect = self.challenge_card_texture_rect
	}
	self.card_back_boosters = {
		texture = self.challenge_card_texture_path .. "cc_back_booster_hud",
		texture_rect = self.challenge_card_texture_rect
	}
	self.card_back_halloween_2017 = {
		texture = self.challenge_card_texture_path .. "cc_back_halloween_hud",
		texture_rect = self.challenge_card_texture_rect
	}
	self.challenge_card_stackable_2_texture_path = "ui/challenge_cards/cc_stackable_2_cards_hud"
	self.challenge_card_stackable_2_texture_rect = {
		0,
		0,
		512,
		512
	}
	self.challenge_card_stackable_3_texture_path = "ui/challenge_cards/cc_stackable_3_cards_hud"
	self.challenge_card_stackable_3_texture_rect = {
		0,
		0,
		512,
		512
	}
	self.challenge_card_stackable_booster_2_texture_path = "ui/challenge_cards/cc_stackable_booster_2_cards_hud"
	self.challenge_card_stackable_booster_2_texture_rect = {
		0,
		0,
		512,
		512
	}
	self.challenge_card_stackable_booster_3_texture_path = "ui/challenge_cards/cc_stackable_booster_3_cards_hud"
	self.challenge_card_stackable_booster_3_texture_rect = {
		0,
		0,
		512,
		512
	}
	self.not_selected_cardback = {
		texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH,
		texture_rect = {
			501,
			2,
			497,
			670
		}
	}
	self.rarity_definition = {
		loot_rarity_common = {}
	}
	self.rarity_definition.loot_rarity_common.texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH
	self.rarity_definition.loot_rarity_common.texture_rect = {
		2,
		2,
		497,
		670
	}
	self.rarity_definition.loot_rarity_common.texture_path_icon = tweak_data.gui.icons.loot_rarity_common.texture
	self.rarity_definition.loot_rarity_common.texture_rect_icon = tweak_data.gui.icons.loot_rarity_common.texture_rect
	self.rarity_definition.loot_rarity_common.color = Color("ececec")
	self.rarity_definition.loot_rarity_uncommon = {
		texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH,
		texture_rect = {
			2,
			1346,
			497,
			670
		},
		texture_path_icon = tweak_data.gui.icons.loot_rarity_uncommon.texture,
		texture_rect_icon = tweak_data.gui.icons.loot_rarity_uncommon.texture_rect,
		color = Color("71b35b")
	}
	self.rarity_definition.loot_rarity_rare = {
		texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH,
		texture_rect = {
			501,
			674,
			497,
			670
		},
		texture_path_icon = tweak_data.gui.icons.loot_rarity_rare.texture,
		texture_rect_icon = tweak_data.gui.icons.loot_rarity_rare.texture_rect,
		color = Color("718c9e")
	}
	self.rarity_definition.loot_rarity_halloween = {
		texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH,
		texture_rect = {
			501,
			674,
			497,
			670
		},
		texture_path_icon = tweak_data.gui.icons.loot_rarity_halloween.texture,
		texture_rect_icon = tweak_data.gui.icons.loot_rarity_halloween.texture_rect,
		color = Color("d88023")
	}
	self.rarity_definition.loot_rarity_none = {
		texture_path = ChallengeCardsTweakData.CARDS_TEXTURE_PATH,
		texture_rect = {
			2,
			674,
			497,
			670
		},
		texture_path_icon = nil,
		texture_rect_icon = nil,
		color = nil
	}
	self.type_definition = {
		card_type_raid = {}
	}
	self.type_definition.card_type_raid.texture_path = tweak_data.gui.icons.ico_raid.texture
	self.type_definition.card_type_raid.texture_rect = tweak_data.gui.icons.ico_raid.texture_rect
	self.type_definition.card_type_operation = {
		texture_path = tweak_data.gui.icons.ico_operation.texture,
		texture_rect = tweak_data.gui.icons.ico_operation.texture_rect
	}
	self.type_definition.card_type_none = {
		texture_path = "ui/main_menu/textures/cards_atlas",
		texture_rect = {
			310,
			664,
			144,
			209
		}
	}
	self.card_glow = {
		texture = "ui/main_menu/textures/cards_atlas",
		texture_rect = {
			305,
			662,
			159,
			222
		}
	}
	self.card_amount_background = {
		texture = tweak_data.gui.icons.card_counter_bg.texture,
		texture_rect = tweak_data.gui.icons.card_counter_bg.texture_rect
	}
	self.steam_inventory = {
		gameplay = {}
	}
	self.steam_inventory.gameplay.def_id = 1
	self.cards = {
		empty = {}
	}
	self.cards.empty.name = "PASS"
	self.cards.empty.description = "PASS"
	self.cards.empty.effects = {}
	self.cards.empty.rarity = LootDropTweakData.RARITY_NONE
	self.cards.empty.card_type = ChallengeCardsTweakData.CARD_TYPE_NONE
	self.cards.empty.texture = ""
	self.cards.empty.achievement_id = ""
	self.cards.empty.bonus_xp = nil
	self.cards.empty.steam_skip = true
	self.cards.ra_on_the_scrounge = {
		name = "card_ra_on_the_scrounge_name_id",
		description = "card_ra_on_the_scrounge_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE
			},
			{
				value = 0.8,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_effect_increased",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_player_primary_and_secondary_ammo_capacity_lowered",
			desc_params = {
				EFFECT_VALUE_1 = "20%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_common_on_the_scrounge_hud",
		achievement_id = "",
		bonus_xp = 300,
		def_id = 20001,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_no_backups = {
		name = "card_ra_no_backups_name_id",
		description = "card_ra_no_backups_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_RELOAD_SPEED
			},
			{
				value = 0,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_SECONDARY_AMMO_CAPACITY
			}
		},
		positive_description = {
			desc_id = "effect_player_faster_reload",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_player_no_secondary_ammo"
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_common_no_backups_hud",
		achievement_id = "",
		bonus_xp = 250,
		def_id = 20002,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_this_is_gonna_hurt = {
		name = "card_ra_this_is_gonna_hurt_name_id",
		description = "card_ra_this_is_gonna_hurt_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_RECEIVE_DAMAGE
			},
			{
				value = 15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER
			}
		},
		positive_description = {
			desc_id = "effect_enemies_take_more_damage",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_set_bleedout_timer",
			desc_params = {
				EFFECT_VALUE_1 = "15"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_common_this_is_gonna_hurt_hud",
		achievement_id = "",
		bonus_xp = 230,
		def_id = 20003,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_not_in_the_face = {
		name = "card_ra_not_in_the_face_name_id",
		description = "card_ra_not_in_the_face_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DOESNT_DO_DAMAGE
			}
		},
		positive_description = {
			desc_id = "effect_critical_hit_chance_increase",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_headshot_doesnt_do_damage"
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_common_not_in_the_face_hud",
		achievement_id = "",
		bonus_xp = 250,
		def_id = 20004,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_loaded_for_bear = {
		name = "card_ra_loaded_for_bear_name_id",
		description = "card_ra_loaded_for_bear_desc_id",
		effects = {
			{
				value = 1.2,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY
			},
			{
				value = 0.85,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED
			}
		},
		positive_description = {
			desc_id = "effect_player_primary_and_secondary_ammo_capacity_increased",
			desc_params = {
				EFFECT_VALUE_1 = "20%"
			}
		},
		negative_description = {
			desc_id = "effect_player_movement_speed_reduced",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_common_loaded_for_bear_hud",
		achievement_id = "",
		bonus_xp = 250,
		def_id = 20005,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_total_carnage = {
		name = "card_ra_total_carnage_name_id",
		description = "card_ra_total_carnage_desc_id",
		effects = {
			{
				value = 1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_AMMO_PICKUPS_REFIL_GRENADES
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_VULNERABLE_ONLY_TO_EXPLOSION
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_VULNERABLE_ONLY_TO_MELEE
			}
		},
		positive_description = {
			desc_id = "effect_ammo_pickups_refill_grenades"
		},
		negative_description = {
			desc_id = "effect_enemies_vulnerable_only_to_explosion_and_melee"
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_uncommon_total_carnage_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.4,
		def_id = 20006,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_switch_hitter = {
		name = "card_ra_switch_hitter_name_id",
		description = "card_ra_switch_hitter_desc_id",
		effects = {
			{
				value = 1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_SHOOTING_SECONDARY_WEAPON_FILLS_PRIMARY_AMMO
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_SHOOTING_PRIMARY_WEAPON_CONSUMES_BOTH_AMMOS
			}
		},
		positive_description = {
			desc_id = "effect_shooting_secondary_weapon_fills_primary_ammo"
		},
		negative_description = {
			desc_id = "effect_shooting_your_primary_weapon_consumes_both_ammos"
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_uncommon_switch_hitter_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.45,
		def_id = 20007,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_gunslingers = {
		name = "card_ra_gunslingers_name_id",
		description = "card_ra_gunslingers_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_PISTOL_DAMAGE
			},
			{
				value = 0,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_PRIMARY_AMMO_CAPACITY
			}
		},
		positive_description = {
			desc_id = "effect_pistol_damage_increased",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_player_no_primary_ammo"
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_uncommon_gunslingers_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.45,
		def_id = 20008,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_fresh_troops = {
		name = "card_ra_fresh_troops_name_id",
		description = "card_ra_fresh_troops_desc_id",
		effects = {
			{
				value = 1.25,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE
			},
			{
				value = 1.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_chance_increased",
			desc_params = {
				EFFECT_VALUE_1 = "25%"
			}
		},
		negative_description = {
			desc_id = "effect_enemies_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_uncommon_fresh_troops_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.45,
		def_id = 20009,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_dont_you_die_on_me = {
		name = "card_ra_dont_you_die_on_me_name_id",
		description = "card_ra_dont_you_die_on_me_desc_id",
		effects = {
			{
				value = 10,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_DIED,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_DIED
			}
		},
		positive_description = {
			desc_id = "effect_bleedout_timer_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10"
			}
		},
		negative_description = {
			desc_id = "effect_players_cannot_die_during_raid"
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_uncommon_dont_you_die_on_me_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.5,
		def_id = 20010,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_no_second_chances = {
		name = "card_ra_no_second_chances_name_id",
		description = "card_ra_no_second_chances_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_BLEEDOUT,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_WENT_TO_BLEEDOUT
			}
		},
		positive_description = {
			desc_id = "effect_player_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10"
			}
		},
		negative_description = {
			desc_id = "effect_players_cannot_bleedout_during_raid"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_rare_no_second_chances_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.75,
		def_id = 20011,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_a_perfect_score = {
		name = "card_ra_a_perfect_score_name_id",
		description = "card_ra_a_perfect_score_desc_id",
		effects = {
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ALL_CHESTS_ARE_LOCKED
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_FAILED_INTERACTION_MINI_GAME
			}
		},
		positive_description = {
			desc_id = "effect_all_chests_are_locked"
		},
		negative_description = {
			desc_id = "effect_players_cant_fail_minigame"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_rare_a_perfect_score_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2,
		def_id = 20012,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_helmet_shortage = {
		name = "card_ra_helmet_shortage_name_id",
		description = "card_ra_helmet_shortage_desc_id",
		effects = {
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_AUTO_KILL
			},
			{
				value = 0.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_headshots_are_instakills"
		},
		negative_description = {
			desc_id = "effect_player_health_reduced",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_rare_helmet_shortage_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2,
		def_id = 20013,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_hemorrhaging = {
		name = "card_ra_hemorrhaging_name_id",
		description = "card_ra_hemorrhaging_desc_id",
		effects = {
			{
				value = 0.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_MELEE_KILL_REGENERATES_HEALTH
			},
			{
				value = -0.00333,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN
			}
		},
		positive_description = {
			desc_id = "effect_melee_kills_regenerate_health",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_health_drain_per_minute",
			desc_params = {
				EFFECT_VALUE_1 = "20%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_rare_hemorrhaging_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.15,
		def_id = 20014,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_crab_people = {
		name = "card_ra_crab_people_name_id",
		description = "card_ra_crab_people_desc_id",
		effects = {
			{
				value = 1.3,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_CAN_MOVE_ONLY_BACK_AND_SIDE
			}
		},
		positive_description = {
			desc_id = "effect_player_movement_speed_increased"
		},
		negative_description = {
			desc_id = "effect_player_can_only_walk_backwards_or_sideways"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_raid_rare_crab_people_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.3,
		def_id = 20015,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_slasher_movie = {
		name = "card_ra_slasher_movie_name_id",
		description = "card_ra_slasher_movie_desc_id",
		effects = {
			{
				value = 0.01666,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN
			},
			{
				value = 20,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_MELEE_DAMAGE_INCREASE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_WARCRIES_DISABLED
			}
		},
		positive_description = {
			desc_id = "effect_melee_damage_increased_health_regen",
			desc_params = {
				EFFECT_VALUE_1 = "100%"
			}
		},
		negative_description = {
			desc_id = "effect_melee_avail_warcries_disabled"
		},
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_special_raid_slasher_movie_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.5,
		def_id = 20016,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD,
		card_back = "card_back_halloween_2017",
		title_in_texture = true,
		loot_drop_group = LootDropTweakData.REWARD_HALLOWEEN_2017,
		selected_sound = "halloween_challenge_card_chosen"
	}
	self.cards.ra_pumpkin_pie = {
		name = "card_ra_pumpkin_pie_name_id",
		description = "card_ra_pumpkin_pie_desc_id",
		effects = {
			{
				value = 3,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DAMAGE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR
			}
		},
		positive_description = {
			desc_id = "effect_headshots_damage_increased",
			desc_params = {
				EFFECT_VALUE_1 = "100%"
			}
		},
		negative_description = {
			desc_id = "effect_only_attack_in_air"
		},
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_special_raid_pumpkin_pie_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.3,
		def_id = 20017,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD,
		card_back = "card_back_halloween_2017",
		title_in_texture = true,
		loot_drop_group = LootDropTweakData.REWARD_HALLOWEEN_2017,
		selected_sound = "halloween_challenge_card_chosen"
	}
	self.cards.ra_season_of_resurrection = {
		name = "card_ra_season_of_resurrection_name_id",
		description = "card_ra_season_of_resurrection_desc_id",
		effects = {
			{
				value = 4,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_LOW_HEALTH_DAMAGE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_NO_BLEEDOUT_PUMPIKIN_REVIVE
			}
		},
		positive_description = {
			desc_id = "effect_player_low_health_damage"
		},
		negative_description = {
			desc_id = "effect_no_bleedout_pumpkin_revive"
		},
		rarity = LootDropTweakData.RARITY_HALLOWEEN_2017,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_special_raid_season_of_resurrection_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.5,
		def_id = 20018,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD,
		card_back = "card_back_halloween_2017",
		title_in_texture = true,
		loot_drop_group = LootDropTweakData.REWARD_HALLOWEEN_2017,
		selected_sound = "halloween_challenge_card_chosen"
	}
	self.cards.op_limited_supplies = {
		name = "card_op_limited_supplies_name_id",
		description = "card_op_limited_supplies_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE
			},
			{
				value = 0.8,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_effect_increased",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_player_primary_and_secondary_ammo_capacity_lowered",
			desc_params = {
				EFFECT_VALUE_1 = "20%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_common_limited_supplies_hud",
		achievement_id = "",
		bonus_xp = 300,
		def_id = 30001,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_take_the_cannoli = {
		name = "card_op_take_the_cannoli_name_id",
		description = "card_op_take_the_cannoli_desc_id",
		effects = {
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN
			},
			{
				value = 0.85,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE
			}
		},
		positive_description = {
			desc_id = "effect_no_movement_penalty_for_carrying_heavy_objects"
		},
		negative_description = {
			desc_id = "effect_loot_drop_chance_decreased",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_common_take_the_canonoli_hud",
		achievement_id = "",
		bonus_xp = 350,
		def_id = 30002,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_everyones_a_tough_guy = {
		name = "card_op_everyones_a_tough_guy_name_id",
		description = "card_op_everyones_a_tough_guy_desc_id",
		effects = {
			{
				value = 5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER
			},
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_bleedout_timer_increased",
			desc_params = {
				EFFECT_VALUE_1 = "5"
			}
		},
		negative_description = {
			desc_id = "effect_enemies_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_common_everyones_a_tough_guy_hud",
		achievement_id = "",
		bonus_xp = 500,
		def_id = 30003,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_nichtsplosions = {
		name = "card_op_nichtsplosions_name_id",
		description = "card_op_nichtsplosions_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_RELOAD_SPEED
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_IMPERVIOUS_TO_EXPLOSIVE_DAMAGE
			}
		},
		positive_description = {
			desc_id = "effect_player_faster_reload",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		negative_description = {
			desc_id = "effect_enemies_impervious_to_explosive_damage"
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_common_nichtsplosions_hud",
		achievement_id = "",
		bonus_xp = 400,
		def_id = 30004,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_war_weary = {
		name = "card_op_war_weary_name_id",
		description = "card_op_war_weary_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_RECEIVE_DAMAGE
			},
			{
				value = 0.75,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE
			}
		},
		positive_description = {
			desc_id = "effect_enemies_take_more_damage",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_loot_drop_effect_decreased",
			desc_params = {
				EFFECT_VALUE_1 = "25%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_common_war_weary_hud",
		achievement_id = "",
		bonus_xp = 400,
		def_id = 30005,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_special_for_a_reason = {
		name = "card_op_special_for_a_reason_name_id",
		description = "card_op_special_for_a_reason_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED
			},
			{
				value = 1.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE
			}
		},
		positive_description = {
			desc_id = "effect_player_movement_speed_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_special_enemies_deal_increased_damage",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_uncommon_special_for_a_reason_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.25,
		def_id = 30006,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_dont_blink = {
		name = "card_op_dont_blink_name_id",
		description = "card_op_dont_blink_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE
			},
			{
				value = 5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_HEALTH
			},
			{
				value = 5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_AMMO
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_chance_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_loot_drop_pickups_desappear",
			desc_params = {
				EFFECT_VALUE_1 = "5"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_uncommon_dont_blink_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.35,
		def_id = 30007,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_bad_coffee = {
		name = "card_op_bad_coffee_name_id",
		description = "card_op_bad_coffee_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_RELOAD_SPEED
			},
			{
				value = 15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER
			}
		},
		positive_description = {
			desc_id = "effect_player_faster_reload",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_set_bleedout_timer",
			desc_params = {
				EFFECT_VALUE_1 = "15"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_uncommon_bad_coffee_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.4,
		def_id = 30008,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_playing_for_keeps = {
		name = "card_op_playing_for_keeps_name_id",
		description = "card_op_playing_for_keeps_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_RECEIVE_DAMAGE
			},
			{
				value = 0.75,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_enemies_take_more_damage",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_player_health_reduced",
			desc_params = {
				EFFECT_VALUE_1 = "25"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_uncommon_playing_for_keeps_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.4,
		def_id = 30009,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_silent_shout = {
		name = "card_op_silent_shout_name_id",
		description = "card_op_silent_shout_desc_id",
		effects = {
			{
				value = 0.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_MELEE_KILL_REGENERATES_HEALTH
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_USED_WARCRY
			}
		},
		positive_description = {
			desc_id = "effect_melee_kills_regenerate_health",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		negative_description = {
			desc_id = "effect_players_cant_use_warcry"
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_uncommon_silent_shout_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.55,
		def_id = 30010,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_blow_me = {
		name = "card_op_blow_me_name_id",
		description = "card_op_blow_me_desc_id",
		effects = {
			{
				value = 2,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_GRENADE_DAMAGE
			},
			{
				value = 0.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY
			}
		},
		positive_description = {
			desc_id = "effect_player_grenade_damage_increased",
			desc_params = {
				EFFECT_VALUE_1 = "100%"
			}
		},
		negative_description = {
			desc_id = "effect_player_primary_and_secondary_ammo_capacity_lowered",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_rare_blow_me_hud",
		achievement_id = "",
		bonus_xp_multiplier = 1.75,
		def_id = 30011,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_you_only_live_once = {
		name = "card_op_you_only_live_once_name_id",
		description = "card_op_you_only_live_once_desc_id",
		effects = {
			{
				value = 0.05,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_KILL_REGENERATES_HEALTH
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYER_DIED,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_DIED
			}
		},
		positive_description = {
			desc_id = "effect_player_health_regenerates_on_every_kill",
			desc_params = {
				EFFECT_VALUE_1 = "5%"
			}
		},
		negative_description = {
			desc_id = "effect_players_cannot_die_during_operation"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_rare_you_only_live_once_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2,
		def_id = 30012,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_short_controlled_bursts = {
		name = "card_op_short_controlled_bursts_name_id",
		description = "card_op_short_controlled_bursts_desc_id",
		effects = {
			{
				value = 1.07,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_PLAYERS_CANT_EMPTY_CLIPS,
				fail_message = BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_EMPTIED_A_CLIP
			}
		},
		positive_description = {
			desc_id = "effect_critical_hit_chance_increase",
			desc_params = {
				EFFECT_VALUE_1 = "7%"
			}
		},
		negative_description = {
			desc_id = "effect_players_cant_empty_any_clips"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_rare_short_controlled_bursts_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2,
		def_id = 30013,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_elite_opponents = {
		name = "card_op_elite_opponents_name_id",
		description = "card_op_elite_opponents_desc_id",
		effects = {
			{
				value = 1.25,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE
			},
			{
				value = 1.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMY_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_chance_increased",
			desc_params = {
				EFFECT_VALUE_1 = "25%"
			}
		},
		negative_description = {
			desc_id = "effect_enemies_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_rare_elite_opponents_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2,
		def_id = 30014,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.op_and_headaches_for_all = {
		name = "card_op_and_headaches_for_all_name_id",
		description = "card_op_and_headaches_for_all_desc_id",
		effects = {
			{
				value = 1.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DAMAGE
			},
			{
				value = true,
				type = ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_DIE_ONLY_ON_HEADSHOT
			}
		},
		positive_description = {
			desc_id = "effect_headshots_damage_increased",
			desc_params = {
				EFFECT_VALUE_1 = "50%"
			}
		},
		negative_description = {
			desc_id = "effect_enemies_vulnerable_only_to_headshots"
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_operation_rare_headaches_for_all_hud",
		achievement_id = "",
		bonus_xp_multiplier = 2.5,
		def_id = 30015,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD
	}
	self.cards.ra_b_walk_it_off = {
		name = "challenge_card_ra_b_walk_it_off_name_id",
		description = "challenge_card_ra_b_walk_it_off_desc_id",
		effects = {
			{
				value = 5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER
			}
		},
		positive_description = {
			desc_id = "effect_bleedout_timer_increased",
			desc_params = {
				EFFECT_VALUE_1 = "5"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_booster_raid_common_walk_it_of_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 40002,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	self.cards.ra_b_in_fine_feather = {
		name = "challenge_card_ra_b_in_fine_feather_name_id",
		description = "challenge_card_ra_b_in_fine_feather_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_player_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_booster_raid_uncommon_in_fine_feather_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 40004,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	self.cards.ra_b_precision_fire = {
		name = "challenge_card_ra_b_precision_fire_name_id",
		description = "challenge_card_ra_b_precision_fire_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMIES_RECEIVE_DAMAGE
			}
		},
		positive_description = {
			desc_id = "effect_enemies_take_increased_damage",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_RAID,
		texture = "cc_booster_raid_rare_precision_shooting_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 40005,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	self.cards.op_b_recycle_for_victory = {
		name = "challenge_card_op_b_recycle_for_victory_name_id",
		description = "challenge_card_op_b_recycle_for_victory_desc_id",
		effects = {
			{
				value = 1.1,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE
			}
		},
		positive_description = {
			desc_id = "effect_loot_drop_effect_increased",
			desc_params = {
				EFFECT_VALUE_1 = "10%"
			}
		},
		rarity = LootDropTweakData.RARITY_COMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_booster_operation_common_recycle_for_victory_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 50001,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	self.cards.op_b_will_not_go_quietly = {
		name = "challenge_card_op_b_will_not_go_quietly_name_id",
		description = "challenge_card_op_b_will_not_go_quietly_desc_id",
		effects = {
			{
				value = 7.5,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER
			}
		},
		positive_description = {
			desc_id = "effect_bleedout_timer_increased",
			desc_params = {
				EFFECT_VALUE_1 = "7.5"
			}
		},
		rarity = LootDropTweakData.RARITY_UNCOMMON,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_booster_operation_uncommon_will_not_go_quietly_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 50003,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	self.cards.op_b_on_top_form = {
		name = "challenge_card_op_b_on_top_form_name_id",
		description = "challenge_card_op_b_on_top_form_desc_id",
		effects = {
			{
				value = 1.15,
				type = ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH
			}
		},
		positive_description = {
			desc_id = "effect_player_health_increased",
			desc_params = {
				EFFECT_VALUE_1 = "15%"
			}
		},
		rarity = LootDropTweakData.RARITY_RARE,
		card_type = ChallengeCardsTweakData.CARD_TYPE_OPERATION,
		texture = "cc_booster_operation_rare_on_top_form_hud",
		achievement_id = "",
		bonus_xp = 0,
		def_id = 50006,
		card_category = ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER
	}
	local card_bonus_xp_multi = 1.5
	local card_bonus_xp_multiplier_multi = 1.2

	for _, card_data in pairs(self.cards) do
		if card_data.bonus_xp then
			card_data.bonus_xp = math.round(card_data.bonus_xp * card_bonus_xp_multi)
		elseif card_data.bonus_xp_multiplier then
			card_data.bonus_xp_multiplier = math.round(card_data.bonus_xp_multiplier * card_bonus_xp_multiplier_multi)
		end
	end

	self.cards_index = {
		"ra_on_the_scrounge",
		"ra_no_backups",
		"ra_this_is_gonna_hurt",
		"ra_not_in_the_face",
		"ra_loaded_for_bear",
		"ra_total_carnage",
		"ra_switch_hitter",
		"ra_gunslingers",
		"ra_fresh_troops",
		"ra_dont_you_die_on_me",
		"ra_no_second_chances",
		"ra_a_perfect_score",
		"ra_helmet_shortage",
		"ra_hemorrhaging",
		"ra_crab_people",
		"op_limited_supplies",
		"op_take_the_cannoli",
		"op_everyones_a_tough_guy",
		"op_nichtsplosions",
		"op_war_weary",
		"op_special_for_a_reason",
		"op_dont_blink",
		"op_bad_coffee",
		"op_playing_for_keeps",
		"op_silent_shout",
		"op_blow_me",
		"op_you_only_live_once",
		"op_short_controlled_bursts",
		"op_elite_opponents",
		"op_and_headaches_for_all",
		"ra_b_walk_it_off",
		"ra_b_in_fine_feather",
		"ra_b_precision_fire",
		"op_b_recycle_for_victory",
		"op_b_will_not_go_quietly",
		"op_b_on_top_form",
		"ra_slasher_movie",
		"ra_pumpkin_pie",
		"ra_season_of_resurrection"
	}
end

function ChallengeCardsTweakData:get_all_cards_indexed()
	local result = {}
	local counter = 1

	for _, card_key_name in pairs(self.cards_index) do
		self.cards[card_key_name][ChallengeCardsTweakData.KEY_NAME_FIELD] = card_key_name
		result[counter] = self.cards[card_key_name]
		counter = counter + 1
	end

	return result
end

function ChallengeCardsTweakData:get_card_by_key_name(card_key_name)
	local result = {}
	local card_data = self.cards[card_key_name]

	if card_data then
		result = clone(card_data)
		result[ChallengeCardsTweakData.KEY_NAME_FIELD] = card_key_name
	else
		result = nil
	end

	return result
end

function ChallengeCardsTweakData:get_cards_by_rarity(rarity)
	local cards = {}

	for key, card in pairs(self.cards) do
		if card.rarity == rarity then
			table.insert(cards, key)
		end
	end

	return cards
end
