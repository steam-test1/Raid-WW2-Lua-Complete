RaidGUIControlServerPlayerDescription = RaidGUIControlServerPlayerDescription or class(RaidGUIControl)

function RaidGUIControlServerPlayerDescription:init(parent, params)
	RaidGUIControlServerPlayerDescription.super.init(self, parent, params)

	self._selected = false
	self._object = self._panel:panel(params)

	self:_create_selector()
	self:_layout()

	self._on_selected_callback = params.on_selected_callback
	self._xuid = nil
end

function RaidGUIControlServerPlayerDescription:_create_selector()
	local selector_params = {
		visible = false,
		name = "selector",
		layer = 1,
		color = tweak_data.gui.colors.raid_list_background
	}
	self._selector = self._object:rect(selector_params)
end

function RaidGUIControlServerPlayerDescription:_layout()
	local class_icon = tweak_data.gui.icons.ico_class_assault
	self._class_icon = self._object:bitmap({
		x = 0,
		y = 0,
		name = "class_icon",
		texture = class_icon.texture,
		texture_rect = class_icon.texture_rect,
		layer = self._selector:layer() + 1
	})

	self._class_icon:hide()

	self._player_name = self._object:label({
		name = "player_name",
		y = 0,
		x = 80,
		text = "PLAYER NAME 1",
		vertical = "center",
		align = "left",
		h = 64,
		w = 336,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._selector:layer() + 1
	})

	self._player_name:hide()

	self._player_class_nation = self._object:label({
		name = "player_class_nation",
		y = 32,
		x = 80,
		text = "INFILTRATOR  |  GERMAN",
		vertical = "center",
		align = "left",
		h = 64,
		w = 336,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey_effects,
		layer = self._selector:layer() + 1
	})

	self._player_class_nation:hide()

	self._host_icon = self._object:bitmap({
		x = 416,
		y = 16,
		name = "host_icon",
		texture = tweak_data.gui.icons.player_panel_host_indicator.texture,
		texture_rect = tweak_data.gui.icons.player_panel_host_indicator.texture_rect,
		layer = self._selector:layer() + 1
	})

	self._host_icon:hide()

	self._player_level = self._object:label({
		name = "player_level",
		y = 0,
		x = 450,
		text = "17",
		vertical = "center",
		align = "right",
		h = 64,
		w = 64,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._selector:layer() + 1
	})

	self._player_level:hide()
end

function RaidGUIControlServerPlayerDescription:set_data(data)
	if data == NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO or not data then
		self:hide()
	else
		self:show()

		local data_list = string.split(data or "", ",")
		local level = data_list[1] or ""
		local class = data_list[2] or ""
		local name = data_list[3] or ""
		local nationality = data_list[4] or ""
		local class_icon_data = tweak_data.gui.icons["ico_class_" .. class]

		if class_icon_data then
			self._class_icon:set_image(class_icon_data.texture, unpack(class_icon_data.texture_rect))
			self._class_icon:show()
		else
			self._class_icon:hide()
		end

		self._class_icon:set_center_x(32)
		self._class_icon:set_center_y(48)
		self._class_icon:show()

		if managers.user:get_setting("capitalize_names") then
			name = utf8.to_upper(name)
		end

		self._player_name:set_text(name)
		self._player_name:show()

		if class and tweak_data.skilltree.classes[class] and nationality then
			self._player_class_nation:set_text(utf8.to_upper(self:translate(tweak_data.skilltree.classes[class].name_id, true) .. "  |  " .. self:translate("nationality_" .. nationality, true)))
			self._player_class_nation:show()
		else
			self._player_class_nation:hide()
		end

		self._player_level:set_text(level)

		local x1, y1, w1, h1 = self._player_level:text_rect()

		self._player_level:set_w(w1)
		self._player_level:set_right(self._object:w() - self._class_icon:x())
		self._player_level:show()
		self._host_icon:set_right(self._player_level:x() - 12)

		self._xuid = nil

		if data_list[5] then
			local xuid = Xuid.from_string(data_list[5])

			if xuid then
				self._xuid = xuid
			end
		end
	end
end

function RaidGUIControlServerPlayerDescription:set_host(flag)
	if flag then
		self._host_icon:show()
	else
		self._host_icon:hide()
	end
end

function RaidGUIControlServerPlayerDescription:set_selected(value)
	self._selected = value

	self._selector:set_visible(self._selected)

	if self._selected and self._on_selected_callback then
		self._on_selected_callback()
	end
end

function RaidGUIControlServerPlayerDescription:show()
	self._object:show()
end

function RaidGUIControlServerPlayerDescription:hide()
	self._object:hide()
end

function RaidGUIControlServerPlayerDescription:confirm_pressed()
	if self._selected and self._xuid then
		RaidMenuCallbackHandler.view_gamer_card(self._xuid)
	end
end
