core:module("CoreElementGlobalEventTrigger")
core:import("CoreMissionScriptElement")
core:import("CoreCode")

ElementGlobalEventTrigger = ElementGlobalEventTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 7-8
function ElementGlobalEventTrigger:client_on_executed(...)
end

-- Lines 11-13
function ElementGlobalEventTrigger:init(...)
	ElementGlobalEventTrigger.super.init(self, ...)
end

-- Lines 15-17
function ElementGlobalEventTrigger:on_script_activated()
	managers.mission:add_global_event_listener(self:_unique_string_id(), {
		self._values.global_event
	}, callback(self, self, Network:is_client() and "send_to_host" or "on_executed"))
end

-- Lines 19-23
function ElementGlobalEventTrigger:send_to_host(instigator)
	if instigator then
		managers.network:session():send_to_host("to_server_mission_element_trigger", self._sync_id, self._id, instigator)
	end
end

-- Lines 25-31
function ElementGlobalEventTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementGlobalEventTrigger.super.on_executed(self, instigator)
end

-- Lines 33-35
function ElementGlobalEventTrigger:pre_destroy()
	managers.mission:remove_global_event_listener(self:_unique_string_id())
end
