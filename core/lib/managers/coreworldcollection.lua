core:import("CoreWorldDefinition")

CoreWorldCollection = CoreWorldCollection or class()
CoreWorldCollection.MAX_STITCHER_ID = 1000
CoreWorldCollection.STAGE_PREPARE = "STAGE_PREPARE"
CoreWorldCollection.STAGE_LOAD = "STAGE_LOAD"
CoreWorldCollection.STAGE_LOAD_FINISHED = "STAGE_LOAD_FINISHED"
CoreWorldCollection.STAGE_DESTROY = "STAGE_DESTROY"
CoreWorldCollection.STATES_NOT_ALOWED_TRANSITION = {
	"ingame_special_interaction",
	"world_camera",
	"event_complete_screen",
	"ingame_waiting_for_players",
	"ingame_driving"
}

-- Lines 14-52
function CoreWorldCollection:init(params)
	self.queued_client_mission_executions = {}
	self.queued_server_mission_executions = {}
	self.queued_world_creation = {}
	self.queued_world_prepare = {}
	self.queued_world_destruction = {}
	self.concurrent_prepare = 0
	self.concurrent_create = 0
	self._world_definitions = {}
	self._missions = {}
	self._mission_paths = {}
	self._mission_params = {}
	self._motion_paths = {}
	self._package_loading = {}
	self._predefined_worlds_file = "lib/utils/dev/editor/xml/predefined_worlds"

	self:_load_predefined_worlds()

	self._world_id_counter = 1
	self._editor_world_names = {}
	self._world_spawns = {}
	self._input_elements = {}
	self._output_elements = {}
	self._world_loaded_callbacks = {}
	self._synced_peers = self._synced_peers or {}
	self._atleast_one_world_loaded = false
	self._stitcher_counter = CoreWorldCollection.MAX_STITCHER_ID
	self._first_pass = true

	World:occlusion_manager():set_max_occluder_tests(25)
end

-- Lines 54-56
function CoreWorldCollection:first_pass()
	return self._first_pass
end

-- Lines 58-61
function CoreWorldCollection:unregister_editor_name(editor_name)
	self._editor_world_names[editor_name] = nil
end

-- Lines 63-67
function CoreWorldCollection:register_editor_name(editor_name, world)
	self._editor_world_names[editor_name] = self._editor_world_names[editor_name] or {}
	self._editor_world_names[editor_name].world = world
end

-- Lines 69-73
function CoreWorldCollection:register_editor_position(editor_name, position)
	self._editor_world_names[editor_name] = self._editor_world_names[editor_name] or {}
	self._editor_world_names[editor_name].position = position
end

-- Lines 75-82
function CoreWorldCollection:register_world_spawn(world_id, editor_name, spawn_loot)
	self._world_spawns[world_id] = {
		active = true,
		editor_name = editor_name,
		plant_loot = spawn_loot
	}

	if self._world_spawns[editor_name] then
		self._world_spawns[world_id].alarm = self._world_spawns[editor_name].alarm
		self._world_spawns[editor_name] = nil
	end
end

-- Lines 84-90
function CoreWorldCollection:register_world_despawn(world_id, editor_name)
	if not self._world_spawns[world_id] then
		return
	end

	self._world_spawns[world_id].active = false
	self._input_elements[editor_name] = nil
end

-- Lines 92-105
function CoreWorldCollection:get_input_elements_for_world(world_editor_name, event)
	local res, world_id = nil

	for key, world in pairs(self._world_spawns) do
		if world_editor_name == world.editor_name and world.active then
			world_id = key
		end
	end

	if world_id and self._input_elements[world_id] then
		res = self._input_elements[world_id][event]
	end

	return res
end

-- Lines 107-115
function CoreWorldCollection:get_output_elements_for_world(world_id, event)
	local res = nil
	local world_spawn = self._world_spawns[world_id]

	if world_spawn and self._output_elements[world_spawn.editor_name] then
		res = self._output_elements[world_spawn.editor_name][event]
	end

	return res
end

-- Lines 117-122
function CoreWorldCollection:register_input_element(world_id, event, input_element)
	self._input_elements[world_id] = self._input_elements[world_id] or {}
	self._input_elements[world_id][event] = self._input_elements[world_id][event] or {}

	table.insert(self._input_elements[world_id][event], input_element)
end

-- Lines 124-129
function CoreWorldCollection:unregister_input_element(world_id, event, input_element)
	Application:debug("[CoreWorldCollection:unregister_input_element(]", world_id, event, input_element)

	if self._input_elements[world_id] and self._input_elements[world_id][event] then
		table.delete(self._input_elements[world_id][event], input_element)
	end
end

-- Lines 132-137
function CoreWorldCollection:register_output_element(world_editor_name, event, output_element)
	self._output_elements[world_editor_name] = self._output_elements[world_editor_name] or {}
	self._output_elements[world_editor_name][event] = self._output_elements[world_editor_name][event] or {}

	table.insert(self._output_elements[world_editor_name][event], output_element)
end

-- Lines 139-144
function CoreWorldCollection:unregister_output_element(world_editor_name, event, output_element)
	Application:debug("[CoreWorldCollection:unregister_output_element(]", world_editor_name, event, output_element)

	if self._output_elements[world_editor_name] and self._output_elements[world_editor_name][event] then
		table.delete(self._output_elements[world_editor_name][event], output_element)
	end
end

-- Lines 146-151
function CoreWorldCollection:get_world_position(editor_name)
	if self._editor_world_names[editor_name] then
		return self._editor_world_names[editor_name].position
	end
end

-- Lines 153-161
function CoreWorldCollection:get_world_from_pos(position)
	local result = nil
	local nav_seg_id = managers.navigation:get_nav_seg_from_pos(position, true)
	local world_id = managers.navigation:get_world_for_nav_seg(nav_seg_id)

	if world_id then
		result = self._world_definitions[world_id]
	end

	return result
end

-- Lines 163-168
function CoreWorldCollection:on_editor_changed_name(old_name, new_name)
	if self._editor_world_names[old_name] then
		self._editor_world_names[new_name] = self._editor_world_names[old_name]
		self._editor_world_names[old_name] = nil
	end
end

