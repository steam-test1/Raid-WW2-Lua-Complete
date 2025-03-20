CampCustomizationTweakData = CampCustomizationTweakData or class()

function CampCustomizationTweakData:init()
	self:_setup_camp_assets()
	self:_setup_default_camp_list()
end

function CampCustomizationTweakData:_setup_camp_assets()
	self.camp_upgrades_automatic = {
		gold_pile = {}
	}
	self.camp_upgrades_automatic.gold_pile.gold = {}
	local total_tiers = 76
	local max_pile = 5000

	for i = 1, total_tiers do
		local v = i / total_tiers
		local gold = math.ceil(max_pile * v * v * v)

		table.insert(self.camp_upgrades_automatic.gold_pile.gold, gold)
	end

	self.camp_upgrades = {
		bomb = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_bomb/bomb_l01_hud",
					name_id = "golden_bomb_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_bomb/level_1/props_camp_bomb_level_01_shop",
					description_id = "golden_bomb_lvl_1_desc_id"
				},
				{
					gold_price = 500,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_bomb/bomb_l02_hud",
					description_id = "golden_bomb_lvl_2_desc_id",
					name_id = "golden_bomb_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_bomb/level_2/props_camp_bomb_level_02_shop"
				},
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_special_edition_bomb/bomb_special_edition_hud",
					description_id = "special_edition_bomb_desc_id",
					name_id = "special_edition_bomb_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_special_edition_bomb/props_special_edition_bomb_shop",
					dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION
				}
			}
		},
		toilet = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_toilet/toilet_l01_hud",
					description_id = "golden_toilet_lvl_1_desc_id",
					name_id = "golden_toilet_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_toilet/level_01/props_camp_toilet_level_01_shop",
					scene_unit_rotation = Rotation(180, 0, 0)
				},
				{
					gold_price = 125,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_toilet/toilet_l02_hud",
					description_id = "golden_toilet_lvl_2_desc_id",
					name_id = "golden_toilet_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_toilet/level_02/props_camp_toilet_level_02_shop",
					scene_unit_rotation = Rotation(180, 0, 0)
				}
			}
		},
		mission_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_mission/table_missions_l01_hud",
					name_id = "mission_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_mission/level_1/props_table_mission_level_01_shop",
					description_id = "mission_table_lvl_1_desc_id"
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_mission/table_missions_l02_hud",
					description_id = "mission_table_lvl_2_desc_id",
					name_id = "mission_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_mission/level_2/props_table_mission_level_02_shop"
				}
			}
		},
		weapons_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_weapon_upgrades/table_weapons_l01_hud",
					description_id = "weapons_table_lvl_1_desc_id",
					name_id = "weapons_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_weapon_upgrades/level_1/props_table_weapon_upgrades_level_01_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_weapon_upgrades/table_weapons_hud",
					description_id = "weapons_table_lvl_2_desc_id",
					name_id = "weapons_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_weapon_upgrades/level_2/props_table_weapon_upgrades_level_02_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				}
			}
		},
		skill_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_skills/table_skills_l01_hud",
					name_id = "skill_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_skills/level_1/props_table_skills_level_01_shop",
					description_id = "skill_table_lvl_1_desc_id"
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_skills/table_skills_l02_hud",
					description_id = "skill_table_lvl_2_desc_id",
					name_id = "skill_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_skills/level_2/props_table_skills_level_02_shop"
				}
			}
		},
		character_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_caracter_creation/table_character_customization_l01_hud",
					description_id = "char_table_lvl_1_desc_id",
					name_id = "char_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_caracter_creation/level_1/props_table_caracter_creation_level_01_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_caracter_creation/table_character_customization_l02_hud",
					description_id = "char_table_lvl_2_desc_id",
					name_id = "char_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_caracter_creation/level_2/props_table_caracter_creation_level_02_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				}
			}
		},
		card_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_challenge_cards/table_cards_l01_hud",
					name_id = "card_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_challenge_cards/level_1/props_card_table_level_01_shop",
					description_id = "card_table_lvl_1_desc_id"
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_challenge_cards/table_cards_l02_hud",
					description_id = "card_table_lvl_2_desc_id",
					name_id = "card_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_challenge_cards/level_2/props_card_table_level_02_shop"
				}
			}
		},
		radio_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_radio/table_servers_l01_hud",
					description_id = "radio_table_lvl_1_desc_id",
					name_id = "radio_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_radio/level_1/props_table_radio_level_01_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				},
				{
					gold_price = 250,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_table_radio/table_servers_l02_hud",
					description_id = "radio_table_lvl_2_desc_id",
					name_id = "radio_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_table_radio/level_2/props_table_radio_level_02_shop",
					scene_unit_rotation = Rotation(90, 0, 0)
				}
			}
		},
		large_picture_1 = {
			levels = {
				{
					gold_price = 50,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_painting_medium_01/painting_medium_01_l02_hud",
					description_id = "large_picture_lvl_1_desc_id",
					name_id = "large_picture_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_painting_medium_01/level_1/props_painting_medium_01_level_01_shop"
				}
			}
		},
		large_picture_2 = {
			levels = {
				{
					gold_price = 50,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_painting_medium_02/painting_medium_02_l02_hud",
					description_id = "large_picture_lvl_2_desc_id",
					name_id = "large_picture_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_painting_medium_02/level_1/props_painting_medium_02_level_01_shop"
				}
			}
		},
		piano = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_piano/piano_l01_hud",
					description_id = "piano_lvl_1_desc_id",
					name_id = "piano_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_piano/broken_level_0/props_camp_piano_broken_level_01_shop",
					scene_unit_rotation = Rotation(0, 0, 0)
				},
				{
					gold_price = 125,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_piano/piano_l02_hud",
					description_id = "piano_lvl_2_desc_id",
					name_id = "piano_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_piano/level_1/props_camp_piano_level_01_shop",
					scene_unit_rotation = Rotation(0, 0, 0)
				}
			}
		},
		rug = {
			levels = {
				{
					gold_price = 25,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_carpet/carpet_l02_hud",
					description_id = "rug_lvl_1_desc_id",
					name_id = "rug_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_carpet/level_1/props_camp_carpet_level_01_shop",
					scene_unit_rotation = Rotation(180, 0, 0)
				}
			}
		},
		control_table = {
			levels = {
				{
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_control_table/table_control_l01_hud",
					description_id = "control_tables_lvl_1_desc_id",
					name_id = "control_table_lvl_1_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_control_table/level_01/props_camp_control_table_level_01_shop",
					scene_unit_rotation = Rotation(0, 0, 0)
				},
				{
					gold_price = 125,
					grid_icon = "units/vanilla/props/props_camp_upgrades/props_camp_control_table/table_control_l02_hud",
					description_id = "control_tables_lvl_2_desc_id",
					name_id = "control_table_lvl_2_name_id",
					scene_unit = "units/vanilla/props/props_camp_upgrades/props_camp_control_table/level_02/props_camp_control_table_golden_level_02_shop",
					scene_unit_rotation = Rotation(0, 0, 0)
				}
			}
		},
		flags = {
			levels = {
				{
					grid_icon = "units/upd_021/props/camp_upgrades/camp_flags/camp_flag_badman_shop_hud",
					description_id = "flags_badman_desc_id",
					name_id = "flags_badman_name_id",
					scene_unit = "units/upd_021/props/camp_upgrades/camp_flags/camp_flag_badman_shop_prop",
					scene_unit_rotation = Rotation(180, 0, 0)
				},
				{
					gold_price = 150,
					grid_icon = "units/upd_021/props/camp_upgrades/camp_flags/camp_flag_raider_shop_hud",
					description_id = "flags_raider_desc_id",
					name_id = "flags_raider_name_id",
					scene_unit = "units/upd_021/props/camp_upgrades/camp_flags/camp_flag_raider_shop_prop",
					scene_unit_rotation = Rotation(180, 0, 0)
				}
			}
		}
	}
