core:import("CoreMissionScriptElement")

ElementDisableUnit = ElementDisableUnit or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-9
function ElementDisableUnit:init(...)
	ElementDisableUnit.super.init(self, ...)

	self._units = {}
end

-- Lines 11-23
function ElementDisableUnit:on_script_activated()
	local elementBroken = false

	for _, id in ipairs(self._values.unit_ids) do
		local unit = managers.worldcollection:get_unit_with_id(id, callback(self, self, "_load_unit"), self._mission_script:sync_id())

		if unit then
			table.insert(self._units, unit)
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 25-27
function ElementDisableUnit:_load_unit(unit)
	table.insert(self._units, unit)
end

-- Lines 29-31
function ElementDisableUnit:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 33-51
function ElementDisableUnit:on_executed(instigator)
	self._has_executed = true

	if not self._values.enabled then
		return
	end

	for _, unit in ipairs(self._units) do
		if self._values.destroy_units then
			if alive(unit) then
				unit:set_slot(0)
			end
		else
			managers.game_play_central:mission_disable_unit(unit)
		end
	end

	ElementDisableUnit.super.on_executed(self, instigator)
end

-- Lines 53-57
function ElementDisableUnit:save(data)
	data.save_me = true
	data.enabled = self._values.enabled
	data.executed = self._has_executed
end

-- Lines 59-79
function ElementDisableUnit:load(data)
	if not self._has_fetched_units then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)

	if data.executed then
		self._has_executed = true

		for _, unit in ipairs(self._units) do
			if self._values.destroy_units and alive(unit) then
				unit:set_slot(0)
			end
		end
	end
end
