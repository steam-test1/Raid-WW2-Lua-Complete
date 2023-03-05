GuiTweakData = GuiTweakData or class()

function GuiTweakData:init()
	self.base_resolution = {
		z = 60,
		x = 1920,
		y = 1080
	}

	self:_setup_layers()
	self:_setup_colors()
	self:_setup_hud_colors()
	self:_setup_fonts()
	self:_setup_font_paths()
	self:_setup_icons()
	self:_setup_menu_elements_icons()
	self:_setup_radial_icons()
	self:_setup_hud_icons()
	self:_setup_hud_accessibility_icons()
	self:_setup_hud_waypoint_icons()
	self:_setup_hud_reticles()
	self:_setup_map_icons()
	self:_setup_skill_icons()
	self:_setup_skill_big_icons()
	self:_setup_backgrounds()
	self:_setup_images()
	self:_setup_mission_photos()
	self:_setup_optical_flares()
	self:_setup_xp_icons()
	self:_setup_paper_icons()
	self:_setup_old_tweak_data()
end

function GuiTweakData:_setup_layers()
	self.PLAYER_PANELS_LAYER = 1300
	self.SAVEFILE_LAYER = 1500
	self.TAB_SCREEN_LAYER = 1400
	self.DEBRIEF_VIDEO_LAYER = 2000
end

function GuiTweakData:_setup_colors()
	self.colors = {
		raid_debug = Color("deaf3e"),
		raid_red = Color("de4a3e"),
		raid_dark_red = Color("c04236"),
		raid_brown_red = Color("802b24"),
		raid_light_red = Color("b8392e"),
		raid_white = Color("d7d7d7"),
		raid_dirty_white = Color("d3d3d3"),
		raid_grey = Color("9e9e9e"),
		raid_dark_grey = Color("565656"),
		raid_black = Color("0f0f0f"),
		raid_gold = Color("c78e38"),
		raid_light_gold = Color("d8b883"),
		raid_list_background = Color.white:with_alpha(0.09803921568627451),
		raid_select_card_background = Color.white:with_alpha(0.15),
		raid_unlock_select_background = Color.white:with_alpha(0.1),
		raid_table_background = Color.white:with_alpha(0.09803921568627451)
	}
	self.colors.raid_table_cell_highlight_on = self.colors.raid_white
	self.colors.raid_table_cell_highlight_off = self.colors.raid_grey
	self.colors.progress_bar_dot = Color("797f88")
	self.colors.raid_grey_effects = Color("787878")
end

function GuiTweakData:_setup_hud_colors()
	self.colors.ammo_background_outline = Color("1f1f22")
	self.colors.ammo_text = Color("222222")
	self.colors.warcry_inactive = Color("ECECEC")
	self.colors.warcry_active = Color("dd9a38")
	self.colors.xp_breakdown_active_column = Color("dd9a38")
	self.colors.interaction_bar = Color("dd9a38")
	self.colors.teammate_interaction_bar = Color("9e9e9e")
	self.colors.progress_green = Color("64bc4c")
	self.colors.progress_yellow = Color("dd9a38")
	self.colors.progress_orange = Color("dd5c23")
	self.colors.progress_red = Color("b8392e")
	self.colors.progress_dark_red = Color("81271f")
	self.colors.toast_notification_border = Color("222222")
	self.colors.turret_overheat = Color("b8392e")
	self.colors.chat_border = Color("222222")
	self.colors.light_grey = Color("ECECEC")
	self.colors.dark_grey = Color("808080")
	self.colors.chat_player_message = self.colors.raid_dirty_white
	self.colors.chat_peer_message = self.colors.raid_dirty_white
	self.colors.chat_system_message = self.colors.raid_red
	self.colors.gold_orange = Color("c68e38")
	self.colors.intel_newspapers_text = Color("d6c8b2")
	self.colors.player_health_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_red
		},
		{
			start_percentage = 0.25,
			color = self.colors.light_grey
		}
	}
	self.colors.player_warcry_colors = {
		{
			start_percentage = 0,
			color = self.colors.light_grey
		}
	}
	self.colors.player_stamina_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_red
		},
		{
			start_percentage = 0.25,
			color = self.colors.light_grey
		}
	}
	self.colors.ammo_clip_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_red
		},
		{
			start_percentage = 0.25,
			color = self.colors.light_grey
		}
	}
	self.colors.ammo_clip_spent_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_dark_red
		},
		{
			start_percentage = 0.25,
			color = self.colors.dark_grey
		}
	}
	self.colors.turret_heat_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_yellow
		}
	}
	self.colors.vehicle_health_colors = {
		{
			start_percentage = 0,
			color = self.colors.progress_red
		},
		{
			start_percentage = 0.25,
			color = self.colors.light_grey
		}
	}
	self.colors.vehicle_carry_amount_colors = {
		{
			start_percentage = 0,
			color = self.colors.light_grey
		},
		{
			start_percentage = 0.25,
			color = self.colors.progress_red
		}
	}
end

function GuiTweakData:_setup_fonts()
	self.fonts = {
		din_compressed = "din_compressed",
		lato = "lato",
		noto = "noto"
	}
	self.font_sizes = {
		size_84 = 84,
		size_76 = 76,
		title = 66,
		subtitle = 32,
		size_56 = 56,
		size_52 = 52,
		size_46 = 46,
		menu_list = 42,
		size_38 = 38,
		dialg_title = 36,
		large = 32,
		size_32 = 32,
		medium = 28,
		small = 26,
		size_24 = 24,
		extra_small = 22,
		size_20 = 20,
		size_18 = 18,
		paragraph = 16,
		size_16 = 16,
		size_14 = 14,
		size_12 = 12
	}
end

function GuiTweakData:_setup_font_paths()
	self.font_paths = {}

	self:_setup_din_compressed_font_paths()
	self:_setup_din_compressed_outlined_fonts()
	self:_setup_lato_outlined_fonts()
	self:_setup_lato_font_paths()
end

function GuiTweakData:_setup_din_compressed_font_paths()
	self.font_paths.din_compressed = {
		[18] = "ui/fonts/pf_din_text_comp_pro_medium_18_mf",
		[20] = "ui/fonts/pf_din_text_comp_pro_medium_20_mf",
		[22] = "ui/fonts/pf_din_text_comp_pro_medium_22_mf",
		[24] = "ui/fonts/pf_din_text_comp_pro_medium_24_mf",
		[26] = "ui/fonts/pf_din_text_comp_pro_medium_26_mf",
		[32] = "ui/fonts/pf_din_text_comp_pro_medium_32_mf",
		[38] = "ui/fonts/pf_din_text_comp_pro_medium_38_mf",
		[42] = "ui/fonts/pf_din_text_comp_pro_medium_42_mf",
		[46] = "ui/fonts/pf_din_text_comp_pro_medium_46_mf",
		[52] = "ui/fonts/pf_din_text_comp_pro_medium_52_mf",
		[56] = "ui/fonts/pf_din_text_comp_pro_medium_56_mf",
		[66] = "ui/fonts/pf_din_text_comp_pro_medium_66_mf",
		[72] = "ui/fonts/pf_din_text_comp_pro_medium_72_mf",
		[76] = "ui/fonts/pf_din_text_comp_pro_medium_76_mf",
		[84] = "ui/fonts/pf_din_text_comp_pro_medium_84_mf",
		default = "ui/fonts/pf_din_text_comp_pro_medium_84_mf"
	}
end

function GuiTweakData:_setup_din_compressed_outlined_fonts()
	self.fonts.din_compressed_outlined_18 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_18_mf"
	self.fonts.din_compressed_outlined_20 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_20_mf"
	self.fonts.din_compressed_outlined_22 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_22_mf"
	self.fonts.din_compressed_outlined_24 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_24_mf"
	self.fonts.din_compressed_outlined_26 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_26_mf"
	self.fonts.din_compressed_outlined_32 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_32_mf"
	self.fonts.din_compressed_outlined_38 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_38_mf"
	self.fonts.din_compressed_outlined_42 = "ui/fonts/pf_din_text_comp_pro_medium_outlined_42_mf"
end

function GuiTweakData:_setup_lato_outlined_fonts()
	self.fonts.lato_outlined_18 = "ui/fonts/lato_regular_outlined_18_mf"
	self.fonts.lato_outlined_20 = "ui/fonts/lato_regular_outlined_20_mf"
end

function GuiTweakData:_setup_lato_font_paths()
	self.font_paths.lato = {
		[18] = "ui/fonts/lato_regular_18_mf",
		[20] = "ui/fonts/lato_regular_20_mf",
		[22] = "ui/fonts/lato_regular_22_mf",
		[24] = "ui/fonts/lato_regular_24_mf",
		[26] = "ui/fonts/lato_regular_26_mf",
		[32] = "ui/fonts/lato_regular_32_mf",
		[38] = "ui/fonts/lato_regular_38_mf",
		[42] = "ui/fonts/lato_regular_42_mf",
		default = "ui/fonts/lato_regular_42_mf"
	}
end

function GuiTweakData:_setup_noto_fonts()
	self.fonts.noto = {
		[18] = "ui/fonts/noto_18",
		[20] = "ui/fonts/noto_20",
		[22] = "ui/fonts/noto_22",
		[24] = "ui/fonts/noto_24",
		[26] = "ui/fonts/noto_26",
		[32] = "ui/fonts/noto_32",
		[38] = "ui/fonts/noto_38",
		[42] = "ui/fonts/noto_42",
		default = "ui/fonts/noto_42"
	}
end

function GuiTweakData:get_font_path(font, font_size)
	local font_paths = self.font_paths[font]

	if not font_paths then
		return font
	end

	if not font_size then
		return font_paths.default
	end

	for i = 1, 4 do
		if font_paths[font_size * i] then
			font_paths[font_size] = font_paths[font_size * i]

			return font_paths[font_size * i]
		end
	end

	for i = font_size + 1, font_size * 2 do
		if font_paths[i] then
			font_paths[font_size] = font_paths[i]

			return font_paths[i]
		end
	end

	debug_pause("[GuiTweakData:get_font_path] Falling back to the default for font " .. tostring(font) .. " with size " .. tostring(font_size), debug.traceback())

	return font_paths.default
end

