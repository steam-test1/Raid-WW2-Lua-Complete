TextBoxGui = TextBoxGui or class()
TextBoxGui.PRESETS = {
	system_menu = {
		w = 600,
		h = 270
	},
	weapon_stats = {
		w = 700,
		x = 60,
		h = 270,
		bottom = 620
	}
}

-- Lines 7-14
function TextBoxGui:init(...)
	self._target_alpha = {}
	self._visible = true
	self._enabled = true
	self._minimized = false

	self:_create_text_box(...)

	self._thread = self._panel:animate(self._update, self)
end

-- Lines 16-26
function TextBoxGui._update(o, self)
	while true do
		local dt = coroutine.yield()

		if self._up_alpha then
			self._up_alpha.current = math.step(self._up_alpha.current, self._up_alpha.target, dt * 5)
		end

		if self._down_alpha then
			self._down_alpha.current = math.step(self._down_alpha.current, self._down_alpha.target, dt * 5)
		end
	end
end

-- Lines 28-34
function TextBoxGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)

	if self._background then
		self._background:set_layer(self._panel:layer() - 1)
	end
end

-- Lines 36-38
function TextBoxGui:layer()
	return self._panel:layer()
end

-- Lines 40-48
function TextBoxGui:add_background()
	if alive(self._fullscreen_ws) then
		Overlay:gui():destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end

	self._fullscreen_ws = Overlay:gui():create_screen_workspace()
	self._background = self._fullscreen_ws:panel():rect({
		name = "bg",
		alpha = 0,
		valign = "grow",
		layer = 0,
		color = Color.black,
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})
end

-- Lines 50-52
function TextBoxGui:set_centered()
	self._panel:set_center(self._ws:panel():center())
end

-- Lines 54-58
function TextBoxGui:recreate_text_box(...)
	self:close()
	self:_create_text_box(...)

	self._thread = self._panel:animate(self._update, self)
end