-- Lines 170-176
function CoreWorldCollection:_load_predefined_worlds()
	if DB:has("xml", self._predefined_worlds_file) then
		local file = DB:open("xml", self._predefined_worlds_file)
		self._all_worlds = ScriptSerializer:from_generic_xml(file:read())

		table.sort(self._all_worlds)
	end
end

-- Lines 178-195
function CoreWorldCollection:get_next_world_id()
	self._world_id_counter = self._world_id_counter + 1
	local world_id_modulo = self._world_id_counter % WorldDefinition.MAX_WORLD_UNIT_ID

	if world_id_modulo == 0 then
		self._world_id_counter = self._world_id_counter + 1
		world_id_modulo = 1
	end

	while self._world_definitions[world_id_modulo] do
		self._world_id_counter = self._world_id_counter + 1
		world_id_modulo = self._world_id_counter % WorldDefinition.MAX_WORLD_UNIT_ID

		if world_id_modulo == 0 then
			self._world_id_counter = self._world_id_counter + 1
		end
	end

	self._world_id_counter = world_id_modulo

	return self._world_id_counter
end

-- Lines 197-203
function CoreWorldCollection:get_next_navstitcher_id()
	self._stitcher_counter = self._stitcher_counter - 1

	if self._stitcher_counter <= WorldDefinition.MAX_WORLD_UNIT_ID + 1 then
		self._stitcher_counter = CoreWorldCollection.MAX_STITCHER_ID
	end

	return self._stitcher_counter
end

-- Lines 205-253
function CoreWorldCollection:prepare_world(world, world_id, editor_name, spawn_counter, excluded_continents)
	local start = TimerManager:now()
	local file_type = "world"
	local file_path = world.meta_data.file .. "/world"
	local reverse = string.reverse(file_path)
	local i = string.find(reverse, "/")
	local world_dir = string.reverse(string.sub(reverse, i))

	if not DB:has(file_type, file_path) then
		error(file_path .. "." .. file_type .. " is not in the database!")
	end

	Application:debug("[CoreWorldCollection:prepare_world()] world_id:", world_id, spawn_counter)

	local params = {
		file_type = "world",
		file_path = file_path,
		world_dir = world_dir,
		translation = world.translation,
		world_id = world_id,
		excluded_continents = excluded_continents
	}
	local definition = CoreWorldDefinition.WorldDefinition:new(params)
	definition.is_created = false
	definition.editor_name = editor_name
	definition.creation_in_progress = true
	definition.spawn_counter = spawn_counter
	definition.meta_data = world.meta_data

	if self._drop_in_sync and self._drop_in_sync[world_id] and self._drop_in_sync[world_id].sync_units then
		for _, synced_unit in ipairs(self._drop_in_sync[world_id].sync_units) do
			definition:sync_unit_reference_data(synced_unit.unit_id, synced_unit.editor_id)
		end

		self._drop_in_sync[world_id].sync_units = nil
	end

	self._world_definitions[world_id] = definition
	self._mission_paths[world_id] = world.meta_data.file .. "/mission"

	table.insert(self.queued_world_creation, world_id)

	if definition.is_prepared then
		self:complete_world_loading_stage(definition._world_id, CoreWorldCollection.STAGE_PREPARE)
	end

	local t_end = TimerManager:now()

	Application:debug("[CoreWorldCollection:prepare_world( world )] DURATION", t_end - start)
end

-- Lines 256-293
function CoreWorldCollection:create(index, nav_graph_loaded)
	local definition = self._world_definitions[index]

	if not definition then
		return
	end

	if definition.is_created or not definition.is_prepared then
		Application:debug("[CoreWorldCollection:create() skip!]")

		return
	end

	self._motion_paths[index] = MotionPathManager:new(index)
	definition.create_called = true

	definition:create("all", Vector3(), true, nav_graph_loaded)

	self._missions[index] = MissionManager:new()
	self._mission_params[index] = {
		file_path = self._mission_paths[index],
		worlddefinition = definition,
		sync_id = index
	}

	if not Application:editor() and not Global.running_slave then
		World:occlusion_manager():merge_occluders(5)
	end

	return true
end

-- Lines 295-298
function CoreWorldCollection:set_world_counter(value)
	self.world_counter = value
	self.sync_world_counter = value
end

-- Lines 300-347
function CoreWorldCollection:on_world_loaded(index)
	Application:debug("[CoreWorldCollection:on_world_loaded]", index)

	if not self.world_counter or self.world_counter == 0 then
		self:execute_world_loaded_callbacks()
	end

	if self.world_counter and self.world_counter > 0 then
		self.world_counter = self.world_counter - 1
	end

	if index > 0 then
		if managers.viewport:first_active_viewport() then
			managers.viewport:first_active_viewport():set_force_feeder_update()
		end

		local definition = self._world_definitions[index]
		self._mission_params[definition._world_id] = nil

		definition:init_done()

		self._atleast_one_world_loaded = true
	end

	if Network:is_server() then
		for i, exec in ipairs(self.queued_server_mission_executions) do
			local mission = managers.worldcollection:mission_by_id(exec.mission_id)

			for name, data in pairs(mission._scripts) do
				local element = data:element(exec.id)

				if element then
					Application:debug("[CoreWorldCollection:on_world_loaded] Firing queued execution on server:", inspect(exec))
					element:on_executed(exec.unit)

					break
				end
			end

			self.queued_server_mission_executions[i] = nil
		end
	else
		self:check_queued_client_mission_executions()
	end

	managers.mouse_pointer:acquire_input()
end

-- Lines 349-367
function CoreWorldCollection:check_queued_client_mission_executions()
	for i, exec in ipairs(self.queued_client_mission_executions) do
		local mission = managers.worldcollection:mission_by_id(exec.mission_id)

		if mission and not exec.executed then
			local found = false

			for name, data in pairs(mission._scripts) do
				if data:element(exec.id) then
					Application:debug("[CoreWorldCollection:check_queued_client_mission_executions] Firing queued execution on client:", inspect(exec))

					self.queued_client_mission_executions[i].executed = true

					data:element(exec.id):set_synced_orientation_element_index(exec.orientation_element_index)

					if data:element(exec.id).client_on_executed then
						data:element(exec.id):client_on_executed(exec.unit)
					end

					break
				end
			end
		end
	end
end

