core:import("CoreMissionScriptElement")

ElementEnableUnit = ElementEnableUnit or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-9
function ElementEnableUnit:init(...)
	ElementEnableUnit.super.init(self, ...)

	self._units = {}
end

-- Lines 11-22
function ElementEnableUnit:on_script_activated()
	for _, id in ipairs(self._values.unit_ids) do
		local unit = managers.worldcollection:get_unit_with_id(id, callback(self, self, "_load_unit"), self._mission_script:sync_id())

		if unit then
			table.insert(self._units, unit)
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 24-26
function ElementEnableUnit:_load_unit(unit)
	table.insert(self._units, unit)
end

-- Lines 28-30
function ElementEnableUnit:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 32-43
function ElementEnableUnit:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, unit in ipairs(self._units) do
		managers.game_play_central:mission_enable_unit(unit)
	end

	ElementEnableUnit.super.on_executed(self, instigator)
end

-- Lines 45-48
function ElementEnableUnit:save(data)
	data.save_me = true
	data.enabled = self._values.enabled
end

-- Lines 50-56
function ElementEnableUnit:load(data)
	if not self._has_fetched_units then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)
end
