core:module("CoreEnvironmentFeeder")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreEngineAccess")

local is_editor = Application:editor()
local platform_intensity_scale = LightIntensityDB:platform_intensity_scale()
local ids_sun_anim_group = Idstring("d_sun")
local ids_ref_cam_obj = Idstring("rp_skydome")
local ids_sky = Idstring("sky")
local ids_top_color = Idstring("color0")
local ids_bottom_color = Idstring("color2")
local ids_ambient_falloff_scale = Idstring("ambient_falloff_scale")
local ids_ambient_color = Idstring("ambient_color")
local ids_sky_top_color = Idstring("sky_top_color")
local ids_sky_bottom_color = Idstring("sky_bottom_color")
local ids_fog_start_color = Idstring("fog_start_color")
local ids_fog_far_low_color = Idstring("fog_far_low_color")
local ids_fog_max_range = Idstring("fog_max_range")
local ids_fog_min_range = Idstring("fog_min_range")
local ids_fog_max_density = Idstring("fog_max_density")
local ids_effect_light_scale = Idstring("effect_light_scale")
local ids_slice0 = Idstring("slice0")
local ids_slice1 = Idstring("slice1")
local ids_slice2 = Idstring("slice2")
local ids_slice3 = Idstring("slice3")
local ids_shadow_slice_depths = Idstring("shadow_slice_depths")
local ids_shadow_slice_overlap = Idstring("shadow_slice_overlap")
local ids_ssao_radius = Idstring("ssao_radius")
local ids_ssao_intensity = Idstring("ssao_intensity")
local ids_vls_density = Idstring("light_scatter_density")
local ids_vls_weight = Idstring("light_scatter_weight")
local ids_vls_decay = Idstring("light_scatter_decay")
local ids_vls_exposure = Idstring("light_scatter_exposure")
local ids_reflection_texture = Idstring("reflection_texture")
local ids_bloom_intensity = Idstring("bloom_intensity")
local ids_ghost_dispersal = Idstring("ghost_dispersal")
local ids_halo_width = Idstring("halo_width")
local ids_chromatic_distortion = Idstring("chromatic_distortion")
local ids_weight_exponent = Idstring("weight_exponent")
local ids_downsample_scale = Idstring("downsample_scale")
local ids_downsample_bias = Idstring("downsample_bias")
local ids_cg_LUT1 = Idstring("filter_color_texture")
local ids_cg_LUT2 = Idstring("refraction_texture")
local ids_gloss_factor = Idstring("gloss_factor")
local ids_spec_factor = Idstring("spec_factor")
local ids_lens_flare_modifier = Idstring("lens_flare_material")
local ids_post_lens_flare = Idstring("lens_flare_post_processor")
local ids_post_lens_flare_apply = Idstring("lens_flare_apply_post_processor")
local ids_lens_flare_effect = Idstring("lens_flare_effect")
local ids_lens_flare_apply_effect = Idstring("lens_flare_apply_effect")
local ids_lens_flare_id = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material"):key()
local ids_cg = Idstring("colorgrade")
local ids_cg_modifier = Idstring("lut_settings")
local ids_post_cg = Idstring("color_grading_post")
local ids_cg_id = Idstring("post_effect/color_grading_post/colorgrade/colorgrade"):key()
local ids_post_DOF_modifier = Idstring("post_DOF")
local ids_post_bloom_prepare = Idstring("bloom_prepare_post_processor")
local ids_post_bloom_combine = Idstring("bloom_combine_post_processor")
local ids_bloom_dof_effect = Idstring("bloom_DOF_combine")
local ids_dof_effect = Idstring("DOF")
local ids_bloom_prepare_effect = Idstring("bloom_prepare")
local ids_deferred = Idstring("deferred")
local ids_deferred_lighting = Idstring("deferred_lighting")
local ids_apply_ambient = Idstring("apply_ambient")
local ids_apply_ambient_id = Idstring("post_effect/deferred/deferred_lighting/apply_ambient"):key()
local ids_post_SSAO = Idstring("SSAO_post_processor")
local ids_SSAO = Idstring("SSAO")
local ids_apply_SSAO = Idstring("apply_SSAO")
local ids_apply_SSAO_id = Idstring("post_effect/SSAO_post_processor/SSAO/ "):key()
local ids_vls = Idstring("volumetric_light_scatter")
local ids_post_vls = Idstring("post_volumetric_light_scatter")
local ids_post_vls_id = Idstring("post_effect/volumetric_light_scatter/volumetric_light_scatter/post_volumetric_light_scatter"):key()
local ids_shadow_processor = Idstring("shadow_processor")
local ids_shadow_rendering = Idstring("shadow_rendering")
local ids_shadow_modifier = Idstring("shadow_modifier")
local ids_shadow_modifier_id = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier"):key()
local ids_normal = Idstring("normal")
local ids_cubemap = Idstring("cubemap")
local zero_rotation = Rotation(0, 0, 0)
local zero_vector3 = Vector3(0, 0, 0)
local temp_rotation = Rotation(0, 0, 0)
local temp_vector3 = Vector3(0, 0, 0)
Feeder = Feeder or CoreClass.class()
Feeder.APPLY_GROUP_ID = 0
Feeder.DATA_PATH_KEY = nil
Feeder.IS_GLOBAL = nil
Feeder.AFFECTED_LIST = nil
Feeder.FILTER_CATEGORY = "Others"