-- Lines 369-375
function CoreWorldCollection:check_all_worlds_prepared()
	local result = true

	for key, definition in pairs(self._world_definitions) do
		result = result and definition.is_prepared
	end

	return result
end

-- Lines 377-384
function CoreWorldCollection:reset_global_ref_counter()
	self._temp_package_ref_added = false

	if Global.package_ref_counter then
		for key, _ in pairs(Global.package_ref_counter) do
			Global.package_ref_counter[key] = 0
		end
	end
end

-- Lines 386-395
function CoreWorldCollection:add_one_package_ref_to_all()
	for key, _ in pairs(Global.package_ref_counter) do
		if Global.package_ref_counter[key] > 0 then
			Global.package_ref_counter[key] = Global.package_ref_counter[key] + 1
		end
	end

	self._temp_package_ref_added = true
end

-- Lines 397-408
function CoreWorldCollection:delete_one_package_ref_from_all()
	if self._temp_package_ref_added then
		for key, _ in pairs(Global.package_ref_counter) do
			if Global.package_ref_counter[key] > 1 then
				Global.package_ref_counter[key] = Global.package_ref_counter[key] - 1
			end
		end
	end

	self._temp_package_ref_added = false
	managers.raid_job.reload_mission_flag = false
end

-- Lines 410-414
function CoreWorldCollection:unload_packages()
	for _, definition in pairs(self._world_definitions) do
		definition:unload_packages()
	end
end

-- Lines 416-424
function CoreWorldCollection:_send_to_peers_world_prepared(world_definition)
	if not world_definition.prepare_synced then
		world_definition.prepare_synced = true
		local peer = managers.network:session():local_peer()
		peer._synced_worlds[world_definition._world_id] = peer._synced_worlds[world_definition._world_id] or {}
		peer._synced_worlds[world_definition._world_id][CoreWorldCollection.STAGE_PREPARE] = true

		managers.network:session():send_to_peers("sync_prepare_world", world_definition._world_id, peer:id(), CoreWorldCollection.STAGE_PREPARE)
	end
end

-- Lines 426-432
function CoreWorldCollection:check_all_peers_synced_last_world(stage)
	if self._world_id_counter > 1 then
		return self:_check_all_peers_synced(self._world_id_counter, stage)
	else
		return true
	end
end

-- Lines 435-450
function CoreWorldCollection:_check_all_peers_synced(world_id, stage)
	if not managers.network:session() then
		return true
	end

	local result = true

	for id, peer in pairs(managers.network:session():peers()) do
		if not peer._synced_worlds[world_id] or not peer._synced_worlds[world_id][stage] then
			Application:debug("\twaiting - peer", id, "world_id", world_id, "stage", stage)

			result = false
		end
	end

	return result
end

-- Lines 453-460
function CoreWorldCollection:complete_world_loading_stage(world_id, stage)
	local params = {
		world_id = world_id,
		stage = stage
	}

	if stage == CoreWorldCollection.STAGE_DESTROY then
		managers.queued_tasks:queue(nil, self._do_complete_world_loading_stage, self, params, 3, nil)
	else
		self:_do_complete_world_loading_stage(params)
	end
end

-- Lines 462-476
function CoreWorldCollection:_do_complete_world_loading_stage(params)
	local world_id = params.world_id
	local stage = params.stage

	if not managers.network:session() then
		return
	end

	local peer = managers.network:session():local_peer()
	peer._synced_worlds[world_id] = peer._synced_worlds[world_id] or {}
	peer._synced_worlds[world_id][stage] = true

	Application:debug("[CoreWorldCollection:update] Sending world spawn sync: (world_id, peer)", world_id, peer:id())
	managers.network:session():send_to_peers("sync_prepare_world", world_id, peer:id(), stage)
end

-- Lines 478-484
function CoreWorldCollection:update_synced_worlds_to_peer(peer)
	local local_peer = managers.network:session():local_peer()

	for world_id, data in pairs(local_peer._synced_worlds) do
		peer:send_queued_sync("sync_peer_world_data", world_id, data[CoreWorldCollection.STAGE_PREPARE] or false, data[CoreWorldCollection.STAGE_LOAD] or false, data[CoreWorldCollection.STAGE_LOAD_FINISHED] or false)
	end
end

-- Lines 486-494
function CoreWorldCollection:update_synced_worlds_to_all_peers()
	Application:trace("[CoreWorldCollection:update_synced_worlds_to_all_peers()]")

	if not managers.network:session() then
		return
	end

	for peer_id, peer in pairs(managers.network:session():peers()) do
		self:update_synced_worlds_to_peer(peer)
	end
end

-- Lines 496-504
function CoreWorldCollection:sync_loading_status(t)
	if not managers.network:session() then
		return
	end

	if not self._next_loading_sync or self._next_loading_sync < t then
		self._next_loading_sync = t + 2

		self:update_synced_worlds_to_all_peers()
	end
end

