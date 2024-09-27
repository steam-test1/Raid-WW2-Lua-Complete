ComicBookGui = ComicBookGui or class(RaidGuiBase)
ComicBookGui.PAGE_WIDTH = 593
ComicBookGui.PAGE_HEIGHT = 912
ComicBookGui.PAGE_COORD_WIDTH = 1024
ComicBookGui.PAGE_COORD_HEIGHT = 2048
ComicBookGui.PAGE_ANIMATION_DURATION = 0.11
ComicBookGui.PAGE_TEXTURE_PREFIX = "ui/comic_book/raid_comic_"
ComicBookGui.TOTAL_PAGE_COUNT = 14
ComicBookGui.CIRCLE_NORMAL_COLOR = tweak_data.gui.colors.raid_grey_effects
ComicBookGui.CIRCLE_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
ComicBookGui.CIRCLE_DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey
ComicBookGui.ARROW_X_OFFSET = ComicBookGui.PAGE_WIDTH + 95
ComicBookGui.ARROW_NORMAL_COLOR = tweak_data.gui.colors.raid_dirty_white
ComicBookGui.ARROW_DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey
ComicBookGui.BULLET_PANEL_HEIGHT = 36
ComicBookGui.BULLET_WIDTH = 22
ComicBookGui.BULLET_HEIGHT = 22
ComicBookGui.BULLET_PADDING = 1
ComicBookGui.BULLET_ANIMATION_DURATION = 0.33
ComicBookGui.BULLET_NORMAL_COLOR = tweak_data.gui.colors.raid_dirty_white
ComicBookGui.BULLET_HIGHLIGHT_COLOR = tweak_data.gui.colors.progress_orange
ComicBookGui.SHUFFLE_EVENT_COOLDOWN = 0.065

function ComicBookGui:init(ws, fullscreen_ws, node, component_name)
	ComicBookGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_footer:hide_name_and_gold_panel()
	self:_preload_pages()
	self:bind_controller_inputs()
end

function ComicBookGui:_set_initial_data()
	self._current_page = 1
	self._paper_event_expire_t = 0
	self._bullets_normal = {}
	self._bullets_active = {}
	self._zoom_position = Vector3()
	self._texture_rect = {
		left = nil,
		right = nil,
		left = {
			0,
			0,
			self.PAGE_COORD_WIDTH,
			self.PAGE_COORD_HEIGHT
		},
		right = {
			self.PAGE_COORD_WIDTH,
			0,
			self.PAGE_COORD_WIDTH,
			self.PAGE_COORD_HEIGHT
		}
	}
end

function ComicBookGui:close()
	ComicBookGui.super.close(self)
	self:_unload_pages()
end

function ComicBookGui:_layout()
	self:_disable_dof()
	self:_layout_comic_pages()
	self:_layout_nav_arrows()
	self:_layout_page_bullets()
end

function ComicBookGui:_layout_comic_pages()
	self._pages_panel = self._root_panel:panel({
		h = nil,
		h = self.PAGE_HEIGHT
	})
	self._page_left = self._pages_panel:bitmap({
		h = nil,
		rotation = 0,
		texture_rect = nil,
		texture = "ui/comic_book/raid_comic_01",
		w = nil,
		w = self.PAGE_WIDTH,
		h = self.PAGE_HEIGHT,
		texture_rect = self._texture_rect.left
	})

	self._page_left:set_right(self._pages_panel:w() / 2)

	self._page_right = self._pages_panel:bitmap({
		h = nil,
		rotation = 0,
		texture_rect = nil,
		texture = "ui/comic_book/raid_comic_01",
		w = nil,
		w = self.PAGE_WIDTH,
		h = self.PAGE_HEIGHT,
		texture_rect = self._texture_rect.right
	})

	self._page_right:set_center_x(self._pages_panel:w() / 2)

	self._fake_page = self._pages_panel:bitmap({
		layer = nil,
		visible = false,
		h = nil,
		w = nil,
		w = self.PAGE_WIDTH,
		h = self.PAGE_HEIGHT,
		layer = self._page_left:layer() + 1
	})
end

