RaidGUIControlLabelNamedValueWithDelta = RaidGUIControlLabelNamedValueWithDelta or class(RaidGUIControlLabelNamedValue)

-- Lines 3-21
function RaidGUIControlLabelNamedValueWithDelta:init(parent, params)
	RaidGUIControlLabelNamedValueWithDelta.super.init(self, parent, params)

	params.align = params.value_align or "center"
	local label_value_with_delta_params = clone(params)
	label_value_with_delta_params.font = tweak_data.gui.fonts.din_compressed
	label_value_with_delta_params.font_size = params.value_delta_font_size or tweak_data.gui.font_sizes.subtitle
	label_value_with_delta_params.h = label_value_with_delta_params.font_size
	label_value_with_delta_params.text = label_value_with_delta_params.value or label_value_with_delta_params.text
	label_value_with_delta_params.x = 0
	label_value_with_delta_params.y = 0
	label_value_with_delta_params.w = nil
	label_value_with_delta_params.text = params.delta_text or ""
	label_value_with_delta_params.color = params.value_delta_color or tweak_data.gui.colors.progress_green
	self._label_value_with_delta = self._object:label(label_value_with_delta_params)
end

-- Lines 23-46
function RaidGUIControlLabelNamedValueWithDelta:set_value_delta(number)
	local full_value = ""

	if not number or number == 0 then
		self._label_value_with_delta:hide()

		full_value = ""
	elseif number < 0 then
		self._label_value_with_delta:show()

		full_value = "-" .. math.abs(number)
	elseif number > 0 then
		self._label_value_with_delta:show()

		full_value = "+" .. number
	end

	self._label_value_with_delta:set_text(full_value)

	local _, _, w, _ = self._label_value_with_delta:text_rect()

	self._label_value_with_delta:set_w(w)
	self._label_value_with_delta:set_x(self._label_value:right())
end

-- Lines 48-50
function RaidGUIControlLabelNamedValueWithDelta:value_delta()
	return self._label_value_with_delta:text()
end

-- Lines 52-55
function RaidGUIControlLabelNamedValueWithDelta:set_label_color(color)
	RaidGUIControlLabelNamedValueWithDelta.super.set_label_color(self, color)
	self._label_value_with_delta:set_color(color)
end

-- Lines 57-60
function RaidGUIControlLabelNamedValueWithDelta:set_label_default_color()
	RaidGUIControlLabelNamedValueWithDelta.super.set_label_default_color(self)
	self._label_value_with_delta:set_color(self._params.value_delta_color or tweak_data.gui.colors.progress_green)
end