-- Lines 506-586
function CoreWorldCollection:update(t, dt, paused_update)
	if managers.worldcollection.destroying then
		return
	end

	self:check_queued_world_create()
	self:sync_loading_status_to_peers()

	if not self._skip_one_loading_frame then
		for key, definition in pairs(self._world_definitions) do
			if not definition.destroyed then
				if definition.is_prepared and definition.create_called then
					if definition.creation_in_progress then
						local all_peers_prepared = self:_check_all_peers_synced(definition._world_id, CoreWorldCollection.STAGE_PREPARE)

						if all_peers_prepared then
							definition:update_load(t, dt)
						else
							Application:trace("[CoreWorldCollection:update] All peers still not prepared, waiting...")
							self:sync_loading_status(t)
						end

						if not definition.creation_in_progress then
							self:complete_world_loading_stage(definition._world_id, CoreWorldCollection.STAGE_LOAD)
						end
					elseif not definition.mission_scripts_created then
						local all_peers_spawned_world = self:_check_all_peers_synced(definition._world_id, CoreWorldCollection.STAGE_LOAD)
						local texture_loaded = TextureCache:check_textures_loaded()

						if all_peers_spawned_world and texture_loaded then
							Application:debug("[CoreWorldCollection:update] Creating mission params", definition._world_id)

							if self._mission_params[definition._world_id] then
								self._missions[definition._world_id]:parse(self._mission_params[definition._world_id])

								if self._drop_in_sync and self._drop_in_sync[definition._world_id] and self._drop_in_sync[definition._world_id].missions then
									self._missions[definition._world_id]:load(self._drop_in_sync[definition._world_id].missions)

									self._drop_in_sync[definition._world_id].missions = nil
								end
							end

							definition.mission_scripts_created = true

							break
						elseif not texture_loaded then
							Application:trace("[CoreWorldCollection:update] Waiting for textures...")
						else
							Application:trace("[CoreWorldCollection:update] All peers still not spawned worlds, waiting...")
							self:sync_loading_status(t)
						end
					elseif definition.mission_scripts_created and not definition.is_created then
						self:complete_world_loading_stage(definition._world_id, CoreWorldCollection.STAGE_LOAD_FINISHED)
						self:on_world_loaded(definition._world_id)

						self.concurrent_create = 0
					end
				elseif WorldDefinition.ASYNC_CALLBACKS then
					definition:update_prepare(t, dt)
				end
			end
		end
	else
		self._skip_one_loading_frame = false
	end

	if not paused_update and not self.level_transition_in_progress then
		for key, definition in pairs(self._world_definitions) do
			if definition.is_created and not definition.destroyed then
				self._missions[key]:update(t, dt)
				self._motion_paths[key]:update(t, dt)
			end

			local now = Application:time()

			if definition._next_cleanup_t < now then
				definition:cleanup_spawned_units()
			end
		end
	end

	self:check_drop_in_sync()
	self:check_queued_world_destroy()
	self:check_finished_destroy()
end

-- Lines 588-593
function CoreWorldCollection:sync_loading_status_to_peers()
	if self._sync_loading_status_to_peers and self._sync_loading_packages == 0 then
		self._sync_loading_status_to_peers = false

		managers.network:session():send_loading_finished_to_peers()
	end
end

-- Lines 595-611
function CoreWorldCollection:check_drop_in_sync()
	if managers.network:session() then
		local local_peer = managers.network:session():local_peer()

		if self:all_worlds_created() and local_peer:is_drop_in() and self._atleast_one_world_loaded then
			Application:debug("[CoreWorldCollection:check_drop_in_sync] all worlds created, sending set_member_ready!")
			Application:set_pause(false)
			managers.navigation:set_data_ready_flag(true)
			managers.network:session():chk_send_local_player_ready(true)
			local_peer:set_drop_in(false)
			managers.mission:start_root_level_script()
			self:remove_dropin_package_references()
		end

		managers.vehicle:process_state_change_queue()
	end
end

-- Lines 614-625
function CoreWorldCollection:check_queued_world_prepare()
	if self.concurrent_prepare > 0 then
		return
	end

	for i = #self.queued_world_prepare, 1, -1 do
		local data = self.queued_world_prepare[i]

		table.remove(self.queued_world_prepare, i)

		self.concurrent_prepare = self.concurrent_prepare + 1

		managers.worldcollection:prepare_world(data.world, data.world_id, data.editor_name, data.spawn_counter)

		break
	end
end

-- Lines 628-641
function CoreWorldCollection:check_queued_world_create()
	if self.concurrent_create > 0 then
		return
	end

	for i = #self.queued_world_creation, 1, -1 do
		local world_id = self.queued_world_creation[i]
		local ok = self:create(world_id, false)

		if ok then
			self.concurrent_create = world_id

			table.remove(self.queued_world_creation, i)
		end

		break
	end
end

-- Lines 643-652
function CoreWorldCollection:check_queued_world_destroy()
	if not self.level_transition_in_progress then
		return
	end

	for i = #self.queued_world_destruction, 1, -1 do
		local world_id = self.queued_world_destruction[i]

		self:destroy_world(world_id)
		table.remove(self.queued_world_destruction, i)
	end
end

-- Lines 654-667
function CoreWorldCollection:check_finished_destroy()
	for key, definition in pairs(self._world_definitions) do
		if not definition.queued_destroyed then
			local all_peers_destroyed = definition.destroyed and self:_check_all_peers_synced(key, CoreWorldCollection.STAGE_DESTROY)

			if all_peers_destroyed then
				definition.queued_destroyed = true

				managers.queued_tasks:queue(nil, self.finish_destroy, self, {
					world_id = key
				}, 0.8, nil)

				for _, peer in pairs(managers.network:session():all_peers()) do
					peer._synced_worlds[key] = nil
				end
			end
		end
	end
end

-- Lines 669-671
function CoreWorldCollection:worlddefinitions()
	return self._world_definitions
end

-- Lines 673-679
function CoreWorldCollection:worlddefinition_by_id(id)
	if id == 0 then
		return managers.worlddefinition
	else
		return self._world_definitions[id]
	end
end

-- Lines 681-683
function CoreWorldCollection:missions()
	return self._missions
end

-- Lines 685-687
function CoreWorldCollection:mission_by_id(id)
	return self._missions[id]
end

-- Lines 689-691
function CoreWorldCollection:motion_path_by_id(id)
	return self._motion_paths[id]
end

-- Lines 693-703
function CoreWorldCollection:mission_element_groups(type)
	local result = {}

	for _, mission in pairs(self._missions) do
		local t = {}

		table.insert(result, t)

		for name, script in pairs(mission:scripts()) do
			t[name] = script:element_group(type)
		end
	end

	return result
end

-- Lines 705-709
function CoreWorldCollection:pre_destroy()
	for _, mission in pairs(self._missions) do
		mission:pre_destroy()
	end
end

-- Lines 711-715
function CoreWorldCollection:destroy()
	for _, mission in pairs(self._missions) do
		mission:destroy()
	end
end

