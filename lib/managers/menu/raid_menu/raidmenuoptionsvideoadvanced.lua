RaidMenuOptionsVideoAdvanced = RaidMenuOptionsVideoAdvanced or class(RaidGuiBase)

-- Lines 3-11
function RaidMenuOptionsVideoAdvanced:init(ws, fullscreen_ws, node, component_name)
	Application:trace("RaidMenuOptionsVideoAdvanced:init: ", inspect(ws))
	RaidMenuOptionsVideoAdvanced.super.init(self, ws, fullscreen_ws, node, component_name)

	if game_state_machine:current_state()._name ~= "menu_main" then
		managers.raid_menu:hide_background()
	end
end

-- Lines 13-15
function RaidMenuOptionsVideoAdvanced:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_options_main_screen_name", "menu_header_options_video_advanced_subtitle")
end

-- Lines 18-27
function RaidMenuOptionsVideoAdvanced:_layout()
	RaidMenuOptionsVideoAdvanced.super._layout(self)
	self:_layout_video_advanced()
	self:_load_advanced_video_values()
	self._toggle_menu_toggle_ssao:set_selected(true)
	self:bind_controller_inputs()
end

-- Lines 29-36
function RaidMenuOptionsVideoAdvanced:close()
	self:_save_advanced_video_values()

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	RaidMenuOptionsVideoAdvanced.super.close(self)
end

-- Lines 38-102
function RaidMenuOptionsVideoAdvanced:_load_advanced_video_values()
	local dof_setting = managers.user:get_setting("dof_setting") == "standard" and true or false
	local ssao_setting = managers.user:get_setting("ssao_setting") == "standard" and true or false
	local use_parallax = managers.user:get_setting("use_parallax")
	local motion_blur_setting = managers.user:get_setting("motion_blur_setting") == "standard" and true or false
	local vls_setting = managers.user:get_setting("vls_setting") == "standard" and true or false
	local flush_gpu_command_queue = managers.user:get_setting("flush_gpu_command_queue")
	local use_lightfx = managers.user:get_setting("use_lightfx")
	local vsync = RenderSettings.v_sync
	local buffer_count = RenderSettings.buffer_count
	local vsync_value = nil

	if not vsync then
		vsync_value = "OFF"
	elseif buffer_count == 1 then
		vsync_value = "DOUBLE_BUFFER"
	else
		vsync_value = "TRIPLE_BUFFER"
	end

	local fov_multiplier = managers.user:get_setting("fov_multiplier")
	local detail_distance = managers.user:get_setting("detail_distance")
	local AA_setting = managers.user:get_setting("AA_setting")
	local texture_quality_default = RenderSettings.texture_quality_default
	local shadow_quality_default = RenderSettings.shadow_quality_default
	local max_anisotropy = RenderSettings.max_anisotropy
	local video_animation_lod = managers.user:get_setting("video_animation_lod")
	local fps_cap = managers.user:get_setting("fps_cap")
	local max_streaming_chunk = managers.user:get_setting("max_streaming_chunk")
	local colorblind_setting = managers.user:get_setting("colorblind_setting")

	self._toggle_menu_toggle_dof:set_value_and_render(dof_setting, true)
	self._toggle_menu_toggle_ssao:set_value_and_render(ssao_setting, true)
	self._toggle_menu_toggle_parallax:set_value_and_render(use_parallax, true)
	self._toggle_menu_toggle_motion_blur:set_value_and_render(motion_blur_setting, true)
	self._toggle_menu_toggle_volumetric_light_scattering:set_value_and_render(vls_setting, true)
	self._toggle_menu_toggle_gpu_flush:set_value_and_render(flush_gpu_command_queue, true)
	self._toggle_menu_toggle_lightfx:set_value_and_render(use_lightfx)

	local fov_multiplier_value = (1 - fov_multiplier) / (1 - tweak_data.player.fov_multiplier.MAX)

	self._progress_bar_menu_fov_adjustment:set_value(fov_multiplier_value * 100, true)
	self._progress_bar_menu_detail_distance:set_value(detail_distance * 100, true)
	self._stepper_menu_antialias:set_value_and_render(AA_setting, true)
	self._stepper_menu_texture_quality:set_value_and_render(texture_quality_default, true)
	self._stepper_menu_shadow_quality:set_value_and_render(shadow_quality_default, true)
	self._stepper_menu_anisotropic:set_value_and_render(max_anisotropy, true)
	self._stepper_menu_anim_lod:set_value_and_render(video_animation_lod, true)
	self._stepper_menu_fps_limit:set_value_and_render(fps_cap, true)
	self._stepper_menu_colorblind_setting:set_value_and_render(colorblind_setting, true)
	self._stepper_menu_toggle_vsync:set_value_and_render(vsync_value, true)

	if managers.viewport:is_fullscreen() then
		self._stepper_menu_toggle_vsync:set_enabled(true)
	else
		self._stepper_menu_toggle_vsync:set_enabled(false)

		self._stepper_menu_colorblind_setting._on_menu_move.down = nil
	end