end

function CampCustomizationTweakData:_setup_default_camp_list()
	self.default_camp = {
		{
			upgrade = "gold_pile"
		},
		{
			upgrade = "bomb",
			level = 1
		},
		{
			upgrade = "toilet",
			level = 1
		},
		{
			upgrade = "mission_table",
			level = 1
		},
		{
			upgrade = "weapons_table",
			level = 1
		},
		{
			upgrade = "skill_table",
			level = 1
		},
		{
			upgrade = "character_table",
			level = 1
		},
		{
			upgrade = "card_table",
			level = 1
		},
		{
			upgrade = "radio_table",
			level = 1
		},
		{
			upgrade = "large_picture_1",
			level = 0
		},
		{
			upgrade = "large_picture_2",
			level = 0
		},
		{
			upgrade = "piano",
			level = 1
		},
		{
			upgrade = "rug",
			level = 0
		},
		{
			upgrade = "control_table",
			level = 1
		},
		{
			upgrade = "flags",
			level = 1
		}
	}
end

function CampCustomizationTweakData:get_applyable_upgrades()
	local upgrades = {}

	for upgrade_slot_name, upgrade_slot in pairs(self.camp_upgrades) do
		for upgrade_level, upgrade in ipairs(upgrade_slot.levels) do
			if self:is_upgrade_applyable(upgrade, upgrade_slot_name, upgrade_level) then
				table.insert(upgrades, {
					upgrade = upgrade_slot_name,
					level = upgrade_level
				})
			end
		end
	end

	return upgrades
end

function CampCustomizationTweakData:is_upgrade_applyable(upgrade, upgrade_slot_name, upgrade_level)
	if self:is_default_upgrade(upgrade_slot_name, upgrade_level) then
		return true
	end

	if not upgrade.dlc and upgrade.gold_price then
		return false
	end

	if upgrade.dlc and managers.dlc:is_dlc_unlocked(upgrade.dlc) and not upgrade.gold_price then
		return true
	end

	return false
end

function CampCustomizationTweakData:is_upgrade_unlocked(upgrade)
	if not upgrade.dlc and upgrade.gold_price then
		return true
	end

	if upgrade.dlc and managers.dlc:is_dlc_unlocked(upgrade.dlc) then
		return true
	end

	return false
end

function CampCustomizationTweakData:is_default_upgrade(upgrade_slot_name, upgrade_level)
	if upgrade_level == self:get_default_upgrade_level(upgrade_slot_name) and upgrade_level > 0 then
		return true
	end

	return false
end

function CampCustomizationTweakData:get_default_upgrade_level(upgrade_slot_name)
	for key, upgrade in pairs(self.default_camp) do
		if upgrade.upgrade == upgrade_slot_name then
			return upgrade.level
		end
	end

	return nil
end
