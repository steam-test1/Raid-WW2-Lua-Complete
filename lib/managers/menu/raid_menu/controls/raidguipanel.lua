RaidGUIPanel = RaidGUIPanel or class()
RaidGUIPanel.ID = 1
RaidGUIPanel.TYPE = "raid_gui_panel"

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

function RaidGUIPanel:get_controls()
	return self._controls
end

function RaidGUIPanel:get_engine_panel()
	return self._engine_panel
end

function RaidGUIPanel:center()
	return self._engine_panel:center()
end

function RaidGUIPanel:center_x()
	return self._engine_panel:center_x()
end

function RaidGUIPanel:center_y()
	return self._engine_panel:center_y()
end

function RaidGUIPanel:set_top(value)
	return self._engine_panel:set_top(value)
end

function RaidGUIPanel:set_bottom(value)
	return self._engine_panel:set_bottom(value)
end

function RaidGUIPanel:get_panel()
	return self
end

function RaidGUIPanel:layer()
	return self._engine_panel:layer()
end

function RaidGUIPanel:close()
	for _, control in ipairs(self._controls) do
		control:close()
	end

	self._controls = {}

	self._engine_panel:clear()
end

function RaidGUIPanel:clear()
	for _, control in ipairs(self._controls) do
		control:close()
	end

	self._controls = {}

	self._engine_panel:clear()
end

function RaidGUIPanel:child(control_name)
	if alive(self._engine_panel) then
		return self._engine_panel:child(control_name)
	else
		return nil
	end
end

function RaidGUIPanel:children()
	return self._engine_panel:children()
end

function RaidGUIPanel:parent()
	return self._parent
end

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

function RaidGUIPanel:fit_content_height()
	local max_y = self:get_max_control_y()

	self._engine_panel:set_h(max_y)
end

function RaidGUIPanel:key_press(callback)
	if callback then
		self._engine_panel:key_press(callback)
	end
end

function RaidGUIPanel:key_release(callback)
	if callback then
		self._engine_panel:key_release(callback)
	end
end

function RaidGUIPanel:enter_text(callback)
	if callback then
		self._engine_panel:enter_text(callback)
	end
end

function RaidGUIPanel:inside(x, y)
	return self._engine_panel:inside(x, y) and self._engine_panel:tree_visible()
end

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

function RaidGUIPanel:mouse_pressed(o, button, x, y)
	for _, control in ipairs(self._controls) do
		local handled = control:mouse_pressed(o, button, x, y)

		if handled then
			return true
		end
	end

	return false
end

function RaidGUIPanel:mouse_clicked(o, button, x, y)
	for _, control in ipairs(self._controls) do
		local handled = control:mouse_clicked(o, button, x, y)

		if handled then
			return true
		end
	end

	return false
end

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

function RaidGUIPanel:back_pressed()
	managers.raid_menu:on_escape()
end

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

function RaidGUIPanel:remove_background()
	self:remove(self._background)
end

function RaidGUIPanel:set_background_color(color)
	if self._background then
		self._background:set_color(color)
	end
end

function RaidGUIPanel:highlight_on()
end

function RaidGUIPanel:highlight_off()
end

function RaidGUIPanel:show()
	self._engine_panel:show()
end

function RaidGUIPanel:hide()
	self._engine_panel:hide()
end

function RaidGUIPanel:tree_visible()
	return self._engine_panel:tree_visible()
end

function RaidGUIPanel:set_visible(flag)
	return self._engine_panel:set_visible(flag)
end

function RaidGUIPanel:visible()
	if self._engine_panel.alive then
		return self._engine_panel.alive and alive(self._engine_panel) and self._engine_panel:visible()
	else
		return self._engine_panel:visible()
	end
end

function RaidGUIPanel:text(params)
	params.font = tweak_data.gui:get_font_path(params.font, params.font_size)

	return self._engine_panel:text(params)
end

function RaidGUIPanel:rect(params)
	return self._engine_panel:rect(params)
end

function RaidGUIPanel:bitmap(params)
	return self._engine_panel:bitmap(params)
end

function RaidGUIPanel:multi_bitmap(params)
	return self._engine_panel:multi_bitmap(params)