function GuiTweakData:_setup_icons()
	self.icons = {
		credits_logo_lgl = {}
	}
	self.icons.credits_logo_lgl.texture = "ui/atlas/raid_atlas_misc"
	self.icons.credits_logo_lgl.texture_rect = {
		2,
		866,
		448,
		448
	}
	self.icons.credits_logo_sb = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			452,
			866,
			448,
			448
		}
	}
	self.icons.raid_hw_logo_small = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			2,
			1316,
			400,
			242
		}
	}
	self.icons.raid_logo_big = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			2,
			2,
			880,
			430
		}
	}
	self.icons.raid_logo_small = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			2,
			1560,
			384,
			192
		}
	}
	self.icons.raid_se_logo_big = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			2,
			434,
			880,
			430
		}
	}
	self.icons.raid_se_logo_small = {
		texture = "ui/atlas/raid_atlas_misc",
		texture_rect = {
			404,
			1316,
			400,
			242
		}
	}
	self.icons.breadcumb_indicator = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			576,
			352,
			32,
			32
		}
	}
	self.icons.btn_circ_lock = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			741,
			452,
			48,
			48
		}
	}
	self.icons.btn_circ_lock_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			610,
			452,
			48,
			48
		}
	}
	self.icons.btn_circ_x = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			664,
			502,
			48,
			48
		}
	}
	self.icons.btn_circ_x_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			714,
			502,
			48,
			48
		}
	}
	self.icons.btn_dissabled_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			610,
			302,
			192,
			48
		}
	}
	self.icons.btn_dissabled_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			804,
			302,
			192,
			48
		}
	}
	self.icons.btn_dissabled_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			2,
			256,
			48
		}
	}
	self.icons.btn_dissabled_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			2,
			256,
			48
		}
	}
	self.icons.btn_list_rect = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			372,
			726,
			116,
			94
		}
	}
	self.icons.btn_list_rect_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			458,
			888,
			116,
			94
		}
	}
	self.icons.btn_primary_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			610,
			352,
			192,
			48
		}
	}
	self.icons.btn_primary_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			804,
			352,
			192,
			48
		}
	}
	self.icons.btn_primary_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			52,
			256,
			48
		}
	}
	self.icons.btn_primary_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			52,
			256,
			48
		}
	}
	self.icons.btn_purchase_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			610,
			402,
			192,
			48
		}
	}
	self.icons.btn_purchase_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			804,
			402,
			192,
			48
		}
	}
	self.icons.btn_purchase_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			102,
			256,
			48
		}
	}
	self.icons.btn_purchase_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			102,
			256,
			48
		}
	}
	self.icons.btn_secondary_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			452,
			192,
			48
		}
	}
	self.icons.btn_secondary_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			502,
			192,
			48
		}
	}
	self.icons.btn_secondary_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			152,
			256,
			48
		}
	}
	self.icons.btn_secondary_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			152,
			256,
			48
		}
	}
	self.icons.btn_small_128 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			534,
			678,
			128,
			40
		}
	}
	self.icons.btn_small_128_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			982,
			128,
			40
		}
	}
	self.icons.btn_tetriary_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			552,
			192,
			48
		}
	}
	self.icons.btn_tetriary_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			602,
			192,
			48
		}
	}
	self.icons.btn_tetriary_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			202,
			256,
			48
		}
	}
	self.icons.btn_tetriary_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			202,
			256,
			48
		}
	}
	self.icons.btn_tetriary_disabled_192 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			652,
			192,
			48
		}
	}
	self.icons.btn_tetriary_disabled_192_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			830,
			702,
			192,
			48
		}
	}
	self.icons.btn_tetriary_disabled_256 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			252,
			256,
			48
		}
	}
	self.icons.btn_tetriary_disabled_256_hover = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			748,
			252,
			256,
			48
		}
	}
	self.icons.card_counter_bg = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			654,
			786,
			51,
			32
		}
	}
	self.icons.card_counter_bg_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			389,
			822,
			102,
			64
		}
	}
	self.icons.cc_empty_slot_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			98,
			452,
			272,
			388
		}
	}
	self.icons.cc_empty_slot_small = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			332,
			2,
			156,
			222
		}
	}
	self.icons.character_creation_1_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			584,
			502,
			48,
			48
		}
	}
	self.icons.character_creation_2_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			584,
			552,
			48,
			48
		}
	}
	self.icons.character_creation_2_small = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			584,
			602,
			48,
			48
		}
	}
	self.icons.character_creation_checked = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			634,
			552,
			48,
			48
		}
	}
	self.icons.character_creation_nationality_american = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			401,
			226,
			52,
			52
		}
	}
	self.icons.character_creation_nationality_british = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			401,
			280,
			52,
			52
		}
	}
	self.icons.character_creation_nationality_german = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			522,
			302,
			52,
			52
		}
	}
	self.icons.character_creation_nationality_russian = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			790,
			820,
			52,
			52
		}
	}
	self.icons.charsel_default_lower = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			129,
			230,
			134,
			134
		}
	}
	self.icons.charsel_default_upper = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			265,
			230,
			134,
			134
		}
	}
	self.icons.checkbox_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			576,
			386,
			32,
			32
		}
	}
	self.icons.checkbox_check_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			342,
			998,
			20,
			20
		}
	}
	self.icons.consumable_purchased_confirmed = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			634,
			602,
			48,
			48
		}
	}
	self.icons.gold_amount_footer = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			576,
			420,
			32,
			32
		}
	}
	self.icons.gold_amount_purchase = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			720,
			752,
			32,
			32
		}
	}
	self.icons.hslider_arrow_left_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			754,
			752,
			32,
			32
		}
	}
	self.icons.hslider_arrow_right_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			759,
			786,
			32,
			32
		}
	}
	self.icons.ico_arrow_large_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			874,
			52,
			52
		}
	}
	self.icons.ico_arrow_large_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			844,
			820,
			52,
			52
		}
	}
	self.icons.ico_bonus = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			576,
			887,
			64,
			64
		}
	}
	self.icons.ico_class_assault = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			826,
			928,
			52,
			52
		}
	}
	self.icons.ico_class_demolitions = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			846,
			874,
			52,
			52
		}
	}
	self.icons.ico_class_infiltrator = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			898,
			820,
			52,
			52
		}
	}
	self.icons.ico_class_recon = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			880,
			928,
			52,
			52
		}
	}
	self.icons.ico_difficulty_deathwish = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			664,
			452,
			75,
			48
		}
	}
	self.icons.ico_difficulty_hard = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			684,
			552,
			48,
			48
		}
	}
	self.icons.ico_difficulty_normal = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			734,
			552,
			48,
			48
		}
	}
	self.icons.ico_difficulty_overkill = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			684,
			602,
			48,
			48
		}
	}
	self.icons.ico_difficulty_very_hard = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			734,
			602,
			48,
			48
		}
	}
	self.icons.ico_dlc = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			788,
			752,
			32,
			32
		}
	}
	self.icons.ico_filter = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			793,
			786,
			32,
			32
		}
	}
	self.icons.ico_flag_american = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			486,
			480,
			96,
			64
		}
	}
	self.icons.ico_flag_british = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			486,
			546,
			96,
			64
		}
	}
	self.icons.ico_flag_empty = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			486,
			612,
			96,
			64
		}
	}
	self.icons.ico_flag_german = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			726,
			96,
			64
		}
	}
	self.icons.ico_flag_russian = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			493,
			821,
			96,
			64
		}
	}
	self.icons.ico_info = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			458,
			984,
			36,
			36
		}
	}
	self.icons.ico_intel = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			496,
			984,
			36,
			36
		}
	}
	self.icons.ico_locker = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			822,
			752,
			32,
			32
		}
	}
	self.icons.ico_lower_body = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			455,
			258,
			33,
			33
		}
	}
	self.icons.ico_malus = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			610,
			953,
			64,
			64
		}
	}
	self.icons.ico_map = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			534,
			984,
			36,
			36
		}
	}
	self.icons.ico_map_mini_raid = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			572,
			984,
			36,
			36
		}
	}
	self.icons.ico_map_raid = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			452,
			36,
			36
		}
	}
	self.icons.ico_map_starting_point = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			490,
			36,
			36
		}
	}
	self.icons.ico_nav_back_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			528,
			36,
			36
		}
	}
	self.icons.ico_nav_right_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			566,
			36,
			36
		}
	}
	self.icons.ico_operation = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			157,
			842,
			56,
			56
		}
	}
	self.icons.ico_ops_card = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			604,
			36,
			36
		}
	}
	self.icons.ico_page_turn_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			827,
			786,
			32,
			32
		}
	}
	self.icons.ico_page_turn_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			856,
			752,
			32,
			32
		}
	}
	self.icons.ico_play_audio = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			792,
			642,
			36,
			36
		}
	}
	self.icons.ico_raid = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			215,
			842,
			56,
			56
		}
	}
	self.icons.ico_sel_rect_bottom_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			458,
			226,
			30,
			30
		}
	}
	self.icons.ico_sel_rect_bottom_right_white = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			302,
			30,
			30
		}
	}
	self.icons.ico_sel_rect_small_bottom_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			440,
			998,
			16,
			16
		}
	}
	self.icons.ico_sel_rect_small_bottom_right_white = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			129,
			432,
			16,
			16
		}
	}
	self.icons.ico_sel_rect_small_top_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			147,
			432,
			16,
			16
		}
	}
	self.icons.ico_sel_rect_small_top_left_white = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			165,
			432,
			16,
			16
		}
	}
	self.icons.ico_sel_rect_top_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			788,
			714,
			30,
			30
		}
	}
	self.icons.ico_sel_rect_top_left_white = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			929,
			786,
			30,
			30
		}
	}
	self.icons.ico_server = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			576,
			302,
			32,
			48
		}
	}
	self.icons.ico_slider_thumb = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			861,
			786,
			32,
			32
		}
	}
	self.icons.ico_slider_thumb_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			890,
			752,
			32,
			32
		}
	}
	self.icons.ico_time = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			742,
			988,
			34,
			34
		}
	}
	self.icons.ico_upper_body = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			455,
			293,
			33,
			33
		}
	}
	self.icons.ico_voice_chat = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			895,
			786,
			32,
			32
		}
	}
	self.icons.icon_loot_won = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			129,
			2,
			201,
			226
		}
	}
	self.icons.icon_paper_stamp_consumable = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			2,
			902,
			112,
			112
		}
	}
	self.icons.icon_paper_stamp_consumable_ver002 = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			116,
			900,
			112,
			112
		}
	}
	self.icons.icon_weapon_unlocked = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			490,
			792,
			40,
			27
		}
	}
	self.icons.if_center_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			104,
			10,
			48
		}
	}
	self.icons.if_left_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			154,
			10,
			48
		}
	}
	self.icons.if_right_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			204,
			10,
			48
		}
	}
	self.icons.info_icon = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			924,
			752,
			32,
			32
		}
	}
	self.icons.kb_center_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			254,
			10,
			32
		}
	}
	self.icons.kb_left_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			288,
			10,
			32
		}
	}
	self.icons.kb_right_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			387,
			366,
			10,
			32
		}
	}
	self.icons.list_btn_ico_customize = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			958,
			752,
			30,
			30
		}
	}
	self.icons.list_btn_ico_shirt = {
		texture = "ui/atlas/raid_atlas_menu_2",
		texture_rect = {
			1,
			1,
			30,
			30
		}
	}
	self.icons.list_btn_ico_rename = {
		texture = "ui/atlas/raid_atlas_menu_2",
		texture_rect = {
			33,
			1,
			30,
			30
		}
	}
	self.icons.list_btn_ico_globe = {
		texture = "ui/atlas/raid_atlas_menu_2",
		texture_rect = {
			1,
			33,
			30,
			30
		}
	}
	self.icons.list_btn_ico_plus = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			961,
			784,
			30,
			30
		}
	}
	self.icons.list_btn_ico_x = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			990,
			752,
			30,
			30
		}
	}
	self.icons.loading_revolver_circle = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			183,
			432,
			10,
			10
		}
	}
	self.icons.loot_meter_parts_l = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			134,
			1014,
			4,
			8
		}
	}
	self.icons.loot_meter_parts_m = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			140,
			1014,
			4,
			8
		}
	}
	self.icons.loot_meter_parts_r = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			146,
			1014,
			4,
			8
		}
	}
	self.icons.loot_rarity_common = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			273,
			842,
			56,
			56
		}
	}
	self.icons.loot_rarity_halloween = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			98,
			842,
			57,
			56
		}
	}
	self.icons.loot_rarity_rare = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			331,
			842,
			56,
			56
		}
	}
	self.icons.loot_rarity_uncommon = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			515,
			422,
			56,
			56
		}
	}
	self.icons.players_icon_gamecard = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			664,
			680,
			32,
			32
		}
	}
	self.icons.players_icon_kick = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			698,
			680,
			32,
			32
		}
	}
	self.icons.players_icon_mute = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			720,
			714,
			32,
			32
		}
	}
	self.icons.players_icon_outline = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			486,
			678,
			46,
			46
		}
	}
	self.icons.players_icon_unmute = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			732,
			680,
			32,
			32
		}
	}
	self.icons.players_icon_xbox_invite = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			754,
			714,
			32,
			32
		}
	}
	self.icons.ready_up_card_not_selected = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			282,
			998,
			18,
			24
		}
	}
	self.icons.ready_up_card_selected_active = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			302,
			998,
			18,
			24
		}
	}
	self.icons.ready_up_card_selected_inactive = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			322,
			998,
			18,
			24
		}
	}
	self.icons.rewards_dog_tags = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			230,
			900,
			112,
			96
		}
	}
	self.icons.rewards_dog_tags_small = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			588,
			720,
			64,
			64
		}
	}
	self.icons.rewards_extra_loot = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			344,
			900,
			112,
			96
		}
	}
	self.icons.rewards_extra_loot_frame = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			372,
			432,
			112,
			96
		}
	}
	self.icons.rewards_extra_loot_middle_gold = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			401,
			334,
			112,
			96
		}
	}
	self.icons.rewards_extra_loot_middle_loot = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			372,
			530,
			112,
			96
		}
	}
	self.icons.rewards_extra_loot_small = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			591,
			820,
			64,
			64
		}
	}
	self.icons.rewards_extra_loot_small_frame = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			642,
			886,
			64,
			64
		}
	}
	self.icons.rewards_extra_loot_small_middle_gold = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			676,
			952,
			64,
			64
		}
	}
	self.icons.rewards_extra_loot_small_middle_loot = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			654,
			720,
			64,
			64
		}
	}
	self.icons.rewards_top_stats = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			372,
			628,
			112,
			96
		}
	}
	self.icons.saving_background = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			129,
			366,
			256,
			64
		}
	}
	self.icons.skill_placeholder = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			657,
			820,
			47,
			64
		}
	}
	self.icons.skill_warcry_placeholder = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			515,
			356,
			56,
			64
		}
	}
	self.icons.skl_bg_vline = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			95,
			452,
			1,
			448
		}
	}
	self.icons.skl_level_bg = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			95,
			2,
			32,
			448
		}
	}
	self.icons.skl_level_bg_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			2,
			2,
			91,
			448
		}
	}
	self.icons.skl_level_bg_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			2,
			452,
			91,
			448
		}
	}
	self.icons.slider_end_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			707,
			786,
			50,
			32
		}
	}
	self.icons.slider_end_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			778,
			988,
			50,
			32
		}
	}
	self.icons.slider_large_center = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			2,
			16,
			32
		}
	}
	self.icons.slider_large_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			36,
			16,
			32
		}
	}
	self.icons.slider_large_pin = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			998,
			302,
			6,
			48
		}
	}
	self.icons.slider_large_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			1006,
			70,
			16,
			32
		}
	}
	self.icons.slider_line_center_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			2,
			1016,
			4,
			4
		}
	}
	self.icons.slider_line_left_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			8,
			1016,
			4,
			4
		}
	}
	self.icons.slider_line_right_base = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			14,
			1016,
			4,
			4
		}
	}
	self.icons.slider_mid_center = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			364,
			998,
			10,
			20
		}
	}
	self.icons.slider_mid_dot = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			195,
			432,
			10,
			10
		}
	}
	self.icons.slider_mid_left = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			376,
			998,
			10,
			20
		}
	}
	self.icons.slider_mid_right = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			388,
			998,
			10,
			20
		}
	}
	self.icons.slider_pimple = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			116,
			1014,
			16,
			8
		}
	}
	self.icons.slider_pin = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			998,
			352,
			18,
			27
		}
	}
	self.icons.star_rating = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			400,
			998,
			18,
			18
		}
	}
	self.icons.star_rating_empty = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			420,
			998,
			18,
			18
		}
	}
	self.icons.star_rating_empty_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			230,
			998,
			24,
			24
		}
	}
	self.icons.star_rating_large = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			256,
			998,
			24,
			24
		}
	}
	self.icons.switch_bg = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			588,
			786,
			64,
			32
		}
	}
	self.icons.switch_thumb = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			766,
			680,
			32,
			32
		}
	}
	self.icons.warcry_berserk = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			900,
			874,
			52,
			52
		}
	}
	self.icons.warcry_cluster_truck = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			934,
			928,
			52,
			52
		}
	}
	self.icons.warcry_invisibility = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			952,
			818,
			52,
			52
		}
	}
	self.icons.warcry_sharpshooter = {
		texture = "ui/atlas/raid_atlas_menu",
		texture_rect = {
			954,
			872,
			52,
			52
		}
	}
	self.icons.wpn_skill_selected = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			0,
			0,
			80,
			108
		}
	}
	local wpnskl_x = 40
	self.icons.wpn_skill_blank = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 2,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_blank_part = deep_clone(self.icons.wpn_skill_blank)
	self.icons.wpn_skill_blank_part.texture_rect[2] = 54
	self.icons.wpn_skill_locked = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 3,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_locked_part = deep_clone(self.icons.wpn_skill_locked)
	self.icons.wpn_skill_locked_part.texture_rect[2] = 54
	self.icons.wpn_skill_unknown = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 4,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_unknown_part = deep_clone(self.icons.wpn_skill_unknown)
	self.icons.wpn_skill_unknown_part.texture_rect[2] = 54
	self.icons.wpn_skill_mag_size = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 5,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_mag_size_part = deep_clone(self.icons.wpn_skill_mag_size)
	self.icons.wpn_skill_mag_size_part.texture_rect[2] = 54
	self.icons.wpn_skill_accuracy = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 6,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_accuracy_part = deep_clone(self.icons.wpn_skill_accuracy)
	self.icons.wpn_skill_accuracy_part.texture_rect[2] = 54
	self.icons.wpn_skill_damage = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 7,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_damage_part = deep_clone(self.icons.wpn_skill_damage)
	self.icons.wpn_skill_damage_part.texture_rect[2] = 54
	self.icons.wpn_skill_stability = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 8,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_stability_part = deep_clone(self.icons.wpn_skill_stability)
	self.icons.wpn_skill_stability_part.texture_rect[2] = 54
	self.icons.wpn_skill_gold = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 9,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_gold_part = deep_clone(self.icons.wpn_skill_gold)
	self.icons.wpn_skill_gold_part.texture_rect[2] = 54
	self.icons.wpn_skill_spread = {
		texture = "ui/atlas/raid_atlas_wpn_upg",
		texture_rect = {
			wpnskl_x * 10,
			0,
			40,
			54
		}
	}
	self.icons.wpn_skill_spread_part = deep_clone(self.icons.wpn_skill_spread)
	self.icons.wpn_skill_spread_part.texture_rect[2] = 54
	self.icons.screen_1 = {
		texture = "ui/atlas/wip/raid_atlas_spec_hud",
		texture_rect = {
			1,
			1,
			1920,
			1080
		}
	}
	self.icons.screen_2 = {
		texture = "ui/atlas/wip/raid_atlas_spec_hud",
		texture_rect = {
			1,
			1083,
			1920,
			1080
		}
	}
	self.icons.screen_3 = {
		texture = "ui/atlas/wip/raid_atlas_spec_hud",
		texture_rect = {
			1,
			2165,
			1920,
			1080
		}
	}
	self.icons.card_common = {
		texture = "ui/atlas/raid_atlas_cards",
		texture_rect = {
			2,
			2,
			497,
			670
		}
	}
	self.icons.card_empty = {
		texture = "ui/atlas/raid_atlas_cards",
		texture_rect = {
			501,
			2,
			497,
			670
		}
	}
	self.icons.card_pass = {
		texture = "ui/atlas/raid_atlas_cards",
		texture_rect = {
			2,
			674,
			497,
			670
		}
	}
	self.icons.card_rare = {
		texture = "ui/atlas/raid_atlas_cards",
		texture_rect = {
			501,
			674,
			497,
			670
		}
	}
	self.icons.card_uncommon = {
		texture = "ui/atlas/raid_atlas_cards",
		texture_rect = {
			2,
			1346,
			497,
			670
		}
	}
	self.icons.difficulty_1 = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			2,
			76,
			64
		}
	}
	self.icons.difficulty_2 = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			80,
			2,
			76,
			64
		}
	}
	self.icons.difficulty_3 = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			158,
			2,
			76,
			64
		}
	}
	self.icons.difficulty_4 = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			236,
			2,
			76,
			64
		}
	}
	self.icons.difficulty_5 = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			314,
			2,
			76,
			64
		}
	}
	self.icons.dog_tags_ops = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			392,
			2,
			76,
			64
		}
	}
	self.icons.extra_loot = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			68,
			76,
			64
		}
	}
	self.icons.mission_raid_railyard_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			200,
			56,
			56
		}
	}
	self.icons.missions_art_storage = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			258,
			56,
			56
		}
	}
	self.icons.missions_bunkers = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			316,
			56,
			56
		}
	}
	self.icons.missions_camp = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			374,
			56,
			56
		}
	}
	self.icons.missions_menu_consumable_forest = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			432,
			56,
			56
		}
	}
	self.icons.missions_consumable_mission = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			60,
			200,
			56,
			56
		}
	}
	self.icons.missions_convoy = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			80,
			68,
			56,
			56
		}
	}
	self.icons.missions_hunters = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			80,
			126,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_1_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			60,
			258,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_2_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			60,
			316,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_3_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			60,
			374,
			56,
			56
		}
	}
	self.icons.missions_mini_raids_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			60,
			432,
			56,
			56
		}
	}
	self.icons.missions_operation_clear_skies_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			118,
			184,
			56,
			56
		}
	}
	self.icons.missions_operation_empty_slot_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			138,
			68,
			56,
			56
		}
	}
	self.icons.missions_operation_rhinegold_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			138,
			126,
			56,
			56
		}
	}
	self.icons.missions_operations_category_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			118,
			242,
			56,
			56
		}
	}
	self.icons.missions_raid_bank_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			118,
			300,
			56,
			56
		}
	}
	self.icons.missions_raid_bridge_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			118,
			358,
			56,
			56
		}
	}
	self.icons.missions_raid_castle_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			118,
			416,
			56,
			56
		}
	}
	self.icons.missions_raid_flaktower_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			196,
			68,
			56,
			56
		}
	}
	self.icons.missions_raid_radio_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			254,
			68,
			56,
			56
		}
	}
	self.icons.missions_raids_category_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			312,
			68,
			56,
			56
		}
	}
	self.icons.missions_silo = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			370,
			68,
			56,
			56
		}
	}
	self.icons.missions_spies = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			428,
			68,
			56,
			56
		}
	}
	self.icons.missions_tank_depot = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			196,
			126,
			56,
			56
		}
	}
	self.icons.missions_kelly = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			312,
			126,
			56,
			56
		}
	}
	self.icons.missions_fury_railway = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			368,
			126,
			56,
			56
		}
	}
	self.icons.missions_tutorial = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			254,
			126,
			56,
			56
		}
	}
	self.icons.server_menu = {
		texture = "ui/atlas/raid_atlas_missions",
		texture_rect = {
			2,
			134,
			76,
			64
		}
	}
	self.icons.icon_intel_tape_01 = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			386,
			1653,
			192,
			64
		}
	}
	self.icons.icon_intel_tape_02 = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			500,
			1539,
			192,
			64
		}
	}
	self.icons.icon_paper_stamp = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			386,
			1539,
			112,
			112
		}
	}
	self.icons.paper_intel = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			1065,
			1388,
			891,
			621
		}
	}
	self.icons.paper_mission_book = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			2,
			2,
			1061,
			1535
		}
	}
	self.icons.paper_reward_large = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			1065,
			2,
			955,
			1384
		}
	}
	self.icons.paper_reward_small = {
		texture = "ui/atlas/raid_atlas_papers",
		texture_rect = {
			2,
			1539,
			382,
			448
		}
	}
	self.icons.rwd_card_pack = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			2,
			112,
			96
		}
	}
	self.icons.rwd_gold_bar = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			324,
			1754,
			112,
			96
		}
	}
	self.icons.rwd_gold_bars = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			100,
			112,
			96
		}
	}
	self.icons.rwd_gold_crate = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			324,
			1852,
			112,
			96
		}
	}
	self.icons.rwd_grenade = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			324,
			1950,
			112,
			96
		}
	}
	self.icons.rwd_grenade_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			2,
			2,
			436,
			436
		}
	}
	self.icons.rwd_lower_body = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			198,
			112,
			96
		}
	}
	self.icons.rwd_lower_body_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			2,
			440,
			436,
			436
		}
	}
	self.icons.rwd_melee = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			296,
			112,
			96
		}
	}
	self.icons.rwd_melee_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			440,
			2,
			436,
			436
		}
	}
	self.icons.rwd_stats_bg = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			440,
			1202,
			578,
			167
		}
	}
	self.icons.rwd_upper_body = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			394,
			112,
			96
		}
	}
	self.icons.rwd_upper_body_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			2,
			878,
			436,
			436
		}
	}
	self.icons.rwd_weapon = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			492,
			112,
			96
		}
	}
	self.icons.rwd_weapon_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			440,
			440,
			436,
			436
		}
	}
	self.icons.rwd_xp = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			878,
			590,
			112,
			96
		}
	}
	self.icons.rwd_xp_large = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			2,
			1316,
			436,
			436
		}
	}
	self.icons.xp_double_unlock = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			440,
			1371,
			316,
			353
		}
	}
	self.icons.xp_failure = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			440,
			878,
			521,
			322
		}
	}
	self.icons.xp_skill_set = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			758,
			1371,
			249,
			324
		}
	}
	self.icons.xp_weapon = {
		texture = "ui/atlas/raid_atlas_reward",
		texture_rect = {
			2,
			1754,
			320,
			286
		}
	}
	self.icons.bonus_bg_flag = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			2,
			2,
			256,
			480
		}
	}
	self.icons.bonus_bg_flag_fail = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			2,
			484,
			256,
			480
		}
	}
	self.icons.bonus_highest_accu = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			490,
			2,
			160,
			160
		}
	}
	self.icons.bonus_highest_accu_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			422,
			232,
			64,
			64
		}
	}
	self.icons.bonus_least_bleedout = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			652,
			2,
			160,
			160
		}
	}
	self.icons.bonus_least_bleedout_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			422,
			298,
			64,
			64
		}
	}
	self.icons.bonus_least_health_lost = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			814,
			2,
			160,
			160
		}
	}
	self.icons.bonus_least_health_lost_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			422,
			364,
			64,
			64
		}
	}
	self.icons.bonus_most_ammo_looted = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			490,
			164,
			160,
			160
		}
	}
	self.icons.bonus_most_ammo_looted_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			422,
			430,
			64,
			64
		}
	}
	self.icons.bonus_most_bleedouts = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			232,
			160,
			160
		}
	}
	self.icons.bonus_most_bleedouts_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			634,
			64,
			64
		}
	}
	self.icons.bonus_most_headshots = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			652,
			164,
			160,
			160
		}
	}
	self.icons.bonus_most_headshots_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			700,
			64,
			64
		}
	}
	self.icons.bonus_most_health_looted = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			814,
			164,
			160,
			160
		}
	}
	self.icons.bonus_most_health_looted_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			766,
			64,
			64
		}
	}
	self.icons.bonus_most_kills = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			488,
			326,
			160,
			160
		}
	}
	self.icons.bonus_most_kills_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			832,
			64,
			64
		}
	}
	self.icons.bonus_most_revives = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			394,
			160,
			160
		}
	}
	self.icons.bonus_most_revives_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			898,
			64,
			64
		}
	}
	self.icons.bonus_most_specials_killed = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			650,
			326,
			160,
			160
		}
	}
	self.icons.bonus_most_specials_killed_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			326,
			634,
			64,
			64
		}
	}
	self.icons.bonus_most_warcries_used = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			812,
			326,
			160,
			160
		}
	}
	self.icons.bonus_most_warcries_used_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			338,
			556,
			64,
			64
		}
	}
	self.icons.reward_loot = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			2,
			228,
			228
		}
	}
	self.icons.reward_loot_small = {
		texture = "ui/atlas/raid_atlas_bonus_loot",
		texture_rect = {
			260,
			556,
			76,
			76
		}
	}
