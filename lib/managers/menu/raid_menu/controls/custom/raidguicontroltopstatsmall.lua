RaidGUIControlTopStatSmall = RaidGUIControlTopStatSmall or class(RaidGUIControl)
RaidGUIControlTopStatSmall.WIDTH = 320
RaidGUIControlTopStatSmall.HEIGHT = 64
RaidGUIControlTopStatSmall.STAT_NAME_H = 32
RaidGUIControlTopStatSmall.STAT_NAME_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlTopStatSmall.STAT_NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlTopStatSmall.PLAYER_NAME_H = 32
RaidGUIControlTopStatSmall.PLAYER_NAME_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlTopStatSmall.PLAYER_NAME_FONT_SIZE = tweak_data.gui.font_sizes.small
RaidGUIControlTopStatSmall.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlTopStatSmall.ICON_SIZE = 64

-- Lines 19-29
function RaidGUIControlTopStatSmall:init(parent, params)
	RaidGUIControlTopStatSmall.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlTopStatSmall:init] Parameters not specified for RaidGUIControlTopStatSmall", params.name)

		return
	end

	self:_create_panel()
	self:_create_stat_info()
end

-- Lines 32-33
function RaidGUIControlTopStatSmall:close()
end

-- Lines 36-45
function RaidGUIControlTopStatSmall:_create_panel()
	local control_params = clone(self._params)
	control_params.w = RaidGUIControlTopStatSmall.WIDTH
	control_params.h = RaidGUIControlTopStatSmall.HEIGHT
	control_params.name = control_params.name .. "_top_stat_small_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 48-78
function RaidGUIControlTopStatSmall:_create_stat_info()
	local player_name_params = {
		name = "player_name_label",
		vertical = "center",
		align = "right",
		text = "PLAYER NAME",
		y = -3,
		layer = 1,
		x = RaidGUIControlTopStatSmall.ICON_SIZE,
		w = self._object:w() - RaidGUIControlTopStatSmall.ICON_SIZE,
		h = RaidGUIControlTopStatSmall.PLAYER_NAME_H,
		font = RaidGUIControlTopStatSmall.FONT,
		font_size = RaidGUIControlTopStatSmall.PLAYER_NAME_FONT_SIZE,
		color = RaidGUIControlTopStatSmall.PLAYER_NAME_COLOR
	}
	self._player_name_label = self._object:label(player_name_params)
	local stat_name_params = {
		vertical = "center",
		wrap = true,
		align = "right",
		name = "stat_name_label",
		word_wrap = true,
		text = "Most specials killed",
		layer = 3,
		w = self._object:w(),
		h = RaidGUIControlTopStatSmall.STAT_NAME_H,
		font = RaidGUIControlTopStatSmall.FONT,
		font_size = RaidGUIControlTopStatSmall.STAT_NAME_FONT_SIZE,
		color = RaidGUIControlTopStatSmall.STAT_NAME_COLOR
	}
	self._stat_name_label = self._object:label(stat_name_params)

	self._stat_name_label:set_y(self._player_name_label:y() + self._player_name_label:h())
end

-- Lines 80-92
function RaidGUIControlTopStatSmall:set_data(data)
	self._player_name_label:set_text(utf8.to_upper(data.player_nickname))
	self._stat_name_label:set_text(self:translate(data.stat, true))

	local icon_params = {
		name = "stat_icon",
		w = RaidGUIControlTopStatSmall.ICON_SIZE,
		h = RaidGUIControlTopStatSmall.ICON_SIZE,
		texture = tweak_data.gui.icons[data.icon].texture,
		texture_rect = tweak_data.gui.icons[data.icon].texture_rect
	}
	self._stat_icon = self._object:bitmap(icon_params)
end
