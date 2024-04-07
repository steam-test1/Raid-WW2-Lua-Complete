core:module("CoreElementWorld")
core:import("CoreMissionScriptElement")

ElementWorldOutputEvent = ElementWorldOutputEvent or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldOutputEvent:init(...)
	ElementWorldOutputEvent.super.init(self, ...)

	if self._values.event_list then
		for _, event_list_data in ipairs(self._values.event_list) do
			managers.worldcollection:register_output_element(event_list_data.world_name, event_list_data.event, self)
		end
	end
end

function ElementWorldOutputEvent:on_created()
	return
end

function ElementWorldOutputEvent:client_on_executed(...)
	return
end

function ElementWorldOutputEvent:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementWorldOutputEvent.super.on_executed(self, instigator)
end

function ElementWorldOutputEvent:destroy()
	for _, event_list_data in ipairs(self._values.event_list) do
		managers.worldcollection:unregister_output_element(event_list_data.world_name, event_list_data.event, self)
	end
end

ElementWorldOutput = ElementWorldOutput or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldOutput:init(...)
	ElementWorldOutput.super.init(self, ...)
end

function ElementWorldOutput:client_on_executed(...)
	return
end

function ElementWorldOutput:on_created()
	Application:debug("[ElementWorldOutput:on_created()]", self._sync_id, self._values.event)

	self._output_elements = managers.worldcollection:get_output_elements_for_world(self._sync_id, self._values.event)
end

function ElementWorldOutput:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._output_elements then
		for _, element in ipairs(self._output_elements) do
			element:on_executed(instigator)
		end
	end

	ElementWorldOutput.super.on_executed(self, instigator)
end

ElementWorldInput = ElementWorldInput or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldInput:init(...)
	ElementWorldInput.super.init(self, ...)
	managers.worldcollection:register_input_element(self._sync_id, self._values.event, self)
end

function ElementWorldInput:client_on_executed(...)
	return
end

function ElementWorldInput:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementWorldInput.super.on_executed(self, instigator)
end

function ElementWorldInput:destroy()
	managers.worldcollection:unregister_input_element(self._sync_id, self._values.event, self)
end

ElementWorldInputEvent = ElementWorldInputEvent or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldInputEvent:init(...)
	ElementWorldInputEvent.super.init(self, ...)
end

function ElementWorldInputEvent:on_created()
	print("ElementWorldInputEvent:on_created()")
end

function ElementWorldInputEvent:client_on_executed(...)
	return
end

function ElementWorldInputEvent:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.event_list then
		for _, event_list_data in ipairs(self._values.event_list) do
			local input_elements = managers.worldcollection:get_input_elements_for_world(event_list_data.world_name, event_list_data.event)

			if input_elements then
				for _, element in ipairs(input_elements) do
					element:on_executed(instigator)
				end
			end
		end
	end

	ElementWorldInputEvent.super.on_executed(self, instigator)
end

ElementWorldPoint = ElementWorldPoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWorldPoint:init(...)
	ElementWorldPoint.super.init(self, ...)

	self._spawn_counter = 0
end

function ElementWorldPoint:value(name)
	return self._values[name]
end

function ElementWorldPoint:client_on_executed(...)
	return
end

function ElementWorldPoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

ElementWorldPoint.DELAY_DESTROY_SINGLE = 1.1
ElementWorldPoint.DELAY_CREATE_SINGLE = 2
ElementWorldPoint.DELAY_DESTROY_MULTI = 3
ElementWorldPoint.DELAY_CREATE_MULTI = 5

