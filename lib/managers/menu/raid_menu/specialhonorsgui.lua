SpecialHonorsGui = SpecialHonorsGui or class(RaidGuiBase)
SpecialHonorsGui.TOP_STATS_SMALL_Y = 448
SpecialHonorsGui.TOP_STATS_SMALL_W = 320
SpecialHonorsGui.TOP_STATS_SMALL_H = 224
SpecialHonorsGui.TOP_STATS_TITLE_CENTER_Y = 80
SpecialHonorsGui.TOP_STATS_TITLE_H = 96
SpecialHonorsGui.TOP_STATS_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
SpecialHonorsGui.TOP_STATS_TITLE_COLOR = tweak_data.gui.colors.raid_red
SpecialHonorsGui.TOP_STATS_TITLE_TEXT = "top_stats_title_label"
SpecialHonorsGui.TOP_STATS_TITLE_TEXT_FAILURE = "top_stats_title_label_failure"
SpecialHonorsGui.FONT = tweak_data.gui.fonts.din_compressed
SpecialHonorsGui.GAMERCARD_BUTTONS = {
	{
		"menu_controller_face_left",
		"menu_legend_top_stats_label_1",
		"BTN_X"
	},
	{
		"menu_controller_face_top",
		"menu_legend_top_stats_label_2",
		"BTN_Y"
	},
	{
		"menu_controller_face_right",
		"menu_legend_top_stats_label_3",
		"BTN_B"
	}
}

-- Lines 25-34
function SpecialHonorsGui:init(ws, fullscreen_ws, node, component_name)
	print("[SpecialHonorsGui:init()]")

	self._closing = false
	self.current_state = game_state_machine:current_state()
	self._callback_handler = RaidMenuCallbackHandler:new()

	SpecialHonorsGui.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))
end

-- Lines 36-39
function SpecialHonorsGui:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_experience_success")
	self._node.components.raid_menu_header._screen_name_label:set_alpha(0)
end

-- Lines 41-52
function SpecialHonorsGui:_layout()
	SpecialHonorsGui.super._layout(self)
	self:_layout_first_screen()

	if game_state_machine:current_state().stats_ready then
		self:show_honors()
	end

	self:bind_controller_inputs()
end

-- Lines 54-89
function SpecialHonorsGui:_layout_first_screen()
	local top_stats_big_panel_params = {
		halign = "scale",
		name = "top_stats_big_panel",
		valign = "scale"
	}
	self._top_stats_big_panel = self._root_panel:panel(top_stats_big_panel_params)
	local title_text = game_state_machine:current_state():is_success() and SpecialHonorsGui.TOP_STATS_TITLE_TEXT or SpecialHonorsGui.TOP_STATS_TITLE_TEXT_FAILURE
	local top_stats_title_params = {
		vertical = "center",
		name = "top_stats_title",
		alpha = 0,
		align = "center",
		h = SpecialHonorsGui.TOP_STATS_TITLE_H,
		font = SpecialHonorsGui.FONT,
		font_size = SpecialHonorsGui.TOP_STATS_TITLE_FONT_SIZE,
		color = SpecialHonorsGui.TOP_STATS_TITLE_COLOR,
		text = self:translate(title_text, true)
	}
	local top_stats_title = self._top_stats_big_panel:text(top_stats_title_params)

	top_stats_title:set_center_y(SpecialHonorsGui.TOP_STATS_TITLE_CENTER_Y)

	self._top_stats_big = {}

	for i = 1, 3 do
		local top_stat_big_params = {
			name = "top_stat_big_" .. tostring(i),
			x = (i - 1) * self._root_panel:w() / 3
		}
		local top_stat_big = self._top_stats_big_panel:create_custom_control(RaidGUIControlTopStatBig, top_stat_big_params)

		table.insert(self._top_stats_big, top_stat_big)
	end
end

-- Lines 92-94
function SpecialHonorsGui:_continue_button_on_click()
	managers.raid_menu:close_menu()
end

-- Lines 96-105
function SpecialHonorsGui:close()
	if self._closing then
		return
	end

	self._closing = true

	if game_state_machine:current_state_name() == "event_complete_screen" then
		game_state_machine:current_state():continue()
	end

	SpecialHonorsGui.super.close(self)
end