function ComicBookGui:_layout_nav_arrows()
	local circle_icon = tweak_data.gui:get_full_gui_data("players_icon_outline")
	local left_arrow_panel = self._root_panel:panel({
		h = nil,
		w = nil,
		w = circle_icon.texture_rect[3],
		h = circle_icon.texture_rect[4]
	})

	left_arrow_panel:set_center_x(self._root_panel:w() / 2 - ComicBookGui.ARROW_X_OFFSET)
	left_arrow_panel:set_center_y(self._root_panel:h() / 2)

	self._left_arrow_circle = left_arrow_panel:image_button({
		texture_rect = nil,
		on_click_callback = nil,
		disabled_color = nil,
		highlight_color = nil,
		color = nil,
		texture = nil,
		texture = circle_icon.texture,
		texture_rect = circle_icon.texture_rect,
		color = ComicBookGui.CIRCLE_NORMAL_COLOR,
		highlight_color = ComicBookGui.CIRCLE_HIGHLIGHT_COLOR,
		disabled_color = ComicBookGui.CIRCLE_DISABLED_COLOR,
		on_click_callback = callback(self, self, "_on_left_arrow_clicked")
	})

	self._left_arrow_circle:set_enabled(false)

	self._left_arrow_arrow = left_arrow_panel:bitmap({
		texture_rect = nil,
		color = nil,
		texture = nil,
		texture = tweak_data.gui.icons.ico_page_turn_left.texture,
		texture_rect = tweak_data.gui.icons.ico_page_turn_left.texture_rect,
		color = ComicBookGui.ARROW_DISABLED_COLOR
	})

	self._left_arrow_arrow:set_center(self._left_arrow_circle:center())

	local right_arrow_panel = self._root_panel:panel({
		h = nil,
		w = nil,
		w = circle_icon.texture_rect[3],
		h = circle_icon.texture_rect[4]
	})

	right_arrow_panel:set_center_x(self._root_panel:w() / 2 + ComicBookGui.ARROW_X_OFFSET)
	right_arrow_panel:set_center_y(self._root_panel:h() / 2)

	self._right_arrow_circle = right_arrow_panel:image_button({
		texture_rect = nil,
		on_click_callback = nil,
		disabled_color = nil,
		highlight_color = nil,
		color = nil,
		texture = nil,
		texture = circle_icon.texture,
		texture_rect = circle_icon.texture_rect,
		color = ComicBookGui.CIRCLE_NORMAL_COLOR,
		highlight_color = ComicBookGui.CIRCLE_HIGHLIGHT_COLOR,
		disabled_color = ComicBookGui.CIRCLE_DISABLED_COLOR,
		on_click_callback = callback(self, self, "_on_right_arrow_clicked")
	})
	self._right_arrow_arrow = right_arrow_panel:bitmap({
		texture_rect = nil,
		color = nil,
		texture = nil,
		texture = tweak_data.gui.icons.ico_page_turn_right.texture,
		texture_rect = tweak_data.gui.icons.ico_page_turn_right.texture_rect,
		color = ComicBookGui.ARROW_NORMAL_COLOR
	})

	self._right_arrow_arrow:set_center(self._right_arrow_circle:center())
end

function ComicBookGui:_layout_page_bullets()
	self._bullet_panel = self._root_panel:panel({
		h = nil,
		h = ComicBookGui.BULLET_PANEL_HEIGHT
	})

	self._bullet_panel:set_w(ComicBookGui.TOTAL_PAGE_COUNT * (ComicBookGui.BULLET_WIDTH + ComicBookGui.BULLET_PADDING))
	self._bullet_panel:set_center_x(self._root_panel:w() / 2)
	self._bullet_panel:set_bottom(self._root_panel:h())

	local bullet_empty_icon = tweak_data.gui:get_full_gui_data("bullet_empty")
	local bullet_active_icon = tweak_data.gui:get_full_gui_data("bullet_active")

	for i = 0, ComicBookGui.TOTAL_PAGE_COUNT - 1 do
		local bullet_x = i * (ComicBookGui.BULLET_WIDTH + ComicBookGui.BULLET_PADDING)
		local normal_bullet = self._bullet_panel:image_button({
			h = nil,
			highlight_color = nil,
			x = nil,
			on_click_callback = nil,
			texture_rect = nil,
			color = nil,
			texture = nil,
			w = nil,
			x = bullet_x,
			w = ComicBookGui.BULLET_WIDTH,
			h = ComicBookGui.BULLET_HEIGHT,
			texture = bullet_empty_icon.texture,
			texture_rect = bullet_empty_icon.texture_rect,
			color = ComicBookGui.BULLET_NORMAL_COLOR,
			highlight_color = ComicBookGui.BULLET_HIGHLIGHT_COLOR,
			on_click_callback = callback(self, self, "_on_bullet_clicked", i + 1)
		})

		table.insert(self._bullets_normal, normal_bullet)

		local active_bullet = self._bullet_panel:bitmap({
			h = 0,
			layer = nil,
			x = nil,
			texture_rect = nil,
			texture = nil,
			w = 0,
			x = bullet_x,
			texture = bullet_active_icon.texture,
			texture_rect = bullet_active_icon.texture_rect,
			layer = normal_bullet:layer() + 1
		})

		table.insert(self._bullets_active, active_bullet)
	end

	self._bullets_active[1]:set_size(ComicBookGui.BULLET_WIDTH, ComicBookGui.BULLET_HEIGHT)
