core:module("CoreEnvironmentManager")
core:import("CoreClass")
core:import("CoreEnvironmentHandler")
core:import("CoreEnvironmentFeeder")

EnvironmentManager = EnvironmentManager or CoreClass.class()
local extension = "environment"
local ids_extension = Idstring(extension)

-- Lines 12-91
function EnvironmentManager:init()
	self._env_data_map = {}
	self._feeder_class_map = {}
	self._global_feeder_map = {}
	self._predefined_environment_filter_map = {}
	self._global_environment_modifier_map = {}
	self._game_default_environment_path = "core/environments/default"
	self._default_environment_path = self._game_default_environment_path
	local feeder_class_list = {
		CoreEnvironmentFeeder.ColorgradeFeeder,
		CoreEnvironmentFeeder.UnderlayPathFeeder,
		CoreEnvironmentFeeder.GlobalLightColorFeeder,
		CoreEnvironmentFeeder.GlobalLightColorScaleFeeder,
		CoreEnvironmentFeeder.CubeMapTextureFeeder,
		CoreEnvironmentFeeder.WorldOverlayTextureFeeder,
		CoreEnvironmentFeeder.WorldOverlayMaskTextureFeeder,
		CoreEnvironmentFeeder.SkyRotationFeeder,
		CoreEnvironmentFeeder.UnderlaySkyTopColorFeeder,
		CoreEnvironmentFeeder.UnderlaySkyTopColorScaleFeeder,
		CoreEnvironmentFeeder.UnderlaySkyBottomColorFeeder,
		CoreEnvironmentFeeder.UnderlaySkyBottomColorScaleFeeder,
		CoreEnvironmentFeeder.PostSpecFactorFeeder,
		CoreEnvironmentFeeder.PostGlossFactorFeeder,
		CoreEnvironmentFeeder.PostAmbientFalloffScaleFeeder,
		CoreEnvironmentFeeder.PostAmbientColorFeeder,
		CoreEnvironmentFeeder.PostAmbientColorScaleFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorFeeder,
		CoreEnvironmentFeeder.PostSkyTopColorScaleFeeder,
		CoreEnvironmentFeeder.PostSkyBottomColorFeeder,
		CoreEnvironmentFeeder.PostSkyBottomColorScaleFeeder,
		CoreEnvironmentFeeder.PostFogStartColorFeeder,
		CoreEnvironmentFeeder.PostFogFarLowColorFeeder,
		CoreEnvironmentFeeder.PostFogMinRangeFeeder,
		CoreEnvironmentFeeder.PostFogMaxRangeFeeder,
		CoreEnvironmentFeeder.PostFogMaxDensityFeeder,
		CoreEnvironmentFeeder.PostEffectLightScaleFeeder,
		CoreEnvironmentFeeder.SSAORadiusFeeder,
		CoreEnvironmentFeeder.SSAOIntensityFeeder,
		CoreEnvironmentFeeder.PostBloomIntensityFeeder,
		CoreEnvironmentFeeder.PostLFGhostDispersalFeeder,
		CoreEnvironmentFeeder.PostLFHaloWidthFeeder,
		CoreEnvironmentFeeder.PostLFChromaticDistortionFeeder,
		CoreEnvironmentFeeder.PostLFWeightExponentFeeder,
		CoreEnvironmentFeeder.PostLFDownsampleScaleFeeder,
		CoreEnvironmentFeeder.PostLFDownsampleBiasFeeder,
		CoreEnvironmentFeeder.PostVLSDensityFeeder,
		CoreEnvironmentFeeder.PostVLSWeightFeeder,
		CoreEnvironmentFeeder.PostVLSDecayFeeder,
		CoreEnvironmentFeeder.PostVLSExposureFeeder,
		CoreEnvironmentFeeder.PostShadowSlice0Feeder,
		CoreEnvironmentFeeder.PostShadowSlice1Feeder,
		CoreEnvironmentFeeder.PostShadowSlice2Feeder,
		CoreEnvironmentFeeder.PostShadowSlice3Feeder,
		CoreEnvironmentFeeder.PostShadowSliceDepthsFeeder,
		CoreEnvironmentFeeder.PostShadowSliceOverlapFeeder
	}

	for _, feeder_class in ipairs(feeder_class_list) do
		self._feeder_class_map[feeder_class.DATA_PATH_KEY] = feeder_class

		if feeder_class.FILTER_CATEGORY then
			local filter_list = self._predefined_environment_filter_map[feeder_class.FILTER_CATEGORY]

			if not filter_list then
				filter_list = {}
				self._predefined_environment_filter_map[feeder_class.FILTER_CATEGORY] = filter_list
			end

			table.insert(filter_list, feeder_class.DATA_PATH_KEY)
		end
	end

	self:preload_environment(self._game_default_environment_path)
end

-- Lines 93-99
function EnvironmentManager:destroy()
	self._env_data_map = nil
	self._feeder_class_map = nil
	self._global_feeder_map = nil
	self._predefined_environment_filter_map = nil
	self._global_environment_modifier_map = nil