-- Lines 103-110
function Feeder:init(current)
	self:set(current)
end

-- Lines 112-116
function Feeder:destroy()
	self._source = nil
	self._target = nil
end

-- Lines 118-121
function Feeder.get_next_id()
	Feeder.APPLY_GROUP_ID = Feeder.APPLY_GROUP_ID + 1

	return Feeder.APPLY_GROUP_ID
end

-- Lines 123-126
function Feeder:set_target(target)
	self._source = self._current
	self._target = target
end

-- Lines 128-130
function Feeder:equals(value)
	return self._current == value
end

-- Lines 132-134
function Feeder:get_current()
	return self._current
end

-- Lines 136-140
function Feeder:set(current)
	self._current = current
	self._source = current
	self._target = current
end

-- Lines 142-144
function Feeder:get_modifier()
	return self._modifier_func, self._is_modifier_override
end

-- Lines 146-149
function Feeder:set_modifier(modifier_func, is_modifier_override)
	self._modifier_func = modifier_func
	self._is_modifier_override = is_modifier_override
end

-- Lines 151-165
function Feeder:update(handler, scale)
	if self._modifier_func then
		local is_done, is_not_changed = nil

		if not self._is_modifier_override then
			is_done, is_not_changed = self:update_current(handler, scale)
		end

		self._current, is_done, is_not_changed = self._modifier_func(handler, self, scale, is_done, is_not_changed)

		return is_done, is_not_changed
	else
		return self:update_current(handler, scale)
	end
end

-- Lines 167-170
function Feeder:update_current(handler, scale)
	self._current = math.lerp(self._source, self._target, scale)

	return scale == 1, false
end

-- Lines 172-183
function Feeder:_set_variable(viewport, scene, pp, effect, modifier_id, variable)
	local post_processor = viewport:get_post_processor_effect(scene, pp, effect)

	if post_processor then
		local modifier = post_processor:modifier(modifier_id)

		if modifier then
			material = modifier:material()

			material:set_variable(variable, self._current)
		end
	end
end

-- Lines 185-186
function Feeder:apply(handler, viewport, scene)
end

Vector3Feeder = Vector3Feeder or CoreClass.class(Feeder)

-- Lines 191-195
function Vector3Feeder:set(current)
	self._current = mvector3.copy(current)
	self._source = current
	self._target = current
end

-- Lines 197-200
function Vector3Feeder:set_target(target)
	self._source = mvector3.copy(self._current)
	self._target = target
end

-- Lines 202-204
function Vector3Feeder:equals(value)
	return mvector3.equal(self._current, value)
end

-- Lines 206-209
function Vector3Feeder:update_current(handler, scale)
	mvector3.lerp(self._current, self._source, self._target, scale)

	return scale == 1, false
end

StringFeeder = StringFeeder or CoreClass.class(Feeder)

-- Lines 214-221
function StringFeeder:update_current(handler, scale)
	if scale > 0.5 then
		self._current = self._target

		return true, false
	else
		return false, true
	end
end

ColorgradeFeeder = ColorgradeFeeder or CoreClass.class(Feeder)
ColorgradeFeeder.DATA_PATH_KEY = Idstring("others/colorgrade"):key()
ColorgradeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
ColorgradeFeeder.IS_GLOBAL = nil
ColorgradeFeeder.FILTER_CATEGORY = "Colorgrade"

-- Lines 231-235
function ColorgradeFeeder:set_target(target)
	self._source = self._target
	self._target = Idstring(target)
	self._current = 0
end

-- Lines 237-239
function ColorgradeFeeder:equals(value)
	return false
end

-- Lines 241-245
function ColorgradeFeeder:set(current)
	self._source = Idstring(current)
	self._target = Idstring(current)
	self._current = 0
end

-- Lines 247-249
function ColorgradeFeeder:update(handler, scale)
	return self:update_current(handler, scale)
end

-- Lines 251-254
function ColorgradeFeeder:update_current(handler, scale)
	self._current = scale

	return scale == 1, false
end

-- Lines 256-269
function ColorgradeFeeder:apply(handler, viewport, scene)
	if self._source ~= Idstring("") and self._target ~= Idstring("") then
		local post_processor = viewport:get_post_processor_effect(scene, ids_post_cg, ids_cg)
		local modifier = post_processor:modifier(ids_cg_modifier)

		if modifier then
			local material = modifier:material()

			Application:set_material_texture(material, ids_cg_LUT1, self._source, ids_normal, 0)
			Application:set_material_texture(material, ids_cg_LUT2, self._target, ids_normal, 0)
			managers.environment_controller:set_lut_lerp_value(self._current)
		end
	end