-- Lines 107-142
function SpecialHonorsGui:show_honors()
	local top_stats_title = self._top_stats_big_panel:child("top_stats_title")

	top_stats_title:animate(callback(self, self, "_fade_in_label"), 0.2, 0.2)

	local honors = game_state_machine:current_state().special_honors
	local stats_used = "top_stats"

	if not game_state_machine:current_state():is_success() then
		stats_used = "bottom_stats"
	end

	for i = 1, 3 do
		local sound_effect = nil

		if honors[i].peer_id == managers.network:session():local_peer():id() then
			sound_effect = "mvp_1p"
		else
			sound_effect = "mvp_team"
		end

		local data = {
			player_nickname = honors[i].peer_name,
			stat = honors[i].id,
			text_id = tweak_data.statistics[stats_used][honors[i].id].text_id,
			icon = tweak_data.statistics[stats_used][honors[i].id].icon,
			icon_texture = tweak_data.statistics[stats_used][honors[i].id].texture,
			icon_texture_rect = tweak_data.statistics[stats_used][honors[i].id].texture_rect,
			sound_effect = sound_effect,
			score = honors[i].score,
			score_format = tweak_data.statistics[stats_used][honors[i].id].score_format,
			mission_successful = game_state_machine:current_state():is_success()
		}

		self._top_stats_big[i]:set_data(data)
		self._top_stats_big[i]:animate_show(2 * (i - 1) + 0.55, callback(self, self, "bind_controller_inputs"))
	end
end

-- Lines 144-152
function SpecialHonorsGui:show_gamercard(i)
	local peer_id = game_state_machine:current_state().special_honors[i].peer_id
	local peer = managers.network:session():peer(peer_id)

	Application:trace("[SpecialHonorsGui:show_gamercard] showing gamercard for peer " .. tostring(peer:name()))
	Application:debug("[SpecialHonorsGui:show_gamercard]", inspect(peer))
	self._callback_handler:view_gamer_card(peer:xuid())
end

-- Lines 154-172
function SpecialHonorsGui:_fade_in_label(text, duration, delay)
	local anim_duration = duration or 0.15
	local t = text:alpha() * anim_duration

	if delay then
		wait(delay)
	end

	while t < anim_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, anim_duration)

		text:set_alpha(current_alpha)
	end

	text:set_alpha(1)
end

-- Lines 175-177
function SpecialHonorsGui:confirm_pressed()
	self:_continue_button_on_click()
end

-- Lines 179-181
function SpecialHonorsGui:on_escape()
	return true
end

-- Lines 183-240
function SpecialHonorsGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_continue_button_on_click")
		}
	}
	local legend = {
		controller = {
			{
				text = "menu_legend_continue",
				padding = 24
			}
		},
		keyboard = {
			{
				key = "footer_continue",
				callback = callback(self, self, "_continue_button_on_click", nil)
			}
		}
	}

	if SystemInfo:platform() == Idstring("XB1") then
		local gamercard_prompts_shown = 0
		local stats_per_peer = {}

		for i = 1, #self._top_stats_big do
			if self._top_stats_big[i]:shown() then
				local binding = {
					key = Idstring(SpecialHonorsGui.GAMERCARD_BUTTONS[i][1]),
					callback = callback(self, self, "show_gamercard", i)
				}

				table.insert(bindings, binding)

				local peer_name = game_state_machine:current_state().special_honors[i].peer_name
				local found_peer = false

				for j = 1, #stats_per_peer do
					if stats_per_peer[j].name == peer_name then
						table.insert(stats_per_peer[j].buttons, SpecialHonorsGui.GAMERCARD_BUTTONS[i][3])

						found_peer = true
					end
				end

				if not found_peer then
					gamercard_prompts_shown = gamercard_prompts_shown + 1

					table.insert(stats_per_peer, {
						name = peer_name,
						buttons = {
							SpecialHonorsGui.GAMERCARD_BUTTONS[i][3]
						}
					})
				end
			end
		end

		for index, stat in pairs(stats_per_peer) do
			local translated_text = ""

			for i = 1, #stat.buttons do
				translated_text = translated_text .. managers.localization:get_default_macros()[stat.buttons[i]] .. " "
			end

			translated_text = translated_text .. utf8.to_upper(stat.name)

			table.insert(legend.controller, {
				translated_text = translated_text
			})
		end

		if gamercard_prompts_shown > 0 then
			table.insert(legend.controller, #legend.controller - gamercard_prompts_shown + 1, "menu_legend_gamercards_label")
		end
	end

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end
