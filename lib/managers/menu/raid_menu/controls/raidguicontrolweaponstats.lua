RaidGUIControlWeaponStats = RaidGUIControlWeaponStats or class(RaidGUIControlTabs)
RaidGUIControlWeaponStats.TAB_HEIGHT = 96

-- Lines 5-14
function RaidGUIControlWeaponStats:init(parent, params)
	params.item_class = RaidGUIControlTabWeaponStats

	self:_set_default_values()

	params.tabs_params = self:_get_tabs_params()
	params.tab_height = RaidGUIControlWeaponStats.TAB_HEIGHT

	RaidGUIControlWeaponStats.super.init(self, parent, params)
end

-- Lines 16-42
function RaidGUIControlWeaponStats:_create_items()
	if self._params.tabs_params then
		for index, tabs_params in ipairs(self._params.tabs_params) do
			tabs_params.x = (index - 1) * self._tab_width + (self._icon_title and self._icon_title:w() or 0)
			tabs_params.y = 0
			tabs_params.w = self._tab_width
			tabs_params.h = self._tab_height
			tabs_params.font_size = tweak_data.gui.font_sizes.medium
			tabs_params.color = tweak_data.gui.colors.raid_grey
			tabs_params.value_font_size = tweak_data.gui.font_sizes.size_52
			tabs_params.value_delta_font_size = tweak_data.gui.font_sizes.subtitle
			tabs_params.value_padding = 10
			tabs_params.value_color = tweak_data.gui.colors.raid_white
			tabs_params.value_delta_color = tweak_data.gui.colors.progress_green
			tabs_params.tab_select_callback = callback(self, self, "_tab_selected")
			tabs_params.tab_align = self._params.tab_align
			tabs_params.tab_idx = index
			tabs_params.callback_param = tabs_params.callback_param
			tabs_params.label_class = self._params.label_class
			local item = self._object:create_custom_control(self._params.item_class or RaidGUIControlTab, tabs_params)

			if index ~= #self._params.tabs_params and self._item_class.needs_divider() then
				item:set_divider()
			end

			table.insert(self._items, item)
		end
	end
end

-- Lines 44-53
function RaidGUIControlWeaponStats:_set_default_values()
	self._values = {
		damage = {
			value = "00",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_damage", true)
		},
		magazine = {
			value = "000",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_magazine", true)
		},
		total_ammo = {
			value = "000",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_total_ammo", true)
		},
		rate_of_fire = {
			value = "00",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_rate_of_fire", true)
		},
		accuracy = {
			value = "00",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_accuracy", true)
		},
		stability = {
			value = "00",
			delta_value = "00",
			text = self:translate("menu_weapons_stats_stability", true)
		}
	}
end

-- Lines 57-67
function RaidGUIControlWeaponStats:_get_tabs_params()
	local tabs_params = {
		{
			name = "damage",
			text = self._values.damage.text,
			modified_value = self._values.damage.modified_value or 0,
			applied_value = self._values.damage.applied_value or 0
		},
		{
			name = "magazine",
			text = self._values.magazine.text,
			modified_value = self._values.magazine.modified_value or 0,
			applied_value = self._values.magazine.applied_value or 0
		},
		{
			name = "total_ammo",
			text = self._values.total_ammo.text,
			modified_value = self._values.total_ammo.modified_value or 0,
			applied_value = self._values.total_ammo.applied_value or 0
		},
		{
			name = "rate_of_fire",
			text = self._values.rate_of_fire.text,
			modified_value = self._values.rate_of_fire.modified_value or 0,
			applied_value = self._values.rate_of_fire.applied_value or 0
		},
		{
			name = "accuracy",
			text = self._values.accuracy.text,
			modified_value = self._values.accuracy.modified_value or 0,
			applied_value = self._values.accuracy.applied_value or 0
		},
		{
			name = "stability",
			text = self._values.stability.text,
			modified_value = self._values.stability.modified_value or 0,
			applied_value = self._values.stability.applied_value or 0
		}
	}

	return tabs_params
end

-- Lines 69-97
function RaidGUIControlWeaponStats:set_modified_stats(params)
	self._values.damage.modified_value = params.damage_modified_value
	self._values.magazine.modified_value = params.magazine_modified_value
	self._values.total_ammo.modified_value = params.total_ammo_modified_value
	self._values.rate_of_fire.modified_value = params.rate_of_fire_modified_value
	self._values.accuracy.modified_value = params.accuracy_modified_value
	self._values.stability.modified_value = params.stability_modified_value

	for _, item in ipairs(self._items) do
		local name = item:name()
		local item_data = self._values[name]
		local sign = ""
		local delta_value = tonumber(item_data.modified_value or 0) - tonumber(item_data.applied_value or 0)

		item:set_value(item_data.applied_value .. "")
		item:set_value_delta(delta_value)

		if delta_value < 0 then
			item:set_color(tweak_data.gui.colors.progress_green)
		elseif delta_value > 0 then
			item:set_color(tweak_data.gui.colors.progress_green)
		else
			item:set_label_default_color()
		end
	end
end

-- Lines 102-111
function RaidGUIControlWeaponStats:set_applied_stats(params)
	self._values.damage.applied_value = params.damage_applied_value
	self._values.magazine.applied_value = params.magazine_applied_value
	self._values.total_ammo.applied_value = params.total_ammo_applied_value
	self._values.rate_of_fire.applied_value = params.rate_of_fire_applied_value
	self._values.accuracy.applied_value = params.accuracy_applied_value
	self._values.stability.applied_value = params.stability_applied_value
end

-- Lines 113-115
function RaidGUIControlWeaponStats:refresh_data()
	Application:trace("[RaidGUIControlWeaponStats:refresh_data]")
end

-- Lines 117-118
function RaidGUIControlWeaponStats:_create_bottom_line()
end

-- Lines 120-121
function RaidGUIControlWeaponStats:_initial_tab_selected(tab_idx)
end

-- Lines 123-124
function RaidGUIControlWeaponStats:_tab_selected(tab_idx, callback_param)
end

-- Lines 126-127
function RaidGUIControlWeaponStats:_unselect_all()
end

-- Lines 133-136
function RaidGUIControlWeaponStats:set_selected(value)
	Application:error("[RaidGUIControlWeaponStats:set_selected] weapon stats control can't be selected")

	self._selected = false
end

-- Lines 138-139
function RaidGUIControlWeaponStats:move_up()
end

-- Lines 141-142
function RaidGUIControlWeaponStats:move_down()
end

-- Lines 144-145
function RaidGUIControlWeaponStats:move_left()
end

-- Lines 147-148
function RaidGUIControlWeaponStats:move_right()
end

-- Lines 151-152
function RaidGUIControlWeaponStats:highlight_on()
end

-- Lines 154-155
function RaidGUIControlWeaponStats:highlight_off()
end

-- Lines 157-159
function RaidGUIControlWeaponStats:mouse_released(o, button, x, y)
	return false
end
