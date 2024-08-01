if core then
	core:module("CoreGuiDataManager")
end

GuiDataManager = GuiDataManager or class()

-- Lines 7-15
function GuiDataManager:init(scene_gui, res, safe_rect_pixels, safe_rect, static_aspect_ratio)
	self._scene_gui = scene_gui
	self._static_resolution = res
	self._safe_rect_pixels = safe_rect_pixels
	self._safe_rect = safe_rect
	self._static_aspect_ratio = static_aspect_ratio

	self:_setup_workspace_data()
end

-- Lines 17-19
function GuiDataManager:destroy()
end

-- Lines 21-25
function GuiDataManager:create_saferect_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_workspace(ws)

	return ws
end

-- Lines 27-31
function GuiDataManager:create_fullscreen_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_fullscreen_workspace(ws)

	return ws
end

-- Lines 33-37
function GuiDataManager:create_fullscreen_16_9_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_fullscreen_16_9_workspace(ws)

	return ws
end

-- Lines 39-43
function GuiDataManager:create_corner_saferect_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_corner_saferect_workspace(ws)

	return ws
end

-- Lines 45-49
function GuiDataManager:create_1280_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_1280_workspace(ws)

	return ws
end

-- Lines 51-55
function GuiDataManager:create_corner_saferect_1280_workspace()
	local ws = (self._scene_gui or Overlay:gui()):create_scaled_screen_workspace(10, 10, 10, 10, 10)

	self:layout_corner_saferect_1280_workspace(ws)

	return ws
end

-- Lines 58-60
function GuiDataManager:destroy_workspace(ws)
	(self._scene_gui or Overlay:gui()):destroy_workspace(ws)
end

-- Lines 62-64
function GuiDataManager:get_scene_gui()
	return self._scene_gui or Overlay:gui()
end

-- Lines 69-75
function GuiDataManager:_get_safe_rect_pixels()
	if self._safe_rect_pixels then
		return self._safe_rect_pixels
	end

	return managers.viewport:get_safe_rect_pixels()
end

-- Lines 77-83
function GuiDataManager:_get_safe_rect()
	if self._safe_rect then
		return self._safe_rect
	end

	return managers.viewport:get_safe_rect()
end

-- Lines 85-91
function GuiDataManager:_aspect_ratio()
	if self._static_aspect_ratio then
		return self._static_aspect_ratio
	end

	return managers.viewport:aspect_ratio()
end

local base_res = {
	x = 1920,
	y = 1080
}