end

function GuiTweakData:_setup_menu_elements_icons()
	self.icons.gold_bar_single = {
		texture = "ui/elements/gold_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.gold_bar_3 = {
		texture = "ui/elements/gold_3x_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.gold_bar_box = {
		texture = "ui/elements/gold_box_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.loot_crate_default = {
		texture = "ui/elements/reward_crate_default_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.loot_crate_bronze = {
		texture = "ui/elements/reward_crate_bronze_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.loot_crate_silver = {
		texture = "ui/elements/reward_crate_silver_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.loot_crate_gold = {
		texture = "ui/elements/reward_crate_gold_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.loot_greed_items = {
		texture = "ui/elements/gold_loot_hud",
		texture_rect = {
			0,
			0,
			1024,
			512
		}
	}
	self.icons.outlaw_raid_hud_item = {
		texture = "ui/elements/outlaw_raid_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
end

function GuiTweakData:_setup_radial_icons()
	self.icons.interact_lockpick_tool = {
		texture = "ui/hud/parts/interact_lockpick_tool_hud",
		texture_rect = {
			0,
			0,
			256,
			256
		}
	}
	self.icons.interact_lockpick_circles = {
		{}
	}
	self.icons.interact_lockpick_circles[1].texture = "ui/hud/parts/interact_lockpick_circle_1_hud"
	self.icons.interact_lockpick_circles[1].texture_rect = {
		0,
		0,
		256,
		256
	}
	self.icons.interact_lockpick_circles[2] = {
		texture = "ui/hud/parts/interact_lockpick_circle_2_hud",
		texture_rect = {
			0,
			0,
			256,
			256
		}
	}
	self.icons.interact_lockpick_circles[3] = {
		texture = "ui/hud/parts/interact_lockpick_circle_3_hud",
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self.icons.teammate_circle_fill_small = {
		texture = "ui/hud/parts/meters_ai_downed_and_objective_countdown_fill_hud",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.icons.teammate_circle_fill_medium = {
		texture = "ui/hud/parts/meters_teammate_downed_fill_hud",
		texture_rect = {
			0,
			0,
			128,
			128
		}
	}
	self.icons.objective_timer_watch = {
		texture = "ui/hud/parts/objective_timer_watch",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.icons.teammate_circle_fill_large = {
		texture = "ui/hud/parts/meters_downed_fill_hud",
		texture_rect = {
			0,
			0,
			128,
			128
		}
	}
	self.icons.teammate_interact_fill_large = {
		texture = "ui/hud/parts/player_panel_interaction_teammate_fill_hud",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.icons.objective_progress_fill = {
		texture = "ui/hud/parts/meters_objective_progress_fill_hud",
		texture_rect = {
			0,
			0,
			64,
			64
		}
	}
	self.icons.stamina_bar_fill = {
		texture = "ui/hud/parts/meters_stamina_fill_hud",
		texture_rect = {
			0,
			0,
			128,
			128
		}
	}
	self.icons.warcry_bar_fill = {
		texture = "ui/hud/parts/meters_warccry_fill_hud",
		texture_rect = {
			0,
			0,
			128,
			128
		}
	}
	self.icons.comm_wheel_circle = {
		texture = "ui/hud/parts/comm_wheel_circle_hud",
		texture_rect = {
			0,
			0,
			256,
			256
		}
	}
	self.icons.stealth_eye_fill = {
		texture = "ui/hud/parts/stealth_eye_in_hud",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
end

function GuiTweakData:_setup_hud_icons()
	self.icons.backgrounds_skill_desc_1 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			0,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_2 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			64,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_3 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			128,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_4 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			192,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_5 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			256,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_6 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			320,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_7 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			384,
			256,
			64
		}
	}
	self.icons.backgrounds_skill_desc_8 = {
		texture = "ui/atlas/raid_atlas_skill_desc_bg",
		texture_rect = {
			0,
			448,
			256,
			64
		}
	}
	self.icons.aa_gun_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1355,
			384,
			54
		}
	}
	self.icons.aa_gun_flak = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			731,
			1281,
			154,
			28
		}
	}
	self.icons.backgrounds_chat_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1165,
			384,
			432
		}
	}
	self.icons.backgrounds_detected_msg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1411,
			380,
			68
		}
	}
	self.icons.backgrounds_equipment_panel_msg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1481,
			380,
			68
		}
	}
	self.icons.backgrounds_health_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1255,
			288,
			10
		}
	}
	self.icons.backgrounds_machine_gun_empty = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1599,
			380,
			50
		}
	}
	self.icons.backgrounds_toast_mission_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1069,
			660,
			94
		}
	}
	self.icons.backgrounds_toast_mission_bg_002 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			963,
			728,
			104
		}
	}
	self.icons.backgrounds_vehicle_bags_weight = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			863,
			1419,
			10,
			84
		}
	}
	self.icons.backgrounds_vehicle_damage_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			663,
			1135,
			64,
			10
		}
	}
	self.icons.backgrounds_warcry_msg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1551,
			380,
			68
		}
	}
	self.icons.backgrounds_weapon_counter_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1045,
			54,
			34
		}
	}
	self.icons.bullet_active = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			713,
			1227,
			16,
			16
		}
	}
	self.icons.bullet_empty = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			713,
			1245,
			16,
			16
		}
	}
	self.icons.car_slot_empty = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1165,
			32,
			32
		}
	}
	self.icons.carry_alive = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			887,
			1281,
			72,
			72
		}
	}
	self.icons.carry_bag = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1279,
			72,
			72
		}
	}
	self.icons.carry_corpse = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			461,
			1279,
			72,
			72
		}
	}
	self.icons.carry_flak_shell = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			535,
			1279,
			72,
			72
		}
	}
	self.icons.carry_gold = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			877,
			1399,
			72,
			72
		}
	}
	self.icons.carry_painting = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			951,
			1405,
			72,
			72
		}
	}
	self.icons.carry_planks = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			875,
			1473,
			72,
			72
		}
	}
	self.icons.chat_input_rounded_rect = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1201,
			324,
			52
		}
	}
	self.icons.comm_wheel_assistance = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1081,
			52,
			52
		}
	}
	self.icons.comm_wheel_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1,
			960,
			960
		}
	}
	self.icons.comm_wheel_enemy = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1135,
			52,
			52
		}
	}
	self.icons.comm_wheel_follow_me = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1189,
			52,
			52
		}
	}
	self.icons.comm_wheel_found_it = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1243,
			52,
			52
		}
	}
	self.icons.comm_wheel_no = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			663,
			1147,
			52,
			52
		}
	}
	self.icons.comm_wheel_not_here = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			677,
			1263,
			52,
			52
		}
	}
	self.icons.comm_wheel_triangle = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1297,
			52,
			52
		}
	}
	self.icons.comm_wheel_wait = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			1351,
			52,
			52
		}
	}
	self.icons.comm_wheel_yes = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			949,
			1479,
			52,
			52
		}
	}
	self.icons.coom_wheel_line = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1017,
			1045,
			6,
			242
		}
	}
	self.icons.equipment_panel_code_book = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			421,
			1165,
			32,
			32
		}
	}
	self.icons.equipment_panel_code_device = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			455,
			1165,
			32,
			32
		}
	}
	self.icons.equipment_panel_crowbar = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			489,
			1165,
			32,
			32
		}
	}
	self.icons.equipment_panel_cvy_landimine = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			523,
			1165,
			32,
			32
		}
	}
	self.icons.equipment_panel_cvy_thermite = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			557,
			1165,
			32,
			32
		}
	}
	self.icons.equipment_panel_dynamite = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			609,
			1317,
			32,
			32
		}
	}
	self.icons.equipment_panel_dynamite_stick = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			643,
			1279,
			32,
			32
		}
	}
	self.icons.equipment_panel_fuel_empty = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			609,
			1279,
			32,
			32
		}
	}
	self.icons.equipment_panel_fuel_full = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			643,
			1313,
			32,
			32
		}
	}
	self.icons.equipment_panel_gold = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			677,
			1317,
			32,
			32
		}
	}
	self.icons.equipment_panel_parachute = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			327,
			1705,
			32,
			32
		}
	}
	self.icons.equipment_panel_portable_radio = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			361,
			1705,
			32,
			32
		}
	}
	self.icons.equipment_panel_recording_device = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			977,
			1723,
			32,
			32
		}
	}
	self.icons.equipment_panel_sps_briefcase = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			977,
			1757,
			32,
			32
		}
	}
	self.icons.equipment_panel_sps_interaction_key = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			649,
			1717,
			32,
			32
		}
	}
	self.icons.equipment_panel_sto_safe_key = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			683,
			1717,
			32,
			32
		}
	}
	self.icons.equipment_panel_tools = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			717,
			1717,
			32,
			32
		}
	}
	self.icons.hud_notification_tier_t1 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1813,
			40,
			54
		}
	}
	self.icons.hud_notification_tier_t2 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1869,
			40,
			54
		}
	}
	self.icons.hud_notification_tier_t3 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1925,
			40,
			54
		}
	}
	self.icons.hud_notification_tier_t4 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1981,
			40,
			54
		}
	}
	self.icons.interaction_hold_meter_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			387,
			1267,
			288,
			10
		}
	}
	self.icons.interaction_key_left = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			717,
			1147,
			12,
			38
		}
	}
	self.icons.interaction_key_middle = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			717,
			1187,
			12,
			38
		}
	}
	self.icons.interaction_key_right = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			869,
			1311,
			12,
			38
		}
	}
	self.icons.machine_gun_full = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			383,
			1621,
			380,
			50
		}
	}
	self.icons.machine_gun_solo = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1011,
			1479,
			10,
			50
		}
	}
	self.icons.miissions_raid_flaktower = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			1,
			56,
			56
		}
	}
	self.icons.mission_camp = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			59,
			56,
			56
		}
	}
	self.icons.missions_consumable_forest = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			117,
			56,
			56
		}
	}
	self.icons.missions_consumable_mission = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			175,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_1 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			233,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_2 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			291,
			56,
			56
		}
	}
	self.icons.missions_mini_raid_3 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			349,
			56,
			56
		}
	}
	self.icons.missions_mini_raids = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			407,
			56,
			56
		}
	}
	self.icons.missions_operation_clear_skies = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			465,
			56,
			56
		}
	}
	self.icons.missions_operation_rhinegold = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			523,
			56,
			56
		}
	}
	self.icons.missions_operations_category = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			581,
			56,
			56
		}
	}
	self.icons.missions_raid_bank = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			639,
			56,
			56
		}
	}
	self.icons.missions_raid_bridge = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			697,
			56,
			56
		}
	}
	self.icons.missions_raid_castle = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			755,
			56,
			56
		}
	}
	self.icons.missions_raid_radio = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			813,
			56,
			56
		}
	}
	self.icons.missions_raid_railyard = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			871,
			56,
			56
		}
	}
	self.icons.missions_raids_category = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			963,
			929,
			56,
			56
		}
	}
	self.icons.nationality_small_american = {
		texture = "ui/atlas/raid_atlas_hud_nations",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.icons.nationality_small_british = {
		texture = "ui/atlas/raid_atlas_hud_nations",
		texture_rect = {
			0,
			32,
			32,
			32
		}
	}
	self.icons.nationality_small_german = {
		texture = "ui/atlas/raid_atlas_hud_nations",
		texture_rect = {
			0,
			64,
			32,
			32
		}
	}
	self.icons.nationality_small_russian = {
		texture = "ui/atlas/raid_atlas_hud_nations",
		texture_rect = {
			0,
			96,
			32,
			32
		}
	}
	self.icons.nationality_small_dr_reinhardt = {
		texture = "ui/atlas/raid_atlas_hud_nations",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.icons.notification_consumable = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			731,
			963,
			228,
			316
		}
	}
	self.icons.objecives_new_empty_frame = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			671,
			1673,
			42,
			42
		}
	}
	self.icons.objective_checked = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			759,
			1711,
			38,
			38
		}
	}
	self.icons.objective_progress_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			663,
			1069,
			64,
			64
		}
	}
	self.icons.objective_unchecked = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			799,
			1711,
			38,
			38
		}
	}
	self.icons.objectives_new_checked_red_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			715,
			1673,
			42,
			42
		}
	}
	self.icons.objectives_new_progress_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			883,
			1355,
			74,
			42
		}
	}
	self.icons.player_panel_ai_downed_and_objective_countdown_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1673,
			48,
			48
		}
	}
	self.icons.player_panel_class_assault = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			327,
			1651,
			52,
			52
		}
	}
	self.icons.player_panel_class_demolitions = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			43,
			1813,
			52,
			52
		}
	}
	self.icons.player_panel_class_infiltrator = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			43,
			1867,
			52,
			52
		}
	}
	self.icons.player_panel_class_recon = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			43,
			1921,
			52,
			52
		}
	}
	self.icons.player_panel_downed_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			773,
			1355,
			88,
			88
		}
	}
	self.icons.player_panel_host_indicator = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			959,
			1825,
			32,
			32
		}
	}
	self.icons.player_panel_interaction_teammate_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			961,
			987,
			56,
			56
		}
	}
	self.icons.player_panel_nationality_american = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			43,
			1975,
			52,
			52
		}
	}
	self.icons.player_panel_nationality_british = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			97,
			1807,
			52,
			52
		}
	}
	self.icons.player_panel_nationality_german = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			97,
			1861,
			52,
			52
		}
	}
	self.icons.player_panel_nationality_russian = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			97,
			1915,
			52,
			52
		}
	}
	self.icons.player_panel_stamina_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			769,
			1445,
			88,
			88
		}
	}
	self.icons.player_panel_status_dead_ai = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			97,
			1969,
			52,
			52
		}
	}
	self.icons.player_panel_status_lockpick = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			151,
			1807,
			52,
			52
		}
	}
	self.icons.player_panel_status_mounted_weapon = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			181,
			1739,
			52,
			52
		}
	}
	self.icons.player_panel_teammate_downed_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			1,
			1723,
			88,
			88
		}
	}
	self.icons.player_panel_warcry_berserk = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			151,
			1861,
			52,
			52
		}
	}
	self.icons.player_panel_warcry_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			91,
			1717,
			88,
			88
		}
	}
	self.icons.player_panel_warcry_cluster_truck = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			151,
			1915,
			52,
			52
		}
	}
	self.icons.player_panel_warcry_invisibility = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			151,
			1969,
			52,
			52
		}
	}
	self.icons.player_panel_warcry_sharpshooter = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			205,
			1793,
			52,
			52
		}
	}
	self.icons.vehicle_bags_weight_indicator = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			631,
			1179,
			12,
			12
		}
	}
	self.icons.view_more_key_left = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			869,
			1351,
			12,
			32
		}
	}
	self.icons.view_more_key_middle = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			711,
			1317,
			12,
			32
		}
	}
	self.icons.view_more_key_right = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			863,
			1385,
			12,
			32
		}
	}
	self.icons.vip_health_bg = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			591,
			1165,
			70,
			12
		}
	}
	self.icons.weapon_panel_ass_carbine = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			731,
			1311,
			136,
			42
		}
	}
	self.icons.weapon_panel_ass_garand = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			873,
			1547,
			136,
			42
		}
	}
	self.icons.weapon_panel_ass_mp44 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			873,
			1591,
			136,
			42
		}
	}
	self.icons.weapon_panel_gre_m24 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			769,
			1535,
			102,
			42
		}
	}
	self.icons.weapon_panel_hdm = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			869,
			1635,
			136,
			42
		}
	}
	self.icons.weapon_panel_indicator_rapid_fire = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			591,
			1179,
			18,
			18
		}
	}
	self.icons.weapon_panel_indicator_single_fire = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			611,
			1179,
			18,
			18
		}
	}
	self.icons.weapon_panel_indicator_shell_loaded = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.icons.weapon_panel_indicator_shell_spent = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			32,
			0,
			32,
			32
		}
	}
	self.icons.weapon_panel_indicator_shell_small_loaded = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			32,
			48,
			16,
			16
		}
	}
	self.icons.weapon_panel_indicator_shell_small_spent = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			48,
			48,
			16,
			16
		}
	}
	self.icons.weapon_panel_indicator_rifle_loaded = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			0,
			32,
			8,
			32
		}
	}
	self.icons.weapon_panel_indicator_rifle_spent = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			8,
			32,
			8,
			32
		}
	}
	self.icons.weapon_panel_indicator_9mm_loaded = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			16,
			48,
			8,
			16
		}
	}
	self.icons.weapon_panel_indicator_9mm_spent = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			24,
			48,
			8,
			16
		}
	}
	self.icons.weapon_panel_indicator_9mm_loaded_thin = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			32,
			32,
			4,
			16
		}
	}
	self.icons.weapon_panel_indicator_9mm_spent_thin = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			36,
			32,
			4,
			16
		}
	}
	self.icons.weapon_panel_indicator_drum_fg_ring = {
		texture = "ui/hud/atlas/ammo_icons_drum_fg",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.icons.weapon_panel_indicator_drum_bg_ring = {
		texture = "ui/hud/atlas/ammo_icons_drum_bg",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.icons.weapon_panel_indicator_drum_ooa_ring = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			16,
			32,
			16,
			16
		}
	}
	self.icons.weapon_panel_indicator_revolver_bullet = {
		texture = "ui/hud/atlas/ammo_icons",
		texture_rect = {
			40,
			40,
			8,
			8
		}
	}
	self.icons.weapon_panel_indicator_revolver_cyl6 = {
		texture = "ui/hud/atlas/ammo_icons_revolver_6",
		texture_rect = {
			0,
			0,
			32,
			32
		}
	}
	self.icons.weapon_panel_lmg_dp28 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			869,
			1679,
			136,
			42
		}
	}
	self.icons.weapon_panel_lmg_m1918 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			51,
			1673,
			136,
			42
		}
	}
	self.icons.weapon_panel_lmg_mg42 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			189,
			1651,
			136,
			42
		}
	}
	self.icons.weapon_panel_nagant_m1895 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			189,
			1695,
			136,
			42
		}
	}
	self.icons.weapon_panel_pis_c96 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			235,
			1739,
			136,
			42
		}
	}
	self.icons.weapon_panel_pis_m1911 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			205,
			1847,
			136,
			42
		}
	}
	self.icons.weapon_panel_pis_tt33 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			259,
			1783,
			136,
			42
		}
	}
	self.icons.weapon_panel_sho_1912 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			373,
			1739,
			136,
			42
		}
	}
	self.icons.weapon_panel_sho_geco = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			395,
			1673,
			136,
			42
		}
	}
	self.icons.weapon_panel_shotty = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			533,
			1673,
			136,
			42
		}
	}
	self.icons.weapon_panel_smg_mp38 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			839,
			1723,
			136,
			42
		}
	}
	self.icons.weapon_panel_smg_sten = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			511,
			1717,
			136,
			42
		}
	}
	self.icons.weapon_panel_smg_sterling = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			649,
			1751,
			136,
			42
		}
	}
	self.icons.weapon_panel_smg_thompson = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			511,
			1761,
			136,
			42
		}
	}
	self.icons.weapon_panel_snp_m1903 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			821,
			1767,
			136,
			42
		}
	}
	self.icons.weapon_panel_snp_mosin = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			649,
			1795,
			136,
			42
		}
	}
	self.icons.weapon_panel_welrod = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			821,
			1811,
			136,
			42
		}
	}
	self.icons.weapons_panel_bren = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			397,
			1805,
			136,
			42
		}
	}
	self.icons.weapons_panel_browning = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			535,
			1839,
			136,
			42
		}
	}
	self.icons.weapons_panel_enfield = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			673,
			1853,
			136,
			42
		}
	}
	self.icons.weapons_panel_gre_concrete = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			769,
			1579,
			102,
			42
		}
	}
	self.icons.weapons_panel_gre_d343 = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			765,
			1623,
			102,
			42
		}
	}
	self.icons.weapons_panel_gre_mills = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			765,
			1667,
			102,
			42
		}
	}
	self.icons.weapons_panel_itchaca = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			811,
			1855,
			136,
			42
		}
	}
	self.icons.weapons_panel_kar_98k = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			343,
			1849,
			136,
			42
		}
	}
	self.icons.weapons_panel_pis_webley = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			205,
			1891,
			136,
			42
		}
	}
	self.icons.weapons_panel_gre_decoy_coin = {
		texture = "ui/atlas/raid_atlas_hud",
		texture_rect = {
			238,
			1940,
			42,
			42
		}
	}
	self.icons.weapons_panel_gre_betty = {
		texture = "ui/atlas/raid_atlas_new_items",
		texture_rect = {
			96,
			0,
			42,
			42
		}
	}
	self.icons.missions_consumable_fury_railway = {
		texture = "ui/atlas/raid_atlas_hud_raids_mini",
		texture_rect = {
			4,
			4,
			56,
			56
		}
	}
