RaidGUIControlAnimatedBitmap = RaidGUIControlAnimatedBitmap or class(RaidGUIControl)

-- Lines 3-26
function RaidGUIControlAnimatedBitmap:init(parent, params)
	RaidGUIControlAnimatedBitmap.super.init(self, parent, params)

	if not self:_params_valid() then
		self._closed = true

		return
	end

	self._object = self._panel:bitmap(self._params)
	self._salt = string.format("%05d", math.random(99999))

	managers.hud:add_updator("animated_bitmap_" .. tostring(self._params.name) .. "_" .. self._salt, callback(self, self, "_update"))

	self._current_frame = 0
	self._initial_x = self._params.texture_rect[1]
	self._initial_y = self._params.texture_rect[2]
	self._w = self._params.texture_rect[3]
	self._h = self._params.texture_rect[4]
	self._loops_left = self._params.loops
	self._frames_in_first_row = math.floor((self._params.texture_width - self._initial_x) / self._w)
	self._frames_in_row = math.floor(self._params.texture_width / self._w)
end

-- Lines 28-58
function RaidGUIControlAnimatedBitmap:_update(t, dt)
	if self._paused then
		return
	end

	if not self._current_frame_t then
		self._current_frame_t = t
	end

	local current_frame = (self._current_frame + math.floor((t - self._current_frame_t) * self._params.framerate)) % self._params.frames

	if current_frame < self._current_frame and (not self._params.loop_forever or self._stop) then
		if not self._loops_left or self._loops_left == 1 or self._stop then
			self:close()

			return
		end

		if self._loops_left then
			self._loops_left = self._loops_left - 1
		end
	end

	if current_frame ~= self._current_frame then
		local text_rect = self:_get_frame(current_frame)

		self._object:set_texture_rect(self:_get_frame(current_frame))

		self._current_frame = current_frame
		self._current_frame_t = t
	end
end

-- Lines 61-72
function RaidGUIControlAnimatedBitmap:_get_frame(frame_index)
	local row, row_index = self:_get_frame_row(frame_index)
	local x = row_index * self._w

	if row == 0 then
		x = x + self._initial_x
	end

	local y = self._initial_y + row * self._h

	return x, y, self._w, self._h
end

-- Lines 75-90
function RaidGUIControlAnimatedBitmap:_get_frame_row(frame_index)
	local row = 0
	local row_index = frame_index

	if self._frames_in_first_row < frame_index + 1 then
		row = 1
		row_index = row_index - self._frames_in_first_row

		while frame_index + 1 > self._frames_in_first_row + row * self._frames_in_row do
			row = row + 1
			row_index = row_index - self._frames_in_row
		end
	end

	return row, row_index
end

-- Lines 92-95
function RaidGUIControlAnimatedBitmap:pause()
	self._paused = true
	self._pause_time = TimerManager:game():time()
end

-- Lines 97-107
function RaidGUIControlAnimatedBitmap:unpause()
	if not self._paused then
		return
	end

	local current_time = TimerManager:game():time()
	self._current_frame_t = self._current_frame_t + current_time - self._pause_time
	self._paused = false
	self._pause_time = nil
end

-- Lines 110-112
function RaidGUIControlAnimatedBitmap:stop()
	self._stop = true
end

-- Lines 114-126
function RaidGUIControlAnimatedBitmap:close()
	if self._closed then
		return
	end

	if not self._params.hold_last_frame then
		self._object:set_visible(false)
	end

	managers.hud:remove_updator("animated_bitmap_" .. tostring(self._params.name) .. "_" .. self._salt)

	self._closed = true
end

-- Lines 130-152
function RaidGUIControlAnimatedBitmap:_params_valid()
	if not self._params.texture then
		Application:error("[RaidGUIControlAnimatedBitmap:init] Texture not specified for the animated bitmap control: ", self._params.name)

		return false
	end

	if not self._params.framerate then
		Application:error("[RaidGUIControlAnimatedBitmap:init] Framerate not specified for the animated bitmap control: ", self._params.name)

		return false
	end

	if not self._params.frames then
		Application:error("[RaidGUIControlAnimatedBitmap:init] Number of frames not specified for the animated bitmap control: ", self._params.name)

		return false
	end

	if not self._params.texture_width then
		Application:error("[RaidGUIControlAnimatedBitmap:init] Texture width not specified for the animated bitmap control: ", self._params.name)

		return false
	end

	return true
end
