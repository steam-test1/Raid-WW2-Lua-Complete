OperationsTweakData = OperationsTweakData or class()
OperationsTweakData.JOB_TYPE_RAID = 1
OperationsTweakData.JOB_TYPE_OPERATION = 2
OperationsTweakData.PROGRESSION_GROUP_SHORT = "short"
OperationsTweakData.PROGRESSION_GROUP_STANDARD = "standard"
OperationsTweakData.PROGRESSION_GROUP_INITIAL = "initial"
OperationsTweakData.PROGRESSION_GROUPS = {
	OperationsTweakData.PROGRESSION_GROUP_INITIAL,
	OperationsTweakData.PROGRESSION_GROUP_SHORT,
	OperationsTweakData.PROGRESSION_GROUP_STANDARD
}
OperationsTweakData.IN_LOBBY = "in_lobby"
OperationsTweakData.STATE_ZONE_MISSION_SELECTED = "system_zone_mission_selected"
OperationsTweakData.STATE_LOCATION_MISSION_SELECTED = "system_location_mission_selected"
OperationsTweakData.ENTRY_POINT_LEVEL = "streaming_level"

function OperationsTweakData:init()
	self.missions = {}

	self:_init_loading_screens()
	self:_init_regions()
	self:_init_raids()
	self:_init_operations()
	self:_init_progression_data()
	self:_init_consumable_missions_data()
end

function OperationsTweakData:_init_regions()
	self.regions = {
		"germany",
		"france",
		"africa"
	}
end

function OperationsTweakData:_init_progression_data()
	self.progression = {
		initially_unlocked_difficulty = TweakData.DIFFICULTY_2,
		unlock_cycles = 6,
		regular_unlock_cycle_duration = 500,
		final_unlock_cycle_duration = 2000,
		operations_unlock_level = 25,
		initial_mission_unlock_blueprint = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_SHORT,
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		regular_mission_unlock_blueprint = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD,
			OperationsTweakData.PROGRESSION_GROUP_SHORT,
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		mission_groups = {}
	}

	for index, group in pairs(OperationsTweakData.PROGRESSION_GROUPS) do
		self.progression.mission_groups[group] = {}

		for mission_name, mission_data in pairs(self.missions) do
			if mission_data.progression_groups then
				for j = 1, #mission_data.progression_groups do
					if mission_data.progression_groups[j] == group then
						table.insert(self.progression.mission_groups[group], mission_name)

						break
					end
				end
			end
		end
	end
end

function OperationsTweakData:_init_consumable_missions_data()
	self.consumable_missions = {
		base_document_spawn_chance = {
			0.15,
			0.2,
			0.25,
			0.3
		},
		spawn_chance_modifier_increase = 0.1,
		difficulty_reward_multiplier = {
			1,
			1.2,
			1.5,
			2
		}
	}
end

function OperationsTweakData:_init_loading_screens()
	self._loading_screens = {
		generic = {}
	}
	self._loading_screens.generic.image = "loading_raid_ww2"
	self._loading_screens.generic.text = "loading_generic"
	self._loading_screens.city = {
		image = "loading_raid_ww2",
		text = "loading_german_city"
	}
	self._loading_screens.camp_church = {
		image = "loading_raid_ww2",
		text = "loading_camp"
	}
	self._loading_screens.tutorial = {
		image = "loading_raid_ww2",
		text = "loading_tutorial"
	}
	self._loading_screens.flakturm = {
		image = "loading_flak",
		text = "loading_flaktower"
	}
	self._loading_screens.train_yard = {
		image = "loading_raid_ww2",
		text = "loading_trainyard"
	}
	self._loading_screens.train_yard_expo = {
		image = "loading_raid_ww2",
		text = "loading_trainyard_expo"
	}
	self._loading_screens.gold_rush = {
		image = "loading_raid_ww2",
		text = "loading_treasury"
	}
	self._loading_screens.bridge = {
		image = "loading_raid_ww2",
		text = "loading_bridge"
	}
	self._loading_screens.bridge_expo = {
		image = "loading_raid_ww2",
		text = "loading_bridge"
	}
	self._loading_screens.castle = {
		image = "loading_raid_ww2",
		text = "loading_castle"
	}
	self._loading_screens.radio_defense = {
		image = "loading_raid_ww2",
		text = "loading_radio_defense"
	}
	self._loading_screens.gold_rush_oper_01 = {
		image = "loading_screens_02",
		text = "loading_treasury_operation_clear_skies"
	}
	self._loading_screens.radio_defense_oper_01 = {
		image = "loading_screens_04",
		text = "loading_radio_defense_operation_clear_skies"
	}
	self._loading_screens.train_yard_oper_01 = {
		image = "loading_screens_06",
		text = "loading_trainyard_operation_clear_skies"
	}
	self._loading_screens.flakturm_oper_01 = {
		image = "loading_screens_07",
		text = "loading_flaktower_operation_clearskies"
	}
	self._loading_screens.bridge_oper_02 = {
		image = "loading_screens_06",
		text = "loading_bridge_operation_02"
	}
	self._loading_screens.castle_oper_02 = {
		image = "loading_screens_07",
		text = "loading_castle_operation_02"
	}
	self._loading_screens.forest_gumpy = {
		image = "loading_screens_07",
		text = "loading_castle_operation_02"
	}
	self._loading_screens.bunker_test = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.tnd = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.hunters = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.convoy = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.spies_test = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.spies_crash_test = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.sto = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.silo = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
end