end

function GuiTweakData:_setup_hud_accessibility_icons()
	local common_motion_dot_size = {
		0,
		0,
		32,
		32
	}
	self.icons.motion_dot = {
		texture = "ui/ingame/textures/hud/access_motion_dot",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_dot_contour = {
		texture = "ui/ingame/textures/hud/access_motion_dot_contour",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_dot_outline = {
		texture = "ui/ingame/textures/hud/access_motion_dot_outline",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_dot_inline = {
		texture = "ui/ingame/textures/hud/access_motion_dot",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_plus = {
		texture = "ui/ingame/textures/hud/access_motion_plus",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_plus_contour = {
		texture = "ui/ingame/textures/hud/access_motion_plus_contour",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_plus_outline = {
		texture = "ui/ingame/textures/hud/access_motion_plus_outline",
		texture_rect = common_motion_dot_size
	}
	self.icons.motion_plus_inline = {
		texture = "ui/ingame/textures/hud/access_motion_plus",
		texture_rect = common_motion_dot_size
	}
end

function GuiTweakData:_setup_hud_waypoint_icons()
	self.icons.damage_indicator_1 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			1,
			296,
			64
		}
	}
	self.icons.damage_indicator_2 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			67,
			296,
			64
		}
	}
	self.icons.damage_indicator_3 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			133,
			296,
			64
		}
	}
	self.icons.damage_indicator_4 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			199,
			296,
			64
		}
	}
	self.icons.indicator_head_shot = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			319,
			509,
			32,
			32
		}
	}
	self.icons.indicator_hit = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			281,
			512,
			32,
			32
		}
	}
	self.icons.indicator_pellet = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			0,
			992,
			32,
			32
		}
	}
	self.icons.indicator_pellet_head = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			32,
			992,
			32,
			32
		}
	}
	self.icons.indicator_pellet_crit = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			64,
			992,
			32,
			32
		}
	}
	self.icons.indicator_kill = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			353,
			509,
			32,
			32
		}
	}
	self.icons.map_state_alarm = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			377,
			167,
			72,
			72
		}
	}
	self.icons.map_state_alarm_1 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			447,
			331,
			64,
			64
		}
	}
	self.icons.map_state_alarm_2 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			149,
			265,
			64,
			64
		}
	}
	self.icons.map_state_alarm_3 = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			215,
			265,
			64,
			64
		}
	}
	self.icons.map_waypoint_pov_in = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			459,
			32,
			32
		}
	}
	self.icons.map_waypoint_pov_out = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			451,
			251,
			38,
			38
		}
	}
	self.icons.map_waypoint_up_down = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			493,
			1,
			18,
			18
		}
	}
	self.icons.stealth_alarm_icon = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			299,
			89,
			76,
			76
		}
	}
	self.icons.stealth_alarm_in = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			377,
			89,
			76,
			76
		}
	}
	self.icons.stealth_alarm_out = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			299,
			167,
			76,
			76
		}
	}
	self.icons.stealth_eye_bg = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			455,
			89,
			52,
			52
		}
	}
	self.icons.stealth_eye_out = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			455,
			143,
			52,
			52
		}
	}
	self.icons.stealth_eye_prompt_icon = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			451,
			197,
			52,
			52
		}
	}
	self.icons.stealth_indicator_fill = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			299,
			1,
			192,
			42
		}
	}
	self.icons.stealth_indicator_stroke = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			299,
			45,
			192,
			42
		}
	}
	self.icons.stealth_triangle_empty = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			377,
			241,
			72,
			72
		}
	}
	self.icons.stealth_triangle_filled = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			299,
			245,
			72,
			72
		}
	}
	self.icons.stealth_triangle_filled_cropped = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			281,
			479,
			36,
			31
		}
	}
	self.icons.stealth_triangle_outside_left = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			373,
			315,
			72,
			72
		}
	}
	self.icons.stealth_triangle_outside_right = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			265,
			72,
			72
		}
	}
	self.icons.stealth_triangle_outside_top = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			75,
			265,
			72,
			72
		}
	}
	self.icons.waypoint_special_mark_flamer = {
		texture = "ui/hud/atlas/waypoint_atlas_02",
		texture_rect = {
			1,
			1,
			46,
			46
		}
	}
	self.icons.waypoint_special_mark_spotter = {
		texture = "ui/hud/atlas/waypoint_atlas_02",
		texture_rect = {
			49,
			1,
			46,
			46
		}
	}
	self.icons.waypoint_special_mark_officer = {
		texture = "ui/hud/atlas/waypoint_atlas_02",
		texture_rect = {
			1,
			49,
			46,
			46
		}
	}
	self.icons.waypoint_special_mark_sniper = {
		texture = "ui/hud/atlas/waypoint_atlas_02",
		texture_rect = {
			49,
			49,
			46,
			46
		}
	}
	self.icons.waypoint_special_aim = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			451,
			291,
			38,
			38
		}
	}
	self.icons.waypoint_special_air_strike = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			281,
			319,
			38,
			38
		}
	}
	self.icons.waypoint_special_ammo = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			321,
			319,
			38,
			38
		}
	}
	self.icons.waypoint_special_boat = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			149,
			331,
			38,
			38
		}
	}
	self.icons.waypoint_special_code_book = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			189,
			331,
			38,
			38
		}
	}
	self.icons.waypoint_special_code_device = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			229,
			331,
			38,
			38
		}
	}
	self.icons.waypoint_special_crowbar = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			269,
			359,
			38,
			38
		}
	}
	self.icons.waypoint_special_cvy_foxhole = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			309,
			359,
			38,
			38
		}
	}
	self.icons.waypoint_special_cvy_landimine = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			349,
			389,
			38,
			38
		}
	}
	self.icons.waypoint_special_defend = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			389,
			389,
			38,
			38
		}
	}
	self.icons.waypoint_special_dog_tags = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			429,
			397,
			38,
			38
		}
	}
	self.icons.waypoint_special_door = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			469,
			397,
			38,
			38
		}
	}
	self.icons.waypoint_special_downed = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			339,
			38,
			38
		}
	}
	self.icons.waypoint_special_dynamite_stick = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			41,
			339,
			38,
			38
		}
	}
	self.icons.waypoint_special_escape = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			81,
			339,
			38,
			38
		}
	}
	self.icons.waypoint_special_explosive = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			121,
			371,
			38,
			38
		}
	}
	self.icons.waypoint_special_fire = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			161,
			371,
			38,
			38
		}
	}
	self.icons.waypoint_special_fix = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			201,
			371,
			38,
			38
		}
	}
	self.icons.waypoint_special_general_vip_sit = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			241,
			399,
			38,
			38
		}
	}
	self.icons.waypoint_special_gereneral_vip_move = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			281,
			399,
			38,
			38
		}
	}
	self.icons.waypoint_special_gold = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			321,
			429,
			38,
			38
		}
	}
	self.icons.waypoint_special_health = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			361,
			429,
			38,
			38
		}
	}
	self.icons.waypoint_special_kill = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			401,
			437,
			38,
			38
		}
	}
	self.icons.waypoint_special_lockpick = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			441,
			437,
			38,
			38
		}
	}
	self.icons.waypoint_special_loot = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			379,
			38,
			38
		}
	}
	self.icons.waypoint_special_loot_drop = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			41,
			379,
			38,
			38
		}
	}
	self.icons.waypoint_special_parachute = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			81,
			379,
			38,
			38
		}
	}
	self.icons.waypoint_special_phone = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			121,
			411,
			38,
			38
		}
	}
	self.icons.waypoint_special_portable_radio = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			161,
			411,
			38,
			38
		}
	}
	self.icons.waypoint_special_power = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			201,
			411,
			38,
			38
		}
	}
	self.icons.waypoint_special_prisoner = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			241,
			439,
			38,
			38
		}
	}
	self.icons.waypoint_special_recording_device = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			281,
			439,
			38,
			38
		}
	}
	self.icons.waypoint_special_refuel = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			321,
			469,
			38,
			38
		}
	}
	self.icons.waypoint_special_refuel_empty = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			361,
			469,
			38,
			38
		}
	}
	self.icons.waypoint_special_key = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			401,
			477,
			38,
			38
		}
	}
	self.icons.waypoint_special_stash_box = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			441,
			477,
			38,
			38
		}
	}
	self.icons.waypoint_special_thermite = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			419,
			38,
			38
		}
	}
	self.icons.waypoint_special_tools = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			41,
			419,
			38,
			38
		}
	}
	self.icons.waypoint_special_valve = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			81,
			419,
			38,
			38
		}
	}
	self.icons.waypoint_special_vehicle_kugelwagen = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			121,
			451,
			38,
			38
		}
	}
	self.icons.waypoint_special_vehicle_truck = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			161,
			451,
			38,
			38
		}
	}
	self.icons.waypoint_special_wait = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			201,
			451,
			38,
			38
		}
	}
	self.icons.waypoint_special_where = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			241,
			479,
			38,
			38
		}
	}
	self.icons.waypoint_special_camp_mission_raid = {
		texture = "ui/hud/atlas/raid_atlas_waypoints",
		texture_rect = {
			1,
			491,
			32,
			32
		}
	}
