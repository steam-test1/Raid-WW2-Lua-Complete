DynamicResourceManager = DynamicResourceManager or class()
DynamicResourceManager.DYN_RESOURCES_PACKAGE = "packages/dyn_resources"
DynamicResourceManager.STREAMING_PROFILE_INGAME = "ingame"
DynamicResourceManager.STREAMING_PROFILE_LOADING = "loading"
DynamicResourceManager.STREAMING_PROFILES = {
	[DynamicResourceManager.STREAMING_PROFILE_INGAME] = {
		chunk_size = 1048576,
		sleep_time = 5
	},
	[DynamicResourceManager.STREAMING_PROFILE_LOADING] = {
		chunk_size = 5242880,
		sleep_time = 1
	}
}
DynamicResourceManager.listener_events = {
	file_streamer_workload = 1
}

function DynamicResourceManager:init()
	if not Global.dyn_resource_manager_data then
		Global.dyn_resource_manager_data = {
			streaming_settings = self.STREAMING_PROFILES[self.STREAMING_PROFILE_INGAME],
			dyn_resources = {}
		}
	end

	self._dyn_resources = Global.dyn_resource_manager_data.dyn_resources
	self._streaming_settings = Global.dyn_resource_manager_data.streaming_settings
	self._to_unload = nil
	self._listener_holder = EventListenerHolder:new()
end

function DynamicResourceManager:post_init()
	self:_set_file_streamer_settings(self:file_streamer_settings())
	self:preload_units()
end

function DynamicResourceManager:update()
	if self._to_unload then
		for key, unload_params in pairs(self._to_unload) do
			PackageManager:package(unload_params.package_name):unload_resource(unload_params.resource_type, unload_params.resource_name, unload_params.keep_using)
		end

		self._to_unload = nil
	end

	if self._listener_holder:has_listeners_for_event(self.listener_events.file_streamer_workload) then
		self:_check_file_streamer_status()
	end
end

function DynamicResourceManager:is_ready_to_close()
	if self._to_unload then
		if not self._still_unloading_msg then
			print("[DynamicResourceManager:is_ready_to_close] still unloading")

			self._still_unloading_msg = true
		end

		return false
	end

	for _, entry in pairs(self._dyn_resources) do
		if not entry.ready then
			if not self._loadign_temp_msg then
				self._loadign_temp_msg = true

				print("[DynamicResourceManager:is_ready_to_close] loading temp")
			end

			return false
		end
	end

	if not Global._game_base_package_loaded or not PackageManager:all_packages_loaded() then
		if not self._still_streaming_msg then
			print("[DynamicResourceManager:is_ready_to_close] waiting for packages to load.")

			self._still_streaming_msg = true
		end

		return false
	end

	return true
end

function DynamicResourceManager._get_resource_key(resource_type, resource_name, package_name)
	return package_name .. resource_name:key() .. resource_type:key()
end

function DynamicResourceManager:load(resource_type, resource_name, package_name, complete_clbk)
	local key = self._get_resource_key(resource_type, resource_name, package_name)
	local entry = self._to_unload and self._to_unload[key]

	if entry then
		entry.keep_using = nil
		entry.callbacks = {}
		self._dyn_resources[key] = entry
		self._to_unload[key] = nil

		if not next(self._to_unload) then
			self._to_unload = nil
		end
	end

	entry = entry or self._dyn_resources[key]

	if entry then
		entry.ref_c = entry.ref_c + 1

		if entry.ready then
			if complete_clbk then
				complete_clbk(true, resource_type, resource_name)
			end

			return
		elseif complete_clbk then
			table.insert(entry.callbacks, complete_clbk)

			return
		else
			entry.ready = true
		end
	else
		entry = {
			ref_c = 1,
			resource_type = resource_type,
			resource_name = resource_name,
			package_name = package_name,
			callbacks = {}
		}

		if complete_clbk then
			table.insert(entry.callbacks, complete_clbk)
		else
			entry.ready = true
		end

		self._dyn_resources[key] = entry
	end

	if complete_clbk and Application:editor() then
		PackageManager:package(package_name):load_temp_resource(resource_type, resource_name, nil)
		self:clbk_resource_loaded(true, resource_type, resource_name, package_name)
	else
		if not complete_clbk then
			Application:debug("[DynamicResourceManager:load]", resource_type, resource_name, package_name, complete_clbk)
		end

		PackageManager:package(package_name):load_temp_resource(resource_type, resource_name, complete_clbk and callback(self, DynamicResourceManager, "clbk_resource_loaded") or nil, true)
	end