function OperationsTweakData:_init_raids()
	self._raids_index = {
		"flakturm",
		"gold_rush",
		"train_yard",
		"radio_defense",
		"ger_bridge",
		"settlement",
		"forest_gumpy",
		"bunker_test",
		"tnd",
		"hunters",
		"convoy",
		"spies_test",
		"sto",
		"silo",
		"kelly",
		"fury_railway"
	}
	self.missions.streaming_level = {
		name_id = "menu_stream",
		level_id = "streaming_level"
	}
	self.missions.camp = {
		name_id = "menu_camp_hl",
		level_id = "camp",
		briefing_id = "menu_germany_desc",
		audio_briefing_id = "menu_enter",
		music_id = "camp",
		region = "germany",
		xp = 0,
		icon_menu = "missions_camp",
		icon_hud = "mission_camp",
		loading = {
			text = "loading_camp",
			image = "camp_loading_screen"
		},
		loading_success = {
			image = "success_loading_screen_01"
		},
		loading_fail = {
			image = "fail_loading_screen_01"
		}
	}
	self.missions.tutorial = {
		name_id = "menu_tutorial_hl",
		level_id = "tutorial",
		briefing_id = "menu_tutorial_desc",
		audio_briefing_id = "flakturm_briefing_long",
		short_audio_briefing_id = "flakturm_brief_short",
		music_id = "camp",
		region = "germany",
		xp = 2000,
		debug = true,
		stealth_bonus = 1.5,
		start_in_stealth = true,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_tutorial",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		icon_menu = "missions_tutorial",
		icon_hud = "miissions_raid_flaktower",
		excluded_continents = {
			"operation"
		},
		loading = {
			text = "loading_tutorial",
			image = "raid_loading_tutorial"
		},
		photos = {
			{
				title_id = "forest_mission_photo_1_title",
				description_id = "forest_mission_photo_1_description",
				photo = "intel_forest_01"
			},
			{
				title_id = "forest_mission_photo_2_title",
				description_id = "forest_mission_photo_2_description",
				photo = "intel_forest_02"
			},
			{
				title_id = "forest_mission_photo_3_title",
				description_id = "forest_mission_photo_3_description",
				photo = "intel_forest_03"
			},
			{
				title_id = "forest_mission_photo_4_title",
				description_id = "forest_mission_photo_4_description",
				photo = "intel_forest_04"
			}
		}
	}
	self.missions.flakturm = {
		name_id = "menu_ger_miss_01_hl",
		level_id = "flakturm",
		briefing_id = "menu_ger_miss_01_desc",
		audio_briefing_id = "flakturm_briefing_long",
		short_audio_briefing_id = "flakturm_brief_short",
		music_id = "flakturm",
		region = "germany",
		xp = 6000,
		stealth_bonus = 1.5,
		start_in_stealth = true,
		dogtags_min = 23,
		dogtags_max = 26,
		trophy = {
			position = "snap_01",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_flaktower"
		},
		greed_items = {
			max = 900,
			min = 750
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_flakturm",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_raid_flaktower",
		icon_menu = "missions_raid_flaktower_menu",
		icon_hud = "miissions_raid_flaktower",
		excluded_continents = {
			"operation"
		},
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b2_assassination_v004"
		},
		loading = {
			text = "menu_ger_miss_01_loading_desc",
			image = "loading_flak"
		},
		photos = {
			{
				title_id = "flak_mission_photo_1_title",
				description_id = "flak_mission_photo_1_description",
				photo = "intel_flak_01"
			},
			{
				title_id = "flak_mission_photo_2_title",
				description_id = "flak_mission_photo_2_description",
				photo = "intel_flak_02"
			},
			{
				title_id = "flak_mission_photo_3_title",
				description_id = "flak_mission_photo_3_description",
				photo = "intel_flak_03"
			},
			{
				title_id = "flak_mission_photo_4_title",
				description_id = "flak_mission_photo_4_description",
				photo = "intel_flak_04"
			},
			{
				title_id = "flak_mission_photo_5_title",
				description_id = "flak_mission_photo_5_description",
				photo = "intel_flak_05"
			},
			{
				title_id = "flak_mission_photo_6_title",
				description_id = "flak_mission_photo_6_description",
				photo = "intel_flak_06"
			}
		}
	}
	self.missions.gold_rush = {
		name_id = "menu_ger_miss_03_ld_hl",
		level_id = "gold_rush",
		briefing_id = "menu_ger_miss_03_ld_desc",
		audio_briefing_id = "bank_briefing_long",
		short_audio_briefing_id = "bank_brief_short",
		region = "germany",
		music_id = "reichsbank",
		xp = 5500,
		dogtags_min = 20,
		dogtags_max = 24,
		trophy = {
			position = "snap_02",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bank"
		},
		greed_items = {
			max = 900,
			min = 700
		},
		sub_worlds_spawned = 1,
		enemy_retire_distance_threshold = 64000000,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_gold_rush",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_raid_bank",
		icon_menu = "missions_raid_bank_menu",
		icon_hud = "mission_raid_railyard",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "menu_ger_miss_03_ld_loading_desc",
			image = "loading_bank"
		},
		photos = {
			{
				title_id = "treasury_mission_photo_1_title",
				description_id = "treasury_mission_photo_1_description",
				photo = "intel_bank_01"
			},
			{
				title_id = "treasury_mission_photo_2_title",
				description_id = "treasury_mission_photo_2_description",
				photo = "intel_bank_02"
			},
			{
				title_id = "treasury_mission_photo_3_title",
				description_id = "treasury_mission_photo_3_description",
				photo = "intel_bank_03"
			},
			{
				title_id = "treasury_mission_photo_4_title",
				description_id = "treasury_mission_photo_4_description",
				photo = "intel_bank_04"
			}
		}
	}
	self.missions.train_yard = {
		name_id = "menu_ger_miss_05_hl",
		level_id = "train_yard",
		briefing_id = "menu_ger_miss_05_desc",
		audio_briefing_id = "trainyard_briefing_long",
		short_audio_briefing_id = "trainyard_brief_short",
		region = "germany",
		music_id = "train_yard",
		start_in_stealth = true,
		xp = 5000,
		dogtags_min = 18,
		dogtags_max = 25,
		trophy = {
			position = "snap_03",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_railyard"
		},
		greed_items = {
			max = 900,
			min = 650
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_train_yard",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_mission_raid_railyard",
		icon_menu = "mission_raid_railyard_menu",
		icon_hud = "mission_raid_railyard",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "menu_ger_miss_05_loading_desc",
			image = "loading_trainyard"
		},
		photos = {
			{
				title_id = "rail_yard_mission_photo_1_title",
				description_id = "rail_yard_mission_photo_1_description",
				photo = "intel_train_01"
			},
			{
				title_id = "rail_yard_mission_photo_2_title",
				description_id = "rail_yard_mission_photo_2_description",
				photo = "intel_train_02"
			},
			{
				title_id = "rail_yard_mission_photo_4_title",
				description_id = "rail_yard_mission_photo_4_description",
				photo = "intel_train_04"
			},
			{
				title_id = "rail_yard_mission_photo_5_title",
				description_id = "rail_yard_mission_photo_5_description",
				photo = "intel_train_05"
			}
		}
	}
	self.missions.radio_defense = {
		name_id = "menu_afr_miss_04_hl",
		level_id = "radio_defense",
		briefing_id = "menu_afr_miss_04_desc",
		audio_briefing_id = "radio_briefing_long",
		short_audio_briefing_id = "radio_brief_short",
		region = "germany",
		music_id = "radio_defense",
		xp = 4500,
		stealth_bonus = 1.5,
		start_in_stealth = true,
		dogtags_min = 20,
		dogtags_max = 25,
		trophy = {
			position = "snap_24",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_radio"
		},
		greed_items = {
			max = 850,
			min = 700
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_radio_defense",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_raid_radio",
		icon_menu = "missions_raid_radio_menu",
		icon_hud = "missions_raid_radio",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_a5_rescue_v005"
		},
		loading = {
			text = "menu_afr_miss_04_loading_desc",
			image = "loading_radio"
		},
		photos = {
			{
				title_id = "radio_base_mission_photo_1_title",
				description_id = "radio_base_mission_photo_1_description",
				photo = "intel_radio_01"
			},
			{
				title_id = "radio_base_mission_photo_2_title",
				description_id = "radio_base_mission_photo_2_description",
				photo = "intel_radio_02"
			},
			{
				title_id = "radio_base_mission_photo_3_title",
				description_id = "radio_base_mission_photo_3_description",
				photo = "intel_radio_03"
			},
			{
				title_id = "radio_base_mission_photo_4_title",
				description_id = "radio_base_mission_photo_4_description",
				photo = "intel_radio_04"
			},
			{
				title_id = "radio_base_mission_photo_5_title",
				description_id = "radio_base_mission_photo_5_description",
				photo = "intel_radio_05"
			}
		}
	}
	self.missions.ger_bridge = {
		name_id = "menu_ger_bridge_00_hl",
		level_id = "ger_bridge",
		briefing_id = "menu_ger_bridge_00_hl_desc",
		audio_briefing_id = "bridge_briefing_long",
		short_audio_briefing_id = "bridge_brief_short",
		region = "germany",
		music_id = "ger_bridge",
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_bridge",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		xp = 5500,
		dogtags_min = 22,
		dogtags_max = 25,
		trophy = {
			position = "snap_23",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bridge"
		},
		icon_menu_big = "xp_events_missions_raid_bridge",
		greed_items = {
			max = 800,
			min = 600
		},
		icon_menu = "missions_raid_bridge_menu",
		icon_hud = "missions_raid_bridge",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_a1_demolition_v005"
		},
		loading = {
			text = "menu_ger_bridge_00_hl_loading_desc",
			image = "loading_bridge"
		},
		excluded_continents = {
			"operation"
		},
		photos = {
			{
				title_id = "bridge_mission_photo_1_title",
				description_id = "bridge_mission_photo_1_description",
				photo = "intel_bridge_01"
			},
			{
				title_id = "bridge_mission_photo_2_title",
				description_id = "bridge_mission_photo_2_description",
				photo = "intel_bridge_02"
			},
			{
				title_id = "bridge_mission_photo_3_title",
				description_id = "bridge_mission_photo_3_description",
				photo = "intel_bridge_03"
			},
			{
				title_id = "bridge_mission_photo_4_title",
				description_id = "bridge_mission_photo_4_description",
				photo = "intel_bridge_04"
			},
			{
				title_id = "bridge_mission_photo_5_title",
				description_id = "bridge_mission_photo_5_description",
				photo = "intel_bridge_05"
			}
		}
	}
	self.missions.settlement = {
		name_id = "menu_afr_miss_05_hl",
		level_id = "settlement",
		briefing_id = "menu_afr_miss_05_desc",
		audio_briefing_id = "castle_briefing_long",
		short_audio_briefing_id = "castle_brief_short",
		region = "germany",
		music_id = "castle",
		xp = 5000,
		dogtags_min = 22,
		dogtags_max = 25,
		trophy = {
			position = "snap_22",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_castle"
		},
		greed_items = {
			max = 820,
			min = 650
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_castle",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_raid_castle",
		icon_menu = "missions_raid_castle_menu",
		icon_hud = "missions_raid_castle",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "menu_afr_miss_05_loading_desc",
			image = "loading_castle"
		},
		photos = {
			{
				title_id = "castle_mission_photo_1_title",
				description_id = "castle_mission_photo_1_description",
				photo = "intel_castle_01"
			},
			{
				title_id = "castle_mission_photo_2_title",
				description_id = "castle_mission_photo_2_description",
				photo = "intel_castle_02"
			},
			{
				title_id = "castle_mission_photo_3_title",
				description_id = "castle_mission_photo_3_description",
				photo = "intel_castle_03"
			},
			{
				title_id = "castle_mission_photo_4_title",
				description_id = "castle_mission_photo_4_description",
				photo = "intel_castle_05"
			},
			{
				title_id = "castle_mission_photo_5_title",
				description_id = "castle_mission_photo_5_description",
				photo = "intel_castle_04"
			}
		}
	}
	self.missions.forest_gumpy = {
		name_id = "menu_forest_gumpy_hl",
		level_id = "forest_gumpy",
		briefing_id = "menu_forest_gumpy_hl_desc",
		audio_briefing_id = "",
		short_audio_briefing_id = "",
		region = "germany",
		music_id = "forest_gumpy",
		xp = 3500,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_forest_gumpy",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		consumable = true,
		icon_menu_big = "xp_events_missions_consumable_forest",
		icon_menu = "missions_menu_consumable_forest",
		icon_hud = "missions_menu_consumable_forest",
		loading = {
			text = "menu_forest_gumpy_hl_loading_desc",
			image = "raid_loading_forest"
		},
		photos = {
			{
				title_id = "forest_mission_photo_1_title",
				description_id = "forest_mission_photo_1_description",
				photo = "intel_forest_01"
			},
			{
				title_id = "forest_mission_photo_2_title",
				description_id = "forest_mission_photo_2_description",
				photo = "intel_forest_02"
			},
			{
				title_id = "forest_mission_photo_3_title",
				description_id = "forest_mission_photo_3_description",
				photo = "intel_forest_03"
			},
			{
				title_id = "forest_mission_photo_4_title",
				description_id = "forest_mission_photo_4_description",
				photo = "intel_forest_04"
			}
		}
	}
	self.missions.bunker_test = {
		name_id = "menu_bunker_test_hl",
		level_id = "bunker_test",
		briefing_id = "menu_bunker_test_desc",
		audio_briefing_id = "mrs_white_bunkers_brief_long",
		short_audio_briefing_id = "mrs_white_bunkers_briefing_short",
		music_id = "random",
		region = "germany",
		xp = 3000,
		stealth_bonus = 1.5,
		dogtags_min = 18,
		dogtags_max = 22,
		trophy = {
			position = "snap_08",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bunker"
		},
		greed_items = {
			max = 650,
			min = 450
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_bunker_test",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		icon_menu_big = "xp_events_missions_bunkers",
		icon_menu = "missions_bunkers",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "loading_bunker_test",
			image = "raid_loading_bunkers"
		},
		start_in_stealth = true,
		photos = {
			{
				title_id = "bunker_mission_photo_1_title",
				description_id = "bunker_mission_photo_1_description",
				photo = "intel_bunkers_05"
			},
			{
				title_id = "bunker_mission_photo_2_title",
				description_id = "bunker_mission_photo_2_description",
				photo = "intel_bunkers_04"
			},
			{
				title_id = "bunker_mission_photo_3_title",
				description_id = "bunker_mission_photo_3_description",
				photo = "intel_bunkers_01"
			},
			{
				title_id = "bunker_mission_photo_4_title",
				description_id = "bunker_mission_photo_4_description",
				photo = "intel_bunkers_02"
			}
		}
	}
	self.missions.tnd = {
		name_id = "menu_tnd_hl",
		level_id = "tnd",
		briefing_id = "menu_tnd_desc",
		audio_briefing_id = "mrs_white_tank_depot_brief_long",
		short_audio_briefing_id = "mrs_white_tank_depot_briefing_short",
		music_id = "castle",
		region = "germany",
		xp = 2500,
		stealth_bonus = 1.5,
		dogtags_min = 18,
		dogtags_max = 22,
		trophy = {
			position = "snap_13",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_tank"
		},
		greed_items = {
			max = 650,
			min = 450
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_tnd",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		icon_menu_big = "xp_events_missions_tank_depot",
		icon_menu = "missions_tank_depot",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "loading_tnd",
			image = "raid_loading_tank_depot"
		},
		photos = {
			{
				title_id = "tank_depot_mission_photo_1_title",
				description_id = "tank_depot_mission_photo_1_description",
				photo = "intel_tank_depot_05"
			},
			{
				title_id = "tank_depot_mission_photo_2_title",
				description_id = "tank_depot_mission_photo_2_description",
				photo = "intel_tank_depot_01"
			},
			{
				title_id = "tank_depot_mission_photo_3_title",
				description_id = "tank_depot_mission_photo_3_description",
				photo = "intel_tank_depot_03"
			},
			{
				title_id = "tank_depot_mission_photo_4_title",
				description_id = "tank_depot_mission_photo_4_description",
				photo = "intel_tank_depot_02"
			}
		}
	}
	self.missions.hunters = {
		name_id = "menu_hunters_hl",
		level_id = "hunters",
		briefing_id = "menu_hunters_desc",
		audio_briefing_id = "mrs_white_hunters_brief_long",
		short_audio_briefing_id = "mrs_white_hunters_briefing_short",
		music_id = "radio_defense",
		region = "germany",
		xp = 2500,
		stealth_bonus = 1.5,
		dogtags_min = 18,
		dogtags_max = 22,
		trophy = {
			position = "snap_06",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_hunters"
		},
		greed_items = {
			max = 650,
			min = 450
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_hunters",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		icon_menu_big = "xp_events_missions_hunters",
		icon_menu = "missions_hunters",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/global/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "loading_hunters",
			image = "raid_loading_hunters"
		},
		start_in_stealth = true,
		photos = {
			{
				title_id = "hunters_mission_photo_1_title",
				description_id = "hunters_mission_photo_1_description",
				photo = "intel_hunters_01"
			},
			{
				title_id = "hunters_mission_photo_2_title",
				description_id = "hunters_mission_photo_2_description",
				photo = "intel_hunters_02"
			},
			{
				title_id = "hunters_mission_photo_4_title",
				description_id = "hunters_mission_photo_4_description",
				photo = "intel_hunters_04"
			}
		}
	}
	self.missions.convoy = {
		name_id = "menu_convoy_hl",
		level_id = "convoy",
		briefing_id = "menu_convoy_desc",
		audio_briefing_id = "mrs_white_convoys_brief_long",
		short_audio_briefing_id = "mrs_white_convoys_briefing_short",
		music_id = "random",
		region = "germany",
		xp = 2500,
		stealth_bonus = 1.5,
		dogtags_min = 22,
		dogtags_max = 26,
		trophy = {
			position = "snap_09",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_convoy"
		},
		greed_items = {
			max = 650,
			min = 450
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_convoy",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		icon_menu_big = "xp_events_missions_convoy",
		icon_menu = "missions_convoy",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_a3_ambush_v005"
		},
		loading = {
			text = "loading_convoy",
			image = "raid_loading_convoy"
		},
		photos = {
			{
				title_id = "convoy_mission_photo_1_title",
				description_id = "convoy_mission_photo_1_description",
				photo = "intel_convoy_01"
			},
			{
				title_id = "convoy_mission_photo_2_title",
				description_id = "convoy_mission_photo_2_description",
				photo = "intel_convoy_03"
			},
			{
				title_id = "convoy_mission_photo_3_title",
				description_id = "convoy_mission_photo_3_description",
				photo = "intel_convoy_02"
			},
			{
				title_id = "convoy_mission_photo_4_title",
				description_id = "convoy_mission_photo_4_description",
				photo = "intel_convoy_04"
			}
		}
	}
	self.missions.spies_test = {
		name_id = "menu_spies_test_hl",
		level_id = "spies_test",
		briefing_id = "menu_spies_test_desc",
		audio_briefing_id = "mrs_white_spies_brief_long",
		short_audio_briefing_id = "mrs_white_spies_briefing_short",
		music_id = "random",
		region = "germany",
		xp = 3000,
		stealth_bonus = 1.5,
		dogtags_min = 22,
		dogtags_max = 28,
		trophy = {
			position = "snap_19",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_spies"
		},
		greed_items = {
			max = 650,
			min = 450
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_spies_test",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_SHORT
		},
		icon_menu_big = "xp_events_missions_spies",
		icon_menu = "missions_spies",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_b3_steal-intel_v004"
		},
		loading = {
			text = "loading_spies_test",
			image = "raid_loading_spies"
		},
		start_in_stealth = true,
		photos = {
			{
				title_id = "spies_mission_photo_1_title",
				description_id = "spies_mission_photo_1_description",
				photo = "intel_spies_05"
			},
			{
				title_id = "spies_mission_photo_2_title",
				description_id = "spies_mission_photo_2_description",
				photo = "intel_spies_02"
			},
			{
				title_id = "spies_mission_photo_3_title",
				description_id = "spies_mission_photo_3_description",
				photo = "intel_spies_03"
			},
			{
				title_id = "spies_mission_photo_4_title",
				description_id = "spies_mission_photo_4_description",
				photo = "intel_spies_04"
			}
		}
	}
	self.missions.sto = {
		name_id = "menu_sto_hl",
		level_id = "sto",
		briefing_id = "menu_sto_desc",
		audio_briefing_id = "",
		short_audio_briefing_id = "",
		music_id = "random",
		region = "germany",
		xp = 2500,
		stealth_bonus = 1.5,
		consumable = true,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_sto",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		icon_menu_big = "xp_events_missions_art_storage",
		icon_menu = "missions_art_storage",
		icon_hud = "missions_raid_flaktower",
		loading = {
			text = "loading_sto",
			image = "raid_loading_art_storage"
		},
		start_in_stealth = true,
		photos = {
			{
				title_id = "art_storage_mission_photo_1_title",
				description_id = "art_storage_mission_photo_1_description",
				photo = "intel_art_storage_01"
			},
			{
				title_id = "art_storage_mission_photo_2_title",
				description_id = "art_storage_mission_photo_2_description",
				photo = "intel_art_storage_02"
			},
			{
				title_id = "art_storage_mission_photo_3_title",
				description_id = "art_storage_mission_photo_3_description",
				photo = "intel_art_storage_03"
			},
			{
				title_id = "art_storage_mission_photo_4_title",
				description_id = "art_storage_mission_photo_4_description",
				photo = "intel_art_storage_05"
			}
		}
	}
	self.missions.silo = {
		name_id = "menu_silo_hl",
		level_id = "silo",
		briefing_id = "menu_silo_desc",
		sub_worlds_spawned = 2,
		audio_briefing_id = "mrs_white_silo_brief_long",
		short_audio_briefing_id = "mrs_white_silo_brief_short",
		music_id = "random",
		region = "germany",
		dogtags_min = 23,
		dogtags_max = 28,
		trophy = {
			position = "snap_17",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_silo"
		},
		xp = 5500,
		stealth_bonus = 1.5,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_silo",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_silo",
		icon_menu = "missions_silo",
		icon_hud = "missions_silo",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004"
		},
		loading = {
			text = "menu_silo_loading_desc",
			image = "loading_silo"
		},
		photos = {
			{
				title_id = "silo_mission_photo_1_title",
				description_id = "silo_mission_photo_1_description",
				photo = "intel_silo_01"
			},
			{
				title_id = "silo_mission_photo_2_title",
				description_id = "silo_mission_photo_2_description",
				photo = "intel_silo_02"
			},
			{
				title_id = "silo_mission_photo_3_title",
				description_id = "silo_mission_photo_3_description",
				photo = "intel_silo_03"
			},
			{
				title_id = "silo_mission_photo_4_title",
				description_id = "silo_mission_photo_4_description",
				photo = "intel_silo_04"
			},
			{
				title_id = "silo_mission_photo_5_title",
				description_id = "silo_mission_photo_5_description",
				photo = "intel_silo_05"
			}
		}
	}
	self.missions.kelly = {
		name_id = "menu_kelly_hl",
		level_id = "kelly",
		briefing_id = "menu_kelly_desc",
		audio_briefing_id = "mrs_white_kelly_brief_long",
		short_audio_briefing_id = "mrs_white_kelly_brief_short",
		music_id = "random",
		region = "germany",
		dogtags_min = 24,
		dogtags_max = 26,
		xp = 4000,
		stealth_bonus = 1.5,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_kelly",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		icon_menu_big = "xp_events_missions_kelly",
		icon_menu = "missions_kelly",
		icon_menu_big = "xp_events_missions_kelly",
		icon_menu = "missions_kelly",
		icon_hud = "missions_raid_flaktower",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004"
		},
		start_in_stealth = true,
		loading = {
			text = "menu_kelly_loading_desc",
			image = "loading_kelly"
		},
		photos = {
			{
				title_id = "kelly_mission_photo_1_title",
				description_id = "kelly_mission_photo_1_description",
				photo = "intel_kelly_01"
			},
			{
				title_id = "kelly_mission_photo_2_title",
				description_id = "kelly_mission_photo_2_description",
				photo = "intel_kelly_02"
			},
			{
				title_id = "kelly_mission_photo_3_title",
				description_id = "kelly_mission_photo_3_description",
				photo = "intel_kelly_03"
			},
			{
				title_id = "kelly_mission_photo_4_title",
				description_id = "kelly_mission_photo_4_description",
				photo = "intel_kelly_04"
			}
		}
	}
	self.missions.fury_railway = {
		level_id = "fury_railway",
		name_id = "menu_fury_railway_name",
		briefing_id = "menu_fury_railway_desc",
		audio_briefing_id = "",
		short_audio_briefing_id = "",
		music_id = "random",
		region = "germany",
		xp = 2500,
		consumable = true,
		stealth_bonus = 1.5,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_fury_railway",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		icon_menu = "missions_fury_railway",
		icon_hud = "missions_consumable_fury_railway",
		loading = {
			text = "loading_fury_railway_text",
			image = "loading_fury_railway"
		},
		start_in_stealth = true,
		photos = {
			{
				title_id = "fury_railway_mission_photo_1_title",
				description_id = "fury_railway_mission_photo_1_description",
				photo = "intel_fury_railway_01"
			},
			{
				title_id = "fury_railway_mission_photo_2_title",
				description_id = "fury_railway_mission_photo_2_description",
				photo = "intel_fury_railway_02"
			},
			{
				title_id = "fury_railway_mission_photo_3_title",
				description_id = "fury_railway_mission_photo_3_description",
				photo = "intel_fury_railway_03"
			},
			{
				title_id = "fury_railway_mission_photo_4_title",
				description_id = "fury_railway_mission_photo_4_description",
				photo = "intel_fury_railway_04"
			}
		}
	}