end

function GuiTweakData:_setup_hud_reticles()
	self.icons.weapons_reticles_ass_carbine = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			1,
			76,
			76
		}
	}
	self.icons.weapons_reticles_ass_garand = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			79,
			1,
			76,
			76
		}
	}
	self.icons.weapons_reticles_ass_mp44 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			157,
			1,
			76,
			76
		}
	}
	self.icons.weapons_reticles_lmg_m1918 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			79,
			76,
			76
		}
	}
	self.icons.weapons_reticles_lmg_mg42 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			79,
			79,
			76,
			76
		}
	}
	self.icons.weapons_reticles_pis_c96 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			157,
			79,
			76,
			76
		}
	}
	self.icons.weapons_reticles_pis_m1911 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			157,
			76,
			76
		}
	}
	self.icons.weapons_reticles_sho_1912 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			79,
			157,
			76,
			76
		}
	}
	self.icons.weapons_reticles_smg_mp38 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			157,
			157,
			76,
			76
		}
	}
	self.icons.weapons_reticles_smg_sten = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			235,
			76,
			76
		}
	}
	self.icons.weapons_reticles_smg_sterling = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			79,
			235,
			76,
			76
		}
	}
	self.icons.weapons_reticles_smg_thompson = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			157,
			235,
			76,
			76
		}
	}
	self.icons.weapons_reticles_smg_thompson_upgraded = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			313,
			76,
			76
		}
	}
	self.icons.weapons_reticles_snp_m1903 = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			1,
			391,
			76,
			76
		}
	}
	self.icons.weapons_reticles_snp_mosin = {
		texture = "ui/hud/atlas/raid_atlas_reticles",
		texture_rect = {
			79,
			313,
			76,
			76
		}
	}
