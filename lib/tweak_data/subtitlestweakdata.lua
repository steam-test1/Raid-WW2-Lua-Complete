SubtitlesTweakData = SubtitlesTweakData or class()

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

function SubtitlesTweakData:_init_intro_video()
	self["01_intro_v014"] = {
		{
			length = 3,
			time = 6,
			id = "01_intro_001"
		},
		{
			length = 4,
			time = 9,
			id = "01_intro_002"
		},
		{
			length = 5,
			time = 13,
			id = "01_intro_003"
		},
		{
			length = 4,
			time = 20,
			id = "01_intro_004"
		},
		{
			length = 5,
			time = 24,
			id = "01_intro_005"
		},
		{
			length = 5,
			time = 30,
			id = "01_intro_006"
		},
		{
			length = 4,
			time = 35,
			id = "01_intro_007"
		},
		{
			length = 5,
			time = 38,
			id = "01_intro_008"
		},
		{
			length = 4,
			time = 45,
			id = "01_intro_009"
		},
		{
			length = 4,
			time = 47,
			id = "01_intro_0010"
		},
		{
			length = 5,
			time = 51,
			id = "01_intro_0011"
		},
		{
			length = 5,
			time = 57,
			id = "01_intro_0012"
		},
		{
			length = 7,
			time = 63,
			id = "01_intro_0013"
		},
		{
			length = 6,
			time = 70,
			id = "01_intro_0014"
		},
		{
			length = 6,
			time = 77,
			id = "01_intro_0015"
		},
		{
			length = 5,
			time = 83,
			id = "01_intro_0016"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a3()
	self["05_credits_v003"] = {
		{
			length = 2,
			time = 0,
			id = "01_credits_001"
		},
		{
			length = 4,
			time = 2,
			id = "01_credits_002"
		},
		{
			length = 6,
			time = 2,
			id = "01_credits_003"
		},
		{
			length = 8,
			time = 2,
			id = "01_credits_004"
		},
		{
			length = 10,
			time = 2,
			id = "01_credits_005"
		},
		{
			length = 12,
			time = 2,
			id = "01_credits_006"
		},
		{
			length = 14,
			time = 2,
			id = "01_credits_007"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_b2()
	self["02_mission_brief_b2_assassination_v004"] = {
		{
			length = 8,
			time = 1,
			id = "b2_assassination_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_b4()
	self["02_mission_brief_b4_steal-valuables_cause-carnage_v004"] = {
		{
			length = 10,
			time = 1,
			id = "b4_steal-valuables_cause-carnage_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a1()
	self["02_mission_brief_a1_demolition_v005"] = {
		{
			length = 10,
			time = 1,
			id = "a1_demolition_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a2()
	self["02_mission_brief_a2_cause-carnage_v005"] = {
		{
			length = 10,
			time = 1,
			id = "a2_cause-carnage_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a3()
	self["02_mission_brief_a3_ambush_v005"] = {
		{
			length = 10,
			time = 1,
			id = "a3_ambush_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a4()
	self["02_mission_brief_a4_infiltration_v004"] = {
		{
			length = 10,
			time = 1,
			id = "a4_infiltration_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_a5()
	self["02_mission_brief_a5_rescue_v005"] = {
		{
			length = 10,
			time = 1,
			id = "a5_rescue_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_b1()
	self["02_mission_brief_b1_cause-carnage_v004"] = {
		{
			length = 10,
			time = 1,
			id = "b1_cause-carnage_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_b3()
	self["02_mission_brief_b3_steal-intel_v004"] = {
		{
			length = 10,
			time = 1,
			id = "b3_steal-intel_001"
		}
	}
end

function SubtitlesTweakData:_init_mission_brief_b5()
	self["02_mission_brief_b5_steal-valuables_cause-carnage_v004"] = {
		{
			length = 10,
			time = 1,
			id = "b5_steal-valuables_cause-carnage_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_1()
	self.s_01_throws_himself_v007 = {
		{
			length = 4,
			time = 9.05,
			id = "s_01_throws_himself_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_2()
	self.s_02_chickens_out_v007 = {
		{
			length = 4,
			time = 1,
			id = "S_02_Chickens_out_001"
		},
		{
			length = 4,
			time = 3.02,
			id = "S_02_Chickens_out_002"
		},
		{
			length = 4,
			time = 20.07,
			id = "S_02_Chickens_out_003"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_3()
	self.s_03_salutes_v006 = {
		{
			length = 4,
			time = 1,
			id = "S_03_salutes_001"
		},
		{
			length = 4,
			time = 16,
			id = "S_03_salutes_002"
		},
		{
			length = 4,
			time = 18.1,
			id = "S_03_salutes_003"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_4()
	self.s_04_shoots_and_miss_v008 = {
		{
			length = 4,
			time = 1,
			id = "S_04_Shoots_and_miss_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_5()
	self.s_05_crunches_bones_v006 = {
		{
			length = 4,
			time = 1,
			id = "S_05_Crunches_bones_001"
		},
		{
			length = 4,
			time = 3.2,
			id = "S_05_Crunches_bones_002"
		},
		{
			length = 4,
			time = 7.01,
			id = "S_05_Crunches_bones_003"
		},
		{
			length = 4,
			time = 17,
			id = "S_05_Crunches_bones_004"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_6()
	self.s_06_plays_with_tin_men_v006 = {
		{
			length = 4,
			time = 3.14,
			id = "S_06_Plays_with_tin_men_001"
		},
		{
			length = 4,
			time = 8.13,
			id = "S_06_Plays_with_tin_men_002"
		},
		{
			length = 4,
			time = 13.21,
			id = "S_06_Plays_with_tin_men_003"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_7()
	self.s_07_cries_tannenbaum_v007 = {}
end

function SubtitlesTweakData:_init_debrief_success_8()
	self.s_08_chess_v008 = {
		{
			length = 4,
			time = 4.07,
			id = "S_08_Chess_001"
		},
		{
			length = 4,
			time = 15.21,
			id = "S_08_Chess_002"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_9()
	self.s_09_is_having_a_reverie_v007 = {
		{
			length = 4,
			time = 1,
			id = "S_09_is_having_a_reverie_001"
		},
		{
			length = 4,
			time = 2.08,
			id = "S_09_is_having_a_reverie_002"
		},
		{
			length = 4,
			time = 17.18,
			id = "S_09_is_having_a_reverie_003"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_10()
	self.s_10_colours_a_map_v009 = {}
end

function SubtitlesTweakData:_init_debrief_success_11()
	self.s_11_swears_v005 = {
		{
			length = 4,
			time = 8.03,
			id = "S_11_swears_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_12()
	self.s_12_plays_with_tanks_v005 = {
		{
			length = 4,
			time = 15.14,
			id = "S_12_plays_with_tanks_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_13()
	self.s_13_flips_a_table_v007 = {
		{
			length = 4,
			time = 10.22,
			id = "S_13_flips_a_table_001"
		},
		{
			length = 4,
			time = 12.17,
			id = "S_13_flips_a_table_002"
		}
	}
end

function SubtitlesTweakData:_init_debrief_success_14()
	self.s_14_moustache_v006 = {
		{
			length = 4,
			time = 8.05,
			id = "S_14_moustache_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_1()
	self.f_01_edelweiss_v007 = {}
end

function SubtitlesTweakData:_init_debrief_failure_2()
	self.f_02_sizzles_v007 = {}
end

function SubtitlesTweakData:_init_debrief_failure_3()
	self.f_03_toasts_v008 = {
		{
			length = 4,
			time = 5.04,
			id = "F_03_toasts_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_4()
	self.f_04_misunderstands_v008 = {
		{
			length = 4,
			time = 1,
			id = "F_04_misunderstands_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_5()
	self.f_05_hugs_the_world_v008 = {
		{
			length = 4,
			time = 1.12,
			id = "F_05_hugs_the_world_001"
		},
		{
			length = 4,
			time = 17.04,
			id = "F_05_hugs_the_world_002"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_6()
	self.f_06_tin_soldiers_v008 = {
		{
			length = 4,
			time = 11,
			id = "F_06_tin_soldiers_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_7()
	self.f_07_told_you_so_v008 = {
		{
			length = 4,
			time = 1,
			id = "F_07_told_you_so_001"
		},
		{
			length = 4,
			time = 6.04,
			id = "F_07_told_you_so_002"
		},
		{
			length = 4,
			time = 9.18,
			id = "F_07_told_you_so_003"
		},
		{
			length = 4,
			time = 16.17,
			id = "F_07_told_you_so_004"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_8()
	self.f_08_pumps_his_fists_v008 = {}
end

function SubtitlesTweakData:_init_debrief_failure_9()
	self.f_09_bras_dhonneur_v008 = {
		{
			length = 4,
			time = 1,
			id = "F_09_bras_dhonneur_001"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_10()
	self.f_10_executes_v008 = {
		{
			length = 4,
			time = 9.01,
			id = "F_10_executes_001"
		},
		{
			length = 4,
			time = 12.09,
			id = "F_10_executes_002"
		}
	}
end

function SubtitlesTweakData:_init_debrief_failure_11()
	self.f_11_sings_v007 = {
		{
			length = 4,
			time = 4.22,
			id = "F_11_sings_001"
		},
		{
			length = 4,
			time = 10.21,
			id = "F_11_sings_002"
		}
	}
end