end

UnderlayPathFeeder = UnderlayPathFeeder or CoreClass.class(StringFeeder)
UnderlayPathFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlayPathFeeder.DATA_PATH_KEY = Idstring("others/underlay"):key()
UnderlayPathFeeder.IS_GLOBAL = true
UnderlayPathFeeder.FILTER_CATEGORY = "Underlay path"

-- Lines 278-317
function UnderlayPathFeeder:apply(handler, viewport, scene)
	if CoreCode.alive(Global._global_light) then
		World:delete_light(Global._global_light)
	end

	if CoreCode.alive(Global._underlay_ref_camera) then
		Underlay:delete_camera(Global._underlay_ref_camera)
	end

	local underlay_path = managers.database and managers.database:entry_path(self._current) or self._current

	if is_editor then
		CoreEngineAccess._editor_load(Idstring("scene"), underlay_path:id())
	end

	Underlay:load(underlay_path, false)

	Global._global_light = World:create_light("directional|specular")

	Global._global_light:link(Underlay:get_object(ids_sun_anim_group))
	Global._global_light:set_local_rotation(zero_rotation)
	World:set_global_shadow_caster(Global._global_light)

	Global._underlay_ref_camera = Underlay:create_camera()

	Global._underlay_ref_camera:set_near_range(1000)
	Global._underlay_ref_camera:set_far_range(10000000)
	Global._underlay_ref_camera:set_fov(75)

	UnderlayPathFeeder.sky_material = Underlay:material(ids_sky)
	UnderlayPathFeeder.ref_cam_obj = Underlay:get_object(ids_ref_cam_obj)

	Global._underlay_ref_camera:set_local_position(UnderlayPathFeeder.ref_cam_obj:position())
	Underlay:set_reference_camera(Global._underlay_ref_camera)

	Global._current_underlay_name = self._current
end

GlobalLightColorFeeder = GlobalLightColorFeeder or CoreClass.class(Vector3Feeder)
GlobalLightColorFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color"):key()
GlobalLightColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
GlobalLightColorFeeder.IS_GLOBAL = true
GlobalLightColorFeeder.FILTER_CATEGORY = "Sun"

