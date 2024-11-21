RaidGUIControlGrenadeWeaponStats = RaidGUIControlGrenadeWeaponStats or class(RaidGUIControlWeaponStats)

function RaidGUIControlGrenadeWeaponStats:init(parent, params)
	RaidGUIControlGrenadeWeaponStats.super.init(self, parent, params)
end

function RaidGUIControlGrenadeWeaponStats:_set_default_values()
	self._values = {
		damage = {
			value = "00-000",
			text = self:translate("menu_weapons_stats_damage", true)
		},
		range = {
			value = "000",
			text = self:translate("menu_weapons_stats_grenade_diameter", true)
		},
		distance = {
			value = "000",
			text = self:translate("menu_weapons_stats_grenade_throw", true)
		},
		capacity = {
			value = "0-00",
			text = self:translate("menu_weapons_stats_grenade_capacity", true)
		}
	}
end

function RaidGUIControlGrenadeWeaponStats:_get_tabs_params()
	local tabs_params = {
		{
			name = "damage",
			text = self._values.damage.text,
			value = self._values.damage.value
		},
		{
			name = "range",
			text = self._values.range.text,
			value = self._values.range.value
		},
		{
			name = "distance",
			text = self._values.distance.text,
			value = self._values.distance.value
		},
		{
			name = "capacity",
			text = self._values.capacity.text,
			value = self._values.capacity.value
		}
	}

	return tabs_params
end

function RaidGUIControlGrenadeWeaponStats:set_stats(damage, range, distance, capacity)
	self._values.damage.value = damage
	self._values.range.value = range
	self._values.distance.value = distance
	self._values.capacity.value = capacity

	for _, item in ipairs(self._items) do
		local name = item:name()
		local value = self._values[name].value

		item:set_value(value)
	end
end

function RaidGUIControlGrenadeWeaponStats:refresh_data()
	Application:trace("[RaidGUIControlGrenadeWeaponStats:refresh_data]")
end

function RaidGUIControlGrenadeWeaponStats:_create_bottom_line()
end

function RaidGUIControlGrenadeWeaponStats:_initial_tab_selected(tab_idx)
end

function RaidGUIControlGrenadeWeaponStats:_tab_selected(tab_idx, callback_param)
end

function RaidGUIControlGrenadeWeaponStats:_unselect_all()
end

function RaidGUIControlGrenadeWeaponStats:set_selected(value)
	Application:error("[RaidGUIControlGrenadeWeaponStats:set_selected] weapon stats control can't be selected")

	self._selected = false
end

function RaidGUIControlGrenadeWeaponStats:move_up()
end

function RaidGUIControlGrenadeWeaponStats:move_down()
end

function RaidGUIControlGrenadeWeaponStats:move_left()
end

function RaidGUIControlGrenadeWeaponStats:move_right()
end

function RaidGUIControlGrenadeWeaponStats:highlight_on()
end

function RaidGUIControlGrenadeWeaponStats:highlight_off()
end

function RaidGUIControlGrenadeWeaponStats:mouse_released(o, button, x, y)
	return false
end
