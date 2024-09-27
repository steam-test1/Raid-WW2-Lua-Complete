local mvec3_set_z = mvector3.set_z
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local tmp_vec1 = Vector3()
local ids_aim = Idstring("aim")
CopActionAct = CopActionAct or class()
CopActionAct._ACT_CATEGORY_INDEX = {
	"script",
	"enemy_spawn",
	"civilian_spawn",
	"SO"
}
CopActionAct._act_redirects = {
	script = {
		"attached_collar_enter",
		"suppressed_reaction",
		"surprised",
		"hands_up",
		"hands_back",
		"tied",
		"stand_tied",
		"tied_all_in_one",
		"drop",
		"panic",
		"idle",
		"halt",
		"stand",
		"crouch",
		"revive",
		"untie",
		"arrest",
		"arrest_call",
		"gesture_stop",
		"sabotage_device_low",
		"sabotage_device_mid",
		"sabotage_device_high",
		"so_civ_dummy_act_loop",
		"dizzy"
	},
	enemy_spawn = {
		"e_sp_para_jump_100m",
		"e_sp_freefall_150m_para_jump_50m",
		"e_sp_down_6m_drop",
		"e_sp_climb_down_tiger_tank",
		"e_sp_climb_up_tiger_tank",
		"e_sp_up_1m_dwn_4_5m_var2",
		"e_sp_up_1m_dwn_4_5m_var3",
		"e_sp_dwn_6m",
		"e_sp_dwn_6m_var1",
		"e_sp_hurt_stairs",
		"e_sp_death_stairs",
		"e_sp_door_tackle",
		"e_sp_wall_down_3_7m_var1",
		"e_sp_wall_down_3_7m_var2",
		"e_sp_wall_down_3_7m_var3",
		"e_sp_wall_down_3_7m_var4",
		"e_sp_exit_crawl_sommelier",
		"e_sp_wall_down_1m_fwd_2m_down_3_3m",
		"e_sp_out_truck_l",
		"e_sp_fall_back",
		"e_sp_up_1_down_4m",
		"e_sp_down_1_30m",
		"e_sp_down_1_30m_var1",
		"e_sp_2_50m_fwd_1_30m_down",
		"e_sp_2_50m_fwd_1_30m_down_var1",
		"e_sp_10m_turn_r_2m",
		"e_sp_10m_turn_r_2m_var1",
		"e_sp_fwd_9m",
		"e_sp_fwd_9m_var1",
		"e_sp_fwd_9m_var2",
		"e_sp_fwd_9m_var3",
		"e_sp_fwd_9m_var4",
		"e_sp_fwd_9m_var5",
		"e_sp_up_3m_down_1m",
		"e_sp_up_3m_down_1m_var1",
		"e_sp_up_3m_down_1m_var2",
		"e_sp_up_3m_down_1m_var3",
		"e_sp_up_3_down_1_2m",
		"e_sp_up_3_down_1_7m",
		"e_sp_climb_over_1_75m",
		"e_sp_climb_over_1_75m_var1",
		"e_sp_climb_over_1_75m_var2",
		"e_sp_climb_over_1_75m_var3",
		"e_sp_climb_over_1_75m_var4",
		"e_sp_run_fwd_on_fire_die_var1",
		"e_sp_run_fwd_on_fire_die_var2",
		"e_sp_fall_out_of_bunker_fire_dth_var1",
		"e_sp_fall_out_of_bunker_fire_dth_var2",
		"e_sp_climb_over_2m_var1",
		"e_sp_climb_over_2m_var2",
		"e_sp_climb_over_2m_var3",
		"e_sp_climb_over_3m_var2",
		"e_sp_climb_over_3m_var3",
		"e_sp_climb_over_3m_var4",
		"e_sp_climb_over_2_30m",
		"e_sp_climb_over_2_30m_var1",
		"e_sp_climb_over_2_30m_var2",
		"e_sp_climb_over_2_30m_var3",
		"e_sp_turn_up_1m_down_4m",
		"e_sp_turn_up_1m_down_4m_var1",
		"e_sp_turn_up_1m_down_4m_var2",
		"e_sp_turn_up_1m_down_4m_var3",
		"e_sp_turn_r_2m_down_4m",
		"e_sp_turn_r_2m_down_4m_var1",
		"e_sp_turn_r_2m_down_4m_var2",
		"e_sp_turn_r_2m_down_4m_var3",
		"e_sp_turn_l_3m_fwd_up_1m_down_4m",
		"e_sp_turn_l_3m_fwd_up_1m_down_4m_var1",
		"e_sp_turn_l_3m_fwd_up_1m_down_4m_var2",
		"e_sp_turn_l_3m_fwd_up_1m_down_4m_var3",
		"e_sp_turn_l_8m_fwd_down_4m",
		"e_sp_turn_l_8m_fwd_down_4m_var1",
		"e_sp_turn_l_8m_fwd_down_4m_var2",
		"e_sp_turn_l_8m_fwd_down_4m_var3",
		"e_sp_turn_r_up_1m_down_5m",
		"e_sp_turn_r_up_1m_down_5m_var1",
		"e_sp_turn_r_up_1m_down_5m_var2",
		"e_sp_turn_r_up_1m_down_5m_var3",
		"e_sp_turn_l_fwd_2m_up_1m_down_4m",
		"e_sp_turn_l_fwd_2m_up_1m_down_4m_var1",
		"e_sp_turn_l_fwd_2m_up_1m_down_4m_var2",
		"e_sp_turn_l_fwd_2m_up_1m_down_4m_var3",
		"e_sp_turn_l_fwd_up_1m_down_4m",
		"e_sp_turn_l_fwd_up_1m_down_4m_var1",
		"e_sp_turn_l_fwd_up_1m_down_4m_var2",
		"e_sp_turn_l_fwd_up_1m_down_4m_var3",
		"e_sp_fwd_turn_l_over_1m",
		"e_sp_fwd_turn_l_over_1m_var1",
		"e_sp_fwd_turn_l_over_1m_var2",
		"e_sp_fwd_turn_l_over_1m_var3",
		"e_sp_fwd_turn_l_over_1m_var4",
		"e_sp_fwd_turn_l_over_1m_var5",
		"e_sp_dropbag",
		"e_sp_exitcar_right",
		"e_sp_car_exit_to_cbt_front_l",
		"e_sp_car_exit_to_cbt_front_r",
		"e_sp_car_exit_to_cbt_front_l_var2",
		"e_sp_car_exit_to_cbt_front_r_var2",
		"e_sp_car_exit_to_cbt_front_l_var3",
		"e_sp_car_exit_to_cbt_front_r_var3",
		"e_sp_jump_down_heli_cbt_right",
		"e_sp_jump_down_heli_cbt_left",
		"e_sp_hurt_from_truck",
		"e_sp_aim_rifle_crh",
		"e_sp_aim_rifle_std",
		"e_sp_crh_to_std_rifle",
		"e_sp_down_12m",
		"e_sp_down_16m",
		"e_sp_kick_enter",
		"e_sp_kick_enter_bulldozer",
		"e_sp_fwd_4m_jump_dwn_4_5m",
		"e_sp_down_17m",
		"e_sp_down_17m_var2",
		"e_sp_run_jump_far",
		"e_sp_up_1_down_9_25m",
		"e_sp_up_2_75_down_1_25m",
		"e_sp_up_1_down_9m",
		"e_sp_up_1_5_down_9m",
		"e_sp_up_1_down_13m",
		"e_sp_down_8m",
		"e_sp_down_12m_var2",
		"e_sp_down_8m_var2",
		"e_sp_down_4m_var2",
		"e_sp_down_4m_var1",
		"e_sp_down_9_6m",
		"e_sp_repel_into_window",
		"e_sp_down_16m_right",
		"e_sp_down_16m_left",
		"e_sp_up_1_down_9m_var2",
		"e_sp_up_1_down_9m_var3",
		"e_sp_down_8m_var3",
		"e_sp_over_3_35m",
		"e_sp_over_1m_dwn_12m",
		"e_sp_climb_over_4m",
		"e_sp_dwn_22m",
		"e_sp_dwn_21m",
		"e_sp_up_ 2_75_fwd_2_7_dwn_2_75m",
		"e_sp_over_3m",
		"e_sp_over_3m_fwd_4m",
		"e_sp_over_3m_fwd_2m_roll",
		"e_sp_run_2m_turn_r_10m",
		"e_sp_run_2m_turn_l_10m",
		"e_sp_run_2m_turn_r_14m",
		"e_sp_run_2m_turn_l_14m",
		"e_sp_armored_truck_1st",
		"e_sp_armored_truck_2nd",
		"e_sp_armored_truck_3rd",
		"e_sp_dizzy_stand",
		"e_sp_dizzy_get_up",
		"e_sp_dizzy_walk_left",
		"e_sp_dizzy_walk_right",
		"e_sp_dizzy_fall_get_up",
		"e_sp_dizzy_stand_v2",
		"e_sp_dizzy_walk_inplace",
		"e_sp_dizzy_look_around",
		"e_sp_car_exit_ntrl_front_r",
		"e_sp_car_exit_ntrl_front_l",
		"e_sp_dwn_5m",
		"e_sp_dwn_10m",
		"e_sp_dwn_11m_var2",
		"e_sp_fwd_5m_dwn_11m",
		"e_sp_down_5_5m",
		"e_sp_down_6m",
		"e_sp_dwn_10_25m",
		"e_sp_climb_over_2m",
		"e_sp_dwn_11m",
		"e_sp_swing_dwn_7m_window",
		"e_sp_over_1m_dwn_7m",
		"e_sp_over_1m_swing_dwn_7m_window",
		"e_sp_up_ledge",
		"e_sp_clk_3m_dwn_vent",
		"e_sp_clk_exit_vent_1_5m",
		"e_sp_clk_3_5m_dwn_vent",
		"e_sp_clk_3_5m_dwn_vent_var2",
		"e_sp_clk_up_manhole",
		"e_sp_clk_up_water",
		"e_sp_clk_over_2_5m",
		"e_sp_clk_jump_dwn_5m_heli_l",
		"e_sp_barn_door_open_l",
		"e_sp_barn_door_open_r",
		"e_sp_clk_4_5m_dwn_vent",
		"e_sp_unarmed_helicopter_step_out1",
		"e_sp_unarmed_helicopter_step_out2",
		"e_sp_bulldozer_turn_chair",
		"e_sp_up_1m_dwn_4_5m_roll",
		"e_sp_up_1m_dwn_4_5m",
		"e_sp_elevator_escape"
	},
	civilian_spawn = {
		"cm_sp_dj_loop",
		"cm_sp_stand_idle",
		"cm_sp_stand_waiting",
		"cm_sp_stand_arms_crossed",
		"cm_sp_sit_normal_table",
		"cm_sp_sit_legs_crossed",
		"cm_sp_male_stripper",
		"cm_sp_smoking_left1",
		"cm_sp_standing_talk1",
		"cm_sp_lean_desk_1_2m_01",
		"cm_sp_sit_table_var1_01",
		"cm_sp_sit_table_var2_01",
		"cm_sp_talking_upset",
		"cm_sp_drunk_idle",
		"cm_sp_lean_wall_right",
		"cm_sp_talking_normal",
		"cm_sp_waiting_sway",
		"cm_sp_bar_standing",
		"cm_sp_smoking_right1",
		"cm_sp_lean_wall1",
		"cm_sp_lean_wall_ass1",
		"cm_sp_phone1",
		"cm_sp_phone2",
		"cm_sp_stretch1",
		"cm_sp_sit_idle1",
		"cm_sp_sit_legs_crossed_var2",
		"cm_sp_standing_idle_var2",
		"cm_sp_look_look_semi_down",
		"cm_sp_look_window",
		"cm_sp_sit_feet_table",
		"cm_sp_listen_music_idle",
		"cm_sp_one_hand_on_hip",
		"cm_sp_hands_on_hip",
		"cm_sp_stand_type",
		"cm_sp_window_observer",
		"cm_sp_sit_high_chair",
		"cm_sp_sit_talk_table",
		"cm_sp_sit_with_wounded",
		"cm_sp_recieving_cpr",
		"cm_sp_wounded_lying2",
		"cm_sp_gives_cpr",
		"cm_sp_wounded_lying",
		"cm_sp_accident_scene",
		"cm_sp_firefighter",
		"cm_sp_investigate_hi",
		"cm_sp_investigate_low",
		"cm_sp_dice_player",
		"cm_sp_slotmachine",
		"cm_sp_take_cover_hide",
		"cf_sp_accident_scene",
		"cm_sp_clean_hi",
		"cm_sp_drink_stand_table_1m",
		"cm_sp_sit_smoke",
		"cm_sp_walk_phone",
		"cm_sp_clean_floor",
		"cm_sp_look_at_phone",
		"cf_sp_dealer_generic",
		"cm_sp_bbqing",
		"cm_sp_boxing_bag_hold",
		"cm_sp_boxing_bag_punch",
		"cm_sp_casino_guest_sit_var2",
		"cm_spawn_prisonvan_var1",
		"cm_spawn_prisonvan_var4",
		"cm_spawn_prisonvan_var5",
		"cm_spawn_prisonvan_var8",
		"cm_spawn_prisonvan_var9",
		"cm_spawn_prisonvan_var10",
		"cm_sp_fastfood_worker",
		"cf_sp_casino_guest_sit_var2",
		"cf_sp_dealer_cards",
		"cf_sp_dealer_roulette",
		"cf_sp_clean_hi",
		"cf_sp_stand_idle_var1",
		"cf_sp_stand_desk_1m",
		"cf_sp_stand_desk_1m",
		"cf_sp_look_window_var1",
		"cf_sp_sitting_var1",
		"cf_sp_stand_look_up",
		"cf_sp_stand_look_down",
		"cf_sp_dance_slow",
		"cf_sp_dance_sexy",
		"cf_sp_sit_hands_on_table_talk",
		"cf_sp_sit_table_hands_in_knee",
		"cf_sp_sit_high_chair",
		"cf_sp_window_observer",
		"cf_sp_stand_type",
		"cf_sp_sms_phone_var1",
		"cf_sp_smoking_var1",
		"cf_sp_pole_dancer_expert",
		"cf_sp_pole_dancer_basic",
		"cf_sp_stand_hands_on_hip_idle",
		"cf_sp_stand_listen_music",
		"cf_sp_stand_one_hand_on_hip",
		"cf_sp_stand_talk_normal",
		"cf_sp_stand_talk_upset",
		"cf_sp_stand_talk_calm",
		"cf_sp_stand_arms_crossed",
		"cf_sp_lean_bar_desk",
		"cf_sp_lean_wall_right",
		"cf_sp_lean_wall_back",
		"cf_sp_lying_hurt",
		"cf_sp_lying_drugged_sleep",
		"cf_sp_sunbed",
		"cf_sp_slot_machine",
		"cf_sp_drink_sit",
		"cf_sp_piano_player",
		"cf_sp_stand_idle_var3",
		"sstash_spawn_crashed_limo1",
		"sstash_spawn_crashed_limo2",
		"sstash_spawn_crashed_limo3",
		"sstash_spawn_crashed_limo4",
		"spawn_prisonvan_var1",
		"spawn_prisonvan_var4",
		"spawn_prisonvan_var5",
		"spawn_prisonvan_var8",
		"spawn_prisonvan_var9",
		"spawn_prisonvan_var10",
		"spawn_crawl_var1"
	},
	SO = {
		"animation_test",
		"animation_test2",
		"e_nl_run_dunk_hood",
		"e_nl_plant_run_through",
		"e_nl_open_door",
		"e_nl_climb_over_2m",
		"e_nl_jump_over_1m_var1",
		"e_nl_jump_over_1m_var2",
		"e_nl_jump_down_2_5m",
		"e_nl_down_5_5m",
		"e_nl_down_5_5m_var2",
		"e_nl_jump_dwn_1_4m_fwd_2_35m",
		"e_nl_down_4m",
		"e_nl_climb_over_3m",
		"e_nl_up_4m",
		"e_nl_up_1m_dwn_9m",
		"e_nl_over_3m_fwd_4m",
		"e_nl_over_and_fwd_1m_var2",
		"e_nl_over_and_fwd_1m",
		"e_nl_up_8m_right_2m_over_1m",
		"e_nl_up_8m_left_2m_over_1m",
		"e_nl_under_0_7m",
		"e_nl_climb_up_4_75m",
		"e_nl_climb_up_2_2m",
		"e_nl_over_3m_fwd_2m_roll",
		"e_nl_up_4m_down_1m",
		"e_nl_up_0_8_down_1_25m",
		"e_nl_kick_enter",
		"e_nl_kick_enter_special",
		"e_nl_up_1_75m",
		"e_nl_up_1_75m_var1",
		"e_nl_crawl_3_5m",
		"e_nl_up_1_5m_dwn_1m",
		"e_nl_down_1_75m",
		"e_nl_up_5_down_1m",
		"e_nl_up_1_25_down_0_8m",
		"e_nl_down_4_fwd_4m",
		"e_nl_fwd_4m",
		"e_nl_fwd_2m",
		"e_nl_up_1_down_3m",
		"e_nl_up_1_down_5m",
		"e_nl_up_2_75m",
		"e_nl_down_2_75m",
		"e_nl_down_4_25m",
		"e_nl_down_5m",
		"e_nl_down_7m",
		"e_nl_up_4_6_down_0_6m",
		"e_nl_up_1_down_13m",
		"e_nl_up_1_down_15_50m",
		"e_nl_up_1_down_8m",
		"e_nl_up_1_down_9m",
		"e_nl_over_3_35m",
		"e_nl_10m_turn_r_2m",
		"e_nl_10m_turn_l_2m",
		"e_nl_down_2_7_fwd_2m",
		"e_nl_up_3_down_1m",
		"e_nl_up_6m",
		"e_nl_up_12m",
		"e_nl_jump_over_0_5m",
		"e_nl_jump_over_2_5m",
		"e_nl_up_rats_roof",
		"e_nl_up_6m_var2",
		"e_nl_up_6m_var3",
		"e_nl_down_12m",
		"e_nl_down_19m",
		"e_nl_down_8m",
		"e_nl_down_2m",
		"e_nl_down_1_25m",
		"e_nl_down_1_5m",
		"e_nl_up_1_5m",
		"e_nl_up_1_5m_var1",
		"e_nl_jump_fwd_4m_down_6_25m",
		"e_nl_up_1_fwd_1_5m",
		"e_nl_up_1_fwd_1_5m_var2",
		"e_nl_slide_fwd_4m",
		"e_nl_up_2_2_down_1m",
		"e_nl_up_6_2_down_1m_var2",
		"e_nl_up_6_2_down_1m",
		"e_nl_up_7_down_1m",
		"e_nl_down_stairs_4m",
		"e_nl_jump_over_1m_shoot",
		"e_nl_press_button_enter",
		"e_nl_up_5_down_1m_var2",
		"e_nl_up_5_down_1m_right",
		"e_nl_up_9_down_1m",
		"e_nl_up_7_down_1m_var2",
		"e_nl_up_2_down_8_2m",
		"e_nl_down_3_35m",
		"e_nl_down_8m_var2",
		"e_nl_down_8m_var3",
		"e_nl_up_1m_dwn_4m_roll",
		"e_nl_up_1m_dwn_4m",
		"e_nl_down_4m_jump",
		"e_nl_door_open_hack_code",
		"e_nl_dwn_4_75m",
		"e_nl_button_slide_under",
		"e_nl_down_1m",
		"e_nl_4m_long_2m_dwn",
		"e_nl_jump_2m_long",
		"e_nl_actionjump_2m_forward",
		"e_nl_actionjump_2m_forward_var2",
		"e_nl_over_4_25m",
		"e_nl_up_1_3m",
		"e_nl_up_1m",
		"e_nl_up_1m_swing_dwn_3_5m",
		"e_nl_up_2_2m_down_2m",
		"e_nl_slope_climb_3_3m",
		"e_nl_slope_climb_3_7m",
		"e_nl_slope_climb_2_4m",
		"e_nl_up_2_2m_down_2_2m",
		"e_nl_hox_enter_car",
		"e_nl_up_5m",
		"e_nl_up_ladder_4m",
		"e_nl_jump_4m_long",
		"e_nl_jump_5m_long",
		"e_nl_up_1_down_7_1m",
		"e_nl_up_1_down_6m",
		"e_nl_up_1_down_6m_v2",
		"e_nl_down_5m_var2",
		"e_nl_down_5m_var3",
		"e_nl_down_4m_var2",
		"e_nl_up_2_75_down_1m",
		"e_nl_up_0_5_down_5_5m",
		"e_nl_cs_jump_desk",
		"e_nl_cs_jump_window",
		"e_nl_cs_dwn_front",
		"e_nl_cs_dwn_back",
		"e_nl_cs_up_short_ladder",
		"e_nl_cs_up_long_ladder",
		"e_nl_cs_up_back_ladder",
		"e_nl_cs_up_front_ladder",
		"e_nl_cs_up_sewer_ladder",
		"e_nl_cs_dwn_sewer",
		"e_nl_cs_up_8m_ladder",
		"e_nl_dwn_11m",
		"e_nl_clk_over_1_8m",
		"e_nl_up1m_fwd2m_through_window",
		"e_nl_down_elevator_shaft",
		"e_nl_up_elevator_shaft",
		"e_nl_down_thermite_hole",
		"e_nl_up_7m_ladder",
		"e_nl_down_4_75m_swing",
		"e_nl_up_1m_dwn_18m",
		"e_nl_up_1m_down_4_5m_swing",
		"e_nl_up_1m_down_5m_swing",
		"e_up_1m_down_3m",
		"e_nl_up_1_5m_dwn_0_8m",
		"e_nl_up_4_3m_dwn_1m",
		"e_nl_up_4_3m_dwn_1m_var2",
		"e_nl_pool_jump",
		"e_nl_jump_dwn_3m_fwd_7m_dwn_0_5m",
		"e_nl_down_3m",
		"e_nl_up_8m_dwn_0_8m_left",
		"e_nl_up_1m_down_4_3m_swing",
		"e_nl_up_11_5m_down_1m",
		"e_nl_up_7_5m_down_1m",
		"e_nl_up_2_5m_right_2m_jump",
		"e_nl_up_3m_dwn_0_5m",
		"e_nl_up_0_5m_window_out",
		"e_nl_enter_wall_hole",
		"e_nl_dwn_0_5m_window_in",
		"e_nl_up_0_5m_dwn_1m_window_out",
		"e_nl_up_0_9m_dwn_1m_window_out",
		"e_nl_up_1m_dwn_0_9m_window_in",
		"e_nl_up_1m_dwn_0_5m_window_in",
		"e_nl_dwn_3_5m_slide_cliff",
		"e_nl_dwn_4_5m_slide_cliff",
		"e_nl_ladder_up_3m",
		"e_nl_ladder_up_16m",
		"e_nl_ladder_dwn_16m",
		"e_nl_ladder_up_4_4m",
		"e_nl_dwn_4_4m_jump",
		"e_nl_dwn_4_4m_hang",
		"e_nl_up_3_3m",
		"e_nl_up_3_5m",
		"e_nl_up_1_down_4_5m_drill",
		"e_nl_dwn_repel_11_25m",
		"e_nl_dwn_jump_4_5m",
		"e_nl_dwn_jump_5_25m",
		"e_nl_up_4_4m_dwn_0_5m",
		"e_nl_up_5m_1m_dwn_right_stairs",
		"e_nl_up_5m_1m_dwn_left_stairs",
		"e_so_push_button",
		"e_so_use_key",
		"e_so_insert_keycard_ntl",
		"e_so_push_button_low",
		"e_so_try_kick_door",
		"e_so_try_kick_door_loop",
		"e_nl_up_1m_dwn_4_5m_roll",
		"e_nl_slide_4m_dwn_2m",
		"e_nl_over_1m_dwn_8m",
		"e_nl_over_1m_dwn_11_5m",
		"e_nl_over_1m_dwn_12m",
		"e_nl_up_1_down_4_8m",
		"e_nl_up_1m_dwn_4_5m",
		"e_nl_run_jump_far_var2",
		"e_nl_run_jump_far_var3",
		"e_nl_run_jump_far_var1",
		"e_so_barn_door_open_r",
		"e_so_barn_door_open_l",
		"e_so_walk_investigate",
		"e_so_walk_investigate_unarmed",
		"e_so_investigate_window",
		"e_so_investigate_window_unarmed",
		"e_so_look_ledge_down_var2",
		"e_so_look_corner_var2",
		"e_so_look_corner_var2_unarmed",
		"e_so_throw_grenade",
		"e_so_shield_throw_grenade",
		"e_so_ntl_idle_tired",
		"player_select_screen",
		"e_so_ntl_crouch_investigate_v01",
		"e_so_ntl_crouch_investigate_v02",
		"e_so_ntl_crouch_investigate_v03",
		"e_so_mg34_enter",
		"e_so_mg34_exit",
		"e_so_mg34_idle",
		"e_so_mg34_aiming",
		"e_so_mg34_aim_right",
		"e_so_mg34_aim_left",
		"e_so_mg34_recoil_v01",
		"ntl_death_flakvierling_var1",
		"ntl_enter_flakvierling",
		"ntl_exit_flakvierling",
		"ntl_idle_flakvierling",
		"so_para_jump_flakturm",
		"e_so_suspicious_pistol_v01",
		"e_so_suspicious_pistol_v02",
		"e_so_suspicious_rifle_v01",
		"e_so_suspicious_rifle_v02",
		"e_nl_up_6m_ladder_v01",
		"e_nl_ladder_up_19m",
		"so_radio_tower_up_idle",
		"e_nl_ladder_down_19m",
		"e_nl_down_6m_ladder_v01",
		"ntl_std_coin_charge",
		"ntl_std_coin_idle",
		"ntl_std_coin_throw",
		"ntl_std_grenade_charge",
		"ntl_std_grenade_idle",
		"ntl_std_grenade_throw",
		"e_so_idle_adjust_boot",
		"e_so_idle_adjust_boot_rifle",
		"e_so_bored_rifle",
		"e_so_bored_pistol",
		"e_so_look_over_pistol",
		"e_so_look_over_rifle",
		"e_so_excited_pistol",
		"e_so_excited_rifle",
		"e_so_unarmed_smoke_enter_pistol",
		"e_so_unarmed_smoke_exit_pistol",
		"e_so_unarmed_smoke_loop_lean_pistol",
		"e_so_unarmed_smoke_loop_pistol",
		"e_so_unarmed_smoke_loop_turn_pistol",
		"e_so_unarmed_smoke_enter_rifle",
		"e_so_unarmed_smoke_exit_rifle",
		"e_so_unarmed_smoke_loop_lean_rifle",
		"e_so_unarmed_smoke_loop_rifle",
		"e_so_unarmed_smoke_loop_turn_rifle",
		"e_so_armed_leanwall_enter_rifle",
		"e_so_armed_leanwall_exit_rifle",
		"e_so_armed_leanwall_loop_clock_rifle",
		"e_so_armed_leanwall_loop_kickpebble_rifle",
		"e_so_armed_leanwall_loop_look_rifle",
		"civ_so_situps_exit",
		"civ_so_situps",
		"civ_so_pushups_exit",
		"civ_so_pushups",
		"civ_so_boxing_exit",
		"civ_so_boxing",
		"civ_so_sit_on_bed_exit",
		"civ_so_sit_on_bed",
		"civ_so_car_climb_back_idle",
		"civ_so_car_climb_back",
		"civ_so_car_climb_l_idle",
		"civ_so_car_climb_l",
		"civ_so_airplane_r_enter",
		"civ_so_airplane_r_loop",
		"civ_so_airplane_l_enter",
		"civ_so_airplane_l_loop",
		"civ_so_airplane_r_enter_var2",
		"civ_so_airplane_r_loop_var2",
		"civ_so_airplane_l_enter_var2",
		"civ_so_airplane_l_loop_var2",
		"e_so_adjust_collar",
		"e_so_adjust_sleves",
		"e_so_idle_std_to_crh_idle_crh_to_std_idle",
		"e_so_idle_std_to_crh_idle_crh_to_std_idle_var1",
		"e_so_look_corner_unarmed",
		"e_so_looking_in_distance",
		"e_so_looking_in_distance_var1",
		"e_so_look_under_caranimation",
		"e_so_partol_circle",
		"e_so_patrol_front_back",
		"e_so_patrol_left_right",
		"e_so_pick_nose",
		"e_so_pickup_stuff_floor_dustoff_hands",
		"e_so_point_at_enter",
		"e_so_polish_boots",
		"e_so_push_button_table",
		"e_so_push_button_wall",
		"e_so_repair",
		"e_so_shoo_away_mosquito",
		"e_so_sit_to_point_at_enter",
		"e_so_sit_to_point_at_exit",
		"e_so_sit_to_point_at_idle",
		"e_so_stretch_arms",
		"e_so_stretch_legs",
		"e_so_swat_mosquito",
		"e_so_yawn",
		"e_so_yawn_var1",
		"e_so_armed_idle",
		"e_so_hurt_stairs",
		"e_so_death_stairs",
		"e_so_door_tackle",
		"e_so_situps_exit",
		"e_so_situps",
		"e_so_ntl_pissing",
		"e_so_ntl_rest",
		"e_so_ntl_rest_exit",
		"e_so_ntl_sit_on_object_idle",
		"e_so_ntl_sit_on_object_idle_exit",
		"e_so_ntl_sit_ground_lean_back_exit",
		"e_so_ntl_sit_ground_lean_back",
		"e_so_foxhole_enter",
		"e_so_foxhole_exit",
		"e_so_foxhole_idle",
		"e_so_pushups_exit",
		"e_so_pushups",
		"e_so_boxing_exit",
		"e_so_boxing",
		"e_so_cover_var2",
		"e_so_cover_exit_var2",
		"e_so_low_cover",
		"e_so_low_cover_exit",
		"e_so_low_cover_var2",
		"e_so_low_cover_exit_var2",
		"e_so_cover_exit",
		"e_so_cover",
		"e_so_unarmed_idle",
		"e_so_pull_lever_towards",
		"e_so_pull_lever_away",
		"e_so_sit_on_tank_hood_enter",
		"e_so_sit_on_tank_hood_exit",
		"e_so_sit_on_tank_hood_idle",
		"e_so_unarmed_smoke_loop_turn_l",
		"e_so_unarmed_smoke_loop_turn_r",
		"e_so_unarmed_smoke_lean_l",
		"e_so_unarmed_smoke_lean_r",
		"e_so_look_up_wall",
		"e_so_look_under_table",
		"e_so_look_ledge_up",
		"e_so_look_corner",
		"e_so_unarmed_wave_camera",
		"e_so_sit_truck_bumper_enter",
		"e_so_leg_on_sandbags_enter",
		"e_so_lean_on_crate_enter",
		"e_so_arm_lean_enter",
		"e_so_sit_on_barrel_enter",
		"e_so_unarmed_leanwall_loop_look",
		"e_so_unarmed_leanwall_loop_kickpebble",
		"e_so_unarmed_leanwall_loop_fingers",
		"e_so_unarmed_leanwall_loop_clock",
		"e_so_unarmed_leanwall_exit",
		"e_so_unarmed_leanwall_enter",
		"e_so_unarmed_idle_enter",
		"e_so_unarmed_idle_enter_corner",
		"ntl_std_idle_var1",
		"husk_hos_std_idle",
		"e_so_idle_v01",
		"e_so_idle_v02",
		"husk_hos_std_idle_rifle",
		"husk_lvl_start_std_idle",
		"husk_lvl_start_crh_idle",
		"husk_stealth_crh_var1",
		"husk_stealth_crh_var2",
		"husk_stealth_crh_var3",
		"husk_stealth_crh_var4",
		"husk_stealth_std_var1",
		"husk_stealth_std_var2",
		"husk_stealth_std_var3",
		"husk_stealth_std_var4",
		"so_camp_inspect_armory",
		"so_camp_inspect_piano",
		"so_camp_look_at_maps",
		"so_camp_look_at_statue",
		"so_camp_sit_idle_get_up",
		"so_camp_sit_lean_on_crate_get_up",
		"so_camp_small_table_sit",
		"so_camp_use_radio",
		"so_camp_small_table_sit_spy",
		"so_spy_idle",
		"e_so_punching_idle",
		"e_so_l_hand_punch",
		"e_so_r_hand_punch",
		"so_run_to_radio_tower",
		"so_chair_sitting_hands_tied_to_stand_idle",
		"so_chair_stand_idle",
		"so_chair_sitting_hands_tied",
		"so_chair_sitting_punched_l",
		"so_chair_sitting_punched_r",
		"e_so_climbing_rope",
		"e_so_climbing_rope_var1",
		"e_so_plant_dynamite_low",
		"e_so_plant_dynamite_hi",
		"e_so_plant_dynamite_floor",
		"e_nl_climb_over_rocks_dwn_2_5m",
		"e_nl_over_rubble_to_inside",
		"e_nl_over_rubble_to_outside",
		"e_nl_down_4_3m",
		"e_nl_up_4_3m",
		"so_radio_tower_idle",
		"so_run_to_hide",
		"so_hide_idle",
		"so_radio_tower_escape",
		"so_radio_tower_escape_idle",
		"e_nl_radio_tower_fall",
		"e_so_climb_down_tiger_tank",
		"e_so_climb_up_tiger_tank",
		"e_so_flak_88_sit_exit",
		"e_so_flak_88_idle",
		"e_so_flak_88_sit_enter",
		"so_enter_flakvierling_20mm_quad",
		"so_exit_flakvierling_20mm_quad",
		"so_idle_flakvierling_20mm_quad",
		"e_nl_up_2m",
		"e_nl_ladder_up_9_7m",
		"e_nl_ladder_up_7_5m",
		"e_nl_ladder_up_5m_down_1m",
		"e_nl_ladder_up_4m",
		"e_nl_ladder_down_9_7m",
		"e_nl_ladder_down_7_5m",
		"e_nl_dwn_6m",
		"e_nl_crawl_4m",
		"e_nl_3m_up_2m",
		"e_nl_3m_fwd_2m_dwn",
		"e_nl_ladder_up_13_7m",
		"e_nl_ladder_down_13_7m",
		"e_nl_barbwires_jump_var1",
		"e_nl_barbwires_jump_var2",
		"e_so_between_single_door_cover",
		"e_so_between_door_cover_3m",
		"e_so_slide_cover_3m",
		"e_so_slide_cover_4m",
		"e_so_slide_cover_5m",
		"e_so_jump_over_cover_var2",
		"e_so_jump_over_cover",
		"e_so_roll_cover_3m",
		"e_so_roll_cover_4m",
		"e_so_roll_cover_5m",
		"e_so_run_cover_3m",
		"e_so_run_cover_4m",
		"e_so_run_cover_5m",
		"e_so_crawl_cover_3m",
		"e_so_crawl_cover_4m",
		"e_so_crawl_cover_5m",
		"e_so_idle_look_around_startled_rifle",
		"e_so_idle_walk_around_rifle",
		"e_so_idle_walk_inplace_look_back_rifle",
		"e_so_idle_walk_in_place_startled_rifle",
		"e_so_idle_walk_in_place_worried",
		"e_so_startled_while_eating_snack",
		"e_so_dive_to_cover_var3",
		"e_so_dive_to_cover_var2",
		"e_so_dive_to_cover",
		"e_so_run_to_cover_var3",
		"e_so_run_to_cover_var2",
		"e_so_run_to_cover",
		"e_so_roll_to_cover_var3",
		"e_so_roll_to_cover_var2",
		"e_so_roll_to_cover",
		"e_so_slide_to_cover_var3",
		"e_so_slide_to_cover_var2",
		"e_so_slide_to_cover",
		"e_so_chr_walk_to_cover",
		"e_so_crawl_to_cover",
		"e_nl_slide_down_low_slope_var1",
		"e_nl_slide_down_low_slope_var2",
		"e_nl_slide_down_low_slope_var3",
		"e_nl_slide_down_slope_var1",
		"e_nl_slide_down_slope_var2",
		"e_nl_slide_down_slope_var3",
		"e_nl_ladder_up_14_5m",
		"e_nl_ladder_down_14_5m",
		"e_nl_down_5_5m_climb_arc",
		"e_nl_up_5_5m_climb_arc",
		"e_nl_over_vault_1_1m",
		"e_nl_down_jump_2_25m",
		"e_nl_over_0_75_down_4m",
		"e_nl_down_jump_1_8m",
		"e_nl_over_0_75_down_3_7m",
		"e_nl_over_0_75_down_4_6m",
		"e_nl_ladder_up_4m_fwd_1m",
		"e_nl_over_1m_down_6m",
		"e_nl_over_1m_down_3_3m",
		"e_nl_up_0_75m_down_1_75m",
		"e_nl_climb_over_4m",
		"e_nl_up_5m_1m_down_left_stairs",
		"e_nl_up_5m_1m_down_right_stairs",
		"e_nl_up_4_4m_down_0_5m",
		"e_nl_up_4_3m_down_1m_var2",
		"e_nl_up_4_3m_down_1m",
		"e_nl_up_3_down_0_5m",
		"e_nl_over_1m_down_8m",
		"e_nl_cs_up_front_ladder_down_loop_and_exit_var2",
		"e_nl_cs_up_front_ladder_down_loop_and_exit_var1",
		"e_nl_4m_long_2m_down",
		"e_nl_over_1m_down_11_5m",
		"e_nl_runjump_far_var1",
		"e_nl_runjump_far_var2",
		"e_nl_runjump_far_var3",
		"e_nl_slide_4m_down_2m",
		"e_nl_up_1_5m_down_1m",
		"e_nl_up_1_5m_down_0_8m",
		"e_nl_ladder_down_4_3m",
		"e_nl_ladder_up_4_3m",
		"e_nl_up_1_15m",
		"e_nl_up_1_down_4m_jump",
		"e_nl_up_ladder_4m_train_cabin",
		"e_nl_down_1_15m",
		"e_nl_down_1_75m_trainyard",
		"e_nl_jump_over_0_5m_train_cabin",
		"e_nl_down_4m_jump_train_cabin",
		"e_nl_up_ladder_3_7m",
		"e_nl_dwn_7m",
		"e_nl_up_1_down_3_3m",
		"e_nl_up_1_down_5_5m",
		"e_nl_ladder_down_3_7m",
		"e_nl_up_1_down_4_6m",
		"e_nl_up_1_down_4_2m",
		"e_nl_up_1_down_5_6m",
		"e_nl_up_1_down_3_6m",
		"e_nl_down_1_85m",
		"e_nl_down_2_25m",
		"e_nl_up_4_25m_down_1m",
		"e_nl_up_0_6_down_4_6m",
		"e_nl_up_0_75_down_3_6m",
		"e_nl_up_0_75_down_5_6m",
		"e_nl_up_1m_fwd_3_5m_dwn_4m",
		"e_nl_ladder_down_8m",
		"e_nl_climb_over_2_30m",
		"e_nl_up_1_35m_down_1_35m",
		"nl_train_start_01",
		"nl_train_start_02",
		"nl_train_start_03",
		"e_nl_30m",
		"e_nl_down_0_75",
		"e_nl_up_2_5m_down_2_5m",
		"e_nl_climb_over_3_15m",
		"e_nl_up_2m_down_2m",
		"e_nl_climb_over_3_75m",
		"so_commander_chair_sit_exit",
		"so_commander_look_idle",
		"so_commander_chair_sit_idle",
		"so_commander_chair_sit_enter",
		"so_commander_sofa_sit_exit",
		"so_commander_sofa_sit_idle",
		"so_commander_sofa_sit_enter",
		"so_commander_couch_exit",
		"so_commander_couch_idle",
		"so_commander_couch_enter",
		"so_commander_look_table_exit",
		"so_commander_look_table_idle",
		"so_commander_look_table_enter",
		"so_team_ai_stand_idle_look_around",
		"so_team_ai_stand_idle_look_l_r",
		"so_team_ai_stand_idle_look_l_r_var1",
		"so_team_ai_stand_idle_stretch_arms",
		"so_team_ai_stand_idle_scratch_head",
		"e_nl_cbt_crh_blind_shot_r",
		"e_nl_cbt_crh_blind_shot_l",
		"e_nl_cbt_crh_blind_shot_top_r",
		"e_nl_cbt_crh_blind_shot_top_l",
		"e_nl_cbt_std_blind_shot_r",
		"e_nl_cbt_std_blind_shot_l",
		"e_so_shout_orders_l_arm_var1",
		"e_so_shout_orders_l_arm_var2",
		"e_so_yell_alarm_var1",
		"e_so_yell_alarm_var2",
		"e_so_yell_alarm_var3",
		"e_so_valve_turn",
		"spotter_cbt_sup_throw_flare",
		"e_so_fall_out_of_bunker_fire_dth_var1",
		"e_so_fall_out_of_bunker_fire_dth_var2",
		"e_so_fall_out_of_zepelin_fire_dth_var1",
		"e_so_fall_out_of_zepelin_fire_dth_var2",
		"e_so_run_fwd_on_fire_die_var2",
		"e_so_run_fwd_on_fire_die_var1",
		"aggressive_russian_punching_idle",
		"beaten_calm_russian",
		"drugged_dying_russian",
		"scared_russian_idle",
		"crazy_russian_idle",
		"e_nl_actionjump_2m_fwd_1m_up",
		"e_nl_actionjump_2m_fwd_1m_down",
		"e_nl_jump_over_4m",
		"e_nl_flak_bunker_fwd_2m_down_6m",
		"so_train_wagon_var3",
		"so_train_wagon_var4",
		"rivet_step_up_v01",
		"rivet_idle_v01",
		"kurgan_step_up_v01",
		"kurgan_idle_v01",
		"stirling_step_up_v01",
		"stirling_idle_v01",
		"wolfgang_step_up_v01",
		"wolfgang_idle_v01",
		"all_idle_standing_loop",
		"tiger_tank_commander",
		"tiger_tank_driver",
		"tiger_tank_gunner",
		"tiger_tank_mg",
		"drive_kubelwagen_driver",
		"drive_kubelwagen_passanger",
		"drive_kubelwagen_back_right",
		"drive_kubelwagen_back_left",
		"drive_kubelwagen_back_right_shooting",
		"drive_kubelwagen_back_left_shooting",
		"drive_truck_driver",
		"drive_truck_passanger",
		"drive_truck_back_right",
		"drive_truck_back_left",
		"e_so_ntl_vendingmachine",
		"e_so_ntl_idle_kickpebble",
		"e_so_ntl_idle_look",
		"e_so_ntl_idle_look2",
		"e_so_ntl_idle_clock",
		"e_so_ntl_idle_brush",
		"e_so_ntl_idle_stickygum",
		"e_so_ntl_idle_backoff",
		"e_so_ntl_wave_camera",
		"e_so_ntl_smoke_stand",
		"e_so_ntl_leanwall",
		"e_so_ntl_talk_phone",
		"e_so_plant_c4_low",
		"e_so_plant_c4_hi",
		"e_so_interact_mid",
		"e_so_plant_c4_floor",
		"e_so_ntl_look_up_wall",
		"e_so_alarm_under_table",
		"e_so_std_alarm",
		"e_so_ntl_look_corner",
		"e_so_ntl_look_ledge_down",
		"e_so_ntl_look_ledge_up",
		"e_so_ntl_look_under_table",
		"e_so_ntl_look_under_car",
		"e_so_sneak_wait_crh",
		"e_so_sneak_wait_stand",
		"e_so_pull_lever",
		"e_so_ntl_boxing",
		"e_so_ntl_boxing_bag_hold",
		"e_so_ntl_bouncer_idle",
		"e_so_ntl_bouncer_step_right",
		"e_so_ntl_bouncer_stop",
		"e_so_idle_to_door_or_point",
		"e_so_door_open",
		"e_so_door_knock",
		"e_so_point_right",
		"e_so_sit_to_point_at",
		"e_so_point_at",
		"e_so_point_at_exit_idle",
		"e_so_sit_on_car_hood_exit",
		"e_so_sit_on_car_hood_idle",
		"e_so_exit_speech",
		"e_so_enter_speech",
		"e_so_loop_speech",
		"e_so_sit_stair1",
		"e_so_sit_stair_exit1",
		"e_so_stair_idle1",
		"e_so_sit_stair2",
		"e_so_sit_stair_exit2",
		"e_so_stair_idle2",
		"e_so_checkbag_short",
		"e_so_stair_idle2_pose",
		"e_so_stair_idle1_pose",
		"e_so_investigate_truck",
		"e_so_investigate_truck_slope",
		"e_so_container_impact_01",
		"e_so_container_impact_02",
		"e_so_container_impact_03",
		"e_so_container_kick",
		"e_so_keyboard_type_loop",
		"e_so_not_dizzy_look_v2",
		"e_so_not_dizzy_look",
		"e_so_hide_under_car_enter",
		"e_so_hide_2_5m_vent_enter",
		"e_so_hide_behind_door_enter",
		"e_so_hide_ledge_enter",
		"e_so_unarmed_shake_fence",
		"e_so_unarmed_scrape_foot_truck",
		"e_so_unarmed_sick_puke_sink",
		"e_so_talking_in_megaphone",
		"e_so_sup_fumble_inplace",
		"e_so_sup_fumble_run_fwd",
		"e_so_investigate_object_unarmed",
		"e_so_investigate_object_armed",
		"cm_so_bbqing",
		"cm_so_goto_trunk",
		"cm_so_enter_limo",
		"cf_so_use_key",
		"cm_so_point_up_shrug",
		"cm_so_escort_get_up_hesitant",
		"cm_so_investigate_hi",
		"cm_so_investigate_low",
		"cm_so_hide",
		"cm_so_look_at_phone",
		"cm_so_crashed_limo1",
		"cm_so_crashed_limo2",
		"cm_so_crashed_limo3",
		"cm_so_crashed_limo4",
		"cmf_so_lean_r_wall",
		"cmf_so_lean_bar",
		"cmf_so_write_note",
		"cmf_so_call_police",
		"cmf_so_panic",
		"cmf_so_surrender",
		"cmf_sp_debug_tpose",
		"cmf_so_answer_phone",
		"cmf_so_sit_in_chair",
		"cmf_so_look_windows",
		"cmf_so_stand_type",
		"cmf_so_window_observer",
		"cmf_so_sit_table_right",
		"cmf_so_sit_table_right2",
		"cmf_so_sit_table_left",
		"cmf_so_sit_table_left2",
		"cmf_so_sit_high_chair",
		"cmf_so_talk",
		"cm_so_tied_eyescan",
		"cf_so_talk_phone",
		"cmf_so_idle",
		"cmf_so_idle_var2",
		"cmf_so_clean_hi",
		"cmf_so_press_alarm_wall",
		"cmf_so_press_alarm_table",
		"cmf_so_smoke",
		"cmf_so_casino_guest",
		"cmf_so_casino_guest_sit",
		"cf_so_sunbed",
		"cm_so_pilot_drunk_idle",
		"cm_so_drunk_sit",
		"cm_so_drunk",
		"cmf_so_slotmachine",
		"cmf_so_slotmachine_win",
		"cmf_so_slotmachine_loose",
		"cm_so_drink_or_puke",
		"cm_so_climb_rope_ladder",
		"cm_so_drink_stand_table_1m",
		"cm_so_puke_var2",
		"cm_so_jump_into_dumpster",
		"cm_so_scared_loop",
		"cm_so_fix_gloves_loop",
		"cf_dance_1",
		"cf_dance_2",
		"cf_dance_3",
		"cf_arms_up_1",
		"cf_arms_up_2",
		"cf_arms_up_3",
		"cm_dance_1",
		"cm_dance_2",
		"cm_dance_3",
		"cm_arms_up_1",
		"cm_arms_up_2",
		"cm_arms_up_3",
		"cf_hand_clap_1",
		"cf_hand_clap_2",
		"cf_hand_clap_3",
		"cm_hand_clap_1",
		"cm_hand_clap_2",
		"cm_hand_clap_3",
		"cf_idle_1",
		"cf_idle_2",
		"cf_idle_3",
		"dj_celebrate",
		"dj_arm_up",
		"dj_mixing",
		"cm_idle_1",
		"cm_idle_2",
		"cm_idle_3",
		"cmf_so_lean_1m",
		"cm_so_impersonator",
		"sstash_stand_enter",
		"sstash_stand_loop",
		"sstash_sit_enter",
		"sstash_sit_untied_loop",
		"sstash_sit_tied_enter",
		"sstash_sit_tied_loop",
		"sstash_sit_tied_react",
		"sstash_sit_tied_react2",
		"sstash_sit_tied_yes",
		"sstash_sit_tied_no",
		"sstash_sit_tied_fwd_hit",
		"sstash_sit_tied_bwd_hit",
		"sstash_sit_tied_faint",
		"sstash_sit_tied_fainted",
		"sstash_sit_tied_wakeup",
		"so_enter_ejectionchair",
		"so_ejectionchair_idle",
		"spawn_prisonvan_var1",
		"spawn_prisonvan_var4",
		"spawn_prisonvan_var5",
		"spawn_prisonvan_var8",
		"spawn_prisonvan_var9",
		"spawn_prisonvan_var10",
		"so_climb_into_chopper",
		"e_escort_f_ckoff_to_van",
		"so_escort_hurt_opens_door",
		"so_escort_before_door_idle",
		"so_escort_before_door_enter",
		"spotter_cbt_sup_throw_flare"
	}
}

