HUDHitConfirm = HUDHitConfirm or class()
HUDHitConfirm.MODE_OFF = 1
HUDHitConfirm.MODE_MINIMAL = 2
HUDHitConfirm.MODE_NORMAL = 3
HUDHitConfirm.MODE_TRACK = 4
HUDHitConfirm.COL_TYPE_HURT = "raid_white"
HUDHitConfirm.COL_TYPE_KILL = "raid_red"
HUDHitConfirm.COL_TYPE_CRIT = "raid_gold"
HUDHitConfirm.COL_TYPE_IMMUNE = "raid_grey"
HUDHitConfirm.ICO_TYPE_BODY = "indicator_hit_body"
HUDHitConfirm.ICO_TYPE_HEAD = "indicator_hit_head"
HUDHitConfirm.ICO_TYPE_PELLET = "indicator_hit_dot"
HUDHitConfirm.ICO_TYPE_ARMOR = "indicator_hit_armor"
HUDHitConfirm.ICO_TYPE_WEAK = "indicator_hit_weakness"
HUDHitConfirm.HIT_NORMAL = 1
HUDHitConfirm.HIT_SPLINTER = 2
HUDHitConfirm.HIT_ARMOR = 3
HUDHitConfirm.HIT_WEAKPOINT = 4
HUDHitConfirm.HIT_KILLSHOT = 5
HUDHitConfirm.JIGGLE_MIN = 1
HUDHitConfirm.JIGGLE_MAX = 1
HUDHitConfirm.MAX_QUEUE = 16

function HUDHitConfirm:init(hud)
	self._hud_panel = hud.panel

	self:cleanup()

	self._queue = {}
	self._hit_confirm = self:_create_icon("hit_confirm", HUDHitConfirm.ICO_TYPE_BODY)
	self._pellet_hit_confirm = {}

	for i = 1, HUDHitConfirm.MAX_QUEUE do
		table.insert(self._pellet_hit_confirm, self:_create_icon("pellet_hit_confirm" .. i, HUDHitConfirm.ICO_TYPE_PELLET))
	end

	self._pellet_hit_confirm_i = 1
end

function HUDHitConfirm:_create_icon(name, icon)
	local icon_params = {
		texture = nil,
		halign = "center",
		valign = "center",
		name = nil,
		texture_rect = nil,
		visible = false,
		layer = 2,
		name = name,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	local icon = self._hud_panel:bitmap(icon_params)

	icon:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)

	return icon
end

function HUDHitConfirm:_on_hit_confirmed_as_pellet(data)
	local hit_con = self._pellet_hit_confirm[self._pellet_hit_confirm_i]
	self._pellet_hit_confirm_i = self._pellet_hit_confirm_i + 1

	if self._pellet_hit_confirm_i == HUDHitConfirm.MAX_QUEUE then
		self._pellet_hit_confirm_i = 1
	end

	return hit_con
end

function HUDHitConfirm:_on_hit_confirmed_as_single(data)
	local is_armor = data.hit_type == HUDHitConfirm.HIT_ARMOR
	local is_weakpoint = data.hit_type == HUDHitConfirm.HIT_WEAKPOINT
	local hit_con = self._hit_confirm
	local color, gui = nil

	if is_armor then
		gui = tweak_data.gui.icons[HUDHitConfirm.ICO_TYPE_ARMOR]
	elseif is_weakpoint then
		gui = tweak_data.gui.icons[HUDHitConfirm.ICO_TYPE_WEAK]
	else
		gui = tweak_data.gui.icons[data.is_headshot and HUDHitConfirm.ICO_TYPE_HEAD or HUDHitConfirm.ICO_TYPE_BODY]
	end

	local jiggle_dir = math.rand_bool()

	hit_con:set_rotation(math.rand(HUDHitConfirm.JIGGLE_MIN, HUDHitConfirm.JIGGLE_MAX) * (jiggle_dir and 1 or -1))
	hit_con:set_image(gui.texture)
	hit_con:set_texture_rect(unpack(gui.texture_rect))

	return hit_con
end

