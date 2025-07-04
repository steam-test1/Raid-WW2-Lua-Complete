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
OperationsTweakData.RAID_NOT_STEALTHABLE = "whisper_info_starts_loud"
OperationsTweakData.RAID_STARTS_STEALTHABLE = "whisper_info_starts_stealth"
OperationsTweakData.RAID_MOSTLY_STEALTHABLE = "whisper_info_mostly_stealthable"
OperationsTweakData.RAID_COMPLETELY_STEALTHABLE = "whisper_info_completely_stealthable"
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
	self:_init_bounty_data()
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
		initially_unlocked_difficulty = TweakData.DIFFICULTY_3,
		bounty_locked_below_difficulty = TweakData.DIFFICULTY_3,
		unlock_cycles = 6,
		regular_unlock_cycle_duration = 420,
		final_unlock_cycle_duration = 1000,
		operations_unlock_level = 10,
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
		spawn_chance_modifier_increase = 0.1
	}
end

function OperationsTweakData:_init_bounty_data()
	self.bounty_data = {
		job_potential = {
			oper_flamable_castle = true,
			oper_flamable_bridge = true,
			clear_skies_gold_rush = true,
			clear_skies_radio_defense = true,
			clear_skies_flakturm = true,
			forest_bunker = true,
			kelly = true,
			silo = true,
			gold_rush = true,
			flakturm = true,
			ger_bridge = true,
			train_yard = true,
			radio_defense = true,
			settlement = true,
			spies_test = true,
			convoy = true,
			bunker_test = true,
			tnd = true,
			hunters = true
		}
	}
	self.bounty_data.possible_jobs = table.map_keys(self.bounty_data.job_potential)
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
	self._loading_screens.gold_rush = {
		image = "loading_raid_ww2",
		text = "loading_treasury"
	}
	self._loading_screens.bridge = {
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
	self._loading_screens.sto = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.silo = {
		image = "loading_screens_07",
		text = "loading_bridge"
	}
	self._loading_screens.kelly = {
		image = "loading_screens_07",
		text = "menu_kelly_loading_desc"
	}
	self._loading_screens.forest_bunker = {
		image = "loading_screens_07",
		text = "forest_bunker_loading"
	}
end

function OperationsTweakData:get_camp_goto_objective_id(job_id)
	job_id = tostring(job_id)
	local job_data = self.missions[job_id]

	if job_data then
		if job_data.camp_objective_id then
			return job_data.camp_objective_id
		else
			return "obj_camp_goto_raid_" .. job_id
		end
	else
		Application:warn("[OperationsTweakData:get_camp_goto_objective_id] job_data was nil, job_id", job_id)

		return "obj_camp_goto_raid"
	end
end

function OperationsTweakData:_init_raids()
	self._raids_index = {
		"sto",
		"forest_gumpy",
		"fury_railway",
		"hunters",
		"tnd",
		"bunker_test",
		"convoy",
		"spies_test",
		"settlement",
		"radio_defense",
		"train_yard",
		"ger_bridge",
		"flakturm",
		"gold_rush",
		"silo",
		"kelly",
		"forest_bunker"
	}
	self.dogtag_types = {
		small = {
			min = 14,
			diff_bonus = 1,
			max = 18
		},
		medium = {
			min = 15,
			diff_bonus = 2,
			max = 20
		},
		large = {
			min = 16,
			diff_bonus = 3,
			max = 22
		}
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
		no_dynamic_objective = true,
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
		},
		excluded_continents = {}
	}
	self.missions.tutorial = {
		name_id = "menu_tutorial_hl",
		level_id = "tutorial",
		briefing_id = "menu_tutorial_desc",
		audio_briefing_id = "flakturm_briefing_long",
		short_audio_briefing_id = "flakturm_brief_short",
		music_id = "camp",
		region = "germany",
		xp = 0,
		no_dynamic_objective = true,
		debug = true,
		start_in_stealth = true,
		stealth_description = OperationsTweakData.RAID_NOT_STEALTHABLE,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_tutorial",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		icon_menu = "missions_tutorial",
		icon_hud = "miissions_raid_flaktower",
		loading = {
			text = "loading_tutorial",
			image = "raid_loading_tutorial"
		},
		photos = {
			{
				description_id = "forest_mission_photo_1_description",
				title_id = "forest_mission_photo_1_title",
				photo = "intel_forest_01"
			},
			{
				description_id = "forest_mission_photo_2_description",
				title_id = "forest_mission_photo_2_title",
				photo = "intel_forest_02"
			},
			{
				description_id = "forest_mission_photo_3_description",
				title_id = "forest_mission_photo_3_title",
				photo = "intel_forest_03"
			},
			{
				description_id = "forest_mission_photo_4_description",
				title_id = "forest_mission_photo_4_title",
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
		xp = 5800,
		start_in_stealth = true,
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		dogtags = self.dogtag_types.medium,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_flaktower",
			position = "snap_01"
		},
		greed_items = {
			min = 1200,
			max = 1500
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_flakturm",
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
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
			"movies/vanilla/mission_briefings/02_mission_brief_b2_assassination_v004"
		},
		loading = {
			text = "menu_ger_miss_01_loading_desc",
			image = "loading_flak"
		},
		photos = {
			{
				description_id = "flak_mission_photo_1_description",
				title_id = "flak_mission_photo_1_title",
				photo = "intel_flak_01"
			},
			{
				description_id = "flak_mission_photo_2_description",
				title_id = "flak_mission_photo_2_title",
				photo = "intel_flak_02"
			},
			{
				description_id = "flak_mission_photo_3_description",
				title_id = "flak_mission_photo_3_title",
				photo = "intel_flak_03"
			},
			{
				description_id = "flak_mission_photo_4_description",
				title_id = "flak_mission_photo_4_title",
				photo = "intel_flak_04"
			},
			{
				description_id = "flak_mission_photo_5_description",
				title_id = "flak_mission_photo_5_title",
				photo = "intel_flak_05"
			},
			{
				description_id = "flak_mission_photo_6_description",
				title_id = "flak_mission_photo_6_title",
				photo = "intel_flak_06"
			}
		}
	}
	self.missions.gold_rush = {
		name_id = "menu_ger_miss_03_ld_hl",
		level_id = "gold_rush",
		camp_objective_id = "obj_camp_goto_raid_reichsbank",
		briefing_id = "menu_ger_miss_03_ld_desc",
		audio_briefing_id = "bank_briefing_long",
		short_audio_briefing_id = "bank_brief_short",
		region = "germany",
		music_id = "reichsbank",
		stealth_description = OperationsTweakData.RAID_NOT_STEALTHABLE,
		xp = 4000,
		dogtags = self.dogtag_types.small,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bank",
			position = "snap_02"
		},
		greed_items = {
			min = 300,
			max = 500
		},
		sub_worlds_spawned = 1,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_gold_rush",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		forbids_random = {
			"clear_skies_gold_rush"
		},
		icon_menu_big = "xp_events_missions_raid_bank",
		icon_menu = "missions_raid_bank_menu",
		icon_hud = "mission_raid_railyard",
		control_brief_video = {
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
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
				description_id = "treasury_mission_photo_1_description",
				title_id = "treasury_mission_photo_1_title",
				photo = "intel_bank_01"
			},
			{
				description_id = "treasury_mission_photo_2_description",
				title_id = "treasury_mission_photo_2_title",
				photo = "intel_bank_02"
			},
			{
				description_id = "treasury_mission_photo_3_description",
				title_id = "treasury_mission_photo_3_title",
				photo = "intel_bank_03"
			},
			{
				description_id = "treasury_mission_photo_4_description",
				title_id = "treasury_mission_photo_4_title",
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
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		xp = 5000,
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		dogtags = self.dogtag_types.large,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_railyard",
			position = "snap_03"
		},
		greed_items = {
			min = 1000,
			max = 1600
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
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
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
				description_id = "rail_yard_mission_photo_1_description",
				title_id = "rail_yard_mission_photo_1_title",
				photo = "intel_train_01"
			},
			{
				description_id = "rail_yard_mission_photo_2_description",
				title_id = "rail_yard_mission_photo_2_title",
				photo = "intel_train_02"
			},
			{
				description_id = "rail_yard_mission_photo_4_description",
				title_id = "rail_yard_mission_photo_4_title",
				photo = "intel_train_04"
			},
			{
				description_id = "rail_yard_mission_photo_5_description",
				title_id = "rail_yard_mission_photo_5_title",
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
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		start_in_stealth = true,
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		dogtags = self.dogtag_types.medium,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_radio",
			position = "snap_24"
		},
		greed_items = {
			min = 1200,
			max = 1800
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
				description_id = "radio_base_mission_photo_1_description",
				title_id = "radio_base_mission_photo_1_title",
				photo = "intel_radio_01"
			},
			{
				description_id = "radio_base_mission_photo_2_description",
				title_id = "radio_base_mission_photo_2_title",
				photo = "intel_radio_02"
			},
			{
				description_id = "radio_base_mission_photo_3_description",
				title_id = "radio_base_mission_photo_3_title",
				photo = "intel_radio_03"
			},
			{
				description_id = "radio_base_mission_photo_4_description",
				title_id = "radio_base_mission_photo_4_title",
				photo = "intel_radio_04"
			},
			{
				description_id = "radio_base_mission_photo_5_description",
				title_id = "radio_base_mission_photo_5_title",
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
		stealth_description = OperationsTweakData.RAID_NOT_STEALTHABLE,
		mission_flag = "level_raid_bridge",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_INITIAL,
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
		xp = 3600,
		dogtags = self.dogtag_types.small,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bridge",
			position = "snap_23"
		},
		icon_menu_big = "xp_events_missions_raid_bridge",
		greed_items = {
			min = 600,
			max = 800
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
				description_id = "bridge_mission_photo_1_description",
				title_id = "bridge_mission_photo_1_title",
				photo = "intel_bridge_01"
			},
			{
				description_id = "bridge_mission_photo_2_description",
				title_id = "bridge_mission_photo_2_title",
				photo = "intel_bridge_02"
			},
			{
				description_id = "bridge_mission_photo_3_description",
				title_id = "bridge_mission_photo_3_title",
				photo = "intel_bridge_03"
			},
			{
				description_id = "bridge_mission_photo_4_description",
				title_id = "bridge_mission_photo_4_title",
				photo = "intel_bridge_04"
			},
			{
				description_id = "bridge_mission_photo_5_description",
				title_id = "bridge_mission_photo_5_title",
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
		stealth_description = OperationsTweakData.RAID_NOT_STEALTHABLE,
		xp = 5000,
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		dogtags = self.dogtag_types.large,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_castle",
			position = "snap_22"
		},
		greed_items = {
			min = 1200,
			max = 1800
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
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
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
				description_id = "castle_mission_photo_1_description",
				title_id = "castle_mission_photo_1_title",
				photo = "intel_castle_01"
			},
			{
				description_id = "castle_mission_photo_2_description",
				title_id = "castle_mission_photo_2_title",
				photo = "intel_castle_02"
			},
			{
				description_id = "castle_mission_photo_3_description",
				title_id = "castle_mission_photo_3_title",
				photo = "intel_castle_03"
			},
			{
				description_id = "castle_mission_photo_4_description",
				title_id = "castle_mission_photo_4_title",
				photo = "intel_castle_05"
			},
			{
				description_id = "castle_mission_photo_5_description",
				title_id = "castle_mission_photo_5_title",
				photo = "intel_castle_04"
			}
		}
	}
	self.missions.forest_gumpy = {
		name_id = "menu_forest_gumpy_hl",
		level_id = "forest_gumpy",
		briefing_id = "menu_forest_gumpy_hl_desc",
		camp_objective_id = "obj_camp_goto_consumable_forest",
		audio_briefing_id = "",
		short_audio_briefing_id = "",
		region = "germany",
		music_id = "forest_gumpy",
		stealth_description = OperationsTweakData.RAID_NOT_STEALTHABLE,
		xp = 3200,
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
				description_id = "forest_mission_photo_1_description",
				title_id = "forest_mission_photo_1_title",
				photo = "intel_forest_01"
			},
			{
				description_id = "forest_mission_photo_2_description",
				title_id = "forest_mission_photo_2_title",
				photo = "intel_forest_02"
			},
			{
				description_id = "forest_mission_photo_3_description",
				title_id = "forest_mission_photo_3_title",
				photo = "intel_forest_03"
			},
			{
				description_id = "forest_mission_photo_4_description",
				title_id = "forest_mission_photo_4_title",
				photo = "intel_forest_04"
			}
		}
	}
	self.missions.bunker_test = {
		name_id = "menu_bunker_test_hl",
		level_id = "bunker_test",
		camp_objective_id = "obj_camp_goto_raid_bunker",
		briefing_id = "menu_bunker_test_desc",
		audio_briefing_id = "mrs_white_bunkers_brief_long",
		short_audio_briefing_id = "mrs_white_bunkers_briefing_short",
		music_id = "random",
		region = "germany",
		xp = 3000,
		dogtags = self.dogtag_types.small,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_bunker",
			position = "snap_08"
		},
		greed_items = {
			min = 600,
			max = 900
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
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_a2_cause-carnage_v005",
			"movies/vanilla/mission_briefings/02_mission_brief_b1_cause-carnage_v004",
			"movies/vanilla/mission_briefings/02_mission_brief_b5_steal-valuables_cause-carnage_v004"
		},
		loading = {
			text = "loading_bunker_test",
			image = "raid_loading_bunkers"
		},
		start_in_stealth = true,
		stealth_description = OperationsTweakData.RAID_STARTS_STEALTHABLE,
		photos = {
			{
				description_id = "bunker_mission_photo_1_description",
				title_id = "bunker_mission_photo_1_title",
				photo = "intel_bunkers_05"
			},
			{
				description_id = "bunker_mission_photo_2_description",
				title_id = "bunker_mission_photo_2_title",
				photo = "intel_bunkers_04"
			},
			{
				description_id = "bunker_mission_photo_3_description",
				title_id = "bunker_mission_photo_3_title",
				photo = "intel_bunkers_01"
			},
			{
				description_id = "bunker_mission_photo_4_description",
				title_id = "bunker_mission_photo_4_title",
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
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		xp = 2500,
		dogtags = self.dogtag_types.small,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_tank",
			position = "snap_13"
		},
		greed_items = {
			min = 600,
			max = 900
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
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
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
				description_id = "tank_depot_mission_photo_1_description",
				title_id = "tank_depot_mission_photo_1_title",
				photo = "intel_tank_depot_05"
			},
			{
				description_id = "tank_depot_mission_photo_2_description",
				title_id = "tank_depot_mission_photo_2_title",
				photo = "intel_tank_depot_01"
			},
			{
				description_id = "tank_depot_mission_photo_3_description",
				title_id = "tank_depot_mission_photo_3_title",
				photo = "intel_tank_depot_03"
			},
			{
				description_id = "tank_depot_mission_photo_4_description",
				title_id = "tank_depot_mission_photo_4_title",
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
		stealth_description = OperationsTweakData.RAID_COMPLETELY_STEALTHABLE,
		xp = 2500,
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		dogtags = self.dogtag_types.medium,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_hunters",
			position = "snap_06"
		},
		greed_items = {
			min = 1700,
			max = 2400
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
			"movies/vanilla/mission_briefings/02_mission_brief_b4_steal-valuables_cause-carnage_v004",
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
				description_id = "hunters_mission_photo_1_description",
				title_id = "hunters_mission_photo_1_title",
				photo = "intel_hunters_01"
			},
			{
				description_id = "hunters_mission_photo_2_description",
				title_id = "hunters_mission_photo_2_title",
				photo = "intel_hunters_02"
			},
			{
				description_id = "hunters_mission_photo_4_description",
				title_id = "hunters_mission_photo_4_title",
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
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		xp = 2500,
		dogtags = self.dogtag_types.small,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_convoy",
			position = "snap_09"
		},
		greed_items = {
			min = 300,
			max = 400
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
				description_id = "convoy_mission_photo_1_description",
				title_id = "convoy_mission_photo_1_title",
				photo = "intel_convoy_01"
			},
			{
				description_id = "convoy_mission_photo_2_description",
				title_id = "convoy_mission_photo_2_title",
				photo = "intel_convoy_03"
			},
			{
				description_id = "convoy_mission_photo_3_description",
				title_id = "convoy_mission_photo_3_title",
				photo = "intel_convoy_02"
			},
			{
				description_id = "convoy_mission_photo_4_description",
				title_id = "convoy_mission_photo_4_title",
				photo = "intel_convoy_04"
			}
		}
	}
	self.missions.spies_test = {
		name_id = "menu_spies_test_hl",
		level_id = "spies_test",
		camp_objective_id = "obj_camp_goto_raid_spies",
		briefing_id = "menu_spies_test_desc",
		audio_briefing_id = "mrs_white_spies_brief_long",
		short_audio_briefing_id = "mrs_white_spies_briefing_short",
		music_id = "random",
		region = "germany",
		stealth_description = OperationsTweakData.RAID_MOSTLY_STEALTHABLE,
		xp = 3000,
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		dogtags = self.dogtag_types.medium,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_spies",
			position = "snap_19"
		},
		greed_items = {
			min = 750,
			max = 950
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
				description_id = "spies_mission_photo_1_description",
				title_id = "spies_mission_photo_1_title",
				photo = "intel_spies_05"
			},
			{
				description_id = "spies_mission_photo_2_description",
				title_id = "spies_mission_photo_2_title",
				photo = "intel_spies_02"
			},
			{
				description_id = "spies_mission_photo_3_description",
				title_id = "spies_mission_photo_3_title",
				photo = "intel_spies_03"
			},
			{
				description_id = "spies_mission_photo_4_description",
				title_id = "spies_mission_photo_4_title",
				photo = "intel_spies_04"
			}
		}
	}
	self.missions.sto = {
		name_id = "menu_sto_hl",
		level_id = "sto",
		briefing_id = "menu_sto_desc",
		camp_objective_id = "obj_camp_goto_consumable_sto",
		audio_briefing_id = "",
		short_audio_briefing_id = "",
		music_id = "random",
		region = "germany",
		stealth_description = OperationsTweakData.RAID_COMPLETELY_STEALTHABLE,
		xp = 2500,
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
				description_id = "art_storage_mission_photo_1_description",
				title_id = "art_storage_mission_photo_1_title",
				photo = "intel_art_storage_01"
			},
			{
				description_id = "art_storage_mission_photo_2_description",
				title_id = "art_storage_mission_photo_2_title",
				photo = "intel_art_storage_02"
			},
			{
				description_id = "art_storage_mission_photo_3_description",
				title_id = "art_storage_mission_photo_3_title",
				photo = "intel_art_storage_03"
			},
			{
				description_id = "art_storage_mission_photo_4_description",
				title_id = "art_storage_mission_photo_4_title",
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
		stealth_description = OperationsTweakData.RAID_STARTS_STEALTHABLE,
		dogtags = self.dogtag_types.medium,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_silo",
			position = "snap_17"
		},
		greed_items = {
			min = 750,
			max = 950
		},
		xp = 5500,
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
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
				description_id = "silo_mission_photo_1_description",
				title_id = "silo_mission_photo_1_title",
				photo = "intel_silo_01"
			},
			{
				description_id = "silo_mission_photo_2_description",
				title_id = "silo_mission_photo_2_title",
				photo = "intel_silo_02"
			},
			{
				description_id = "silo_mission_photo_3_description",
				title_id = "silo_mission_photo_3_title",
				photo = "intel_silo_03"
			},
			{
				description_id = "silo_mission_photo_4_description",
				title_id = "silo_mission_photo_4_title",
				photo = "intel_silo_04"
			},
			{
				description_id = "silo_mission_photo_5_description",
				title_id = "silo_mission_photo_5_title",
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
		stealth_description = OperationsTweakData.RAID_COMPLETELY_STEALTHABLE,
		dogtags = self.dogtag_types.medium,
		xp = 3200,
		greed_items = {
			min = 200,
			max = 400
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		mission_flag = "level_raid_kelly",
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		progression_groups = {
			OperationsTweakData.PROGRESSION_GROUP_STANDARD
		},
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
				description_id = "kelly_mission_photo_1_description",
				title_id = "kelly_mission_photo_1_title",
				photo = "intel_kelly_01"
			},
			{
				description_id = "kelly_mission_photo_2_description",
				title_id = "kelly_mission_photo_2_title",
				photo = "intel_kelly_02"
			},
			{
				description_id = "kelly_mission_photo_3_description",
				title_id = "kelly_mission_photo_3_title",
				photo = "intel_kelly_03"
			},
			{
				description_id = "kelly_mission_photo_4_description",
				title_id = "kelly_mission_photo_4_title",
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
		music_id = "forest_gumpy",
		region = "germany",
		camp_objective_id = "obj_camp_goto_outlaw_fury_railway",
		stealth_description = OperationsTweakData.RAID_STARTS_STEALTHABLE,
		xp = 2500,
		consumable = true,
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
				description_id = "fury_railway_mission_photo_1_description",
				title_id = "fury_railway_mission_photo_1_title",
				photo = "intel_fury_railway_01"
			},
			{
				description_id = "fury_railway_mission_photo_2_description",
				title_id = "fury_railway_mission_photo_2_title",
				photo = "intel_fury_railway_02"
			},
			{
				description_id = "fury_railway_mission_photo_3_description",
				title_id = "fury_railway_mission_photo_3_title",
				photo = "intel_fury_railway_03"
			},
			{
				description_id = "fury_railway_mission_photo_4_description",
				title_id = "fury_railway_mission_photo_4_title",
				photo = "intel_fury_railway_04"
			}
		}
	}
	self.missions.forest_bunker = {
		icon_hud = "missions_forest_bunker",
		icon_menu = "missions_forest_bunker",
		xp = 4400,
		region = "germany",
		music_id = "random",
		audio_briefing_id = "mrs_white_fb_briefing_long",
		icon_menu_big = "xp_events_missions_forest_bunker",
		briefing_id = "forest_bunker_briefing",
		level_id = "forest_bunker",
		mission_flag = "level_raid_forest_bunker",
		name_id = "forest_bunker",
		start_in_stealth = true,
		short_audio_briefing_id = "mrs_white_fb_briefing_short",
		dogtags = self.dogtag_types.medium,
		greed_items = {
			min = 1200,
			max = 1500
		},
		progression_groups = {
			self.PROGRESSION_GROUP_STANDARD
		},
		mission_state = self.STATE_LOCATION_MISSION_SELECTED,
		job_type = self.JOB_TYPE_RAID,
		stealth_description = self.RAID_STARTS_STEALTHABLE,
		loading = {
			text = "forest_bunker_loading",
			image = "forest_bunker_loading_screen"
		},
		photos = {
			{
				description_id = "forest_bunker_mission_photo_1_description",
				title_id = "forest_bunker_mission_photo_1_title",
				photo = "intel_forest_bunker_01"
			},
			{
				description_id = "forest_bunker_mission_photo_2_description",
				title_id = "forest_bunker_mission_photo_2_title",
				photo = "intel_forest_bunker_02"
			},
			{
				description_id = "forest_bunker_mission_photo_3_description",
				title_id = "forest_bunker_mission_photo_3_title",
				photo = "intel_forest_bunker_03"
			},
			{
				description_id = "forest_bunker_mission_photo_4_description",
				title_id = "forest_bunker_mission_photo_4_title",
				photo = "intel_forest_bunker_04"
			}
		}
	}