end

function ComicBookGui:_preload_pages()
	self._page_textures = {}

	for i = 1, ComicBookGui.TOTAL_PAGE_COUNT do
		local texture = string.format("%s%02d", ComicBookGui.PAGE_TEXTURE_PREFIX, i)

		managers.menu_component:retrieve_texture(texture)
		table.insert(self._page_textures, texture)
	end
end

function ComicBookGui:_unload_pages()
	for _, texture in ipairs(self._page_textures) do
		TextureCache:unretrieve(Idstring(texture))
	end
end

function ComicBookGui:_process_comic_book(previous_page, current_page)
	local t = TimerManager:game():time()

	if self._paper_event_expire_t <= t then
		managers.menu_component:post_event("paper_shuffle_menu")

		self._paper_event_expire_t = t + self.SHUFFLE_EVENT_COOLDOWN
	end

	local on_first_page = current_page == 1
	local on_last_page = current_page == self.TOTAL_PAGE_COUNT

	self._left_arrow_circle:set_enabled(not on_first_page)
	self._right_arrow_circle:set_enabled(not on_last_page)
	self._left_arrow_arrow:set_color(on_first_page and self.ARROW_DISABLED_COLOR or self.ARROW_NORMAL_COLOR)
	self._right_arrow_arrow:set_color(on_last_page and self.ARROW_DISABLED_COLOR or self.ARROW_NORMAL_COLOR)

	local previous_texture = self._page_textures[previous_page]
	local next_texture = self._page_textures[current_page]
	local next_page = current_page - previous_page > 0

	if next_page then
		self._page_right:set_image(next_texture, unpack(self._texture_rect.right))
		self._fake_page:set_image(previous_texture, unpack(self._texture_rect.right))
		self._fake_page:set_x(self._page_right:x())
	else
		self._page_left:set_image(next_texture, unpack(self._texture_rect.left))
		self._fake_page:set_image(previous_texture, unpack(self._texture_rect.left))
		self._fake_page:set_x(self._page_left:x())
	end

	self._fake_page:set_w(ComicBookGui.PAGE_WIDTH)
	self:bind_controller_inputs()

	return next_texture
end

function ComicBookGui:_set_page(page)
	if self._zoomed then
		return
	end

	page = math.clamp(page, 1, ComicBookGui.TOTAL_PAGE_COUNT)

	if self._current_page == page then
		return
	end

	self._previous_page = self._current_page
	self._current_page = page

	if not self._animating_pages then
		self._pages_panel:stop()
		self._pages_panel:animate(callback(self, self, "_animate_pages", self._previous_page))
	end
end

function ComicBookGui:_on_left_arrow_clicked()
	self:_set_page(self._current_page - 1)
end

function ComicBookGui:_on_right_arrow_clicked()
	self:_set_page(self._current_page + 1)
end

function ComicBookGui:_on_bullet_clicked(page)
	self:_set_page(page)
end

function ComicBookGui:_on_zoom_in()
end

function ComicBookGui:_on_zoom_out()
end

function ComicBookGui:move_left()
	self:_on_left_arrow_clicked()

	return ComicBookGui.super.move_left(self)
end

function ComicBookGui:move_right()
	self:_on_right_arrow_clicked()

	return ComicBookGui.super.move_right(self)
end

function ComicBookGui:update(t, dt)
end