function CopActionAct:init(action_desc, common_data)
	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._unit = common_data.unit
	self._machine = common_data.machine
	self._host_expired = action_desc.host_expired
	self._skipped_frames = 0
	self._last_vel_z = 0

	self:_init_ik()
	self:_create_blocks_table(action_desc.blocks)

	if self._ext_anim.act_idle then
		self._blocks.walk = nil
	end

	if action_desc.needs_full_blend and self._ext_anim.idle and (not self._ext_anim.idle_full_blend or self._ext_anim.to_idle) then
		self._waiting_full_blend = true

		self:_set_updator("_upd_wait_for_full_blend")
	elseif not self:_play_anim() then
		return
	end

	self:_sync_anim_play()
	self._ext_movement:enable_update()

	if self._host_expired and not self._waiting_full_blend then
		self._expired = true
	end

	if not self._expired and Network:is_server() then
		local stand_rsrv = self._unit:brain():get_pos_rsrv("stand")

		if not stand_rsrv or mvector3.distance_sq(stand_rsrv.position, common_data.pos) > 400 then
			self._unit:brain():add_pos_rsrv("stand", {
				position = nil,
				radius = 30,
				position = mvector3.copy(common_data.pos)
			})
		end
	end

	return true
end

function CopActionAct:on_exit()
	if self._changed_driving then
		self._unit:set_driving("script")

		self._changed_driving = nil

		self._ext_movement:set_m_rot(self._unit:rotation())
		self._ext_movement:set_m_pos(self._unit:position())
	end

	self._ext_movement:drop_held_items()

	if self._ext_anim.stop_talk_on_action_exit then
		self._unit:sound():stop()
	end

	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end

	if self._expired then
		CopActionWalk._chk_correct_pose(self)
	end

	if Network:is_client() then
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	elseif not self._expired then
		self._common_data.ext_network:send("action_act_end")
	end
