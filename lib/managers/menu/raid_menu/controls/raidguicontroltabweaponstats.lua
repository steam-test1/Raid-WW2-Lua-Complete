RaidGUIControlTabWeaponStats = RaidGUIControlTabWeaponStats or class(RaidGUIControl)

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

function RaidGUIControlTabWeaponStats:set_text(text)
	self._text = text

	self._label:set_text(text)
end

function RaidGUIControlTabWeaponStats:text()
	return self._label:text()
end

function RaidGUIControlTabWeaponStats:set_value(text)
	self._label:set_value(text)
end

function RaidGUIControlTabWeaponStats:value()
	return self._label:value()
end

function RaidGUIControlTabWeaponStats:set_value_delta(text)
	self._label:set_value_delta(text)
end

function RaidGUIControlTabWeaponStats:value_delta()
	return self._label:value_delta()
end

function RaidGUIControlTabWeaponStats:needs_divider()
	return false
end

function RaidGUIControlTabWeaponStats:needs_bottom_line()
	return false
end

function RaidGUIControlTabWeaponStats:get_callback_param()
	return nil
end

function RaidGUIControlTabWeaponStats:highlight_on()
	return
end

function RaidGUIControlTabWeaponStats:highlight_off()
	return
end

function RaidGUIControlTabWeaponStats:select()
	self._selected = false
end

function RaidGUIControlTabWeaponStats:unselect()
	self._selected = false
end

function RaidGUIControlTabWeaponStats:mouse_released(o, button, x, y)
	return false
end

function RaidGUIControlTabWeaponStats:on_mouse_released(button, x, y)
	return false
end

function RaidGUIControlTabWeaponStats:set_color(color)
	self._label:set_label_color(color)
end

function RaidGUIControlTabWeaponStats:set_label_default_color()
	self._label:set_label_default_color()
end
