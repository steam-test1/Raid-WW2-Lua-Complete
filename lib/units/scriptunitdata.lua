ScriptUnitData = ScriptUnitData or class(CoreScriptUnitData)
local ids_lod = Idstring("lod")
local ids_object3d = Idstring("object3d")
local ids_wpn = Idstring("wpn")

-- Lines 7-32
function ScriptUnitData:init(unit)
	CoreScriptUnitData.init(self)

	if managers.occlusion and self.skip_occlusion then
		managers.occlusion:remove_occlusion(unit)
	end

	if unit:type() == ids_wpn then
		self.skip_distance_culling = true
	end

	if self.skip_distance_culling then
		for _, o in ipairs(unit:get_objects_by_type(ids_lod)) do
			if o.set_skip_detail_distance_culling then
				o:set_skip_detail_distance_culling(true)
			end
		end

		for _, o in ipairs(unit:get_objects_by_type(ids_object3d)) do
			if o.set_skip_detail_distance_culling then
				o:set_skip_detail_distance_culling(true)
			end
		end
	end
end

-- Lines 34-49
function ScriptUnitData:destroy(unit)
	local effect_spawners = unit:get_objects_by_type(Idstring("effect_spawner"))

	if effect_spawners then
		for _, spawner in pairs(effect_spawners) do
			spawner:kill_effect()
		end
	end

	if managers.occlusion and self.skip_occlusion then
		managers.occlusion:add_occlusion(unit)
	end

	if self._destroy_listener_holder then
		self._destroy_listener_holder:call(unit)
	end
end

-- Lines 51-54
function ScriptUnitData:add_destroy_listener(key, clbk)
	self._destroy_listener_holder = self._destroy_listener_holder or ListenerHolder:new()

	self._destroy_listener_holder:add(key, clbk)
end

-- Lines 56-62
function ScriptUnitData:remove_destroy_listener(key)
	self._destroy_listener_holder:remove(key)

	if self._destroy_listener_holder:is_empty() then
		self._destroy_listener_holder = nil
	end
end
