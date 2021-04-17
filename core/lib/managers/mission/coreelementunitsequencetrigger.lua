core:module("CoreElementUnitSequenceTrigger")
core:import("CoreMissionScriptElement")
core:import("CoreCode")

ElementUnitSequenceTrigger = ElementUnitSequenceTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 7-12
function ElementUnitSequenceTrigger:init(...)
	ElementUnitSequenceTrigger.super.init(self, ...)

	if not self._values.sequence_list and self._values.sequence then
		self._values.sequence_list = {
			{
				unit_id = self._values.unit_id,
				sequence = self._values.sequence
			}
		}
	end
end

-- Lines 14-41
function ElementUnitSequenceTrigger:on_script_activated()
	if not Network:is_client() then
		self._mission_script:add_save_state_cb(self._id)

		for _, data in pairs(self._values.sequence_list) do
			local unit_id = self._mission_script:worlddefinition():id_convert_old_to_new(data.unit_id)

			if unit_id then
				managers.mission:add_runned_unit_sequence_trigger(unit_id, data.sequence, callback(self, self, "on_executed"))
			else
				_G.debug_pause("[ElementUnitSequenceTrigger:on_executed] Trying to run sequnce on a non existing unit. Editor name of the mission element:", data.unit_id, self._editor_name, self._values.instance_name)
			end
		end
	end

	self._has_active_callback = true
end

-- Lines 43-50
function ElementUnitSequenceTrigger:send_to_host(instigator)
	if alive(instigator) then
		managers.network:session():send_to_host("to_server_mission_element_trigger", self._id, instigator)
	end
end

-- Lines 52-54
function ElementUnitSequenceTrigger:client_on_executed(...)
end

-- Lines 56-67
function ElementUnitSequenceTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementUnitSequenceTrigger.super.on_executed(self, instigator)
end

-- Lines 69-72
function ElementUnitSequenceTrigger:save(data)
	data.enabled = self._values.enabled
	data.save_me = true
end

-- Lines 74-82
function ElementUnitSequenceTrigger:load(data)
	self._values.enabled = data.enabled

	if not self._has_active_callback then
		self:on_script_activated()
	end
end