end

function CopActionAct:_init_ik()
	self._look_vec = mvector3.copy(self._common_data.fwd)
	self._ik_update = callback(self, self, "_ik_update_func")
	self._m_head_pos = self._ext_movement:m_head_pos()

	self:on_attention(self._common_data.attention)
end

function CopActionAct:_ik_update_func(t)
	self:_update_ik_type()

	if self._attention and self._ik_type then
		local look_from_pos = self._m_head_pos
		self._look_vec = self._look_vec or mvector3.copy(self._common_data.fwd)
		local target_vec = self._look_vec

		if self._attention.handler or self._attention.unit then
			mvec3_set(target_vec, self._m_attention_head_pos)
			mvec3_sub(target_vec, look_from_pos)
		else
			mvec3_set(target_vec, self._attention.pos)
			mvec3_sub(target_vec, look_from_pos)
		end

		mvec3_set(tmp_vec1, target_vec)
		mvec3_set_z(tmp_vec1, 0)
		mvec3_norm(tmp_vec1)

		local fwd_dot = mvector3.dot(self._common_data.fwd, tmp_vec1)

		if fwd_dot < 0.2 then
			if self._modifier_on then
				self._modifier_on = nil

				self._machine:forbid_modifier(self._modifier_name)
			end
		elseif not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._modifier_name)

			local old_look_vec = self._modifier_name == Idstring("look_head") and self._unit:get_object(Idstring("Head")):rotation():z() or self._unit:get_object(ids_aim):rotation():y()
			local duration = math.lerp(0.1, 1, target_vec:angle(old_look_vec) / 90)
			self._look_trans = {
				start_vec = nil,
				start_t = nil,
				duration = nil,
				start_t = TimerManager:game():time(),
				duration = duration,
				start_vec = old_look_vec
			}
		end

		if self._look_trans then
			local look_trans = self._look_trans
			local prog = (t - look_trans.start_t) / look_trans.duration

			if prog > 1 then
				self._look_trans = nil
			else
				local end_vec = nil

				if look_trans.end_vec then
					end_vec = look_trans.end_vec
				else
					end_vec = tmp_vec1

					mvec3_set(end_vec, target_vec)
					mvec3_norm(end_vec)
				end

				local prog_smooth = math.bezier({
					0,
					0,
					1,
					1
				}, prog)

				mvector3.lerp(target_vec, look_trans.start_vec, end_vec, prog_smooth)
			end
		end

		if self._modifier_on then
			self._modifier:set_target_z(target_vec)
		end
	elseif self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end