-- Lines 95-237
function GuiDataManager:_setup_workspace_data()
	print("[GuiDataManager:_setup_workspace_data]")

	self._saferect_data = {}
	self._corner_saferect_data = {}
	self._fullrect_data = {}
	self._fullrect_16_9_data = {}
	self._fullrect_1280_data = {}
	self._corner_saferect_1280_data = {}
	local safe_rect = self:_get_safe_rect_pixels()
	local scaled_size = self:scaled_size()
	local res = self._static_resolution or RenderSettings.resolution
	local scaled_w = scaled_size.width
	local scaled_h = scaled_size.height
	local scaled_aspect = scaled_w / scaled_h
	local safe_h = math.min(safe_rect.height, safe_rect.width / scaled_aspect)
	local safe_w = math.min(safe_rect.width, safe_rect.height * scaled_aspect)
	local safe_x = (res.x - safe_h * scaled_aspect) / 2
	local safe_y = (res.y - safe_w / scaled_aspect) / 2
	self._safe_x = safe_x
	self._safe_y = safe_y
	self._saferect_data.w = scaled_w
	self._saferect_data.h = scaled_h
	self._saferect_data.width = scaled_w
	self._saferect_data.height = scaled_h
	self._saferect_data.x = safe_x
	self._saferect_data.y = safe_y
	self._saferect_data.on_screen_width = safe_w
	local h_c = scaled_w / (safe_rect.width / safe_rect.height)
	scaled_h = math.max(scaled_h, h_c)
	local w_c = h_c / scaled_h
	scaled_w = math.max(scaled_w, scaled_w / w_c)
	self._corner_saferect_data.w = scaled_w
	self._corner_saferect_data.h = scaled_h
	self._corner_saferect_data.width = scaled_w
	self._corner_saferect_data.height = scaled_h
	self._corner_saferect_data.x = safe_rect.x
	self._corner_saferect_data.y = safe_rect.y
	self._corner_saferect_data.on_screen_width = safe_rect.width
	safe_h = base_res.x / self:_aspect_ratio()
	scaled_h = math.max(base_res.y, safe_h)
	safe_w = safe_h / scaled_h
	scaled_w = math.max(base_res.x, base_res.x / safe_w)
	self._fullrect_data.w = scaled_w
	self._fullrect_data.h = scaled_h
	self._fullrect_data.width = scaled_w
	self._fullrect_data.height = scaled_h
	self._fullrect_data.x = 0
	self._fullrect_data.y = 0
	self._fullrect_data.on_screen_width = res.x
	self._fullrect_data.convert_x = math.floor((scaled_w - self._saferect_data.w) / 2)
	self._fullrect_data.convert_y = (scaled_h - scaled_size.height) / 2
	self._fullrect_data.corner_convert_x = math.floor((self._fullrect_data.width - self._corner_saferect_data.width) / 2)
	self._fullrect_data.corner_convert_y = math.floor((self._fullrect_data.height - self._corner_saferect_data.height) / 2)
	scaled_w = base_res.x
	scaled_h = base_res.y
	safe_h = math.min(res.y, res.x / scaled_aspect)
	safe_w = math.min(res.x, res.y * scaled_aspect)
	local safe_x = (res.x - safe_h * scaled_aspect) / 2
	local safe_y = (res.y - safe_w / scaled_aspect) / 2
	self._fullrect_16_9_data.w = scaled_w
	self._fullrect_16_9_data.h = scaled_h
	self._fullrect_16_9_data.width = scaled_w
	self._fullrect_16_9_data.height = scaled_h
	self._fullrect_16_9_data.x = safe_x
	self._fullrect_16_9_data.y = safe_y
	self._fullrect_16_9_data.on_screen_width = safe_w
	self._fullrect_16_9_data.convert_x = math.floor((self._fullrect_16_9_data.w - self._saferect_data.w) / 2)
	self._fullrect_16_9_data.convert_y = (self._fullrect_16_9_data.h - self._saferect_data.h) / 2
	local aspect = math.clamp(res.x / res.y, 1, 1.7777777777777777)
	scaled_w = base_res.x
	scaled_h = base_res.x / aspect
	safe_w = math.min(res.x, res.y * aspect)
	safe_h = safe_w / scaled_w * scaled_h
	safe_x = (res.x - safe_w) / 2
	safe_y = (res.y - safe_h) / 2
	self._fullrect_1280_data.w = scaled_w
	self._fullrect_1280_data.h = scaled_h
	self._fullrect_1280_data.width = scaled_w
	self._fullrect_1280_data.height = scaled_h
	self._fullrect_1280_data.x = safe_x
	self._fullrect_1280_data.y = safe_y
	self._fullrect_1280_data.on_screen_width = safe_w
	self._fullrect_1280_data.safe_w = safe_w
	self._fullrect_1280_data.safe_h = safe_h
	self._fullrect_1280_data.aspect = aspect
	self._fullrect_1280_data.convert_x = math.floor((self._fullrect_data.w - self._fullrect_1280_data.w) / 2)
	self._fullrect_1280_data.convert_y = math.floor((self._fullrect_data.h - self._fullrect_1280_data.h) / 2)
	scaled_w = scaled_size.width
	scaled_h = scaled_size.width / aspect
	safe_w = math.min(safe_rect.width, safe_rect.height * aspect)
	safe_h = safe_w / scaled_w * scaled_h
	safe_x = (res.x - safe_w) / 2
	safe_y = (res.y - safe_h) / 2
	self._corner_saferect_1280_data.w = scaled_w
	self._corner_saferect_1280_data.h = scaled_h
	self._corner_saferect_1280_data.width = scaled_w
	self._corner_saferect_1280_data.height = scaled_h
	self._corner_saferect_1280_data.x = safe_x
	self._corner_saferect_1280_data.y = safe_y
	self._corner_saferect_1280_data.on_screen_width = safe_w