end

-- Lines 104-113
function RaidMenuOptionsVideoAdvanced:_save_advanced_video_values()
	self:on_click_toggle_ssao()
	self:on_click_toggle_motion_blur()
	self:on_click_toggle_volumetric_light_scattering()
	self:on_click_toggle_gpu_flush()
	self:on_click_toggle_lightfx()
	self:on_item_selected_anim_lod()
	self:on_item_selected_max_streaming_chunk()
end

-- Lines 115-350
function RaidMenuOptionsVideoAdvanced:_layout_video_advanced()
	local start_x = 0
	local start_y = 320
	local default_width = 512
	local toggle_menu_toggle_ssao_params = {
		name = "toggle_menu_toggle_ssao",
		x = start_x,
		y = start_y,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_ssao"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_ssao")),
		on_menu_move = {
			down = "toggle_menu_toggle_parallax"
		}
	}
	self._toggle_menu_toggle_ssao = self._root_panel:toggle_button(toggle_menu_toggle_ssao_params)
	local toggle_menu_toggle_parallax_params = {
		name = "toggle_menu_toggle_parallax",
		x = start_x,
		y = toggle_menu_toggle_ssao_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_parallax"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_parallax")),
		on_menu_move = {
			down = "toggle_menu_toggle_motion_blur",
			up = "toggle_menu_toggle_ssao"
		}
	}
	self._toggle_menu_toggle_parallax = self._root_panel:toggle_button(toggle_menu_toggle_parallax_params)
	local toggle_menu_toggle_motion_blur_params = {
		name = "toggle_menu_toggle_motion_blur",
		x = start_x,
		y = toggle_menu_toggle_parallax_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_motion_blur"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_motion_blur")),
		on_menu_move = {
			down = "toggle_menu_toggle_dof",
			up = "toggle_menu_toggle_parallax"
		}
	}
	self._toggle_menu_toggle_motion_blur = self._root_panel:toggle_button(toggle_menu_toggle_motion_blur_params)
	local toggle_menu_toggle_dof_params = {
		name = "toggle_menu_toggle_dof",
		x = start_x,
		y = toggle_menu_toggle_motion_blur_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_dof"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_dof")),
		on_menu_move = {
			down = "toggle_menu_toggle_volumetric_light_scattering",
			up = "toggle_menu_toggle_motion_blur"
		}
	}
	self._toggle_menu_toggle_dof = self._root_panel:toggle_button(toggle_menu_toggle_dof_params)
	local toggle_menu_toggle_volumetric_light_scattering_params = {
		name = "toggle_menu_toggle_volumetric_light_scattering",
		x = start_x,
		y = toggle_menu_toggle_dof_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_volumetric_light_scattering"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_volumetric_light_scattering")),
		on_menu_move = {
			down = "toggle_menu_toggle_gpu_flush",
			up = "toggle_menu_toggle_motion_blur"
		}
	}
	self._toggle_menu_toggle_volumetric_light_scattering = self._root_panel:toggle_button(toggle_menu_toggle_volumetric_light_scattering_params)
	local toggle_menu_toggle_gpu_flush_params = {
		name = "toggle_menu_toggle_gpu_flush",
		x = start_x,
		y = toggle_menu_toggle_volumetric_light_scattering_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_gpu_flush"),
		description = utf8.to_upper(managers.localization:text("menu_toggle_gpu_flush")),
		on_menu_move = {
			down = "toggle_menu_toggle_lightfx_params",
			up = "toggle_menu_toggle_volumetric_light_scattering"
		}
	}
	self._toggle_menu_toggle_gpu_flush = self._root_panel:toggle_button(toggle_menu_toggle_gpu_flush_params)
	local toggle_menu_toggle_lightfx_params = {
		name = "toggle_menu_toggle_lightfx_params",
		x = start_x,
		y = toggle_menu_toggle_gpu_flush_params.y + RaidGuiBase.PADDING,
		w = default_width,
		on_click_callback = callback(self, self, "on_click_toggle_lightfx"),
		description = utf8.to_upper(managers.localization:text("menu_lightfx")),
		on_menu_move = {
			down = "progress_bar_menu_fov_adjustment",
			up = "toggle_menu_toggle_gpu_flush"
		}
	}
	self._toggle_menu_toggle_lightfx = self._root_panel:toggle_button(toggle_menu_toggle_lightfx_params)
	local progress_bar_menu_fov_adjustment_params = {
		name = "progress_bar_menu_fov_adjustment",
		description = utf8.to_upper(managers.localization:text("menu_fov_adjustment")),
		x = start_x,
		y = toggle_menu_toggle_lightfx_params.y + RaidGuiBase.PADDING,
		min_display_value = tweak_data.player.stances.default.standard.FOV,
		max_display_value = math.round(tweak_data.player.stances.default.standard.FOV * tweak_data.player.fov_multiplier.MAX),
		on_value_change_callback = callback(self, self, "on_value_change_fov_adjustment"),
		on_menu_move = {
			down = "progress_bar_menu_detail_distance",
			up = "toggle_menu_toggle_lightfx_params"
		}
	}
	self._progress_bar_menu_fov_adjustment = self._root_panel:slider(progress_bar_menu_fov_adjustment_params)
	local progress_bar_menu_detail_distance_params = {
		name = "progress_bar_menu_detail_distance",
		value_format = "%02d%%",
		description = utf8.to_upper(managers.localization:text("menu_detail_distance")),
		x = start_x,
		y = progress_bar_menu_fov_adjustment_params.y + RaidGuiBase.PADDING,
		on_value_change_callback = callback(self, self, "on_value_change_detail_distance"),
		on_menu_move = {
			down = "stepper_menu_antialias",
			up = "progress_bar_menu_fov_adjustment"
		}
	}
	self._progress_bar_menu_detail_distance = self._root_panel:slider(progress_bar_menu_detail_distance_params)
	start_x = 704
	local stepper_menu_antialias_params = {
		name = "stepper_menu_antialias",
		x = start_x,
		y = start_y,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_options_video_advanced_antialias")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_antialias"),
		on_item_selected_callback = callback(self, self, "on_item_selected_antialias"),
		on_menu_move = {
			down = "stepper_menu_texture_quality",
			up = "progress_bar_menu_detail_distance"
		}
	}
	self._stepper_menu_antialias = self._root_panel:stepper(stepper_menu_antialias_params)
	local stepper_menu_texture_quality_params = {
		name = "stepper_menu_texture_quality",
		x = start_x,
		y = stepper_menu_antialias_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_texture_quality")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_texture_quality"),
		on_item_selected_callback = callback(self, self, "on_item_selected_texture_quality"),
		on_menu_move = {
			down = "stepper_menu_shadow_quality",
			up = "stepper_menu_antialias"
		}
	}
	self._stepper_menu_texture_quality = self._root_panel:stepper(stepper_menu_texture_quality_params)
	local stepper_menu_shadow_quality_params = {
		name = "stepper_menu_shadow_quality",
		x = start_x,
		y = stepper_menu_texture_quality_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_shadow_quality")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_shadow_quality"),
		on_item_selected_callback = callback(self, self, "on_item_selected_shadow_quality"),
		on_menu_move = {
			down = "stepper_menu_anisotropic",
			up = "stepper_menu_texture_quality"
		}
	}
	self._stepper_menu_shadow_quality = self._root_panel:stepper(stepper_menu_shadow_quality_params)
	local stepper_menu_anisotropic_params = {
		name = "stepper_menu_anisotropic",
		x = start_x,
		y = stepper_menu_shadow_quality_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_options_video_advanced_anisotropic")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_anisotropic"),
		on_item_selected_callback = callback(self, self, "on_item_selected_anisotropic"),
		on_menu_move = {
			down = "stepper_menu_anim_lod",
			up = "stepper_menu_shadow_quality"
		}
	}
	self._stepper_menu_anisotropic = self._root_panel:stepper(stepper_menu_anisotropic_params)
	local stepper_menu_anim_lod_params = {
		name = "stepper_menu_anim_lod",
		x = start_x,
		y = stepper_menu_anisotropic_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_anim_lod")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_anim_lod"),
		on_item_selected_callback = callback(self, self, "on_item_selected_anim_lod"),
		on_menu_move = {
			down = "stepper_menu_fps_limit",
			up = "stepper_menu_anisotropic"
		}
	}
	self._stepper_menu_anim_lod = self._root_panel:stepper(stepper_menu_anim_lod_params)
	local stepper_menu_fps_limit_params = {
		name = "stepper_menu_fps_limit",
		x = start_x,
		y = stepper_menu_anim_lod_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_fps_limit")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_fps_limit"),
		on_item_selected_callback = callback(self, self, "on_item_selected_fps_limit"),
		on_menu_move = {
			down = "stepper_menu_colorblind_setting",
			up = "stepper_menu_anim_lod"
		}
	}
	self._stepper_menu_fps_limit = self._root_panel:stepper(stepper_menu_fps_limit_params)
	local stepper_menu_colorblind_setting_params = {
		name = "stepper_menu_colorblind_setting",
		x = start_x,
		y = stepper_menu_fps_limit_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_colorblind_setting")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_colorblind_setting"),
		on_item_selected_callback = callback(self, self, "on_item_selected_colorblind_setting"),
		on_menu_move = {
			down = "label_menu_vsync",
			up = "stepper_menu_fps_limit"
		}
	}
	self._stepper_menu_colorblind_setting = self._root_panel:stepper(stepper_menu_colorblind_setting_params)
	local _stepper_menu_toggle_vsync_params = {
		name = "label_menu_vsync",
		x = start_x,
		y = stepper_menu_colorblind_setting_params.y + RaidGuiBase.PADDING,
		w = default_width,
		description = utf8.to_upper(managers.localization:text("menu_options_video_advanced_vsync")),
		data_source_callback = callback(self, self, "data_source_stepper_menu_vsync"),
		on_item_selected_callback = callback(self, self, "on_item_selected_vsync"),
		on_menu_move = {
			up = "stepper_menu_colorblind_setting"
		}
	}
	self._stepper_menu_toggle_vsync = self._root_panel:stepper(_stepper_menu_toggle_vsync_params)
	local default_advanced_video_params = {
		name = "default_advanced_video",
		y = 832,
		x = 1472,
		text = utf8.to_upper(managers.localization:text("menu_options_controls_default")),
		on_click_callback = callback(self, self, "on_click_default_advanced_video"),
		layer = RaidGuiBase.FOREGROUND_LAYER
	}
	self._default_advanced_video_button = self._root_panel:long_secondary_button(default_advanced_video_params)

	if managers.raid_menu:is_pc_controller() then
		self._default_advanced_video_button:show()
	else
		self._default_advanced_video_button:hide()
	end
