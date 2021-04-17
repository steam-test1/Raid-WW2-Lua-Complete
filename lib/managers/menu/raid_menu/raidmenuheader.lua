RaidMenuHeader = RaidMenuHeader or class(RaidGuiBase)
RaidMenuHeader.HEIGHT = 2 * RaidGuiBase.PADDING + 22

-- Lines 5-7
function RaidMenuHeader:init(ws, fullscreen_ws, node, component_name)
	RaidMenuHeader.super.init(self, ws, fullscreen_ws, node, component_name)
end

-- Lines 9-29
function RaidMenuHeader:_layout()
	self._screen_name_label = self._root_panel:label_title({
		text = "",
		name = "screen_name_label",
		x = 0,
		y = 0
	})
	self._screen_subtitle_label = self._root_panel:label_subtitle({
		text = "",
		name = "screen_subtitle_label",
		x = 0,
		y = self._screen_name_label:h() + RaidGuiBase.PADDING + 22
	})
end

-- Lines 33-40
function RaidMenuHeader:_setup_properties()
	self._panel_x = 0
	self._panel_y = 0
	self._panel_w = self._ws:width()
	self._panel_h = RaidMenuHeader.HEIGHT
	self._panel_layer = RaidGuiBase.FOREGROUND_LAYER
	self._panel_is_root_panel = true
end

-- Lines 43-60
function RaidMenuHeader:set_screen_name(screen_name_id, subtitle)
	local text = utf8.to_upper(managers.localization:text(screen_name_id))

	self._screen_name_label:set_text(text)

	local _, _, w, h = self._screen_name_label:text_rect()

	self._screen_name_label:set_w(w)
	self._screen_name_label:set_h(h)

	if subtitle then
		local subtitle_text = utf8.to_upper(managers.localization:text(subtitle))

		self._screen_subtitle_label:set_text(subtitle_text)

		local _, _, w, h = self._screen_subtitle_label:text_rect()

		self._screen_subtitle_label:set_w(w)
		self._screen_subtitle_label:set_h(h)
	end
end

-- Lines 62-67
function RaidMenuHeader:set_screen_name_raw(text)
	self._screen_name_label:set_text(text)

	local _, _, w, h = self._screen_name_label:text_rect()

	self._screen_name_label:set_w(w)
	self._screen_name_label:set_h(h)
end

-- Lines 70-77
function RaidMenuHeader:set_header_icon(icon_data)
	self._header_icon = self._root_panel:image({
		name = "header_icon",
		y = 0,
		x = 0,
		w = icon_data.tex_rect[3],
		h = icon_data.tex_rect[4],
		texture = icon_data.texture,
		texture_rect = icon_data.tex_rect,
		color = icon_data.color
	})
	local x = self._screen_name_label:left()

	self._screen_name_label:set_x(x + icon_data.tex_rect[3] + 16)
end

-- Lines 79-82
function RaidMenuHeader:get_screen_name_rect()
	local x, y, w, h = self._screen_name_label:text_rect()

	return x, y, w, h
end

-- Lines 84-91
function RaidMenuHeader:set_character_name(character_name)
	local full_name = ""
	local steam_name = managers.network:session():local_peer():name()
	full_name = character_name .. " (" .. steam_name .. ")"
end

-- Lines 94-95
function RaidMenuHeader:back_pressed()
end

-- Lines 97-98
function RaidMenuHeader:on_escape()
end

-- Lines 100-102
function RaidMenuHeader:confirm_pressed()
	return false
end
