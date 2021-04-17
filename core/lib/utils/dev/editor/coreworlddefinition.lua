core:module("CoreWorldDefinition")
core:import("CoreUnit")
core:import("CoreMath")
core:import("CoreEditorUtils")
core:import("CoreEngineAccess")
core:import("CoreTable")

local sky_orientation_data_key = Idstring("sky_orientation/rotation"):key()
WorldDefinition = WorldDefinition or class()
WorldDefinition.LOAD_UNITS_PER_FRAME = 100
WorldDefinition.TIME_PER_SECOND_FOR_PACKAGE_LOAD = 0.1667
WorldDefinition.ASYNC_CALLBACKS = Global.STREAM_ALL_PACKAGES
WorldDefinition.VEHICLES_CONTINENT_NAME = "NOT_USED_vehicles"
WorldDefinition.MAX_WORLD_UNIT_ID = 15
WorldDefinition.UNIT_ID_BASE = 1000000

-- Lines 23-207
function WorldDefinition:init(params)
	WorldDefinition.ASYNC_CALLBACKS = Global.STREAM_ALL_PACKAGES
	self._no_loading_packages = {}

	self:_add_loading_counter("on_world_package_loaded")

	self._unique_id_counter = {}
	self.is_prepared = false
	self._queued_packages = {}
	self._package_load_params = {}
	self._loaded_packages = {}

	self:_measure_lap_time("start init")

	if params.translation == nil then
		managers.worlddefinition = self
	end

	self._world_id = params.world_id or 0
	self._key_counter = 0
	self._id_converter = {
		old_to_new = {},
		new_to_old = {}
	}
	self._translation = params.translation
	self.is_streamed_world = self._world_id > 0
	self._created_by_editor = not self._translation and Application:editor()
	self._world_dir = params.world_dir
	self._cube_lights_path = params.cube_lights_path
	self._continent_definitions = {}
	self._continents = {}
	self._excluded_continents = {}
	self._massunit_replace_names = {}
	self._replace_names = {}
	self._ignore_spawn_list = {}
	self._all_units = {}
	self._trigger_units = {}
	self._use_unit_callbacks = {}
	self._mission_element_units = {}
	self._temp_units = {}
	self._temp_units_synced = {}
	self._units_synced_on_dropin = {}
	self._spawned_units = {}
	self._termination_counter = 0
	self._portal_slot_mask = World:make_slot_mask(1)
	self._replace_units_path = "assets/lib/utils/dev/editor/xml/replace_units"

	self:_parse_world_setting(params.world_setting, params.excluded_continents)

	self._file_type = params.file_type
	self._file_path = params.file_path

	Application:debug("[WorldDefinition:init:set_resource_loaded_clbk]")
	PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)
	self:_load_world_package()

	if not self.is_streamed_world or not WorldDefinition.ASYNC_CALLBACKS then
		self:_all_world_packages_loaded()
	end

	self:_measure_lap_time("start _serialize_to_script")
	self:_parse_replace_unit()
	self:_measure_lap_time("start _parse_world_setting")

	if not self.is_streamed_world then
		self.load_packages_done = true
		self.load_statics_done = true
		self.load_dynamics_done = true
		self.load_packages = nil
		self.load_statics = nil
		self.load_dynamics = nil
	else
		self.load_packages_done = false
		self.load_statics_done = false
		self.load_dynamics_done = false
		self.load_packages = coroutine.create(function ()
			self:_load_world_package()
		end)
		self.load_statics = coroutine.create(function ()
			if self._definition.statics then
				for _, values in ipairs(self._definition.statics) do
					values.unit_data.package = values.unit_data.package or self._definition.package
					local unit = self:_create_statics_unit(values, self._offset, true)

					coroutine.yield()
				end
			end

			for name, continent in pairs(self._continent_definitions) do
				local skip = false

				if name == WorldDefinition.VEHICLES_CONTINENT_NAME and self.spawn_counter > 1 then
					skip = true
				end

				local continent_def = self._continents[name]

				if continent.statics and not continent_def.editor_only and continent_def.enabled and not skip then
					local counter = 0

					for _, values in ipairs(continent.statics) do
						counter = counter + 1
						values.unit_data.package = values.unit_data.package or continent.package
						local unit = self:_create_statics_unit(values, self._offset, true, name)

						if counter == WorldDefinition.LOAD_UNITS_PER_FRAME then
							counter = 1

							coroutine.yield()
						end
					end
				end
			end

			self.load_statics_done = true
		end)
		self.load_dynamics = coroutine.create(function ()
			if self._definition.dynamics then
				for _, values in ipairs(self._definition.dynamics) do
					values.unit_data.package = values.unit_data.package or self._definition.package

					coroutine.yield()
				end
			end

			for name, continent in pairs(self._continent_definitions) do
				local continent_def = self._continents[name]

				if continent.dynamics and not continent_def.editor_only and continent_def.enabled then
					local counter = 0

					for _, values in ipairs(continent.dynamics) do
						counter = counter + 1
						values.unit_data.package = values.unit_data.package or continent.package
						local unit = self:_create_dynamics_unit(values, offset)

						if counter == WorldDefinition.LOAD_UNITS_PER_FRAME then
							counter = 1

							coroutine.yield()
						end
					end
				end
			end

			self.load_dynamics_done = true
		end)
	end

	self._offset = nil
	self._return_data = nil

	if self.is_streamed_world then
		for _, package in ipairs(self._loaded_packages) do
			-- Nothing
		end

		if not WorldDefinition.ASYNC_CALLBACKS then
			self.is_prepared = true
		end
	end

	if self._world_id == 0 then
		self.alarmed = true
	end

	if not WorldDefinition.ASYNC_CALLBACKS or not self.is_streamed_world then
		Application:debug("[WorldDefinition:init] Reenabling PackageManager:set_resource_loaded_clbk()")
		managers.sequence:preload()
		PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))
	end

	self._next_cleanup_t = 0

	self:_remove_loading_counter("on_world_package_loaded")
	self:_measure_lap_time("start end")
end

-- Lines 209-220
function WorldDefinition:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name:id())
	else
		if not PackageManager:has(type:id(), name:id()) then
			Application:throw_exception("Script data file " .. name .. " of type " .. type .. " has not been loaded. Could be that old world format is being loaded. Try resaving the level.")
		end

		return PackageManager:script_data(type:id(), name:id())
	end
end

-- Lines 222-224
function WorldDefinition:translation()
	return self._translation
end

-- Lines 226-228
function WorldDefinition:world_id()
	return self._world_id
end

-- Lines 230-232
function WorldDefinition:created_by_editor()
	return self._created_by_editor
end

-- Lines 234-236
function WorldDefinition:get_max_id()
	return self._definition.world_data.max_id
end

-- Lines 238-251
function WorldDefinition:_parse_replace_unit()
	local is_editor = Application:editor()

	if DB:has("xml", self._replace_units_path) then
		local node = DB:load_node("xml", self._replace_units_path)

		for unit in node:children() do
			local old_name = unit:name()
			local replace_with = unit:parameter("replace_with")
			self._replace_names[old_name] = replace_with

			if is_editor then
				managers.editor:output_info("Unit " .. old_name .. " will be replaced with " .. replace_with)
			end
		end
	end
end

-- Lines 254-260
function WorldDefinition:_translate_entries(entries)
	if not entries then
		return
	end

	for _, entry in ipairs(entries) do
		entry.rotation = self._translation.rotation * entry.rotation
		entry.position = self._translation.position + entry.position:rotate_with(self._translation.rotation)
	end
end

-- Lines 262-272
function WorldDefinition:_translate_covers(cover_data)
	if not cover_data then
		return
	end

	local i = 1

	for _, rotation in ipairs(cover_data.rotations) do
		local tmp_rot = Rotation(rotation, 0, 0)
		tmp_rot = self._translation.rotation * tmp_rot
		rotation = tmp_rot:yaw()
		cover_data.positions[i] = self._translation.position + cover_data.positions[i]:rotate_with(self._translation.rotation)
		i = i + 1
	end
end