end

-- Lines 352-356
function RaidMenuOptionsVideoAdvanced:on_click_toggle_ssao()
	local ssao_setting = self._toggle_menu_toggle_ssao:get_value()

	managers.menu:active_menu().callback_handler:toggle_ssao_setting_raid(ssao_setting)
end

-- Lines 358-362
function RaidMenuOptionsVideoAdvanced:on_click_toggle_parallax()
	local use_parallax = self._toggle_menu_toggle_parallax:get_value()

	managers.menu:active_menu().callback_handler:set_use_parallax_raid(use_parallax)
end

-- Lines 364-368
function RaidMenuOptionsVideoAdvanced:on_click_toggle_motion_blur()
	local motion_blur_setting = self._toggle_menu_toggle_motion_blur:get_value()

	managers.menu:active_menu().callback_handler:toggle_motion_blur_setting_raid(motion_blur_setting)
end

-- Lines 370-374
function RaidMenuOptionsVideoAdvanced:on_click_toggle_dof()
	local dof_setting = self._toggle_menu_toggle_dof:get_value()

	managers.menu:active_menu().callback_handler:toggle_dof_setting_raid(dof_setting)
end

-- Lines 376-380
function RaidMenuOptionsVideoAdvanced:on_click_toggle_volumetric_light_scattering()
	local vls_setting = self._toggle_menu_toggle_volumetric_light_scattering:get_value()

	managers.menu:active_menu().callback_handler:toggle_volumetric_light_scattering_setting_raid(vls_setting)