-- Lines 60-284
function TextBoxGui:_create_text_box(ws, title, text, content_data, config)
	self._ws = ws
	self._init_layer = self._ws:panel():layer()

	if alive(self._text_box) then
		ws:panel():remove(self._text_box)

		self._text_box = nil
	end

	self._text_box_focus_button = nil
	local scaled_size = managers.gui_data:scaled_size()
	local type = config and config.type
	local preset = type and self.PRESETS[type]
	local stats_list = content_data and content_data.stats_list
	local stats_text = content_data and content_data.stats_text
	local button_list = content_data and content_data.button_list
	local focus_button = content_data and content_data.focus_button
	local no_close_legend = config and config.no_close_legend
	local no_scroll_legend = config and config.no_scroll_legend
	self._no_scroll_legend = true
	local only_buttons = config and config.only_buttons
	local use_minimize_legend = config and config.use_minimize_legend or false
	local w = preset and preset.w or config and config.w or scaled_size.width / 2.25
	local h = preset and preset.h or config and config.h or scaled_size.height
	local x = preset and preset.x or config and config.x or 0
	local y = preset and preset.y or config and config.y or 0
	local bottom = preset and preset.bottom or config and config.bottom
	local forced_h = preset and preset.forced_h or config and config.forced_h or false
	local title_font = preset and preset.title_font or config and config.title_font or tweak_data.menu.pd2_large_font
	local title_font_size = preset and preset.title_font_size or config and config.title_font_size or 28
	local font = preset and preset.font or config and config.font or tweak_data.menu.pd2_medium_font
	local font_size = preset and preset.font_size or config and config.font_size or tweak_data.menu.pd2_medium_font_size
	local use_text_formating = preset and preset.use_text_formating or config and config.use_text_formating or false
	local text_formating_color = preset and preset.text_formating_color or config and config.text_formating_color or Color.white
	local text_formating_color_table = preset and preset.text_formating_color_table or config and config.text_formating_color_table or nil
	local is_title_outside = preset and preset.is_title_outside or config and config.is_title_outside or false
	local text_blend_mode = preset and preset.text_blend_mode or config and config.text_blend_mode or "normal"
	self._allow_moving = config and config.allow_moving or false
	local preset_or_config_y = y ~= 0
	title = title and utf8.to_upper(title)

	if text then
		-- Nothing
	end

	self.controls = {}
	self._default_button = content_data.focus_button or 1
	local main = ws:panel():panel({
		name = "text_box_gui_panel_main",
		valign = "center",
		visible = self._visible,
		x = x,
		y = y,
		w = w,
		h = h,
		layer = self._init_layer
	})
	self._panel = main
	self._panel_h = self._panel:h()
	self._panel_w = self._panel:w()
	local title_params = {
		name = "title",
		vertical = "top",
		wrap = false,
		word_wrap = false,
		align = "center",
		valign = "top",
		y = 10,
		halign = "center",
		font_size = 32,
		x = 10,
		layer = 1,
		text = title or "none",
		visible = title and true or false,
		w = main:w() - 20,
		color = tweak_data.gui.colors.raid_white,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, 32)
	}
	local title_text = main:text(title_params)
	local _, _, tw, th = title_text:text_rect()

	title_text:set_h(th + 5)

	th = th + 10

	if is_title_outside then
		th = 0
	end

	local top_line = main:bitmap({
		texture = "core/textures/default_texture_01_df",
		name = "top_line",
		y = 0,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	top_line:set_bottom(th)

	local bottom_line = main:bitmap({
		texture = "core/textures/default_texture_01_df",
		name = "bottom_line",
		y = 100,
		rotation = 180,
		layer = 0,
		color = Color.white,
		w = main:w()
	})

	bottom_line:set_top(main:h() - th)
	top_line:hide()
	bottom_line:hide()

	local lower_static_panel = main:panel({
		name = "text_box_gui_lower_static_panel",
		h = 0,
		y = 0,
		x = 0,
		layer = 0,
		w = main:w()
	})

	self:_create_lower_static_panel(lower_static_panel)

	local info_area = main:panel({
		name = "info_area",
		y = 0,
		x = 0,
		layer = 0,
		w = main:w(),
		h = main:h() - th * 2
	})
	local buttons_panel = self:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	local scroll_panel = info_area:panel({
		name = "scroll_panel",
		x = 10,
		layer = 1,
		y = math.round(th + 15),
		w = info_area:w() - 20,
		h = info_area:h()
	})
	local has_stats = stats_list and #stats_list > 0
	local stats_panel = self:_setup_stats_panel(scroll_panel, stats_list, stats_text)
	local text_params = {
		word_wrap = true,
		name = "text_box_gui_text",
		halign = "center",
		wrap = true,
		align = "center",
		vertical = "top",
		valign = "top",
		font_size = 22,
		layer = 1,
		text = utf8.to_upper(text) or "none",
		visible = text and true or false,
		w = scroll_panel:w() - math.round(stats_panel:w()) - (has_stats and 20 or 0),
		x = math.round(stats_panel:w()) + (has_stats and 20 or 0),
		color = tweak_data.gui.colors.raid_grey,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, 22)
	}
	local text = scroll_panel:text(text_params)

	if use_text_formating then
		local text_string = text:text()
		local text_dissected = utf8.characters(text_string)
		local idsp = Idstring("#")
		local start_ci = {}
		local end_ci = {}
		local first_ci = true

		for i, c in ipairs(text_dissected) do
			if Idstring(c) == idsp then
				local next_c = text_dissected[i + 1]

				if next_c and Idstring(next_c) == idsp then
					if first_ci then
						table.insert(start_ci, i)
					else
						table.insert(end_ci, i)
					end

					first_ci = not first_ci
				end
			end
		end

		if #start_ci == #end_ci then
			for i = 1, #start_ci do
				start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
				end_ci[i] = end_ci[i] - (i * 4 - 1)
			end
		end

		text_string = string.gsub(text_string, "##", "")

		text:set_text(text_string)
		text:clear_range_color(1, utf8.len(text_string))

		if #start_ci ~= #end_ci then
			Application:error("TextBoxGui: Not even amount of ##'s in skill description string!", #start_ci, #end_ci)
		else
			for i = 1, #start_ci do
				text:set_range_color(start_ci[i], end_ci[i], text_formating_color_table and text_formating_color_table[i] or text_formating_color)
			end
		end
	end

	text:set_w(scroll_panel:w())
	text:set_x(0)

	local _, _, ttw, tth = text:text_rect()

	text:set_h(tth)

	local textbox_panel = self:_setup_textbox(content_data.textbox, content_data.textbox_value)

	scroll_panel:set_h(forced_h or math.min(h - th, tth))
	info_area:set_h(scroll_panel:bottom() + textbox_panel:h() + buttons_panel:h() + 64)
	buttons_panel:set_bottom(info_area:h() - 10)
	textbox_panel:set_bottom(buttons_panel:y() - 30)

	if not preset_or_config_y then
		main:set_h(info_area:h())

		if bottom then
			main:set_bottom(bottom)
		elseif y == 0 then
			main:set_center_y(main:parent():h() / 2)
		end
	end

	top_line:set_world_bottom(scroll_panel:world_top())
	bottom_line:set_world_top(scroll_panel:world_bottom())
	lower_static_panel:set_bottom(main:h() - h * 2)

	local legend_minimize = main:text({
		text = "MINIMIZE",
		name = "text_box_gui_legend_minimize",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = use_minimize_legend,
		font = tweak_data.gui.font_paths.din_compressed[32],
		font_size = tweak_data.gui.font_sizes.size_32
	})
	local _, _, lw, lh = legend_minimize:text_rect()

	legend_minimize:set_size(lw, lh)
	legend_minimize:set_bottom(top_line:bottom() - 4)
	legend_minimize:set_right(top_line:right())

	local legend_close = main:text({
		text = "CLOSE",
		name = "text_box_gui_legend_close",
		halign = "left",
		valign = "top",
		layer = 1,
		visible = not no_close_legend,
		font = tweak_data.gui.font_paths.din_compressed[32],
		font_size = tweak_data.gui.font_sizes.size_32
	})
	local _, _, lw, lh = legend_close:text_rect()

	legend_close:set_size(lw, lh)
	legend_close:set_top(bottom_line:top() + 4)

	self._scroll_panel = scroll_panel
	self._text_box = main

	if is_title_outside then
		title_text:set_bottom(0)
		title_text:set_rotation(360)

		self._is_title_outside = is_title_outside
	end

	return main
end

-- Lines 287-361
function TextBoxGui:_setup_stats_panel(scroll_panel, stats_list, stats_text)
	local has_stats = stats_list and #stats_list > 0
	local stats_panel = scroll_panel:panel({
		name = "text_box_gui_stats_panel",
		x = 10,
		layer = 1,
		w = has_stats and scroll_panel:w() / 3 or 0,
		h = scroll_panel:h()
	})
	local total_h = 0

	if has_stats then
		for _, stats in ipairs(stats_list) do
			if stats.type == "bar" then
				local panel = stats_panel:panel({
					layer = -1,
					h = 20,
					w = stats_panel:w(),
					y = total_h
				})
				local bg = panel:rect({
					layer = -1,
					color = Color.black:with_alpha(0.5)
				})
				local w = (bg:w() - 4) * stats.current / stats.total
				local progress_bar = panel:rect({
					y = 1,
					x = 1,
					layer = 0,
					w = w,
					h = bg:h() - 2,
					color = tweak_data.hud.prime_color:with_alpha(0.5)
				})
				local text = panel:text({
					name = "text_box_gui_stats_text",
					halign = "left",
					align = "left",
					vertical = "center",
					valign = "center",
					blend_mode = "normal",
					y = -1,
					kern = 0,
					x = 4,
					layer = 1,
					text = stats.text,
					w = panel:w(),
					h = panel:h(),
					font = tweak_data.gui.font_paths.din_compressed[32],
					font_size = tweak_data.gui.font_sizes.size_32
				})
				total_h = total_h + panel:h()
			elseif stats.type == "condition" then
				local panel = stats_panel:panel({
					h = 22,
					w = stats_panel:w(),
					y = total_h
				})
				local texture, rect = tweak_data.hud_icons:get_icon_data("icon_repair")
				local icon = panel:bitmap({
					name = "icon",
					layer = 0,
					texture = texture,
					texture_rect = rect,
					color = Color.white
				})

				icon:set_center_y(panel:h() / 2)

				local text = panel:text({
					name = "text_box_gui_scondition_label",
					vertical = "center",
					align = "left",
					valign = "center",
					blend_mode = "normal",
					kern = 0,
					halign = "left",
					layer = 0,
					text = "CONDITION: " .. stats.value .. "%",
					w = panel:w(),
					h = panel:h(),
					x = icon:right(),
					font = tweak_data.gui.font_paths.din_compressed[32],
					font_size = tweak_data.gui.font_sizes.size_32
				})

				text:set_center_y(panel:h() / 2)

				total_h = total_h + panel:h()
			elseif stats.type == "empty" then
				local panel = stats_panel:panel({
					name = "text_box_gui_stats_empty_panel",
					w = stats_panel:w(),
					h = stats.h,
					y = total_h
				})
				total_h = total_h + panel:h()
			elseif stats.type == "mods" then
				local panel = stats_panel:panel({
					name = "text_box_gui_mods_panel",
					h = 22,
					w = stats_panel:w(),
					y = total_h
				})
				local texture, rect = tweak_data.hud_icons:get_icon_data("icon_addon")
				local icon = panel:bitmap({
					name = "icon",
					layer = 0,
					texture = texture,
					texture_rect = rect,
					color = Color.white
				})

				icon:set_center_y(panel:h() / 2)

				local text = panel:text({
					name = "text_box_gui_active_mods_label",
					vertical = "center",
					align = "left",
					valign = "center",
					blend_mode = "normal",
					text = "ACTIVE MODS:",
					kern = 0,
					halign = "left",
					layer = 0,
					w = panel:w(),
					h = panel:h(),
					x = icon:right(),
					font = tweak_data.gui.font_paths.din_compressed[32],
					font_size = tweak_data.gui.font_sizes.size_32
				})

				text:set_center_y(panel:h() / 2)

				local s = ""

				for _, mod in ipairs(stats.list) do
					s = s .. mod .. "\n"
				end

				local mods_text = panel:text({
					name = "text_box_gui_mods_text",
					halign = "left",
					align = "left",
					vertical = "top",
					valign = "top",
					blend_mode = "normal",
					kern = 0,
					layer = 0,
					text = s,
					w = panel:w(),
					h = panel:h(),
					y = text:bottom(),
					x = icon:right(),
					font = tweak_data.gui.font_paths.din_compressed[32],
					font_size = tweak_data.gui.font_sizes.size_32
				})
				local _, _, w, h = mods_text:text_rect()

				mods_text:set_h(h)
				panel:set_h(text:h() + mods_text:h())

				total_h = total_h + panel:h()
			end
		end

		local stats_text = stats_panel:text({
			vertical = "top",
			halign = "left",
			wrap = true,
			align = "left",
			word_wrap = true,
			valign = "top",
			blend_mode = "normal",
			kern = 0,
			layer = 0,
			text = stats_text or "Nunc vel diam vel neque sodales gravida et ac quam. Phasellus egestas, arcu in tristique mattis, velit nisi tincidunt lorem, bibendum molestie nunc purus id turpis. Donec sagittis nibh in eros ultrices aliquam. Vestibulum ante mauris, mattis quis commodo a, dictum eget sapien. Maecenas eu diam lorem. Nunc dolor metus, varius sit amet rhoncus vel, iaculis sed massa. Morbi tempus mi quis dolor posuere eu commodo magna eleifend. Pellentesque sit amet mattis nunc. Nunc lectus quam, pretium sit amet consequat sed, vestibulum vitae lorem. Sed bibendum egestas turpis, sit amet viverra risus viverra in. Suspendisse aliquam dapibus urna, posuere fermentum tellus vulputate vitae.",
			w = stats_panel:w(),
			y = total_h,
			font = tweak_data.gui.font_paths.din_compressed[32],
			font_size = tweak_data.gui.font_sizes.size_32
		})
		local _, _, w, h = stats_text:text_rect()

		stats_text:set_h(h)

		total_h = total_h + h
	end

	stats_panel:set_h(total_h)

	return stats_panel
end

-- Lines 364-418
function TextBoxGui:_setup_buttons_panel(info_area, button_list, focus_button, only_buttons)
	local has_buttons = button_list and #button_list > 0
	self._text_box_buttons_panel = info_area:panel({
		name = "buttons_panel",
		h = 48,
		x = 10,
		layer = 1,
		w = has_buttons and 800 or 0
	})

	self._text_box_buttons_panel:set_right(info_area:w())

	self._buttons = {}

	if has_buttons then
		local button_text_config = {
			name = "button_text",
			vertical = "center",
			word_wrap = "true",
			wrap = "true",
			blend_mode = "add",
			halign = "right",
			x = 10,
			layer = 2,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size,
			color = tweak_data.screen_colors.button_stage_3
		}
		local button_distance = 35
		local max_w = 0
		local max_h = 0

		if button_list then
			for i, button in ipairs(button_list) do
				local x = 0

				if i > 1 then
					x = self._buttons[#self._buttons]:x() + self._buttons[#self._buttons]:w() + button_distance
					max_w = max_w + button_distance
				end

				local button_params = {
					y = 0,
					name = button.id_name,
					x = x,
					text = utf8.to_upper(button.text) or "",
					font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.medium)
				}
				local button_class = button.class or RaidGUIControlButtonShortPrimary
				local new_button = button_class:new(self._text_box_buttons_panel, button_params)
				max_w = max_w + new_button:w()

				self._text_box_buttons_panel:set_h(new_button:h())

				max_h = math.max(max_h, new_button:h())

				table.insert(self._buttons, new_button)

				if i == focus_button then
					self:set_focus_button(focus_button)
				end
			end

			self._text_box_buttons_panel:set_h(max_h)
			self._text_box_buttons_panel:set_bottom(info_area:h() - 10)
		end

		self._text_box_buttons_panel:set_w(max_w)
		self._text_box_buttons_panel:set_center_x(info_area:center_x())
	end

	return self._text_box_buttons_panel
end

-- Lines 420-461
function TextBoxGui:_setup_textbox(has_textbox, texbox_value)
	local info_area = self._panel:child("info_area")
	local scroll_panel = info_area:child("scroll_panel")
	local title = self._panel:child("title")
	local text = scroll_panel:child("text_box_gui_text")
	local padding_up = 20
	local y = math.max(0, title:y() + title:h() + padding_up)
	y = math.max(y, scroll_panel:y() + scroll_panel:h() + padding_up)
	local textbox_panel_params = {
		name = "textbox_panel",
		h = 0,
		w = 433,
		x = 0,
		y = y
	}
	local textbox_panel = info_area:panel(textbox_panel_params)

	textbox_panel:set_center_x(info_area:center_x())

	if not has_textbox then
		return textbox_panel
	end

	textbox_panel:set_h(48)

	local input_field_params = {
		name = "input_field",
		y = 0,
		x = 0,
		w = textbox_panel:w(),
		h = textbox_panel:h(),
		ws = self._ws,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.small),
		text_changed_callback = callback(self, self, "_input_field_text_changed"),
		text = texbox_value
	}
	self._input_field = RaidGUIControlInputField:new(textbox_panel, input_field_params)

	table.insert(self.controls, self._input_field)
	self._input_field:set_chat_focus(true)

	return textbox_panel
end

-- Lines 463-469
function TextBoxGui:_input_field_text_changed()
	if not self._callback_data then
		self._callback_data = {}
	end

	self._callback_data.input_field_text = self._input_field:get_text()
end

-- Lines 471-473
function TextBoxGui:_create_lower_static_panel()
end

-- Lines 475-477
function TextBoxGui:get_callback_data()
	return self._callback_data
end

-- Lines 479-487
function TextBoxGui:check_focus_button(x, y)
	for i, panel in ipairs(self._text_box_buttons_panel:children()) do
		if panel.child and panel:inside(x, y) then
			self:set_focus_button(i)

			return true
		end
	end

	return false
end

-- Lines 489-500
function TextBoxGui:set_focus_button(focus_button)
	if focus_button ~= self._text_box_focus_button then
		managers.menu:post_event("highlight")

		if self._text_box_focus_button then
			self:_set_button_selected(self._text_box_focus_button, false)
		end

		self:_set_button_selected(focus_button, true)

		self._text_box_focus_button = focus_button
	end
end

-- Lines 502-507
function TextBoxGui:unfocus_button(index)
	if self._text_box_focus_button == index then
		self:_set_button_selected(index, false)

		self._text_box_focus_button = nil
	end
end

-- Lines 509-514
function TextBoxGui:_set_button_selected(index, is_selected)
	local button = self._buttons[index]

	if button then
		button:set_selected(is_selected)
	end
end

-- Lines 516-530
function TextBoxGui:change_focus_button(change)
	if self._input_field and self._input_field:input_focus() and not managers.controller:is_xbox_controller_present() then
		return
	end

	local button_count = #self._buttons
	local current_focus_button = self._text_box_focus_button or self._default_button
	local focus_button = math.clamp(current_focus_button + change, 1, button_count)

	if focus_button == 0 then
		focus_button = button_count
	end

	self:set_focus_button(focus_button)
end

-- Lines 532-534
function TextBoxGui:get_focus_button()
	return self._text_box_focus_button
end

-- Lines 536-538
function TextBoxGui:get_focus_button_id()
	return self._text_box_buttons_panel:child(self._text_box_focus_button - 1):name()
end

-- Lines 540-542
function TextBoxGui:input_focus()
	return false
end

-- Lines 544-546
function TextBoxGui:mouse_pressed(button, x, y)
	return false
end

-- Lines 548-562
function TextBoxGui:check_close(x, y)
	if not self:can_take_input() then
		return false
	end

	local legend_close = self._panel:child("legend_close")

	if not legend_close:visible() then
		return false
	end

	if legend_close:inside(x, y) then
		return true
	end

	return false
end

-- Lines 564-578
function TextBoxGui:check_minimize(x, y)
	if not self:can_take_input() then
		return false
	end

	local legend_minimize = self._panel:child("legend_minimize")

	if not legend_minimize:visible() then
		return false
	end

	if legend_minimize:inside(x, y) then
		return true
	end

	return false
end

-- Lines 580-614
function TextBoxGui:mouse_moved(x, y)
	if not self:can_take_input() or not alive(self._panel) then
		return false, "arrow"
	end

	if self._grabbed_title then
		local _x = x + self._grabbed_offset_x
		local _y = y + self._grabbed_offset_y

		if self._ws:panel():w() < _x + self:w() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():w() - self:w()
		elseif _x < self._ws:panel():x() then
			self._grabbed_offset_x = self:x() - x
			_x = self._ws:panel():x()
		end

		if self._ws:panel():h() < _y + self:h() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():h() - self:h()
		elseif _y < self._ws:panel():y() then
			self._grabbed_offset_y = self:y() - y
			_y = self._ws:panel():y()
		end

		self:set_position(_x, _y)

		return true, "grab"
	else
		for i, panel in ipairs(self._text_box_buttons_panel:children()) do
			if panel.child and panel:inside(x, y) then
				return true, "link"
			end
		end
	end

	return false, "arrow"
end

-- Lines 616-619
function TextBoxGui:check_grab_scroll_bar()
	return false
end

-- Lines 621-624
function TextBoxGui:moved_scroll_bar()
	return false, "arrow"
end

-- Lines 626-628
function TextBoxGui:release_scroll_bar()
end

-- Lines 630-635
function TextBoxGui:set_fade(fade)
	self:_set_alpha(fade)

	if alive(self._background) then
		self._background:set_alpha(fade * 0.8)
	end
end

-- Lines 637-640
function TextBoxGui:_set_alpha(alpha)
	self._panel:set_alpha(alpha)
	self._panel:set_visible(alpha ~= 0)
end

-- Lines 642-653
function TextBoxGui:_set_alpha_recursive(obj, alpha)
	if obj.set_color then
		local a = self._target_alpha[obj:key()] and self._target_alpha[obj:key()] * alpha or alpha

		obj:set_color(obj:color():with_alpha(a))
	end

	if obj.children then
		for _, child in ipairs(obj:children()) do
			self:_set_alpha_recursive(child, alpha)
		end
	end
end

-- Lines 655-662
function TextBoxGui:set_title(title)
	local title_text = self._panel:child("title")

	title_text:set_text(title or "none")

	local _, _, w, h = title_text:text_rect()

	title_text:set_h(h)
	title_text:set_center_x(self._panel:center_x())
	title_text:set_visible(title and true or false)
end

-- Lines 664-667
function TextBoxGui:set_text(txt, no_upper)
	local text = self._panel:child("info_area"):child("scroll_panel"):child("text_box_gui_text")

	text:set_text(no_upper and txt or utf8.to_upper(txt or ""))
end

-- Lines 669-671
function TextBoxGui:set_use_minimize_legend(use)
	self._panel:child("legend_minimize"):set_visible(use)
end

-- Lines 673-675
function TextBoxGui:in_focus(x, y)
	return self._panel:inside(x, y)
end

-- Lines 677-679
function TextBoxGui:in_info_area_focus(x, y)
	return self._panel:child("info_area"):inside(x, y)
end

-- Lines 681-688
function TextBoxGui:_set_visible_state()
	local visible = self._visible and self._enabled

	self._panel:set_visible(visible)

	if alive(self._background) then
		self._background:set_visible(visible)
	end
end

-- Lines 690-692
function TextBoxGui:can_take_input()
	return self._visible and self._enabled
end

-- Lines 694-697
function TextBoxGui:set_visible(visible)
	self._visible = visible

	self:_set_visible_state()
end

-- Lines 699-713
function TextBoxGui:set_enabled(enabled)
	if self._enabled == enabled then
		return
	end

	self._enabled = enabled

	self:_set_visible_state()

	if self._minimized then
		if not self._enabled then
			self:_remove_minimized(self._minimized_id)
		else
			self:_add_minimized()
		end
	end
end

-- Lines 715-717
function TextBoxGui:enabled()
	return self._enabled
end

-- Lines 719-724
function TextBoxGui:_maximize(data)
	self:set_visible(true)
	self:set_minimized(false, nil)
	self:_remove_minimized(data.id)
end

-- Lines 726-732
function TextBoxGui:set_minimized(minimized, minimized_data)
	self._minimized = minimized
	self._minimized_data = minimized_data

	if self._minimized then
		self:_add_minimized()
	end
end

-- Lines 734-738
function TextBoxGui:_add_minimized()
	self._minimized_data.callback = callback(self, self, "_maximize")

	self:set_visible(false)

	self._minimized_id = managers.menu_component:add_minimized(self._minimized_data)
end

-- Lines 740-743
function TextBoxGui:_remove_minimized(id)
	self._minimized_id = nil

	managers.menu_component:remove_minimized(id)
end

-- Lines 745-747
function TextBoxGui:minimized()
	return self._minimized
end

-- Lines 749-751
function TextBoxGui:set_position(x, y)
	self._panel:set_position(x, y)
end

-- Lines 753-755
function TextBoxGui:position()
	return self._panel:position()
end

-- Lines 757-790
function TextBoxGui:set_size(x, y)
	self._panel:set_size(x, y)

	local _, _, w, h = self._panel:child("title"):text_rect()
	local lower_static_panel = self._panel:child("lower_static_panel")

	lower_static_panel:set_w(self._panel:w())
	lower_static_panel:set_bottom(self._panel:h() - h)

	local lsp_h = lower_static_panel:h()
	local info_area = self._panel:child("info_area")

	info_area:set_size(self._panel:w(), self._panel:h() - h * 2 - lsp_h)

	local buttons_panel = info_area:child("buttons_panel")
	local scroll_panel = info_area:child("scroll_panel")

	scroll_panel:set_w(info_area:w() - buttons_panel:w() - 30)
	scroll_panel:set_y(scroll_panel:y() - 1)
	scroll_panel:set_y(scroll_panel:y() + 1)

	local top_line = self._panel:child("top_line")

	top_line:set_w(self._panel:w())
	top_line:set_bottom(h)

	local bottom_line = self._panel:child("bottom_line")

	bottom_line:set_w(self._panel:w())
	bottom_line:set_top(self._panel:h() - h)

	local legend_close = self._panel:child("legend_close")

	legend_close:set_top(bottom_line:top() + 4)

	local legend_minimize = self._panel:child("legend_minimize")

	legend_minimize:set_bottom(top_line:bottom() - 4)
	legend_minimize:set_right(top_line:right())
end

-- Lines 792-794
function TextBoxGui:size()
	return self._panel:size()
end

-- Lines 796-796
function TextBoxGui:open_page()
end

-- Lines 797-797
function TextBoxGui:close_page()
end

-- Lines 799-799
function TextBoxGui:x()
	return self._panel:x()
end

-- Lines 800-800
function TextBoxGui:y()
	return self._panel:y()
end

-- Lines 801-801
function TextBoxGui:h()
	return self._panel:h()
end

-- Lines 802-802
function TextBoxGui:w()
	return self._panel:w()
end

-- Lines 804-806
function TextBoxGui:h()
	return self._panel:h()
end

-- Lines 808-810
function TextBoxGui:visible()
	return self._visible
end

-- Lines 812-829
function TextBoxGui:close()
	if self._minimized then
		self:_remove_minimized(self._minimized_id)
	end

	if self._thread then
		self._panel:stop(self._thread)

		self._thread = nil
	end

	self._ws:panel():remove(self._panel)

	if alive(self._background) then
		self._fullscreen_ws:panel():remove(self._background)
	end

	if alive(self._fullscreen_ws) then
		Overlay:gui():destroy_workspace(self._fullscreen_ws)

		self._fullscreen_ws = nil
	end
end
