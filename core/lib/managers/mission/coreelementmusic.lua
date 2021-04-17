core:module("CoreElementMusic")
core:import("CoreMissionScriptElement")

ElementMusic = ElementMusic or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-8
function ElementMusic:init(...)
	ElementMusic.super.init(self, ...)
end

-- Lines 10-12
function ElementMusic:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 14-33
function ElementMusic:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	Application:debug("[ElementMusic:on_executed()]", self._values.music_event)

	if self._values.music_event then
		local event_name = self._values.music_event

		if self._values.music_event == "_RANDOM" then
			event_name = managers.music:get_random_event()
		elseif self._values.music_event == "_LEVEL_DEFAULT" then
			event_name = managers.music:get_default_event()
		end

		managers.music:post_event(event_name)
	elseif Application:editor() then
		managers.editor:output_error("Cant play music event nil [" .. self._editor_name .. "]")
	end

	ElementMusic.super.on_executed(self, instigator)
end