end

-- Lines 101-105
function EnvironmentManager:preload_environment(path)
	if not self._env_data_map[path] then
		self._env_data_map[path] = self:_load(path)
	end
end

-- Lines 107-109
function EnvironmentManager:has_data_path_key(data_path_key)
	return self._feeder_class_map[data_path_key] ~= nil
end

-- Lines 111-113
function EnvironmentManager:get_predefined_environment_filter_map()
	return self._predefined_environment_filter_map
end

-- Lines 115-130
function EnvironmentManager:get_value(path, data_path_key)
	local env_data = self:_get_data(path)

	if not env_data then
		Application:stack_dump_error("[EnvironmentManager] Invalid environment path: " .. path)

		return nil
	end

	local value = env_data[data_path_key]

	if not value then
		Application:stack_dump_error("[EnvironmentManager] Invalid data path.")
	end

	return value
end

-- Lines 132-140
function EnvironmentManager:set_global_environment_modifier(data_path_key, is_override, modifier_func)
	local global_modifier_data = nil

	if modifier_func then
		global_modifier_data = {
			is_override = is_override,
			modifier_func = modifier_func
		}
	end

	self._global_environment_modifier_map[data_path_key] = global_modifier_data
end

-- Lines 142-144
function EnvironmentManager:set_default_environment(default_environment_path)
	self._default_environment_path = default_environment_path
end

-- Lines 146-148
function EnvironmentManager:default_environment()
	return self._default_environment_path
end

-- Lines 150-152
function EnvironmentManager:game_default_environment()
	return self._game_default_environment_path
end

-- Lines 154-158
function EnvironmentManager:_set_global_feeder(feeder)
	local old_feeder = self._global_feeder_map[feeder.DATA_PATH_KEY]
	self._global_feeder_map[feeder.DATA_PATH_KEY] = feeder

	return old_feeder
end

-- Lines 160-163
function EnvironmentManager:editor_add_created_callback(func)
	self._created_callback_list = self._created_callback_list or {}

	table.insert(self._created_callback_list, func)
end

-- Lines 165-199
function EnvironmentManager:editor_reload(path)
	local entry_path = managers.database:entry_relative_path(path .. "." .. extension)
	local is_new = not managers.database:has(entry_path)
	local source_files = {
		entry_path
	}

	for _, old_path in ipairs(managers.database:list_entries_of_type("environment")) do
		table.insert(source_files, old_path .. "." .. extension)
	end

	local compile_settings = {
		target_db_name = "all",
		send_idstrings = false,
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:base_path(),
		target_db_root = Application:base_path() .. "assets",
		source_files = source_files
	}

	Application:data_compile(compile_settings)
	DB:reload()
	managers.database:clear_all_cached_indices()
	PackageManager:reload(ids_extension, path:id())

	if self._env_data_map[path] then
		self._env_data_map[path] = self:_load(path)
	end

	if is_new and self._created_callback_list then
		for _, func in ipairs(self._created_callback_list) do
			func(path)
		end
	end
end

-- Lines 201-214
function EnvironmentManager:_get_data(path)
	local env_data = self._env_data_map[path]

	if not env_data then
		if not Application:editor() then
			Application:stack_dump_error("[EnvironmentManager] Environment was not preloaded: " .. tostring(path))
		end

		env_data = self:_load(path)
		self._env_data_map[path] = env_data
	end

	return env_data
end

-- Lines 216-225
function EnvironmentManager:_create_feeder(data_path_key, value)
	local feeder = self._feeder_class_map[data_path_key]:new(value)
	local global_modifier_data = self._global_environment_modifier_map[data_path_key]

	if global_modifier_data then
		feeder:set_modifier(global_modifier_data.modifier_func, global_modifier_data.is_override)
	end

	return feeder
end

-- Lines 227-241
function EnvironmentManager:_load(path)
	local raw_data = nil

	if Application:editor() then
		raw_data = PackageManager:editor_load_script_data(ids_extension, path:id())
	else
		raw_data = PackageManager:script_data(ids_extension, path:id())
	end

	local env_data = {}

	self:_load_env_data(nil, env_data, raw_data.data, path)

	return env_data
end

-- Lines 243-259
function EnvironmentManager:_load_env_data(data_path, env_data, raw_data, path)
	for _, sub_raw_data in ipairs(raw_data) do
		if sub_raw_data._meta == "param" then
			local next_data_path = data_path and data_path .. "/" .. sub_raw_data.key or sub_raw_data.key
			local next_data_path_key = Idstring(next_data_path):key()

			if self._feeder_class_map[next_data_path_key] then
				env_data[next_data_path_key] = sub_raw_data.value
			else
				Application:error("[EnvironmentManager] Invalid data path: " .. next_data_path .. " in " .. path)
			end
		else
			local next_data_path = data_path and data_path .. "/" .. sub_raw_data._meta or sub_raw_data._meta

			self:_load_env_data(next_data_path, env_data, sub_raw_data, path)
		end
	end
end
