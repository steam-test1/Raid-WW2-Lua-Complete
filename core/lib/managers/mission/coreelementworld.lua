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
end

function ElementWorldOutputEvent:client_on_executed(...)
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
end

function ElementWorldInputEvent:client_on_executed(...)
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

	self._counted_continents = 0
end

function ElementWorldPoint:value(name)
	return self._values[name]
end

function ElementWorldPoint:client_on_executed(...)
end

function ElementWorldPoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

ElementWorldPoint.DELAY_DESTROY_SINGLE = 1.1
ElementWorldPoint.DELAY_CREATE_SINGLE = 2
ElementWorldPoint.DELAY_DESTROY_MULTI = 3
ElementWorldPoint.DELAY_CREATE_MULTI = 5

function ElementWorldPoint:on_executed(instigator)
	Application:debug("[ElementWorldPoint:on_executed] on_executed world name:", self._values.world, "enable:", self._values.enabled, "IDX:", self._world_id, "Action:", self._action)

	if not self._values.enabled then
		return
	end

	self._action = self._action or "spawn"

	if self._action == "despawn" then
		Application:debug("[ElementWorldPoint:on_executed] on_executed queue destroy world...")

		local delay_destroy = nil

		if managers.network:session():count_all_peers() > 1 then
			delay_destroy = ElementWorldPoint.DELAY_DESTROY_MULTI
		else
			delay_destroy = ElementWorldPoint.DELAY_DESTROY_SINGLE
		end

		managers.queued_tasks:queue(nil, self._destroy_world, self, nil, delay_destroy, nil, true)
	elseif self._action == "enable_plant_loot" then
		local spawn = managers.worldcollection:world_spawn(self._world_id)

		if not spawn then
			_G.debug_pause("[ElementWorldPoint:on_executed] Tried to enable spawn loot flag on world that is still not spawned!")
		else
			spawn.plant_loot = true
		end
	elseif self._action == "enable_alarm_state" then
		self:_set_alarm_state(true)
	elseif self._action == "disable_alarm_state" then
		self:_set_alarm_state(false)
	elseif self._action == "spawn" or self._action == "spawn_alarmed" then
		local delay_create = nil

		if managers.network:session():count_all_peers() > 1 then
			delay_create = ElementWorldPoint.DELAY_CREATE_MULTI
		else
			delay_create = ElementWorldPoint.DELAY_CREATE_SINGLE
		end

		local alarmed = self._action == "spawn_alarmed"

		Application:debug("[ElementWorldPoint:_set_alarm_state()] alarmed????", alarmed, self._action)

		local que_data = {
			world_id = nil,
			alarmed = alarmed
		}

		managers.queued_tasks:queue(nil, self._create_world, self, que_data, delay_create, nil, true)
	end

	self._action = nil

	ElementWorldPoint.super.on_executed(self, instigator)
end

function ElementWorldPoint:_set_alarm_state(state)
	Application:debug("[ElementWorldPoint:_set_alarm_state()] set state:", state, "for world", self._world_id)

	local spawn = managers.worldcollection:world_spawn(self._world_id)

	if not spawn then
		_G.debug_pause("[ElementWorldPoint:on_executed] Tried to set alarm flag on world that is still not spawned!")
	else
		managers.worldcollection:set_alarm_for_world_id(self._world_id, state)
	end
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

function ElementWorldPoint:_create_world(data)
	local world_id = data.world_id or nil
	local alarmed = data.alarmed or false

	Application:debug("[ElementWorldPoint:_create_world()] world_id:" .. tostring(data.world_id or "NEW") .. ", alarmed:" .. tostring(data.alarmed), self._has_created, inspect(self._values))

	if self._has_created or not self._values.world then
		Application:debug("[ElementWorldPoint:_create_world()] World is alreaedy created (or if nil doesnt exist), skipping!]", world_id)

		return
	end

	self._has_created = true
	self._counted_continents = self._counted_continents + 1
	local level_data = _G.tweak_data.levels[self._values.world]

	assert(level_data, "Supplied world id " .. self._values.world .. " is missing tweak data entry")
	Application:debug("[ElementWorldPoint:_create_world()]  Creating world:", level_data.file, self._values.position, self._values.rotation)

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

	local world = {
		level_data = level_data,
		translation = {
			position = pos,
			rotation = rot
		}
	}

	if not world_id then
		self._world_id = managers.worldcollection:get_next_world_id()

		Application:debug("[ElementWorldPoint:_create_world()] get_next_world_id returned" .. tostring(self._world_id))
	else
		self._world_id = world_id
	end

	Application:debug("[ElementWorldPoint:_create] world prepare...", self._world_id, self._editor_name)
	managers.worldcollection:prepare_world(world, self._world_id, self._editor_name, self._counted_continents, self._excluded_continents)
	managers.worldcollection:register_world_spawn(self._world_id, self._editor_name, self._spawn_loot)
	self:_set_alarm_state(alarmed)
	Application:debug("[ElementWorldPoint:_create] world created")
end

function ElementWorldPoint:save(data)
	data.has_created = self._has_created
	data.world_id = self._world_id
	data.excluded_continents = self._excluded_continents
	data.enabled = self._values.enabled
	data.world = self._values.world
	data.alarmed = managers.worldcollection:get_alarm_for_world(self._world_id)
end

function ElementWorldPoint:load(data)
	self._values.world = data.world
	self._excluded_continents = data.excluded_continents

	if data.has_created then
		local data = {
			world_id = data.world_id,
			alarmed = data.alarmed
		}

		self:_create_world(data)
	end

	self:set_enabled(data.enabled)
end

function ElementWorldPoint:stop_simulation(...)
end

function ElementWorldPoint:execute_action(action, operation_world_id)
	Application:debug("[ElementWorldPoint:execute_action]", action, operation_world_id)

	self._action = action

	if action == "set_world_id" and operation_world_id ~= "" then
		self._values.world = operation_world_id
	end

	self:on_executed(nil)
end

function ElementWorldPoint:destroy()
	self:_destroy_world()
end
