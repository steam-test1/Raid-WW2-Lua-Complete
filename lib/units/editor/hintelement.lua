HintUnitElement = HintUnitElement or class(MissionElement)

-- Lines 3-9
function HintUnitElement:init(unit)
	HintUnitElement.super.init(self, unit)

	self._hed.hint_id = "none"

	table.insert(self._save_values, "hint_id")
end

-- Lines 11-12
function HintUnitElement:_set_text()
end

-- Lines 14-19
function HintUnitElement:set_element_data(params, ...)
	HintUnitElement.super.set_element_data(self, params, ...)

	if params.value == "hint_id" then
		self:_set_text()
	end
end

-- Lines 21-37
function HintUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, "", "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	self:_set_text()
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
end
