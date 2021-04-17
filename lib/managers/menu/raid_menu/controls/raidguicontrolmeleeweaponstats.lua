RaidGUIControlMeleeWeaponStats = RaidGUIControlMeleeWeaponStats or class(RaidGUIControlWeaponStats)

-- Lines 3-5
function RaidGUIControlMeleeWeaponStats:init(parent, params)
	RaidGUIControlMeleeWeaponStats.super.init(self, parent, params)
end

-- Lines 7-14
function RaidGUIControlMeleeWeaponStats:_set_default_values()
	self._values = {
		damage = {
			value = "00-000",
			text = self:translate("menu_weapons_stats_damage", true)
		},
		knockback = {
			value = "00-000",
			text = self:translate("menu_weapons_stats_knockback", true)
		},
		range = {
			value = "000",
			text = self:translate("menu_weapons_stats_range", true)
		},
		charge_time = {
			value = "00",
			text = self:translate("menu_weapons_stats_charge_time", true)
		}
	}
end

-- Lines 16-24
function RaidGUIControlMeleeWeaponStats:_get_tabs_params()
	local tabs_params = {
		{
			name = "damage",
			text = self._values.damage.text,
			value = self._values.damage.value
		},
		{
			name = "knockback",
			text = self._values.knockback.text,
			value = self._values.knockback.value
		},
		{
			name = "range",
			text = self._values.range.text,
			value = self._values.range.value
		},
		{
			name = "charge_time",
			text = self._values.charge_time.text,
			value = self._values.charge_time.value
		}
	}

	return tabs_params
end

-- Lines 26-39
function RaidGUIControlMeleeWeaponStats:set_stats(damage, knockback, range, charge_time)
	self._values.damage.value = damage
	self._values.knockback.value = knockback
	self._values.range.value = range
	self._values.charge_time.value = charge_time

	for _, item in ipairs(self._items) do
		local name = item:name()
		local value = self._values[name].value

		item:set_value(value)
	end
end

-- Lines 41-43
function RaidGUIControlMeleeWeaponStats:refresh_data()
	Application:trace("[RaidGUIControlMeleeWeaponStats:refresh_data]")
end

-- Lines 45-46
function RaidGUIControlMeleeWeaponStats:_create_bottom_line()
end

-- Lines 48-49
function RaidGUIControlMeleeWeaponStats:_initial_tab_selected(tab_idx)
end

-- Lines 51-52
function RaidGUIControlMeleeWeaponStats:_tab_selected(tab_idx, callback_param)
end

-- Lines 54-55
function RaidGUIControlMeleeWeaponStats:_unselect_all()
end

-- Lines 61-64
function RaidGUIControlMeleeWeaponStats:set_selected(value)
	Application:error("[RaidGUIControlMeleeWeaponStats:set_selected] weapon stats control can't be selected")

	self._selected = false
end

-- Lines 66-67
function RaidGUIControlMeleeWeaponStats:move_up()
end

-- Lines 69-70
function RaidGUIControlMeleeWeaponStats:move_down()
end

-- Lines 72-73
function RaidGUIControlMeleeWeaponStats:move_left()
end

-- Lines 75-76
function RaidGUIControlMeleeWeaponStats:move_right()
end

-- Lines 79-80
function RaidGUIControlMeleeWeaponStats:highlight_on()
end

-- Lines 82-83
function RaidGUIControlMeleeWeaponStats:highlight_off()
end

-- Lines 85-87
function RaidGUIControlMeleeWeaponStats:mouse_released(o, button, x, y)
	return false
end