end

function DynamicResourceManager:unload(resource_type, resource_name, package_name, keep_using)
	if keep_using then
		debug_pause("[DynamicResourceManager:unload] keep_using should be false!", resource_type, resource_name, package_name, keep_using)
	end

	local key = self._get_resource_key(resource_type, resource_name, package_name)
	local entry = self._dyn_resources[key]
	entry.ref_c = entry.ref_c - 1

	if entry.ref_c ~= 0 then
		return
	end

	self._to_unload = self._to_unload or {}
	self._to_unload[key] = entry
	entry.keep_using = keep_using
	entry.callbacks = nil
	self._dyn_resources[key] = nil
end

function DynamicResourceManager:has_resource(resource_type, resource_name, package_name)
	local key = self._get_resource_key(resource_type, resource_name, package_name)

	return self._dyn_resources[key] and true or false
end

function DynamicResourceManager:is_resource_ready(resource_type, resource_name, package_name)
	local key = self._get_resource_key(resource_type, resource_name, package_name)
	local entry = self._dyn_resources[key]

	return entry and entry.ready
end

function DynamicResourceManager:clbk_resource_loaded(status, resource_type, resource_name, package_name)
	local key = self._get_resource_key(resource_type, resource_name, package_name)
	local entry = self._dyn_resources[key] or self._to_unload and self._to_unload[key]

	if not entry then
		return
	end

	entry.ready = true

	if not entry.callbacks then
		return
	end

	local callbacks = entry.callbacks
	entry.callbacks = nil

	for _, clbk in ipairs(callbacks) do
		clbk(status, resource_type, resource_name)
	end
end

function DynamicResourceManager:change_material_config(name, unit)
	unit:set_material_config(name, true, callback(self, self, "on_material_applied", unit), 100)
end

function DynamicResourceManager:on_material_applied(unit)
	if alive(unit) then
		if unit:interaction() then
			unit:interaction():refresh_material()
		end

		if unit:contour() then
			unit:contour():update_materials()
		end
	end
end

function DynamicResourceManager:_check_file_streamer_status()
	local nr_tasks = Application:file_streamer_workload()

	self._listener_holder:call(self.listener_events.file_streamer_workload, nr_tasks)
end

function DynamicResourceManager:is_file_streamer_idle()
	local nr_tasks = Application:file_streamer_workload()

	return nr_tasks == 0
end

function DynamicResourceManager:set_file_streaming_profile(profile_name)
	local profile = DynamicResourceManager.STREAMING_PROFILES[profile_name]

	if not profile and not profile.chunk_size and not profile.sleep_time then
		Application:error("[DynamicResourceManager:set_file_streaming_profile] invalid streaming profile:", profile_name)

		return
	end

	if profile == self._streaming_settings then
		return
	end

	self._streaming_settings = profile

	Application:debug("[DynamicResourceManager:set_file_streaming_profile] name, chunk_size, sleep time:", profile_name, profile.chunk_size, profile.sleep_time)
	self:_set_file_streamer_settings(self:file_streamer_settings())
end

function DynamicResourceManager:_set_file_streamer_settings(chunk_size, sleep_time)
	Application:set_file_streamer_settings(chunk_size, sleep_time)
end

function DynamicResourceManager:file_streamer_settings()
	return self._streaming_settings.chunk_size, self._streaming_settings.sleep_time
end

function DynamicResourceManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function DynamicResourceManager:remove_listener(key)
	self._listener_holder:remove(key)
end

function DynamicResourceManager:preload_units()
end
