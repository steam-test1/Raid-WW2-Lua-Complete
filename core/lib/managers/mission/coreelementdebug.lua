core:module("CoreElementDebug")
core:import("CoreMissionScriptElement")

ElementDebug = ElementDebug or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-8
function ElementDebug:init(...)
	ElementDebug.super.init(self, ...)
end

-- Lines 10-12
function ElementDebug:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 14-32
function ElementDebug:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local prefix = "<debug>    "
	local text = prefix .. self._values.debug_string

	if not self._values.as_subtitle and self._values.show_instigator then
		text = text .. " - " .. tostring(instigator)
	end

	local color = self._values.color or self._values.as_subtitle and Color.yellow

	managers.mission:add_fading_debug_output(text, color, self._values.as_subtitle)
	ElementDebug.super.on_executed(self, instigator)
end

-- Lines 34-49
function ElementDebug:on_monitored_element(monitored_element_name, output_string)
	if not self._values.enabled then
		return
	end

	local prefix = "<monitor>    "
	local text = prefix .. self._values.debug_string .. " " .. output_string

	if not self._values.as_subtitle and self._values.show_instigator then
		text = text .. " - " .. tostring(monitored_element_name)
	end

	local color = self._values.color or self._values.as_subtitle and Color.yellow

	managers.mission:add_fading_debug_output(text, color, self._values.as_subtitle)
end