end

function GuiTweakData:_setup_map_icons()
	self.icons.map = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1,
			1,
			1098,
			1080
		}
	}
	self.icons.map_camp = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1507,
			1,
			52,
			52
		}
	}
	self.icons.map_gang = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1561,
			1,
			52,
			52
		}
	}
	self.icons.map_unknown_location = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1101,
			1,
			256,
			256
		}
	}
	self.icons.map_waypoint_map_kugelwagen = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1359,
			1,
			72,
			72
		}
	}
	self.icons.map_waypoint_map_truck = {
		texture = "ui/hud/atlas/raid_atlas_map",
		texture_rect = {
			1433,
			1,
			72,
			72
		}
	}
end

function GuiTweakData:_setup_skill_icons()
	self.icons.skills_dealing_damage_assault_rifle_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_critical_chance = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_extra_after_revive = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_headshot_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_heavy_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_melee_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			2,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_pistol_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			80,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_rifle_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			80,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_shotgun_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			80,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_smg_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			80,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_snp_multiplier = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			80,
			76,
			76
		}
	}
	self.icons.skills_dealing_damage_tagged_enemies = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			80,
			76,
			76
		}
	}
	self.icons.skills_general_faster_interaction = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			158,
			76,
			76
		}
	}
	self.icons.skills_general_faster_reload = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			158,
			76,
			76
		}
	}
	self.icons.skills_general_resist = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			158,
			76,
			76
		}
	}
	self.icons.skills_general_speed = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			158,
			76,
			76
		}
	}
	self.icons.skills_interaction_extra_ammo_pickups = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			158,
			76,
			76
		}
	}
	self.icons.skills_interaction_extra_health_pickups = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			158,
			76,
			76
		}
	}
	self.icons.skills_interaction_faster_place_explosive = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_less_damage_interact = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_one_fewer_wheel = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_pack_bags_faster = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_revive_teammates_faster = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_search_crates_faster = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			236,
			76,
			76
		}
	}
	self.icons.skills_interaction_wheel_hotspots_larger = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			314,
			76,
			76
		}
	}
	self.icons.skills_interaction_wheels_turn_faster = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			314,
			76,
			76
		}
	}
	self.icons.skills_navigation_increase_climbing_speed = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			314,
			76,
			76
		}
	}
	self.icons.skills_navigation_increase_crouch_speed = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			314,
			76,
			76
		}
	}
	self.icons.skills_navigation_increase_run_speed = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			314,
			76,
			76
		}
	}
	self.icons.skills_navigation_move_faster_bags = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			314,
			76,
			76
		}
	}
	self.icons.skills_navigation_player_sprint_longer = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			392,
			76,
			76
		}
	}
	self.icons.skills_navigation_stamina_regeneration = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			392,
			76,
			76
		}
	}
	self.icons.skills_navigation_stamina_reserve = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			392,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_increase_bleedout_time = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			392,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_increased_health = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			392,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_less_after_revive = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			392,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_less_melee = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			470,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_less_ranged_weapons = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			470,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_less_sprinting = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			470,
			76,
			76
		}
	}
	self.icons.skills_soaking_damage_less_while_crouch = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			470,
			76,
			76
		}
	}
	self.icons.skills_special_skills_increase_prim_ammo_capacity = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			470,
			76,
			76
		}
	}
	self.icons.skills_special_skills_increase_sec_ammo_capacity = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			470,
			76,
			76
		}
	}
	self.icons.skills_special_skills_mounted_guns_overheat = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			548,
			76,
			76
		}
	}
	self.icons.skills_special_skills_revive_range_teammates = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			626,
			76,
			76
		}
	}
	self.icons.skills_special_skills_scopes = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			704,
			76,
			76
		}
	}
	self.icons.skills_warcry_assault_berserk = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			782,
			76,
			76
		}
	}
	self.icons.skills_warcry_demolition_cluster_truck = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			860,
			76,
			76
		}
	}
	self.icons.skills_warcry_infilitrator_invisibility = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			2,
			938,
			76,
			76
		}
	}
	self.icons.skills_warcry_recon_sharpshooter = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			548,
			76,
			76
		}
	}
	self.icons.skills_weapon_tier_1 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			548,
			76,
			76
		}
	}
	self.icons.skills_weapon_tier_2 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			548,
			76,
			76
		}
	}
	self.icons.skills_weapon_tier_3 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			548,
			76,
			76
		}
	}
	self.icons.skills_weapon_tier_4 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			548,
			76,
			76
		}
	}
	self.icons.skills_weapons_carry_extra_granade = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			626,
			76,
			76
		}
	}
	self.icons.skills_weapons_ready_faster_after_sprint = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			704,
			76,
			76
		}
	}
	self.icons.skills_weapons_reduce_flinch_when_hit = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			782,
			76,
			76
		}
	}
	self.icons.skills_weapons_reduce_movement_penalty = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			860,
			76,
			76
		}
	}
	self.icons.skills_weapons_reduce_sway_when_ads = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			80,
			938,
			76,
			76
		}
	}
	self.icons.skills_weapons_reduce_time_to_ads = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			626,
			76,
			76
		}
	}
	self.icons.skills_weapons_switch_faster = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			626,
			76,
			76
		}
	}
	self.icons.warcry_assault_berserk_upgrade_dismemberment = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			626,
			76,
			76
		}
	}
	self.icons.warcry_assault_berserk_upgrade_increased_team_heal = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			626,
			76,
			76
		}
	}
	self.icons.warcry_assault_berserk_upgrade_low_health = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			704,
			76,
			76
		}
	}
	self.icons.warcry_common_upgrade_duration_lvl1 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			782,
			76,
			76
		}
	}
	self.icons.warcry_common_upgrade_duration_lvl2 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			860,
			76,
			76
		}
	}
	self.icons.warcry_common_upgrade_duration_lvl3 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			158,
			938,
			76,
			76
		}
	}
	self.icons.warcry_common_upgrade_duration_lvl4 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			704,
			76,
			76
		}
	}
	self.icons.warcry_demolition_cluster_truck_damage_resist = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			704,
			76,
			76
		}
	}
	self.icons.warcry_demolition_cluster_truck_granade = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			704,
			76,
			76
		}
	}
	self.icons.warcry_demolition_cluster_truck_kill_streak = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			782,
			76,
			76
		}
	}
	self.icons.warcry_insurgent_untouchable_short_range_bonus = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			860,
			76,
			76
		}
	}
	self.icons.warcry_insurgent_untouchable_upgrade_increased_move_speed = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			236,
			938,
			76,
			76
		}
	}
	self.icons.warcry_insurgent_untouchable_upgrade_melee = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			782,
			76,
			76
		}
	}
	self.icons.warcry_recon_sharpshooter_upgrade_headshot = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			392,
			782,
			76,
			76
		}
	}
	self.icons.warcry_recon_sharpshooter_upgrade_increased_damage = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			860,
			76,
			76
		}
	}
	self.icons.warcry_recon_sharpshooter_upgrade_long_range = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			314,
			938,
			76,
			76
		}
	}
	self.icons.weapon_upgrade_tier_1 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			470,
			2,
			38,
			42
		}
	}
	self.icons.weapon_upgrade_tier_2 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			470,
			46,
			38,
			42
		}
	}
	self.icons.weapon_upgrade_tier_3 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			470,
			90,
			38,
			42
		}
	}
	self.icons.weapon_upgrade_tier_4 = {
		texture = "ui/atlas/raid_atlas_skills",
		texture_rect = {
			470,
			134,
			38,
			42
		}
	}
end