-- Lines 275-295
function WorldDefinition:_translate_unit_entries(entries, base_id)
	if not entries then
		return
	end

	for _, entry in ipairs(entries) do
		entry.unit_data.rotation = self._translation.rotation * entry.unit_data.rotation
		entry.unit_data.position = self._translation.position + entry.unit_data.position:rotate_with(self._translation.rotation)
		entry.unit_data.original_unit_id = entry.unit_data.unit_id
		local new_id = self:_get_new_id(entry.unit_data.unit_id, base_id)
		entry.unit_data.unit_id = new_id

		if entry.wire_data then
			entry.wire_data.target_rot = self._translation.rotation * entry.wire_data.target_rot
			entry.wire_data.target_pos = self._translation.position + entry.wire_data.target_pos:rotate_with(self._translation.rotation)
		end

		if entry.unit_data.zipline then
			entry.unit_data.zipline.end_pos = self._translation.position + entry.unit_data.zipline.end_pos:rotate_with(self._translation.rotation)
		end
	end
end

-- Lines 298-311
function WorldDefinition:_add_translation()
	if not self._translation then
		return
	end

	Application:debug("[WorldDefinition:_add_translation()] Adding transaltion", inspect(self._translation))
	self:_translate_unit_entries(self._definition.wires)
	self:_translate_entries(self._definition.environment.effects)
	self:_translate_entries(self._definition.environment.environment_areas)

	for _, group in pairs(self._definition.portal.unit_groups) do
		self:_translate_entries(group.shapes)
	end
end

-- Lines 313-315
function WorldDefinition:world_dir()
	return self._world_dir
end

-- Lines 318-320
function WorldDefinition:continent_excluded(name)
	return self._excluded_continents[name]
end

-- Lines 323-359
function WorldDefinition:_load_world_package()
	if self._created_by_editor then
		return
	end

	local package = self._world_dir .. "world"

	if not DB:is_bundled() and not DB:has("package", package) then
		Application:throw_exception("No world.package file found in " .. self._world_dir .. ", please resave level")

		return
	end

	if WorldDefinition.ASYNC_CALLBACKS then
		self:_load_package_async(package, "on_world_package_loaded")
	else
		self:_load_package(package)
	end

	self._current_world_package = package
	local init_package = self._world_dir .. "world_init"

	if not DB:is_bundled() and not DB:has("package", init_package) then
		Application:throw_exception("No world_init.package file found in " .. self._world_dir .. ", please resave level")

		return
	end

	if WorldDefinition.ASYNC_CALLBACKS then
		self:_load_package_async(init_package, "on_world_package_loaded", nil, true)
	else
		self:_load_package(init_package)
	end

	self._current_world_init_package = init_package

	self:_load_sound_package()
end

-- Lines 361-373
function WorldDefinition:_load_sound_package()
	local package = self._world_dir .. "world_sounds"

	if not DB:is_bundled() and not DB:has("package", package) then
		Application:error("No world_sounds.package file found in " .. self._world_dir .. ", emitters and ambiences won't work (resave level)")

		return
	end

	if WorldDefinition.ASYNC_CALLBACKS then
		self:_load_package_async(package, "on_world_package_loaded")
	else
		self:_load_package(package)
	end

	self._current_sound_package = package
end

-- Lines 376-395
function WorldDefinition:_load_continent_init_package(path, cb_name, key)
	if self._created_by_editor then
		return
	end

	if not DB:is_bundled() and not DB:has("package", path) then
		Application:error("Missing init package for a continent(" .. path .. "), resave level " .. self._world_dir .. ".")

		return
	end

	self._continent_init_packages = self._continent_init_packages or {}

	if WorldDefinition.ASYNC_CALLBACKS then
		self:_load_package_async(path, cb_name, key, true)
	else
		self:_load_package(path)
	end

	table.insert(self._continent_init_packages, path)
end

-- Lines 397-399
function WorldDefinition:on_world_package_loaded(params, package)
	Application:debug("[WorldDefinition:on_world_package_loaded()] WORLD PACKAGE LOADED", package, params)
end

-- Lines 401-434
function WorldDefinition:on_continent_package_loaded(params, package)
	Application:debug("[WorldDefinition:on_continent_package_loaded()] CONTITNENT PACKAGE LOADED", package, inspect(params))

	self._package_load_params[params.key].loaded = true
	local name = self._package_load_params[params.key].name
	local pkg = self._package_load_params[params.key].pkg
	local dep_loaded = true

	if PackageManager:package_exists(params.dep_pkg) then
		dep_loaded = PackageManager:loaded(params.dep_pkg) and not managers.worldcollection:test_package_loading(params.dep_pkg)
	end

	if name and dep_loaded then
		Application:debug("[WorldDefinition:on_continent_package_loaded()] Finishing up continent load", pkg)

		if DB:has("continent", pkg) then
			self._continent_definitions[name] = self:_serialize_to_script("continent", pkg)
			self._continent_definitions[name].package = pkg

			if Application:editor() then
				local path = self:world_dir() .. name .. "/mission"

				if DB:has("continent", path) then
					local mission_data = self:_serialize_to_script("continent", path)

					for mission_data_name, mission_data_block in pairs(mission_data) do
						self._continent_definitions[name][mission_data_name] = mission_data_block
					end
				end
			end
		else
			Application:error("Continent file " .. package .. " continent doesnt exist.")
		end
	end
end

-- Lines 436-453
function WorldDefinition:on_instance_package_loaded(params, package)
	Application:debug("[WorldDefinition:on_instance_package_loaded()] INSTANCE PACKAGE LOADED", package, inspect(params))

	local instance = self._package_load_params[params.key].instance
	local pkg = self._package_load_params[params.key].pkg
	local dep_loaded = true

	if PackageManager:package_exists(params.dep_pkg) then
		dep_loaded = PackageManager:loaded(params.dep_pkg) and not managers.worldcollection:test_package_loading(params.dep_pkg)
	end

	if instance and dep_loaded and not self._package_load_params[params.key].loaded then
		Application:debug("[WorldDefinition:on_instance_package_loaded()] Finishing up instance load", params.key, pkg)
		self:_do_instance_loaded(params.key)

		self._package_load_params[params.key].loaded = true
	end
end

-- Lines 455-482
function WorldDefinition:_do_instance_loaded(key)
	Application:debug("WorldDefinition:_do_instance_loaded(key)", key, inspect(self._package_load_params[key]))

	local instance = self._package_load_params[key].instance
	local data = self._package_load_params[key].data

	if self._created_by_editor or not instance.mission_placed then
		local package_data = managers.world_instance:packages_by_instance(instance)
		local prepared_unit_data = managers.world_instance:prepare_unit_data(instance, self._continents[instance.continent], self._translation and self)

		if prepared_unit_data.statics then
			for _, static in ipairs(prepared_unit_data.statics) do
				data.statics = data.statics or {}
				static.unit_data.package = package_data.package

				table.insert(data.statics, static)
			end
		end

		if prepared_unit_data.dynamics then
			for _, dynamic in ipairs(prepared_unit_data.dynamics) do
				data.dynamics = data.dynamics or {}
				dynamic.unit_data.package = package_data.package

				table.insert(data.dynamics, dynamic)
			end
		end
	else
		managers.world_instance:prepare_serialized_instance_data(instance)
	end
end

-- Lines 486-509
function WorldDefinition:_load_continent_package(path, cb_name, key)
	if self._created_by_editor then
		return
	end

	if not PackageManager:package_exists(path) then
		Application:debug("Missing package for a continent(" .. path .. "), maybe level needs to be resaved: " .. self._world_dir .. ".")

		return
	end

	self:_measure_lap_time("cont start " .. path)

	self._continent_packages = self._continent_packages or {}

	table.insert(self._continent_packages, path)

	if WorldDefinition.ASYNC_CALLBACKS then
		self:_load_package_async(path, cb_name, key)
	else
		self:_load_package(path)
	end

	self:_measure_lap_time("cont end " .. path)
end

-- Lines 512-524
function WorldDefinition:unload_packages()
	self:_unload_package(self._current_world_package)
	self:_unload_package(self._current_sound_package)

	for _, package in ipairs(self._continent_packages) do
		self:_unload_package(package)
	end

	self:_unload_package(self._current_world_init_package)

	for _, package in ipairs(self._continent_init_packages) do
		self:_unload_package(package)
	end
end

-- Lines 527-534
function WorldDefinition:_unload_package(package)
	if not package then
		return
	end

	if self.is_streamed_world then
		managers.worldcollection:delete_package_ref(package)
	end
end

