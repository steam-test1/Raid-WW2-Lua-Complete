RaidGUIControlLootBracket = RaidGUIControlLootBracket or class(RaidGUIControl)
RaidGUIControlLootBracket.BRONZE = tweak_data.gui.colors.raid_red
RaidGUIControlLootBracket.SILVER = Color.white
RaidGUIControlLootBracket.GOLD = Color("f1a130")
RaidGUIControlLootBracket.ICON = "reward_loot"
RaidGUIControlLootBracket.ICON_INACTIVE_SIZE = 202
RaidGUIControlLootBracket.ICON_INACTIVE_H = 213
RaidGUIControlLootBracket.ICON_ACTIVE_H = 283
RaidGUIControlLootBracket.ICON_ACTIVE_PADDING_BOTTOM = 9
RaidGUIControlLootBracket.DEFAULT_W = 283
RaidGUIControlLootBracket.DEFAULT_H = 320
RaidGUIControlLootBracket.NOTCH_W = 3
RaidGUIControlLootBracket.NOTCH_H = 50
RaidGUIControlLootBracket.NOTCH_COLOR = Color.white
RaidGUIControlLootBracket.NOTCH_ICON = "slider_pin"
RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE = Color("787878")
RaidGUIControlLootBracket.NOTCH_COLOR_ACTIVE = tweak_data.gui.colors.raid_red
RaidGUIControlLootBracket.NOTCH_PADDING_TOP = 19
RaidGUIControlLootBracket.NOTCH_PADDING_BOTTOM = 13

function RaidGUIControlLootBracket:init(parent, params)
	RaidGUIControlLootBracket.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlLootBracket:init] Parameters not specified for the customization details")

		return
	end

	self._bracket = params.bracket or RaidGUIControlLootBracket.SILVER

	self:_create_panel()
	self:_create_notch()
	self:_create_bracket_icon()
end

function RaidGUIControlLootBracket:_create_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_panel"
	control_params.layer = self._params.layer or self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlLootBracket.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlLootBracket.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlLootBracket:_create_notch()
	local notch_params = {
		name = "notch",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlLootBracket.NOTCH_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlLootBracket.NOTCH_ICON].texture_rect,
		color = RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE,
		layer = self._object:layer() + 1
	}
	self._notch = self._object:bitmap(notch_params)

	self._notch:set_center_x(self._object:w() / 2)
	self._notch:set_bottom(self._object:h() - RaidGUIControlLootBracket.NOTCH_PADDING_BOTTOM)
end

function RaidGUIControlLootBracket:_create_bracket_icon()
	local bracket_icon_params = {
		name = "bracket_icon",
		y = 0,
		x = 0,
		h = RaidGUIControlLootBracket.ICON_INACTIVE_H,
		w = RaidGUIControlLootBracket.ICON_INACTIVE_H * tweak_data.gui:icon_w(RaidGUIControlLootBracket.ICON) / tweak_data.gui:icon_h(RaidGUIControlLootBracket.ICON),
		texture = tweak_data.gui.icons[RaidGUIControlLootBracket.ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlLootBracket.ICON].texture_rect,
		color = self._bracket,
		layer = self._object:layer() + 2
	}
	self._bracket_icon = self._object:bitmap(bracket_icon_params)

	self._bracket_icon:set_center_x(self._object:w() / 2)
	self._bracket_icon:set_bottom(self._notch:y() - RaidGUIControlLootBracket.NOTCH_PADDING_TOP)
end

function RaidGUIControlLootBracket:activate()
	self._bracket_icon:stop()
	self._bracket_icon:animate(callback(self, self, "_animate_activate"))
end

function RaidGUIControlLootBracket:deactivate()
	self._bracket_icon:stop()
	self._bracket_icon:animate(callback(self, self, "_animate_deactivate"))
end

