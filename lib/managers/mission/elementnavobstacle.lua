core:import("CoreMissionScriptElement")

ElementNavObstacle = ElementNavObstacle or class(CoreMissionScriptElement.MissionScriptElement)

function ElementNavObstacle:init(...)
	ElementDisableUnit.super.init(self, ...)

	self._obstacle_units = {}
end

function ElementNavObstacle:on_script_activated()
	if not self._values.obstacle_list then
		self._values.obstacle_list = {
			{
				unit_id = nil,
				obj_name = nil,
				unit_id = self._values.obstacle_unit_id,
				obj_name = self._values.obstacle_obj_name
			}
		}

		Application:debug("[ElementNavObstacle:on_script_activated] Converted unit id, object name.", self._values.obstacle_unit_id)
	end

	for _, data in ipairs(self._values.obstacle_list) do
		if Application:editor() then
			table.insert(self._obstacle_units, {
				obj_name = nil,
				unit = nil,
				unit = managers.editor:unit_with_id(data.unit_id),
				obj_name = data.obj_name
			})
		else
			local unit = self._mission_script:worlddefinition():get_unit_on_load(data.unit_id, callback(self, self, "_load_unit", data.obj_name))

			if unit then
				table.insert(self._obstacle_units, {
					obj_name = nil,
					unit = nil,
					unit = unit,
					obj_name = data.obj_name
				})
			end
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

function ElementNavObstacle:_load_unit(obj_name, unit)
	table.insert(self._obstacle_units, {
		obj_name = nil,
		unit = nil,
		unit = unit,
		obj_name = obj_name
	})
end

function ElementNavObstacle:client_on_executed(...)
	self:on_executed(...)
end

function ElementNavObstacle:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, data in ipairs(self._obstacle_units) do
		if not alive(data.unit) then
			Application:warn("[ElementNavObstacle:on_executed] dead obstacle unit. element_id:", self._id)
		elseif not data.unit:get_object(data.obj_name) then
			debug_pause_unit(data.unit, "[ElementNavObstacle:on_executed] object missing from unit. element_id:", self._id, "unit", data.unit, "Objec3D", data.obj_name)
		elseif self._values.operation == "add" then
			managers.navigation:add_obstacle(data.unit, data.obj_name, self._sync_id)
		else
			managers.navigation:remove_obstacle(data.unit, data.obj_name)
		end
	end

	ElementNavObstacle.super.on_executed(self, instigator)
end

function ElementNavObstacle:save(data)
	data.save_me = true
	data.enabled = self._values.enabled
end

function ElementNavObstacle:load(data)
	if not self._has_fetched_units then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)
end
