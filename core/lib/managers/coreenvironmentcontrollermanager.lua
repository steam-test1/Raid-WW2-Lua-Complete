local flashbang_test_offset = Vector3(0, 0, 150)
CoreEnvironmentControllerManager = CoreEnvironmentControllerManager or class()
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_START = 0.5
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_END = 0.1
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_POWER = 2
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_INTERVAL = CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_START - CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_END
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_PULSE_AMPLITUDE = 0.4
CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_PULSE_FREQ = 200
CoreEnvironmentControllerManager.DEFAULT_DOF_DISTANCE = 10

-- Lines 22-94
function CoreEnvironmentControllerManager:init()
	self._dof_distance = CoreEnvironmentControllerManager.DEFAULT_DOF_DISTANCE
	self._current_dof_distance = self._dof_distance
	self._base_contrast = 0.1
	self._hurt_value = 1
	self._health_effect_value = 1
	self._suppression_value = 0
	self._current_suppression_value = 0
	self._old_suppression_value = 0
	self._supression_start_flash = 0
	self._old_health_effect_value = 1
	self._health_effect_value_diff = 0
	self._blurzones = {}
	self._hit_right = 0
	self._hit_left = 0
	self._hit_up = 0
	self._hit_down = 0
	self._hit_front = 0
	self._hit_back = 0
	self._hit_some = 0
	self._hit_amount = 0.3
	self._hit_cap = 1
	self._current_flashbang = 0
	self._current_flashbang_flash = 0
	self._flashbang_multiplier = 1
	self._flashbang_duration = 1
	self._HE_blinding = 0
	self._downed_value = 0
	self._last_life = false
	self._last_life_mod = 1
	self._vignette = 0
	self._lut_lerp_value = 0

	self:_create_dof_tweak_data()

	self._current_dof_setting = "standard"
	self._near_plane_x = self._dof_tweaks[self._current_dof_setting].steelsight.near_plane_x
	self._near_plane_y = self._dof_tweaks[self._current_dof_setting].steelsight.near_plane_y
	self._far_plane_x = self._dof_tweaks[self._current_dof_setting].steelsight.far_plane_x
	self._far_plane_y = self._dof_tweaks[self._current_dof_setting].steelsight.far_plane_y
	self._dof_override = false
	self._dof_override_near = 5
	self._dof_override_near_pad = 5
	self._dof_override_far = 5000
	self._dof_override_far_pad = 1000
	self._lens_distortion = self:get_default_lens_distortion_value()

	self:set_dome_occ_default()
end

-- Lines 96-99
function CoreEnvironmentControllerManager:update(t, dt)
	self:_update_values(t, dt)
	self:set_post_composite(t, dt)
end

-- Lines 101-113
function CoreEnvironmentControllerManager:_update_values(t, dt)
	if self._current_dof_distance ~= self._dof_distance then
		self._current_dof_distance = math.lerp(self._current_dof_distance, self._dof_distance, 5 * dt)
	end

	if Global.debug_post_effects_enabled and self._current_suppression_value ~= self._suppression_value then
		self._current_suppression_value = math.step(self._current_suppression_value, self._suppression_value, 2 * dt)
	end
end

-- Lines 115-117
function CoreEnvironmentControllerManager:get_dof_distance()
	return self._dof_distance
end

-- Lines 120-123
function CoreEnvironmentControllerManager:set_dof_distance(distance, in_steelsight, position)
	self._dof_distance = math.max(CoreEnvironmentControllerManager.DEFAULT_DOF_DISTANCE, distance or CoreEnvironmentControllerManager.DEFAULT_DOF_DISTANCE)
	self._in_steelsight = in_steelsight
end

-- Lines 125-127
function CoreEnvironmentControllerManager:get_default_lens_distortion_value()
	return 1.02
end

-- Lines 129-131
function CoreEnvironmentControllerManager:get_lens_distortion_value()
	return self._lens_distortion
end