function RaidGUIControlLootBracket:_animate_activate()
	local duration = 0.25
	local t = (self._bracket_icon:w() - RaidGUIControlLootBracket.ICON_INACTIVE_SIZE) / (self._object:w() - RaidGUIControlLootBracket.ICON_INACTIVE_SIZE) * duration

	managers.menu_component:post_event("bronze_silver_gold_icon")

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_bottom_padding = Easing.quartic_in_out(t, 0, RaidGUIControlLootBracket.ICON_ACTIVE_PADDING_BOTTOM, duration)
		local current_size = Easing.quartic_in_out(t, RaidGUIControlLootBracket.ICON_INACTIVE_H, RaidGUIControlLootBracket.ICON_ACTIVE_H - RaidGUIControlLootBracket.ICON_INACTIVE_H, duration)
		local current_r = Easing.quartic_in_out(t, RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.r, RaidGUIControlLootBracket.NOTCH_COLOR_ACTIVE.r - RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.r, duration)
		local current_g = Easing.quartic_in_out(t, RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.g, RaidGUIControlLootBracket.NOTCH_COLOR_ACTIVE.g - RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.g, duration)
		local current_b = Easing.quartic_in_out(t, RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.b, RaidGUIControlLootBracket.NOTCH_COLOR_ACTIVE.b - RaidGUIControlLootBracket.NOTCH_COLOR_INACTIVE.b, duration)

		self._notch:set_color(Color(current_r, current_g, current_b))
		self._bracket_icon:set_h(current_size)
		self._bracket_icon:set_w(current_size * tweak_data.gui:icon_w(RaidGUIControlLootBracket.ICON) / tweak_data.gui:icon_h(RaidGUIControlLootBracket.ICON))
		self._bracket_icon:set_center_x(self._object:w() / 2)
		self._bracket_icon:set_bottom(self._notch:y() - RaidGUIControlLootBracket.NOTCH_PADDING_TOP - current_bottom_padding)
	end

	self._notch:set_color(RaidGUIControlLootBracket.NOTCH_COLOR_ACTIVE)
	self._bracket_icon:set_h(RaidGUIControlLootBracket.ICON_ACTIVE_H)
	self._bracket_icon:set_w(RaidGUIControlLootBracket.ICON_ACTIVE_H * tweak_data.gui:icon_w(RaidGUIControlLootBracket.ICON) / tweak_data.gui:icon_h(RaidGUIControlLootBracket.ICON))
	self._bracket_icon:set_center_x(self._object:w() / 2)
	self._bracket_icon:set_bottom(self._notch:y() - RaidGUIControlLootBracket.NOTCH_PADDING_TOP - RaidGUIControlLootBracket.ICON_ACTIVE_PADDING_BOTTOM)
end

function RaidGUIControlLootBracket:_animate_deactivate()
	local duration = 0.25
	local t = (1 - (self._bracket_icon:w() - RaidGUIControlLootBracket.ICON_INACTIVE_SIZE) / (self._object:w() - RaidGUIControlLootBracket.ICON_INACTIVE_SIZE)) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_bottom_padding = Easing.quartic_in_out(t, RaidGUIControlLootBracket.ICON_ACTIVE_PADDING_BOTTOM, -RaidGUIControlLootBracket.ICON_ACTIVE_PADDING_BOTTOM, duration)
		local current_size = Easing.quartic_in_out(t, RaidGUIControlLootBracket.ICON_ACTIVE_H, RaidGUIControlLootBracket.ICON_INACTIVE_H - RaidGUIControlLootBracket.ICON_ACTIVE_H, duration)

		self._bracket_icon:set_h(current_size)
		self._bracket_icon:set_w(current_size * tweak_data.gui:icon_w(RaidGUIControlLootBracket.ICON) / tweak_data.gui:icon_h(RaidGUIControlLootBracket.ICON))
		self._bracket_icon:set_center_x(self._object:w() / 2)
		self._bracket_icon:set_bottom(self._notch:y() - RaidGUIControlLootBracket.NOTCH_PADDING_TOP - current_bottom_padding)
	end

	self._bracket_icon:set_h(RaidGUIControlLootBracket.ICON_INACTIVE_H)
	self._bracket_icon:set_w(RaidGUIControlLootBracket.ICON_INACTIVE_H * tweak_data.gui:icon_w(RaidGUIControlLootBracket.ICON) / tweak_data.gui:icon_h(RaidGUIControlLootBracket.ICON))
	self._bracket_icon:set_center_x(self._object:w() / 2)
	self._bracket_icon:set_bottom(self._notch:y() - RaidGUIControlLootBracket.NOTCH_PADDING_TOP)
end