end

function CopActionAct:on_attention(attention)
	self:_update_ik_type()

	self._m_attention_head_pos = attention and (attention.handler and attention.handler:get_attention_m_pos() or attention.unit and attention.unit:movement():m_head_pos())
	self._attention = attention

	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end

	self._ext_movement:enable_update()
end

function CopActionAct:_update_ik_type()
	local new_ik_type = self._ext_anim.ik_type

	if self._ik_type ~= new_ik_type then
		if self._modifier_on then
			self._machine:forbid_modifier(self._modifier_name)

			self._modifier_on = nil
		end

		if new_ik_type == "head" then
			self._ik_type = new_ik_type
			self._modifier_name = Idstring("look_head")
			self._modifier = self._machine:get_modifier(self._modifier_name)
		elseif new_ik_type == "upper_body" then
			self._ik_type = new_ik_type
			self._modifier_name = Idstring("look_upper_body")
			self._modifier = self._machine:get_modifier(self._modifier_name)
		else
			self._ik_type = nil
		end
	end
end

function CopActionAct:_upd_wait_for_full_blend()
	if not self._ext_anim.idle or self._ext_anim.idle_full_blend and not self._ext_anim.to_idle then
		self._waiting_full_blend = nil

		if not self:_play_anim() then
			if Network:is_server() then
				self._expired = true

				self._common_data.ext_network:send("action_act_end")
			end

			return
		end

		if self._host_expired then
			self._expired = true
		end
	end