-- Lines 717-798
function CoreWorldCollection:destroy_world(id)
	Application:debug("[CoreWorldCollection:destroy_world]", id)

	local mission = self._missions[id]

	if mission then
		for key, script in pairs(mission._scripts) do
			for element_id, element in pairs(script._elements) do
				if element.unspawn_all_units then
					element:unspawn_all_units()
				end

				if element.unregister then
					element:unregister()
				end
			end
		end

		mission:pre_destroy()
		mission:destroy()

		self._missions[id] = nil
		self._mission_paths[id] = nil
	end

	managers.objectives:remove_objective_for_world(id)

	local motion_path = self._motion_paths[id]

	if motion_path then
		motion_path:delete_paths()

		self._motion_paths[id] = nil
	end

	managers.vehicle:freeze_vehicles_on_world(id)

	local definition = self._world_definitions[id]

	if definition then
		for _, unit in pairs(definition._all_units) do
			if alive(unit) then
				if not unit:vehicle_driving() then
					managers.interaction:remove_unit(unit)
					unit:set_slot(0)
				else
					local cont_vehicle = unit:unit_data().continent_name and unit:unit_data().continent_name == WorldDefinition.VEHICLES_CONTINENT_NAME

					if not cont_vehicle then
						managers.vehicle:remove_vehicle(unit)
					end
				end
			end
		end

		for _, unit in ipairs(definition._spawned_units) do
			if alive(unit) then
				unit:set_slot(0)
			end
		end

		definition:destroy()
	end

	managers.world_instance:remove_instances_for_world(id)
	managers.world_instance:remove_instance_params(id)
	managers.world_instance:unregister_input_elements(id)
	managers.world_instance:unregister_output_event_elements(id)
	managers.navigation:on_world_destroyed(id)
	self:complete_world_loading_stage(id, CoreWorldCollection.STAGE_DESTROY)
end

-- Lines 800-807
function CoreWorldCollection:finish_destroy(data)
	Application:debug("[CoreWorldCollection:finish_destroy]", data.world_id)

	local definition = self._world_definitions[data.world_id]

	if not Application:editor() then
		definition:unload_packages()
	end

	self._world_definitions[data.world_id] = nil
end

-- Lines 809-841
function CoreWorldCollection:_create_test(params)
	print("CoreWorldCollection:_create_test( params )", inspect(params))

	local worlds = {}

	if true or false then
		table.insert(worlds, {
			level_path = "levels/tests/stealth_test_garden",
			translation = {
				position = Vector3(0, 0, 5000),
				rotation = Rotation(0, 0, 0)
			}
		})
		table.insert(worlds, {
			level_path = "levels/tests/stealth_test_garden",
			translation = {
				position = Vector3(0, 5000, 2500),
				rotation = Rotation(0, 0, 0)
			}
		})
		table.insert(worlds, {
			level_path = "levels/tests/stealth_test_garden",
			translation = {
				position = Vector3(5000, 0, 2500),
				rotation = Rotation(0, 0, 0)
			}
		})
	end

	return worlds
end