end

-- Lines 382-385
function RaidMenuOptionsVideoAdvanced:on_click_toggle_gpu_flush()
	local flush_gpu_command_queue = self._toggle_menu_toggle_gpu_flush:get_value()

	managers.menu:active_menu().callback_handler:toggle_gpu_flush_setting_raid(flush_gpu_command_queue)
end

-- Lines 387-390
function RaidMenuOptionsVideoAdvanced:on_click_toggle_lightfx()
	local use_lightfx = self._toggle_menu_toggle_lightfx:get_value()

	managers.menu:active_menu().callback_handler:toggle_lightfx_raid(use_lightfx)
end

-- Lines 392-396
function RaidMenuOptionsVideoAdvanced:on_value_change_fov_adjustment()
	local fov_multiplier = self._progress_bar_menu_fov_adjustment:get_value() / 100
	fov_multiplier = fov_multiplier * (tweak_data.player.fov_multiplier.MAX - 1) + 1

	managers.menu:active_menu().callback_handler:set_fov_multiplier_raid(fov_multiplier)
end

-- Lines 398-402
function RaidMenuOptionsVideoAdvanced:on_value_change_detail_distance()
	local detail_distance = self._progress_bar_menu_detail_distance:get_value() / 100

	managers.menu:active_menu().callback_handler:set_detail_distance_raid(detail_distance)