-- Lines 133-135
function CoreEnvironmentControllerManager:reset_lens_distortion_value()
	self:set_lens_distortion_power(self:get_default_lens_distortion_value())
end

-- Lines 137-139
function CoreEnvironmentControllerManager:set_lens_distortion_power(lens_distortion)
	self._lens_distortion = lens_distortion
end

-- Lines 141-143
function CoreEnvironmentControllerManager:set_vignette(vignette)
	self._vignette = vignette
end

-- Lines 145-147
function CoreEnvironmentControllerManager:set_hurt_value(hurt)
	self._hurt_value = hurt
end

-- Lines 149-151
function CoreEnvironmentControllerManager:set_health_effect_value(health_effect_value)
	self._health_effect_value = health_effect_value
end

-- Lines 153-155
function CoreEnvironmentControllerManager:set_downed_value(downed_value)
	self._downed_value = downed_value
end

-- Lines 157-159
function CoreEnvironmentControllerManager:set_last_life(last_life)
	self._last_life = last_life
end

-- Lines 161-163
function CoreEnvironmentControllerManager:set_last_life_mod(last_life_mod)
	self._last_life_mod = last_life_mod
end

-- Lines 165-167
function CoreEnvironmentControllerManager:hurt_value()
	return self._hurt_value
end

-- Lines 169-171
function CoreEnvironmentControllerManager:set_suppression_value(effective_value, raw_value)
	self._suppression_value = effective_value > 0 and 1 or 0
end