function GuiTweakData:_setup_skill_big_icons()
	self.icons.experience_mission_fail_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			2,
			2,
			380,
			380
		}
	}
	self.icons.experience_no_progress_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			2,
			384,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_assault_rifle_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			2,
			766,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_critical_chance_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			2,
			1148,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_extra_after_revive_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			2,
			1530,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_headshot_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			384,
			2,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_heavy_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			766,
			2,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_melee_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1148,
			2,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_pistol_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1530,
			2,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_rifle_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			384,
			384,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_shotgun_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			384,
			766,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_smg_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			384,
			1148,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_snp_multiplier_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			384,
			1530,
			380,
			380
		}
	}
	self.icons.skills_dealing_damage_tagged_enemies_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			766,
			384,
			380,
			380
		}
	}
	self.icons.skills_interaction_extra_ammo_pickups_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1148,
			384,
			380,
			380
		}
	}
	self.icons.skills_interaction_extra_health_pickups_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1530,
			384,
			380,
			380
		}
	}
	self.icons.skills_interaction_faster_place_explosive_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			766,
			766,
			380,
			380
		}
	}
	self.icons.skills_interaction_less_damage_interact_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			766,
			1148,
			380,
			380
		}
	}
	self.icons.skills_interaction_one_fewer_wheel_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			766,
			1530,
			380,
			380
		}
	}
	self.icons.skills_interaction_pack_bags_faster_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1148,
			766,
			380,
			380
		}
	}
	self.icons.skills_interaction_revive_teammates_faster_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1530,
			766,
			380,
			380
		}
	}
	self.icons.skills_interaction_search_crates_faster_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1148,
			1148,
			380,
			380
		}
	}
	self.icons.skills_interaction_wheel_hotspots_larger_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1148,
			1530,
			380,
			380
		}
	}
	self.icons.skills_interaction_wheels_turn_faster_large = {
		texture = "ui/atlas/raid_atlas_experience_1",
		texture_rect = {
			1530,
			1148,
			380,
			380
		}
	}
	self.icons.skills_navigation_increase_climbing_speed_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			2,
			2,
			380,
			380
		}
	}
	self.icons.skills_navigation_increase_crouch_speed_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			2,
			384,
			380,
			380
		}
	}
	self.icons.skills_navigation_increase_run_speed_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			2,
			766,
			380,
			380
		}
	}
	self.icons.skills_navigation_move_faster_bags_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			2,
			1148,
			380,
			380
		}
	}
	self.icons.skills_navigation_player_sprint_longer_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			2,
			1530,
			380,
			380
		}
	}
	self.icons.skills_navigation_stamina_regeneration_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			384,
			2,
			380,
			380
		}
	}
	self.icons.skills_navigation_stamina_reserve_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			766,
			2,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_increase_bleedout_time_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1148,
			2,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_increased_health_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1530,
			2,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_less_after_revive_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			384,
			384,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_less_melee_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			384,
			766,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_less_ranged_weapons_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			384,
			1148,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_less_sprinting_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			384,
			1530,
			380,
			380
		}
	}
	self.icons.skills_soaking_damage_less_while_crouch_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			766,
			384,
			380,
			380
		}
	}
	self.icons.skills_special_skills_increase_prim_ammo_capacity_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1148,
			384,
			380,
			380
		}
	}
	self.icons.skills_special_skills_increase_sec_ammo_capacity_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1530,
			384,
			380,
			380
		}
	}
	self.icons.skills_special_skills_mounted_guns_overheat_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			766,
			766,
			380,
			380
		}
	}
	self.icons.skills_special_skills_revive_range_teammates_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			766,
			1148,
			380,
			380
		}
	}
	self.icons.skills_special_skills_scopes_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			766,
			1530,
			380,
			380
		}
	}
	self.icons.skills_warcry_assault_berserk_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1148,
			766,
			380,
			380
		}
	}
	self.icons.skills_warcry_demolition_cluster_truck_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1530,
			766,
			380,
			380
		}
	}
	self.icons.skills_warcry_infilitrator_invisibility_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1148,
			1148,
			380,
			380
		}
	}
	self.icons.skills_warcry_recon_sharpshooter_large = {
		texture = "ui/atlas/raid_atlas_experience_2",
		texture_rect = {
			1148,
			1530,
			380,
			380
		}
	}
	self.icons.skills_weapon_tier_1_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1642,
			2,
			380,
			380
		}
	}
	self.icons.skills_weapon_tier_2_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1642,
			384,
			380,
			380
		}
	}
	self.icons.skills_weapon_tier_3_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			766,
			380,
			380
		}
	}
	self.icons.skills_weapon_tier_4_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			1148,
			380,
			380
		}
	}
	self.icons.skills_weapons_carry_extra_granade_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			1530,
			380,
			380
		}
	}
	self.icons.skills_weapons_ready_faster_after_sprint_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			384,
			766,
			380,
			380
		}
	}
	self.icons.skills_weapons_reduce_flinch_when_hit_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			384,
			1148,
			380,
			380
		}
	}
	self.icons.skills_weapons_reduce_movement_penalty_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			384,
			1530,
			380,
			380
		}
	}
	self.icons.skills_weapons_reduce_sway_when_ads_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1642,
			766,
			380,
			380
		}
	}
	self.icons.skills_weapons_reduce_time_to_ads_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			766,
			1148,
			380,
			380
		}
	}
	self.icons.skills_weapons_switch_faster_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			766,
			1530,
			380,
			380
		}
	}
	self.icons.weapon_ass_carbine_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			2,
			408,
			126
		}
	}
	self.icons.weapon_ass_garand_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			2,
			408,
			126
		}
	}
	self.icons.weapon_ass_mp44_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			2,
			408,
			126
		}
	}
	self.icons.weapon_bren_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			2,
			408,
			126
		}
	}
	self.icons.weapon_browning_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			130,
			408,
			126
		}
	}
	self.icons.weapon_enfield_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			130,
			408,
			126
		}
	}
	self.icons.weapon_gre_concrete_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1266,
			1026,
			240,
			126
		}
	}
	self.icons.weapon_gre_decoy_coin_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1024,
			772,
			128,
			128
		}
	}
	self.icons.weapon_gre_d343_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			856,
			770,
			126,
			126
		}
	}
	self.icons.weapon_gre_mills_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			856,
			898,
			126,
			126
		}
	}
	self.icons.weapon_hdm = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			130,
			408,
			126
		}
	}
	self.icons.weapon_itchaca_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			130,
			408,
			126
		}
	}
	self.icons.weapon_kar_98k_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			258,
			408,
			126
		}
	}
	self.icons.weapon_lmg_dp28_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			258,
			408,
			126
		}
	}
	self.icons.weapon_lmg_m1918_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			258,
			408,
			126
		}
	}
	self.icons.weapon_lmg_mg42_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			258,
			408,
			126
		}
	}
	self.icons.weapon_nagant_m1895 = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			386,
			408,
			126
		}
	}
	self.icons.weapon_pis_c96_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			514,
			408,
			126
		}
	}
	self.icons.weapon_pis_m1911_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			2,
			1912,
			408,
			126
		}
	}
	self.icons.weapon_pis_tt33_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			386,
			408,
			126
		}
	}
	self.icons.weapon_pis_webley_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			514,
			408,
			126
		}
	}
	self.icons.weapon_sho_1912_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			412,
			1912,
			408,
			126
		}
	}
	self.icons.weapon_sho_geco_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			386,
			408,
			126
		}
	}
	self.icons.weapon_shotty = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			386,
			408,
			126
		}
	}
	self.icons.weapon_smg_mp38_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			514,
			408,
			126
		}
	}
	self.icons.weapon_smg_sten_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			514,
			408,
			126
		}
	}
	self.icons.weapon_smg_sterling_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			642,
			408,
			126
		}
	}
	self.icons.weapon_smg_thompson_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			642,
			408,
			126
		}
	}
	self.icons.weapon_snp_m1903_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			822,
			1912,
			408,
			126
		}
	}
	self.icons.weapon_snp_mosin_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			770,
			408,
			126
		}
	}
	self.icons.weapon_welrod_large = {
		texture = "ui/atlas/raid_atlas_experience_3",
		texture_rect = {
			1232,
			898,
			408,
			126
		}
	}
	self.icons.skills_general_faster_interaction_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			2,
			2,
			380,
			380
		}
	}
	self.icons.skills_general_faster_reload_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			2,
			384,
			380,
			380
		}
	}
	self.icons.skills_general_resist_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			2,
			766,
			380,
			380
		}
	}
	self.icons.skills_general_speed_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			2,
			1148,
			380,
			380
		}
	}
	self.icons.skills_warcry_assault_berserk_upgrade_dismemberment_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			2,
			1530,
			380,
			380
		}
	}
	self.icons.skills_warcry_assault_berserk_upgrade_increased_team_heal_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			384,
			2,
			380,
			380
		}
	}
	self.icons.skills_warcry_assault_berserk_upgrade_low_health_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			766,
			2,
			380,
			380
		}
	}
	self.icons.skills_warcry_common_upgrade_duration_lvl1_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			1148,
			2,
			380,
			380
		}
	}
	self.icons.skills_warcry_common_upgrade_duration_lvl2_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			1530,
			2,
			380,
			380
		}
	}
	self.icons.skills_warcry_common_upgrade_duration_lvl3_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			384,
			384,
			380,
			380
		}
	}
	self.icons.skills_warcry_common_upgrade_duration_lvl4_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			384,
			766,
			380,
			380
		}
	}
	self.icons.skills_warcry_demolition_cluster_truck_damage_resist_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			384,
			1148,
			380,
			380
		}
	}
	self.icons.skills_warcry_demolition_cluster_truck_granade_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			384,
			1530,
			380,
			380
		}
	}
	self.icons.skills_warcry_demolition_cluster_truck_kill_streak_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			766,
			384,
			380,
			380
		}
	}
	self.icons.skills_warcry_insurgent_untouchable_short_range_bonus_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			1148,
			384,
			380,
			380
		}
	}
	self.icons.skills_warcry_insurgent_untouchable_upgrade_increased_move_speed_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			1530,
			384,
			380,
			380
		}
	}
	self.icons.skills_warcry_insurgent_untouchable_upgrade_melee_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			766,
			766,
			380,
			380
		}
	}
	self.icons.skills_warcry_recon_sharpshooter_upgrade_headshot_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			766,
			1148,
			380,
			380
		}
	}
	self.icons.skills_warcry_recon_sharpshooter_upgrade_increased_damage_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			766,
			1530,
			380,
			380
		}
	}
	self.icons.skills_warcry_recon_sharpshooter_upgrade_long_range_large = {
		texture = "ui/atlas/raid_atlas_experience_4",
		texture_rect = {
			1148,
			766,
			380,
			380
		}
	}
	self.icons.weapon_gre_betty_large = {
		texture = "ui/atlas/raid_atlas_new_items",
		texture_rect = {
			0,
			0,
			96,
			128
		}
	}
end

function GuiTweakData:_setup_backgrounds()
	self.backgrounds = {
		splash_screen = {}
	}
	self.backgrounds.splash_screen.texture = "ui/backgrounds/raid_main_bg_hud"
	self.backgrounds.splash_screen.texture_rect = {
		0,
		0,
		2048,
		1024
	}
	self.backgrounds.main_menu = {
		texture = "ui/backgrounds/raid_main_bg_hud",
		texture_rect = {
			0,
			0,
			2048,
			1024
		}
	}
	self.backgrounds.secondary_menu = {
		texture = "ui/backgrounds/raid_secondary_menu_bg_hud",
		texture_rect = {
			0,
			0,
			2048,
			1024
		}
	}
end

function GuiTweakData:_setup_images()
	self.images = {
		menu_paper = {}
	}
	self.images.menu_paper.texture = "ui/main_menu/textures/mission_paper_background"
	self.images.menu_paper.texture_rect = {
		5,
		0,
		1049,
		1527
	}
end