-- Lines 537-564
function WorldDefinition:_parse_world_setting(world_setting, excluded_continents)
	Application:debug("[WorldDefinition:_parse_world_setting]", inspect(excluded_continents))

	if excluded_continents then
		for _, cont in ipairs(excluded_continents) do
			self._excluded_continents[cont] = true
		end
	end

	if not world_setting then
		return
	end

	local path = self:world_dir() .. world_setting

	if not DB:has("world_setting", path) then
		Application:error("There is no world_setting file " .. world_setting .. " at path " .. path)

		return
	end

	local t = self:_serialize_to_script("world_setting", path)

	if t._meta then
		Application:throw_exception("Loading old world setting file (" .. path .. "), resave it!")
	end

	for name, bool in pairs(t) do
		self._excluded_continents[name] = self._excluded_continents[name] or bool
	end
end

-- Lines 566-617
function WorldDefinition:parse_continents(node, t)
	local path = self:world_dir() .. self._definition.world_data.continents_file

	if not DB:has("continents", path) then
		Application:error("Continent file didn't exist " .. path .. ").")

		return
	end

	self._continents = self:_serialize_to_script("continents", path)
	self._continents._meta = nil

	self:_add_loading_counter("on_continent_package_loaded")

	for name, data in pairs(self._continents) do
		if not self:_continent_editor_only(data) then
			if not self._excluded_continents[name] then
				local init_path = self:world_dir() .. name .. "/" .. name .. "_init"
				local path = self:world_dir() .. name .. "/" .. name
				local pkg_key = self:next_key()
				self._package_load_params[pkg_key] = {
					name = name,
					pkg = path
				}

				self:_load_continent_init_package(init_path, "on_continent_package_loaded", pkg_key)
				self:_load_continent_package(path, "on_continent_package_loaded", pkg_key)

				if not self.is_streamed_world or not WorldDefinition.ASYNC_CALLBACKS then
					if DB:has("continent", path) then
						self._continent_definitions[name] = self:_serialize_to_script("continent", path)
						self._continent_definitions[name].package = path

						if Application:editor() then
							local path = self:world_dir() .. name .. "/mission"

							if DB:has("continent", path) then
								local mission_data = self:_serialize_to_script("continent", path)

								for mission_data_name, mission_data_block in pairs(mission_data) do
									self._continent_definitions[name][mission_data_name] = mission_data_block
								end
							end
						end
					else
						Application:error("Continent file " .. path .. ".continent doesnt exist.")
					end
				end
			end
		else
			self._excluded_continents[name] = true
		end
	end

	self:_remove_loading_counter("on_continent_package_loaded")

	if not self.is_streamed_world or not WorldDefinition.ASYNC_CALLBACKS then
		self:_all_continent_packages_loaded()
	end
end

-- Lines 619-625
function WorldDefinition:get_next_unique_id(base_id)
	local base = base_id or 100000
	self._unique_id_counter[base] = self._unique_id_counter[base] or 0
	self._unique_id_counter[base] = self._unique_id_counter[base] + 1
	local id = self._world_id % WorldDefinition.MAX_WORLD_UNIT_ID * WorldDefinition.UNIT_ID_BASE + base + self._unique_id_counter[base]

	return id
end

-- Lines 627-630
function WorldDefinition:get_next_unique_instance_id(old_id)
	local id = self._world_id % WorldDefinition.MAX_WORLD_UNIT_ID * WorldDefinition.UNIT_ID_BASE + old_id

	return id
end

-- Lines 632-637
function WorldDefinition:_get_new_id(old_id, base_id)
	local new_id = self:get_next_unique_id(base_id)
	self._id_converter.old_to_new[old_id] = new_id
	self._id_converter.new_to_old[new_id] = old_id

	return new_id
end

-- Lines 639-644
function WorldDefinition:_get_new_instance_id(old_id, offset)
	local new_id = self:get_next_unique_instance_id(old_id)
	self._id_converter.old_to_new[old_id] = new_id
	self._id_converter.new_to_old[new_id] = old_id

	return new_id
end

-- Lines 647-685
function WorldDefinition:_add_continent_translation()
	if not self._translation then
		return
	end

	for name, data in pairs(self._continent_definitions) do
		self:_translate_unit_entries(data.statics, self._continents[name].base_id)
		self:_translate_unit_entries(data.dynamics, self._continents[name].base_id)
		self:_translate_entries(data.instances)
	end
end

-- Lines 687-736
function WorldDefinition:_insert_instances()
	self:_add_loading_counter("on_instance_package_loaded")

	for name, data in pairs(self._continent_definitions) do
		if data.instances then
			for i, instance in ipairs(data.instances) do
				local skip = false

				if instance.continent == WorldDefinition.VEHICLES_CONTINENT_NAME and self.spawn_counter > 1 then
					skip = true
				end

				if not skip then
					local package_data = managers.world_instance:packages_by_instance(instance)
					local pkg_key = self:next_key()
					self._package_load_params[pkg_key] = {
						data = data,
						instance = instance,
						pkg = package_data.package
					}

					self:_load_continent_init_package(package_data.init_package, "on_instance_package_loaded", pkg_key)
					self:_load_continent_package(package_data.package, "on_instance_package_loaded", pkg_key)

					if not self.is_streamed_world or not WorldDefinition.ASYNC_CALLBACKS then
						if self._created_by_editor or not instance.mission_placed then
							local prepared_unit_data = managers.world_instance:prepare_unit_data(instance, self._continents[instance.continent], self._translation and self)

							if prepared_unit_data.statics then
								for _, static in ipairs(prepared_unit_data.statics) do
									data.statics = data.statics or {}
									static.unit_data.package = package_data.package

									table.insert(data.statics, static)
								end
							end

							if prepared_unit_data.dynamics then
								for _, dynamic in ipairs(prepared_unit_data.dynamics) do
									data.dynamics = data.dynamics or {}
									dynamic.unit_data.package = package_data.package

									table.insert(data.dynamics, dynamic)
								end
							end
						else
							managers.world_instance:prepare_serialized_instance_data(instance)
						end
					end
				end
			end
		end
	end

	self:_remove_loading_counter("on_instance_package_loaded")
end

-- Lines 739-741
function WorldDefinition:_continent_editor_only(data)
	return not Application:editor() and data.editor_only
end

-- Lines 744-754
function WorldDefinition:init_done()
	if self._continent_init_packages then
		for _, package in ipairs(self._continent_init_packages) do
			-- Nothing
		end
	end

	self._continent_definitions = nil
	self._definition = nil
	self.is_created = true
end

-- Lines 756-764
function WorldDefinition:_measure_lap_time(name)
	return

	self._start_lap = self._start_lap or TimerManager:now()
	local now = TimerManager:now()

	Application:debug("Lap ", name, now - self._start_lap)

	self._start_lap = now
end

