SubtitlesTweakData = SubtitlesTweakData or class()

-- Lines 3-48
function SubtitlesTweakData:init()
	self:_init_intro_video()
	self:_init_mission_brief_a1()
	self:_init_mission_brief_a2()
	self:_init_mission_brief_a3()
	self:_init_mission_brief_a4()
	self:_init_mission_brief_a5()
	self:_init_mission_brief_b1()
	self:_init_mission_brief_b2()
	self:_init_mission_brief_b3()
	self:_init_mission_brief_b4()
	self:_init_mission_brief_b5()
	self:_init_debrief_success_1()
	self:_init_debrief_success_2()
	self:_init_debrief_success_3()
	self:_init_debrief_success_4()
	self:_init_debrief_success_5()
	self:_init_debrief_success_6()
	self:_init_debrief_success_7()
	self:_init_debrief_success_8()
	self:_init_debrief_success_9()
	self:_init_debrief_success_10()
	self:_init_debrief_success_11()
	self:_init_debrief_success_12()
	self:_init_debrief_success_13()
	self:_init_debrief_success_14()
	self:_init_debrief_failure_1()
	self:_init_debrief_failure_2()
	self:_init_debrief_failure_3()
	self:_init_debrief_failure_4()
	self:_init_debrief_failure_5()
	self:_init_debrief_failure_6()
	self:_init_debrief_failure_7()
	self:_init_debrief_failure_8()
	self:_init_debrief_failure_9()
	self:_init_debrief_failure_10()
	self:_init_debrief_failure_11()
end

