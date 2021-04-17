RaidGUIControlImageViewer = RaidGUIControlImageViewer or class(RaidGUIControl)
RaidGUIControlImageViewer.ANIMATION_DURATION = 2
RaidGUIControlImageViewer.ANIMATION_WAIT = 5
RaidGUIControlImageViewer.BULLET_PANEL_HEIGHT = 32
RaidGUIControlImageViewer.BULLET_WIDTH = 16
RaidGUIControlImageViewer.BULLET_HEIGHT = 16
RaidGUIControlImageViewer.BULLET_PADDING = 2

-- Lines 10-16
function RaidGUIControlImageViewer:init(parent, params)
	RaidGUIControlImageViewer.super.init(self, parent, params)

	self._object = self._panel:panel(self._params)

	self:_layout()
end

-- Lines 18-36
function RaidGUIControlImageViewer:_layout()
	self._image_frames = {}
	self._bullets = {}
	self._bullets_active = {}
	self._image_frame_1 = self._object:bitmap({
		name = "_image_frame_1",
		alpha = 1,
		y = 0,
		x = 0,
		w = self._params.w,
		h = self._params.h - RaidGUIControlImageViewer.BULLET_PANEL_HEIGHT,
		layer = self._object:layer() + 1,
		texture = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture,
		texture_rect = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture_rect
	})

	table.insert(self._image_frames, self._image_frame_1)

	self._image_frame_2 = self._object:bitmap({
		name = "_image_frame_2",
		alpha = 1,
		y = 0,
		x = self._params.w,
		w = self._params.w,
		h = self._params.h - RaidGUIControlImageViewer.BULLET_PANEL_HEIGHT,
		layer = self._object:layer() + 1,
		texture = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture,
		texture_rect = tweak_data.gui.icons.intel_table_opp_img_herr_a.texture_rect
	})

	table.insert(self._image_frames, self._image_frame_2)

	self._bullet_panel = self._object:panel({
		x = 0,
		y = self._image_frame_1:h(),
		w = self._params.w,
		h = RaidGUIControlImageViewer.BULLET_PANEL_HEIGHT
	})
end

-- Lines 38-49
function RaidGUIControlImageViewer:set_data(item_value)
	self._object:stop()
	self:_reset_animation_state()

	if item_value then
		self._data = item_value

		self:start()
	end
end

-- Lines 51-68
function RaidGUIControlImageViewer:_reset_animation_state()
	self._image_frames[1]:set_x(0)
	self._image_frames[2]:set_x(self._params.w)

	if self._bullets_active then
		for i = 1, #self._bullets_active do
			self._bullet_panel:remove(self._bullets_active[i])

			self._bullets_active[i] = nil
		end
	end

	if self._bullets then
		for i = 1, #self._bullets do
			self._bullet_panel:remove(self._bullets[i])

			self._bullets[i] = nil
		end
	end
end