-- Lines 326-342
function GlobalLightColorFeeder:apply(handler, viewport, scene)
	if alive(Global._global_light) then
		local color = handler:get_value(GlobalLightColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(GlobalLightColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			Global._global_light:set_color(temp_vector3)
		else
			Global._global_light:set_color(zero_vector3)
		end
	else
		Application:error("[EnvironmentManager][GlobalLightFeeder] No underlay loaded.")
	end
end

GlobalLightColorScaleFeeder = GlobalLightColorScaleFeeder or CoreClass.class(Feeder)
GlobalLightColorScaleFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color_scale"):key()
GlobalLightColorScaleFeeder.APPLY_GROUP_ID = GlobalLightColorFeeder.APPLY_GROUP_ID
GlobalLightColorScaleFeeder.IS_GLOBAL = GlobalLightColorFeeder.IS_GLOBAL
GlobalLightColorScaleFeeder.FILTER_CATEGORY = GlobalLightColorFeeder.FILTER_CATEGORY
GlobalLightColorScaleFeeder.apply = GlobalLightColorFeeder.apply
CubeMapTextureFeeder = CubeMapTextureFeeder or CoreClass.class(StringFeeder)
CubeMapTextureFeeder.DATA_PATH_KEY = Idstring("others/global_texture"):key()
CubeMapTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
CubeMapTextureFeeder.IS_GLOBAL = nil
CubeMapTextureFeeder.FILTER_CATEGORY = "Cubemap"

-- Lines 359-376
function CubeMapTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_texture", self._current, "CUBEMAP")

	local post_processor = viewport:get_post_processor_effect(scene, ids_deferred, ids_deferred_lighting)

	if post_processor then
		local modifier = post_processor:modifier(ids_apply_ambient)

		if modifier then
			local ids_current = Idstring(self._current)

			if ids_current ~= Idstring("") then
				material = modifier:material()

				Application:set_material_texture(material, ids_reflection_texture, ids_current, ids_cubemap, 0)
			end
		end
	end
end

WorldOverlayTextureFeeder = WorldOverlayTextureFeeder or CoreClass.class(StringFeeder)
WorldOverlayTextureFeeder.DATA_PATH_KEY = Idstring("others/global_world_overlay_texture"):key()
WorldOverlayTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
WorldOverlayTextureFeeder.IS_GLOBAL = true
WorldOverlayTextureFeeder.FILTER_CATEGORY = "GlobalTexture"

-- Lines 385-387
function WorldOverlayTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_world_overlay_texture", self._current, "texture")
end

WorldOverlayMaskTextureFeeder = WorldOverlayMaskTextureFeeder or CoreClass.class(StringFeeder)
WorldOverlayMaskTextureFeeder.DATA_PATH_KEY = Idstring("others/global_world_overlay_mask_texture"):key()
WorldOverlayMaskTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
WorldOverlayMaskTextureFeeder.IS_GLOBAL = true
WorldOverlayMaskTextureFeeder.FILTER_CATEGORY = "GlobalTexture"

-- Lines 396-398
function WorldOverlayMaskTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_world_overlay_mask_texture", self._current, "texture")
end

SkyRotationFeeder = SkyRotationFeeder or CoreClass.class(Feeder)
SkyRotationFeeder.DATA_PATH_KEY = Idstring("others/sky_rotation"):key()
SkyRotationFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
SkyRotationFeeder.IS_GLOBAL = true
SkyRotationFeeder.FILTER_CATEGORY = false

-- Lines 407-414
function SkyRotationFeeder:apply(handler, viewport, scene)
	if alive(UnderlayPathFeeder.ref_cam_obj) then
		mrotation.set_yaw_pitch_roll(temp_rotation, -self._current, 0, 0)
		UnderlayPathFeeder.ref_cam_obj:set_rotation(temp_rotation)
	elseif UnderlayPathFeeder.ref_cam_obj then
		Application:error("[SkyRotationFeeder:apply] ref_cam_obj exists, but is destroyed")
	end
end

UnderlaySkyTopColorFeeder = UnderlaySkyTopColorFeeder or CoreClass.class(Vector3Feeder)
UnderlaySkyTopColorFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color0"):key()
UnderlaySkyTopColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlaySkyTopColorFeeder.IS_GLOBAL = true
UnderlaySkyTopColorFeeder.FILTER_CATEGORY = "Sky"

-- Lines 424-440
function UnderlaySkyTopColorFeeder:apply(handler, viewport, scene)
	if alive(UnderlayPathFeeder.sky_material) then
		local color = handler:get_value(UnderlaySkyTopColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(UnderlaySkyTopColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			UnderlayPathFeeder.sky_material:set_variable(ids_top_color, temp_vector3)
		else
			UnderlayPathFeeder.sky_material:set_variable(ids_top_color, zero_vector3)
		end
	elseif UnderlayPathFeeder.sky_material then
		Application:error("[UnderlaySkyTopColorFeeder:apply] sky_material exists, but is destroyed")
	end
end

UnderlaySkyTopColorScaleFeeder = UnderlaySkyTopColorScaleFeeder or CoreClass.class(Feeder)
UnderlaySkyTopColorScaleFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color0_scale"):key()
UnderlaySkyTopColorScaleFeeder.APPLY_GROUP_ID = UnderlaySkyTopColorFeeder.APPLY_GROUP_ID
UnderlaySkyTopColorScaleFeeder.IS_GLOBAL = UnderlaySkyTopColorFeeder.IS_GLOBAL
UnderlaySkyTopColorScaleFeeder.FILTER_CATEGORY = UnderlaySkyTopColorFeeder.FILTER_CATEGORY
UnderlaySkyTopColorScaleFeeder.apply = UnderlaySkyTopColorFeeder.apply
UnderlaySkyBottomColorFeeder = UnderlaySkyBottomColorFeeder or CoreClass.class(Vector3Feeder)
UnderlaySkyBottomColorFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color2"):key()
UnderlaySkyBottomColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
UnderlaySkyBottomColorFeeder.IS_GLOBAL = true
UnderlaySkyBottomColorFeeder.FILTER_CATEGORY = "Sky"

-- Lines 457-473
function UnderlaySkyBottomColorFeeder:apply(handler, viewport, scene)
	if alive(UnderlayPathFeeder.sky_material) then
		local color = handler:get_value(UnderlaySkyBottomColorFeeder.DATA_PATH_KEY)

		if color then
			local color_scale = handler:get_value(UnderlaySkyBottomColorScaleFeeder.DATA_PATH_KEY) or 1

			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			UnderlayPathFeeder.sky_material:set_variable(ids_bottom_color, temp_vector3)
		else
			UnderlayPathFeeder.sky_material:set_variable(ids_bottom_color, zero_vector3)
		end
	elseif UnderlayPathFeeder.sky_material then
		Application:error("[UnderlaySkyBottomColorFeeder:apply] sky_material exists, but is destroyed")
	end
end

UnderlaySkyBottomColorScaleFeeder = UnderlaySkyBottomColorScaleFeeder or CoreClass.class(Feeder)
UnderlaySkyBottomColorScaleFeeder.DATA_PATH_KEY = Idstring("underlay_effect/sky/color2_scale"):key()
UnderlaySkyBottomColorScaleFeeder.APPLY_GROUP_ID = UnderlaySkyBottomColorFeeder.APPLY_GROUP_ID
UnderlaySkyBottomColorScaleFeeder.IS_GLOBAL = UnderlaySkyBottomColorFeeder.IS_GLOBAL
UnderlaySkyBottomColorScaleFeeder.FILTER_CATEGORY = UnderlaySkyBottomColorFeeder.FILTER_CATEGORY
UnderlaySkyBottomColorScaleFeeder.apply = UnderlaySkyBottomColorFeeder.apply
PostSpecFactorFeeder = PostSpecFactorFeeder or CoreClass.class(Feeder)
PostSpecFactorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/spec_factor"):key()
PostSpecFactorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostSpecFactorFeeder.IS_GLOBAL = nil
PostSpecFactorFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 491-494
function PostSpecFactorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_spec_factor, self._current)
end

PostGlossFactorFeeder = PostGlossFactorFeeder or CoreClass.class(Feeder)
PostGlossFactorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/gloss_factor"):key()
PostGlossFactorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostGlossFactorFeeder.IS_GLOBAL = nil
PostGlossFactorFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 502-505
function PostGlossFactorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_gloss_factor, self._current)
end

PostAmbientFalloffScaleFeeder = PostAmbientFalloffScaleFeeder or CoreClass.class(Feeder)
PostAmbientFalloffScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_falloff_scale"):key()
PostAmbientFalloffScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostAmbientFalloffScaleFeeder.IS_GLOBAL = nil
PostAmbientFalloffScaleFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 513-516
function PostAmbientFalloffScaleFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_ambient_falloff_scale, self._current)
end

PostAmbientColorFeeder = PostAmbientColorFeeder or CoreClass.class(Vector3Feeder)
PostAmbientColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color"):key()
PostAmbientColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostAmbientColorFeeder.IS_GLOBAL = nil
PostAmbientColorFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 525-538
function PostAmbientColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostAmbientColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostAmbientColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_ambient_color, temp_vector3)
	else
		material:set_variable(ids_ambient_color, zero_vector3)
	end
