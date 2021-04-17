ComicBookGui = ComicBookGui or class(RaidGuiBase)
ComicBookGui.PAGE_WIDTH = 992
ComicBookGui.PAGE_HEIGHT = 768
ComicBookGui.TOTAL_PAGE_COUNT = 14
ComicBookGui.PAGING_NO_PAGE_COLOR_CIRCLE = tweak_data.gui.colors.raid_dark_grey
ComicBookGui.PAGING_NO_PAGE_COLOR_ARROW = tweak_data.gui.colors.raid_dark_grey
ComicBookGui.PAGING_NORMAL_PAGE_COLOR_CIRCLE = tweak_data.gui.colors.raid_grey_effects
ComicBookGui.PAGING_NORMAL_PAGE_COLOR_ARROW = tweak_data.gui.colors.raid_dirty_white
ComicBookGui.NORMAL_PAGE_HOVER_COLOR_CIRCLE = tweak_data.gui.colors.raid_red
ComicBookGui.NORMAL_PAGE_HOVER_COLOR_ARROW = tweak_data.gui.colors.raid_dirty_white
ComicBookGui.BULLET_PANEL_HEIGHT = 32
ComicBookGui.BULLET_WIDTH = 16
ComicBookGui.BULLET_HEIGHT = 16
ComicBookGui.BULLET_PADDING = 2
ComicBookGui.ANIMATION_DURATION = 1
ComicBookGui.PAGE_NAME = "ui/comic_book/raid_comic_"

-- Lines 24-32
function ComicBookGui:init(ws, fullscreen_ws, node, component_name)
	ComicBookGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_comic_book_screen_name")
	self:_process_comic_book()
end

-- Lines 34-39
function ComicBookGui:_set_initial_data()
	self._current_page = 1
	self._bullets_normal = {}
	self._bullets_active = {}
end

-- Lines 41-43
function ComicBookGui:close()
	ComicBookGui.super.close(self)
end

-- Lines 45-92
function ComicBookGui:_layout()
	self:_disable_dof()

	self._left_arrow = self._root_panel:panel({
		visible = true,
		y = 0,
		x = 0,
		w = tweak_data.gui.icons.players_icon_outline.texture_rect[3],
		h = tweak_data.gui.icons.players_icon_outline.texture_rect[4]
	})
	self._left_arrow_circle = self._left_arrow:image_button({
		visible = true,
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons.players_icon_outline.texture,
		texture_rect = tweak_data.gui.icons.players_icon_outline.texture_rect,
		color = ComicBookGui.PAGING_NO_PAGE_COLOR_CIRCLE,
		highlight_color = ComicBookGui.NORMAL_PAGE_HOVER_COLOR_CIRCLE,
		on_click_callback = callback(self, self, "_on_left_arrow_clicked")
	})
	self._left_arrow_arrow = self._left_arrow:bitmap({
		visible = true,
		y = 7,
		x = 7,
		texture = tweak_data.gui.icons.ico_page_turn_left.texture,
		texture_rect = tweak_data.gui.icons.ico_page_turn_left.texture_rect,
		color = ComicBookGui.PAGING_NO_PAGE_COLOR_ARROW
	})

	self._left_arrow:set_center_x(176)
	self._left_arrow:set_center_y(464)

	self._right_arrow = self._root_panel:panel({
		visible = true,
		y = 0,
		x = 0,
		w = tweak_data.gui.icons.players_icon_outline.texture_rect[3],
		h = tweak_data.gui.icons.players_icon_outline.texture_rect[4]
	})
	self._right_arrow_circle = self._right_arrow:image_button({
		visible = true,
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons.players_icon_outline.texture,
		texture_rect = tweak_data.gui.icons.players_icon_outline.texture_rect,
		color = ComicBookGui.PAGING_NO_PAGE_COLOR_CIRCLE,
		highlight_color = ComicBookGui.NORMAL_PAGE_HOVER_COLOR_CIRCLE,
		on_click_callback = callback(self, self, "_on_right_arrow_clicked")
	})
	self._right_arrow_arrow = self._right_arrow:bitmap({
		visible = true,
		y = 7,
		x = 7,
		texture = tweak_data.gui.icons.ico_page_turn_right.texture,
		texture_rect = tweak_data.gui.icons.ico_page_turn_right.texture_rect,
		color = ComicBookGui.PAGING_NO_PAGE_COLOR_ARROW
	})

	self._right_arrow:set_center_x(1552)
	self._right_arrow:set_center_y(464)

	self._comic_book_image = self._root_panel:bitmap({
		texture = "ui/comic_book/raid_comic_001",
		visible = true,
		y = 96,
		x = 0,
		w = ComicBookGui.PAGE_WIDTH,
		h = ComicBookGui.PAGE_HEIGHT
	})

	self._comic_book_image:set_center_x(self._root_panel:center_x())

	self._bullet_panel = self._root_panel:panel({
		h = 32,
		x = 0,
		y = self._root_panel:h() - ComicBookGui.BULLET_PANEL_HEIGHT * 2,
		w = self._root_panel:w()
	})

	for i = 1, ComicBookGui.TOTAL_PAGE_COUNT do
		table.insert(self._bullets_normal, self._bullet_panel:bitmap({
			x = (i - 1) * (ComicBookGui.BULLET_WIDTH + ComicBookGui.BULLET_PADDING),
			y = ComicBookGui.BULLET_HEIGHT / 2,
			w = ComicBookGui.BULLET_WIDTH,
			h = ComicBookGui.BULLET_HEIGHT,
			texture = tweak_data.gui.icons.bullet_empty.texture,
			texture_rect = tweak_data.gui.icons.bullet_empty.texture_rect
		}))
		table.insert(self._bullets_active, self._bullet_panel:bitmap({
			h = 0,
			w = 0,
			x = (i - 1) * (ComicBookGui.BULLET_WIDTH + ComicBookGui.BULLET_PADDING),
			y = ComicBookGui.BULLET_HEIGHT / 2,
			texture = tweak_data.gui.icons.bullet_active.texture,
			texture_rect = tweak_data.gui.icons.bullet_active.texture_rect
		}))
	end

	self._bullet_panel:set_w(ComicBookGui.TOTAL_PAGE_COUNT * (ComicBookGui.BULLET_WIDTH + ComicBookGui.BULLET_PADDING))
	self._bullet_panel:set_center_x(self._root_panel:w() / 2)
	self._bullets_active[1]:set_w(ComicBookGui.BULLET_WIDTH)
	self._bullets_active[1]:set_h(ComicBookGui.BULLET_HEIGHT)
	self:bind_controller_inputs()
