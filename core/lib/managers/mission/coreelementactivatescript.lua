core:module("CoreElementActivateScript")
core:import("CoreMissionScriptElement")

ElementActivateScript = ElementActivateScript or class(CoreMissionScriptElement.MissionScriptElement)

function ElementActivateScript:init(...)
	ElementActivateScript.super.init(self, ...)
end

function ElementActivateScript:client_on_executed(...)
	self:on_executed(...)
end

function ElementActivateScript:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementActivateScript.super.on_executed(self, instigator)

	if self._values.activate_script ~= "none" then
		local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission

		mission:activate_script(self._values.activate_script, instigator)
	elseif Application:editor() then
		managers.editor:output_error("Cant activate script named \"none\" [" .. self._editor_name .. "]")
	end
end