-- Lines 843-868
function CoreWorldCollection:_new_random_world(worlds, ordered)
	local files = {
		"levels/tests/world_part1",
		"levels/tests/world_part2",
		"levels/tests/world_part3",
		"levels/tests/world_part4",
		"levels/tests/world_part5",
		"levels/tests/world_part6",
		"levels/tests/world_part7",
		"levels/tests/world_part8",
		"levels/tests/world_part2"
	}
	local s = 4
	local k = 0
	local l = 0
	local s_pos = -800 * s / 2

	for i = 0, s do
		for j = 0, s do
			local pos = Vector3(s_pos + i * 800, s_pos + j * 800, 0)
			local yaw = ordered and math.mod(l, 4) * 90 or math.round(math.rand(360) / 90) * 90
			local rot = Rotation(yaw, 0, 0)
			local file = nil

			if ordered then
				file = files[k + 1]
			else
				file = files[math.random(#files)]
			end

			table.insert(worlds, {
				level_path = file,
				translation = {
					position = pos,
					rotation = rot
				}
			})

			k = math.mod(k + 1, #files)
			l = l + 1
		end
	end
end

-- Lines 870-900
function CoreWorldCollection:on_simulation_ended()
	Application:trace("CoreWorldCollection:on_simulation_ended()")

	for key, definition in pairs(self._world_definitions) do
		self:destroy_world(key)
	end

	managers.vehicle:delete_all_vehicles()

	self._world_definitions = {}
	self._missions = {}
	self._mission_paths = {}
	self._world_spawns = {}
	self._input_elements = {}
	self._output_elements = {}
	self._synced_peers = {}
	self._atleast_one_world_loaded = false
	self._world_id_counter = 1

	managers.portal:kill_all_effects()
	managers.portal:clear()

	if managers.worlddefinition then
		MassUnitManager:delete_all_units()
		managers.worlddefinition:_create_massunit(managers.worlddefinition._definition.brush, Vector3(0, 0, 0))
	end
end

-- Lines 903-916
function CoreWorldCollection:clear()
	self:on_simulation_ended()
	MassUnitManager:delete_all_units()
	managers.sound_environment:destroy()
	managers.portal:kill_all_effects()
	managers.environment_area:remove_all_areas()
	managers.portal:clear()
	managers.world_instance:clear()
	managers.world_instance:on_simulation_ended()

	managers.navigation._has_loaded = nil

	managers.navigation:clear()
	self:pre_destroy()
end

-- Lines 919-931
function CoreWorldCollection:get_worlddefinition_by_unit_id(unit_id)
	if unit_id < WorldDefinition.UNIT_ID_BASE then
		return managers.worlddefinition
	else
		local world_id = math.floor(unit_id / WorldDefinition.UNIT_ID_BASE)
		local def = managers.worldcollection._world_definitions[world_id]

		if not def then
			Application:error("[CoreWorldCollection:get_worlddefinition_by_unit_id] World definition not found!", unit_id, world_id, debug.traceback())
		end

		return def
	end
end

-- Lines 934-952
function CoreWorldCollection:sync_save(data)
	Application:debug("[CoreWorldCollection:sync_save]", inspect(self._synced_peers))

	local state = {
		missions = {},
		synced_units = {}
	}

	for i, mission in pairs(self._missions) do
		state.missions[i] = {}

		mission:save(state.missions[i])
	end

	state.stitcher_counter = self._stitcher_counter
	state.unique_id_counter = self._unique_id_counter
	state.world_id_counter = self._world_id_counter
	state.sync_world_counter = self.sync_world_counter

	for world_id, world in pairs(self._world_definitions) do
		table.insert(state.synced_units, {
			world_id = world_id,
			units = world._units_synced_on_dropin
		})
	end

	data.CoreWorldCollection = state
end

-- Lines 955-994
function CoreWorldCollection:sync_load(data)
	local state = data.CoreWorldCollection
	self._drop_in_sync = {}

	for i, mission in pairs(state.missions) do
		if self._missions[i] then
			self._missions[i]:load(mission)
		else
			self._drop_in_sync[i] = {
				missions = state.missions[i]
			}
		end
	end

	self._stitcher_counter = state.stitcher_counter
	self._unique_id_counter = state.unique_id_counter
	self._world_id_counter = state.world_id_counter
	self.sync_world_counter = state.sync_world_counter
	self.world_counter = state.sync_world_counter

	for _, synced_units in ipairs(state.synced_units) do
		local world_id = synced_units.world_id
		local all_units = synced_units.units
		local world_definition = self:worlddefinition_by_id(world_id)

		if all_units then
			if world_definition then
				for _, synced_unit in ipairs(all_units) do
					world_definition:sync_unit_reference_data(synced_unit.unit_id, synced_unit.editor_id)
				end
			else
				Application:debug("[CoreWorldCollection:sync_load] World definition not available, will sync unit references later for world:", world_id)

				self._drop_in_sync[world_id] = self._drop_in_sync[world_id] or {}
				self._drop_in_sync[world_id].sync_units = all_units
			end
		end
	end

	self._atleast_one_world_loaded = true
	self._first_pass = false
end

-- Lines 998-1005
function CoreWorldCollection:get_world_meta_data(key)
	local result = self._all_worlds[key]

	if not result then
		Application:error("[CoreWorldCollection:get_world_meta_data] Meta data for world does not exist: ", key)
	end

	return result
end

-- Lines 1007-1014
function CoreWorldCollection:get_all_worlds()
	local res = {}

	for k, v in pairs(self._all_worlds) do
		table.insert(res, k)
	end

	table.sort(res)

	return res
end

-- Lines 1017-1039
function CoreWorldCollection:get_unit_with_id(id, cb, world_id)
	local unit = nil

	if world_id > 0 then
		local world_def = self._world_definitions[world_id]

		if cb then
			unit = world_def:get_unit_on_load(id, cb)
		else
			unit = world_def:get_unit_by_id(id)
		end
	elseif Global.running_simulation then
		unit = managers.editor:unit_with_id(id)
	elseif cb then
		unit = managers.worlddefinition:get_unit_on_load(id, cb)
	else
		unit = managers.worlddefinition:get_unit_by_id(id)
	end

	return unit
end

-- Lines 1041-1066
function CoreWorldCollection:debug_print_stats()
	local all_units = World:unit_manager():get_units()
	local i = 0

	for key, u in pairs(all_units) do
		i = i + 1
	end

	local j = 0
	local k = 0

	for _, definition in pairs(managers.worldcollection._world_definitions) do
		for _, _ in pairs(definition._all_units) do
			j = j + 1
		end

		k = k + #definition._spawned_units
	end

	local l = 0

	for _, _ in pairs(managers.navigation._pos_reservations) do
		l = l + 1
	end

	Application:debug("World:unit_manager(): ", i)
	Application:debug("WorldDefinition:all_units:", j)
	Application:debug("WorldDefinition:spawned_units:", k)
	Application:debug("NavigationManager:pos_reservations:", l)
end

-- Lines 1068-1080
function CoreWorldCollection:get_unit_with_real_id(id)
	local all_units = World:unit_manager():get_units()
	local unit = nil

	for key, u in pairs(all_units) do
		if u:id() == id then
			unit = u

			break
		end
	end

	return unit
end

-- Lines 1082-1084
function CoreWorldCollection:__get_unit_with_real_id(id)
	return World:unit_manager():get_unit_by_id(id)
end

-- Lines 1086-1092
function CoreWorldCollection:world_name_ids()
	local names = {}

	for key, value in pairs(self._editor_world_names) do
		table.insert(names, key)
	end

	return names
end

-- Lines 1094-1096
function CoreWorldCollection:world_names()
	return self._editor_world_names
end

-- Lines 1099-1115
function CoreWorldCollection:get_mission_elements_from_script(name, element_class)
	local path = self._all_worlds[name].file .. "/" .. "world/world"
	local instance_data = self:_serialize_to_script("mission", Idstring(path))
	local mission_elements = {}

	for script, script_data in pairs(instance_data) do
		for _, element in ipairs(script_data.elements) do
			if element.class == element_class then
				table.insert(mission_elements, element.values.event)
			end
		end
	end

	table.sort(mission_elements)

	return mission_elements
end

-- Lines 1117-1126
function CoreWorldCollection:_serialize_to_script(type, name)
	if Application:editor() then
		return PackageManager:editor_load_script_data(type:id(), name:id())
	else
		if not PackageManager:has(type:id(), name:id()) then
			Application:throw_exception("Script data file " .. name .. " of type " .. type .. " has not been loaded.")
		end

		return PackageManager:script_data(type:id(), name:id())
	end
end

-- Lines 1128-1133
function CoreWorldCollection:add_package_ref(package)
	Global.package_ref_counter = Global.package_ref_counter or {}
	Global.package_ref_counter[package] = Global.package_ref_counter[package] or 0
	Global.package_ref_counter[package] = Global.package_ref_counter[package] + 1
end

-- Lines 1135-1141
function CoreWorldCollection:delete_package_ref(package)
	Global.package_ref_counter[package] = Global.package_ref_counter[package] or 1

	if Global.package_ref_counter[package] > 0 then
		Global.package_ref_counter[package] = Global.package_ref_counter[package] - 1
	end
end

-- Lines 1143-1157
function CoreWorldCollection:has_queued_unloads()
	local cnt = 0

	if Global.package_ref_counter then
		for package, count in pairs(Global.package_ref_counter) do
			if count == 0 then
				cnt = cnt + 1
			end
		end
	end

	if cnt > 0 then
		return true
	else
		return false
	end
end

-- Lines 1161-1168
function CoreWorldCollection:register_spawned_unit(unit, pos)
	local nav_seg_id = managers.navigation:get_nav_seg_from_pos(pos, true)
	local def_id = managers.navigation:get_world_for_nav_seg(nav_seg_id)
	local definition = self:worlddefinition_by_id(def_id)

	if definition then
		definition:register_spawned_unit(unit)
	end
end

-- Lines 1170-1178
function CoreWorldCollection:register_spawned_unit_on_last_world(unit)
	local definition = nil

	if Application:editor() then
		definition = managers.worlddefinition
	else
		definition = self._world_definitions[self._world_id_counter]
	end

	definition:register_spawned_unit(unit)
end

-- Lines 1180-1191
function CoreWorldCollection:get_alarm_for_world(world_id)
	if world_id == 0 then
		return managers.worlddefinition.alarmed
	else
		local world_spawn = self._world_spawns[world_id]

		if world_spawn then
			return world_spawn.alarm
		else
			return false
		end
	end
end

-- Lines 1194-1205
function CoreWorldCollection:set_alarm_for_world(editor_name, alarm)
	local found = false

	for _, world in pairs(self._world_spawns) do
		if world.active and world.editor_name == editor_name then
			found = true
			world.alarm = alarm
		end
	end

	if not found then
		self._world_spawns[editor_name] = {
			alarm = alarm
		}
	end
end

-- Lines 1208-1216
function CoreWorldCollection:set_alarm_for_world_id(world_id, alarm)
	Application:trace("[CoreWorldCollection:set_alarm_for_world_id]", world_id, alarm)

	if world_id == 0 then
		managers.worlddefinition.alarmed = alarm
	else
		self._world_spawns[world_id] = self._world_spawns[world_id] or {}
		self._world_spawns[world_id].alarm = alarm
	end
end

-- Lines 1218-1235
function CoreWorldCollection:sync_world_prepared(world_id, peer, stage)
	if not managers.network:session() then
		return
	end

	Application:trace("[CoreWorldCollection:sync_world_prepared]", world_id, peer, stage)

	local p = managers.network:session():peer(peer)
	p._synced_worlds = p._synced_worlds or {}
	p._synced_worlds[world_id] = p._synced_worlds[world_id] or {}
	local old_stage_value = p._synced_worlds[world_id][stage]
	p._synced_worlds[world_id][stage] = true

	if Network:is_server() and stage == CoreWorldCollection.STAGE_LOAD and not old_stage_value then
		-- Nothing
	end
end

-- Lines 1238-1246
function CoreWorldCollection:send_loaded_packages(peer)
	Application:trace("[CoreWorldCollection:send_loaded_packages]")

	for package, count in pairs(Global.package_ref_counter) do
		if count > 0 then
			Application:trace("[CoreWorldCollection:send_loaded_packages] sending string:", package, count)
			peer:send("send_loaded_packages", package, count)
		end
	end
end

-- Lines 1248-1258
function CoreWorldCollection:remove_dropin_package_references()
	if not self._packages_packed then
		return
	end

	for _, pkg in ipairs(self._packages_packed) do
		if pkg.count > 0 then
			Global.package_ref_counter[pkg.package] = Global.package_ref_counter[pkg.package] - pkg.count
		end
	end

	self._packages_packed = nil
end

-- Lines 1261-1304
function CoreWorldCollection:sync_loaded_packages(packages_packed)
	Application:trace("[CoreWorldCollection:sync_loaded_packages]", inspect(packages_packed))

	if not packages_packed then
		return
	end

	PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)

	self._sync_loading_packages = 0

	self:reset_global_ref_counter()

	self._packages_packed = packages_packed

	for _, pkg in ipairs(packages_packed) do
		if pkg.count > 0 then
			Global.package_ref_counter = Global.package_ref_counter or {}
			Global.package_ref_counter[pkg.package] = pkg.count

			if not PackageManager:loaded(pkg.package) then
				Application:trace("[CoreWorldCollection:sync_loaded_packages] Loading package:", pkg.package)

				if Global.STREAM_ALL_PACKAGES then
					self._sync_loading_packages = self._sync_loading_packages + 1

					PackageManager:load(pkg.package, function ()
						Application:trace("[CoreWorldCollection:sync_loaded_packages] DONE", pkg.package)

						self._sync_loading_packages = self._sync_loading_packages - 1

						if self._sync_loading_packages == 0 then
							managers.sequence:preload()
							PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))
						end
					end)
				else
					PackageManager:load(pkg.package)
				end
			else
				Application:trace("[CoreWorldCollection:sync_load] Package already loaded:", pkg.package)
			end
		end
	end

	self._sync_loading_status_to_peers = true

	if not Global.STREAM_ALL_PACKAGES then
		managers.sequence:preload()
		PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))
	end
