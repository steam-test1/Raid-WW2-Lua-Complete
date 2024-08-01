HUDPlayerCustody = HUDPlayerCustody or class()
HUDPlayerCustody.SPECTATOR_PANEL_W = 520
HUDPlayerCustody.SPECTATOR_PANEL_H = 72
HUDPlayerCustody.SPECTATOR_TEXT = "hud_spectator_prompt_current"
HUDPlayerCustody.SPECTATOR_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_38
HUDPlayerCustody.SPECTATOR_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.dialg_title
HUDPlayerCustody.SPECTATOR_BACKGROUND = "backgrounds_chat_bg"
HUDPlayerCustody.SPECTATOR_BACKGROUND_H = 44
HUDPlayerCustody.BUTTON_PROMPT_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDPlayerCustody.BUTTON_PROMPT_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDPlayerCustody.BUTTON_PROMPT_TEXT_COLOR = tweak_data.gui.colors.raid_white
HUDPlayerCustody.BUTTON_PROMPT_CYCLE = "hud_spectator_prompt_cycle"

-- Lines 18-119
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

-- Lines 124-139
function HUDPlayerCustody:set_spectator_info(unit)
	if not self._spectator_panel then
		self:_create_spectator_info(self._hud_panel:child("custody_panel"))
	end

	if alive(unit) then
		local nick_name = unit:base():nick_name()

		self._spectator_text:set_text(utf8.to_upper(nick_name))
		self._spectator_panel:set_visible(true)
		self:_refresh_button_prompt()
	else
		self._spectator_panel:set_visible(false)
	end
end

-- Lines 141-180
function HUDPlayerCustody:_create_spectator_info(parent)
	self._spectator_panel = parent:panel({
		name = "spectator_panel",
		halign = "left",
		valign = "bottom",
		w = HUDPlayerCustody.SPECTATOR_PANEL_W,
		h = HUDPlayerCustody.SPECTATOR_PANEL_H
	})

	self._spectator_panel:set_center_x(parent:w() / 2)
	self._spectator_panel:set_bottom(parent:h() - 25)

	local spectator_background = self._spectator_panel:bitmap({
		name = "spectator_background",
		w = HUDPlayerCustody.SPECTATOR_PANEL_W,
		h = HUDPlayerCustody.SPECTATOR_BACKGROUND_H,
		texture = tweak_data.gui.icons[HUDPlayerCustody.SPECTATOR_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDPlayerCustody.SPECTATOR_BACKGROUND].texture_rect
	})
	self._spectator_text = self._spectator_panel:text({
		name = "spectator_text",
		vertical = "center",
		align = "center",
		text = "SPECTATING",
		halign = "center",
		valign = "center",
		font = HUDPlayerCustody.SPECTATOR_TEXT_FONT,
		font_size = HUDPlayerCustody.SPECTATOR_TEXT_FONT_SIZE,
		h = HUDPlayerCustody.SPECTATOR_BACKGROUND_H,
		layer = spectator_background:layer() + 1
	})
	self._button_prompt = self._spectator_panel:text({
		name = "prompt_previous",
		vertical = "bottom",
		align = "center",
		text = "",
		halign = "center",
		valign = "center",
		font = HUDPlayerCustody.BUTTON_PROMPT_TEXT_FONT,
		font_size = HUDPlayerCustody.BUTTON_PROMPT_TEXT_FONT_SIZE,
		color = HUDPlayerCustody.BUTTON_PROMPT_TEXT_COLOR
	})

	self:_refresh_button_prompt()
end

-- Lines 182-198
function HUDPlayerCustody:_refresh_button_prompt()
	local btn_macros = nil

	if managers.controller:is_using_controller() then
		btn_macros = {
			BTN_LEFT = managers.localization:get_default_macros().BTN_PRIMARY,
			BTN_RIGHT = managers.localization:get_default_macros().BTN_SECONDARY
		}
	else
		btn_macros = {
			BTN_LEFT = managers.localization:btn_macro("left"),
			BTN_RIGHT = managers.localization:btn_macro("right")
		}
	end

	local prompt_text = managers.localization:text(HUDPlayerCustody.BUTTON_PROMPT_CYCLE, btn_macros)

	self._button_prompt:set_text(utf8.to_upper(prompt_text))
end

-- Lines 204-210
function HUDPlayerCustody:set_pumpkin_challenge()
	local top_text = utf8.to_upper(managers.localization:text("card_ra_season_of_resurrection_name_id"))

	self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(top_text)

	local bottom_text = utf8.to_upper(managers.localization:text("hud_pumpkin_revive_tutorial"))

	self._timer:set_text(bottom_text)
end

-- Lines 212-217
function HUDPlayerCustody:set_timer_visibility(visible)
	self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(utf8.to_upper(managers.localization:text("hud_respawning_in")))
	self._timer:set_visible(visible)
	self._hud_panel:child("custody_panel"):child("timer_msg"):set_visible(visible)
end

-- Lines 219-227
function HUDPlayerCustody:set_respawn_time(time)
	if math.floor(time) == math.floor(self._last_time) then
		return
	end

	self._last_time = time
	local time_text = self:_get_time_text(time)

	self._timer:set_text(utf8.to_upper(tostring(time_text)))
end

-- Lines 229-238
function HUDPlayerCustody:_get_time_text(time)
	time = math.max(math.floor(time), 0)
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local text = ""

	return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

-- Lines 240-248
function HUDPlayerCustody:_animate_text_pulse(text)
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = 0.5 + math.abs(math.sin(t * 360 * 0.5)) / 2

		text:set_alpha(alpha)
	end
end

-- Lines 250-256
function HUDPlayerCustody:set_respawn_type(is_ai_trade)
	if self._last_respawn_type_is_ai_trade ~= is_ai_trade then
		local text = utf8.to_upper(managers.localization:text(is_ai_trade and "hud_ai_traded_in" or "hud_respawning_in"))

		self._hud_panel:child("custody_panel"):child("timer_msg"):set_text(text)

		self._last_respawn_type_is_ai_trade = is_ai_trade
	end
end

-- Lines 262-266
function HUDPlayerCustody:set_civilians_killed(amount)
end

-- Lines 268-277
function HUDPlayerCustody:set_trade_delay(time)
end

-- Lines 279-282
function HUDPlayerCustody:set_trade_delay_visible(visible)
end

-- Lines 284-290
function HUDPlayerCustody:set_negotiating_visible(visible)
end

-- Lines 292-298
function HUDPlayerCustody:set_can_be_trade_visible(visible)
end
