HUDPlayerCustody = HUDPlayerCustody or class()

function HUDPlayerCustody:init(hud)
	self._hud = hud
	self._hud_panel = hud.panel
	self._last_respawn_type_is_ai_trade = false

	if self._hud_panel:child("custody_panel") then
		self._hud_panel:remove(self._hud_panel:child("custody_panel"))
	end

	local custody_panel = self._hud_panel:panel({
		valign = "grow",
		name = "custody_panel",
		halign = "grow"
	})
	local timer_message_params = {
		text = "custodddddy in",
		vertical = "center",
		h = 40,
		name = "timer_msg",
		w = 400,
		align = "center",
		font = tweak_data.gui.fonts.din_compressed_outlined_24,
		font_size = tweak_data.gui.font_sizes.size_24
	}
	local timer_msg = custody_panel:text(timer_message_params)

	timer_msg:set_text(utf8.to_upper(managers.localization:text("hud_respawning_in")))

	local _, _, w, h = timer_msg:text_rect()

	timer_msg:set_h(h)
	timer_msg:set_x(math.round(self._hud_panel:center_x() - timer_msg:w() / 2))
	timer_msg:set_y(28)

	local timer_params = {
		text = "00:00",
		vertical = "bottom",
		h = 32,
		name = "timer",
		align = "center",
		w = custody_panel:w(),
		font = tweak_data.gui.fonts.din_compressed_outlined_42,
		font_size = tweak_data.gui.font_sizes.menu_list
	}
	local timer = custody_panel:text(timer_params)
	local _, _, w, h = timer:text_rect()

	timer:set_h(h)
	timer:set_y(math.round(timer_msg:bottom() - 6))
	timer:set_center_x(self._hud_panel:center_x())

	self._timer = timer
	self._last_time = -1
	self._last_trade_delay_time = -1
end

function HUDPlayerCustody:set_pumpkin_challenge()
	local top_text = utf8.to_upper(managers.localization:text("card_ra_season_of_resurrection_name_id"))

	self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(top_text)

	local bottom_text = utf8.to_upper(managers.localization:text("hud_pumpkin_revive_tutorial"))

	self._timer:set_text(bottom_text)
end

function HUDPlayerCustody:set_timer_visibility(visible)
	self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(utf8.to_upper(managers.localization:text("hud_respawning_in")))
	self._timer:set_visible(visible)
	self._hud_panel:child("custody_panel"):child("timer_msg"):set_visible(visible)
end

function HUDPlayerCustody:set_respawn_time(time)
	if math.floor(time) == math.floor(self._last_time) then
		return
	end

	self._last_time = time

	local time_text = self:_get_time_text(time)

	self._timer:set_text(utf8.to_upper(tostring(time_text)))
end

function HUDPlayerCustody:set_civilians_killed(amount)
	return
end

function HUDPlayerCustody:set_trade_delay(time)
	return
end

function HUDPlayerCustody:set_trade_delay_visible(visible)
	return
end

function HUDPlayerCustody:set_negotiating_visible(visible)
	return
end

function HUDPlayerCustody:set_can_be_trade_visible(visible)
	return
end

function HUDPlayerCustody:_get_time_text(time)
	time = math.max(math.floor(time), 0)

	local minutes = math.floor(time / 60)

	time = time - minutes * 60

	local seconds = math.round(time)
	local text = ""

	return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

function HUDPlayerCustody:_animate_text_pulse(text)
	local t = 0

	while true do
		local dt = coroutine.yield()

		t = t + dt

		local alpha = 0.5 + math.abs((math.sin(t * 360 * 0.5))) / 2

		text:set_alpha(alpha)
	end
end

function HUDPlayerCustody:set_respawn_type(is_ai_trade)
	if self._last_respawn_type_is_ai_trade ~= is_ai_trade then
		local text = utf8.to_upper(managers.localization:text(is_ai_trade and "hud_ai_traded_in" or "hud_respawning_in"))

		self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(text)

		self._last_respawn_type_is_ai_trade = is_ai_trade
	end
end
