UnitBase = UnitBase or class()

function UnitBase:init(unit, update_enabled)
	self._unit = unit

	if not update_enabled then
		local base_ext = self._unit:base()

		if base_ext ~= self then
			Application:error("UnitBase:init disabled updates of foreign class. \nExtension name: ", inspect(base_ext.name_id), " \nUnit: ", inspect(self._unit))
		end

		unit:set_extension_update_enabled(Idstring("base"), false)
	end

	self._destroy_listener_holder = ListenerHolder:new()
end

function UnitBase:add_destroy_listener(key, clbk)
	if not self._destroying then
		self._destroy_listener_holder:add(key, clbk)
	end
end

function UnitBase:remove_destroy_listener(key)
	self._destroy_listener_holder:remove(key)
end

function UnitBase:save(data)
	return
end

function UnitBase:load(data)
	managers.worldcollection:add_world_loaded_callback(self)
end

function UnitBase:pre_destroy(unit)
	self._destroying = true

	self._destroy_listener_holder:call(unit)

	local unit_data = self._unit:unit_data()

	if unit_data and unit_data.dismembered_parts then
		for _, u in ipairs(unit_data.dismembered_parts) do
			if alive(u) then
				u:set_slot(0)
			end
		end
	end

	if unit_data and unit_data.spawned_units then
		for _, u in ipairs(unit_data.spawned_units) do
			if alive(u) then
				u:set_slot(0)
			end
		end
	end
end

function UnitBase:destroy(unit)
	if self._destroying then
		return
	end

	self._destroy_listener_holder:call(unit)
end

function UnitBase:set_slot(unit, slot)
	unit:set_slot(slot)
end

function UnitBase:on_world_loaded()
	if not alive(self._unit) then
		return
	end

	local worlddefinition = managers.worldcollection and managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:editor_id()) or managers.worlddefinition

	worlddefinition:use_me(self._unit)
end