function GuiTweakData:_setup_mission_photos()
	self.mission_photos = {
		intel_bank_01 = {}
	}
	self.mission_photos.intel_bank_01.texture = "ui/missions/treasury/raid_atlas_photos_bank"
	self.mission_photos.intel_bank_01.texture_rect = {
		2,
		2,
		416,
		288
	}
	self.mission_photos.intel_bank_02 = {
		texture = "ui/missions/treasury/raid_atlas_photos_bank",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_bank_03 = {
		texture = "ui/missions/treasury/raid_atlas_photos_bank",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_bank_04 = {
		texture = "ui/missions/treasury/raid_atlas_photos_bank",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_bridge_01 = {
		texture = "ui/missions/bridge/raid_atlas_photos_bridge",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_bridge_02 = {
		texture = "ui/missions/bridge/raid_atlas_photos_bridge",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_bridge_03 = {
		texture = "ui/missions/bridge/raid_atlas_photos_bridge",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_bridge_04 = {
		texture = "ui/missions/bridge/raid_atlas_photos_bridge",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_bridge_05 = {
		texture = "ui/missions/bridge/raid_atlas_photos_bridge",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_castle_01 = {
		texture = "ui/missions/castle/raid_atlas_photos_castle",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_castle_02 = {
		texture = "ui/missions/castle/raid_atlas_photos_castle",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_castle_03 = {
		texture = "ui/missions/castle/raid_atlas_photos_castle",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_castle_04 = {
		texture = "ui/missions/castle/raid_atlas_photos_castle",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_castle_05 = {
		texture = "ui/missions/castle/raid_atlas_photos_castle",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_01 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_02 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_03 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_04 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_05 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_flak_06 = {
		texture = "ui/missions/flakturm/raid_atlas_photos_flak",
		texture_rect = {
			420,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_radio_01 = {
		texture = "ui/missions/radio_base/raid_atlas_photos_radio",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_radio_02 = {
		texture = "ui/missions/radio_base/raid_atlas_photos_radio",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_radio_03 = {
		texture = "ui/missions/radio_base/raid_atlas_photos_radio",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_radio_04 = {
		texture = "ui/missions/radio_base/raid_atlas_photos_radio",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_radio_05 = {
		texture = "ui/missions/radio_base/raid_atlas_photos_radio",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_train_01 = {
		texture = "ui/missions/rail_yard/raid_atlas_photos_trainyard",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_train_02 = {
		texture = "ui/missions/rail_yard/raid_atlas_photos_trainyard",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_train_03 = {
		texture = "ui/missions/rail_yard/raid_atlas_photos_trainyard",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_train_04 = {
		texture = "ui/missions/rail_yard/raid_atlas_photos_trainyard",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_train_05 = {
		texture = "ui/missions/rail_yard/raid_atlas_photos_trainyard",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_forest_01 = {
		texture = "ui/missions/forest/raid_atlas_photos_forest",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_forest_02 = {
		texture = "ui/missions/forest/raid_atlas_photos_forest",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_forest_03 = {
		texture = "ui/missions/forest/raid_atlas_photos_forest",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_forest_04 = {
		texture = "ui/missions/forest/raid_atlas_photos_forest",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_art_storage_01 = {
		texture = "ui/missions/art_storage/raid_atlas_photos_art_storage",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_art_storage_02 = {
		texture = "ui/missions/art_storage/raid_atlas_photos_art_storage",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_art_storage_03 = {
		texture = "ui/missions/art_storage/raid_atlas_photos_art_storage",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_art_storage_04 = {
		texture = "ui/missions/art_storage/raid_atlas_photos_art_storage",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_art_storage_05 = {
		texture = "ui/missions/art_storage/raid_atlas_photos_art_storage",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_bunkers_01 = {
		texture = "ui/missions/bunkers/raid_atlas_photos_bunkers",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_bunkers_02 = {
		texture = "ui/missions/bunkers/raid_atlas_photos_bunkers",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_bunkers_03 = {
		texture = "ui/missions/bunkers/raid_atlas_photos_bunkers",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_bunkers_04 = {
		texture = "ui/missions/bunkers/raid_atlas_photos_bunkers",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_bunkers_05 = {
		texture = "ui/missions/bunkers/raid_atlas_photos_bunkers",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_convoy_01 = {
		texture = "ui/missions/convoy/raid_atlas_photos_convoy",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_convoy_02 = {
		texture = "ui/missions/convoy/raid_atlas_photos_convoy",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_convoy_03 = {
		texture = "ui/missions/convoy/raid_atlas_photos_convoy",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_convoy_04 = {
		texture = "ui/missions/convoy/raid_atlas_photos_convoy",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_convoy_05 = {
		texture = "ui/missions/convoy/raid_atlas_photos_convoy",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_tank_depot_01 = {
		texture = "ui/missions/tank_depot/raid_atlas_photos_tank_depot",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_tank_depot_02 = {
		texture = "ui/missions/tank_depot/raid_atlas_photos_tank_depot",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_tank_depot_03 = {
		texture = "ui/missions/tank_depot/raid_atlas_photos_tank_depot",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_tank_depot_04 = {
		texture = "ui/missions/tank_depot/raid_atlas_photos_tank_depot",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_tank_depot_05 = {
		texture = "ui/missions/tank_depot/raid_atlas_photos_tank_depot",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_hunters_01 = {
		texture = "ui/missions/hunters/raid_atlas_photos_hunters",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_hunters_02 = {
		texture = "ui/missions/hunters/raid_atlas_photos_hunters",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_hunters_03 = {
		texture = "ui/missions/hunters/raid_atlas_photos_hunters",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_hunters_04 = {
		texture = "ui/missions/hunters/raid_atlas_photos_hunters",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_kelly_01 = {
		texture = "ui/missions/kelly/raid_atlas_photos_kelly",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_kelly_02 = {
		texture = "ui/missions/kelly/raid_atlas_photos_kelly",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_kelly_03 = {
		texture = "ui/missions/kelly/raid_atlas_photos_kelly",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_kelly_04 = {
		texture = "ui/missions/kelly/raid_atlas_photos_kelly",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_spies_01 = {
		texture = "ui/missions/spies/raid_atlas_photos_spies",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_spies_02 = {
		texture = "ui/missions/spies/raid_atlas_photos_spies",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_spies_03 = {
		texture = "ui/missions/spies/raid_atlas_photos_spies",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_spies_04 = {
		texture = "ui/missions/spies/raid_atlas_photos_spies",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_spies_05 = {
		texture = "ui/missions/spies/raid_atlas_photos_spies",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_01 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_02 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_03 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_04 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_05 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_silo_06 = {
		texture = "ui/missions/silo/raid_atlas_photos_silo",
		texture_rect = {
			420,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_01 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_02 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_03 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_04 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_05 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_06 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			420,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_07 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			2,
			872,
			416,
			288
		}
	}
	self.mission_photos.intel_clear_skies_08 = {
		texture = "ui/missions/operation_clear_skies/raid_atlas_photos_op_clear_skies",
		texture_rect = {
			420,
			872,
			416,
			288
		}
	}
	self.mission_photos.intel_rhinegold_01 = {
		texture = "ui/missions/operation_rhinegold/raid_atlas_photos_op_rhine_gold",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_rhinegold_02 = {
		texture = "ui/missions/operation_rhinegold/raid_atlas_photos_op_rhine_gold",
		texture_rect = {
			420,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_rhinegold_03 = {
		texture = "ui/missions/operation_rhinegold/raid_atlas_photos_op_rhine_gold",
		texture_rect = {
			2,
			292,
			416,
			288
		}
	}
	self.mission_photos.intel_rhinegold_04 = {
		texture = "ui/missions/operation_rhinegold/raid_atlas_photos_op_rhine_gold",
		texture_rect = {
			2,
			582,
			416,
			288
		}
	}
	self.mission_photos.intel_rhinegold_05 = {
		texture = "ui/missions/operation_rhinegold/raid_atlas_photos_op_rhine_gold",
		texture_rect = {
			420,
			292,
			416,
			288
		}
	}
	self.icons.intel_table_newspapers = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			2,
			2,
			1120,
			752
		}
	}
	self.icons.intel_table_personnel_folder = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			2,
			756,
			1088,
			768
		}
	}
	self.icons.intel_table_personnel_img_control = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			2,
			1526,
			320,
			448
		}
	}
	self.icons.intel_table_personnel_img_kurgan = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			324,
			1526,
			320,
			448
		}
	}
	self.icons.intel_table_personnel_img_mrs_white = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			646,
			1526,
			320,
			448
		}
	}
	self.icons.intel_table_personnel_img_rivet = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			968,
			1526,
			320,
			448
		}
	}
	self.icons.intel_table_personnel_img_sterling = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			1092,
			756,
			320,
			448
		}
	}
	self.icons.intel_table_personnel_img_wolfgang = {
		texture = "ui/atlas/raid_atlas_intel_table_1",
		texture_rect = {
			1124,
			2,
			320,
			448
		}
	}
	self.icons.intel_table_archive = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			2,
			2,
			1024,
			704
		}
	}
	self.icons.intel_table_opp_img_fallschirmjager_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			2,
			1414,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_fallschirmjager_b = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			324,
			1414,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_flammen_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			646,
			1414,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_gebirgsjager_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			968,
			1414,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_gebirgsjager_b = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1290,
			2,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_herr_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1612,
			2,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_herr_b = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1290,
			452,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_herr_c = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1028,
			902,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_officer_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1612,
			452,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_sniper_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1290,
			1352,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_spotter_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1350,
			902,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_waffen_ss_a = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1672,
			902,
			320,
			448
		}
	}
	self.icons.intel_table_opp_img_waffen_ss_b = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			1612,
			1352,
			320,
			448
		}
	}
	self.icons.intel_table_opposition_card = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			2,
			708,
			1024,
			704
		}
	}
	self.icons.play_icon = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			2,
			1864,
			100,
			100
		}
	}
	self.icons.play_icon_outline = {
		texture = "ui/atlas/raid_atlas_intel_table_2",
		texture_rect = {
			104,
			1864,
			100,
			100
		}
	}
	self.mission_photos.intel_fury_railway_01 = {
		texture = "ui/missions/fury_railway/raid_atlas_photos_fury_railway",
		texture_rect = {
			2,
			2,
			416,
			288
		}
	}
	self.mission_photos.intel_fury_railway_02 = {
		texture = "ui/missions/fury_railway/raid_atlas_photos_fury_railway",
		texture_rect = {
			2,
			290,
			416,
			288
		}
	}
	self.mission_photos.intel_fury_railway_03 = {
		texture = "ui/missions/fury_railway/raid_atlas_photos_fury_railway",
		texture_rect = {
			2,
			578,
			416,
			288
		}
	}
	self.mission_photos.intel_fury_railway_04 = {
		texture = "ui/missions/fury_railway/raid_atlas_photos_fury_railway",
		texture_rect = {
			418,
			2,
			416,
			288
		}
	}
end

function GuiTweakData:_setup_optical_flares()
	self.icons.lens_glint = {
		texture = "ui/optical_flares/raid_reward_lens_glint_df",
		texture_rect = {
			0,
			0,
			1024,
			1024
		}
	}
	self.icons.lens_iris = {
		texture = "ui/optical_flares/raid_reward_lens_iris_df",
		texture_rect = {
			0,
			0,
			1024,
			1024
		}
	}
	self.icons.lens_orbs = {
		texture = "ui/optical_flares/raid_reward_lens_orbs_df",
		texture_rect = {
			0,
			0,
			1024,
			1024
		}
	}
	self.icons.lens_shimmer = {
		texture = "ui/optical_flares/raid_reward_lens_shimmer_df",
		texture_rect = {
			0,
			0,
			1024,
			1024
		}
	}
	self.icons.lens_spike_ball = {
		texture = "ui/optical_flares/raid_reward_lens_spike_ball_df",
		texture_rect = {
			0,
			0,
			1024,
			1024
		}
	}
end

function GuiTweakData:_setup_xp_icons()
	self.icons.xp_events_mission_raid_railyard = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			2,
			2,
			392,
			392
		}
	}
	self.icons.xp_events_missions_art_storage = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			2,
			396,
			392,
			392
		}
	}
	self.icons.xp_events_missions_bunkers = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			2,
			790,
			392,
			392
		}
	}
	self.icons.xp_events_missions_consumable_forest = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			2,
			1184,
			392,
			392
		}
	}
	self.icons.xp_events_missions_convoy = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			2,
			1578,
			392,
			392
		}
	}
	self.icons.xp_events_missions_hunters = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			396,
			2,
			392,
			392
		}
	}
	self.icons.xp_events_missions_operation_clear_skies = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			790,
			2,
			392,
			392
		}
	}
	self.icons.xp_events_missions_operation_rhinegold = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			1184,
			2,
			392,
			392
		}
	}
	self.icons.xp_events_missions_operations_category = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			1578,
			2,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raid_bank = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			396,
			396,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raid_bridge = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			396,
			790,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raid_castle = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			396,
			1184,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raid_flaktower = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			396,
			1578,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raid_radio = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			790,
			396,
			392,
			392
		}
	}
	self.icons.xp_events_missions_raids_category = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			1184,
			396,
			392,
			392
		}
	}
	self.icons.xp_events_missions_silo = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			1578,
			396,
			392,
			392
		}
	}
	self.icons.xp_events_missions_spies = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			790,
			790,
			392,
			392
		}
	}
	self.icons.xp_events_missions_tank_depot = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			790,
			1184,
			392,
			392
		}
	}
	self.icons.xp_events_missions_kelly = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			790,
			1576,
			392,
			392
		}
	}
	self.icons.xp_events_missions_fury_railway = {
		texture = "ui/atlas/raid_atlas_xp",
		texture_rect = {
			1182,
			790,
			392,
			392
		}
	}
end

function GuiTweakData:_setup_paper_icons()
	self.icons.folder_mission = {
		texture = "ui/atlas/raid_atlas_papers_2",
		texture_rect = {
			2,
			786,
			546,
			782
		}
	}
	self.icons.folder_mission_hud_notification_ops = {
		texture = "ui/atlas/raid_atlas_papers_2",
		texture_rect = {
			598,
			388,
			252,
			332
		}
	}
	self.icons.folder_mission_hud_notification_raid = {
		texture = "ui/atlas/raid_atlas_papers_2",
		texture_rect = {
			598,
			722,
			232,
			332
		}
	}
	self.icons.folder_mission_op = {
		texture = "ui/atlas/raid_atlas_papers_2",
		texture_rect = {
			2,
			2,
			594,
			782
		}
	}
	self.icons.folder_mission_selection = {
		texture = "ui/atlas/raid_atlas_papers_2",
		texture_rect = {
			598,
			2,
			268,
			384
		}
	}
end

function GuiTweakData:icon_w(icon)
	return self.icons[icon].texture_rect[3]
end

function GuiTweakData:icon_h(icon)
	return self.icons[icon].texture_rect[4]
end

function GuiTweakData:_setup_old_tweak_data()
	self.content_updates = {
		title_id = "menu_content_updates",
		num_items = 6,
		choice_id = "menu_content_updates_previous"
	}

	if _G.IS_PC then
		self.content_updates.item_list = {}
	elseif _G.IS_PS3 then
		self.content_updates.item_list = {}
	elseif _G.IS_PS4 then
		self.content_updates.item_list = {}
	elseif _G.IS_XB1 then
		self.content_updates.item_list = {}
	elseif _G.IS_XB360 then
		self.content_updates.item_list = {}
	end

	self.fav_videos = {
		title_id = "menu_fav_videos",
		num_items = 3,
		db_url = "http://www.overkillsoftware.com/?page_id=1263",
		button = {
			url = "http://www.overkillsoftware.com/?page_id=1263",
			text_id = "menu_fav_video_homepage"
		},
		item_list = {
			{
				id = "fav3",
				image = "guis/textures/pd2/fav_video3",
				use_db = true
			},
			{
				id = "fav2",
				image = "guis/textures/pd2/fav_video2",
				use_db = true
			},
			{
				id = "fav1",
				image = "guis/textures/pd2/fav_video1",
				use_db = true
			}
		}
	}
	self.masks_sort_order = {}
	self.suspicion_to_visibility = {
		{}
	}
	self.suspicion_to_visibility[1].name_id = "bm_menu_concealment_low"
	self.suspicion_to_visibility[1].max_index = 9
	self.suspicion_to_visibility[2] = {
		name_id = "bm_menu_concealment_medium",
		max_index = 20
	}
	self.suspicion_to_visibility[3] = {
		name_id = "bm_menu_concealment_high",
		max_index = 30
	}
	self.mouse_pointer = {
		controller = {}
	}
	self.mouse_pointer.controller.acceleration_speed = 4
	self.mouse_pointer.controller.max_acceleration = 3
	self.mouse_pointer.controller.mouse_pointer_speed = 125
	local min_amount_masks = 72
	self.MASK_ROWS_PER_PAGE = 4
	self.MASK_COLUMNS_PER_PAGE = 4
	self.MAX_MASK_PAGES = math.ceil(min_amount_masks / (self.MASK_ROWS_PER_PAGE * self.MASK_COLUMNS_PER_PAGE))
	self.MAX_MASK_SLOTS = self.MAX_MASK_PAGES * self.MASK_ROWS_PER_PAGE * self.MASK_COLUMNS_PER_PAGE
	local min_amount_weapons = 72
	self.WEAPON_ROWS_PER_PAGE = 4
	self.WEAPON_COLUMNS_PER_PAGE = 4
	self.MAX_WEAPON_PAGES = math.ceil(min_amount_weapons / (self.WEAPON_ROWS_PER_PAGE * self.WEAPON_COLUMNS_PER_PAGE))
	self.MAX_WEAPON_SLOTS = self.MAX_WEAPON_PAGES * self.WEAPON_ROWS_PER_PAGE * self.WEAPON_COLUMNS_PER_PAGE
	self.server_browser = {
		max_active_jobs = 0,
		active_job_time = 925,
		new_job_min_time = 1.5,
		new_job_max_time = 3.5,
		refresh_servers_time = 5,
		total_active_jobs = 40,
		max_active_server_jobs = 100
	}
	self.rename_max_letters = 20
	self.rename_skill_set_max_letters = 15
	self.mod_preview_min_fov = -20
	self.mod_preview_max_fov = 3
	self.stats_present_multiplier = 10
	self.armor_damage_shake_base = 1.1
	self.buy_weapon_category_groups = {
		flamethrower = "wpn_special",
		grenade_launcher = "wpn_special",
		bow = "wpn_special",
		crossbow = "wpn_special",
		minigun = "wpn_special",
		saw = "wpn_special"
	}
	self.weapon_texture_switches = {}
end