end

-- Lines 239-241
function GuiDataManager:layout_workspace(ws)
	ws:set_screen(self._saferect_data.w, self._saferect_data.h, self._saferect_data.x, self._saferect_data.y, self._saferect_data.on_screen_width)
end

-- Lines 243-245
function GuiDataManager:layout_fullscreen_workspace(ws)
	ws:set_screen(self._fullrect_data.w, self._fullrect_data.h, self._fullrect_data.x, self._fullrect_data.y, self._fullrect_data.on_screen_width)
end

-- Lines 247-249
function GuiDataManager:layout_fullscreen_16_9_workspace(ws)
	ws:set_screen(self._fullrect_16_9_data.w, self._fullrect_16_9_data.h, self._fullrect_16_9_data.x, self._fullrect_16_9_data.y, self._fullrect_16_9_data.on_screen_width)
end

-- Lines 251-253
function GuiDataManager:layout_corner_saferect_workspace(ws)
	ws:set_screen(self._corner_saferect_data.w, self._corner_saferect_data.h, self._corner_saferect_data.x, self._corner_saferect_data.y, self._corner_saferect_data.on_screen_width)
end

-- Lines 255-257
function GuiDataManager:layout_1280_workspace(ws)
	ws:set_screen(self._fullrect_1280_data.w, self._fullrect_1280_data.h, self._fullrect_1280_data.x, self._fullrect_1280_data.y, self._fullrect_1280_data.on_screen_width)
end

-- Lines 259-261
function GuiDataManager:layout_corner_saferect_1280_workspace(ws)
	ws:set_screen(self._corner_saferect_1280_data.w, self._corner_saferect_1280_data.h, self._corner_saferect_1280_data.x, self._corner_saferect_1280_data.y, self._corner_saferect_1280_data.on_screen_width)
end

-- Lines 276-281
function GuiDataManager:scaled_size()
	local w = math.round(self:_get_safe_rect().width * base_res.x)
	local h = math.round(self:_get_safe_rect().height * base_res.y)

	return {
		x = 0,
		y = 0,
		width = w,
		height = h
	}
end

-- Lines 283-285
function GuiDataManager:safe_scaled_size()
	return self._saferect_data
end

-- Lines 287-289
function GuiDataManager:corner_scaled_size()
	return self._corner_saferect_data
end

-- Lines 291-293
function GuiDataManager:full_scaled_size()
	return self._fullrect_data
end

-- Lines 295-297
function GuiDataManager:full_16_9_size()
	return self._fullrect_16_9_data
end

-- Lines 299-301
function GuiDataManager:full_1280_size()
	return self._fullrect_1280_data
end

-- Lines 304-307
function GuiDataManager:full_to_full_16_9(in_x, in_y)
	return self:safe_to_full_16_9(self:full_to_safe(in_x, in_y))
end

-- Lines 309-311
function GuiDataManager:safe_to_full_16_9(in_x, in_y)
	return self._fullrect_16_9_data.convert_x + in_x, self._fullrect_16_9_data.convert_y + in_y
end

-- Lines 313-315
function GuiDataManager:full_16_9_to_safe(in_x, in_y)
	return in_x - self._fullrect_16_9_data.convert_x, in_y - self._fullrect_16_9_data.convert_y
end

-- Lines 318-320
function GuiDataManager:safe_to_full(in_x, in_y)
	return self._fullrect_data.convert_x + in_x, self._fullrect_data.convert_y + in_y
end

-- Lines 322-324
function GuiDataManager:full_to_safe(in_x, in_y)
	return in_x - self._fullrect_data.convert_x, in_y - self._fullrect_data.convert_y
end

-- Lines 326-328
function GuiDataManager:corner_safe_to_full(in_x, in_y)
	return self._fullrect_data.corner_convert_x + in_x, self._fullrect_data.corner_convert_y + in_y
end

-- Lines 330-332
function GuiDataManager:y_safe_to_full(in_y)
	return self._fullrect_data.convert_y + in_y
end

-- Lines 334-336
function GuiDataManager:resolution_changed()
	self:_setup_workspace_data()
end