-- Lines 766-1014
function WorldDefinition:create(layer, offset, world_in_world, nav_graph_loaded)
	Application:debug("[WorldDefinition:create]", layer, offset, world_in_world, nav_graph_loaded)
	Application:check_termination()
	self:_measure_lap_time("start create")

	offset = offset or Vector3(0, 0, 0)
	local return_data = {}

	if (layer == "level_settings" or layer == "all") and self._definition.level_settings then
		self:_load_level_settings(self._definition.level_settings.settings, offset)

		return_data = self._definition.level_settings.settings
	end

	self:_measure_lap_time("level_settings")

	if layer == "markers" then
		return_data = self._definition.world_data.markers
	end

	if layer == "values" then
		local t = {}

		for name, continent in pairs(self._continent_definitions) do
			t[name] = continent.values
		end

		return_data = t
	end

	if layer == "editor_groups" then
		return_data = self:_create_editor_groups()
	end

	if layer == "continents" then
		return_data = self._continents
	end

	if layer == "instances" or layer == "all" then
		for name, continent in pairs(self._continent_definitions) do
			if continent.instances then
				for _, data in ipairs(continent.instances) do
					if self._translation then
						data.worlddefinition_id = self._world_id
					end

					managers.world_instance:add_instance_data(data)
					table.insert(return_data, data)
				end
			end
		end
	end

	self:_measure_lap_time("instances")
	self:_create_cover_data()

	if layer == "ai" and self._definition.ai then
		for _, values in ipairs(self._definition.ai) do
			local unit = self:_create_ai_editor_unit(values, offset)

			if unit then
				table.insert(return_data, unit)
			end
		end
	end

	self:_measure_lap_time("ai")

	if layer == "ai" or layer == "all" then
		if self._definition.ai_nav_graphs and not nav_graph_loaded then
			self:_load_ai_nav_graphs(self._definition.ai_nav_graphs, offset)
			Application:cleanup_thread_garbage()
		end

		self:_measure_lap_time("nav")

		if self._definition.ai_mop_graphs then
			self:_load_ai_mop_graphs(self._definition.ai_mop_graphs, offset)
			Application:cleanup_thread_garbage()
		end

		self:_measure_lap_time("mop")
	end

	Application:check_termination()

	if layer == "ai_settings" or layer == "all" then
		Application:debug("[WorldDefinition:create()] loading AI settengs")

		if self._definition.ai_settings then
			return_data = self:_load_ai_settings(self._definition.ai_settings, offset)
		end
	end

	Application:check_termination()

	if (layer == "portal" or layer == "all") and self._definition.portal then
		self:_create_portal(self._definition.portal, offset)

		return_data = self._definition.portal
	end

	self:_measure_lap_time("portal")
	Application:check_termination()

	if layer == "sounds" or layer == "all" then
		return_data = self:_create_sounds(self._definition.sounds)
	end

	self:_measure_lap_time("sounds")
	Application:check_termination()

	if layer == "mission_scripts" then
		return_data.scripts = return_data.scripts or {}

		if self._definition.mission_scripts then
			for _, values in ipairs(self._definition.mission_scripts) do
				for name, script in pairs(values) do
					return_data.scripts[name] = script
				end
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.mission_scripts then
				for _, values in ipairs(continent.mission_scripts) do
					for name, script in pairs(values) do
						return_data.scripts[name] = script
					end
				end
			end
		end
	end

	self:_measure_lap_time("mission_scripts")

	if layer == "mission" then
		if self._definition.mission then
			for _, values in ipairs(self._definition.mission) do
				table.insert(return_data, self:_create_mission_unit(values, offset))
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.mission then
				for _, values in ipairs(continent.mission) do
					table.insert(return_data, self:_create_mission_unit(values, offset))
				end
			end
		end
	end

	self:_measure_lap_time("mission")

	if (layer == "brush" or layer == "all") and self._definition.brush then
		self:_create_massunit(self._definition.brush, offset)
	end

	self:_measure_lap_time("brush")
	Application:check_termination()

	if layer == "environment" or layer == "all" then
		local environment = self._definition.environment

		self:_create_environment(environment, offset, world_in_world)

		return_data = CoreTable.deep_clone(environment)
	end

	self:_measure_lap_time("environment")

	if layer == "world_camera" or layer == "all" then
		self:_create_world_cameras(self._definition.world_camera, self._translation)
	end

	self:_measure_lap_time("world_camera")

	if (layer == "wires" or layer == "all") and self._definition.wires then
		for _, values in ipairs(self._definition.wires) do
			table.insert(return_data, self:_create_wires_unit(values, offset))
		end
	end

	self:_measure_lap_time("wires")

	self.load_statics_done = false
	self._offset = offset
	self._return_data = return_data

	if (layer == "statics" or layer == "all") and not world_in_world then
		if self._definition.statics then
			for _, values in ipairs(self._definition.statics) do
				values.unit_data.package = values.unit_data.package or self._definition.package
				local unit = self:_create_statics_unit(values, offset)

				if unit then
					table.insert(return_data, unit)
				end
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.statics then
				for _, values in ipairs(continent.statics) do
					values.unit_data.package = values.unit_data.package or continent.package
					local unit = self:_create_statics_unit(values, offset)

					if unit then
						table.insert(return_data, unit)
					end
				end
			end
		end
	end

	self:_measure_lap_time("statics")

	if (layer == "dynamics" or layer == "all") and not world_in_world then
		if self._definition.dynamics then
			for _, values in ipairs(self._definition.dynamics) do
				values.unit_data.package = values.unit_data.package or self._definition.package

				table.insert(return_data, self:_create_dynamics_unit(values, offset))
			end
		end

		for name, continent in pairs(self._continent_definitions) do
			if continent.dynamics then
				for _, values in ipairs(continent.dynamics) do
					values.unit_data.package = values.unit_data.package or continent.package
					local unit = self:_create_dynamics_unit(values, offset)

					if unit then
						table.insert(return_data, unit)
					end
				end
			end
		end
	end

	self:_measure_lap_time("dynamics")

	return return_data
end

-- Lines 1016-1022
function WorldDefinition:destroy()
	self.destroyed = true

	managers.sound_environment:destroy_world_sounds(self._world_id)
	managers.environment_area:remove_all_areas_for_world(self._world_id)
	managers.worldcamera:destroy_world_cameras(self._world_id)
	managers.environment_effects:kill_world_mission_effects(self._world_id)
end

-- Lines 1024-1026
function WorldDefinition:_load_level_settings(data, offset)
end

-- Lines 1028-1046
function WorldDefinition:_load_ai_nav_graphs(data, offset)
	local path = self:world_dir() .. data.file

	if not DB:has("nav_data", path) then
		Application:error("The specified nav data file '" .. path .. ".nav_data' was not found for this level! ", path, "Navigation graph will not be loaded!")

		return
	end

	self:_measure_lap_time("_load_ai_nav_graphs")

	local values = self:_serialize_to_script("nav_data", path)

	self:_measure_lap_time("_load_ai_nav_graphs PARSE")
	Application:check_termination()
	managers.navigation:set_load_data(values, self._world_id, self._translation and self._translation.position, self._translation and mrotation.yaw(self._translation.rotation))
	managers.navigation:register_cover_units(self._world_id)
	self:_measure_lap_time("_load_ai_nav_graphs LOAD")
end

-- Lines 1049-1066
function WorldDefinition:_load_ai_mop_graphs(data, offset)
	local path = self:world_dir() .. data.file

	if not DB:has("mop_data", path) then
		Application:error("The specified mop data file '" .. path .. ".mop_data' was not found for this level! ", path, "Motion paths will not be loaded!")

		return
	end

	local values = self:_serialize_to_script("mop_data", path)

	Application:check_termination()

	local motion_path = self._world_id ~= 0 and managers.worldcollection:motion_path_by_id(self._world_id) or managers.motion_path

	motion_path:set_load_data(values, self._translation)

	values = nil
end

-- Lines 1068-1072
function WorldDefinition:_load_ai_settings(data, offset)
	managers.groupai:set_state(data.ai_settings.group_state, self._world_id)
	managers.ai_data:load_data(data.ai_data)

	return data.ai_settings
end

-- Lines 1074-1107
function WorldDefinition:_create_portal(data, offset)
	if not Application:editor() then
		for _, portal in ipairs(data.portals) do
			local t = {}

			for _, point in ipairs(portal.points) do
				table.insert(t, point.position + offset)
			end

			local top = portal.top
			local bottom = portal.bottom

			if top == 0 and bottom == 0 then
				top, bottom = nil
			end

			managers.portal:add_portal(t, bottom, top)
		end
	end

	data.unit_groups._meta = nil

	for name, data in pairs(data.unit_groups) do
		if managers.portal:unit_group(name) then
			name = managers.portal:group_name()
		end

		local group = managers.portal:add_unit_group(name)
		local shapes = data.shapes or data

		for _, shape in ipairs(shapes) do
			group:add_shape(shape)
		end

		group:set_ids(data.ids, self)
	end
end

-- Lines 1109-1132
function WorldDefinition:_create_editor_groups()
	local groups = {}
	local group_names = {}

	if self._definition.editor_groups then
		for _, values in ipairs(self._definition.editor_groups) do
			if not groups[values.name] then
				groups[values.name] = values

				table.insert(group_names, values.name)
			end
		end
	end

	for name, continent in pairs(self._continent_definitions) do
		if continent.editor_groups then
			for _, values in ipairs(continent.editor_groups) do
				if not groups[values.name] then
					groups[values.name] = values

					table.insert(group_names, values.name)
				end
			end
		end
	end

	return {
		groups = groups,
		group_names = group_names
	}
end

-- Lines 1134-1142
function WorldDefinition:_add_sound_translation(values)
	if not self._translation then
		return
	end

	self:_translate_entries(values.sound_emitters)
	self:_translate_entries(values.sound_environments)
	self:_translate_entries(values.sound_area_emitters)
end

-- Lines 1144-1154
function WorldDefinition:_create_cover_data()
	local path = self:world_dir() .. "cover_data"

	if not DB:has("cover_data", path) then
		return false
	end

	self._cover_data = self:_serialize_to_script("cover_data", path)

	if self._translation then
		self:_translate_covers(self._cover_data)
	end
