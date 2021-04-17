RaidGUIPanel = RaidGUIPanel or class()
RaidGUIPanel.ID = 1
RaidGUIPanel.TYPE = "raid_gui_panel"

-- Lines 6-31
function RaidGUIPanel:init(parent, params)
	self._type = self._type or RaidGUIPanel.TYPE
	self._panel_id = RaidGUIPanel.ID
	RaidGUIPanel.ID = RaidGUIPanel.ID + 1
	self._name = params.name or self._type .. "_" .. self._panel_id
	self._parent = parent
	self._params = clone(params)
	self._params.name = params.name or self._name
	self._params.layer = params.layer or parent.layer and parent:layer() + 2 or RaidGuiBase.FOREGROUND_LAYER
	self.is_root_panel = params.is_root_panel

	if self.is_root_panel then
		self._engine_panel = self._parent:panel(self._params)
	else
		self._engine_panel = self._parent:get_engine_panel():panel(self._params)
	end

	if params.background_color then
		self._background = self:rect({
			layer = 1,
			name = self._name .. "_bg",
			color = params.background_color
		})
	end

	self._controls = {}
end

-- Lines 33-35
function RaidGUIPanel:get_controls()
	return self._controls
end

-- Lines 37-39
function RaidGUIPanel:get_engine_panel()
	return self._engine_panel
end

-- Lines 41-43
function RaidGUIPanel:center()
	return self._engine_panel:center()
end

-- Lines 45-47
function RaidGUIPanel:center_x()
	return self._engine_panel:center_x()
end

-- Lines 49-51
function RaidGUIPanel:center_y()
	return self._engine_panel:center_y()
end

-- Lines 53-55
function RaidGUIPanel:set_top(value)
	return self._engine_panel:set_top(value)
end

-- Lines 57-59
function RaidGUIPanel:set_bottom(value)
	return self._engine_panel:set_bottom(value)
end

-- Lines 61-63
function RaidGUIPanel:get_panel()
	return self
end

-- Lines 66-68
function RaidGUIPanel:layer()
	return self._engine_panel:layer()
end

-- Lines 71-77
function RaidGUIPanel:close()
	for _, control in ipairs(self._controls) do
		control:close()
	end

	self._controls = {}

	self._engine_panel:clear()
end

-- Lines 80-86
function RaidGUIPanel:clear()
	for _, control in ipairs(self._controls) do
		control:close()
	end

	self._controls = {}

	self._engine_panel:clear()
end

-- Lines 88-94
function RaidGUIPanel:child(control_name)
	if alive(self._engine_panel) then
		return self._engine_panel:child(control_name)
	else
		return nil
	end
end

-- Lines 96-98
function RaidGUIPanel:children()
	return self._engine_panel:children()
end

-- Lines 100-102
function RaidGUIPanel:parent()
	return self._parent
end

-- Lines 108-131
function RaidGUIPanel:remove(control)
	local removed = false
	local i = #self._controls

	while i > 0 do
		if self._controls[i] == control then
			table.remove(self._controls, i)

			if control._object._type == RaidGUIPanel.TYPE then
				self._engine_panel:remove(control._object:get_engine_panel())
			else
				self._engine_panel:remove(control._object)
			end

			removed = true

			break
		end

		i = i - 1
	end

	if not removed and control ~= nil then
		self._engine_panel:remove(control)
	end

	control = nil
end

-- Lines 133-143
function RaidGUIPanel:get_max_control_y()
	local max_y = 0

	for _, control in pairs(self._controls) do
		local bottom_y = control:y() + control:h()

		if max_y < bottom_y then
			max_y = bottom_y
		end
	end

	return max_y
end

-- Lines 145-148
function RaidGUIPanel:fit_content_height()
	local max_y = self:get_max_control_y()

	self._engine_panel:set_h(max_y)
end

-- Lines 152-156
function RaidGUIPanel:key_press(callback)
	if callback then
		self._engine_panel:key_press(callback)
	end
end

-- Lines 158-162
function RaidGUIPanel:key_release(callback)
	if callback then
		self._engine_panel:key_release(callback)
	end
end

-- Lines 164-168
function RaidGUIPanel:enter_text(callback)
	if callback then
		self._engine_panel:enter_text(callback)
	end
end

-- Lines 172-174
function RaidGUIPanel:inside(x, y)
	return self._engine_panel:inside(x, y) and self._engine_panel:tree_visible()