end

PostAmbientColorScaleFeeder = PostAmbientColorScaleFeeder or CoreClass.class(Feeder)
PostAmbientColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/ambient_color_scale"):key()
PostAmbientColorScaleFeeder.APPLY_GROUP_ID = PostAmbientColorFeeder.APPLY_GROUP_ID
PostAmbientColorScaleFeeder.IS_GLOBAL = PostAmbientColorFeeder.IS_GLOBAL
PostAmbientColorScaleFeeder.FILTER_CATEGORY = PostAmbientColorFeeder.FILTER_CATEGORY
PostAmbientColorScaleFeeder.apply = PostAmbientColorFeeder.apply
PostSkyTopColorFeeder = PostSkyTopColorFeeder or CoreClass.class(Vector3Feeder)
PostSkyTopColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_top_color"):key()
PostSkyTopColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostSkyTopColorFeeder.IS_GLOBAL = nil
PostSkyTopColorFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 555-568
function PostSkyTopColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostSkyTopColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostSkyTopColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_sky_top_color, temp_vector3)
	else
		material:set_variable(ids_sky_top_color, zero_vector3)
	end
end

PostSkyTopColorScaleFeeder = PostSkyTopColorScaleFeeder or CoreClass.class(Feeder)
PostSkyTopColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_top_color_scale"):key()
PostSkyTopColorScaleFeeder.APPLY_GROUP_ID = PostSkyTopColorFeeder.APPLY_GROUP_ID
PostSkyTopColorScaleFeeder.IS_GLOBAL = PostSkyTopColorFeeder.IS_GLOBAL
PostSkyTopColorScaleFeeder.FILTER_CATEGORY = PostSkyTopColorFeeder.FILTER_CATEGORY
PostSkyTopColorScaleFeeder.apply = PostSkyTopColorFeeder.apply
PostSkyBottomColorFeeder = PostSkyBottomColorFeeder or CoreClass.class(Vector3Feeder)
PostSkyBottomColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_bottom_color"):key()
PostSkyBottomColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostSkyBottomColorFeeder.IS_GLOBAL = nil
PostSkyBottomColorFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 585-598
function PostSkyBottomColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	local color = handler:get_value(PostSkyBottomColorFeeder.DATA_PATH_KEY)

	if color then
		local color_scale = handler:get_value(PostSkyBottomColorScaleFeeder.DATA_PATH_KEY) or 1

		mvector3.set(temp_vector3, color)
		mvector3.multiply(temp_vector3, color_scale * platform_intensity_scale)
		material:set_variable(ids_sky_bottom_color, temp_vector3)
	else
		material:set_variable(ids_sky_bottom_color, zero_vector3)
	end
end

PostSkyBottomColorScaleFeeder = PostSkyBottomColorScaleFeeder or CoreClass.class(Feeder)
PostSkyBottomColorScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/sky_bottom_color_scale"):key()
PostSkyBottomColorScaleFeeder.APPLY_GROUP_ID = PostSkyBottomColorFeeder.APPLY_GROUP_ID
PostSkyBottomColorScaleFeeder.IS_GLOBAL = PostSkyBottomColorFeeder.IS_GLOBAL
PostSkyBottomColorScaleFeeder.FILTER_CATEGORY = PostSkyBottomColorFeeder.FILTER_CATEGORY
PostSkyBottomColorScaleFeeder.apply = PostSkyBottomColorFeeder.apply
PostFogStartColorFeeder = PostFogStartColorFeeder or CoreClass.class(Vector3Feeder)
PostFogStartColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_start_color"):key()
PostFogStartColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogStartColorFeeder.IS_GLOBAL = nil
PostFogStartColorFeeder.FILTER_CATEGORY = "Fog"

