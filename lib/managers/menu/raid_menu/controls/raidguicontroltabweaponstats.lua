RaidGUIControlTabWeaponStats = RaidGUIControlTabWeaponStats or class(RaidGUIControl)

-- Lines 3-18
function RaidGUIControlTabWeaponStats:init(parent, params)
	RaidGUIControlTabWeaponStats.super.init(self, parent, params)

	self._object = parent:panel(params)
	params.x = 0
	params.y = 0
	self._label = self._object:create_custom_control(params.label_class or RaidGUIControlLabelNamedValue, params)
	self._callback_param = nil
	self._tab_select_callback = nil
	self._selected = false
end

-- Lines 20-23
function RaidGUIControlTabWeaponStats:set_text(text)
	self._text = text

	self._label:set_text(text)
end

-- Lines 25-27
function RaidGUIControlTabWeaponStats:text()
	return self._label:text()
end

-- Lines 29-31
function RaidGUIControlTabWeaponStats:set_value(text)
	self._label:set_value(text)
end

-- Lines 33-35
function RaidGUIControlTabWeaponStats:value()
	return self._label:value()
end

-- Lines 37-39
function RaidGUIControlTabWeaponStats:set_value_delta(text)
	self._label:set_value_delta(text)
end

-- Lines 41-43
function RaidGUIControlTabWeaponStats:value_delta()
	return self._label:value_delta()
end

-- Lines 45-47
function RaidGUIControlTabWeaponStats:needs_divider()
	return false
end

-- Lines 49-51
function RaidGUIControlTabWeaponStats:needs_bottom_line()
	return false
end

-- Lines 53-55
function RaidGUIControlTabWeaponStats:get_callback_param()
	return nil
end

-- Lines 57-58
function RaidGUIControlTabWeaponStats:highlight_on()
end

-- Lines 60-61
function RaidGUIControlTabWeaponStats:highlight_off()
end

-- Lines 63-65
function RaidGUIControlTabWeaponStats:select()
	self._selected = false
end

-- Lines 67-69
function RaidGUIControlTabWeaponStats:unselect()
	self._selected = false
end

-- Lines 71-73
function RaidGUIControlTabWeaponStats:mouse_released(o, button, x, y)
	return false
end

-- Lines 75-77
function RaidGUIControlTabWeaponStats:on_mouse_released(button, x, y)
	return false
end

-- Lines 79-81
function RaidGUIControlTabWeaponStats:set_color(color)
	self._label:set_label_color(color)
end

-- Lines 83-85
function RaidGUIControlTabWeaponStats:set_label_default_color()
	self._label:set_label_default_color()
end