-- Lines 52-70
function SubtitlesTweakData:get_subtitle(movie, time)
	local split_movie_path = string.split(movie, "/")
	local movie_name = split_movie_path[#split_movie_path]
	local subtitle_data = self[movie_name]

	if not subtitle_data then
		Application:error("[SubtitlesTweakData][get_subtitle] Movie ", movie, " not in SubtitlesTweakData")

		return
	end

	for _, subtitle in ipairs(subtitle_data) do
		if subtitle.time < time and time < subtitle.time + subtitle.length then
			return managers.localization:text(subtitle.id)
		end
	end

	return ""
end

-- Lines 74-158
function SubtitlesTweakData:_init_intro_video()
	self["01_intro_v014"] = {
		{
			id = "01_intro_001",
			time = 6,
			length = 3
		},
		{
			id = "01_intro_002",
			time = 9,
			length = 4
		},
		{
			id = "01_intro_003",
			time = 13,
			length = 5
		},
		{
			id = "01_intro_004",
			time = 20,
			length = 4
		},
		{
			id = "01_intro_005",
			time = 24,
			length = 5
		},
		{
			id = "01_intro_006",
			time = 30,
			length = 5
		},
		{
			id = "01_intro_007",
			time = 35,
			length = 4
		},
		{
			id = "01_intro_008",
			time = 38,
			length = 5
		},
		{
			id = "01_intro_009",
			time = 45,
			length = 4
		},
		{
			id = "01_intro_0010",
			time = 47,
			length = 4
		},
		{
			id = "01_intro_0011",
			time = 51,
			length = 5
		},
		{
			id = "01_intro_0012",
			time = 57,
			length = 5
		},
		{
			id = "01_intro_0013",
			time = 63,
			length = 7
		},
		{
			id = "01_intro_0014",
			time = 70,
			length = 6
		},
		{
			id = "01_intro_0015",
			time = 77,
			length = 6
		},
		{
			id = "01_intro_0016",
			time = 83,
			length = 5
		}
	}
end

-- Lines 160-198
function SubtitlesTweakData:_init_mission_brief_a3()
	self["05_credits_v003"] = {
		{
			id = "01_credits_001",
			time = 0,
			length = 2
		},
		{
			id = "01_credits_002",
			time = 2,
			length = 4
		},
		{
			id = "01_credits_003",
			time = 2,
			length = 6
		},
		{
			id = "01_credits_004",
			time = 2,
			length = 8
		},
		{
			id = "01_credits_005",
			time = 2,
			length = 10
		},
		{
			id = "01_credits_006",
			time = 2,
			length = 12
		},
		{
			id = "01_credits_007",
			time = 2,
			length = 14
		}
	}
end

-- Lines 203-211
function SubtitlesTweakData:_init_mission_brief_b2()
	self["02_mission_brief_b2_assassination_v004"] = {
		{
			id = "b2_assassination_001",
			time = 1,
			length = 8
		}
	}
end

-- Lines 213-221
function SubtitlesTweakData:_init_mission_brief_b4()
	self["02_mission_brief_b4_steal-valuables_cause-carnage_v004"] = {
		{
			id = "b4_steal-valuables_cause-carnage_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 223-231
function SubtitlesTweakData:_init_mission_brief_a1()
	self["02_mission_brief_a1_demolition_v005"] = {
		{
			id = "a1_demolition_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 233-241
function SubtitlesTweakData:_init_mission_brief_a2()
	self["02_mission_brief_a2_cause-carnage_v005"] = {
		{
			id = "a2_cause-carnage_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 243-251
function SubtitlesTweakData:_init_mission_brief_a3()
	self["02_mission_brief_a3_ambush_v005"] = {
		{
			id = "a3_ambush_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 253-261
function SubtitlesTweakData:_init_mission_brief_a4()
	self["02_mission_brief_a4_infiltration_v004"] = {
		{
			id = "a4_infiltration_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 263-271
function SubtitlesTweakData:_init_mission_brief_a5()
	self["02_mission_brief_a5_rescue_v005"] = {
		{
			id = "a5_rescue_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 273-281
function SubtitlesTweakData:_init_mission_brief_b1()
	self["02_mission_brief_b1_cause-carnage_v004"] = {
		{
			id = "b1_cause-carnage_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 283-291
function SubtitlesTweakData:_init_mission_brief_b3()
	self["02_mission_brief_b3_steal-intel_v004"] = {
		{
			id = "b3_steal-intel_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 293-301
function SubtitlesTweakData:_init_mission_brief_b5()
	self["02_mission_brief_b5_steal-valuables_cause-carnage_v004"] = {
		{
			id = "b5_steal-valuables_cause-carnage_001",
			time = 1,
			length = 10
		}
	}
end

-- Lines 304-312
function SubtitlesTweakData:_init_debrief_success_1()
	self.s_01_throws_himself_v007 = {
		{
			id = "s_01_throws_himself_001",
			time = 9.05,
			length = 4
		}
	}
end

-- Lines 314-332
function SubtitlesTweakData:_init_debrief_success_2()
	self.s_02_chickens_out_v007 = {
		{
			id = "S_02_Chickens_out_001",
			time = 1,
			length = 4
		},
		{
			id = "S_02_Chickens_out_002",
			time = 3.02,
			length = 4
		},
		{
			id = "S_02_Chickens_out_003",
			time = 20.07,
			length = 4
		}
	}
end

-- Lines 334-352
function SubtitlesTweakData:_init_debrief_success_3()
	self.s_03_salutes_v006 = {
		{
			id = "S_03_salutes_001",
			time = 1,
			length = 4
		},
		{
			id = "S_03_salutes_002",
			time = 16,
			length = 4
		},
		{
			id = "S_03_salutes_003",
			time = 18.1,
			length = 4
		}
	}
end

-- Lines 354-362
function SubtitlesTweakData:_init_debrief_success_4()
	self.s_04_shoots_and_miss_v008 = {
		{
			id = "S_04_Shoots_and_miss_001",
			time = 1,
			length = 4
		}
	}
end

-- Lines 364-387
function SubtitlesTweakData:_init_debrief_success_5()
	self.s_05_crunches_bones_v006 = {
		{
			id = "S_05_Crunches_bones_001",
			time = 1,
			length = 4
		},
		{
			id = "S_05_Crunches_bones_002",
			time = 3.2,
			length = 4
		},
		{
			id = "S_05_Crunches_bones_003",
			time = 7.01,
			length = 4
		},
		{
			id = "S_05_Crunches_bones_004",
			time = 17,
			length = 4
		}
	}
end

-- Lines 389-407
function SubtitlesTweakData:_init_debrief_success_6()
	self.s_06_plays_with_tin_men_v006 = {
		{
			id = "S_06_Plays_with_tin_men_001",
			time = 3.14,
			length = 4
		},
		{
			id = "S_06_Plays_with_tin_men_002",
			time = 8.13,
			length = 4
		},
		{
			id = "S_06_Plays_with_tin_men_003",
			time = 13.21,
			length = 4
		}
	}
end

-- Lines 409-412
function SubtitlesTweakData:_init_debrief_success_7()
	self.s_07_cries_tannenbaum_v007 = {}
end

-- Lines 414-427
function SubtitlesTweakData:_init_debrief_success_8()
	self.s_08_chess_v008 = {
		{
			id = "S_08_Chess_001",
			time = 4.07,
			length = 4
		},
		{
			id = "S_08_Chess_002",
			time = 15.21,
			length = 4
		}
	}
end

-- Lines 429-447
function SubtitlesTweakData:_init_debrief_success_9()
	self.s_09_is_having_a_reverie_v007 = {
		{
			id = "S_09_is_having_a_reverie_001",
			time = 1,
			length = 4
		},
		{
			id = "S_09_is_having_a_reverie_002",
			time = 2.08,
			length = 4
		},
		{
			id = "S_09_is_having_a_reverie_003",
			time = 17.18,
			length = 4
		}
	}
end

-- Lines 449-452
function SubtitlesTweakData:_init_debrief_success_10()
	self.s_10_colours_a_map_v009 = {}
end

-- Lines 454-462
function SubtitlesTweakData:_init_debrief_success_11()
	self.s_11_swears_v005 = {
		{
			id = "S_11_swears_001",
			time = 8.03,
			length = 4
		}
	}
end

-- Lines 464-472
function SubtitlesTweakData:_init_debrief_success_12()
	self.s_12_plays_with_tanks_v005 = {
		{
			id = "S_12_plays_with_tanks_001",
			time = 15.14,
			length = 4
		}
	}
end

-- Lines 474-487
function SubtitlesTweakData:_init_debrief_success_13()
	self.s_13_flips_a_table_v007 = {
		{
			id = "S_13_flips_a_table_001",
			time = 10.22,
			length = 4
		},
		{
			id = "S_13_flips_a_table_002",
			time = 12.17,
			length = 4
		}
	}
end

-- Lines 489-497
function SubtitlesTweakData:_init_debrief_success_14()
	self.s_14_moustache_v006 = {
		{
			id = "S_14_moustache_001",
			time = 8.05,
			length = 4
		}
	}
end

-- Lines 501-504
function SubtitlesTweakData:_init_debrief_failure_1()
	self.f_01_edelweiss_v007 = {}
end

-- Lines 506-509
function SubtitlesTweakData:_init_debrief_failure_2()
	self.f_02_sizzles_v007 = {}
end

-- Lines 511-519
function SubtitlesTweakData:_init_debrief_failure_3()
	self.f_03_toasts_v008 = {
		{
			id = "F_03_toasts_001",
			time = 5.04,
			length = 4
		}
	}
end

-- Lines 521-529
function SubtitlesTweakData:_init_debrief_failure_4()
	self.f_04_misunderstands_v008 = {
		{
			id = "F_04_misunderstands_001",
			time = 1,
			length = 4
		}
	}
end

-- Lines 531-544
function SubtitlesTweakData:_init_debrief_failure_5()
	self.f_05_hugs_the_world_v008 = {
		{
			id = "F_05_hugs_the_world_001",
			time = 1.12,
			length = 4
		},
		{
			id = "F_05_hugs_the_world_002",
			time = 17.04,
			length = 4
		}
	}
end

-- Lines 546-554
function SubtitlesTweakData:_init_debrief_failure_6()
	self.f_06_tin_soldiers_v008 = {
		{
			id = "F_06_tin_soldiers_001",
			time = 11,
			length = 4
		}
	}
end

-- Lines 556-579
function SubtitlesTweakData:_init_debrief_failure_7()
	self.f_07_told_you_so_v008 = {
		{
			id = "F_07_told_you_so_001",
			time = 1,
			length = 4
		},
		{
			id = "F_07_told_you_so_002",
			time = 6.04,
			length = 4
		},
		{
			id = "F_07_told_you_so_003",
			time = 9.18,
			length = 4
		},
		{
			id = "F_07_told_you_so_004",
			time = 16.17,
			length = 4
		}
	}
end

-- Lines 581-584
function SubtitlesTweakData:_init_debrief_failure_8()
	self.f_08_pumps_his_fists_v008 = {}
end

-- Lines 586-594
function SubtitlesTweakData:_init_debrief_failure_9()
	self.f_09_bras_dhonneur_v008 = {
		{
			id = "F_09_bras_dhonneur_001",
			time = 1,
			length = 4
		}
	}
end

-- Lines 596-609
function SubtitlesTweakData:_init_debrief_failure_10()
	self.f_10_executes_v008 = {
		{
			id = "F_10_executes_001",
			time = 9.01,
			length = 4
		},
		{
			id = "F_10_executes_002",
			time = 12.09,
			length = 4
		}
	}
end

-- Lines 611-624
function SubtitlesTweakData:_init_debrief_failure_11()
	self.f_11_sings_v007 = {
		{
			id = "F_11_sings_001",
			time = 4.22,
			length = 4
		},
		{
			id = "F_11_sings_002",
			time = 10.21,
			length = 4
		}
	}
end
