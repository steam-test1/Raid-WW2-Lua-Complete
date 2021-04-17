core:import("CoreMissionScriptElement")

ElementBlackscreen = ElementBlackscreen or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementBlackscreen:init(...)
	ElementBlackscreen.super.init(self, ...)
end

-- Lines 9-11
function ElementBlackscreen:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 13-34
function ElementBlackscreen:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.action == "fade_in" then
		local data = {}
		local loading_screen = tweak_data.operations:get_loading_screen(self._values.level)
		data.background = loading_screen.image
		data.loading_text = loading_screen.text
		data.skip_delete_brushes = self._values.skip_delete_brushes

		managers.menu:show_loading_screen(data)
	elseif self._values.action == "fade_out" then
		managers.menu:hide_loading_screen()
	elseif self._values.action == "fade_to_black" then
		managers.menu:fade_to_black()
	end

	ElementBlackscreen.super.on_executed(self, instigator)
end
