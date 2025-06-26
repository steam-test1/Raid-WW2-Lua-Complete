RaidMenuFooter = RaidMenuFooter or class(RaidGuiBase)
RaidMenuFooter.PROFILE_NAME_W = 550

function RaidMenuFooter:init(ws, fullscreen_ws, node, component_name)
	RaidMenuFooter.super.init(self, ws, fullscreen_ws, node, component_name)
end

function RaidMenuFooter:_layout()
	self._object = self._root_panel:panel({
		x = 0,
		name = "footer_object_panel",
		y = 0,
		w = self._root_panel:w(),
		h = self._root_panel:h()
	})
	self._legend = self._object:legend({
		name = "footer_legend"
	})

	self:_create_name_and_gold_panel()
end

function RaidMenuFooter:set_navigation_button_visibility(flag)
	self._navigation_button:set_visible(flag)
end

function RaidMenuFooter:_setup_properties()
	self._panel_x = 0
	self._panel_y = self._ws:height() - RaidGuiBase.PADDING
	self._panel_w = self._ws:width()
	self._panel_h = RaidGuiBase.PADDING
	self._panel_layer = RaidGuiBase.FOREGROUND_LAYER
	self._panel_is_root_panel = true
end

function RaidMenuFooter:_create_name_and_gold_panel()
	local string_width_measure_text_field = self._object:child("string_width") or self._object:text({
		wrap = true,
		name = "string_width",
		visible = false,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24
	})
	local username = managers.network.account:username()

	if managers.user:get_setting("capitalize_names") then
		username = utf8.to_upper(username)
	end

	string_width_measure_text_field:set_text(username)

	local _, _, w1, _ = string_width_measure_text_field:text_rect()
	w1 = w1 + 64
	local params_profile_gold_label = {
		vertical = "bottom",
		type = "label",
		name = "gold_label",
		h = 32,
		w = w1,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		text = username,
		color = tweak_data.gui.colors.raid_grey
	}
	local gold_icon = tweak_data.gui.icons.gold_amount_footer
	local gold_icon_params = {
		valign = "scale",
		halign = "scale",
		y = 0,
		texture = gold_icon.texture,
		texture_rect = gold_icon.texture_rect,
		x = w1,
		color = tweak_data.gui.colors.raid_grey,
		w = gold_icon.texture_rect[3],
		h = gold_icon.texture_rect[4],
		layer = self._object:layer()
	}
	local w2 = gold_icon_params.w + 10
	local gold = managers.gold_economy:gold_string(managers.gold_economy:current())

	string_width_measure_text_field:set_text(gold)

	local _, _, w3, _ = string_width_measure_text_field:text_rect()
	local params_profile_name_label = {
		type = "label",
		name = "profile_name_label",
		h = 32,
		vertical = "bottom",
		x = w1 + w2,
		w = w3,
		text = gold,
		color = tweak_data.gui.colors.raid_grey,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24
	}
	local total_width = w1 + w2 + w3
	local separator_params = {
		vertical = "bottom",
		name = "separator",
		h = 14,
		w = 2,
		y = 14,
		x = w1 - 32,
		color = tweak_data.gui.colors.raid_grey,
		layer = self._object:layer()
	}
	self._name_and_gold_panel = self._object:panel({
		align = "right",
		name = "name_and_gold_panel",
		y = 0,
		x = self._object:w() - total_width,
		w = total_width,
		h = self._object:h()
	})
	self._profile_name_label = self._name_and_gold_panel:label(params_profile_name_label)
	self._gold_icon = self._name_and_gold_panel:bitmap(gold_icon_params)
	self._profile_gold_label = self._name_and_gold_panel:label(params_profile_gold_label)
	self._separator = self._name_and_gold_panel:rect(separator_params)
end

function RaidMenuFooter:hide_name_and_gold_panel()
	self._name_and_gold_panel:hide()
end

function RaidMenuFooter:refresh_player_profile()
	local username = managers.network.account:username()

	if managers.user:get_setting("capitalize_names") then
		username = utf8.to_upper(username)
	end

	self._profile_gold_label:set_text(username)
end

function RaidMenuFooter:refresh_gold_amount()
	local gold_amount = managers.gold_economy:gold_string(managers.gold_economy:current())

	self._profile_name_label:set_text(gold_amount)

	local _, _, w = self._profile_name_label:text_rect()

	self._profile_name_label:set_w(w)
end

function RaidMenuFooter:back_pressed()
end

function RaidMenuFooter:confirm_pressed()
	return false
end
