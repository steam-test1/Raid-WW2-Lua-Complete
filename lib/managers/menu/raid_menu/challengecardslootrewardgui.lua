ChallengeCardsLootRewardGui = ChallengeCardsLootRewardGui or class(RaidGuiBase)
ChallengeCardsLootRewardGui.EVENT_KET_STEAM_LOOT_DROPPED = "event_key_steam_loot_dropped"

-- Lines 5-13
function ChallengeCardsLootRewardGui:init(ws, fullscreen_ws, node, component_name)
	ChallengeCardsLootRewardGui.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._timer_frequency = 30
	self._timer = 31
end

-- Lines 15-20
function ChallengeCardsLootRewardGui:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_challenge_cards")

	self._loot_list = clone(managers.challenge_cards:get_temp_steam_loot())
end

-- Lines 22-26
function ChallengeCardsLootRewardGui:_layout()
	self:bind_controller_inputs()
	self:_show_loot_list(self._loot_list)
end

-- Lines 28-39
function ChallengeCardsLootRewardGui:_show_loot_list(loot_list)
	local coord_y = 200
	local loot_reward_card_params = {
		x = 0,
		y = coord_y,
		w = self._root_panel:w(),
		h = self._root_panel:h() - coord_y,
		item_params = {
			item_w = 256,
			item_h = 352,
			wrapper_h = 600
		},
		loot_list = loot_list
	}
	self._loot_cards = self._root_panel:create_custom_control(RaidGUIControlLootRewardCards, loot_reward_card_params)
end

-- Lines 41-43
function ChallengeCardsLootRewardGui:update(t, dt)
end

-- Lines 45-47
function ChallengeCardsLootRewardGui:_continue_button_on_click()
	managers.raid_menu:close_menu()
end

-- Lines 49-58
function ChallengeCardsLootRewardGui:close()
	if self._closing then
		return
	end

	self._closing = true

	game_state_machine:current_state():continue()

	self._peer_slots = {}

	ChallengeCardsLootRewardGui.super.close(self)
end

-- Lines 60-63
function ChallengeCardsLootRewardGui:on_escape()
	self:_continue_button_on_click()

	return true
end

-- Lines 66-81
function ChallengeCardsLootRewardGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_continue_button_on_click")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_continue"
		},
		keyboard = {
			{
				key = "footer_continue",
				callback = callback(self, self, "_continue_button_on_click", nil)
			}
		}
	}

	self:set_legend(legend)
end