-- Lines 173-176
function CoreEnvironmentControllerManager:hit_feedback_front()
	self._hit_front = math.min(self._hit_front + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 178-181
function CoreEnvironmentControllerManager:hit_feedback_back()
	self._hit_back = math.min(self._hit_back + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 184-190
function CoreEnvironmentControllerManager:hit_feedback_right()
	self._hit_right = math.min(self._hit_right + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 191-197
function CoreEnvironmentControllerManager:hit_feedback_left()
	self._hit_left = math.min(self._hit_left + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 198-204
function CoreEnvironmentControllerManager:hit_feedback_up()
	self._hit_up = math.min(self._hit_up + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 205-211
function CoreEnvironmentControllerManager:hit_feedback_down()
	self._hit_down = math.min(self._hit_down + self._hit_amount, 1)
	self._hit_some = math.min(self._hit_some + self._hit_amount, 1)
end

-- Lines 213-277
function CoreEnvironmentControllerManager:set_blurzone(id, mode, pos, radius, height, delete_after_fadeout)
	local blurzone = self._blurzones[id]

	if id then
		blurzone = blurzone or {
			opacity = 0,
			radius = 0,
			mode = -1,
			height = 0,
			delete_after_fadeout = false
		}

		if mode > 0 then
			blurzone.mode = mode
			blurzone.pos = pos
			blurzone.radius = radius
			blurzone.height = height

			if mode == 2 then
				blurzone.opacity = 2
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in_line_of_sight
			elseif mode == 3 then
				blurzone.opacity = 2
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in
			else
				blurzone.opacity = 0
				blurzone.update = self.blurzone_fade_in
			end

			if height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end

			blurzone.delete_after_fadeout = delete_after_fadeout
		elseif blurzone and blurzone.mode > 0 then
			blurzone.mode = mode
			blurzone.pos = blurzone.pos or pos
			blurzone.radius = blurzone.radius or radius
			blurzone.height = blurzone.height or height
			blurzone.opacity = 1
			blurzone.update = self.blurzone_fade_out

			if blurzone.height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end
		end

		self._blurzones[id] = blurzone
	end
end

-- Lines 279-283
function CoreEnvironmentControllerManager:set_all_blurzones(mode)
	for id, blurzone in pairs(self._blurzones) do
		self:set_blurzone(id, mode)
	end
end

-- Lines 285-303
function CoreEnvironmentControllerManager:_blurzones_update(t, dt, camera_pos)
	local result = 0

	for id, blurzone in pairs(self._blurzones) do
		if blurzone and blurzone.mode > -1 then
			local blur_zone_val = blurzone:update(self, t, dt, camera_pos, blurzone)

			if result < blur_zone_val then
				result = blur_zone_val
			end
		elseif blurzone.delete_after_fadeout then
			self._blurzones[id] = nil
		end
	end

	return result
end

-- Lines 305-317
function CoreEnvironmentControllerManager:blurzone_flash_in_line_of_sight(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt * 0.3
	self._HE_blinding = self:test_line_of_sight(blurzone.pos, 150, 1000, 2000)

	if blurzone.opacity < 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle_line_of_sight
	end

	return blurzone:check(blurzone, camera_pos) * (1 + 11 * (blurzone.opacity - 1))
end

-- Lines 319-330
function CoreEnvironmentControllerManager:blurzone_flash_in(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt * 0.3

	if blurzone.opacity < 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos) * (1 + 11 * (blurzone.opacity - 1))
end

-- Lines 332-343
function CoreEnvironmentControllerManager:blurzone_fade_in(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity + dt

	if blurzone.opacity > 1 then
		blurzone.opacity = 1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

-- Lines 345-355
function CoreEnvironmentControllerManager:blurzone_fade_out(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity - dt

	if blurzone.opacity < 0 then
		blurzone.opacity = 0
		blurzone.mode = -1
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

-- Lines 357-361
function CoreEnvironmentControllerManager:blurzone_fade_idle_line_of_sight(self, t, dt, camera_pos, blurzone)
	self._HE_blinding = self:test_line_of_sight(blurzone.pos, 150, 1000, 2000)

	return blurzone:check(blurzone, camera_pos)
end

-- Lines 363-365
function CoreEnvironmentControllerManager:blurzone_fade_idle(self, t, dt, camera_pos, blurzone)
	return blurzone:check(blurzone, camera_pos)
end

-- Lines 367-371
function CoreEnvironmentControllerManager:blurzone_fade_out_switch(self, t, dt, camera_pos, blurzone)
	return blurzone:check(blurzone, camera_pos)
end

-- Lines 373-392
function CoreEnvironmentControllerManager:blurzone_check_cylinder(blurzone, camera_pos)
	local pos_z = blurzone.pos.z
	local cam_z = camera_pos.z
	local len = nil

	if cam_z < pos_z then
		len = (blurzone.pos - camera_pos):length()
	elseif cam_z > pos_z + blurzone.height then
		len = (blurzone.pos:with_z(pos_z + blurzone.height) - camera_pos):length()
	else
		len = (blurzone.pos:with_z(cam_z) - camera_pos):length()
	end

	local result = math.min(len / blurzone.radius, 1)
	result = result * result

	return (1 - result) * blurzone.opacity
end

-- Lines 394-402
function CoreEnvironmentControllerManager:blurzone_check_sphere(blurzone, camera_pos)
	local len = (blurzone.pos - camera_pos):length()
	local result = math.min(len / blurzone.radius, 1)
	result = result * result

	return (1 - result) * blurzone.opacity
end

local ids_dof_near_plane = Idstring("near_plane")
local ids_dof_far_plane = Idstring("far_plane")
local ids_dof_settings = Idstring("settings")
local ids_radial_pos = Idstring("radial_pos")
local ids_radial_offset = Idstring("radial_offset")
local ids_tgl_r = Idstring("tgl_r")
local hit_feedback_rlu = Idstring("hit_feedback_rlu")
local hit_feedback_d = Idstring("hit_feedback_d")
local ids_dof_prepare_post_processor = Idstring("dof_prepare_post_processor")
local ids_post_DOF = Idstring("post_DOF")
local mvec1 = Vector3()
local mvec2 = Vector3()
local new_cam_fwd = Vector3()
local new_cam_up = Vector3()
local new_cam_right = Vector3()
local ids_LUT_post = Idstring("color_grading_post")
local ids_LUT_settings = Idstring("lut_settings")
local ids_LUT_params = Idstring("LUT_settings")
local ids_low_health_params = Idstring("low_health_settings")
local ids_LUT_contrast = Idstring("contrast")
local ids_lens_distortion_post = Idstring("lens_distortion")
local ids_lens_distortion_settings = Idstring("lens_distortion_mod")
local ids_lens_distortion_power = Idstring("distortion_power")

-- Lines 437-439
function CoreEnvironmentControllerManager:set_lut_lerp_value(lut_lerp_value)
	self._lut_lerp_value = lut_lerp_value
end

-- Lines 441-576
function CoreEnvironmentControllerManager:set_post_composite(t, dt)
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return
	end

	if self._occ_dirty then
		self._occ_dirty = false

		self:_refresh_occ_params(vp)
	end

	if self._vp ~= vp then
		local dof_prepare_post_processor = vp:vp():get_post_processor_effect("World", ids_dof_prepare_post_processor)

		if dof_prepare_post_processor then
			local post_composite = dof_prepare_post_processor:modifier(ids_post_DOF)

			if not post_composite then
				return
			end

			self._material = post_composite:material()

			if not self._material then
				return
			end

			self._vp = vp

			self:_update_post_process_effects()
		end
	end

	local camera = vp:camera()

	if self._old_vp ~= vp then
		self._occ_dirty = true
		self._old_vp = vp
	end

	local blur_zone_val = self:_blurzones_update(t, dt, camera:position())

	if self._hit_some > 0 then
		local hit_fade = dt * 1.5
		self._hit_some = math.max(self._hit_some - hit_fade, 0)
		self._hit_right = math.max(self._hit_right - hit_fade, 0)
		self._hit_left = math.max(self._hit_left - hit_fade, 0)
		self._hit_up = math.max(self._hit_up - hit_fade, 0)
		self._hit_down = math.max(self._hit_down - hit_fade, 0)
		self._hit_front = math.max(self._hit_front - hit_fade, 0)
		self._hit_back = math.max(self._hit_back - hit_fade, 0)
	end

	local downed_value = self._downed_value / 100

	if self._custom_dof_settings then
		self._material:set_variable(ids_dof_settings, self._custom_dof_settings)
	else
		self._material:set_variable(ids_dof_settings, Vector3(math.min(self._hit_some * 10, 1) + blur_zone_val * 0.4, math.min(blur_zone_val + downed_value * 2, 1), 1 + downed_value * 3))
	end

	self._material:set_variable(ids_radial_offset, Vector3((self._hit_left - self._hit_right) * 0.2, (self._hit_up - self._hit_down) * 0.2, self._hit_front - self._hit_back + blur_zone_val * 0.1))
	self._material:set_variable(ids_LUT_contrast, self._base_contrast + self._hit_some * 0.25)
	self:_update_dof(t, dt)

	local lens_distortion_post = vp:vp():get_post_processor_effect("World", ids_lens_distortion_post)

	if lens_distortion_post then
		local lens_distortion_modifier = lens_distortion_post:modifier(ids_lens_distortion_settings)

		if lens_distortion_modifier then
			local lens_distortion_modifier_material = lens_distortion_modifier:material()

			if lens_distortion_modifier_material then
				lens_distortion_modifier_material:set_variable(ids_lens_distortion_power, self._lens_distortion)
			end
		end
	end

	local lut_post = vp:vp():get_post_processor_effect("World", ids_LUT_post)

	if lut_post then
		local lut_modifier = lut_post:modifier(ids_LUT_settings)

		if lut_modifier then
			self._lut_modifier_material = lut_modifier:material()
		end
	end

	if not self._lut_modifier_material then
		return
	end

	local feedback_strength = 6
	local health_diff = math.clamp((self._old_health_effect_value - self._health_effect_value) * feedback_strength, 0, 1)
	self._old_health_effect_value = self._health_effect_value

	if self._health_effect_value_diff < health_diff then
		self._health_effect_value_diff = health_diff
	end

	self._health_effect_value_diff = math.max(self._health_effect_value_diff - dt * 0.5, 0)
	local damage_feedback = math.clamp(self._health_effect_value_diff, 0, 1)
	local last_life = 0

	if self._last_life then
		local hurt_mod = 1 - self._health_effect_value
		last_life = math.clamp((hurt_mod - 0.5) * 2, 0, 1) * self._last_life_mod
	end

	local low_health_effect = 0
	local low_health_effect_power = CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_POWER + CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_PULSE_AMPLITUDE * math.sin(t * CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_PULSE_FREQ)

	if self._health_effect_value < CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_END then
		low_health_effect = 1
	elseif CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_START < self._health_effect_value then
		low_health_effect = 0
	else
		local fraction = (self._health_effect_value - CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_END) / CoreEnvironmentControllerManager.LOW_HEALTH_EFFECT_INTERVAL
		low_health_effect = 1 - math.lerp(0, 1, fraction)
	end

	self._lut_modifier_material:set_variable(ids_LUT_params, Vector3(damage_feedback, last_life, self._lut_lerp_value))
	self._lut_modifier_material:set_variable(ids_low_health_params, Vector3(low_health_effect, low_health_effect_power, self._vignette))
end

-- Lines 578-587
function CoreEnvironmentControllerManager:_update_post_process_effects()
	self:set_volumetric_light_scatter_setting(managers.user:get_setting("vls_setting"))
	self:set_motion_blur_setting(managers.user:get_setting("motion_blur_setting"))
	self:set_ssao_setting(managers.user:get_setting("ssao_setting"))
	self:set_AA_setting(managers.user:get_setting("AA_setting"))
	self:set_colorblind_mode(managers.user:get_setting("colorblind_setting"))
	self:set_parallax_setting(managers.user:get_setting("use_parallax"))
	self._vp:vp():set_post_processor_effect("World", Idstring("color_grading_post"), Idstring("colorgrade"))
	managers.viewport:first_active_viewport():set_force_feeder_update()
end

-- Lines 589-607
function CoreEnvironmentControllerManager:_create_dof_tweak_data()
	local new_dof_settings = {
		none = {
			use_no_dof = true
		},
		standard = {}
	}
	new_dof_settings.standard.steelsight = {
		near_plane_x = 2500,
		near_plane_y = 2500,
		far_plane_x = 500,
		far_plane_y = 2000
	}
	new_dof_settings.standard.other = {
		near_plane_x = 10,
		near_plane_y = 12,
		far_plane_x = 4000,
		far_plane_y = 5000
	}
	self._dof_tweaks = new_dof_settings
end

-- Lines 609-620
function CoreEnvironmentControllerManager:set_AA_setting(setting)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		if setting == "FXAA" then
			vp:vp():set_post_processor_effect("World", Idstring("AA_post_processor"), Idstring("AA_fxaa"))
		elseif setting == "SMAA" then
			vp:vp():set_post_processor_effect("World", Idstring("AA_post_processor"), Idstring("AA_smaa_x1"))
		else
			vp:vp():set_post_processor_effect("World", Idstring("AA_post_processor"), Idstring("empty"))
		end
	end
end

-- Lines 622-627
function CoreEnvironmentControllerManager:set_parallax_setting(setting)
	local global_material = Application:global_material()

	if global_material then
		global_material:set_variable(Idstring("use_parallax"), setting and 1 or 0)
	end
end

-- Lines 629-638
function CoreEnvironmentControllerManager:set_dof_setting(setting)
	if not self._dof_tweaks[setting] then
		Application:error("[CoreEnvironmentControllerManager:set_dof_setting] DOF setting do not exist!", setting)

		return
	end

	self._current_dof_setting = setting

	if self._material then
		self:_update_dof(1, 1)
	end
end

-- Lines 640-648
function CoreEnvironmentControllerManager:set_colorblind_mode(setting)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local cb_correction = vp:vp():get_post_processor_effect("World", Idstring("colorblind_correction_post"))

		cb_correction:set_visibility(setting ~= "off")
	end

	World:set_colorblind_mode(Idstring(setting))
end

-- Lines 650-681
function CoreEnvironmentControllerManager:set_ssao_setting(setting)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local SSAO_processor = vp:vp():get_post_processor_effect("World", Idstring("SSAO_post_processor"))
		local ssao_intensity = 0

		if SSAO_processor then
			local SSAO_combiner = SSAO_processor:modifier(Idstring("apply_SSAO"))
			ssao_intensity = SSAO_combiner:material():get_variable(Idstring("ssao_intensity"))
		end

		local visibility = setting == "standard" and ssao_intensity > 0.001

		if SSAO_processor then
			SSAO_processor:set_visibility(visibility)
		end

		local SSAO_mask = vp:vp():get_post_processor_effect("World", Idstring("SSAO_mask_post_processor"))

		if SSAO_mask then
			SSAO_mask:set_visibility(visibility)
		end

		local deferred_processor = vp:vp():get_post_processor_effect("World", Idstring("deferred"))

		if deferred_processor then
			local apply_ambient = deferred_processor:modifier(Idstring("apply_ambient"))

			if apply_ambient then
				apply_ambient:material():set_variable(Idstring("use_ssao"), visibility and 1 or 0)
			end
		end
	end
end

-- Lines 683-691
function CoreEnvironmentControllerManager:set_motion_blur_setting(setting)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local motion_blur_processor = vp:vp():get_post_processor_effect("World", Idstring("post_motion_blur"))

		if motion_blur_processor then
			motion_blur_processor:set_visibility(setting == "standard")
		end
	end
end

-- Lines 693-708
function CoreEnvironmentControllerManager:set_volumetric_light_scatter_setting(setting)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		local vls_processor = vp:vp():get_post_processor_effect("World", Idstring("volumetric_light_scatter"))

		if vls_processor then
			local vls_combiner = vls_processor:modifier(Idstring("post_volumetric_light_scatter"))

			if vls_combiner then
				local exposure_value = vls_combiner:material():get_variable(Idstring("light_scatter_exposure"))
				local visibility = setting == "standard" and exposure_value > 0.001

				vls_processor:set_visibility(visibility)
			end
		end
	end
end

-- Lines 710-725
function CoreEnvironmentControllerManager:remove_dof_tweak_data(remove_setting_name)
	if not self._dof_tweaks[new_setting_name] then
		Application:error("[CoreEnvironmentControllerManager:remove_dof_tweak_data] DOF setting do not exist!", remove_setting_name)

		return
	end

	self._dof_tweaks[remove_setting_name] = nil

	if self._current_dof_setting == remove_setting_name then
		if self._dof_tweaks.standard then
			self._current_dof_setting = "standard"
		else
			self._current_dof_setting = next(self._dof_tweaks)
		end
	end
end

-- Lines 727-734
function CoreEnvironmentControllerManager:add_dof_tweak_data(new_setting_name, new_setting_tweak_data)
	if self._dof_tweaks[new_setting_name] then
		Application:error("[CoreEnvironmentControllerManager:add_dof_tweak_data] DOF setting already exists!", new_setting_name)

		return
	end

	self._dof_tweaks[new_setting_name] = new_setting_tweak_data
end

-- Lines 736-802
function CoreEnvironmentControllerManager:_update_dof(t, dt)
	local mvec_set = mvector3.set_static
	local mvec = mvec1

	if self._dof_override then
		if self._dof_override_transition_params then
			local params = self._dof_override_transition_params
			params.time = math.max(0, params.time - dt)
			local lerp_v = math.bezier({
				0,
				0,
				1,
				1
			}, 1 - params.time / params.total_t)
			self._dof_override_near = math.lerp(params.start.near, params.stop.near, lerp_v)
			self._dof_override_near_pad = math.lerp(params.start.near_pad, params.stop.near_pad, lerp_v)
			self._dof_override_far = math.lerp(params.start.far, params.stop.far, lerp_v)
			self._dof_override_far_pad = math.lerp(params.start.far_pad, params.stop.far_pad, lerp_v)

			if params.time == 0 then
				self._dof_override_transition_params = nil
			end
		end

		mvec_set(mvec, self._dof_override_near, self._dof_override_near + self._dof_override_near_pad, 0)
		self._material:set_variable(ids_dof_near_plane, mvec)
		mvec_set(mvec, self._dof_override_far - self._dof_override_far_pad, self._dof_override_far, 1)
		self._material:set_variable(ids_dof_far_plane, mvec)
	else
		local dof_settings = self._dof_tweaks[self._current_dof_setting]

		if dof_settings.use_no_dof == true then
			mvec_set(mvec, 0, 0, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, 10000, 10000, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		elseif self._in_steelsight then
			dof_settings = dof_settings.steelsight
			local dof_plane_v = math.clamp(self._current_dof_distance / 5000, 0, 1)
			self._near_plane_x = math.lerp(500, dof_settings.near_plane_x, dof_plane_v)
			self._near_plane_y = math.lerp(20, dof_settings.near_plane_y, dof_plane_v)
			self._far_plane_x = math.lerp(100, dof_settings.far_plane_x, dof_plane_v)
			self._far_plane_y = math.lerp(500, dof_settings.far_plane_y, dof_plane_v)

			mvec_set(mvec, math.max(self._current_dof_distance - self._near_plane_x, 5), self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._current_dof_distance + self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		else
			dof_settings = dof_settings.other
			local dof_speed = math.min(10 * dt, 1)
			self._near_plane_x = math.lerp(self._near_plane_x, dof_settings.near_plane_x, dof_speed)
			self._near_plane_y = math.lerp(self._near_plane_y, dof_settings.near_plane_y, dof_speed)
			self._far_plane_x = math.lerp(self._far_plane_x, dof_settings.far_plane_x, dof_speed)
			self._far_plane_y = math.lerp(self._far_plane_y, dof_settings.far_plane_y, dof_speed)

			mvec_set(mvec, self._near_plane_x, self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		end
	end
end

-- Lines 804-818
function CoreEnvironmentControllerManager:set_flashbang(flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	local flash = self:test_line_of_sight(flashbang_pos + flashbang_test_offset, 200, 1000, 3000)
	self._flashbang_duration = duration

	if flash > 0 then
		self._current_flashbang = math.min(self._current_flashbang + flash, 1.5) * self._flashbang_duration
		self._current_flashbang_flash = math.min(self._current_flashbang_flash + flash, 1.5) * self._flashbang_duration
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/vanilla/explosions/exp_projectile_001"),
		position = flashbang_pos,
		normal = Vector3(0, 0, 1)
	})
end

-- Lines 820-824
function CoreEnvironmentControllerManager:set_flashbang_multiplier(multiplier)
	self._flashbang_multiplier = multiplier ~= 0 and multiplier or 1
	self._flashbang_multiplier = 1 + (1 - self._flashbang_multiplier) * 2
end

-- Lines 826-884
function CoreEnvironmentControllerManager:test_line_of_sight(test_pos, min_distance, dot_distance, max_distance)
	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local tmp_vec3 = Vector3()
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return 0
	end

	local camera = vp:camera()
	local cam_pos = tmp_vec1

	camera:m_position(cam_pos)

	local test_vec = tmp_vec2
	local dis = mvector3.direction(test_vec, cam_pos, test_pos)

	if max_distance < dis then
		return 0
	end

	if dis < min_distance then
		return 1
	end

	local dot_mul = 1
	local max_dot = math.cos(75)
	local cam_rot = camera:rotation()
	local cam_fwd = camera:rotation():y()

	if mvector3.dot(cam_fwd, test_vec) < max_dot then
		if dis < dot_distance then
			dot_mul = 0.5
		else
			return 0
		end
	end

	local ray_hit = World:raycast("ray", cam_pos, test_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

	if ray_hit then
		return 0
	end

	local flash = math.max(dis - min_distance, 0) / (max_distance - min_distance)
	flash = (1 - flash) * dot_mul

	return flash
end

-- Lines 886-888
function CoreEnvironmentControllerManager:set_dof_override(mode)
	self._dof_override = mode
end

-- Lines 890-892
function CoreEnvironmentControllerManager:get_dof_override_ranges()
	return self._dof_override_near, self._dof_override_near_pad, self._dof_override_far, self._dof_override_far_pad
end

-- Lines 894-899
function CoreEnvironmentControllerManager:set_dof_override_ranges(near, near_pad, far, far_pad)
	self._dof_override_near = near
	self._dof_override_near_pad = near_pad
	self._dof_override_far = far
	self._dof_override_far_pad = far_pad
end

-- Lines 902-919
function CoreEnvironmentControllerManager:set_dof_override_ranges_transition(time, near, near_pad, far, far_pad)
	self:set_dof_override(true)

	self._dof_override_transition_params = {
		total_t = time,
		time = time,
		start = {}
	}
	self._dof_override_transition_params.start.near = self._dof_override_near
	self._dof_override_transition_params.start.near_pad = self._dof_override_near_pad
	self._dof_override_transition_params.start.far = self._dof_override_far
	self._dof_override_transition_params.start.far_pad = self._dof_override_far_pad
	self._dof_override_transition_params.stop = {
		near = near,
		near_pad = near_pad,
		far = far,
		far_pad = far_pad
	}
end

-- Lines 921-925
function CoreEnvironmentControllerManager:set_dome_occ_default()
	local area = 20000
	local occ_texture = "core/textures/dome_occ_test"

	self:set_dome_occ_params(Vector3(-(area * 0.5), -(area * 0.5), 0), Vector3(area, area, 1200), occ_texture)
end

-- Lines 927-935
function CoreEnvironmentControllerManager:set_dome_occ_params(occ_pos, occ_size, occ_texture)
	self._occ_dirty = true
	self._occ_pos = occ_pos
	self._occ_pos = Vector3(self._occ_pos.x, self._occ_pos.y - occ_size.y, self._occ_pos.z)
	self._occ_size = occ_size
	self._occ_texture = occ_texture
end

-- Lines 937-961
function CoreEnvironmentControllerManager:_refresh_occ_params(vp)
	local deferred_processor = (vp or self._vp):vp():get_post_processor_effect("World", Idstring("deferred"))

	if deferred_processor then
		local apply_ambient = deferred_processor:modifier(Idstring("apply_ambient"))

		if apply_ambient then
			local dome_occ_feed = apply_ambient:material()

			if dome_occ_feed then
				dome_occ_feed:set_variable(Idstring("dome_occ_pos"), self._occ_pos)
				dome_occ_feed:set_variable(Idstring("dome_occ_size"), self._occ_size)
				Application:set_material_texture(dome_occ_feed, Idstring("filter_color_texture"), Idstring(self._occ_texture), Idstring("normal"), 0)
			end
		end

		local shadow = deferred_processor:modifier(Idstring("move_global_occ"))

		if shadow then
			local dome_occ_feed_ps3 = shadow:material()

			if dome_occ_feed_ps3 then
				Application:set_material_texture(dome_occ_feed_ps3, Idstring("filter_color_texture"), Idstring(self._occ_texture), Idstring("normal"), 0)
			end
		end
	end
end

-- Lines 964-966
function CoreEnvironmentControllerManager:set_custom_dof_settings(custom_dof_settings)
	self._custom_dof_settings = custom_dof_settings
end

-- Lines 968-970
function CoreEnvironmentControllerManager:set_base_contrast(base_contrast)
	self._base_contrast = base_contrast
end

-- Lines 972-974
function CoreEnvironmentControllerManager:base_contrast()
	return self._base_contrast
end

-- Lines 976-979
function CoreEnvironmentControllerManager:feed_param_underlay(material_name, param_name, param_value)
	local material = Underlay:material(Idstring(material_name))

	material:set_variable(Idstring(param_name), param_value)
end
