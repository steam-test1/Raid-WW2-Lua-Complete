HintUnitElement = HintUnitElement or class(MissionElement)
local WAHOOOOO = {
	"reminder_about_maps"
}

function HintUnitElement:init(unit)
	HintUnitElement.super.init(self, unit)

	self._hed.hint_id = "none"

	table.insert(self._save_values, "hint_id")
end

function HintUnitElement:_set_text(hint_id)
	local text = "none"

	if not hint_id or hint_id ~= "none" then
		text = managers.localization:text("hint_" .. hint_id)

		if managers.localization:exists("hint_" .. hint_id .. "_desc") then
			local desc_text = managers.localization:text("hint_" .. hint_id .. "_desc")
			text = text .. "\n" .. desc_text
		end
	end

	self._text:set_value(text)
end

function HintUnitElement:set_element_data(params, ...)
	HintUnitElement.super.set_element_data(self, params, ...)

	if params.value == "hint_id" then
		self:_set_text(self._hed.hint_id)
	end
end

function HintUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "hint_id", table.list_add({
		"none"
	}, WAHOOOOO))

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, "", "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	self:_set_text(self._hed.hint_id)
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
end
