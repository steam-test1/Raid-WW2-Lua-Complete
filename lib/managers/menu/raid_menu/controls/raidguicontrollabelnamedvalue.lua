RaidGUIControlLabelNamedValue = RaidGUIControlLabelNamedValue or class(RaidGUIControl)

function RaidGUIControlLabelNamedValue:init(parent, params)
	self._object = parent:panel(params)
	self._params = clone(params)
	params.align = params.value_align or "center"

	local label_value_params = clone(params)

	label_value_params.font = tweak_data.gui.fonts.din_compressed
	label_value_params.font_size = params.value_font_size or tweak_data.gui.font_sizes.size_56
	label_value_params.h = label_value_params.font_size
	label_value_params.text = label_value_params.value or label_value_params.text
	label_value_params.x = 0
	label_value_params.y = 0
	label_value_params.w = nil
	label_value_params.text = params.value_text or ""
	label_value_params.color = params.value_color or tweak_data.gui.colors.raid_white
	self._label_value = self._object:text(label_value_params)
	params.align = params.align or "center"

	local label_text_params = clone(params)

	label_text_params.font_size = params.font_size or tweak_data.gui.font_sizes.medium
	label_text_params.x = 0
	label_text_params.y = label_value_params.font_size + (label_text_params.value_padding or 0)
	label_text_params.h = label_text_params.font_size + 3
	label_text_params.w = nil
	label_text_params.text = params.text or ""
	label_text_params.color = params.color or tweak_data.gui.colors.raid_white
	self._label_text = self._object:label(label_text_params)
end

function RaidGUIControlLabelNamedValue:set_text(text)
	self._text = text

	self._label_text:set_text(text)
end

function RaidGUIControlLabelNamedValue:text()
	return self._label_text:text()
end

function RaidGUIControlLabelNamedValue:set_value(text)
	self._label_value:set_text(text)

	local _, _, w, _ = self._label_value:text_rect()

	self._label_value:set_w(w)
	self._label_value:set_center_x(self._object:w() / 2)
end

function RaidGUIControlLabelNamedValue:value()
	return self._label_value:text()
end

function RaidGUIControlLabelNamedValue:highlight_on()
	return
end

function RaidGUIControlLabelNamedValue:highlight_off()
	return
end

function RaidGUIControlLabelNamedValue:mouse_released(o, button, x, y)
	return false
end

function RaidGUIControlLabelNamedValue:set_label_color(color)
	self._label_value:set_color(color)
	self._label_text:set_color(color)
end

function RaidGUIControlLabelNamedValue:set_label_default_color()
	self._label_value:set_color(self._params.value_color or tweak_data.gui.colors.raid_white)
	self._label_text:set_color(self._params.color or tweak_data.gui.colors.raid_white)
end