end

-- Lines 404-414
function RaidMenuOptionsVideoAdvanced:on_item_selected_vsync()
	local vsync_value = self._stepper_menu_toggle_vsync:get_value()

	if vsync_value == "OFF" then
		managers.menu:active_menu().callback_handler:toggle_vsync_raid(false, 1)
	elseif vsync_value == "DOUBLE_BUFFER" then
		managers.menu:active_menu().callback_handler:toggle_vsync_raid(true, 1)
	else
		managers.menu:active_menu().callback_handler:toggle_vsync_raid(true, 2)
	end
end

-- Lines 416-422
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_vsync()
	local result = {}

	table.insert(result, {
		value = "OFF",
		text = utf8.to_upper(managers.localization:text("menu_vsync_quality_off")),
		info = utf8.to_upper(managers.localization:text("menu_vsync_quality_off"))
	})
	table.insert(result, {
		value = "DOUBLE_BUFFER",
		text = utf8.to_upper(managers.localization:text("menu_vsync_quality_db")),
		info = utf8.to_upper(managers.localization:text("menu_vsync_quality_db"))
	})
	table.insert(result, {
		value = "TRIPLE_BUFFER",
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_vsync_quality_tb")),
		info = utf8.to_upper(managers.localization:text("menu_vsync_quality_tb"))
	})

	return result
end

-- Lines 424-428
function RaidMenuOptionsVideoAdvanced:on_item_selected_antialias()
	local AA_setting = self._stepper_menu_antialias:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_anti_alias_raid(AA_setting)
end

-- Lines 430-436
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_antialias()
	local result = {}

	table.insert(result, {
		value = "OFF",
		text = utf8.to_upper(managers.localization:text("menu_AA_quality_off")),
		info = utf8.to_upper(managers.localization:text("menu_AA_quality_off"))
	})
	table.insert(result, {
		value = "FXAA",
		text = utf8.to_upper(managers.localization:text("menu_AA_quality_fxaa")),
		info = utf8.to_upper(managers.localization:text("menu_AA_quality_fxaa"))
	})
	table.insert(result, {
		value = "SMAA",
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_AA_quality_smaa")),
		info = utf8.to_upper(managers.localization:text("menu_AA_quality_smaa"))
	})

	return result
end

-- Lines 438-442
function RaidMenuOptionsVideoAdvanced:on_item_selected_texture_quality()
	local texture_quality_default = self._stepper_menu_texture_quality:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_texture_quality_raid(texture_quality_default)