end

-- Lines 1156-1158
function WorldDefinition:get_cover_data()
	return self._cover_data
end

-- Lines 1160-1183
function WorldDefinition:_create_sounds(data)
	local path = self:world_dir() .. data.file

	if not DB:has("world_sounds", path) then
		Application:error("The specified sound file '" .. path .. ".world_sounds' was not found for this level! ", path, "No sound will be loaded!")

		return
	end

	local values = self:_serialize_to_script("world_sounds", path)

	self:_add_sound_translation(values)
	managers.sound_environment:set_default_environment(values.default_environment)
	managers.sound_environment:set_default_ambience(values.default_ambience)
	managers.sound_environment:set_ambience_enabled(values.ambience_enabled)
	managers.sound_environment:set_default_occasional(values.default_occasional)

	for _, sound_environment in ipairs(values.sound_environments) do
		managers.sound_environment:add_area(sound_environment, self._world_id)
	end

	for _, sound_emitter in ipairs(values.sound_emitters) do
		managers.sound_environment:add_emitter(sound_emitter, self._world_id)
	end

	for _, sound_area_emitter in ipairs(values.sound_area_emitters) do
		managers.sound_environment:add_area_emitter(sound_area_emitter, self._world_id)
	end
end

local zero_rot = Rotation()

-- Lines 1188-1222
function WorldDefinition:_create_massunit(data, offset)
	local path = self:world_dir() .. data.file

	if Application:editor() then
		CoreEngineAccess._editor_load(Idstring("massunit"), path:id())

		local l = MassUnitManager:list(path:id())

		for _, name in ipairs(l) do
			if DB:has(Idstring("unit"), name:id()) then
				CoreEngineAccess._editor_load(Idstring("unit"), name:id())
			elseif not table.has(self._massunit_replace_names, name:s()) then
				managers.editor:output("Unit " .. name:s() .. " does not exist")

				local old_name = name:s()
				name = managers.editor:show_replace_massunit()

				if name and DB:has(Idstring("unit"), name:id()) then
					CoreEngineAccess._editor_load(Idstring("unit"), name:id())
				end

				self._massunit_replace_names[old_name] = name or ""

				managers.editor:output("Unit " .. old_name .. " changed to " .. tostring(name))
			end
		end
	end

	local rotation = self._translation and self._translation.rotation or zero_rot

	if self._translation then
		offset = self._translation.position
	end

	MassUnitManager:delete_all_units()
	MassUnitManager:load(path:id(), offset, rotation, self._massunit_replace_names)
end

-- Lines 1224-1229
function check_is_environment_vanilla(environment_name)
	local vanilla_env_path = "environments/vanilla"

	if environment_name:sub(0, vanilla_env_path:len()) ~= vanilla_env_path then
		Application:error("[NOT VANILLA][Environment] Loading environment outside of vanilla folder: ", environment_name)
	end
end

-- Lines 1231-1243
function WorldDefinition:_set_environment(environment_name)
	check_is_environment_vanilla(environment_name)

	if Global.game_settings.level_id then
		local env_params = _G.tweak_data.levels[Global.game_settings.level_id].env_params

		if env_params then
			environment_name = env_params.environment or environment_name
		end
	end

	if environment_name ~= "none" then
		managers.viewport:preload_environment(environment_name)
		managers.viewport:set_default_environment(environment_name, nil, nil)
	end
end

-- Lines 1245-1302
function WorldDefinition:_create_environment(data, offset, world_in_world)
	if not world_in_world or self.meta_data and self.meta_data.load_env == "true" then
		self:_set_environment(data.environment_values.environment)
	end

	local offset = 0

	if self._translation then
		offset = 0
	end

	local wind = data.wind

	Wind:set_direction(wind.angle, wind.angle_var, 5)
	Wind:set_tilt(wind.tile, wind.tilt_var, 5)
	Wind:set_speed_m_s(wind.speed or 6, wind.speed_variation or 1, 5)
	Wind:set_enabled(true)

	if not self._created_by_editor then
		for _, unit_effect in ipairs(data.effects) do
			local name = Idstring(unit_effect.name)

			if DB:has("effect", name) then
				managers.portal:add_effect({
					effect = name,
					position = unit_effect.position,
					rotation = unit_effect.rotation
				})
			end
		end
	end

	for _, environment_area in ipairs(data.environment_areas) do
		check_is_environment_vanilla(environment_area.environment)
		managers.viewport:preload_environment(environment_area.environment)
		managers.environment_area:add_area(environment_area, self._world_id)
	end

	if Application:editor() then
		local units = {}

		for _, gizmo in ipairs(data.cubemap_gizmos) do
			local unit = self:make_unit(gizmo, offset)

			table.insert(units, unit)
		end

		data.units = units
	end

	if data.dome_occ_shapes then
		local shape_data = data.dome_occ_shapes[1]

		if shape_data then
			local corner = shape_data.position
			local size = Vector3(shape_data.depth, shape_data.width, shape_data.height)
			local texture_name = self:world_dir() .. "cube_lights/" .. "dome_occlusion"

			if not DB:has(Idstring("texture"), Idstring(texture_name)) then
				Application:error("Dome occlusion texture doesn't exists, probably needs to be generated", texture_name)
			else
				managers.environment_controller:set_dome_occ_params(corner, size, texture_name)
			end
		end
	end
end

-- Lines 1304-1315
function WorldDefinition:_create_world_cameras(data, translation)
	local path = self:world_dir() .. data.file

	if not DB:has("world_cameras", path) then
		Application:error("No world_camera file found! (" .. path .. ")")

		return
	end

	local values = self:_serialize_to_script("world_cameras", path)
	local world_translation = self._translation and self._translation.position or Vector3(0, 0, 0)
	local world_rotation_yaw = self._translation and mrotation.yaw(self._translation.rotation) or 0

	managers.worldcamera:load(values, self._world_id, world_translation, world_rotation_yaw)
end

-- Lines 1317-1331
function WorldDefinition:_create_mission_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	local unit = self:make_unit(data.unit_data, offset)

	if unit then
		unit:mission_element_data().script = data.script

		self:add_mission_element_unit(unit)

		for name, value in pairs(data.script_data) do
			unit:mission_element_data()[name] = value
		end

		unit:mission_element():post_init()
	end

	return unit
end

-- Lines 1333-1347
function WorldDefinition:_create_wires_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	local unit = self:make_unit(data.unit_data, offset)

	if unit then
		unit:wire_data().slack = data.wire_data.slack
		local target = unit:get_object(Idstring("a_target"))

		target:set_position(data.wire_data.target_pos)
		target:set_rotation(data.wire_data.target_rot)
		CoreMath.wire_set_midpoint(unit, unit:orientation_object():name(), Idstring("a_target"), Idstring("a_bender"))
		unit:set_moving()
	end

	return unit
end

-- Lines 1349-1352
function WorldDefinition:_create_statics_unit(data, offset, world_in_world, continent_name)
	self:preload_unit(data.unit_data.name)

	return self:make_unit(data.unit_data, offset, world_in_world, continent_name)
end

-- Lines 1354-1357
function WorldDefinition:_create_dynamics_unit(data, offset)
	self:preload_unit(data.unit_data.name)

	return self:make_unit(data.unit_data, offset)
end

-- Lines 1359-1367
function WorldDefinition:_create_ai_editor_unit(data, offset)
	local unit = self:_create_statics_unit(data, offset)

	if data.ai_editor_data then
		for name, value in pairs(data.ai_editor_data) do
			unit:ai_editor_data()[name] = value
		end
	end

	return unit
end

-- Lines 1371-1390
function WorldDefinition:preload_unit(name)
	local is_editor = Application:editor()

	if table.has(self._replace_names, name) then
		name = self._replace_names[name]
	elseif is_editor and (not DB:has(Idstring("unit"), name:id()) or CoreEngineAccess._editor_unit_data(name:id()):type():id() == Idstring("deleteme")) then
		if not DB:has(Idstring("unit"), name:id()) then
			managers.editor:output_info("Unit " .. name .. " does not exist")
		else
			managers.editor:output_info("Unit " .. name .. " is of type " .. CoreEngineAccess._editor_unit_data(name:id()):type():t())
		end

		local old_name = name
		name = managers.editor:show_replace_unit()
		self._replace_names[old_name] = name

		managers.editor:output_info("Unit " .. old_name .. " changed to " .. tostring(name))
	end

	if is_editor and name then
		CoreEngineAccess._editor_load(Idstring("unit"), name:id())
	end