function ElementWorldPoint:on_executed(instigator)
	Application:debug("[ElementWorldPoint:on_executed] on_executed", self._values.world, self._values.enabled, self._world_id, self._action)

	if not self._values.enabled then
		return
	end

	local delay_destroy, delay_create

	if managers.network:session():count_all_peers() > 1 then
		delay_destroy = ElementWorldPoint.DELAY_DESTROY_MULTI
		delay_create = ElementWorldPoint.DELAY_CREATE_MULTI
	else
		delay_destroy = ElementWorldPoint.DELAY_DESTROY_SINGLE
		delay_create = ElementWorldPoint.DELAY_CREATE_SINGLE
	end

	if self._action == "despawn" then
		Application:debug("[ElementWorldPoint:on_executed] on_executed queue destroy world...")
		managers.queued_tasks:queue(nil, self._destroy_world, self, nil, delay_destroy, nil, true)
	elseif self._action == "enable_plant_loot" then
		local spawn = managers.worldcollection:world_spawn(self._world_id)

		if not spawn then
			_G.debug_pause("[ElementWorldPoint:on_executed] Tried to enable spawn loot flag on world that is still not spawned!")
		else
			spawn.plant_loot = true
		end
	else
		managers.queued_tasks:queue(nil, self._create_world, self, nil, delay_create, nil, true)
	end

	ElementWorldPoint.super.on_executed(self, instigator)
end

function ElementWorldPoint:_destroy_world()
	Application:debug("[ElementWorldPoint:_destroy_world()]", self._world_id, self._has_created)

	if not self._has_created then
		return
	end

	self._has_created = false

	table.insert(managers.worldcollection.queued_world_destruction, self._world_id)
	managers.worldcollection:register_world_despawn(self._world_id, self._editor_name)

	self._world_id = nil
end

function ElementWorldPoint:_create_world(world_id)
	Application:debug("[ElementWorldPoint:_create()", world_id, self._has_created, inspect(self._values))

	if self._has_created or not self._values.world then
		Application:debug("[ElementWorldPoint:_create() World is alreaedy created (or if nil doesnt exist), skipping!]", world_id)

		return
	end

	self._has_created = true
	self._spawn_counter = self._spawn_counter + 1

	local world_meta_data = managers.worldcollection:get_world_meta_data(self._values.world)

	Application:debug("[ElementWorldPoint:_create() Creating world:]", world_meta_data.file, self._values.position, self._values.rotation)

	local world_def = managers.worldcollection:get_worlddefinition_by_unit_id(self._id)
	local pos = Vector3()
	local rot = Rotation()

	if world_def:translation() == nil then
		pos = self._values.position
		rot = self._values.rotation
	else
		mvector3.set(pos, world_def:translation().position)
		mvector3.add(pos, self._values.position)
		mrotation.set_zero(rot)
		mrotation.multiply(rot, world_def:translation().rotation)
		mrotation.multiply(rot, self._values.rotation)
	end

	local world = {}

	world.meta_data = world_meta_data
	world.translation = {}
	world.translation.position = pos
	world.translation.rotation = rot

	if not world_id then
		self._world_id = managers.worldcollection:get_next_world_id()
	else
		self._world_id = world_id
	end

	managers.worldcollection:prepare_world(world, self._world_id, self._editor_name, self._spawn_counter, self._excluded_continents)
	managers.worldcollection:register_world_spawn(self._world_id, self._editor_name, self._spawn_loot)
	Application:debug("[ElementWorldPoint:_create] world created")
end

function ElementWorldPoint:save(data)
	data.has_created = self._has_created
	data.world_id = self._world_id
	data.excluded_continents = self._excluded_continents
	data.enabled = self._values.enabled
	data.world = self._values.world
end

function ElementWorldPoint:load(data)
	self._values.world = data.world
	self._excluded_continents = data.excluded_continents

	if data.has_created then
		self:_create_world(data.world_id)
	end

	self:set_enabled(data.enabled)
end

function ElementWorldPoint:stop_simulation(...)
	return
end

function ElementWorldPoint:execute_action(action)
	Application:debug("[ElementWorldPoint:execute_action]", action)

	self._action = action

	self:on_executed(nil)
end

function ElementWorldPoint:destroy()
	self:_destroy_world()
end