end

-- Lines 177-190
function RaidGUIPanel:mouse_moved(o, x, y)
	local used = false
	local pointer = nil

	for _, control in ipairs(self._controls) do
		local u, p = control:mouse_moved(o, x, y)

		if not used and u then
			used = u
			pointer = p
		end
	end

	return used, pointer
end

-- Lines 193-201
function RaidGUIPanel:mouse_pressed(o, button, x, y)
	for _, control in ipairs(self._controls) do
		local handled = control:mouse_pressed(o, button, x, y)

		if handled then
			return true
		end
	end

	return false
end

-- Lines 204-212
function RaidGUIPanel:mouse_clicked(o, button, x, y)
	for _, control in ipairs(self._controls) do
		local handled = control:mouse_clicked(o, button, x, y)

		if handled then
			return true
		end
	end

	return false
end

-- Lines 215-225
function RaidGUIPanel:mouse_double_click(o, button, x, y)
	for _, control in ipairs(self._controls) do
		if control and control:visible() and control:inside(x, y) then
			local handled = control:mouse_double_click(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 228-238
function RaidGUIPanel:mouse_released(o, button, x, y)
	for _, control in ipairs(self._controls) do
		if control and control:visible() and control:inside(x, y) then
			local handled = control:mouse_released(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 240-250
function RaidGUIPanel:mouse_scroll_up(o, button, x, y)
	for _, control in ipairs(self._controls) do
		if control:inside(x, y) then
			local handled = control:mouse_scroll_up(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 252-262
function RaidGUIPanel:mouse_scroll_down(o, button, x, y)
	for _, control in ipairs(self._controls) do
		if control:inside(x, y) then
			local handled = control:mouse_scroll_down(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 264-266
function RaidGUIPanel:back_pressed()
	managers.raid_menu:on_escape()
end

-- Lines 268-282
function RaidGUIPanel:special_btn_pressed(...)
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:special_btn_pressed(...)

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 284-298
function RaidGUIPanel:move_up()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:move_up()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 300-314
function RaidGUIPanel:move_down()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:move_down()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 316-330
function RaidGUIPanel:move_left()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:move_left()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 332-346
function RaidGUIPanel:move_right()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:move_right()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 348-362
function RaidGUIPanel:scroll_up()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:scroll_up()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 364-378
function RaidGUIPanel:scroll_down()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:scroll_down()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 380-394
function RaidGUIPanel:scroll_left()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:scroll_left()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 396-410
function RaidGUIPanel:scroll_right()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled, target = control:scroll_right()

			if handled then
				return true
			end

			if not handled and target then
				return false, target
			end
		end
	end

	return false
end

-- Lines 412-423
function RaidGUIPanel:special_btn_pressed(...)
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled = control:special_btn_pressed(...)

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 425-436
function RaidGUIPanel:confirm_pressed()
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			local handled = control:confirm_pressed()

			if handled then
				return true
			end
		end
	end

	return false
end

-- Lines 438-459
function RaidGUIPanel:set_background(params)
	if params.texture then
		if self._background then
			self._engine_panel:remove(self._background)
		end

		params.name = self._name .. "_bg"
		params.x = 0
		params.y = 0
		params.w = self._engine_panel:w()
		params.h = self._engine_panel:h()
		params.layer = 1
		self._background = self:bitmap(params)
	elseif params.background_color then
		if self._background then
			self._engine_panel:remove(self._background)
		end

		self._background = self:rect({
			layer = 1,
			name = self._name .. "_bg",
			color = params.background_color
		})
	end
end

-- Lines 461-463
function RaidGUIPanel:remove_background()
	self:remove(self._background)
end

-- Lines 465-469
function RaidGUIPanel:set_background_color(color)
	if self._background then
		self._background:set_color(color)
	end
end

-- Lines 471-478
function RaidGUIPanel:highlight_on()
end

-- Lines 480-484
function RaidGUIPanel:highlight_off()
end

-- Lines 486-488
function RaidGUIPanel:show()
	self._engine_panel:show()
end

-- Lines 492-494
function RaidGUIPanel:hide()
	self._engine_panel:hide()
end

-- Lines 496-498
function RaidGUIPanel:tree_visible()
	return self._engine_panel:tree_visible()
end

-- Lines 500-502
function RaidGUIPanel:set_visible(flag)
	return self._engine_panel:set_visible(flag)
end

-- Lines 504-512
function RaidGUIPanel:visible()
	if self._engine_panel.alive then
		return self._engine_panel.alive and alive(self._engine_panel) and self._engine_panel:visible()
	else
		return self._engine_panel:visible()
	end
end

-- Lines 520-524
function RaidGUIPanel:text(params)
	params.font = tweak_data.gui:get_font_path(params.font, params.font_size)

	return self._engine_panel:text(params)
end

-- Lines 527-529
function RaidGUIPanel:rect(params)
	return self._engine_panel:rect(params)
end

-- Lines 532-534
function RaidGUIPanel:bitmap(params)
	return self._engine_panel:bitmap(params)
end

-- Lines 537-539
function RaidGUIPanel:multi_bitmap(params)
	return self._engine_panel:multi_bitmap(params)
end

-- Lines 542-544
function RaidGUIPanel:gradient(params)
	return self._engine_panel:gradient(params)
end

-- Lines 547-549
function RaidGUIPanel:polyline(params)
	return self._engine_panel:polyline(params)
end

-- Lines 552-554
function RaidGUIPanel:polygon(params)
	return self._engine_panel:polygon(params)
end

-- Lines 557-561
function RaidGUIPanel:video(params)
	local control = RaidGUIControlVideo:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 564-566
function RaidGUIPanel:unit(params)
	return self._engine_panel:unit(params)
end

-- Lines 571-577
function RaidGUIPanel:panel(params, dont_create_panel)
	local control = RaidGUIPanel:new(self, params)

	if not dont_create_panel then
		self:_add_control(control)
	end

	return control
end

-- Lines 582-588
function RaidGUIPanel:label(params)
	params.font = tweak_data.gui:get_font_path(params.font, params.font_size)
	local control = RaidGUIControlLabel:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 590-594
function RaidGUIPanel:label_title(params)
	local control = RaidGUIControlLabelTitle:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 596-600
function RaidGUIPanel:label_subtitle(params)
	local control = RaidGUIControlLabelSubtitle:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 602-606
function RaidGUIPanel:label_named_value(params)
	local control = RaidGUIControlLabelNamedValue:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 608-612
function RaidGUIPanel:label_named_value_with_delta(params)
	local control = RaidGUIControlLabelNamedValueWithDelta:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 614-618
function RaidGUIPanel:button(params)
	local control = RaidGUIControlButton:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 620-624
function RaidGUIPanel:small_button(params)
	local control = RaidGUIControlButtonSmall:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 626-630
function RaidGUIPanel:short_primary_button(params)
	local control = RaidGUIControlButtonShortPrimary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 632-636
function RaidGUIPanel:short_primary_gold_button(params)
	local control = RaidGUIControlButtonShortPrimaryGold:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 638-642
function RaidGUIPanel:short_primary_button_disabled(params)
	local control = RaidGUIControlButtonShortPrimaryDisabled:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 644-648
function RaidGUIPanel:short_secondary_button(params)
	local control = RaidGUIControlButtonShortSecondary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 650-654
function RaidGUIPanel:short_tertiary_button(params)
	local control = RaidGUIControlButtonShortTertiary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 656-660
function RaidGUIPanel:long_primary_button(params)
	local control = RaidGUIControlButtonLongPrimary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 662-666
function RaidGUIPanel:long_primary_button_disabled(params)
	local control = RaidGUIControlButtonLongPrimaryDisabled:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 668-672
function RaidGUIPanel:long_secondary_button(params)
	local control = RaidGUIControlButtonLongSecondary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 674-678
function RaidGUIPanel:long_tertiary_button(params)
	local control = RaidGUIControlButtonLongTertiary:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 680-684
function RaidGUIPanel:info_button(params)
	local control = RaidGUIControlButtonSubtitle:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 686-690
function RaidGUIPanel:button_weapon_skill(params)
	local control = RaidGUIControlButtonWeaponSkill:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 692-696
function RaidGUIPanel:toggle_button(params)
	local control = RaidGUIControlButtonToggle:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 698-702
function RaidGUIPanel:switch_button(params)
	local control = RaidGUIControlButtonSwitch:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 704-708
function RaidGUIPanel:breadcrumb(params)
	local control = RaidGUIControlBreadcrumb:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 710-714
function RaidGUIPanel:image(params)
	local control = RaidGUIControlImage:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 716-720
function RaidGUIPanel:info_icon(params)
	local control = RaidGUIControlInfoIcon:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 722-726
function RaidGUIPanel:three_cut_bitmap(params)
	local control = RaidGUIControlThreeCutBitmap:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 728-732
function RaidGUIPanel:image_button(params)
	local control = RaidGUIControlImageButton:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 734-738
function RaidGUIPanel:navigation_button(params)
	local control = RaidGUIControlNavigationButton:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 740-744
function RaidGUIPanel:animated_bitmap(params)
	local control = RaidGUIControlAnimatedBitmap:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 746-750
function RaidGUIPanel:list(params)
	local control = RaidGUIControlList:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 752-756
function RaidGUIPanel:list_active(params)
	local control = RaidGUIControlListActive:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 758-762
function RaidGUIPanel:stepper(params)
	local control = RaidGUIControlStepper:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 764-768
function RaidGUIPanel:stepper_simple(params)
	local control = RaidGUIControlStepperSimple:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 770-774
function RaidGUIPanel:slider(params)
	local control = RaidGUIControlSlider:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 777-781
function RaidGUIPanel:slider_simple(params)
	local control = RaidGUIControlSliderSimple:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 784-788
function RaidGUIPanel:table(params)
	local control = RaidGUIControlTable:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 790-794
function RaidGUIPanel:tabs(params)
	local control = RaidGUIControlTabs:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 796-800
function RaidGUIPanel:rotate_unit(params)
	local control = RaidGUIControlRotateUnit:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 803-807
function RaidGUIPanel:progress_bar(params)
	local control = RaidGUIControlProgressBar:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 809-813
function RaidGUIPanel:progress_bar_simple(params)
	local control = RaidGUIControlProgressBarSimple:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 815-819
function RaidGUIPanel:branching_progress_bar(params)
	local control = RaidGUIControlBranchingProgressBar:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 821-825
function RaidGUIPanel:keybind(params)
	local control = RaidGuiControlKeyBind:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 827-831
function RaidGUIPanel:grid(params)
	local control = RaidGUIControlGrid:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 833-837
function RaidGUIPanel:grid_active(params)
	local control = RaidGUIControlGridActive:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 839-843
function RaidGUIPanel:paged_grid(params)
	local control = RaidGUIControlPagedGrid:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 845-849
function RaidGUIPanel:scroll_grid(params)
	local control = RaidGUIControlScrollGrid:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 851-855
function RaidGUIPanel:paged_grid_character_customization(params)
	local control = RaidGUIControlPagedGridCharacterCustomization:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 857-861
function RaidGUIPanel:suggested_cards_grid(params)
	local control = RaidGUIControlSuggestedCards:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 863-867
function RaidGUIPanel:suggested_cards_grid_large(params)
	local control = RaidGUIControlSuggestedCardsLarge:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 869-873
function RaidGUIPanel:input_field(params)
	local control = RaidGUIControlInputField:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 875-879
function RaidGUIPanel:scrollable_area(params)
	local control = RaidGUIControlScrollableArea:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 881-885
function RaidGUIPanel:scrollbar(params)
	local control = RaidGUIControlScrollbar:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 887-891
function RaidGUIPanel:legend(params)
	local control = RaidGUIControlLegend:new(self, params)

	self:_add_control(control)

	return control
end

-- Lines 893-897
function RaidGUIPanel:create_custom_control(control_class, params, ...)
	local control = control_class:new(self, params, ...)

	self:_add_control(control)

	return control
end

-- Lines 902-914
function RaidGUIPanel:_add_control(control)
	local control_layer = control:layer()
	local control_index = #self._controls + 1

	for i = 1, #self._controls do
		if self._controls[i]:layer() < control_layer then
			control_index = i

			break
		end
	end

	table.insert(self._controls, control_index, control)
end

-- Lines 922-924
function RaidGUIPanel:w()
	return self._engine_panel:w()
end

-- Lines 926-928
function RaidGUIPanel:h()
	return self._engine_panel:h()
end

-- Lines 930-932
function RaidGUIPanel:animate(params)
	self._engine_panel:animate(params)
end

-- Lines 934-936
function RaidGUIPanel:stop()
	self._engine_panel:stop()
end

-- Lines 938-940
function RaidGUIPanel:x()
	return self._engine_panel:x()
end

-- Lines 942-944
function RaidGUIPanel:y()
	return self._engine_panel:y()
end

-- Lines 946-948
function RaidGUIPanel:world_x()
	return self._engine_panel:world_x()
end

-- Lines 950-952
function RaidGUIPanel:world_y()
	return self._engine_panel:world_y()
end

-- Lines 954-956
function RaidGUIPanel:size()
	return self._engine_panel:size()
end

-- Lines 958-960
function RaidGUIPanel:set_debug(flag)
	return self._engine_panel:set_debug(flag)
end

-- Lines 962-964
function RaidGUIPanel:left()
	return self._engine_panel:left()
end

-- Lines 966-968
function RaidGUIPanel:right()
	return self._engine_panel:right()
end

-- Lines 970-972
function RaidGUIPanel:top()
	return self._engine_panel:top()
end

-- Lines 974-976
function RaidGUIPanel:world_top()
	return self._engine_panel:world_top()
end

-- Lines 978-980
function RaidGUIPanel:bottom()
	return self._engine_panel:bottom()
end

-- Lines 982-984
function RaidGUIPanel:world_bottom()
	return self._engine_panel:world_bottom()
end

-- Lines 986-988
function RaidGUIPanel:set_center(x, y)
	return self._engine_panel:set_center(x, y)
end

-- Lines 990-992
function RaidGUIPanel:set_center_x(x)
	return self._engine_panel:set_center_x(x)
end

-- Lines 994-996
function RaidGUIPanel:set_center_y(y)
	return self._engine_panel:set_center_y(y)
end

-- Lines 998-1000
function RaidGUIPanel:set_right(right)
	return self._engine_panel:set_right(right)
end

-- Lines 1002-1004
function RaidGUIPanel:set_left(left)
	return self._engine_panel:set_left(left)
end

-- Lines 1006-1008
function RaidGUIPanel:set_x(x)
	return self._engine_panel:set_x(x)
end

-- Lines 1010-1012
function RaidGUIPanel:set_y(y)
	return self._engine_panel:set_y(y)
end

-- Lines 1014-1016
function RaidGUIPanel:set_size(w, h)
	self._engine_panel:set_size(w, h)
end

-- Lines 1018-1020
function RaidGUIPanel:set_w(w)
	return self._engine_panel:set_w(w)
end

-- Lines 1022-1024
function RaidGUIPanel:set_h(h)
	return self._engine_panel:set_h(h)
end

-- Lines 1026-1028
function RaidGUIPanel:alpha()
	return self._engine_panel:alpha()
end

-- Lines 1030-1032
function RaidGUIPanel:set_alpha(alpha)
	self._engine_panel:set_alpha(alpha)
end

-- Lines 1034-1050
function RaidGUIPanel:set_rotation(angle)
	for i, element in pairs(self._engine_panel:children()) do
		if element.rotate then
			element:set_center(self:get_position_after_rotation(element, angle))
			element:set_rotation(angle)
		end
	end

	for i, control in pairs(self._controls) do
		control:set_center(self:get_position_after_rotation(control, angle))
		control:set_rotation(angle)
	end

	self._rotation = angle
end

-- Lines 1052-1056
function RaidGUIPanel:rotate(angle)
	local current_rotation = self:rotation()

	self:set_rotation(current_rotation + angle)
end

-- Lines 1058-1060
function RaidGUIPanel:rotation()
	return self._rotation or 0
end

-- Lines 1062-1073
function RaidGUIPanel:get_position_after_rotation(element, angle)
	local center_x = self:w() / 2
	local center_y = self:h() / 2
	local old_angle = element:rotation()
	local angle_difference = angle - old_angle
	local new_x = center_x + (element:center_x() - center_x) * math.cos(angle_difference) - (element:center_y() - center_y) * math.sin(angle_difference)
	local new_y = center_y + (element:center_x() - center_x) * math.sin(angle_difference) + (element:center_y() - center_y) * math.cos(angle_difference)

	return new_x, new_y
end

-- Lines 1075-1080
function RaidGUIPanel:engine_panel_alive()
	if alive(self._engine_panel) then
		return true
	end

	return false
end

-- Lines 1083-1084
function RaidGUIPanel:scrollable_area_post_setup(params)
end