end

local is_editor = Application:editor()

-- Lines 1394-1476
function WorldDefinition:make_unit(data, offset, world_in_world, continent_name)
	local name = data.name

	if self._ignore_spawn_list[Idstring(name):key()] then
		return nil
	end

	if table.has(self._replace_names, name) then
		name = self._replace_names[name]
	end

	if not name then
		return nil
	end

	data.continent_name = continent_name
	local pkg = data.package or ""
	local network_sync = PackageManager:unit_data(name:id(), pkg):network_sync()
	local need_sync = false
	local unit = nil

	if network_sync ~= "none" and network_sync ~= "client" then
		need_sync = true

		if not is_editor and not Network:is_server() then
			local found = false

			for _, u in ipairs(self._temp_units_synced) do
				if u.synced_editor_id == data.unit_id then
					unit = managers.worldcollection:get_unit_with_real_id(u.unit_id)

					if unit then
						self:assign_unit_data(unit, data, world_in_world)

						found = true
						u.found_unit = unit
					end
				end
			end

			if not found then
				table.insert(self._temp_units, data)
			end

			return
		end
	end

	if MassUnitManager:can_spawn_unit(Idstring(name)) and not is_editor then
		unit = MassUnitManager:spawn_unit(Idstring(name), data.position + offset, data.rotation)
	elseif data.package then
		unit = CoreUnit.safe_spawn_unit_from_package(name, data.package, data.position, data.rotation)
	else
		unit = CoreUnit.safe_spawn_unit(name, data.position, data.rotation)
	end

	if unit then
		self:assign_unit_data(unit, data, world_in_world)
	elseif is_editor then
		local s = "Failed creating unit " .. tostring(name)

		Application:throw_exception(s)
	end

	if self._termination_counter == 0 then
		Application:check_termination()
	end

	self._termination_counter = (self._termination_counter + 1) % 100

	if Network:is_server() and need_sync then
		table.insert(self._units_synced_on_dropin, {
			unit_id = unit:id(),
			editor_id = unit:editor_id()
		})
		managers.network:session():send_to_peers_synched("sync_unit_data", unit, self._world_id, unit:editor_id())
	end

	return unit
end

local is_editor = Application:editor()

-- Lines 1479-1528
function WorldDefinition:assign_unit_data(unit, data, world_in_world)
	if not unit:unit_data() then
		Application:error("The unit does not have the required extension unit_data (ScriptUnitData)", unit)
	end

	if unit:unit_data().only_exists_in_editor and (not is_editor or world_in_world) then
		self._ignore_spawn_list[unit:name():key()] = true

		unit:set_slot(0)

		return
	end

	unit:unit_data().instance = data.instance
	unit:unit_data().continent_name = data.continent_name
	unit:unit_data().package = data.package

	self:_setup_unit_id(unit, data)
	self:_setup_editor_unit_data(unit, data)

	if unit:unit_data().helper_type and unit:unit_data().helper_type ~= "none" then
		managers.helper_unit:add_unit(unit, unit:unit_data().helper_type)
	end

	if data.continent and self._created_by_editor then
		managers.editor:add_unit_to_continent(data.continent, unit)
	end

	self:_setup_lights(unit, data)
	self:_setup_variations(unit, data)
	self:_setup_editable_gui(unit, data)
	self:add_trigger_sequence(unit, data.triggers)
	self:_set_only_visible_in_editor(unit, data, world_in_world)
	self:_setup_cutscene_actor(unit, data)
	self:_setup_disable_shadow(unit, data)
	self:_setup_hide_on_projection_light(unit, data)
	self:_setup_disable_on_ai_graph(unit, data)
	self:_add_to_portal(unit, data)
	self:_setup_projection_light(unit, data)
	self:_setup_ladder(unit, data)
	self:_setup_zipline(unit, data)
	self:_project_assign_unit_data(unit, data)

	for _, ext in pairs(unit:extensions_infos()) do
		if ext.on_load_complete then
			ext:on_load_complete()
		end
	end
end

-- Lines 1531-1543
function WorldDefinition:_setup_unit_id(unit, data)
	unit:unit_data().unit_id = data.unit_id

	unit:set_editor_id(unit:unit_data().unit_id)

	local old_unit = self._all_units[unit:unit_data().unit_id]

	if old_unit and not Application:editor() then
		Application:debug("[WorldDefinition:_setup_unit_id] Leaking unit! old unit", old_unit, inspect(old_unit:unit_data()))
		Application:debug("[WorldDefinition:_setup_unit_id] Leaking unit! new unit", unit, inspect(data))
		_G.debug_pause("[WorldDefinition:_setup_unit_id] Leaking unit! unique_id_counter:", inspect(self._unique_id_counter))
	end

	self._all_units[unit:unit_data().unit_id] = unit

	self:use_me(unit, Application:editor())
end

-- Lines 1546-1554
function WorldDefinition:_setup_editor_unit_data(unit, data)
	if not Application:editor() then
		return
	end

	unit:unit_data().name_id = data.name_id
	unit:unit_data().world_pos = unit:position()
	unit:unit_data().projection_lights = data.projection_lights
end

-- Lines 1557-1590
function WorldDefinition:_setup_lights(unit, data)
	if not data.lights then
		return
	end

	for _, l in ipairs(data.lights) do
		local light = unit:get_object(l.name:id())

		if light then
			light:set_enable(l.enabled)
			light:set_far_range(l.far_range)
			light:set_near_range(l.near_range or light:near_range())
			light:set_color(l.color)
			light:set_spot_angle_start(l.spot_angle_start)
			light:set_spot_angle_end(l.spot_angle_end)

			if l.multiplier_nr then
				light:set_multiplier(l.multiplier_nr)
			end

			if l.specular_multiplier_nr then
				light:set_specular_multiplier(l.specular_multiplier_nr)
			end

			if l.multiplier then
				l.multiplier = l.multiplier:id()

				light:set_multiplier(LightIntensityDB:lookup(l.multiplier))
				light:set_specular_multiplier(LightIntensityDB:lookup_specular_multiplier(l.multiplier))
			end

			light:set_falloff_exponent(l.falloff_exponent)
			light:set_linear_attenuation_factor(l.linear_attenuation_factor)

			if l.clipping_values then
				light:set_clipping_values(l.clipping_values)
			end
		end
	end
end

-- Lines 1593-1595
function WorldDefinition:setup_lights(...)
	self:_setup_lights(...)
end

-- Lines 1598-1616
function WorldDefinition:_setup_variations(unit, data)
	if data.mesh_variation and data.mesh_variation ~= "default" then
		if not Application:editor() or unit:damage() and unit:damage():has_sequence(data.mesh_variation) then
			unit:unit_data().mesh_variation = data.mesh_variation

			managers.sequence:run_sequence_simple2(unit:unit_data().mesh_variation, "change_state", unit)
		elseif Application:editor() then
			managers.editor:output_info("Removed variation sequence " .. data.mesh_variation .. " from unit " .. unit:name():s())
		end
	end

	if data.material_variation and data.material_variation ~= "default" then
		unit:unit_data().material = data.material_variation

		unit:set_material_config(Idstring(unit:unit_data().material), true, function ()
		end)
	end
end

-- Lines 1618-1643
function WorldDefinition:_setup_editable_gui(unit, data)
	if not data.editable_gui then
		return
	end

	if not unit:editable_gui() then
		Application:error("Unit has editable gui data saved but no editable gui extesnion. No text will be loaded. (probably cause the unit should no longer have editable text)")

		return
	end

	unit:editable_gui():set_text(data.editable_gui.text)
	unit:editable_gui():set_font_color(data.editable_gui.font_color)
	unit:editable_gui():set_font_size(data.editable_gui.font_size)
	unit:editable_gui():set_font(data.editable_gui.font)
	unit:editable_gui():set_align(data.editable_gui.align)
	unit:editable_gui():set_vertical(data.editable_gui.vertical)
	unit:editable_gui():set_blend_mode(data.editable_gui.blend_mode)
	unit:editable_gui():set_render_template(data.editable_gui.render_template)
	unit:editable_gui():set_wrap(data.editable_gui.wrap)
	unit:editable_gui():set_word_wrap(data.editable_gui.word_wrap)
	unit:editable_gui():set_alpha(data.editable_gui.alpha)
	unit:editable_gui():set_shape(data.editable_gui.shape)

	if not Application:editor() then
		unit:editable_gui():lock_gui()
	end