end

-- Lines 444-451
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_texture_quality()
	local result = {}

	table.insert(result, {
		value = "very low",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_very_low")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_very_low"))
	})
	table.insert(result, {
		value = "low",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_low")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_low"))
	})
	table.insert(result, {
		value = "medium",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_medium")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_medium"))
	})
	table.insert(result, {
		value = "high",
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_high")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_high"))
	})

	return result
end

-- Lines 453-456
function RaidMenuOptionsVideoAdvanced:on_item_selected_shadow_quality()
	local shadow_quality_default = self._stepper_menu_shadow_quality:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_shadow_quality_raid(shadow_quality_default)
end

-- Lines 458-466
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_shadow_quality()
	local result = {}

	table.insert(result, {
		value = "very low",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_very_low")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_very_low"))
	})
	table.insert(result, {
		value = "low",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_low")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_low"))
	})
	table.insert(result, {
		value = "medium",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_medium")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_medium"))
	})
	table.insert(result, {
		value = "high",
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_high")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_high"))
	})
	table.insert(result, {
		value = "very high",
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_texture_quality_very_high")),
		info = utf8.to_upper(managers.localization:text("menu_texture_quality_very_high"))
	})

	return result
end

-- Lines 468-471
function RaidMenuOptionsVideoAdvanced:on_item_selected_anisotropic()
	local max_anisotropy = self._stepper_menu_anisotropic:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_anisotropic_raid(max_anisotropy)
end

-- Lines 473-481
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_anisotropic()
	local result = {}

	table.insert(result, {
		value = 1,
		text = utf8.to_upper(managers.localization:text("menu_anisotropic_1")),
		info = utf8.to_upper(managers.localization:text("menu_anisotropic_1"))
	})
	table.insert(result, {
		value = 2,
		text = utf8.to_upper(managers.localization:text("menu_anisotropic_2")),
		info = utf8.to_upper(managers.localization:text("menu_anisotropic_2"))
	})
	table.insert(result, {
		value = 4,
		text = utf8.to_upper(managers.localization:text("menu_anisotropic_4")),
		info = utf8.to_upper(managers.localization:text("menu_anisotropic_4"))
	})
	table.insert(result, {
		value = 8,
		text = utf8.to_upper(managers.localization:text("menu_anisotropic_8")),
		info = utf8.to_upper(managers.localization:text("menu_anisotropic_8"))
	})
	table.insert(result, {
		value = 16,
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_anisotropic_16")),
		info = utf8.to_upper(managers.localization:text("menu_anisotropic_16"))
	})

	return result
end

-- Lines 483-486
function RaidMenuOptionsVideoAdvanced:on_item_selected_anim_lod()
	local video_animation_lod = self._stepper_menu_anim_lod:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_anim_lod_raid(video_animation_lod)
end

-- Lines 488-494
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_anim_lod()
	local result = {}

	table.insert(result, {
		value = 1,
		text = utf8.to_upper(managers.localization:text("menu_anim_lod_1")),
		info = utf8.to_upper(managers.localization:text("menu_anim_lod_1"))
	})
	table.insert(result, {
		value = 2,
		text = utf8.to_upper(managers.localization:text("menu_anim_lod_2")),
		info = utf8.to_upper(managers.localization:text("menu_anim_lod_2"))
	})
	table.insert(result, {
		value = 3,
		selected = true,
		text = utf8.to_upper(managers.localization:text("menu_anim_lod_3")),
		info = utf8.to_upper(managers.localization:text("menu_anim_lod_3"))
	})

	return result
end

-- Lines 496-499
function RaidMenuOptionsVideoAdvanced:on_item_selected_fps_limit()
	local fps_cap = self._stepper_menu_fps_limit:get_value()

	managers.menu:active_menu().callback_handler:choice_fps_cap_raid(fps_cap)
end

