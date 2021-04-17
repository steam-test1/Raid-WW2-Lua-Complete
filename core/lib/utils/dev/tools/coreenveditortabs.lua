CoreEnvEditor = CoreEnvEditor or class()

-- Lines 3-136
function CoreEnvEditor:create_interface()
	local gui = self:add_sky_param("sun_ray_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Sun color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_sky_param("sun_ray_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Sun intensity", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_sky_param("sky_rotation", SingelSlider:new(self, self:get_tab("Global illumination"), "Sun rotation", nil, 0, 359, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "fog_start_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Fog start color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "fog_far_low_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Fog far low color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "fog_min_range", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog min range", nil, 0, 5000, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "fog_max_range", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog max range", nil, 0, 500000, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "fog_max_density", SingelSlider:new(self, self:get_tab("Global illumination"), "Fog max density", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "sky_top_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient top color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "sky_top_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient top scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "sky_bottom_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient bottom color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "sky_bottom_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient bottom scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "ambient_color", EnvEdColorBox:new(self, self:get_tab("Global illumination"), "Ambient color"))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "ambient_color_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient color scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "ambient_falloff_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Ambient falloff scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "effect_light_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Effect lighting scale", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "spec_factor", SingelSlider:new(self, self:get_tab("Global illumination"), "Specular factor", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("deferred", "apply_ambient", "gloss_factor", SingelSlider:new(self, self:get_tab("Global illumination"), "Glossiness factor", nil, -1000, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("SSAO_post_processor", "apply_SSAO", "ssao_radius", SingelSlider:new(self, self:get_tab("Global illumination"), "SSAO radius", nil, 1, 100, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("SSAO_post_processor", "apply_SSAO", "ssao_intensity", SingelSlider:new(self, self:get_tab("Global illumination"), "SSAO intensity (value of 0 turns off the effect)", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("bloom_combine_post_processor", "post_DOF", "bloom_intensity", SingelSlider:new(self, self:get_tab("Global illumination"), "Bloom intensity (value of 0 turns off the effect)", nil, 0, 2000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("volumetric_light_scatter", "post_volumetric_light_scatter", "light_scatter_density", SingelSlider:new(self, self:get_tab("Global illumination"), "Volumetric light scatter density", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("volumetric_light_scatter", "post_volumetric_light_scatter", "light_scatter_weight", SingelSlider:new(self, self:get_tab("Global illumination"), "Volumetric light scatter weight", nil, 0, 100, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("volumetric_light_scatter", "post_volumetric_light_scatter", "light_scatter_decay", SingelSlider:new(self, self:get_tab("Global illumination"), "Volumetric light scatter decay", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("volumetric_light_scatter", "post_volumetric_light_scatter", "light_scatter_exposure", SingelSlider:new(self, self:get_tab("Global illumination"), "Volumetric light scatter exposure (value of 0 turns off the effect)", nil, 0, 2000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "ghost_dispersal", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens ghost dispersal", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "halo_width", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens halo width", nil, 0, 2000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "chromatic_distortion", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens chromatic distortion", nil, 0, 30, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "weight_exponent", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens weight exponent", nil, 1, 50, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "downsample_scale", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens downsample scale", nil, 0, 10, 1, 1))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_post_processors_param("lens_flare_post_processor", "lens_flare_material", "downsample_bias", SingelSlider:new(self, self:get_tab("Global illumination"), "Lens downssample bias (value of 1 turns off the effect)", nil, 0, 1000, 1000, 1000))

	self:add_gui_element(gui, "Global illumination", "Global lighting")

	gui = self:add_underlay_param("sky", "color0", EnvEdColorBox:new(self, self:get_tab("Skydome"), "Color top"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color0_scale", SingelSlider:new(self, self:get_tab("Skydome"), "Color top scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color2", EnvEdColorBox:new(self, self:get_tab("Skydome"), "Color low"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_underlay_param("sky", "color2_scale", SingelSlider:new(self, self:get_tab("Skydome"), "Color low scale", nil, 0, 10000, 1000, 1000))

	self:add_gui_element(gui, "Skydome", "Sky")

	local gui = self:add_sky_param("underlay", PathBox:new(self, self:get_tab("Skydome"), "Underlay"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_sky_param("global_texture", DBPickDialog:new(self, self:get_tab("Skydome"), "Global cubemap", "texture"))

	self:add_gui_element(gui, "Skydome", "Sky")

	gui = self:add_sky_param("global_world_overlay_texture", DBPickDialog:new(self, self:get_tab("Global textures"), "Global world overlay texture", "texture"))

	self:add_gui_element(gui, "Global textures", "World")

	gui = self:add_sky_param("global_world_overlay_mask_texture", DBPickDialog:new(self, self:get_tab("Global textures"), "Global world overlay mask texture", "texture"))

	self:add_gui_element(gui, "Global textures", "World")

	gui = self:add_colorgrade(DBPickDialog:new(self, self:get_tab("Global textures"), "Colorgrade LUT texture", "texture"))

	self:add_gui_element(gui, "Global textures", "Colorgrade")
end

-- Lines 138-140
function CoreEnvEditor:create_simple_interface()
end