end

function CopActionAct:_clamping_update(t)
	if self._ext_anim.act then
		if not self._unit:parent() then
			local dt = TimerManager:game():delta_time()
			self._last_pos = CopActionHurt._get_pos_clamped_to_graph(self)

			CopActionWalk._set_new_pos(self, dt)

			local new_rot = self._unit:get_animation_delta_rotation()
			new_rot = self._common_data.rot * new_rot

			mrotation.set_yaw_pitch_roll(new_rot, new_rot:yaw(), 0, 0)
			self._ext_movement:set_rotation(new_rot)
		end
	else
		self._expired = true
	end

	if self._ik_update then
		self._ik_update(t)
	end
end

function CopActionAct:update(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state ~= 1 then
		if self._freefall then
			-- Nothing
		elseif self._skipped_frames < vis_state then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	if self._ik_update then
		self._ik_update(t)
	end

	if self._freefall then
		if self._ext_anim.freefall then
			local pos_new = tmp_vec1
			local delta_pos = self._unit:get_animation_delta_position()

			self._unit:m_position(pos_new)
			mvec3_add(pos_new, delta_pos)
			self._ext_movement:upd_ground_ray(pos_new, true)

			local gnd_z = self._common_data.gnd_ray.position.z

			if gnd_z < pos_new.z then
				self._last_vel_z = CopActionWalk._apply_freefall(pos_new, self._last_vel_z, gnd_z, TimerManager:game():delta_time())
			else
				if pos_new.z < gnd_z then
					mvec3_set_z(pos_new, gnd_z)
				end

				self._last_vel_z = 0
			end

			local new_rot = self._unit:get_animation_delta_rotation()
			new_rot = self._common_data.rot * new_rot

			mrotation.set_yaw_pitch_roll(new_rot, new_rot:yaw(), 0, 0)
			self._ext_movement:set_rotation(new_rot)
			self._ext_movement:set_position(pos_new)
		else
			self._freefall = nil
			self._last_vel_z = nil

			self._unit:set_driving("animation")

			self._changed_driving = true
		end
	elseif not self._unit:parent() then
		self._ext_movement:set_m_rot(self._unit:rotation())
		self._ext_movement:set_m_pos(self._unit:position())
	end

	if not self._ext_anim.act then
		self._expired = true

		CopActionWalk._chk_correct_pose(self)
	end
end

function CopActionAct:type()
	return "act"
end

function CopActionAct:expired()
	return self._expired
end

function CopActionAct:save(save_data)
	for k, v in pairs(self._action_desc) do
		save_data[k] = v
	end

	save_data.blocks = save_data.blocks or {
		act = -1,
		action = -1,
		walk = -1
	}
	save_data.start_anim_time = self._machine:segment_real_time(Idstring("base"))

	if save_data.variant then
		local state_name = self._machine:segment_state(Idstring("base"))
		local state_index = self._machine:state_name_to_index(state_name)
		save_data.variant = state_index
	end

	save_data.pos_z = mvector3.z(self._common_data.pos)
end

function CopActionAct:need_upd()
	return self._attention or self._waiting_full_blend
end

function CopActionAct:chk_block(action_type, t)
	local unblock_t = self._blocks[action_type]

	return unblock_t and (unblock_t == -1 or t < unblock_t)
end

function CopActionAct:_create_blocks_table(block_desc)
	local blocks = self._blocks or {}

	if block_desc then
		local t = TimerManager:game():time()

		for action_type, block_duration in pairs(block_desc) do
			blocks[action_type] = block_duration == -1 and -1 or t + block_duration
		end
	end

	self._blocks = blocks
end

function CopActionAct:_get_act_index(anim_name)
	local cat_offset = 0

	for _, category_name in ipairs(self._ACT_CATEGORY_INDEX) do
		local category = self._act_redirects[category_name]

		for i_anim, test_anim_name in ipairs(category) do
			if test_anim_name == anim_name then
				return i_anim + cat_offset
			end
		end

		cat_offset = cat_offset + #category
	end

	debug_pause("[CopActionAct:_get_act_index] animation", anim_name, "not found on look-up table.")

	return 1
end

function CopActionAct:_get_act_name_from_index(index)
	for _, category_name in ipairs(self._ACT_CATEGORY_INDEX) do
		local category = self._act_redirects[category_name]

		if index <= #category then
			return category[index]
		end

		index = index - #category
	end

	debug_pause("[CopActionAct:_get_act_name_from_index] index", index, "is out of limits.")
end

function CopActionAct:_play_anim()
	if self._ext_anim.upper_body_active and not self._ext_anim.upper_body_empty then
		self._ext_movement:play_redirect("up_idle")
	end

	local redir_name, redir_res = nil

	if type(self._action_desc.variant) == "number" then
		redir_name = self._machine:index_to_state_name(self._action_desc.variant)
		redir_res = self._ext_movement:play_state_idstr(redir_name, self._action_desc.start_anim_time)

		self._unit:movement():set_position(self._unit:movement():m_pos():with_z(self._action_desc.pos_z))
	else
		redir_name = self._action_desc.variant

		if redir_name == "idle" and self._common_data.stance.code == 1 then
			redir_name = "exit"
		end

		redir_res = self._ext_movement:play_redirect(redir_name, self._action_desc.start_anim_time)
	end

	if not redir_res then
		debug_pause_unit(self._unit, "[CopActionAct:_play_anim] redirect", redir_name, "failed in", self._machine:segment_state(Idstring("base")), self._unit)

		self._expired = true

		return
	end

	if Network:is_client() and self._action_desc.start_rot and not self._unit:parent() then
		self._ext_movement:set_rotation(self._action_desc.start_rot)
		self._ext_movement:set_position(self._action_desc.start_pos)
	end

	if self._action_desc.clamp_to_graph then
		self:_set_updator("_clamping_update")
	else
		if not self._ext_anim.freefall and not self._unit:parent() then
			self._unit:set_driving("animation")

			self._changed_driving = true
		end

		self:_set_updator()
	end

	if self._ext_anim.freefall and not self._unit:parent() then
		self._freefall = true
		self._last_vel_z = 0
	end

	self._ext_movement:set_root_blend(false)
	self._ext_movement:spawn_wanted_items()

	if self._ext_anim.ik_type then
		self:_update_ik_type()
	end

	return true
end

function CopActionAct:_sync_anim_play()
	if Network:is_server() then
		local action_index = self:_get_act_index(self._action_desc.variant)

		if action_index then
			if self._action_desc.align_sync then
				local yaw = mrotation.yaw(self._common_data.rot)

				if yaw < 0 then
					yaw = 360 + yaw
				end

				local sync_yaw = 1 + math.ceil(yaw * 254 / 360)

				self._common_data.ext_network:send("action_act_start_align", action_index, self._blocks.heavy_hurt and true or false, self._action_desc.clamp_to_graph or false, self._action_desc.needs_full_blend and true or false, sync_yaw, mvector3.copy(self._common_data.pos))
			else
				self._common_data.ext_network:send("action_act_start", action_index, self._blocks.heavy_hurt and true or false, self._action_desc.clamp_to_graph or false, self._action_desc.needs_full_blend and true or false)
			end
		else
			print("[CopActionAct:_sync_anim_play] redirect", self._action_desc.variant, "not found")
		end
	end
end

function CopActionAct:_set_updator(func_name)
	self.update = func_name and self[func_name] or nil
end

CopActionAct._apply_freefall = CopActionWalk._apply_freefall
