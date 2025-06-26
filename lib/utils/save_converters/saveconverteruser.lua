local SaveConverterUser = {
	to_version_2 = function (setting_map)
		local conversion_map = {
			"invert_camera_x",
			"invert_camera_y",
			nil,
			"rumble",
			"music_volume",
			"sfx_volume",
			"subtitles",
			"brightness",
			"hold_to_steelsight",
			"hold_to_run",
			"voice_volume",
			"keyboard_keybinds",
			nil,
			nil,
			"voice_chat",
			"push_to_talk",
			"hold_to_duck",
			nil,
			nil,
			"video_animation_lod",
			nil,
			nil,
			nil,
			"fov_standard",
			"fov_zoom",
			nil,
			"camera_sensitivity_separate",
			nil,
			nil,
			nil,
			"hit_indicator",
			"aim_assist",
			nil,
			"objective_reminder",
			"effect_quality",
			"fov_multiplier",
			"southpaw",
			"dof_setting",
			"fps_cap",
			"use_headbob",
			nil,
			"net_packet_throttling",
			nil,
			"net_use_compression",
			"net_forwarding",
			nil,
			nil,
			"ssao_setting",
			"AA_setting",
			"last_selected_character_profile_slot",
			"motion_blur_setting",
			"vls_setting",
			"detail_distance",
			"use_parallax",
			"colorblind_setting",
			"voice_over_volume",
			"master_volume",
			"camera_sensitivity_x",
			"camera_sensitivity_y",
			nil,
			"camera_zoom_sensitivity_x",
			"camera_zoom_sensitivity_y",
			"sticky_aim",
			"use_camera_accel",
			"motion_dot",
			"motion_dot_size",
			"motion_dot_icon",
			"motion_dot_offset",
			"motion_dot_color",
			"motion_dot_toggle_aim",
			"tinnitus_sound_enabled",
			"hud_special_weapon_panels",
			"camera_shake",
			"hud_crosshairs",
			"skip_cinematics",
			"warcry_ready_indicator",
			nil,
			"corpse_limit",
			"server_filter_friends_only",
			"server_filter_camp_only",
			"server_filter_distance",
			"server_filter_difficulty"
		}
		local new_settings_map = {}

		for id, value in pairs(setting_map) do
			local name = conversion_map[id]

			if name then
				new_settings_map[name] = value
			end
		end

		return new_settings_map
	end
}

return SaveConverterUser