end

function RaidGUIPanel:gradient(params)
	return self._engine_panel:gradient(params)
end

function RaidGUIPanel:polyline(params)
	return self._engine_panel:polyline(params)
end

function RaidGUIPanel:polygon(params)
	return self._engine_panel:polygon(params)
end

function RaidGUIPanel:video(params)
	local control = RaidGUIControlVideo:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:unit(params)
	return self._engine_panel:unit(params)
end

function RaidGUIPanel:panel(params, dont_create_panel)
	local control = RaidGUIPanel:new(self, params)

	if not dont_create_panel then
		self:_add_control(control)
	end

	return control
end

function RaidGUIPanel:label(params)
	params.font = tweak_data.gui:get_font_path(params.font, params.font_size)
	local control = RaidGUIControlLabel:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:label_title(params)
	local control = RaidGUIControlLabelTitle:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:label_subtitle(params)
	local control = RaidGUIControlLabelSubtitle:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:label_named_value(params)
	local control = RaidGUIControlLabelNamedValue:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:label_named_value_with_delta(params)
	local control = RaidGUIControlLabelNamedValueWithDelta:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:button(params)
	local control = RaidGUIControlButton:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:small_button(params)
	local control = RaidGUIControlButtonSmall:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:short_primary_button(params)
	local control = RaidGUIControlButtonShortPrimary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:short_primary_gold_button(params)
	local control = RaidGUIControlButtonShortPrimaryGold:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:short_primary_button_disabled(params)
	local control = RaidGUIControlButtonShortPrimaryDisabled:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:short_secondary_button(params)
	local control = RaidGUIControlButtonShortSecondary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:short_tertiary_button(params)
	local control = RaidGUIControlButtonShortTertiary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:long_primary_button(params)
	local control = RaidGUIControlButtonLongPrimary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:long_primary_button_disabled(params)
	local control = RaidGUIControlButtonLongPrimaryDisabled:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:long_secondary_button(params)
	local control = RaidGUIControlButtonLongSecondary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:long_tertiary_button(params)
	local control = RaidGUIControlButtonLongTertiary:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:info_button(params)
	local control = RaidGUIControlButtonSubtitle:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:button_weapon_skill(params)
	local control = RaidGUIControlButtonWeaponSkill:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:toggle_button(params)
	local control = RaidGUIControlButtonToggle:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:switch_button(params)
	local control = RaidGUIControlButtonSwitch:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:breadcrumb(params)
	local control = RaidGUIControlBreadcrumb:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:image(params)
	local control = RaidGUIControlImage:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:info_icon(params)
	local control = RaidGUIControlInfoIcon:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:three_cut_bitmap(params)
	local control = RaidGUIControlThreeCutBitmap:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:image_button(params)
	local control = RaidGUIControlImageButton:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:navigation_button(params)
	local control = RaidGUIControlNavigationButton:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:animated_bitmap(params)
	local control = RaidGUIControlAnimatedBitmap:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:list(params)
	local control = RaidGUIControlList:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:list_active(params)
	local control = RaidGUIControlListActive:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:stepper(params)
	local control = RaidGUIControlStepper:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:stepper_simple(params)
	local control = RaidGUIControlStepperSimple:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:slider(params)
	local control = RaidGUIControlSlider:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:slider_simple(params)
	local control = RaidGUIControlSliderSimple:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:table(params)
	local control = RaidGUIControlTable:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:tabs(params)
	local control = RaidGUIControlTabs:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:rotate_unit(params)
	local control = RaidGUIControlRotateUnit:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:progress_bar(params)
	local control = RaidGUIControlProgressBar:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:progress_bar_simple(params)
	local control = RaidGUIControlProgressBarSimple:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:branching_progress_bar(params)
	local control = RaidGUIControlBranchingProgressBar:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:keybind(params)
	local control = RaidGuiControlKeyBind:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:grid(params)
	local control = RaidGUIControlGrid:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:grid_active(params)
	local control = RaidGUIControlGridActive:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:paged_grid(params)
	local control = RaidGUIControlPagedGrid:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:scroll_grid(params)
	local control = RaidGUIControlScrollGrid:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:paged_grid_character_customization(params)
	local control = RaidGUIControlPagedGridCharacterCustomization:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:suggested_cards_grid(params)
	local control = RaidGUIControlSuggestedCards:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:suggested_cards_grid_large(params)
	local control = RaidGUIControlSuggestedCardsLarge:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:input_field(params)
	local control = RaidGUIControlInputField:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:scrollable_area(params)
	local control = RaidGUIControlScrollableArea:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:scrollbar(params)
	local control = RaidGUIControlScrollbar:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:legend(params)
	local control = RaidGUIControlLegend:new(self, params)

	self:_add_control(control)

	return control