end

-- Lines 1645-1657
function WorldDefinition:_setup_ladder(unit, data)
	if not data.ladder then
		return
	end

	if not unit:ladder() then
		Application:error("Unit has ladder data saved but no ladder extension. No ladder data will be loaded.")

		return
	end

	unit:ladder():set_width(data.ladder.width)
	unit:ladder():set_height(data.ladder.height)
end

-- Lines 1659-1674
function WorldDefinition:_setup_zipline(unit, data)
	if not data.zipline then
		return
	end

	if not unit:zipline() then
		Application:error("Unit has zipline data saved but no zipline extension. No zipline data will be loaded.")

		return
	end

	unit:zipline():set_end_pos(data.zipline.end_pos)
	unit:zipline():set_speed(data.zipline.speed)
	unit:zipline():set_slack(data.zipline.slack)
	unit:zipline():set_usage_type(data.zipline.usage_type)
	unit:zipline():set_ai_ignores_bag(data.zipline.ai_ignores_bag)
end

-- Lines 1677-1679
function WorldDefinition:external_set_only_visible_in_editor(unit)
	self:_set_only_visible_in_editor(unit, nil)
end

-- Lines 1682-1689
function WorldDefinition:_set_only_visible_in_editor(unit, data, world_in_world)
	if Application:editor() and not world_in_world then
		return
	end

	if unit:unit_data().only_visible_in_editor then
		unit:set_visible(false)
	end
end

-- Lines 1692-1699
function WorldDefinition:_setup_cutscene_actor(unit, data)
	if not data.cutscene_actor then
		return
	end

	unit:unit_data().cutscene_actor = data.cutscene_actor

	managers.cutscene:register_cutscene_actor(unit)
end

-- Lines 1702-1711
function WorldDefinition:_setup_disable_shadow(unit, data)
	if not data.disable_shadows then
		return
	end

	if Application:editor() then
		unit:unit_data().disable_shadows = data.disable_shadows
	end

	unit:set_shadows_disabled(data.disable_shadows)
end

-- Lines 1714-1722
function WorldDefinition:_setup_hide_on_projection_light(unit, data)
	if not data.hide_on_projection_light then
		return
	end

	if Application:editor() then
		unit:unit_data().hide_on_projection_light = data.hide_on_projection_light
	end
end

-- Lines 1725-1733
function WorldDefinition:_setup_disable_on_ai_graph(unit, data)
	if not data.disable_on_ai_graph then
		return
	end

	if Application:editor() then
		unit:unit_data().disable_on_ai_graph = data.disable_on_ai_graph
	end
end

-- Lines 1736-1746
function WorldDefinition:_add_to_portal(unit, data)
	if self._created_by_editor or not self._portal_slot_mask then
		return
	end

	if unit:in_slot(self._portal_slot_mask) and not unit:unit_data().only_visible_in_editor then
		managers.portal:add_unit(unit, self, data.original_unit_id)
	end
end

-- Lines 1749-1776
function WorldDefinition:_setup_projection_light(unit, data)
	if not data.projection_light then
		return
	end

	unit:unit_data().projection_textures = data.projection_textures
	unit:unit_data().projection_light = data.projection_light
	local light = unit:get_object(Idstring(data.projection_light))
	local texture_name = nil

	if unit:unit_data().projection_textures then
		texture_name = unit:unit_data().projection_textures[data.projection_light]

		if not DB:has(Idstring("texture"), Idstring(texture_name)) then
			Application:error("Projection light texture doesn't exists,", unit, texture_name)

			return
		end
	else
		local id = data.original_unit_id or unit:unit_data().unit_id
		texture_name = (self._cube_lights_path or self:world_dir()) .. "cube_lights/" .. id

		if not DB:has(Idstring("texture"), Idstring(texture_name)) then
			Application:error("Cube light texture doesn't exists, probably needs to be generated", unit, texture_name)

			return
		end
	end

	local omni = string.find(light:properties(), "omni") and true or false

	light:set_projection_texture(Idstring(texture_name), omni, true)
end

-- Lines 1779-1781
function WorldDefinition:setup_projection_light(...)
	self:_setup_projection_light(...)
end

-- Lines 1784-1785
function WorldDefinition:_project_assign_unit_data(...)
end

-- Lines 1787-1809
function WorldDefinition:add_trigger_sequence(unit, triggers)
	local is_editor = Application:editor()

	if not triggers then
		return
	end

	for _, trigger in ipairs(triggers) do
		local notify_unit = managers.worldcollection:get_unit_with_id(trigger.notify_unit_id, nil, self._world_id)

		if notify_unit then
			unit:damage():add_trigger_sequence(trigger.name, trigger.notify_unit_sequence, notify_unit, trigger.time, nil, nil, is_editor)
		elseif self._trigger_units[trigger.notify_unit_id] then
			table.insert(self._trigger_units[trigger.notify_unit_id], {
				unit = unit,
				trigger = trigger
			})
		else
			self._trigger_units[trigger.notify_unit_id] = {
				{
					unit = unit,
					trigger = trigger
				}
			}
		end
	end
end

-- Lines 1812-1836
function WorldDefinition:use_me(unit, is_editor)
	local id = unit:unit_data().unit_id
	id = id ~= 0 and id or unit:editor_id()
	unit:unit_data().unit_id = id

	if not self._all_units[id] then
		self:_on_dropin_unit_added(unit)
	end

	self._all_units[id] = self._all_units[id] or unit
	local original_id = self:get_original_unit_id(id)

	if self._trigger_units[original_id] then
		for _, t in ipairs(self._trigger_units[original_id]) do
			t.unit:damage():add_trigger_sequence(t.trigger.name, t.trigger.notify_unit_sequence, unit, t.trigger.time, nil, nil, is_editor)
		end

		self._trigger_units[original_id] = nil
	end

	if self._use_unit_callbacks[original_id] then
		for _, call in ipairs(self._use_unit_callbacks[original_id]) do
			call(unit)
		end

		self._use_unit_callbacks[original_id] = nil
	end
end

-- Lines 1839-1853
function WorldDefinition:get_unit_on_load(id, call)
	if not id then
		Application:error("[WorldDefinition:get_unit_on_load( id, call )] id is nill?")

		return
	end

	local unit = self:get_unit_by_id(id)

	if unit then
		return unit
	end

	self._use_unit_callbacks[id] = self._use_unit_callbacks[id] or {}

	table.insert(self._use_unit_callbacks[id], call)
end

-- Lines 1855-1857
function WorldDefinition:_on_dropin_unit_added(unit)
	self:_add_to_portal(unit, {
		original_unit_id = self:id_convert_new_to_old(unit:unit_data().unit_id)
	})
end

-- Lines 1859-1864
function WorldDefinition:get_original_unit_id(id)
	if not self._translation then
		return id
	end

	return self:id_convert_new_to_old(id)
end

-- Lines 1866-1871
function WorldDefinition:get_unique_id(id)
	if not self._translation then
		return id
	end

	return self:id_convert_old_to_new(id)
end

-- Lines 1873-1878
function WorldDefinition:id_convert_old_to_new(id)
	if self._world_id > 0 then
		return self._id_converter.old_to_new[id]
	end

	return id
end

-- Lines 1880-1885
function WorldDefinition:id_convert_new_to_old(id)
	if self._world_id > 0 then
		return self._id_converter.new_to_old[id]
	end

	return id
end

-- Lines 1887-1892
function WorldDefinition:get_unit_by_id(id)
	if self._translation then
		return self._all_units[self._id_converter.old_to_new[id]]
	end

	return self._all_units[id]
end

-- Lines 1894-1896
function WorldDefinition:register_spawned_unit(unit)
	table.insert(self._spawned_units, unit)
end

-- Lines 1898-1908
function WorldDefinition:cleanup_spawned_units(unit)
	local new_spawend_units = {}

	for _, unit in ipairs(self._spawned_units) do
		if alive(unit) then
			table.insert(new_spawend_units, unit)
		end
	end

	self._spawned_units = new_spawend_units
	self._next_cleanup_t = Application:time() + 5
end

