RaidGUIControlImage = RaidGUIControlImage or class(RaidGUIControl)

-- Lines 3-20
function RaidGUIControlImage:init(parent, params)
	RaidGUIControlImage.super.init(self, parent, params)

	if not self._params.texture then
		Application:error("[RaidGUIControlImage:init] Texture not specified for the image control: ", self._params.name)

		return
	end

	self._on_mouse_pressed_callback = params.on_mouse_pressed_callback
	self._on_mouse_released_callback = params.on_mouse_released_callback

	if self._params.vertical == "center" then
		self._params.y = (self._params.panel:h() - self._params.h) / 2
	end

	self._object = self._panel:bitmap(self._params)
end

-- Lines 22-24
function RaidGUIControlImage:set_color(color)
	self._object:set_color(color)
end

-- Lines 26-28
function RaidGUIControlImage:color()
	return self._object:color()
end

-- Lines 30-32
function RaidGUIControlImage:set_image(texture)
	self._object:set_image(texture)
end

-- Lines 34-36
function RaidGUIControlImage:set_texture_rect(rect)
	self._object:set_texture_rect(unpack(rect))
end

-- Lines 38-45
function RaidGUIControlImage:on_mouse_pressed(o, button, x, y)
	if self._on_mouse_pressed_callback then
		self._on_mouse_pressed_callback()

		return true
	end

	return false
end

-- Lines 47-54
function RaidGUIControlImage:mouse_released(o, button, x, y)
	if self._on_mouse_released_callback then
		self._on_mouse_released_callback()

		return true
	end

	return false
end

-- Lines 56-58
function RaidGUIControlImage:center()
	return self._object:center()
end

-- Lines 60-62
function RaidGUIControlImage:set_center(x, y)
	self._object:set_center(x, y)
end

-- Lines 64-66
function RaidGUIControlImage:set_center_x(x)
	self._object:set_center_x(x)
end
