IntelGui = IntelGui or class(RaidGuiBase)
IntelGui.CATEGORY_BULLETINS = "bulletins"
IntelGui.CATEGORY_OPERATIONAL_STATUS = "operational_status"
IntelGui.CATEGORY_RAID_PERSONEL = "raid_personnel"
IntelGui.CATEGORY_OPPOSITION_FORCES = "opposition_forces"
IntelGui.CATEGORY_CONTROL_ARCHIVE = "control_archive"

-- Lines 10-18
function IntelGui:init(ws, fullscreen_ws, node, component_name)
	IntelGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_intel_screen_name")
end

-- Lines 20-22
function IntelGui:_set_initial_data()
	self._selected_category = IntelGui.CATEGORY_RAID_PERSONEL
end

-- Lines 24-33
function IntelGui:_layout()
	self:_disable_dof()
	self:_layout_content()
	self:_layout_tab_categories()
	self:_layout_list()
	self._category_items_list:set_selected(true, false)
	self:bind_controller_inputs()
end

-- Lines 35-60
function IntelGui:_layout_tab_categories()
	local category_tabs_params = {
		name = "category_tabs",
		tab_width = 220,
		initial_tab_idx = 1,
		tab_align = "center",
		tab_height = 64,
		y = 80,
		x = 0,
		tab_font_size = tweak_data.gui.font_sizes.small,
		on_click_callback = callback(self, self, "on_intel_category_selected"),
		parent_control_ref = self,
		tabs_params = {}
	}

	for category_index, category_name in ipairs(tweak_data.intel.category_index) do
		category_tabs_params.tabs_params[category_index] = {
			name = "tab_" .. category_name,
			icon = nil,
			text = self:translate(tweak_data.intel.categories[category_name].name_id, true),
			callback_param = category_name
		}
	end

	self._category_tabs = self._root_panel:tabs(category_tabs_params)
end

-- Lines 62-91
function IntelGui:_layout_list()
	local category_items_list_scrollable_area_params = {
		scrollbar_width = 3,
		name = "category_items_list_scrollable_area",
		h = 752,
		y = 192,
		w = 384,
		x = 0,
		scroll_step = 19
	}
	self._category_items_list_scrollable_area = self._root_panel:scrollable_area(category_items_list_scrollable_area_params)
	local category_items_list_params = {
		selection_enabled = true,
		name = "category_items_list",
		w = 384,
		on_mouse_over_sound_event = "highlight",
		y = 0,
		item_h = 62,
		x = 0,
		use_unlocked = false,
		item_font = tweak_data.gui.fonts.lato,
		item_font_size = tweak_data.gui.font_sizes.size_24,
		on_item_clicked_callback = callback(self, self, "on_item_clicked_category_items_list"),
		on_item_selected_callback = callback(self, self, "on_item_selected_category_items_list"),
		data_source_callback = callback(self, self, "data_source_category_items_list"),
		item_class = RaidGUIControlListItem,
		scrollable_area_ref = self._category_items_list_scrollable_area
	}
	self._category_items_list = self._category_items_list_scrollable_area:get_panel():list(category_items_list_params)

	self._category_items_list_scrollable_area:setup_scroll_area()
end

-- Lines 93-97
function IntelGui:_layout_content()
	self:_create_category_controls(self._selected_category)
	self:_setup_category_controls(self._selected_category)
end

-- Lines 99-101
function IntelGui:close()
	IntelGui.super.close(self)
end

-- Lines 105-121
function IntelGui:on_intel_category_selected(data)
	self._selected_category = data

	self:_setup_category_controls(self._selected_category)

	if self._selected_category == IntelGui.CATEGORY_CONTROL_ARCHIVE then
		self:bind_controller_inputs_play_video()
	else
		self:bind_controller_inputs()
	end

	self._category_items_list:refresh_data()
	self._category_items_list_scrollable_area:setup_scroll_area()
	self._category_items_list:set_selected(true, false)
end

-- Lines 123-127
function IntelGui:on_item_clicked_category_items_list(data)
	self:_list_item_selected(data.value)
end

-- Lines 129-133
function IntelGui:on_item_selected_category_items_list(data)
	self:_list_item_selected(data.value)
end

-- Lines 135-171
function IntelGui:data_source_category_items_list()
	local result = {}
	local is_unlocked = true
	local data_source_table = tweak_data.intel.categories[self._selected_category].items

	if data_source_table then
		for list_item_index, list_item_data in pairs(data_source_table) do
			if self._selected_category == IntelGui.CATEGORY_CONTROL_ARCHIVE then
				is_unlocked = managers.unlock:is_unlocked({
					slot = UnlockManager.SLOT_PROFILE,
					identifier = UnlockManager.CATEGORY_CONTROL_ARCHIVE
				}, {
					list_item_data.id
				})
			elseif self._selected_category == IntelGui.CATEGORY_OPERATIONAL_STATUS or self._selected_category == IntelGui.CATEGORY_BULLETINS then
				list_item_index = #data_source_table - list_item_index + 1
				list_item_data = data_source_table[list_item_index]
			else
				is_unlocked = true
			end

			if is_unlocked then
				if #result == 0 then
					table.insert(result, {
						selected = true,
						text = self:translate(list_item_data.list_item_name_id, false),
						value = list_item_data.id
					})
				else
					table.insert(result, {
						selected = false,
						text = self:translate(list_item_data.list_item_name_id, false),
						value = list_item_data.id
					})
				end
			end
		end
	end

	return result