function ComicBookGui:bind_controller_inputs()
	local bindings = {}
	local legend = {
		keyboard = nil,
		controller = nil,
		controller = {
			"menu_legend_back"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = nil,
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	if self._current_page > 1 then
		table.insert(legend.controller, "menu_legend_comic_book_left")
	end

	if self._current_page < ComicBookGui.TOTAL_PAGE_COUNT then
		table.insert(legend.controller, "menu_legend_comic_book_right")
	end

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function ComicBookGui:confirm_pressed()
	return false
end

function ComicBookGui:_animate_bullets(params)
	local previous_page = params.previous_page
	local current_page = params.current_page
	local previous_bullet = self._bullets_active[previous_page]
	local current_bullet = self._bullets_active[current_page]
	local previous_center_x, previous_center_y = self._bullets_normal[previous_page]:center()
	local current_center_x, current_center_y = self._bullets_normal[current_page]:center()

	previous_bullet:set_size(ComicBookGui.BULLET_WIDTH, ComicBookGui.BULLET_HEIGHT)
	previous_bullet:set_center(previous_center_x, previous_center_y)
	current_bullet:set_size(0, 0)
	current_bullet:set_center(current_center_x, current_center_y)

	local duration = ComicBookGui.BULLET_ANIMATION_DURATION
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_lerp = Easing.quadratic_in_out(t, 0, 1, duration)
		local current_active_width = ComicBookGui.BULLET_WIDTH * (1 - current_lerp)
		local current_active_height = ComicBookGui.BULLET_HEIGHT * (1 - current_lerp)

		previous_bullet:set_size(current_active_width, current_active_height)
		previous_bullet:set_center(previous_center_x, previous_center_y)

		local current_next_width = ComicBookGui.BULLET_WIDTH * current_lerp
		local current_next_height = ComicBookGui.BULLET_HEIGHT * current_lerp

		current_bullet:set_size(current_next_width, current_next_height)
		current_bullet:set_center(current_center_x, current_center_y)
	end

	previous_bullet:set_size(0, 0)
	previous_bullet:set_center(previous_center_x, previous_center_y)
	current_bullet:set_size(ComicBookGui.BULLET_WIDTH, ComicBookGui.BULLET_HEIGHT)
	current_bullet:set_center(current_center_x, current_center_y)
end

function ComicBookGui:_animate_pages(current_page)
	self._animating_pages = true
	local center_x = self._pages_panel:w() / 2
	local closed_offset = ComicBookGui.PAGE_WIDTH / 2

	repeat
		local previous_page = current_page
		local wanted_page = self._current_page
		local difference = math.abs(wanted_page - previous_page)
		local step = difference > 3 and 2 or 1
		current_page = math.step(current_page, wanted_page, step)

		self._bullet_panel:animate(callback(self, self, "_animate_bullets", {
			current_page = nil,
			previous_page = nil,
			current_page = current_page,
			previous_page = previous_page
		}))

		local next_texture = self:_process_comic_book(previous_page, current_page)

		self._fake_page:show()

		local next_page = previous_page < wanted_page
		local previous_center = self._page_right:x()
		local target_center = center_x

		if current_page == 1 then
			target_center = center_x - closed_offset
		elseif current_page == ComicBookGui.TOTAL_PAGE_COUNT then
			target_center = center_x + closed_offset
		end

		local duration = ComicBookGui.PAGE_ANIMATION_DURATION / difference
		local t = 0

		while duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_lerp = Easing.quadratic_in(t, 0, 1, duration)
			local current_w = math.lerp(ComicBookGui.PAGE_WIDTH, 0, current_lerp)

			self._fake_page:set_w(current_w)

			local current_center = math.lerp(previous_center, target_center, current_lerp / 2)

			self._page_left:set_right(current_center)
			self._page_right:set_left(current_center)

			local current_x = next_page and 0 or current_w

			self._fake_page:set_left(current_center - current_x)
		end

		local texture_rect = next_page and self._texture_rect.left or self._texture_rect.right

		self._fake_page:set_image(next_texture, unpack(texture_rect))
		self._fake_page:set_w(0)

		t = 0

		while duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_lerp = Easing.quadratic_out(t, 0, 1, duration)
			local current_w = math.lerp(0, ComicBookGui.PAGE_WIDTH, current_lerp)

			self._fake_page:set_w(current_w)

			local center_lerp = 0.5 + current_lerp / 2
			local current_center = math.lerp(previous_center, target_center, center_lerp)

			self._page_left:set_right(current_center)
			self._page_right:set_left(current_center)

			local current_x = next_page and current_w or 0

			self._fake_page:set_left(current_center - current_x)
		end

		self._page_left:set_right(target_center)
		self._page_left:set_image(next_texture, unpack(self._texture_rect.left))
		self._page_right:set_left(target_center)
		self._page_right:set_image(next_texture, unpack(self._texture_rect.right))
	until current_page == self._current_page

	self._fake_page:hide()

	self._animating_pages = false
end