-- Lines 1911-1913
function WorldDefinition:add_mission_element_unit(unit)
	self._mission_element_units[unit:unit_data().unit_id] = unit
end

-- Lines 1916-1918
function WorldDefinition:get_mission_element_unit(id)
	return self._mission_element_units[id]
end

-- Lines 1920-1940
function WorldDefinition:update_load(t, dt)
	if managers.worldcollection.concurrent_create ~= self._world_id then
		return
	end

	if not self.load_statics_done and not self.load_statics_error then
		local k, v = coroutine.resume(self.load_statics)

		if not k then
			Application:error("[WorldDefinition:update_load] ERROR IN CORUTINE, LEVEL WILL NOT LOAD", v)

			self.load_statics_error = true
		end
	end

	if not self.load_dynamics_done and not self.load_dynamics_error then
		local k, v = coroutine.resume(self.load_dynamics)

		if not k then
			Application:error("[WorldDefinition:update_load] ERROR IN CORUTINE, LEVEL WILL NOT LOAD", v)

			self.load_dynamics_error = true
		end
	end

	self.creation_in_progress = not self.load_statics_done or not self.load_dynamics_done
end

-- Lines 1942-1983
function WorldDefinition:update_prepare(t, dt)
	if managers.worldcollection._sync_loading_packages and managers.worldcollection._sync_loading_packages > 0 then
		Application:debug("[WorldDefinition:update_prepare] Waiting for dropin sync packages to load")

		return
	end

	if self:_test_loading_counter("on_world_package_loaded") then
		self:_all_world_packages_loaded()
	else
		return
	end

	if self:_test_loading_counter("on_continent_package_loaded") then
		self:_all_continent_packages_loaded()
	else
		return
	end

	if self:_test_loading_counter("on_instance_package_loaded") then
		Application:debug("[WorldDefinition:update_prepare] WORLD PREPARED, world_id:", self._world_id)

		self.is_prepared = true

		managers.worldcollection:complete_world_loading_stage(self._world_id, "STAGE_PREPARE")

		if managers.worldcollection:check_all_worlds_prepared() then
			Application:debug("[WorldDefinition:update_prepare()] Reenabling PackageManager:set_resource_loaded_clbk()")

			if not managers.player.dropin then
				managers.sequence:preload()
			end

			PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))
			Application:debug("[WorldDefinition:update_prepare()] Managers sequence count:", managers.sequence:count())
		end
	end
end

-- Lines 1985-1994
function WorldDefinition:_add_loading_counter(callback_method, pkg)
	Application:trace("[WorldDefinition:_add_loading_counter]", callback_method)

	self._no_loading_packages[callback_method] = self._no_loading_packages[callback_method] or {}
	self._no_loading_packages[callback_method].count = self._no_loading_packages[callback_method].count or 0
	self._no_loading_packages[callback_method].count = self._no_loading_packages[callback_method].count + 1

	if pkg then
		managers.worldcollection._package_loading[pkg] = true
	end
end

-- Lines 1996-2005
function WorldDefinition:_remove_loading_counter(callback_method, pkg)
	Application:trace("[WorldDefinition:_remove_loading_counter]", callback_method)

	self._no_loading_packages[callback_method].count = self._no_loading_packages[callback_method].count - 1

	if self._no_loading_packages[callback_method].count < 0 then
		self._no_loading_packages[callback_method].count = 0
	end

	if pkg then
		managers.worldcollection._package_loading[pkg] = nil
	end
end

-- Lines 2008-2014
function WorldDefinition:_test_loading_counter(callback_method)
	local result = false

	if self._no_loading_packages[callback_method] and self._no_loading_packages[callback_method].count == 0 then
		result = true
	end

	return result
end

-- Lines 2017-2076
function WorldDefinition:_load_package_async(pkg, callback_method, key, init_pkg)
	self:keep_alive(TimerManager:now())

	if self.is_streamed_world and string.find(pkg, "vehicles$") then
		Application:debug("WorldDefinition:_load_package_async] Skip loading of the vehicles package in the streamed world:", package, callback_method)

		return
	end

	local dep_pkg = nil

	if not init_pkg then
		dep_pkg = pkg .. "_init"
	else
		dep_pkg = string.sub(pkg, 1, string.find(pkg, "_init") - 1)
	end

	local params = {
		key = key,
		dep_pkg = dep_pkg,
		init_pkg = init_pkg
	}

	if self.is_streamed_world then
		managers.worldcollection:add_package_ref(pkg)
	end

	if PackageManager:loaded(pkg) then
		if managers.worldcollection:test_package_loading(params.dep_pkg) then
			Application:trace("[WorldDefinition:_load_package_async] Putting callback to queue", pkg, callback_method)

			self._temp_queue = self._temp_queue or {}
			self._temp_queue[pkg] = self._temp_queue[pkg] or {}
			self._temp_queue[pkg][key] = params
		elseif self.is_streamed_world then
			self[callback_method](self, params, pkg)
		end

		return
	end

	Application:debug("[WorldDefinition:_load_package_async] Loading...", pkg)
	table.insert(self._loaded_packages, pkg)

	if self.is_streamed_world then
		self:_add_loading_counter(callback_method, pkg)
		PackageManager:load(pkg, function ()
			Application:debug("[WorldDefinition:_load_package_async] DONE", pkg)
			self[callback_method](self, params, pkg)

			if self._temp_queue and self._temp_queue[pkg] then
				Application:trace("[WorldDefinition:_load_package_async] Fire up queued methods", inspect(self._temp_queue[pkg]))

				for key, value in pairs(self._temp_queue[pkg]) do
					self[callback_method](self, value, pkg)
				end

				self._temp_queue[pkg] = nil
			end

			self:_remove_loading_counter(callback_method, pkg)
		end)
	else
		Application:trace("[WorldDefinition:_load_package_async] Trying to async load non streamed level", pkg)
		PackageManager:load(pkg)
	end
end

-- Lines 2081-2098
function WorldDefinition:_load_package(package)
	self:keep_alive(TimerManager:now())

	if self.is_streamed_world and string.find(package, "vehicles$") then
		Application:debug("WorldDefinition:_load_package] Skip loading of the vehicles package in the streamed world:", package)

		return
	end

	managers.worldcollection:add_package_ref(package)

	if PackageManager:loaded(package) then
		return
	end

	Application:debug("[WorldDefinition:_load_package] Loading package", package)
	table.insert(self._loaded_packages, package)
	PackageManager:load(package)
end

-- Lines 2100-2116
function WorldDefinition:sync_unit_data(unit, editor_id)
	local found = false

	for _, data in ipairs(self._temp_units) do
		if data.unit_id == editor_id then
			self:assign_unit_data(unit, data)
			self:use_me(unit, Application:editor())

			found = true
			data.found_unit = unit
		end
	end

	if not found then
		table.insert(self._temp_units_synced, {
			synced_editor_id = editor_id,
			unit_id = unit:id()
		})
	end
end

-- Lines 2118-2120
function WorldDefinition:sync_unit_reference_data(unit_id, editor_id)
	table.insert(self._temp_units_synced, {
		dropin = true,
		synced_editor_id = editor_id,
		unit_id = unit_id
	})
end

-- Lines 2123-2126
function WorldDefinition:next_key()
	self._key_counter = self._key_counter + 1

	return self._key_counter
end

-- Lines 2128-2137
function WorldDefinition:_all_world_packages_loaded()
	if not self._all_world_packages_loaded_called then
		Application:trace("[WorldDefinition:_all_world_packages_loaded()]")

		self._all_world_packages_loaded_called = true
		self._definition = self:_serialize_to_script(self._file_type, self._file_path)
		self._definition.package = self._file_path

		self:_add_translation()
		self:parse_continents()
	end
end

-- Lines 2139-2146
function WorldDefinition:_all_continent_packages_loaded()
	if not self._all_continent_packages_loaded_called then
		Application:trace("[WorldDefinition:_all_continent_packages_loaded()]")

		self._all_continent_packages_loaded_called = true

		self:_add_continent_translation()
		self:_insert_instances()
	end
end

-- Lines 2148-2158
function WorldDefinition:keep_alive(t)
	if not managers.network:session() then
		return
	end

	self._keep_alive_t = self._keep_alive_t or t

	if self._keep_alive_t < t then
		self._keep_alive_t = t + 1

		managers.network:session():send_to_peers_ip_verified("connection_keep_alive")
	end
end