end

-- Lines 175-180
function IntelGui:_list_item_selected(list_item_value)
	self:_show_selected_list_item_data(list_item_value)
end

-- Lines 183-190
function IntelGui:_create_category_controls(selected_category)
	self._bulletins_control = self._root_panel:create_custom_control(RaidGUIControlIntelBulletin, {
		visible = false,
		h = 752,
		y = 144,
		w = 1120,
		x = 512
	})
	self._operational_status_control = self._root_panel:create_custom_control(RaidGUIControlIntelOperationalStatus, {
		visible = false,
		h = 752,
		y = 144,
		w = 1120,
		x = 512
	})
	self._raid_personel_control = self._root_panel:create_custom_control(RaidGUIControlIntelRaidPersonel, {
		visible = false,
		h = 768,
		y = 160,
		w = 1088,
		x = 512
	})
	self._opposite_forces_control = self._root_panel:create_custom_control(RaidGUIControlIntelOppositeForces, {
		visible = false,
		h = 704,
		y = 192,
		w = 1024,
		x = 544
	})
	self._control_archive_control = self._root_panel:create_custom_control(RaidGUIControlIntelControlArchive, {
		visible = false,
		h = 704,
		y = 192,
		w = 1024,
		x = 544
	})
end

-- Lines 192-231
function IntelGui:_setup_category_controls(selected_category)
	if selected_category == IntelGui.CATEGORY_BULLETINS then
		self._active_category_control = self._bulletins_control

		self._bulletins_control:set_visible(true)
		self._operational_status_control:set_visible(false)
		self._raid_personel_control:set_visible(false)
		self._opposite_forces_control:set_visible(false)
		self._control_archive_control:set_visible(false)
	elseif selected_category == IntelGui.CATEGORY_OPERATIONAL_STATUS then
		self._active_category_control = self._operational_status_control

		self._bulletins_control:set_visible(false)
		self._operational_status_control:set_visible(true)
		self._raid_personel_control:set_visible(false)
		self._opposite_forces_control:set_visible(false)
		self._control_archive_control:set_visible(false)
	elseif selected_category == IntelGui.CATEGORY_RAID_PERSONEL then
		self._active_category_control = self._raid_personel_control

		self._bulletins_control:set_visible(false)
		self._operational_status_control:set_visible(false)
		self._raid_personel_control:set_visible(true)
		self._opposite_forces_control:set_visible(false)
		self._control_archive_control:set_visible(false)
	elseif selected_category == IntelGui.CATEGORY_OPPOSITION_FORCES then
		self._active_category_control = self._opposite_forces_control

		self._bulletins_control:set_visible(false)
		self._operational_status_control:set_visible(false)
		self._raid_personel_control:set_visible(false)
		self._opposite_forces_control:set_visible(true)
		self._control_archive_control:set_visible(false)
	elseif selected_category == IntelGui.CATEGORY_CONTROL_ARCHIVE then
		self._active_category_control = self._control_archive_control

		self._bulletins_control:set_visible(false)
		self._operational_status_control:set_visible(false)
		self._raid_personel_control:set_visible(false)
		self._opposite_forces_control:set_visible(false)
		self._control_archive_control:set_visible(true)
	end
end

-- Lines 233-243
function IntelGui:_show_selected_list_item_data(list_item_value)
	self._active_category_control:set_data(list_item_value)

	local item_full_data = self._active_category_control:get_data()

	self:_stop_intel_audio()

	if item_full_data and item_full_data.description_vo_id then
		self:_play_intel_audio(item_full_data.description_vo_id)
	end
end

-- Lines 245-249
function IntelGui:update(t, dt)
	if self._control_archive_control then
		self._control_archive_control:update(t, dt)
	end
end

-- Lines 253-255
function IntelGui:_play_intel_audio(intel_audio_id)
	self._intel_audio = managers.menu_component:post_event(intel_audio_id)
end

-- Lines 257-264
function IntelGui:_stop_intel_audio()
	managers.queued_tasks:unqueue("play_intel_audio")

	if alive(self._intel_audio) then
		self._intel_audio:stop()

		self._intel_audio = nil
	end
end

-- Lines 272-290
function IntelGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_intel_tabs"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

-- Lines 292-311
function IntelGui:bind_controller_inputs_play_video()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_intel_tabs",
			"menu_legend_intel_play_video"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

-- Lines 313-317
function IntelGui:_on_weapon_category_tab_left()
	self._category_tabs:_move_left()

	return true, nil
end

-- Lines 319-323
function IntelGui:_on_weapon_category_tab_right()
	self._category_tabs:_move_right()

	return true, nil
end

-- Lines 325-340
function IntelGui:confirm_pressed()
	if self._selected_category == IntelGui.CATEGORY_CONTROL_ARCHIVE then
		local selected_item = self._category_items_list:selected_item()

		if selected_item then
			local selected_item_data = self._category_items_list:selected_item():data()

			self._control_archive_control:play_video()
		end
	end

	return true
end
