core:import("CoreMenuNodeGui")

MenuNodeGui = MenuNodeGui or class(CoreMenuNodeGui.NodeGui)

function MenuNodeGui:init(node, layer, parameters)
	self._align_line_proportions = node:parameters().align_line_proportions or 0.65
	self._align_line_padding = 10
	self._use_info_rect = node:parameters().use_info_rect or node:parameters().use_info_rect == nil and true
	self._stencil_align = node:parameters().stencil_align or "right"
	self._stencil_align_percent = node:parameters().stencil_align_percent or 0
	self._stencil_image = node:parameters().stencil_image
	self._scene_state = node:parameters().scene_state
	self._no_menu_wrapper = true
	self._is_loadout = node:parameters().is_loadout
	self._align = node:parameters().align or "mid"
	self._bg_visible = node:parameters().hide_bg
	self._bg_visible = self._bg_visible == nil
	self._bg_area = node:parameters().area_bg
	self._bg_area = not self._bg_area and "full" or self._bg_area
	self.row_item_color = tweak_data.screen_colors.button_stage_3
	self.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
	self.row_item_disabled_text_color = tweak_data.menu.default_disabled_text_color
	self.item_panel_h = node:parameters().item_panel_h

	MenuNodeGui.super.init(self, node, layer, parameters)

	if node:parameters().no_item_parent then
		self._item_panel_parent:set_visible(false)
	end
end

function MenuNodeGui:align_line_padding()
	return self._align_line_padding
end

function MenuNodeGui:_mid_align()
	local safe_rect = self:_scaled_size()

	return safe_rect.width * self._align_line_proportions
end

function MenuNodeGui:_right_align(align_line_proportions)
	local safe_rect = self:_scaled_size()

	return safe_rect.width * (align_line_proportions or self._align_line_proportions) + self._align_line_padding
end

function MenuNodeGui:_left_align(align_line_proportions)
	return 50
end

function MenuNodeGui:_setup_item_panel_parent(safe_rect, shape)
	local res = RenderSettings.resolution
	shape = shape or {}
	local x = shape.x or safe_rect.x
	local y = shape.y or safe_rect.y + CoreMenuRenderer.Renderer.border_height
	local w = shape.w or safe_rect.width
	local h = safe_rect.height

	self._item_panel_parent:set_shape(x, y, w, h)
	self._item_panel_parent:set_y(0)
	self._item_panel_parent:set_h(h)
end

function MenuNodeGui:_setup_item_panel(safe_rect, res)
	if self._align == "mid" and false then
		self._item_panel_y = self._item_panel_y or {
			first = self._item_panel_parent:h() / 2,
			current = self._item_panel_parent:h() / 2
		}

		if self:_item_panel_height() < self._item_panel_parent:h() then
			self._item_panel_y.target = self._item_panel_parent:h() / 2
		end

		self.item_panel:set_shape(0, self.item_panel:y(), safe_rect.width, self:_item_panel_height())

		if not self._item_panel_y then
			self.item_panel:set_center_y(self._item_panel_parent:h() / 2)
		elseif self._item_panel_y.first then
			self.item_panel:set_center_y(self._item_panel_parent:h() / 2)

			self._item_panel_y.first = nil
		end
	else
		local coordX = safe_rect.x
		local coordY = self._item_panel_parent:h() - self:_item_panel_height()
		local width = safe_rect.width
		local height = self:_item_panel_height()
		local y = self:_item_panel_height() < self._item_panel_parent:h() and 0 or self.item_panel:y()

		self.item_panel:set_shape(coordX, coordY, width, height)
	end

	self.item_panel:set_w(safe_rect.width)

	local active_menu = managers.menu:active_menu().id

	if active_menu == "start_menu" or active_menu == "pause_menu" then
		local bg_width = self:_get_node_background_width()

		self.item_panel:rect({
			alpha = 0,
			valign = "scale",
			name = "bg_color",
			halign = "scale",
			color = Color.black,
			width = bg_width
		})
	end