-- Lines 615-621
function PostFogStartColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	mvector3.set(temp_vector3, self._current)
	mvector3.multiply(temp_vector3, platform_intensity_scale)
	material:set_variable(ids_fog_start_color, temp_vector3)
end

PostFogFarLowColorFeeder = PostFogFarLowColorFeeder or CoreClass.class(Vector3Feeder)
PostFogFarLowColorFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_far_low_color"):key()
PostFogFarLowColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogFarLowColorFeeder.IS_GLOBAL = nil
PostFogFarLowColorFeeder.FILTER_CATEGORY = "Fog"

-- Lines 630-636
function PostFogFarLowColorFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	mvector3.set(temp_vector3, self._current)
	mvector3.multiply(temp_vector3, platform_intensity_scale)
	material:set_variable(ids_fog_far_low_color, temp_vector3)
end

PostFogMinRangeFeeder = PostFogMinRangeFeeder or CoreClass.class(Feeder)
PostFogMinRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_min_range"):key()
PostFogMinRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMinRangeFeeder.IS_GLOBAL = nil
PostFogMinRangeFeeder.FILTER_CATEGORY = "Fog"

-- Lines 645-649
function PostFogMinRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_min_range, self._current)
end

PostFogMaxRangeFeeder = PostFogMaxRangeFeeder or CoreClass.class(Feeder)
PostFogMaxRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_max_range"):key()
PostFogMaxRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMaxRangeFeeder.IS_GLOBAL = nil
PostFogMaxRangeFeeder.FILTER_CATEGORY = "Fog"

-- Lines 658-662
function PostFogMaxRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_max_range, self._current)
end

PostFogMaxDensityFeeder = PostFogMaxDensityFeeder or CoreClass.class(Feeder)
PostFogMaxDensityFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_max_density"):key()
PostFogMaxDensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMaxDensityFeeder.IS_GLOBAL = nil
PostFogMaxDensityFeeder.FILTER_CATEGORY = "Fog"

-- Lines 670-674
function PostFogMaxDensityFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_fog_max_density, self._current)
end

PostEffectLightScaleFeeder = PostEffectLightScaleFeeder or CoreClass.class(Feeder)
PostEffectLightScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/effect_light_scale"):key()
PostEffectLightScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostEffectLightScaleFeeder.IS_GLOBAL = nil
PostEffectLightScaleFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 682-686
function PostEffectLightScaleFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)

	material:set_variable(ids_effect_light_scale, self._current)
end

SSAORadiusFeeder = SSAORadiusFeeder or CoreClass.class(Feeder)
SSAORadiusFeeder.DATA_PATH_KEY = Idstring("post_effect/SSAO_post_processor/SSAO/apply_SSAO/ssao_radius"):key()
SSAORadiusFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
SSAORadiusFeeder.IS_GLOBAL = nil
SSAORadiusFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 694-698
function SSAORadiusFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_SSAO_id, ids_post_SSAO, ids_SSAO, ids_apply_SSAO)

	material:set_variable(ids_ssao_radius, self._current)
end

SSAOIntensityFeeder = SSAOIntensityFeeder or CoreClass.class(Feeder)
SSAOIntensityFeeder.DATA_PATH_KEY = Idstring("post_effect/SSAO_post_processor/SSAO/apply_SSAO/ssao_intensity"):key()
SSAOIntensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
SSAOIntensityFeeder.IS_GLOBAL = nil
SSAOIntensityFeeder.FILTER_CATEGORY = "Ambient"

-- Lines 706-713
function SSAOIntensityFeeder:apply(handler, viewport, scene)
	managers.environment_controller:set_ssao_setting(managers.user:get_setting("ssao_setting"))

	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_SSAO_id, ids_post_SSAO, ids_SSAO, ids_apply_SSAO)

	material:set_variable(ids_ssao_intensity, self._current)
end

PostBloomIntensityFeeder = PostBloomIntensityFeeder or CoreClass.class(Feeder)
PostBloomIntensityFeeder.DATA_PATH_KEY = Idstring("post_effect/bloom_combine_post_processor/bloom_DOF_combine/post_DOF/bloom_intensity"):key()
PostBloomIntensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostBloomIntensityFeeder.IS_GLOBAL = nil
PostBloomIntensityFeeder.FILTER_CATEGORY = "Sun"