-- Lines 70-97
function RaidGUIControlImageViewer:start()
	if not self._data then
		return
	end

	self._image_frames[1]:set_image(self._data[1].texture)
	self._image_frames[1]:set_texture_rect(unpack(self._data[1].texture_rect))

	if #self._data > 1 then
		for i = 1, #self._data do
			table.insert(self._bullets, self._bullet_panel:bitmap({
				x = (i - 1) * (RaidGUIControlImageViewer.BULLET_WIDTH + RaidGUIControlImageViewer.BULLET_PADDING),
				y = RaidGUIControlImageViewer.BULLET_HEIGHT / 2,
				w = RaidGUIControlImageViewer.BULLET_WIDTH,
				h = RaidGUIControlImageViewer.BULLET_HEIGHT,
				layer = self._object:layer() + 1,
				texture = tweak_data.gui.icons.bullet_empty.texture,
				texture_rect = tweak_data.gui.icons.bullet_empty.texture_rect
			}))
			table.insert(self._bullets_active, self._bullet_panel:bitmap({
				h = 0,
				w = 0,
				x = (i - 1) * (RaidGUIControlImageViewer.BULLET_WIDTH + RaidGUIControlImageViewer.BULLET_PADDING),
				y = RaidGUIControlImageViewer.BULLET_HEIGHT / 2,
				layer = self._object:layer() + 2,
				texture = tweak_data.gui.icons.bullet_active.texture,
				texture_rect = tweak_data.gui.icons.bullet_active.texture_rect
			}))
		end

		self._bullet_panel:set_w(#self._data * (RaidGUIControlImageViewer.BULLET_WIDTH + RaidGUIControlImageViewer.BULLET_PADDING))
		self._bullet_panel:set_center_x(self._params.w / 2)
		self._object:animate(callback(self, self, "_animate_image_rotation"))
	end
end

-- Lines 99-199
function RaidGUIControlImageViewer:_animate_image_rotation()
	self._current_image_index = 1
	self._active_image_frame = 1

	self._image_frames[1]:set_image(self._data[1].texture)
	self._image_frames[1]:set_texture_rect(unpack(self._data[1].texture_rect))
	self._bullets_active[1]:set_w(RaidGUIControlImageViewer.BULLET_WIDTH)
	self._bullets_active[1]:set_h(RaidGUIControlImageViewer.BULLET_HEIGHT)
	self._bullets_active[1]:set_center_x(self._bullets[1]:center_x())
	self._bullets_active[1]:set_center_y(self._bullets[1]:center_y())
	wait(RaidGUIControlImageViewer.ANIMATION_WAIT)

	while true do
		local next_image_index = self:_get_next_index(self._current_image_index, #self._data)
		local next_frame_index = self:_get_next_index(self._active_image_frame, 2)

		self._image_frames[next_frame_index]:set_image(self._data[next_image_index].texture)
		self._image_frames[next_frame_index]:set_texture_rect(unpack(self._data[next_image_index].texture_rect))

		local t = 0
		local animation_duration = RaidGUIControlImageViewer.ANIMATION_DURATION
		local distance = self._params.w

		while t < animation_duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_distance = dt / animation_duration * distance

			for _, image_frame in ipairs(self._image_frames) do
				image_frame:set_x(image_frame:x() - current_distance)
			end

			local active_bullet_center_x = self._bullets[self._current_image_index]:center_x()
			local active_bullet_center_y = self._bullets[self._current_image_index]:center_y()
			local next_bullet_center_x = self._bullets[next_image_index]:center_x()
			local next_bullet_center_y = self._bullets[next_image_index]:center_y()

			if t < animation_duration / 2 then
				local current_active_width = (animation_duration / 2 - t) / (animation_duration / 2) * RaidGUIControlImageViewer.BULLET_WIDTH
				local current_active_height = (animation_duration / 2 - t) / (animation_duration / 2) * RaidGUIControlImageViewer.BULLET_HEIGHT

				self._bullets_active[self._current_image_index]:set_w(current_active_width)
				self._bullets_active[self._current_image_index]:set_h(current_active_height)
				self._bullets_active[self._current_image_index]:set_center_x(active_bullet_center_x)
				self._bullets_active[self._current_image_index]:set_center_y(active_bullet_center_y)
			elseif t > animation_duration / 2 then
				local current_next_width = (t - animation_duration / 2) / (animation_duration / 2) * RaidGUIControlImageViewer.BULLET_WIDTH
				local current_next_height = (t - animation_duration / 2) / (animation_duration / 2) * RaidGUIControlImageViewer.BULLET_HEIGHT

				self._bullets_active[next_image_index]:set_w(current_next_width)
				self._bullets_active[next_image_index]:set_h(current_next_height)
				self._bullets_active[next_image_index]:set_center_x(next_bullet_center_x)
				self._bullets_active[next_image_index]:set_center_y(next_bullet_center_y)
			end
		end

		self._image_frames[self._active_image_frame]:set_x(self._params.w)
		self._image_frames[next_frame_index]:set_x(0)

		self._current_image_index = next_image_index
		self._active_image_frame = next_frame_index

		wait(RaidGUIControlImageViewer.ANIMATION_WAIT)
	end
end

-- Lines 201-209
function RaidGUIControlImageViewer:_get_next_index(current_index, table_size)
	local next_index = (current_index + 1) % table_size

	if next_index == 0 then
		next_index = table_size
	end

	return next_index
end

-- Lines 211-215
function RaidGUIControlImageViewer:destroy()
	self._object:stop()
	self:_reset_animation_state()
end