end

function MenuNodeGui:_create_menu_item(row_item)
	local safe_rect = self:_scaled_size()
	local align_x = safe_rect.width * self._align_line_proportions

	if row_item.gui_panel then
		self.item_panel:remove(row_item.gui_panel)
	end

	if alive(row_item.gui_pd2_panel) then
		row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
	end

	if row_item.item:parameters().back then
		row_item.item:parameters().back = false
		row_item.item:parameters().pd2_corner = true
	end

	if row_item.item:parameters().back then
		row_item.gui_panel = self._item_panel_parent:panel({
			h = 30,
			w = 30,
			layer = self.layers.items
		})
	elseif row_item.item:parameters().pd2_corner then
		row_item.gui_panel = self._item_panel_parent:panel({
			h = 3,
			w = 3,
			layer = self.layers.items
		})
		row_item.gui_pd2_panel = self.ws:panel():panel({
			layer = self.layers.items
		})
		local row_item_panel = managers.menu:is_pc_controller() and row_item.gui_pd2_panel or row_item.gui_panel
		row_item.gui_text = row_item_panel:bitmap({
			texture = "ui/main_menu/textures/debug_menu_icons",
			texture_rect = {
				448,
				64,
				64,
				64
			}
		})

		if managers.menu:is_pc_controller() then
			row_item.gui_text:set_rightbottom(row_item.gui_pd2_panel:w(), row_item.gui_pd2_panel:h())
		else
			row_item.gui_text:set_rotation(360)
			row_item.gui_text:set_right(row_item.gui_pd2_panel:w())
		end
	elseif not row_item.item:setup_gui(self, row_item) then
		local cot_align = row_item.align == "right" and "left" or row_item.align == "left" and "right" or row_item.align
		row_item.gui_panel = self:_text_item_part(row_item, self.item_panel, self:_left_align(), "left")

		self:_align_normal(row_item)

		row_item.background_image = managers.menu:create_menu_item_background(self.item_panel, row_item.gui_panel:x() - managers.menu.MENU_ITEM_LEFT_PADDING, row_item.gui_panel:y(), row_item.gui_panel:w(), self.layers.items - 1)
	end
end