end

function RaidGUIPanel:create_custom_control(control_class, params, ...)
	local control = control_class:new(self, params, ...)

	self:_add_control(control)

	return control
end

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

function RaidGUIPanel:w()
	return self._engine_panel:w()
end

function RaidGUIPanel:h()
	return self._engine_panel:h()
end

function RaidGUIPanel:animate(params)
	self._engine_panel:animate(params)
end

function RaidGUIPanel:stop()
	self._engine_panel:stop()
end

function RaidGUIPanel:x()
	return self._engine_panel:x()
end

function RaidGUIPanel:y()
	return self._engine_panel:y()
end

function RaidGUIPanel:world_x()
	return self._engine_panel:world_x()
end

function RaidGUIPanel:world_y()
	return self._engine_panel:world_y()
end

function RaidGUIPanel:size()
	return self._engine_panel:size()
end

function RaidGUIPanel:set_debug(flag)
	return self._engine_panel:set_debug(flag)
end

function RaidGUIPanel:left()
	return self._engine_panel:left()
end

function RaidGUIPanel:right()
	return self._engine_panel:right()
end

function RaidGUIPanel:top()
	return self._engine_panel:top()
end

function RaidGUIPanel:world_top()
	return self._engine_panel:world_top()
end

function RaidGUIPanel:bottom()
	return self._engine_panel:bottom()
end

function RaidGUIPanel:world_bottom()
	return self._engine_panel:world_bottom()
end

function RaidGUIPanel:set_center(x, y)
	return self._engine_panel:set_center(x, y)
end

function RaidGUIPanel:set_center_x(x)
	return self._engine_panel:set_center_x(x)
end

function RaidGUIPanel:set_center_y(y)
	return self._engine_panel:set_center_y(y)
end

function RaidGUIPanel:set_right(right)
	return self._engine_panel:set_right(right)
end

function RaidGUIPanel:set_left(left)
	return self._engine_panel:set_left(left)
end

function RaidGUIPanel:set_x(x)
	return self._engine_panel:set_x(x)
end

function RaidGUIPanel:set_y(y)
	return self._engine_panel:set_y(y)
end

function RaidGUIPanel:set_size(w, h)
	self._engine_panel:set_size(w, h)
end

function RaidGUIPanel:set_w(w)
	return self._engine_panel:set_w(w)
end

function RaidGUIPanel:set_h(h)
	return self._engine_panel:set_h(h)
end

function RaidGUIPanel:alpha()
	return self._engine_panel:alpha()
end

function RaidGUIPanel:set_alpha(alpha)
	self._engine_panel:set_alpha(alpha)
end

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

function RaidGUIPanel:rotate(angle)
	local current_rotation = self:rotation()

	self:set_rotation(current_rotation + angle)
end

function RaidGUIPanel:rotation()
	return self._rotation or 0
end

function RaidGUIPanel:get_position_after_rotation(element, angle)
	local center_x = self:w() / 2
	local center_y = self:h() / 2
	local old_angle = element:rotation()
	local angle_difference = angle - old_angle
	local new_x = center_x + (element:center_x() - center_x) * math.cos(angle_difference) - (element:center_y() - center_y) * math.sin(angle_difference)
	local new_y = center_y + (element:center_x() - center_x) * math.sin(angle_difference) + (element:center_y() - center_y) * math.cos(angle_difference)

	return new_x, new_y
end

function RaidGUIPanel:engine_panel_alive()
	if alive(self._engine_panel) then
		return true
	end

	return false
end

function RaidGUIPanel:scrollable_area_post_setup(params)
end