-- Lines 721-738
function PostBloomIntensityFeeder:apply(handler, viewport, scene)
	local has_bloom = self._current > 1e-05
	local bloom_prepare_effect = viewport:get_post_processor_effect(scene, ids_post_bloom_prepare, ids_bloom_prepare_effect)

	bloom_prepare_effect:set_visibility(has_bloom)

	if has_bloom then
		if not is_editor then
			viewport:set_post_processor_effect("World", ids_post_bloom_combine, ids_bloom_dof_effect)
		end

		self:_set_variable(viewport, scene, ids_post_bloom_combine, ids_bloom_dof_effect, ids_post_DOF_modifier, ids_bloom_intensity)
	elseif not is_editor then
		viewport:set_post_processor_effect("World", ids_post_bloom_combine, ids_dof_effect)
	end
end

PostLFGhostDispersalFeeder = PostLFGhostDispersalFeeder or CoreClass.class(Feeder)
PostLFGhostDispersalFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/ghost_dispersal"):key()
PostLFGhostDispersalFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFGhostDispersalFeeder.IS_GLOBAL = nil
PostLFGhostDispersalFeeder.FILTER_CATEGORY = "Sun"

-- Lines 747-749
function PostLFGhostDispersalFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_ghost_dispersal)
end

PostLFHaloWidthFeeder = PostLFHaloWidthFeeder or CoreClass.class(Feeder)
PostLFHaloWidthFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/halo_width"):key()
PostLFHaloWidthFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFHaloWidthFeeder.IS_GLOBAL = nil
PostLFHaloWidthFeeder.FILTER_CATEGORY = "Sun"

-- Lines 757-759
function PostLFHaloWidthFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_halo_width)
end

PostLFChromaticDistortionFeeder = PostLFChromaticDistortionFeeder or CoreClass.class(Feeder)
PostLFChromaticDistortionFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/chromatic_distortion"):key()
PostLFChromaticDistortionFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFChromaticDistortionFeeder.IS_GLOBAL = nil
PostLFChromaticDistortionFeeder.FILTER_CATEGORY = "Sun"

-- Lines 767-769
function PostLFChromaticDistortionFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_chromatic_distortion)
end

PostLFWeightExponentFeeder = PostLFWeightExponentFeeder or CoreClass.class(Feeder)
PostLFWeightExponentFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/weight_exponent"):key()
PostLFWeightExponentFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFWeightExponentFeeder.IS_GLOBAL = nil
PostLFWeightExponentFeeder.FILTER_CATEGORY = "Sun"

-- Lines 777-779
function PostLFWeightExponentFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_weight_exponent)
end

PostLFDownsampleScaleFeeder = PostLFDownsampleScaleFeeder or CoreClass.class(Feeder)
PostLFDownsampleScaleFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/downsample_scale"):key()
PostLFDownsampleScaleFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFDownsampleScaleFeeder.IS_GLOBAL = nil
PostLFDownsampleScaleFeeder.FILTER_CATEGORY = "Sun"

-- Lines 787-789
function PostLFDownsampleScaleFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_downsample_scale)
end

PostLFDownsampleBiasFeeder = PostLFDownsampleBiasFeeder or CoreClass.class(Feeder)
PostLFDownsampleBiasFeeder.DATA_PATH_KEY = Idstring("post_effect/lens_flare_post_processor/lens_flare_effect/lens_flare_material/downsample_bias"):key()
PostLFDownsampleBiasFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostLFDownsampleBiasFeeder.IS_GLOBAL = nil
PostLFDownsampleBiasFeeder.FILTER_CATEGORY = "Sun"

-- Lines 797-810
function PostLFDownsampleBiasFeeder:apply(handler, viewport, scene)
	local lens_flare_post = viewport:get_post_processor_effect(scene, ids_post_lens_flare, ids_lens_flare_effect)
	local lens_flare_apply_post = viewport:get_post_processor_effect(scene, ids_post_lens_flare_apply, ids_lens_flare_apply_effect)

	lens_flare_post:set_visibility(self._current < 1)
	lens_flare_apply_post:set_visibility(self._current < 1)

	local save_current = self._current
	self._current = Vector3(self._current, self._current, self._current)

	self:_set_variable(viewport, scene, ids_post_lens_flare, ids_lens_flare_effect, ids_lens_flare_modifier, ids_downsample_bias)

	self._current = save_current
end

PostVLSDensityFeeder = PostVLSDensityFeeder or CoreClass.class(Feeder)
PostVLSDensityFeeder.DATA_PATH_KEY = Idstring("post_effect/volumetric_light_scatter/volumetric_light_scatter/post_volumetric_light_scatter/light_scatter_density"):key()
PostVLSDensityFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostVLSDensityFeeder.IS_GLOBAL = true
PostVLSDensityFeeder.FILTER_CATEGORY = "Sun"

-- Lines 819-821
function PostVLSDensityFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_vls, ids_vls, ids_post_vls, ids_vls_density)
end

