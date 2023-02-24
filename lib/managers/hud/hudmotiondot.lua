HUDMotionDot = HUDMotionDot or class()
HUDMotionDot.ICONS = {
	"motion_dot",
	"motion_dot_contour",
	"motion_dot_outline",
	"motion_dot_inline",
	"motion_plus",
	"motion_plus_contour",
	"motion_plus_outline",
	"motion_plus_inline"
}
HUDMotionDot.SIZES = {
	8,
	12,
	16,
	20,
	24,
	32
}
HUDMotionDot.OFFSETS = {
	32,
	64,
	128,
	172,
	256
}
HUDMotionDot.DOT_MODE_OFF = 1
HUDMotionDot.DOT_MODE_OFF_TEMPLATE = {}
HUDMotionDot.DOT_MODE_SINGLE = 2
HUDMotionDot.DOT_MODE_SINGLE_TEMPLATE = {
	{
		0,
		0
	}
}
HUDMotionDot.DOT_MODE_HORIZONTAL = 3
HUDMotionDot.DOT_MODE_HORIZONTAL_TEMPLATE = {
	{
		-1,
		0
	},
	{
		1,
		0
	}
}
HUDMotionDot.DOT_MODE_VERTICAL = 4
HUDMotionDot.DOT_MODE_VERTICAL_TEMPLATE = {
	{
		0,
		1
	},
	{
		0,
		-1
	}
}
HUDMotionDot.DOT_MODE_CORNERS_DIAGONAL = 5
HUDMotionDot.DOT_MODE_CORNERS_DIAGONAL_TEMPLATE = {
	{
		-1,
		-1
	},
	{
		1,
		-1
	},
	{
		-1,
		1
	},
	{
		1,
		1
	}
}
HUDMotionDot.DOT_MODE_CORNERS_ALIGNED = 6
HUDMotionDot.DOT_MODE_CORNERS_ALIGNED_TEMPLATE = {
	{
		-1,
		0
	},
	{
		1,
		0
	},
	{
		0,
		1
	},
	{
		0,
		-1
	}
}
HUDMotionDot.MODES = {
	HUDMotionDot.DOT_MODE_OFF_TEMPLATE,
	HUDMotionDot.DOT_MODE_SINGLE_TEMPLATE,
	HUDMotionDot.DOT_MODE_HORIZONTAL_TEMPLATE,
	HUDMotionDot.DOT_MODE_VERTICAL_TEMPLATE,
	HUDMotionDot.DOT_MODE_CORNERS_DIAGONAL_TEMPLATE,
	HUDMotionDot.DOT_MODE_CORNERS_ALIGNED_TEMPLATE
}

function HUDMotionDot:init(hud)
	self._hud_panel = hud.panel

	Application:debug("[HUDMotionDot] init", hud, hud.panel)
	self:cleanup()

	self._size_icon_index = managers.user:get_setting("motion_dot_size")
	self._offset_index = managers.user:get_setting("motion_dot_offset")
	self._motion_icon_index = managers.user:get_setting("motion_dot_icon")
	self._dot_mode_idx = managers.user:get_setting("motion_dot")
	self._dot_color = Color(1, 1, 1, 1)
	self._motion_icons = {}

	for i = 1, 4 do
		table.insert(self._motion_icons, self:_create_icon("motion_icon_" .. tostring(i), HUDMotionDot.ICONS[self._motion_icon_index]))
		Application:debug("[HUDMotionDot] init -- Made motion_icon_" .. tostring(i))
	end

	if managers.user:get_setting("motion_dot") ~= 0 then
		self:_update_dots()
	end
end