end

-- Lines 1306-1312
function CoreWorldCollection:all_worlds_created()
	local res = true

	for _, world in pairs(self._world_definitions) do
		res = res and world.is_created
	end

	return res
end

-- Lines 1317-1347
function CoreWorldCollection:level_transition_cleanup()
	Application:trace("[CoreWorldCollection:level_transition_cleanup()]")

	local player = managers.player:local_player()

	managers.player:clear_synced_turret()

	if alive(player) then
		player:base():_unregister()
		World:delete_unit(player)
	end

	World:set_extensions_update_enabled(false)
	managers.gold_economy:reset_camp_units()
	World:occlusion_manager():clear_occluders()
	MassUnitManager:delete_all_units()
	managers.objectives:on_level_transition()
	managers.trade:remove_all_criminals_to_respawn()
	managers.hud:clear_hit_direction_indicators()
	managers.hud:clear_suspicion_direction_indicators()
	managers.hud:clear_waypoints()
	managers.hud:pd_cancel_progress()
	managers.hud:hide_interaction_bar(false, false)
	managers.music:stop()
	managers.groupai:kill_all_AI()
	managers.queued_tasks:queue(nil, managers.groupai:state().clean_up, managers.groupai:state(), nil, 0.1, nil, true)
	managers.game_play_central:on_level_tranistion()
	managers.portal:clear()
	managers.drop_loot:clear()
end

