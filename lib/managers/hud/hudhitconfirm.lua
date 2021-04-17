HUDHitConfirm = HUDHitConfirm or class()
HUDHitConfirm.HIT_ICON = "indicator_hit"
HUDHitConfirm.HEADSHOT_ICON = "indicator_head_shot"
HUDHitConfirm.CRITICAL_ICON = "indicator_kill"

-- Lines 7-15
function HUDHitConfirm:init(hud)
	self._hud_panel = hud.panel

	self:cleanup()

	self._hit_confirm = self:_create_icon("hit_confirm", HUDHitConfirm.HIT_ICON)
	self._headshot_confirm = self:_create_icon("headshot_confirm", HUDHitConfirm.HEADSHOT_ICON)
	self._crit_confirm = self:_create_icon("crit_confirm", HUDHitConfirm.CRITICAL_ICON)
end

-- Lines 17-29
function HUDHitConfirm:_create_icon(name, icon)
	local icon_params = {
		valign = "center",
		halign = "center",
		visible = false,
		name = name,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	local icon = self._hud_panel:bitmap(icon_params)

	icon:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)

	return icon
end

-- Lines 31-34
function HUDHitConfirm:on_hit_confirmed()
	self._hit_confirm:stop()
	self._hit_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25)
end

-- Lines 36-39
function HUDHitConfirm:on_headshot_confirmed()
	self._headshot_confirm:stop()
	self._headshot_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25)
end

-- Lines 41-44
function HUDHitConfirm:on_crit_confirmed()
	self._crit_confirm:stop()
	self._crit_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25)
end

-- Lines 46-57
function HUDHitConfirm:cleanup()
	if self._hud_panel:child("hit_confirm") then
		self._hud_panel:remove(self._hud_panel:child("hit_confirm"))
	end

	if self._hud_panel:child("headshot_confirm") then
		self._hud_panel:remove(self._hud_panel:child("headshot_confirm"))
	end

	if self._hud_panel:child("crit_confirm") then
		self._hud_panel:remove(self._hud_panel:child("crit_confirm"))
	end
end

-- Lines 59-70
function HUDHitConfirm:_animate_show(hint_confirm, done_cb, seconds)
	hint_confirm:set_visible(true)
	hint_confirm:set_alpha(1)

	local t = seconds

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		hint_confirm:set_alpha(t / seconds)
	end

	hint_confirm:set_visible(false)
	done_cb()
end

-- Lines 73-75
function HUDHitConfirm:show_done()
end