function HUDMotionDot:_create_icon(name, icon)
	local icon_params = {
		valign = "center",
		halign = "center",
		visible = false,
		name = name,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	local icon = self._hud_panel:bitmap(icon_params)

	return icon
end

function HUDMotionDot:on_setting_icons(index)
	if type(index) == "boolean" then
		if index then
			index = 2
		else
			index = 1
		end
	end

	self._motion_icon_index = index <= #HUDMotionDot.ICONS and index or 1
	self._motion_icon_index = self._motion_icon_index < 1 and #HUDMotionDot.ICONS or self._motion_icon_index
	local icon_img = HUDMotionDot.ICONS[self._motion_icon_index]

	print("New icon: " .. icon_img)

	local image = tweak_data.gui.icons[icon_img].texture

	for i, icon in ipairs(self._motion_icons) do
		icon:set_image(image)
	end

	Application:debug("[HUDMotionDot] on_setting_icons", icon_img, index, "/", #HUDMotionDot.ICONS)
end

function HUDMotionDot:on_setting_icons_increment()
	self:on_setting_icons(self._motion_icon_index + 1)
end

function HUDMotionDot:on_setting_sizes(index)
	if type(index) == "boolean" then
		if index then
			index = 2
		else
			index = 1
		end
	end

	self._size_icon_index = index
	self._size_icon_index = index <= #HUDMotionDot.SIZES and index or 1
	self._size_icon_index = self._size_icon_index < 1 and #HUDMotionDot.SIZES or self._size_icon_index

	self:_update_dots()
end

function HUDMotionDot:on_setting_sizes_increment()
	self:on_setting_sizes(self._size_icon_index + 1)
end

function HUDMotionDot:on_setting_offsets(index)
	if type(index) == "boolean" then
		if index then
			index = 2
		else
			index = 1
		end
	end

	self._offset_index = index
	self._offset_index = index <= #HUDMotionDot.OFFSETS and index or 1
	self._offset_index = self._offset_index < 1 and #HUDMotionDot.OFFSETS or self._offset_index

	self:_update_dots()
end

function HUDMotionDot:on_setting_offsets_increment()
	self:on_setting_offsets((self._offset_index or 1) + 1)
end

function HUDMotionDot:_update_dots()
	local offset = HUDMotionDot.OFFSETS[self._offset_index]
	local center_screen_x = self._hud_panel:w() / 2
	local center_screen_y = self._hud_panel:h() / 2
	local template = HUDMotionDot.MODES[self._dot_mode_idx]
	local size = HUDMotionDot.SIZES[self._size_icon_index]

	for i, icon in ipairs(self._motion_icons) do
		local tgt_x = center_screen_x
		local tgt_y = center_screen_y

		if not template or i > #template then
			icon:set_visible(false)
			Application:debug("[HUDMotionDot] _realign_dots - hid a dot")
		else
			icon:set_visible(true)
			Application:debug("[HUDMotionDot] _realign_dots - showed a dot")

			tgt_x = tgt_x + template[i][1] * offset
			tgt_y = tgt_y + template[i][2] * offset

			icon:set_width(size)
			icon:set_height(size)
			icon:set_center(tgt_x, tgt_y)
			icon:set_color(self._dot_color)
		end
	end

	Application:debug("[HUDMotionDot] on_setting_offsets", self._offset_index, offset)
end

function HUDMotionDot:on_setting_counts(index)
	if type(index) == "boolean" then
		if index then
			index = 2
		else
			index = 1
		end
	end

	self._dot_mode_idx = index
	self._dot_mode_idx = index <= #HUDMotionDot.MODES and index or 1
	self._dot_mode_idx = self._dot_mode_idx < 1 and #HUDMotionDot.MODES or self._dot_mode_idx

	Application:debug("[HUDMotionDot] on_setting_counts", self._dot_mode_idx)
	self:_update_dots()
end

function HUDMotionDot:on_setting_counts_increment()
	self:on_setting_counts(self._dot_mode_idx + 1)
end

function HUDMotionDot:on_setting_color(color)
	self._dot_color = color

	for _, icon in ipairs(self._motion_icons) do
		icon:stop()
	end

	self._silly_mode = false

	self:_update_dots()
end

function HUDMotionDot:on_setting_color_silly()
	self._silly_mode = true

	for _, icon in ipairs(self._motion_icons) do
		icon:stop()
		icon:animate(callback(self, self, "_animate_silly"), callback(self, self, "show_done"))
	end
end

function HUDMotionDot:_animate_silly(item_ref, done_cb)
	local t = 0

	while self._silly_mode == true do
		local dt = coroutine.yield()
		t = t + dt

		item_ref:set_color(Color(math.max(0.25, math.sin(t * 13)), math.max(0.25, math.sin(t * 69)), math.max(0.25, math.sin(t * 420))))
	end

	done_cb()
end

function HUDMotionDot:show_done()
end

function HUDMotionDot:cleanup()
	for i = 1, 4 do
		if self._hud_panel:child("motion_icon_" .. tostring(i)) then
			self._hud_panel:remove(self._hud_panel:child("motion_icon_" .. tostring(i)))
		end
	end
end

function HUDMotionDot:set_fade_hide_dots()
	for i, icon in ipairs(self._motion_icons) do
		icon:set_visible(false)
	end
end

function HUDMotionDot:set_fade_show_dots()
	self:_update_dots()
end