function HUDHitConfirm:on_hit_confirmed(data)
	local is_minimalist_mode = managers.user:get_setting("hit_indicator") == HUDHitConfirm.MODE_MINIMAL
	local is_pellet = not is_minimalist_mode and data.hit_type == HUDHitConfirm.HIT_SPLINTER
	local hit_con = nil

	if is_pellet then
		hit_con = self:_on_hit_confirmed_as_pellet(data)
	else
		hit_con = self:_on_hit_confirmed_as_single(data)
	end

	local priority = data.is_headshot and 1 or 0
	local col = nil

	if data.is_killshot then
		col = tweak_data.gui.colors[HUDHitConfirm.COL_TYPE_KILL]
		priority = priority + 4
	elseif data.is_crit or data.hit_type == HUDHitConfirm.HIT_WEAKPOINT then
		col = tweak_data.gui.colors[HUDHitConfirm.COL_TYPE_CRIT]
		priority = priority + 2
	elseif data.hit_type == HUDHitConfirm.HIT_ARMOR then
		col = tweak_data.gui.colors[HUDHitConfirm.COL_TYPE_IMMUNE]
		priority = priority - 2
	else
		col = tweak_data.gui.colors[HUDHitConfirm.COL_TYPE_HURT]
	end

	hit_con:set_color(col)
	self:_queue_pop_hit(hit_con, data.pos, is_pellet, priority)
end

function HUDHitConfirm:hud_pos_from_world(world_v3)
	local camera = managers.viewport:get_current_camera()

	if not camera then
		return self._hud_panel:w() / 2, self._hud_panel:h() / 2
	end

	local hud_pos = camera:world_to_screen(world_v3)
	local screen_x = self._hud_panel:w() / 2
	local screen_y = self._hud_panel:h() / 2
	screen_x = screen_x + hud_pos.x * self._hud_panel:w() / 2
	screen_y = screen_y + hud_pos.y * self._hud_panel:h() / 2

	return screen_x, screen_y
end

function HUDHitConfirm:cleanup()
	if self._hud_panel:child("hit_confirm") then
		self._hud_panel:remove(self._hud_panel:child("hit_confirm"))
	end

	if self._pellet_hit_confirm and not table.empty(self._pellet_hit_confirm) then
		for _, v in ipairs(self._pellet_hit_confirm) do
			self._hud_panel:remove(v)
		end
	end
end

function HUDHitConfirm:_queue_pop_hit(hit_con, pos, is_pellet, priority)
	if table.empty(self._queue) then
		local is_minimalist_mode = managers.user:get_setting("hit_indicator") == HUDHitConfirm.MODE_MINIMAL

		managers.queued_tasks:queue("pop_hit_confirm", is_minimalist_mode and self._pop_hit_confirm_minimal or self._pop_hit_confirm, self, nil, 0, nil)
	end

	if #self._queue < HUDHitConfirm.MAX_QUEUE then
		table.insert(self._queue, {
			hit_con,
			pos,
			is_pellet or false,
			priority or -1
		})
	end
end

function HUDHitConfirm:_pop_hit_confirm_minimal()
	local hit_con, priority = nil

	for i, data in ipairs(self._queue) do
		if not hit_con or priority < data[4] then
			hit_con = data[1]
			priority = data[4]
		end
	end

	if alive(hit_con) then
		local c_x = self._hud_panel:w() / 2
		local c_y = self._hud_panel:h() / 2

		hit_con:set_center(c_x, c_y)
		hit_con:stop()
		hit_con:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.4)
	else
		Application:warn("[HUDHitConfirm:_pop_hit_confirm_minimal] Something went wrong!")
	end

	self._queue = {}
end

function HUDHitConfirm:_pop_hit_confirm()
	local div = 360 / #self._queue
	local r = 8 + #self._queue
	local is_tracked = managers.user:get_setting("hit_indicator") == HUDHitConfirm.MODE_TRACK

	for i, data in ipairs(self._queue) do
		local hit_con, pos, is_pellet = unpack(data)

		if not alive(hit_con) then
			Application:warn("[HUDHitConfirm:_pop_hit_confirm] Something went wrong!")

			break
		end

		hit_con:stop()
		hit_con:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.4, is_tracked and pos or nil)

		if pos and is_tracked then
			hit_con:set_center(self:hud_pos_from_world(pos))
		else
			local c_x = self._hud_panel:w() / 2
			local c_y = self._hud_panel:h() / 2

			if is_pellet and #self._queue > 1 then
				local t = div * i
				c_x = c_x + r * math.cos(t)
				c_y = c_y + r * math.sin(t)
			end

			hit_con:set_center(c_x, c_y)
		end
	end

	self._queue = {}
end

function HUDHitConfirm:_animate_show(hit_con, done_cb, seconds, pos)
	hit_con:set_visible(true)
	hit_con:set_alpha(1)

	local t = seconds + math.rand(-0.1, 0.1)

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local v = t / seconds * 2

		hit_con:set_alpha(v)

		if pos then
			hit_con:set_center(self:hud_pos_from_world(pos))
		end
	end

	hit_con:set_visible(false)
	done_cb()
end

function HUDHitConfirm:show_done()
end
