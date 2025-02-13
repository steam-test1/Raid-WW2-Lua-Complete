core:import("CoreMissionScriptElement")

ElementPlayerCharacterFilter = ElementPlayerCharacterFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPlayerCharacterFilter:client_on_executed(...)
	self:on_executed(...)
end

function ElementPlayerCharacterFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self:_check_character(instigator) then
		return
	end

	ElementPlayerStateTrigger.super.on_executed(self, self._unit or instigator)
end

function ElementPlayerCharacterFilter:_check_character(instigator)
	local character = self:value("character")

	if self:value("use_instigator") then
		return managers.criminals:character_name_by_unit(instigator) == character
	end

	return managers.criminals:is_taken(character)
end