function MenuNodeGui:_key_press(o, key, input_id, item, no_add)
	if managers.system_menu:is_active() then
		return
	end

	if self._skip_first_activate_key then
		self._skip_first_activate_key = false

		if input_id == "mouse" then
			if key == Idstring("0") then
				return
			end
		elseif input_id == "keyboard" and key == Idstring("enter") then
			return
		end
	end

	local row_item = self:row_item(item)

	if key == Idstring("esc") then
		self:_end_customize_controller(o, item)

		return
	end

	local key_name = "" .. (input_id == "mouse" and Input:mouse():button_name_str(key) or Input:keyboard():button_name_str(key))

	if not no_add and input_id == "mouse" then
		key_name = "mouse " .. key_name or key_name
	end

	local forbidden_btns = {
		"esc",
		"tab",
		"num abnt c1",
		"num abnt c2",
		"@",
		"ax",
		"convert",
		"kana",
		"kanji",
		"no convert",
		"oem 102",
		"stop",
		"unlabeled",
		"yen",
		"mouse 8",
		"mouse 9",
		""
	}

	for _, btn in ipairs(forbidden_btns) do
		if Idstring(btn) == key then
			managers.menu:show_key_binding_forbidden({
				KEY = key_name
			})
			self:_end_customize_controller(o, item)

			return
		end
	end

	local button_category = RaidMenuOptionsControlsKeybinds.CONTROLS_INFO[item:parameters().button].category
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(RaidMenuOptionsControlsKeybinds.controls_info_by_category(button_category)) do
		local connection = connections[name]

		if connection._btn_connections then
			for name, btn_connection in pairs(connection._btn_connections) do
				if btn_connection.name == key_name and item:parameters().binding ~= btn_connection.name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(RaidMenuOptionsControlsKeybinds.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)

					return
				end
			end
		else
			for _, b_name in ipairs(connection:get_input_name_list()) do
				if tostring(b_name) == key_name and item:parameters().binding ~= b_name then
					managers.menu:show_key_binding_collision({
						KEY = key_name,
						MAPPED = managers.localization:text(RaidMenuOptionsControlsKeybinds.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, item)

					return
				end
			end
		end
	end

	if item:parameters().axis then
		connections[item:parameters().axis]._btn_connections[item:parameters().button].name = key_name

		managers.controller:set_user_mod(item:parameters().connection_name, {
			axis = item:parameters().axis,
			button = item:parameters().button,
			connection = key_name
		})

		item:parameters().binding = key_name
	else
		connections[item:parameters().button]:set_controller_id(input_id)
		connections[item:parameters().button]:set_input_name_list({
			key_name
		})
		managers.controller:set_user_mod(item:parameters().connection_name, {
			button = item:parameters().button,
			connection = key_name,
			controller_id = input_id
		})

		item:parameters().binding = key_name
	end

	managers.controller:rebind_connections()
	self:_end_customize_controller(o, item)
end

function MenuNodeGui:_end_customize_controller(o, item)
	self.ws:disconnect_keyboard()
	self.ws:disconnect_mouse()
	o:key_press(nil)
	o:key_release(nil)
	o:mouse_click(nil)
	o:mouse_release(nil)
	Input:mouse():remove_trigger(self._mouse_wheel_up_trigger)
	Input:mouse():remove_trigger(self._mouse_wheel_down_trigger)
	setup:add_end_frame_clbk(function ()
		self._listening_to_input = false
	end)
	item:dirty()
end

function MenuNodeGui:_cb_chat(row_item)
	local chat_text = row_item.chat_input:child("text"):text()

	if chat_text and tostring(chat_text) ~= "" then
		local name = managers.network:session():local_peer():name()
		local say = name .. ": " .. tostring(chat_text)

		self:_say(say, row_item, managers.network:session():local_peer():id())
		managers.network:session():send_to_peers("sync_chat_message", say)
	end

	self._chatbox_typing = false

	row_item.chat_input:child("text"):set_text("")
	row_item.chat_input:child("text"):set_selection(0, 0)
end

function MenuNodeGui:sync_say(message, row_item, id)
	self:_say(message, row_item, id)
end

function MenuNodeGui:_say(message, row_item, id)
	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:post_event("prompt_exit")
	end

	local s = row_item.chat_output:script()
	local i = utf8.find_char(message, ":")

	s.box_print(message, tweak_data.chat_colors[id], i)
end

function MenuNodeGui:_cb_unlock()
end

function MenuNodeGui:_cb_lock()
end

function MenuNodeGui:_text_item_part(row_item, panel, align_x, text_align)
	local new_text = panel:text({
		halign = "left",
		kern = 2,
		y = 0,
		vertical = "center",
		name = "row_item_gui_panel_text_item_part",
		font_size = tweak_data.gui.font_sizes.size_20,
		x = align_x,
		w = panel:w(),
		align = text_align or row_item.align or "left",
		font = tweak_data.gui.font_paths.din_compressed[20],
		color = row_item.item:parameters().color or row_item.color,
		layer = self.layers.items,
		blend_mode = self.row_item_blend_mode or "normal",
		text = row_item.to_upper and utf8.to_upper(row_item.text) or row_item.text,
		render_template = Idstring("VertexColorTextured")
	})
	local color_ranges = row_item.color_ranges

	return new_text
end

function MenuNodeGui:scroll_update(dt)
	local scrolled = MenuNodeGui.super.scroll_update(self, dt)

	self:update_item_icon_visibility()

	return scrolled
end

function MenuNodeGui:reload_item(item)
	local type = item:type()
	local row_item = self:row_item(item)

	if row_item then
		row_item.color = item:enabled() and (row_item.highlighted and (row_item.hightlight_color or self.row_item_hightlight_color) or row_item.row_item_color or self.row_item_color) or row_item.disabled_color
	end

	if not item:reload(row_item, self) then
		if type == "expand" then
			self:_reload_expand(item)
		else
			MenuNodeGui.super.reload_item(self, item)
		end
	end
end

function MenuNodeGui:_collaps_others(my_item)
	for _, row_item in ipairs(self.row_items) do
		local item = row_item.item
		local type = item:type()

		if my_item ~= item and type == "expand" and not item:is_parent_to_item(my_item) and item:expanded() then
			item:toggle()
			self:_reload_expand(item)
		end
	end
end

function MenuNodeGui:_reload_expand(item)
	local row_item = self:row_item(item)

	item:reload(row_item, self)

	if item:expanded() then
		self:_collaps_others(item)
	end

	local need_repos = false

	if item:can_expand() then
		if item:expanded() then
			need_repos = item:expand(self, row_item)
		else
			need_repos = item:collaps(self, row_item)
		end
	end

	if need_repos then
		self:need_repositioning()
		row_item.node:select_item(item:name())
		self:_reposition_items(row_item)
	end
end

function MenuNodeGui:_delete_row_item(item)
	for i, row_item in ipairs(self.row_items) do
		if row_item.item == item then
			if alive(row_item.gui_pd2_panel) then
				row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
			end

			break
		end
	end

	MenuNodeGui.super._delete_row_item(self, item)
end

function MenuNodeGui:_clear_gui()
	for i, row_item in ipairs(self.row_items) do
		if alive(row_item.gui_pd2_panel) then
			row_item.gui_pd2_panel:parent():remove(row_item.gui_pd2_panel)
		end
	end

	MenuNodeGui.super._clear_gui(self)
end

function MenuNodeGui:need_repositioning()
	self:_setup_size()
	self:scroll_setup()
	self:_set_item_positions()
end

function MenuNodeGui:update_item_icon_visibility()
	for _, row_item in pairs(self.row_items) do
		if alive(row_item.icon) then
			row_item.icon:set_visible(row_item.item:icon_visible() and self._item_panel_parent:world_y() <= row_item.icon:world_y() and row_item.icon:world_bottom() <= self._item_panel_parent:world_bottom())
		end
	end
end

function MenuNodeGui:_highlight_row_item(row_item, mouse_over)
	if row_item then
		row_item.highlighted = true
		local active_menu = managers.menu:active_menu()
		row_item.color = row_item.item:enabled() and (row_item.hightlight_color or self.row_item_hightlight_color) or row_item.disabled_color

		if row_item.type == "NOTHING" then
			-- Nothing
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(true)
			row_item.arrow_unselected:set_visible(false)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(Color(1, 0.5, 0.5, 0.5))
		elseif not row_item.item:highlight_row_item(self, row_item, mouse_over) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(Idstring(tweak_data.gui.font_paths.din_compressed[20]))
			end

			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(true)
			end

			MenuNodeGui.super._highlight_row_item(self, row_item)

			if row_item.icon then
				row_item.icon:set_left(row_item.gui_panel:right())
				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end
		end
	end
end

function MenuNodeGui:_fade_row_item(row_item)
	if row_item then
		row_item.highlighted = false
		row_item.color = row_item.item:enabled() and (row_item.row_item_color or self.row_item_color) or row_item.disabled_color

		if row_item.type == "NOTHING" then
			-- Nothing
		elseif row_item.type == "column" then
			for _, gui in ipairs(row_item.gui_columns) do
				gui:set_color(row_item.color)
				gui:set_font(tweak_data.menu.pd2_medium_font_id)
			end
		elseif row_item.item:parameters().back then
			row_item.arrow_selected:set_visible(false)
			row_item.arrow_unselected:set_visible(true)
		elseif row_item.item:parameters().pd2_corner then
			row_item.gui_text:set_color(tweak_data.screen_colors.button_stage_3)
		elseif not row_item.item:fade_row_item(self, row_item) then
			if row_item.gui_panel.set_text then
				row_item.gui_panel:set_font(Idstring(tweak_data.gui.font_paths.din_compressed[20]))
			end

			if row_item.gui_info_panel then
				row_item.gui_info_panel:set_visible(false)
			end

			MenuNodeGui.super._fade_row_item(self, row_item)

			if row_item.icon then
				row_item.icon:set_left(row_item.gui_panel:right())
				row_item.icon:set_center_y(row_item.gui_panel:center_y())
				row_item.icon:set_color(row_item.gui_panel:color())
			end
		end
	end
end

function MenuNodeGui:_align_item_gui_info_panel(panel)
	panel:set_shape(self._info_bg_rect:x() + tweak_data.menu.info_padding, self._info_bg_rect:y() + tweak_data.menu.info_padding, self._info_bg_rect:w() - tweak_data.menu.info_padding * 2, self._info_bg_rect:h() - tweak_data.menu.info_padding * 2)
end

local xl_pad = 64

function MenuNodeGui:_align_info_panel(row_item)
	self:_align_item_gui_info_panel(row_item.gui_info_panel)
	row_item.help_title:set_font_size(self.font_size)
	row_item.help_title:set_shape(row_item.help_title:text_rect())
	row_item.help_title:set_position(0, 0)
	row_item.help_text:set_font_size(tweak_data.gui.font_paths.din_compressed[20])
	row_item.help_text:set_w(row_item.gui_info_panel:w())
	row_item.help_text:set_shape(row_item.help_text:text_rect())
	row_item.help_text:set_x(0)
	row_item.help_text:set_top(row_item.help_title:bottom() + tweak_data.menu.info_padding)
end

function MenuNodeGui:_align_normal(row_item)
	local safe_rect = self:_scaled_size()

	row_item.gui_panel:set_font_size(row_item.font_size or self.font_size)

	local x, y, w, h = row_item.gui_panel:text_rect()

	row_item.gui_panel:set_height(managers.menu.MENU_ITEM_HEIGHT)
	row_item.gui_panel:set_w(safe_rect.width - row_item.gui_panel:left())

	if row_item.icon then
		row_item.icon:set_left(row_item.gui_panel:right())
		row_item.icon:set_center_y(row_item.gui_panel:center_y())
		row_item.icon:set_color(row_item.gui_panel:color())
	end

	if row_item.gui_info_panel then
		self:_align_info_panel(row_item)
	end

	local node_padding = self:_get_node_padding()

	if row_item.align and row_item.align == "left" then
		local max_w = managers.menu:get_menu_item_width()

		for _, item in ipairs(row_item.node_gui.row_items or {}) do
			max_w = math.max((item.gui_panel:w() or 0) * 0.5, max_w)
		end

		row_item.gui_panel:set_left(node_padding)
		row_item.gui_panel:set_width(max_w)
	end
end

function MenuNodeGui:_update_scaled_values()
	self.font_size = tweak_data.gui.font_sizes.size_20
	self.font = tweak_data.gui.font_paths.din_compressed[20]
	self._align_line_padding = 10
end

function MenuNodeGui:resolution_changed()
	self:_update_scaled_values()

	local safe_rect = self:_scaled_size()
	local res = RenderSettings.resolution

	for _, row_item in pairs(self.row_items) do
		row_item.item:reload(row_item, self)
	end

	MenuNodeGui.super.resolution_changed(self)
end

function MenuNodeGui:set_visible(visible)
	MenuNodeGui.super.set_visible(self, visible)

	local active_menu = managers.menu:active_menu()

	if active_menu and visible and self.row_items and #self.row_items > 0 then
		for _, row_item in ipairs(self.row_items) do
			if row_item.highlighted then
				break
			end
		end
	end
end

function MenuNodeGui:close(...)
	for _, row_item in ipairs(self.row_items) do
		local item = row_item.item
		local type = item:type()

		if type == "expand" and item:expanded() then
			item:toggle()
			self:_reload_expand(item)
		end
	end

	MenuNodeGui.super.close(self, ...)
end