end

-- Lines 94-149
function ComicBookGui:_process_comic_book()
	managers.menu_component:post_event("paper_shuffle_menu")

	if self._current_page == 1 then
		self._left_arrow_circle:set_color(ComicBookGui.PAGING_NO_PAGE_COLOR_CIRCLE)
		self._left_arrow_arrow:set_color(ComicBookGui.PAGING_NO_PAGE_COLOR_ARROW)
		self._right_arrow_circle:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_CIRCLE)
		self._right_arrow_arrow:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_ARROW)
		self._comic_book_image:set_w(ComicBookGui.PAGE_WIDTH / 2)
		self._left_arrow_circle:set_param_value("no_highlight", true)
		self._right_arrow_circle:set_param_value("no_highlight", false)
		self:bind_controller_inputs_right_only()
	elseif self._current_page == ComicBookGui.TOTAL_PAGE_COUNT then
		self._left_arrow_circle:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_CIRCLE)
		self._left_arrow_arrow:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_ARROW)
		self._right_arrow_circle:set_color(ComicBookGui.PAGING_NO_PAGE_COLOR_CIRCLE)
		self._right_arrow_arrow:set_color(ComicBookGui.PAGING_NO_PAGE_COLOR_ARROW)
		self._comic_book_image:set_w(ComicBookGui.PAGE_WIDTH / 2)
		self._left_arrow_circle:set_param_value("no_highlight", false)
		self._right_arrow_circle:set_param_value("no_highlight", true)
		self:bind_controller_inputs_left_only()
	else
		self._left_arrow_circle:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_CIRCLE)
		self._left_arrow_arrow:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_ARROW)
		self._right_arrow_circle:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_CIRCLE)
		self._right_arrow_arrow:set_color(ComicBookGui.PAGING_NORMAL_PAGE_COLOR_ARROW)
		self._comic_book_image:set_w(ComicBookGui.PAGE_WIDTH)
		self._left_arrow_circle:set_param_value("no_highlight", false)
		self._right_arrow_circle:set_param_value("no_highlight", false)
		self:bind_controller_inputs()
	end

	self._comic_book_image:set_center_x(self._root_panel:center_x())
	self._comic_book_image:set_image(ComicBookGui.PAGE_NAME .. string.format("%03d", self._current_page))
