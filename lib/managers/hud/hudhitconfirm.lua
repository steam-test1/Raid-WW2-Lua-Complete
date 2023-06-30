HUDHitConfirm = HUDHitConfirm or class()
HUDHitConfirm.HIT_ICON = "indicator_hit"
HUDHitConfirm.HEADSHOT_ICON = "indicator_head_shot"
HUDHitConfirm.CRITICAL_ICON = "indicator_kill"

function HUDHitConfirm:init(hud)
	self._hud_panel = hud.panel

	self:cleanup()

	self._hit_confirm = self:_create_icon("hit_confirm", HUDHitConfirm.HIT_ICON)
	self._headshot_confirm = self:_create_icon("headshot_confirm", HUDHitConfirm.HEADSHOT_ICON)
	self._crit_confirm = self:_create_icon("crit_confirm", HUDHitConfirm.CRITICAL_ICON)
end

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

function HUDHitConfirm:on_hit_confirmed(world_hit_pos, is_shotgun)
	local hit_con = self._hit_confirm

	self:_pop_hit_confirm(hit_con, world_hit_pos)
end

function HUDHitConfirm:on_headshot_confirmed(world_hit_pos, is_shotgun)
	local hit_con = self._headshot_confirm

	self:_pop_hit_confirm(hit_con, world_hit_pos)
end

function HUDHitConfirm:on_crit_confirmed(world_hit_pos, is_shotgun)
	local hit_con = self._crit_confirm

	self:_pop_hit_confirm(hit_con, world_hit_pos)
end

function HUDHitConfirm:hud_pos_from_world(v3)
	if v3.z < 0 then
		return self._hud_panel:w() / 2, self._hud_panel:h() / 2
	end

	local camera = managers.viewport:get_current_camera()

	if not camera then
		return self._hud_panel:w() / 2, self._hud_panel:h() / 2
	end

	local x = v3.x
	local y = v3.y
	local hud_pos = camera:world_to_screen(v3)
	local screen_x = self._hud_panel:w() / 2
	local screen_y = self._hud_panel:h() / 2
	screen_x = screen_x + hud_pos.x * self._hud_panel:w()
	screen_y = screen_y + hud_pos.y * self._hud_panel:h()

	return screen_x, screen_y
end

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

function HUDHitConfirm:_pop_hit_confirm(hit_con, pos)
	hit_con:stop()
	hit_con:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25)

	if pos and managers.user:get_setting("hit_indicator") == 3 then
		hit_con:set_center(self:hud_pos_from_world(pos))
	else
		hit_con:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	end
end

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

function HUDHitConfirm:show_done()
end