end

function OperationsTweakData:_init_operations()
	self._operations_index = {
		"clear_skies",
		"oper_flamable"
	}
	self.missions.clear_skies = {
		name_id = "menu_ger_oper_01_hl",
		briefing_id = "menu_ger_oper_01_desc",
		audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		short_audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		region = "germany",
		xp = 11000,
		trophy = {
			position = "snap_05",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_operation_clear_sky"
		},
		job_type = OperationsTweakData.JOB_TYPE_OPERATION,
		icon_menu = "missions_operation_clear_skies_menu",
		icon_hud = "missions_operation_clear_skies",
		events = {},
		loading = {
			text = "menu_ger_oper_01",
			image = "raid_loading_clear_skies_00"
		},
		photos = {
			{
				title_id = "clear_skies_mission_photo_1_title",
				description_id = "clear_skies_mission_photo_1_description",
				photo = "intel_clear_skies_01"
			},
			{
				title_id = "clear_skies_mission_photo_2_title",
				description_id = "clear_skies_mission_photo_2_description",
				photo = "intel_clear_skies_02"
			},
			{
				title_id = "clear_skies_mission_photo_3_title",
				description_id = "clear_skies_mission_photo_3_description",
				photo = "intel_clear_skies_03"
			},
			{
				title_id = "clear_skies_mission_photo_4_title",
				description_id = "clear_skies_mission_photo_4_description",
				photo = "intel_clear_skies_04"
			},
			{
				title_id = "clear_skies_mission_photo_5_title",
				description_id = "clear_skies_mission_photo_5_description",
				photo = "intel_clear_skies_05"
			},
			{
				title_id = "clear_skies_mission_photo_6_title",
				description_id = "clear_skies_mission_photo_6_description",
				photo = "intel_clear_skies_06"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_1 = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_01",
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_01_event_1_name",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		level_id = "zone_germany",
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.mini_raid_1_park = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_01",
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_01_event_1_name",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		level_id = "zone_germany_park",
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.mini_raid_1_destroyed = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_01",
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_01_event_1_name",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		level_id = "zone_germany_destroyed",
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.mini_raid_1_roundabout = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_01",
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_01_event_1_name",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		level_id = "zone_germany_roundabout",
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2",
			"raid_brnvct"
		}
	}
	self.missions.clear_skies.events.gold_rush = {
		music_id = "reichsbank",
		xp = 1800,
		stealth_bonus = 1.5,
		start_in_stealth = true,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_02",
		checkpoint = true,
		icon_menu = "missions_raid_bank_menu",
		icon_hud = "missions_raid_bank",
		name_id = "menu_ger_oper_01_event_2_name",
		progress_title_id = "menu_ger_oper_01_event_2_progress_title",
		progress_text_id = "menu_ger_oper_01_event_2_progress_text",
		level_id = "gold_rush",
		loading = {
			text = "menu_ger_oper_01_event_2_loading_text",
			image = "raid_loading_clear_skies_02"
		}
	}
	self.missions.clear_skies.events.mini_raid_2 = {
		music_id = "random",
		xp = 2600,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_03",
		checkpoint = true,
		icon_menu = "missions_mini_raid_2_menu",
		icon_hud = "missions_mini_raid_2",
		level_id = "zone_germany",
		name_id = "menu_ger_oper_01_event_3_name",
		progress_title_id = "menu_ger_oper_01_event_3_progress_title",
		progress_text_id = "menu_ger_oper_01_event_3_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_3_loading_text",
			image = "raid_loading_clear_skies_03"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.mini_raid_2_park = {
		music_id = "random",
		xp = 2600,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_03",
		checkpoint = true,
		icon_menu = "missions_mini_raid_2_menu",
		icon_hud = "missions_mini_raid_2",
		level_id = "zone_germany_park",
		name_id = "menu_ger_oper_01_event_3_name",
		progress_title_id = "menu_ger_oper_01_event_3_progress_title",
		progress_text_id = "menu_ger_oper_01_event_3_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_3_loading_text",
			image = "raid_loading_clear_skies_03"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.mini_raid_2_destroyed = {
		music_id = "random",
		xp = 2600,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_03",
		checkpoint = true,
		icon_menu = "missions_mini_raid_2_menu",
		icon_hud = "missions_mini_raid_2",
		level_id = "zone_germany_destroyed",
		name_id = "menu_ger_oper_01_event_3_name",
		progress_title_id = "menu_ger_oper_01_event_3_progress_title",
		progress_text_id = "menu_ger_oper_01_event_3_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_3_loading_text",
			image = "raid_loading_clear_skies_03"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.radio_defense = {
		music_id = "radio_defense",
		xp = 3200,
		stealth_bonus = 1.5,
		start_in_stealth = true,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_04",
		checkpoint = true,
		icon_menu = "missions_raid_radio_menu",
		icon_hud = "missions_raid_radio",
		level_id = "radio_defense",
		name_id = "menu_ger_oper_01_event_4_name",
		progress_title_id = "menu_ger_oper_01_event_4_progress_title",
		progress_text_id = "menu_ger_oper_01_event_4_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_4_loading_text",
			image = "raid_loading_clear_skies_04"
		}
	}
	self.missions.clear_skies.events.mini_raid_3 = {
		music_id = "random",
		xp = 2800,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_05",
		checkpoint = true,
		icon_menu = "missions_mini_raid_3_menu",
		icon_hud = "missions_mini_raid_3",
		level_id = "zone_germany",
		name_id = "menu_ger_oper_01_event_5_name",
		progress_title_id = "menu_ger_oper_01_event_5_progress_title",
		progress_text_id = "menu_ger_oper_01_event_5_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_5_loading_text",
			image = "loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation2mission1",
			"operation2mission2"
		}
	}
	self.missions.clear_skies.events.railyard = {
		music_id = "train_yard",
		xp = 2000,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_06",
		checkpoint = true,
		icon_menu = "mission_raid_railyard_menu",
		icon_hud = "mission_raid_railyard",
		level_id = "train_yard",
		name_id = "menu_ger_oper_01_event_6_name",
		progress_title_id = "menu_ger_oper_01_event_6_progress_title",
		progress_text_id = "menu_ger_oper_01_event_6_progress_text",
		loading = {
			text = "menu_ger_oper_01_event_6_loading_text",
			image = "raid_loading_clear_skies_05"
		}
	}
	self.missions.clear_skies.events.flakturm = {
		level_id = "flakturm",
		music_id = "flakturm",
		start_in_stealth = true,
		xp = 2400,
		icon_menu = "missions_raid_flaktower_menu",
		icon_hud = "miissions_raid_flaktower",
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_operation_01_mission_07",
		name_id = "menu_ger_oper_01_event_7_name",
		progress_title_id = "menu_ger_oper_01_event_7_progress_title",
		progress_text_id = "menu_ger_oper_01_event_7_progress_text",
		excluded_continents = {
			"world"
		},
		loading = {
			text = "menu_ger_oper_01_event_7_loading_text",
			image = "raid_loading_clear_skies_06"
		}
	}
	self.missions.clear_skies.events_index_template = {
		{
			"mini_raid_1_park",
			"mini_raid_1_destroyed",
			"mini_raid_1_roundabout"
		},
		{
			"gold_rush"
		},
		{
			"mini_raid_2_park",
			"mini_raid_2_destroyed"
		},
		{
			"radio_defense"
		},
		{
			"railyard"
		},
		{
			"flakturm"
		}
	}
	self.missions.oper_flamable = {
		name_id = "menu_ger_oper_02_hl",
		briefing_id = "menu_ger_oper_02_desc",
		audio_briefing_id = "mrs_white_or_mr1_brief_long",
		short_audio_briefing_id = "mrs_white_or_mr1_brief_long",
		region = "germany",
		xp = 10000,
		trophy = {
			position = "snap_18",
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_operation_rhinegold"
		},
		job_type = OperationsTweakData.JOB_TYPE_OPERATION,
		icon_menu = "missions_operation_rhinegold_menu",
		icon_hud = "missions_operation_rhinegold",
		events = {},
		loading = {
			text = "menu_ger_oper_rhinegold",
			image = "loading_rhinegold_00"
		},
		photos = {
			{
				title_id = "rhinegold_mission_photo_1_title",
				description_id = "rhinegold_mission_photo_1_description",
				photo = "intel_rhinegold_01"
			},
			{
				title_id = "rhinegold_mission_photo_2_title",
				description_id = "rhinegold_mission_photo_2_description",
				photo = "intel_rhinegold_02"
			},
			{
				title_id = "rhinegold_mission_photo_3_title",
				description_id = "rhinegold_mission_photo_3_description",
				photo = "intel_rhinegold_03"
			},
			{
				title_id = "rhinegold_mission_photo_4_title",
				description_id = "rhinegold_mission_photo_4_description",
				photo = "intel_rhinegold_04"
			},
			{
				title_id = "rhinegold_mission_photo_5_title",
				description_id = "rhinegold_mission_photo_5_description",
				photo = "intel_rhinegold_05"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_park = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_flag = "level_operation_02_mission_01",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		level_id = "zone_germany_park",
		loading = {
			text = "menu_ger_oper_rhinegold_event_1_loading_text",
			image = "loading_rhinegold_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission2"
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_destroyed = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_flag = "level_operation_02_mission_01",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		level_id = "zone_germany_destroyed",
		loading = {
			text = "menu_ger_oper_rhinegold_event_1_loading_text",
			image = "loading_rhinegold_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission2"
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_roundabout = {
		music_id = "random",
		xp = 1400,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_mini_raid_1_menu",
		icon_hud = "missions_mini_raid_1",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_flag = "level_operation_02_mission_01",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		level_id = "zone_germany_roundabout",
		loading = {
			text = "menu_ger_oper_rhinegold_event_1_loading_text",
			image = "loading_rhinegold_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission2",
			"raid_brnvct"
		}
	}
	self.missions.oper_flamable.events.mini_raid_2_destroyed = {
		music_id = "random",
		xp = 1900,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_mini_raid_2_menu",
		icon_hud = "missions_mini_raid_2",
		name_id = "menu_ger_oper_02_event_2_name",
		mission_flag = "level_operation_02_mission_02",
		level_id = "zone_germany_destroyed_fuel",
		progress_title_id = "menu_ger_oper_rhinegold_event_2_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_2_progress_text",
		loading = {
			text = "menu_ger_oper_rhinegold_event_2_loading_text",
			image = "loading_rhinegold_02"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission1"
		}
	}
	self.missions.oper_flamable.events.mini_raid_2_roundabout = {
		music_id = "random",
		xp = 1900,
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_mini_raid_2_menu",
		icon_hud = "missions_mini_raid_2",
		name_id = "menu_ger_oper_02_event_2_name",
		mission_flag = "level_operation_02_mission_02",
		level_id = "zone_germany_roundabout_fuel",
		progress_title_id = "menu_ger_oper_rhinegold_event_2_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_2_progress_text",
		loading = {
			text = "menu_ger_oper_rhinegold_event_2_loading_text",
			image = "loading_rhinegold_02"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission1"
		}
	}
	self.missions.oper_flamable.events.bridge = {
		music_id = "ger_bridge",
		xp = 2400,
		dogtags_min = 20,
		dogtags_max = 25,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		checkpoint = true,
		icon_menu = "missions_raid_bridge_menu",
		icon_hud = "missions_raid_bridge",
		name_id = "menu_ger_oper_02_event_3_name",
		mission_flag = "level_operation_02_mission_03",
		progress_title_id = "menu_ger_oper_rhinegold_event_3_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_3_progress_text",
		loading = {
			text = "menu_ger_oper_rhinegold_event_3_loading_text",
			image = "loading_rhinegold_03"
		},
		level_id = "ger_bridge_operation"
	}
	self.missions.oper_flamable.events.castle = {
		music_id = "castle",
		xp = 3100,
		icon_menu = "missions_raid_castle_menu",
		icon_hud = "missions_raid_castle",
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		start_in_stealth = true,
		name_id = "menu_ger_oper_02_event_4_name",
		mission_flag = "level_operation_02_mission_04",
		progress_title_id = "menu_ger_oper_rhinegold_event_4_progress_title",
		progress_text_id = "menu_ger_oper_rhinegold_event_4_progress_text",
		loading = {
			text = "menu_ger_oper_rhinegold_event_4_loading_text",
			image = "loading_rhinegold_04"
		},
		level_id = "settlement"
	}
	self.missions.oper_flamable.events_index_template = {
		{
			"mini_raid_1_park",
			"mini_raid_1_destroyed",
			"mini_raid_1_roundabout"
		},
		{
			"mini_raid_2_destroyed",
			"mini_raid_2_roundabout"
		},
		{
			"bridge"
		},
		{
			"castle"
		}
	}
end

function OperationsTweakData:get_all_loading_screens()
	return self._loading_screens
end

function OperationsTweakData:get_loading_screen(level)
	local level = self._loading_screens[level]

	if level.success and managers.raid_job:current_job() then
		if managers.raid_job:stage_success() then
			return self._loading_screens[level].success
		else
			return self._loading_screens[level].fail
		end
	else
		return self._loading_screens[level]
	end
end

function OperationsTweakData:mission_data(mission_id)
	if not mission_id or not self.missions[mission_id] then
		return
	end

	local res = deep_clone(self.missions[mission_id])
	res.job_id = mission_id

	return res
end

function OperationsTweakData:get_raids_index()
	return self._raids_index
end

function OperationsTweakData:get_operations_index()
	return self._operations_index
end

function OperationsTweakData:get_index_from_raid_id(raid_id)
	for index, entry_name in ipairs(self._raids_index) do
		if entry_name == raid_id then
			return index
		end
	end

	return 0
end

function OperationsTweakData:get_index_from_operation_id(raid_id)
	for index, entry_name in ipairs(self._operations_index) do
		if entry_name == raid_id then
			return index
		end
	end

	return 0
end

function OperationsTweakData:get_region_index_from_name(region_name)
	for index, reg_name in ipairs(self.regions) do
		if region_name == reg_name then
			return index
		end
	end

	return 0
end

function OperationsTweakData:get_raid_name_from_index(index)
	return self._raids_index[index]
end

function OperationsTweakData:get_operation_name_from_index(index)
	return self._operations_index[index]
end

function OperationsTweakData:randomize_operation(operation_id)
	local operation = self.missions[operation_id]
	local template = operation.events_index_template
	local calculated_index = {}

	for _, value in ipairs(template) do
		local index = math.floor(math.rand(#value)) + 1

		table.insert(calculated_index, value[index])
	end

	operation.events_index = calculated_index

	Application:debug("[OperationsTweakData:randomize_operation]", operation_id, inspect(calculated_index))
end

function OperationsTweakData:get_operation_indexes_delimited(operation_id)
	return table.concat(self.missions[operation_id].events_index, "|")
end

function OperationsTweakData:set_operation_indexes_delimited(operation_id, delimited_string)
	self.missions[operation_id].events_index = string.split(delimited_string, "|")
end

function OperationsTweakData:get_all_consumable_raids()
	local raids = self:get_raids_index()
	local consumable_missions = {}

	for i, raid in pairs(raids) do
		if tweak_data.operations.missions[raid].consumable then
			table.insert(consumable_missions, raid)
		end
	end

	Application:debug("[OperationsTweakData] get_all_consumable_raids, Found:", #consumable_missions)

	return consumable_missions
end

function OperationsTweakData:get_random_consumable_raid()
	local consumable_missions = self:get_all_consumable_raids()
	local chosen_consumable_id = consumable_missions[math.random(1, #consumable_missions)]

	Application:debug("[OperationsTweakData:get_random_consumable_raid]", chosen_consumable_id)

	return chosen_consumable_id
end

function OperationsTweakData:get_random_unowned_consumable_raid()
	local consumable_missions = {}
	local all_consumables = self:get_all_consumable_raids()

	for i, v in ipairs(all_consumables) do
		if not Global.consumable_missions_manager.inventory[v] then
			table.insert(consumable_missions, v)
		end
	end

	local chosen_consumable_id = consumable_missions[math.random(1, #consumable_missions)]

	Application:debug("[OperationsTweakData:get_random_unowned_consumable_raid]", chosen_consumable_id)

	return chosen_consumable_id
end