-- Lines 501-514
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_fps_limit()
	local result = {}

	table.insert(result, {
		value = 30,
		info = "30",
		text = "30"
	})
	table.insert(result, {
		value = 45,
		info = "45",
		text = "45"
	})
	table.insert(result, {
		value = 60,
		info = "60",
		text = "60"
	})
	table.insert(result, {
		value = 75,
		info = "75",
		text = "75"
	})
	table.insert(result, {
		value = 90,
		info = "90",
		text = "90"
	})
	table.insert(result, {
		value = 105,
		info = "105",
		text = "105"
	})
	table.insert(result, {
		value = 120,
		info = "120",
		text = "120"
	})
	table.insert(result, {
		value = 135,
		info = "135",
		text = "135",
		selected = true
	})
	table.insert(result, {
		value = 144,
		info = "144",
		text = "144"
	})
	table.insert(result, {
		value = 600,
		text = utf8.to_upper(managers.localization:text("menu_fps_unlimited")),
		info = utf8.to_upper(managers.localization:text("menu_fps_unlimited"))
	})

	return result
end

-- Lines 516-520
function RaidMenuOptionsVideoAdvanced:on_item_selected_max_streaming_chunk()
	local max_streaming_chunk = 4096

	managers.menu:active_menu().callback_handler:choice_max_streaming_chunk_raid(max_streaming_chunk)
end

-- Lines 522-533
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_max_streaming_chunk()
	local result = {}

	table.insert(result, {
		value = 32,
		info = "32",
		text = "32"
	})
	table.insert(result, {
		value = 64,
		info = "64",
		text = "64"
	})
	table.insert(result, {
		value = 128,
		info = "128",
		text = "128"
	})
	table.insert(result, {
		value = 256,
		info = "256",
		text = "256"
	})
	table.insert(result, {
		value = 512,
		info = "512",
		text = "512"
	})
	table.insert(result, {
		value = 1024,
		info = "1024",
		text = "1024"
	})
	table.insert(result, {
		value = 2048,
		info = "2048",
		text = "2048"
	})
	table.insert(result, {
		value = 4096,
		info = "4096",
		text = "4096",
		selected = true
	})

	return result
end

-- Lines 535-542
function RaidMenuOptionsVideoAdvanced:data_source_stepper_menu_colorblind_setting()
	local result = {}

	table.insert(result, {
		value = "off",
		text = utf8.to_upper(managers.localization:text("menu_colorblind_setting_off")),
		info = utf8.to_upper(managers.localization:text("menu_colorblind_setting_off"))
	})
	table.insert(result, {
		value = "protanope",
		text = utf8.to_upper(managers.localization:text("menu_colorblind_setting_protanope")),
		info = utf8.to_upper(managers.localization:text("menu_colorblind_setting_protanope"))
	})
	table.insert(result, {
		value = "deuteranope",
		text = utf8.to_upper(managers.localization:text("menu_colorblind_setting_deuteranope")),
		info = utf8.to_upper(managers.localization:text("menu_colorblind_setting_deuteranope"))
	})
	table.insert(result, {
		value = "tritanope",
		text = utf8.to_upper(managers.localization:text("menu_colorblind_setting_tritanope")),
		info = utf8.to_upper(managers.localization:text("menu_colorblind_setting_tritanope"))
	})

	return result
end

-- Lines 544-562
function RaidMenuOptionsVideoAdvanced:on_click_default_advanced_video()
	local params = {
		title = managers.localization:text("dialog_reset_advanced_video_title"),
		message = managers.localization:text("dialog_reset_advanced_video_message"),
		callback = function ()
			managers.user:reset_advanced_video_setting_map()

			RenderSettings.texture_quality_default = "high"
			RenderSettings.shadow_quality_default = "high"
			RenderSettings.max_anisotropy = 16
			RenderSettings.v_sync = false

			self:_load_advanced_video_values()
			managers.menu:active_menu().callback_handler:apply_and_save_render_settings()
			managers.menu:active_menu().callback_handler:_refresh_brightness()
		end
	}

	managers.menu:show_option_dialog(params)
end

-- Lines 564-567
function RaidMenuOptionsVideoAdvanced:on_item_selected_colorblind_setting()
	local colorblind_setting = self._stepper_menu_colorblind_setting:get_value()

	managers.menu:active_menu().callback_handler:choice_choose_cb_mode_raid(colorblind_setting)
end

-- Lines 573-589
function RaidMenuOptionsVideoAdvanced:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "on_click_default_advanced_video")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_options_controls_default_controller"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end
