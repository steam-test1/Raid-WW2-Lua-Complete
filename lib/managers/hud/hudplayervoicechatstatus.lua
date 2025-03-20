HUDPlayerVoiceChatStatus = HUDPlayerVoiceChatStatus or class()
HUDPlayerVoiceChatStatus.DEFAULT_X = 0
HUDPlayerVoiceChatStatus.DEFAULT_W = 256
HUDPlayerVoiceChatStatus.DEFAULT_H = 32
HUDPlayerVoiceChatStatus.PLAYER_NAME_H = 24
HUDPlayerVoiceChatStatus.PLAYER_NAME_FONT = "din_compressed_outlined_22"
HUDPlayerVoiceChatStatus.PLAYER_NAME_FONT_SIZE = 18
HUDPlayerVoiceChatStatus.CHAT_ICON_SPEAKING = "voice_chat_talking_icon"
HUDPlayerVoiceChatStatus.CHAT_PANEL_W = 32
HUDPlayerVoiceChatStatus.CHAT_ICON_BG_BLACK = "voice_chat_bg_black_icon"

function HUDPlayerVoiceChatStatus:init(index, parent_panel)
	self:_create_panel(index, parent_panel)
	self:_create_background()
	self:_create_player_name()
	self:_create_voice_chat_indicator()
	self:hide_chat_indicator()
end

function HUDPlayerVoiceChatStatus:_create_panel(index, parent_panel)
	local panel_params = {
		halign = "right",
		valign = "top",
		x = HUDPlayerVoiceChatStatus.DEFAULT_X,
		y = index * HUDPlayerVoiceChatStatus.DEFAULT_H,
		w = HUDPlayerVoiceChatStatus.DEFAULT_W,
		h = HUDPlayerVoiceChatStatus.DEFAULT_H,
		layer = tweak_data.gui.PLAYER_PANELS_LAYER
	}
	self._object = parent_panel:panel(panel_params)
end

function HUDPlayerVoiceChatStatus:_create_background()
	local background_params = {
		alpha = 0.75,
		layer = 28,
		name = "chat_background",
		texture = tweak_data.gui.icons[HUDPlayerVoiceChatStatus.CHAT_ICON_BG_BLACK].texture,
		texture_rect = tweak_data.gui.icons[HUDPlayerVoiceChatStatus.CHAT_ICON_BG_BLACK].texture_rect
	}
	self._chat_background = self._object:bitmap(background_params)

	self._chat_background:set_left(0)
	self._chat_background:set_center_y(HUDPlayerVoiceChatStatus.DEFAULT_H / 2)
end

function HUDPlayerVoiceChatStatus:_create_player_name()
	local player_name_params = {
		x = 0,
		name = "player_name",
		text = "",
		layer = 30,
		w = self._object:w() - HUDPlayerVoiceChatStatus.CHAT_PANEL_W,
		h = HUDPlayerVoiceChatStatus.PLAYER_NAME_H,
		font = tweak_data.gui.fonts[HUDPlayerVoiceChatStatus.PLAYER_NAME_FONT],
		font_size = HUDPlayerVoiceChatStatus.PLAYER_NAME_FONT_SIZE,
		color = tweak_data.gui.colors.raid_red
	}
	self._player_name = self._object:text(player_name_params)

	self._player_name:set_center_y(HUDPlayerVoiceChatStatus.DEFAULT_H / 2 + 1)
end

function HUDPlayerVoiceChatStatus:_create_voice_chat_indicator()
	local chat_indicator_params_speaking = {
		alpha = 1,
		layer = 30,
		name = "chat_indicator_speaking",
		texture = tweak_data.gui.icons[HUDPlayerVoiceChatStatus.CHAT_ICON_SPEAKING].texture,
		texture_rect = tweak_data.gui.icons[HUDPlayerVoiceChatStatus.CHAT_ICON_SPEAKING].texture_rect,
		color = tweak_data.gui.colors.raid_red
	}
	self._chat_indicator_speaking = self._object:bitmap(chat_indicator_params_speaking)

	self._chat_indicator_speaking:set_right(self._object:w())
	self._chat_indicator_speaking:set_center_y(HUDPlayerVoiceChatStatus.DEFAULT_H / 2 + 1)
end

function HUDPlayerVoiceChatStatus:show_chat_indicator(peer_name)
	local peer_name_formatted = peer_name

	if string.len(peer_name_formatted) > 20 then
		peer_name_formatted = string.sub(peer_name_formatted, 1, 17)
		peer_name_formatted = peer_name_formatted .. ".."
	end

	self._player_name:set_text(utf8.to_upper(peer_name_formatted))

	local _, _, w1, _ = self._player_name:text_rect()
	local label_width = self._player_name:w()
	local offset = label_width - w1

	self._player_name:set_right(self._chat_indicator_speaking:left() - 8 + offset)
	self._object:show()
end

function HUDPlayerVoiceChatStatus:hide_chat_indicator()
	self._object:hide()
end