end

-- Lines 151-196
function ComicBookGui:_animate_bullets(params)
	local current_page = params.current_page
	local previous_page = params.previous_page

	self._bullets_active[previous_page]:set_w(0)
	self._bullets_active[previous_page]:set_h(0)
	self._bullets_active[current_page]:set_w(0)
	self._bullets_active[current_page]:set_h(0)

	local t = 0
	local animation_duration = ComicBookGui.ANIMATION_DURATION

	while t < animation_duration do
		local dt = coroutine.yield()
		t = t + dt

		if t < animation_duration / 2 then
			local current_active_width = (animation_duration / 2 - t) / (animation_duration / 2) * ComicBookGui.BULLET_WIDTH
			local current_active_height = (animation_duration / 2 - t) / (animation_duration / 2) * ComicBookGui.BULLET_HEIGHT

			self._bullets_active[previous_page]:set_w(current_active_width)
			self._bullets_active[previous_page]:set_h(current_active_height)
			self._bullets_active[previous_page]:set_center_x(self._bullets_normal[previous_page]:center_x())
			self._bullets_active[previous_page]:set_center_y(self._bullets_normal[previous_page]:center_y())
		elseif t > animation_duration / 2 then
			local current_next_width = (t - animation_duration / 2) / (animation_duration / 2) * ComicBookGui.BULLET_WIDTH
			local current_next_height = (t - animation_duration / 2) / (animation_duration / 2) * ComicBookGui.BULLET_HEIGHT

			self._bullets_active[current_page]:set_w(current_next_width)
			self._bullets_active[current_page]:set_h(current_next_height)
			self._bullets_active[current_page]:set_center_x(self._bullets_normal[current_page]:center_x())
			self._bullets_active[current_page]:set_center_y(self._bullets_normal[current_page]:center_y())
		end
	end
end

-- Lines 198-211
function ComicBookGui:_stop_animation(current_page, previous_page)
	if previous_page then
		self._bullets_active[previous_page]:set_w(0)
		self._bullets_active[previous_page]:set_h(0)
	end

	if current_page then
		self._bullets_active[current_page]:set_w(0)
		self._bullets_active[current_page]:set_h(0)
	end

	self._bullet_panel:stop()
end

-- Lines 213-230
function ComicBookGui:_page_left()
	if self._current_page == 1 then
		return
	end

	self:_stop_animation(self._current_page, self._previous_page)

	self._previous_page = self._current_page
	self._current_page = self._current_page - 1

	if self._current_page < 1 then
		self._current_page = 1
	end

	self:_process_comic_book()
	self._bullet_panel:animate(callback(self, self, "_animate_bullets", {
		current_page = self._current_page,
		previous_page = self._previous_page
	}))
	Application:trace("[ComicBookGui:_page_left] self._current_page ", self._current_page)
end

-- Lines 232-249
function ComicBookGui:_page_right()
	if self._current_page == ComicBookGui.TOTAL_PAGE_COUNT then
		return
	end

	self:_stop_animation(self._current_page, self._previous_page)

	self._previous_page = self._current_page
	self._current_page = self._current_page + 1

	if ComicBookGui.TOTAL_PAGE_COUNT < self._current_page then
		self._current_page = ComicBookGui.TOTAL_PAGE_COUNT
	end

	self:_process_comic_book()
	self._bullet_panel:animate(callback(self, self, "_animate_bullets", {
		current_page = self._current_page,
		previous_page = self._previous_page
	}))
	Application:trace("[ComicBookGui:_page_right] self._current_page ", self._current_page)
end

-- Lines 251-253
function ComicBookGui:_on_left_arrow_clicked()
	self:_page_left()
end

-- Lines 255-257
function ComicBookGui:_on_right_arrow_clicked()
	self:_page_right()
end

-- Lines 265-284
function ComicBookGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_left_arrow_clicked")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_right_arrow_clicked")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_comic_book_left",
			"menu_legend_comic_book_right"
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

-- Lines 286-303
function ComicBookGui:bind_controller_inputs_left_only()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_left_arrow_clicked")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_comic_book_left"
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

-- Lines 305-322
function ComicBookGui:bind_controller_inputs_right_only()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_right_arrow_clicked")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_comic_book_right"
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

-- Lines 324-327
function ComicBookGui:confirm_pressed()
	return false
end