-- Lines 1349-1427
function CoreWorldCollection:level_transition_started()
	Application:trace("[CoreWorldCollection:world_transition_started()]", self._first_pass, self.world_counter)

	self.level_transition_in_progress = true
	managers.network:session():local_peer().loading_worlds = true
	managers.player._players_spawned = false
	managers.player.dropin = false

	if not self._first_pass then
		managers.dialog:quit_dialog(true)
		managers.navigation:set_data_ready_flag(false)
		self:_reset_loot_planting_flags()

		if Network:is_server() then
			managers.network:session():set_state("loading")
		end
	else
		self.first_login_check = true
		self._first_pass = false
	end

	managers.queued_tasks:unqueue_all(nil, nil, true)
	managers.player:remove_all_specials()
	managers.player:clear_carry(true)
	managers.environment_effects:kill_all_mission_effects()
	managers.enemy:dispose_all_corpses()
	managers.enemy:unqueue_all_tasks()
	managers.enemy:remove_delayed_clbks()
	managers.enemy:on_level_tranistion()
	managers.sequence:on_level_transition()
	managers.hud:clean_up()
	managers.barrage:stop_barrages()
	managers.network:unregister_all_spawn_points()
	managers.menu:close_all_menus()
	managers.system_menu:force_close_all()
	Global.music_manager.source:post_event("stop_all")

	if Network:is_server() then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			if data and alive(data.unit) then
				Application:trace("[CoreWorldCollection:level_transition_started()] unregister", data.unit)
				data.unit:brain():set_active(false)
				data.unit:set_slot(0)
				data.unit:base():unregister()
				data.unit:_clear_damage_transition_callbacks()
			end
		end
	end

	managers.player:set_player_state("standard")

	if false then
		Application:trace("[CoreWorldCollection:level_transition_started()] event_complete_screen")
		game_state_machine:change_state_by_name("event_complete_screen")
	elseif game_state_machine:current_state_name() ~= "ingame_loading" then
		game_state_machine:change_state_by_name("ingame_loading")
	end

	managers.queued_tasks:queue(nil, managers.worldcollection.level_transition_cleanup, managers.worldcollection, nil, 1, nil)
end

-- Lines 1429-1465
function CoreWorldCollection:level_transition_ended()
	Application:trace("[CoreWorldCollection:world_transition_ended()]")
	managers.raid_menu:set_pause_menu_enabled(true)
	managers.navigation:set_data_ready_flag(true)

	managers.network:session():local_peer().loading_worlds = false

	if Network:is_server() then
		managers.network:session():set_state("in_game")
		self:_plant_loot_on_spawned_levels()
		managers.queued_tasks:queue(nil, self._do_spawn_players, self, nil, 0.1)
		managers.gold_economy:layout_camp()
		managers.progression:layout_camp()
	else
		self.level_transition_in_progress = false
	end

	World:set_extensions_update_enabled(true)
	managers.game_play_central:set_restarting(false)
	managers.queued_tasks:queue(nil, self._fire_level_loaded_event, self, nil, ElementPlayerSpawner.HIDE_LOADING_SCREEN_DELAY + 0.1, nil)
	self:delete_one_package_ref_from_all()

	if managers.network.matchmake and not managers.network.matchmake.lobby_handler then
		managers.network.matchmake:create_lobby(managers.network:get_matchmake_attributes(), true)
	end
end

-- Lines 1467-1470
function CoreWorldCollection:_do_spawn_players()
	managers.network:session():spawn_players()

	self.level_transition_in_progress = false
end

-- Lines 1472-1475
function CoreWorldCollection:_fire_level_loaded_event()
	Application:trace("[CoreWorldCollection:_fire_level_loaded_event()]")
	managers.global_state:fire_event("system_level_loaded")
end

-- Lines 1478-1483
function CoreWorldCollection:world_spawn(world_id)
	if not world_id then
		return
	end

	return self._world_spawns[world_id]
end

-- Lines 1485-1491
function CoreWorldCollection:count_world_spawns()
	local cnt = 0

	for world_id, data in pairs(self._world_spawns) do
		cnt = cnt + 1
	end

	return cnt
end

-- Lines 1493-1527
function CoreWorldCollection:_plant_loot_on_spawned_levels()
	local job_data = managers.raid_job:current_job()
	local job_id = job_data and job_data.job_id
	local total_value = LootDropTweakData.TOTAL_LOOT_VALUE_DEFAULT

	if job_data and job_data.dogtags_min and job_data.dogtags_max then
		total_value = math.random(job_data.dogtags_min, job_data.dogtags_max)
	end

	if not self._world_spawns or self:count_world_spawns() == 0 then
		managers.lootdrop:plant_loot_on_level(0, total_value, job_id)
		managers.consumable_missions:plant_document_on_level(0)
		managers.greed:plant_greed_items_on_level(world_id)
	else
		local count = 0

		for world_id, data in pairs(self._world_spawns) do
			if data.active and data.plant_loot then
				count = count + 1
			end
		end

		local loot_per_level = count == 0 and 0 or total_value / count

		for world_id, data in pairs(self._world_spawns) do
			if data.active and data.plant_loot then
				managers.lootdrop:plant_loot_on_level(world_id, loot_per_level, job_id)
				managers.consumable_missions:plant_document_on_level(world_id)
				managers.greed:plant_greed_items_on_level(world_id)
			elseif data.active then
				managers.lootdrop:remove_loot_from_level(world_id)
				managers.greed:remove_greed_items_from_level(world_id)
			end
		end
	end
end

-- Lines 1529-1533
function CoreWorldCollection:_reset_loot_planting_flags()
	for world_id, data in pairs(self._world_spawns) do
		data.plant_loot = false
	end
end

-- Lines 1535-1537
function CoreWorldCollection:test_package_loading(pkg)
	return self._package_loading[pkg]
end

-- Lines 1539-1543
function CoreWorldCollection:on_server_left()
	Application:trace("CoreWorldCollection:on_server_left()")
	self:destroy_all_worlds()

	self._skip_one_loading_frame = true
end

-- Lines 1545-1550
function CoreWorldCollection:destroy_all_worlds()
	for w_id, w in pairs(self._world_definitions) do
		table.insert(managers.worldcollection.queued_world_destruction, w_id)
	end

	managers.menu:hide_loading_screen()
end

-- Lines 1552-1555
function CoreWorldCollection:add_world_loaded_callback(obj)
	table.insert(self._world_loaded_callbacks, obj)
end

-- Lines 1557-1563
function CoreWorldCollection:execute_world_loaded_callbacks()
	Application:trace("[CoreWorldCollection:execute_world_loaded_callbacks()]")

	for _, obj in ipairs(self._world_loaded_callbacks) do
		obj:on_world_loaded()
	end

	self._world_loaded_callbacks = {}
end