end

function OperationsTweakData:_init_operations()
	self._operations_index = {
		"clear_skies",
		"oper_flamable",
		"random_short",
		"random_medium",
		"random_long"
	}
	self.missions.clear_skies = {
		name_id = "menu_ger_oper_01_hl",
		briefing_id = "menu_ger_oper_01_desc",
		camp_objective_id = "obj_camp_goto_op_1",
		audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		short_audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		region = "germany",
		xp = 11000,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_operation_clear_sky",
			position = "snap_05"
		},
		job_type = OperationsTweakData.JOB_TYPE_OPERATION,
		icon_menu = "op_clear_skies_lq",
		icon_hud = "op_clear_skies_hd",
		allow_free_play = true,
		events = {},
		loading = {
			text = "menu_ger_oper_01",
			image = "raid_loading_clear_skies_00"
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_1_description",
				title_id = "clear_skies_mission_photo_1_title",
				photo = "intel_clear_skies_01"
			},
			{
				description_id = "clear_skies_mission_photo_2_description",
				title_id = "clear_skies_mission_photo_2_title",
				photo = "intel_clear_skies_02"
			},
			{
				description_id = "clear_skies_mission_photo_3_description",
				title_id = "clear_skies_mission_photo_3_title",
				photo = "intel_clear_skies_03"
			},
			{
				description_id = "clear_skies_mission_photo_4_description",
				title_id = "clear_skies_mission_photo_4_title",
				photo = "intel_clear_skies_04"
			},
			{
				description_id = "clear_skies_mission_photo_5_description",
				title_id = "clear_skies_mission_photo_5_title",
				photo = "intel_clear_skies_05"
			},
			{
				description_id = "clear_skies_mission_photo_6_description",
				title_id = "clear_skies_mission_photo_6_title",
				photo = "intel_clear_skies_06"
			},
			{
				description_id = "clear_skies_mission_photo_7_description",
				title_id = "clear_skies_mission_photo_7_title",
				photo = "intel_clear_skies_07"
			},
			{
				description_id = "clear_skies_mission_photo_8_description",
				title_id = "clear_skies_mission_photo_8_title",
				photo = "intel_clear_skies_08"
			}
		}
	}
	self.missions.clear_skies_mini_raid_1_park = {
		icon_menu = "missions_operation_clear_skies_menu_1",
		xp = 2200,
		music_id = "random",
		audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_1",
		level_id = "zone_germany_park",
		mission_flag = "level_operation_01_mission_01",
		name_id = "menu_ger_oper_01_event_1_name",
		mission_id = "clear_skies_mini_raid_1_park",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_01",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		},
		forbids_random = {
			"clear_skies_mini_raid_1_destroyed",
			"clear_skies_mini_raid_1_roundabout"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_1_description",
				title_id = "clear_skies_mission_photo_1_title",
				photo = "intel_clear_skies_01"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_1_park = self.missions.clear_skies_mini_raid_1_park
	self.missions.clear_skies_mini_raid_1_destroyed = {
		icon_menu = "missions_operation_clear_skies_menu_1",
		xp = 2200,
		music_id = "random",
		audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_1",
		level_id = "zone_germany_destroyed",
		mission_flag = "level_operation_01_mission_01",
		name_id = "menu_ger_oper_01_event_1_name",
		mission_id = "clear_skies_mini_raid_1_destroyed",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_01",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_1_loading_text",
			image = "raid_loading_clear_skies_01"
		},
		excluded_continents = {
			"operation1mission2",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		},
		forbids_random = {
			"clear_skies_mini_raid_1_park",
			"clear_skies_mini_raid_1_roundabout"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_1_description",
				title_id = "clear_skies_mission_photo_1_title",
				photo = "intel_clear_skies_01"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_1_destroyed = self.missions.clear_skies_mini_raid_1_destroyed
	self.missions.clear_skies_mini_raid_1_roundabout = {
		icon_menu = "missions_operation_clear_skies_menu_1",
		xp = 2200,
		music_id = "random",
		audio_briefing_id = "mrs_white_cs_op_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_1",
		level_id = "zone_germany_roundabout",
		mission_flag = "level_operation_01_mission_01",
		name_id = "menu_ger_oper_01_event_1_name",
		mission_id = "clear_skies_mini_raid_1_roundabout",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_01",
		progress_text_id = "menu_ger_oper_01_event_1_progress_text",
		progress_title_id = "menu_ger_oper_01_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
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
		},
		forbids_random = {
			"clear_skies_mini_raid_1_park",
			"clear_skies_mini_raid_1_destroyed"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_1_description",
				title_id = "clear_skies_mission_photo_1_title",
				photo = "intel_clear_skies_01"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_1_roundabout = self.missions.clear_skies_mini_raid_1_roundabout
	self.missions.clear_skies_gold_rush = {
		icon_menu = "missions_operation_clear_skies_menu_2",
		mission_id = "clear_skies_gold_rush",
		xp = 3200,
		music_id = "reichsbank",
		audio_briefing_id = "mrs_white_bank_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_2",
		level_id = "gold_rush",
		mission_flag = "level_operation_01_mission_02",
		name_id = "menu_ger_oper_01_event_2_name",
		start_in_stealth = true,
		camp_objective_id = "obj_camp_goto_oper_clear_sky_02",
		progress_text_id = "menu_ger_oper_01_event_2_progress_text",
		progress_title_id = "menu_ger_oper_01_event_2_progress_title",
		dogtags = self.dogtag_types.medium,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_2_loading_text",
			image = "raid_loading_clear_skies_02"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_2_description",
				title_id = "clear_skies_mission_photo_2_title",
				photo = "intel_clear_skies_02"
			},
			{
				description_id = "clear_skies_mission_photo_3_description",
				title_id = "clear_skies_mission_photo_3_title",
				photo = "intel_clear_skies_03"
			}
		}
	}
	self.missions.clear_skies.events.gold_rush = self.missions.clear_skies_gold_rush
	self.missions.clear_skies_mini_raid_2_park = {
		icon_menu = "missions_operation_clear_skies_menu_3",
		xp = 2600,
		music_id = "random",
		audio_briefing_id = "mrs_white_cs_op_mr2_briefing_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_3",
		level_id = "zone_germany_park",
		mission_flag = "level_operation_01_mission_03",
		name_id = "menu_ger_oper_01_event_3_name",
		mission_id = "clear_skies_mini_raid_2_park",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_03",
		progress_text_id = "menu_ger_oper_01_event_3_progress_text",
		progress_title_id = "menu_ger_oper_01_event_3_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_3_loading_text",
			image = "raid_loading_clear_skies_03"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		},
		forbids_random = {
			"clear_skies_mini_raid_2_destroyed"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_4_description",
				title_id = "clear_skies_mission_photo_4_title",
				photo = "intel_clear_skies_04"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_2_park = self.missions.clear_skies_mini_raid_2_park
	self.missions.clear_skies_mini_raid_2_destroyed = {
		icon_menu = "missions_operation_clear_skies_menu_3",
		xp = 2600,
		music_id = "random",
		audio_briefing_id = "mrs_white_cs_op_mr2_briefing_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_3",
		level_id = "zone_germany_destroyed",
		mission_flag = "level_operation_01_mission_03",
		name_id = "menu_ger_oper_01_event_3_name",
		mission_id = "clear_skies_mini_raid_2_destroyed",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_03",
		progress_text_id = "menu_ger_oper_01_event_3_progress_text",
		progress_title_id = "menu_ger_oper_01_event_3_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_3_loading_text",
			image = "raid_loading_clear_skies_03"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission3",
			"operation2mission1",
			"operation2mission2"
		},
		forbids_random = {
			"clear_skies_mini_raid_2_park"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_4_description",
				title_id = "clear_skies_mission_photo_4_title",
				photo = "intel_clear_skies_04"
			}
		}
	}
	self.missions.clear_skies.events.mini_raid_2_destroyed = self.missions.clear_skies_mini_raid_2_destroyed
	self.missions.clear_skies_radio_defense = {
		icon_menu = "missions_operation_clear_skies_menu_4",
		mission_id = "clear_skies_radio_defense",
		xp = 3200,
		music_id = "radio_defense",
		audio_briefing_id = "mrs_white_radio_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_4",
		level_id = "radio_defense",
		mission_flag = "level_operation_01_mission_04",
		name_id = "menu_ger_oper_01_event_4_name",
		start_in_stealth = true,
		camp_objective_id = "obj_camp_goto_oper_clear_sky_04",
		progress_text_id = "menu_ger_oper_01_event_4_progress_text",
		progress_title_id = "menu_ger_oper_01_event_4_progress_title",
		dogtags = self.dogtag_types.medium,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_4_loading_text",
			image = "raid_loading_clear_skies_04"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_5_description",
				title_id = "clear_skies_mission_photo_5_title",
				photo = "intel_clear_skies_05"
			},
			{
				description_id = "clear_skies_mission_photo_6_description",
				title_id = "clear_skies_mission_photo_6_title",
				photo = "intel_clear_skies_06"
			}
		}
	}
	self.missions.clear_skies.events.radio_defense = self.missions.clear_skies_radio_defense
	self.missions.clear_skies_railyard = {
		icon_menu = "missions_operation_clear_skies_menu_5",
		xp = 1500,
		music_id = "train_yard",
		audio_briefing_id = "mrs_white_trainyard_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_5",
		level_id = "train_yard",
		mission_flag = "level_operation_01_mission_06",
		name_id = "menu_ger_oper_01_event_6_name",
		mission_id = "clear_skies_railyard",
		camp_objective_id = "obj_camp_goto_oper_clear_sky_05",
		progress_text_id = "menu_ger_oper_01_event_6_progress_text",
		progress_title_id = "menu_ger_oper_01_event_6_progress_title",
		dogtags = {
			min = 6,
			diff_bonus = 1,
			max = 10
		},
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_6_loading_text",
			image = "raid_loading_clear_skies_05"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_7_description",
				title_id = "clear_skies_mission_photo_7_title",
				photo = "intel_clear_skies_07"
			}
		}
	}
	self.missions.clear_skies.events.railyard = self.missions.clear_skies_railyard
	self.missions.clear_skies_flakturm = {
		camp_objective_id = "obj_camp_goto_oper_clear_sky_06",
		icon_menu = "missions_operation_clear_skies_menu_6",
		mission_id = "clear_skies_flakturm",
		xp = 3600,
		music_id = "flakturm",
		audio_briefing_id = "mrs_white_flakturm_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_clear_skies_6",
		level_id = "flakturm",
		mission_flag = "level_operation_01_mission_07",
		name_id = "menu_ger_oper_01_event_7_name",
		start_in_stealth = true,
		progress_text_id = "menu_ger_oper_01_event_7_progress_text",
		progress_title_id = "menu_ger_oper_01_event_7_progress_title",
		dogtags = self.dogtag_types.large,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_01_event_7_loading_text",
			image = "raid_loading_clear_skies_06"
		},
		excluded_continents = {
			"world"
		},
		forbids_random = {
			"flakturm"
		},
		photos = {
			{
				description_id = "clear_skies_mission_photo_8_description",
				title_id = "clear_skies_mission_photo_8_title",
				photo = "intel_clear_skies_08"
			}
		}
	}
	self.missions.clear_skies.events.flakturm = self.missions.clear_skies_flakturm
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
		camp_objective_id = "obj_camp_goto_op_2",
		audio_briefing_id = "mrs_white_or_mr1_brief_long",
		short_audio_briefing_id = "mrs_white_or_mr1_brief_long",
		region = "germany",
		xp = 10000,
		trophy = {
			unit = "units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_trophy_operation_rhinegold",
			position = "snap_18"
		},
		job_type = OperationsTweakData.JOB_TYPE_OPERATION,
		icon_menu = "op_rhinegold_lq",
		icon_hud = "op_rhinegold_hd",
		allow_free_play = true,
		events = {},
		loading = {
			text = "menu_ger_oper_rhinegold",
			image = "loading_rhinegold_00"
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_1_description",
				title_id = "rhinegold_mission_photo_1_title",
				photo = "intel_rhinegold_01"
			},
			{
				description_id = "rhinegold_mission_photo_2_description",
				title_id = "rhinegold_mission_photo_2_title",
				photo = "intel_rhinegold_02"
			},
			{
				description_id = "rhinegold_mission_photo_3_description",
				title_id = "rhinegold_mission_photo_3_title",
				photo = "intel_rhinegold_03"
			},
			{
				description_id = "rhinegold_mission_photo_4_description",
				title_id = "rhinegold_mission_photo_4_title",
				photo = "intel_rhinegold_04"
			},
			{
				description_id = "rhinegold_mission_photo_5_description",
				title_id = "rhinegold_mission_photo_5_title",
				photo = "intel_rhinegold_05"
			}
		}
	}
	self.missions.oper_flamable_mini_raid_1_park = {
		icon_menu = "missions_operation_rhinegold_menu_1",
		xp = 2400,
		music_id = "random",
		audio_briefing_id = "mrs_white_or_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_1",
		level_id = "zone_germany_park",
		mission_flag = "level_operation_02_mission_01",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_id = "oper_flamable_mini_raid_1_park",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_01",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_1_loading_text",
			image = "loading_rhinegold_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission2"
		},
		forbids_random = {
			"oper_flamable_mini_raid_1_destroyed",
			"oper_flamable_mini_raid_1_roundabout"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_1_description",
				title_id = "rhinegold_mission_photo_1_title",
				photo = "intel_rhinegold_01"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_park = self.missions.oper_flamable_mini_raid_1_park
	self.missions.oper_flamable_mini_raid_1_destroyed = {
		icon_menu = "missions_operation_rhinegold_menu_1",
		xp = 2400,
		music_id = "random",
		audio_briefing_id = "mrs_white_or_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_1",
		level_id = "zone_germany_destroyed",
		mission_flag = "level_operation_02_mission_01",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_id = "oper_flamable_mini_raid_1_destroyed",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_01",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_1_loading_text",
			image = "loading_rhinegold_01"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission2"
		},
		forbids_random = {
			"oper_flamable_mini_raid_1_park",
			"oper_flamable_mini_raid_1_roundabout"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_1_description",
				title_id = "rhinegold_mission_photo_1_title",
				photo = "intel_rhinegold_01"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_destroyed = self.missions.oper_flamable_mini_raid_1_destroyed
	self.missions.oper_flamable_mini_raid_1_roundabout = {
		icon_menu = "missions_operation_rhinegold_menu_1",
		xp = 2400,
		music_id = "random",
		audio_briefing_id = "mrs_white_or_mr1_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_1",
		level_id = "zone_germany_roundabout",
		mission_flag = "level_operation_02_mission_01",
		name_id = "menu_ger_oper_02_event_1_name",
		mission_id = "oper_flamable_mini_raid_1_roundabout",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_01",
		progress_text_id = "menu_ger_oper_rhinegold_event_1_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_1_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
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
		},
		forbids_random = {
			"oper_flamable_mini_raid_1_park",
			"oper_flamable_mini_raid_1_destroyed"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_1_description",
				title_id = "rhinegold_mission_photo_1_title",
				photo = "intel_rhinegold_01"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_1_roundabout = self.missions.oper_flamable_mini_raid_1_roundabout
	self.missions.oper_flamable_mini_raid_2_destroyed = {
		icon_menu = "missions_operation_rhinegold_menu_2",
		xp = 2200,
		music_id = "random",
		audio_briefing_id = "mrs_white_or_mr2_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_2",
		level_id = "zone_germany_destroyed_fuel",
		mission_flag = "level_operation_02_mission_02",
		name_id = "menu_ger_oper_02_event_2_name",
		mission_id = "oper_flamable_mini_raid_2_destroyed",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_02",
		progress_text_id = "menu_ger_oper_rhinegold_event_2_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_2_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_2_loading_text",
			image = "loading_rhinegold_02"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission1"
		},
		forbids_random = {
			"oper_flamable_mini_raid_2_roundabout"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_2_description",
				title_id = "rhinegold_mission_photo_2_title",
				photo = "intel_rhinegold_02"
			},
			{
				description_id = "rhinegold_mission_photo_3_description",
				title_id = "rhinegold_mission_photo_3_title",
				photo = "intel_rhinegold_03"
			},
			{
				description_id = "rhinegold_mission_photo_4_description",
				title_id = "rhinegold_mission_photo_4_title",
				photo = "intel_rhinegold_04"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_2_destroyed = self.missions.oper_flamable_mini_raid_2_destroyed
	self.missions.oper_flamable_mini_raid_2_roundabout = {
		icon_menu = "missions_operation_rhinegold_menu_2",
		xp = 2200,
		music_id = "random",
		audio_briefing_id = "mrs_white_or_mr2_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_2",
		level_id = "zone_germany_roundabout_fuel",
		mission_flag = "level_operation_02_mission_02",
		name_id = "menu_ger_oper_02_event_2_name",
		mission_id = "oper_flamable_mini_raid_2_roundabout",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_02",
		progress_text_id = "menu_ger_oper_rhinegold_event_2_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_2_progress_title",
		mission_state = OperationsTweakData.STATE_ZONE_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_2_loading_text",
			image = "loading_rhinegold_02"
		},
		excluded_continents = {
			"operation1mission1",
			"operation1mission2",
			"operation1mission3",
			"operation2mission1"
		},
		forbids_random = {
			"oper_flamable_mini_raid_2_destroyed"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_2_description",
				title_id = "rhinegold_mission_photo_2_title",
				photo = "intel_rhinegold_02"
			},
			{
				description_id = "rhinegold_mission_photo_3_description",
				title_id = "rhinegold_mission_photo_3_title",
				photo = "intel_rhinegold_03"
			},
			{
				description_id = "rhinegold_mission_photo_4_description",
				title_id = "rhinegold_mission_photo_4_title",
				photo = "intel_rhinegold_04"
			}
		}
	}
	self.missions.oper_flamable.events.mini_raid_2_roundabout = self.missions.oper_flamable_mini_raid_2_roundabout
	self.missions.oper_flamable_bridge = {
		icon_menu = "missions_operation_rhinegold_menu_3",
		xp = 2400,
		music_id = "ger_bridge",
		audio_briefing_id = "mrs_white_bridge_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_3",
		level_id = "ger_bridge",
		mission_flag = "level_operation_02_mission_03",
		name_id = "menu_ger_oper_02_event_3_name",
		mission_id = "oper_flamable_bridge",
		camp_objective_id = "obj_camp_goto_oper_rhinegold_03",
		progress_text_id = "menu_ger_oper_rhinegold_event_3_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_3_progress_title",
		dogtags = self.dogtag_types.medium,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_3_loading_text",
			image = "loading_rhinegold_03"
		},
		forbids_random = {
			"ger_bridge"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		},
		photos = {
			{
				description_id = "rhinegold_mission_photo_5_description",
				title_id = "rhinegold_mission_photo_5_title",
				photo = "intel_rhinegold_05"
			}
		}
	}
	self.missions.oper_flamable.events.bridge = self.missions.oper_flamable_bridge
	self.missions.oper_flamable_castle = {
		icon_menu = "missions_operation_rhinegold_menu_4",
		mission_id = "oper_flamable_castle",
		xp = 4000,
		music_id = "castle",
		audio_briefing_id = "mrs_white_castle_op_brief_long",
		icon_menu_big = "xp_events_missions_operation_rhinegold_4",
		level_id = "settlement",
		mission_flag = "level_operation_02_mission_04",
		name_id = "menu_ger_oper_02_event_4_name",
		start_in_stealth = true,
		camp_objective_id = "obj_camp_goto_oper_rhinegold_04",
		progress_text_id = "menu_ger_oper_rhinegold_event_4_progress_text",
		progress_title_id = "menu_ger_oper_rhinegold_event_4_progress_title",
		dogtags = self.dogtag_types.large,
		mission_state = OperationsTweakData.STATE_LOCATION_MISSION_SELECTED,
		job_type = OperationsTweakData.JOB_TYPE_RAID,
		loading = {
			text = "menu_ger_oper_rhinegold_event_4_loading_text",
			image = "loading_rhinegold_04"
		},
		forbids_random = {
			"settlement"
		},
		bounty_filters = {
			forbid_buffs = {
				BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN,
				BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED
			}
		}
	}
	self.missions.oper_flamable.events.castle = self.missions.oper_flamable_castle
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

	local function events_from_template(data)
		local events = {}

		for _, template in ipairs(data) do
			for _, job_id in ipairs(template) do
				local job_data = self.missions[job_id]

				if job_data then
					events[job_id] = deep_clone(job_data)
					events[job_id].mission_id = job_id
				end
			end
		end

		return events
	end

	local random_events_intel = {
		"spies_test",
		"spies_test",
		"bunker_test",
		"bunker_test",
		"hunters",
		"hunters",
		"settlement",
		"settlement",
		"radio_defense",
		"convoy",
		"convoy",
		"clear_skies_gold_rush",
		"clear_skies_gold_rush",
		"clear_skies_mini_raid_1_park",
		"clear_skies_mini_raid_1_destroyed",
		"clear_skies_mini_raid_1_roundabout",
		"oper_flamable_mini_raid_1_park",
		"oper_flamable_mini_raid_1_destroyed",
		"oper_flamable_mini_raid_1_roundabout"
	}
	local random_events_padding = {
		"radio_defense",
		"clear_skies_radio_defense",
		"clear_skies_gold_rush",
		"settlement",
		"tnd",
		"hunters",
		"convoy",
		"oper_flamable_bridge",
		"clear_skies_mini_raid_2_park",
		"clear_skies_mini_raid_2_destroyed",
		"spies_test",
		"bunker_test"
	}
	local random_events_reward = {
		"forest_gumpy",
		"fury_railway",
		"sto",
		"gold_rush",
		"kelly",
		"ger_bridge"
	}
	local random_events_finale = {
		"forest_bunker",
		"train_yard",
		"silo",
		"flakturm",
		"clear_skies_flakturm",
		"settlement",
		"oper_flamable_castle"
	}
	self.missions.random_short = {
		icon_hud = "op_random_short_hd",
		icon_menu = "op_random_short_lq",
		xp = 500,
		region = "germany",
		camp_objective_id = "obj_camp_goto_op_random_short",
		briefing_id = "menu_ger_op_random_short_desc",
		name_id = "menu_ger_op_random_short_hl",
		job_type = OperationsTweakData.JOB_TYPE_OPERATION,
		photos = {
			{
				description_id = "random_mission_photo_1_description",
				title_id = "random_mission_photo_1_title",
				photo = "intel_random_operation_01"
			},
			{
				description_id = "random_mission_photo_2_description",
				title_id = "random_mission_photo_2_title",
				photo = "intel_random_operation_02"
			}
		},
		loading = {
			text = "menu_ger_oper_rhinegold",
			image = "loading_rhinegold_00"
		},
		events_index_template = {
			random_events_padding,
			random_events_finale
		}
	}
	self.missions.random_short.events = events_from_template(self.missions.random_short.events_index_template)
	self.missions.random_medium = deep_clone(self.missions.random_short)
	self.missions.random_medium.name_id = "menu_ger_op_random_medium_hl"
	self.missions.random_medium.briefing_id = "menu_ger_op_random_medium_desc"
	self.missions.random_medium.camp_objective_id = "obj_camp_goto_op_random_medium"
	self.missions.random_medium.xp = 1800
	self.missions.random_medium.icon_hud = "op_random_medium_hd"
	self.missions.random_medium.icon_menu = "op_random_medium_lq"
	self.missions.random_medium.photos = {
		{
			description_id = "random_mission_photo_1_description",
			title_id = "random_mission_photo_1_title",
			photo = "intel_random_operation_01"
		},
		{
			description_id = "random_mission_photo_1_description",
			title_id = "random_mission_photo_1_title",
			photo = "intel_random_operation_01"
		},
		{
			description_id = "random_mission_photo_3_description",
			title_id = "random_mission_photo_3_title",
			photo = "intel_random_operation_03"
		},
		{
			description_id = "random_mission_photo_2_description",
			title_id = "random_mission_photo_2_title",
			photo = "intel_random_operation_02"
		}
	}
	self.missions.random_medium.events_index_template = {
		random_events_intel,
		random_events_padding,
		random_events_reward,
		random_events_finale
	}
	self.missions.random_medium.events = events_from_template(self.missions.random_medium.events_index_template)
	self.missions.random_long = deep_clone(self.missions.random_short)
	self.missions.random_long.name_id = "menu_ger_op_random_long_hl"
	self.missions.random_long.briefing_id = "menu_ger_op_random_long_desc"
	self.missions.random_long.camp_objective_id = "obj_camp_goto_op_random_long"
	self.missions.random_long.xp = 3000
	self.missions.random_long.icon_hud = "op_random_long_hd"
	self.missions.random_long.icon_menu = "op_random_long_lq"
	self.missions.random_long.photos = {
		{
			description_id = "random_mission_photo_1_description",
			title_id = "random_mission_photo_1_title",
			photo = "intel_random_operation_01"
		},
		{
			description_id = "random_mission_photo_1_description",
			title_id = "random_mission_photo_1_title",
			photo = "intel_random_operation_01"
		},
		{
			description_id = "random_mission_photo_3_description",
			title_id = "random_mission_photo_3_title",
			photo = "intel_random_operation_03"
		},
		{
			description_id = "random_mission_photo_1_description",
			title_id = "random_mission_photo_1_title",
			photo = "intel_random_operation_01"
		},
		{
			description_id = "random_mission_photo_3_description",
			title_id = "random_mission_photo_3_title",
			photo = "intel_random_operation_03"
		},
		{
			description_id = "random_mission_photo_2_description",
			title_id = "random_mission_photo_2_title",
			photo = "intel_random_operation_02"
		}
	}
	self.missions.random_long.events_index_template = {
		random_events_intel,
		random_events_padding,
		random_events_reward,
		random_events_padding,
		random_events_reward,
		random_events_finale
	}
	self.missions.random_long.events = events_from_template(self.missions.random_long.events_index_template)
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
		return self._loading_screens[level] or self._loading_screens.generic
	end
end

function OperationsTweakData:mission_data(mission_id)
	if not mission_id or not self.missions[mission_id] then
		Application:error("[OperationsTweakData:mission_data] There was no mission id or no missions for the id:", mission_id)

		return
	end

	local mission_data = deep_clone(self.missions[mission_id])
	mission_data.job_id = mission_id

	return mission_data
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

function OperationsTweakData:randomize_operation(operation_id, operation_data)
	operation_data = operation_data or self.missions[operation_id]
	local template = operation_data.events_index_template
	local calculated_index = {}
	local already_picked = {}

	for _, value in ipairs(template) do
		local picked = false

		while not picked do
			local index = math.floor(math.rand(#value)) + 1
			local mission_id = value[index]

			if not already_picked[mission_id] then
				already_picked[mission_id] = true

				table.insert(calculated_index, mission_id)

				local mission_data = operation_data.events[mission_id]

				if mission_data and mission_data.forbids_random then
					for _, forbid_id in ipairs(mission_data.forbids_random) do
						already_picked[forbid_id] = true
					end
				end

				picked = true
			end
		end
	end

	operation_data.events_index = calculated_index

	Application:debug("[OperationsTweakData:randomize_operation]", operation_id, inspect(calculated_index))
end

function OperationsTweakData:get_raid_id_from_raid_index(operation_id, raid_index)
	local operation = self.missions[operation_id]

	if operation ~= nil then
		local template = operation.events_index_template
		local rows = #template
		local i = math.floor(raid_index / rows) + 1
		local j = raid_index % rows + 1

		return template[i][j]
	end

	return ""
end

function OperationsTweakData:get_raid_index_from_raid_id(operation_id, raid_id)
	local operation = self.missions[operation_id]

	if operation ~= nil then
		local template = operation.events_index_template
		local rows = #template

		for i, value_i in ipairs(template) do
			for j, value_j in ipairs(value_i) do
				if value_j == raid_id then
					local index = (i - 1) * rows + j - 1

					return index
				end
			end
		end
	end

	return 0
end

function OperationsTweakData:get_operation_indexes_delimited(mission_id, mission_data)
	local events_index = (mission_data or self.missions[mission_id]).events_index

	return table.concat(events_index, "|")
end

function OperationsTweakData:set_operation_indexes_delimited(mission_id, delimited_string)
	self.missions[mission_id].events_index = string.split(delimited_string, "|")
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

function OperationsTweakData:get_all_mission_flags()
	local mission_flags = {}

	for _, mission in pairs(self.missions) do
		local flag = mission.mission_flag

		if flag and not table.contains(mission_flags, flag) then
			table.insert(mission_flags, flag)
		end
	end

	return mission_flags
end