PostVLSWeightFeeder = PostVLSWeightFeeder or CoreClass.class(Feeder)
PostVLSWeightFeeder.DATA_PATH_KEY = Idstring("post_effect/volumetric_light_scatter/volumetric_light_scatter/post_volumetric_light_scatter/light_scatter_weight"):key()
PostVLSWeightFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostVLSWeightFeeder.IS_GLOBAL = true
PostVLSWeightFeeder.FILTER_CATEGORY = "Sun"

-- Lines 829-831
function PostVLSWeightFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_vls, ids_vls, ids_post_vls, ids_vls_weight)
end

PostVLSDecayFeeder = PostVLSDecayFeeder or CoreClass.class(Feeder)
PostVLSDecayFeeder.DATA_PATH_KEY = Idstring("post_effect/volumetric_light_scatter/volumetric_light_scatter/post_volumetric_light_scatter/light_scatter_decay"):key()
PostVLSDecayFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostVLSDecayFeeder.IS_GLOBAL = true
PostVLSDecayFeeder.FILTER_CATEGORY = "Sun"

-- Lines 839-841
function PostVLSDecayFeeder:apply(handler, viewport, scene)
	self:_set_variable(viewport, scene, ids_vls, ids_vls, ids_post_vls, ids_vls_decay)
end

PostVLSExposureFeeder = PostVLSExposureFeeder or CoreClass.class(Feeder)
PostVLSExposureFeeder.DATA_PATH_KEY = Idstring("post_effect/volumetric_light_scatter/volumetric_light_scatter/post_volumetric_light_scatter/light_scatter_exposure"):key()
PostVLSExposureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostVLSExposureFeeder.IS_GLOBAL = true
PostVLSExposureFeeder.FILTER_CATEGORY = "Sun"

-- Lines 849-852
function PostVLSExposureFeeder:apply(handler, viewport, scene)
	managers.environment_controller:set_volumetric_light_scatter_setting(managers.user:get_setting("vls_setting"))
	self:_set_variable(viewport, scene, ids_vls, ids_vls, ids_post_vls, ids_vls_exposure)
end

PostShadowSlice0Feeder = PostShadowSlice0Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice0Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice0"):key()
PostShadowSlice0Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice0Feeder.IS_GLOBAL = nil
PostShadowSlice0Feeder.FILTER_CATEGORY = "Shadow"

-- Lines 862-866
function PostShadowSlice0Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_slice0, self._current)
end

PostShadowSlice1Feeder = PostShadowSlice1Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice1Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice1"):key()
PostShadowSlice1Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice1Feeder.IS_GLOBAL = nil
PostShadowSlice1Feeder.FILTER_CATEGORY = "Shadow"

-- Lines 875-879
function PostShadowSlice1Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_slice1, self._current)
end

PostShadowSlice2Feeder = PostShadowSlice2Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice2Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice2"):key()
PostShadowSlice2Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice2Feeder.IS_GLOBAL = nil
PostShadowSlice2Feeder.FILTER_CATEGORY = "Shadow"

-- Lines 888-892
function PostShadowSlice2Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_slice2, self._current)
end

PostShadowSlice3Feeder = PostShadowSlice3Feeder or CoreClass.class(Vector3Feeder)
PostShadowSlice3Feeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/slice3"):key()
PostShadowSlice3Feeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSlice3Feeder.IS_GLOBAL = nil
PostShadowSlice3Feeder.FILTER_CATEGORY = "Shadow"

-- Lines 901-905
function PostShadowSlice3Feeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_slice3, self._current)
end

PostShadowSliceDepthsFeeder = PostShadowSliceDepthsFeeder or CoreClass.class(Vector3Feeder)
PostShadowSliceDepthsFeeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/shadow_slice_depths"):key()
PostShadowSliceDepthsFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSliceDepthsFeeder.IS_GLOBAL = nil
PostShadowSliceDepthsFeeder.FILTER_CATEGORY = "Shadow"

-- Lines 914-918
function PostShadowSliceDepthsFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_shadow_slice_depths, self._current)
end

PostShadowSliceOverlapFeeder = PostShadowSliceOverlapFeeder or CoreClass.class(Vector3Feeder)
PostShadowSliceOverlapFeeder.DATA_PATH_KEY = Idstring("post_effect/shadow_processor/shadow_rendering/shadow_modifier/shadow_slice_overlap"):key()
PostShadowSliceOverlapFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostShadowSliceOverlapFeeder.IS_GLOBAL = nil
PostShadowSliceOverlapFeeder.FILTER_CATEGORY = "Shadow"

-- Lines 927-931
function PostShadowSliceOverlapFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_shadow_modifier_id, ids_shadow_processor, ids_shadow_rendering, ids_shadow_modifier)

	material:set_variable(ids_shadow_slice_overlap, self._current)
end

UnderlayPathFeeder.AFFECTED_LIST = {
	GlobalLightColorScaleFeeder,
	GlobalLightColorFeeder,
	SkyRotationFeeder,
	UnderlaySkyTopColorFeeder,
	UnderlaySkyTopColorScaleFeeder,
	UnderlaySkyBottomColorFeeder,
	UnderlaySkyBottomColorScaleFeeder
}
