core:import("CoreMissionScriptElement")

ElementHint = ElementHint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementHint:init(...)
	ElementHint.super.init(self, ...)
end

function ElementHint:client_on_executed(...)
	self:on_executed(...)
end

function ElementHint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.hint_id ~= "none" then
		local hint_text = managers.localization:to_upper_text("hint_" .. self._values.hint_id)
		local desc_text = managers.localization:exists("hint_" .. self._values.hint_id .. "_desc") and managers.localization:to_upper_text("hint_" .. self._values.hint_id .. "_desc")

		managers.hud:set_big_prompt({
			id = "shoot_flamer_tank",
			duration = 5,
			title = hint_text,
			description = desc_text
		})
	end

	ElementHint.super.on_executed(self, instigator)
end
