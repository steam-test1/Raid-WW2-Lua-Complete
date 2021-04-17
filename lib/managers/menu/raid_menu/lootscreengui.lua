LootScreenGui = LootScreenGui or class(RaidGuiBase)
LootScreenGui.EVENT_KEY_PEER_LOOT_RECEIVED = "loot_screen_gui"
LootScreenGui.PROFILE_NAME_PADDING_LEFT = 64
LootScreenGui.PROFILE_NAME_OFFSET_DOWN = -4
LootScreenGui.PROFILE_NAME_FONT_SIZE = tweak_data.gui.font_sizes.menu_list
LootScreenGui.FONT = tweak_data.gui.fonts.din_compressed
LootScreenGui.TOTAL_LOOT_W = 224
LootScreenGui.TOTAL_LOOT_H = 64
LootScreenGui.LOOT_FONT_SIZE = tweak_data.gui.font_sizes.size_76
LootScreenGui.LOOT_COLOR = tweak_data.gui.colors.raid_red
LootScreenGui.LOOT_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
LootScreenGui.LOOT_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
LootScreenGui.ACQUIRED_LOOT_W = 224
LootScreenGui.ACQUIRED_LOOT_H = 64
LootScreenGui.ACQUIRED_LOOT_PADDING_RIGHT = 0
LootScreenGui.ACQUIRED_LOOT_PADDING_LEFT = 15
LootScreenGui.ACQUIRED_LOOT_PADDING_BOTTOM = 160
LootScreenGui.LOOT_PROGRESS_BAR_X = 64
LootScreenGui.LOOT_PROGRESS_BAR_Y = 288
LootScreenGui.LOOT_PROGRESS_BAR_PADDING_DOWN = 32
LootScreenGui.BRACKET_UNLOCKED_TITLE_Y = 128
LootScreenGui.BRACKET_UNLOCKED_TITLE_H = 32
LootScreenGui.BRACKET_UNLOCKED_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_32
LootScreenGui.BRACKET_UNLOCKED_TITLE_COLOR = tweak_data.gui.colors.raid_white
LootScreenGui.BRACKET_UNLOCKED_LABEL_H = 64
LootScreenGui.BRACKET_UNLOCKED_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_76
LootScreenGui.BRACKET_UNLOCKED_LABEL_COLOR = tweak_data.gui.colors.raid_red
LootScreenGui.LOCAL_LOOT_X = 401
LootScreenGui.LOCAL_LOOT_Y = 0
LootScreenGui.LOCAL_LOOT_W = 1327
LootScreenGui.LOCAL_LOOT_H = 928
LootScreenGui.PEER_LOOT_PANEL_X = 0
LootScreenGui.PEER_LOOT_PANEL_Y = 224
LootScreenGui.PEER_LOOT_PANEL_W = 544
LootScreenGui.PEER_LOOT_PANEL_H = 480
LootScreenGui.LOOT_INFO_RIBBON_Y = 768
LootScreenGui.LOOT_INFO_RIBBON_ICON = "rwd_stats_bg"
LootScreenGui.LOOT_INFO_RIBBON_ICON_CENTER_FROM_RIGHT = 320
LootScreenGui.LOOT_INFO_RIBBON_CENTER_Y = 800
LootScreenGui.LOOT_INFO_RIBBON_VALUE_CENTER_H = 60
LootScreenGui.LOOT_INFO_RIBBON_VALUE_CENTER_Y = 784
LootScreenGui.LOOT_INFO_RIBBON_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_52
LootScreenGui.LOOT_INFO_RIBBON_DESCRIPTION_CENTER_Y = 832
LootScreenGui.LOOT_INFO_RIBBON_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_24
LootScreenGui.LOOT_INFO_RIBBON_TEXT_COLOR = tweak_data.gui.colors.raid_white
LootScreenGui.LOOT_INFO_RIBBON_ACQUIRED_VALUE_W = 128
LootScreenGui.LOOT_INFO_RIBBON_TOTAL_VALUE_W = 96
LootScreenGui.LOOT_INFO_RIBBON_ACQUIRED_CENTER_FROM_RIGHT = 176
LootScreenGui.ONE_POINT_SOUND_EFFECT = "one_number_one_click"
LootScreenGui.CRATE_CHANGE_SOUND_EFFECT = "bronze_silver_gold_icon"
LootScreenGui.SLIDE_SOUND_EFFECT = "page_turn"
LootScreenGui.REWARD_SOUND_EFFECT = "generic_loot_reward_sound"
LootScreenGui.EMPTY_LOOT_ITEM_SOUND_EFFECT = "generic_fail_sound"
LootScreenGui.LOOT_ITEM_DOG_TAGS = "dog_tags"
LootScreenGui.LOOT_ITEM_TOP_STATS = "top_stats"
LootScreenGui.LOOT_ITEM_EXTRA_LOOT = "extra_loot"
LootScreenGui.GAMERCARD_BUTTONS = {
	{
		"menu_controller_face_left",
		"BTN_X"
	},
	{
		"menu_controller_face_top",
		"BTN_Y"
	},
	{
		"menu_controller_face_right",
		"BTN_B"
	}
}
LootScreenGui.LOOT_DATA_ORDER = {
	LootScreenGui.LOOT_ITEM_DOG_TAGS,
	LootScreenGui.LOOT_ITEM_TOP_STATS,
	LootScreenGui.LOOT_ITEM_EXTRA_LOOT
}
LootScreenGui.LOOT_BOXES_IMAGES = {
	"loot_crate_default",
	"loot_crate_bronze",
	"loot_crate_silver",
	"loot_crate_gold"
}

function LootScreenGui:init(ws, fullscreen_ws, node, component_name)
	print("[LootScreenGui:init()]")

	self._closing = false
	self._peer_slots = {}
	self.peer_loot_shown = false
	self.showing_loot = false
	self.local_loot_shown = false
	self.current_state = game_state_machine:current_state()
	self._callback_handler = RaidMenuCallbackHandler:new()

	LootScreenGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_loot_screen_title")
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._local_peer_id = managers.network:session():local_peer():id()
end

function LootScreenGui:_layout()
	LootScreenGui.super._layout(self)
	self:_create_fullscreen_panel()
	self:_create_flares()
	self:_layout_loot_breakdown_items()
	self:_layout_loot_crates()
	self:_layout_first_screen()
	self:_layout_second_screen()
	self:refresh_peers_loot_display()

	local loot_acquired = self.current_state.loot_acquired
	local loot_spawned = self.current_state.loot_spawned

	self:bind_controller_inputs()
	self:give_points(loot_acquired, loot_spawned)
end

function LootScreenGui:_create_fullscreen_panel()
	self._full_workspace = Overlay:gui():create_screen_workspace()
	self._fullscreen_panel = self._full_workspace:panel()
end

function LootScreenGui:_create_flares()
	local flare_panel_params = {
		layer = 1,
		name = "loot_screen_flare_panel"
	}
	self._flare_panel = self._fullscreen_panel:panel(flare_panel_params)
	local lens_glint_params = {
		blend_mode = "add",
		name = "loot_screen_glint",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_glint.texture,
		texture_rect = tweak_data.gui.icons.lens_glint.texture_rect
	}
	self._lens_glint = self._flare_panel:bitmap(lens_glint_params)

	self._lens_glint:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)

	local lens_iris_params = {
		blend_mode = "add",
		name = "loot_screen_iris",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_iris.texture,
		texture_rect = tweak_data.gui.icons.lens_iris.texture_rect
	}
	self._lens_iris = self._flare_panel:bitmap(lens_iris_params)

	self._lens_iris:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)

	local lens_orbs_params = {
		blend_mode = "add",
		name = "loot_screen_orbs",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_orbs.texture,
		texture_rect = tweak_data.gui.icons.lens_orbs.texture_rect
	}
	self._lens_orbs = self._flare_panel:bitmap(lens_orbs_params)

	self._lens_orbs:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)

	local lens_shimmer_params = {
		blend_mode = "add",
		name = "loot_screen_shimmer",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_shimmer.texture,
		texture_rect = tweak_data.gui.icons.lens_shimmer.texture_rect
	}
	self._lens_shimmer = self._flare_panel:bitmap(lens_shimmer_params)

	self._lens_shimmer:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)

	local lens_spike_ball_params = {
		blend_mode = "add",
		name = "loot_screen_spike_ball",
		alpha = 0,
		texture = tweak_data.gui.icons.lens_spike_ball.texture,
		texture_rect = tweak_data.gui.icons.lens_spike_ball.texture_rect
	}
	self._lens_spike_ball = self._flare_panel:bitmap(lens_spike_ball_params)

	self._lens_spike_ball:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
end

function LootScreenGui:_layout_profile_name()
	local x, y, w, h = self._node.components.raid_menu_header:get_screen_name_rect()
	local profile_name_label_params = {
		name = "loot_screen_profile_name_label",
		h = 64,
		y = 0,
		w = 400,
		x = x + w + LootScreenGui.PROFILE_NAME_PADDING_LEFT,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.PROFILE_NAME_FONT_SIZE,
		text = utf8.to_upper(managers.player:get_character_profile_name())
	}
	self._profile_name = self._root_panel:text(profile_name_label_params)
	local _, _, profile_name_w, profile_name_h = self._profile_name:text_rect()

	self._profile_name:set_w(profile_name_w)
	self._profile_name:set_h(profile_name_h)
	self._profile_name:set_bottom(y + h + LootScreenGui.PROFILE_NAME_OFFSET_DOWN)
end

function LootScreenGui:_layout_loot_breakdown_items()
	local persistent_panel_params = {
		layer = 10,
		name = "loot_screen_persistent_panel"
	}
	self._persistent_panel = self._root_panel:panel(persistent_panel_params)
	local v = true

	if managers.challenge_cards.forced_loot_card then
		v = false
	end

	local loot_data_panel_params = {
		name = "loot_screen_loot_data_panel",
		h = 426,
		y = 51,
		visible = v
	}
	self._loot_data_panel = self._persistent_panel:panel(loot_data_panel_params)
	self._loot_breakdown_items = {}
	self._loot_acquired = 0
	self._loot_total = 0
	local loot_breakdown_items = game_state_machine:current_state().loot_data
	local breakdown_items_w = 0

	for index, loot_id in ipairs(LootScreenGui.LOOT_DATA_ORDER) do
		if loot_breakdown_items[loot_id] then
			local loot_item_params = {
				name = "loot_screen_loot_item_" .. index,
				title = loot_breakdown_items[loot_id].title,
				icon = loot_breakdown_items[loot_id].icon,
				acquired = loot_breakdown_items[loot_id].acquired,
				total = loot_breakdown_items[loot_id].total
			}
			local loot_item = self._loot_data_panel:create_custom_control(RaidGUIControlLootBreakdownItem, loot_item_params)

			loot_item:set_center_x(self._loot_data_panel:w() / 2)
			loot_item:set_visible(v)
			table.insert(self._loot_breakdown_items, loot_item)

			self._loot_acquired = self._loot_acquired + loot_breakdown_items[loot_id].acquired

			if loot_breakdown_items[loot_id].total then
				self._loot_total = self._loot_total + loot_breakdown_items[loot_id].total
			end

			breakdown_items_w = breakdown_items_w + loot_item:w()
		end
	end
end

function LootScreenGui:_layout_loot_crates()
	local loot_crate_panel_params = {
		alpha = 1,
		name = "loot_Screen_loot_crate_panel",
		layer = 5
	}
	self._loot_crate_panel = self._root_panel:panel(loot_crate_panel_params)
	self._crate_images = {}

	if not managers.challenge_cards.forced_loot_card then
		for index, crate_image in ipairs(LootScreenGui.LOOT_BOXES_IMAGES) do
			local crate_image_params = {
				alpha = 0,
				name = "loot_screen_crate_image_" .. index,
				texture = tweak_data.gui.icons[crate_image].texture,
				texture_rect = tweak_data.gui.icons[crate_image].texture_rect,
				layer = index
			}
			local crate_image = self._loot_crate_panel:bitmap(crate_image_params)

			crate_image:set_center_x(self._loot_crate_panel:w() / 2)
			crate_image:set_center_y(self._loot_crate_panel:h() / 2)
			table.insert(self._crate_images, crate_image)
		end
	else
		local card_params = {
			item_w = 496,
			name = "player_loot_card",
			x = 64,
			item_h = 671
		}
		local card_control = self._loot_crate_panel:create_custom_control(RaidGUIControlCardBase, card_params)

		card_control:set_card(managers.challenge_cards.forced_loot_card)
		card_control:set_center_x(self._loot_crate_panel:w() / 2)
		card_control:set_center_y(self._loot_crate_panel:h() / 2)
		table.insert(self._crate_images, card_control)
	end

	if self._crate_images[1] then
		self._crate_images[1]:set_alpha(1)
	end

	self._crate_image_shown = 1
end

function LootScreenGui:_layout_first_screen()
	local first_screen_panel_params = {
		alpha = 0,
		name = "first_screen_panel",
		y = 0,
		x = 0,
		w = self._root_panel:w(),
		h = self._root_panel:h()
	}
	self._first_screen_panel = self._root_panel:panel(first_screen_panel_params)
	self._brackets = self:_get_loot_point_data()
	local loot_progress_bar_params = {
		name = "loot_progress_bar",
		total_points = 1100,
		x = LootScreenGui.LOOT_PROGRESS_BAR_X,
		y = LootScreenGui.LOOT_PROGRESS_BAR_Y,
		brackets = self._brackets
	}
	self._loot_progress_bar = self._first_screen_panel:create_custom_control(RaidGUIControlLootProgressBar, loot_progress_bar_params)
	local total_loot_params = {
		vertical = "center",
		name = "total_loot",
		align = "center",
		text = "0000",
		x = self._first_screen_panel:w() / 2,
		y = self._loot_progress_bar:y() + self._loot_progress_bar:h() + LootScreenGui.LOOT_PROGRESS_BAR_PADDING_DOWN,
		w = LootScreenGui.TOTAL_LOOT_W,
		h = LootScreenGui.TOTAL_LOOT_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.LOOT_FONT_SIZE,
		color = LootScreenGui.LOOT_COLOR
	}
	self._total_loot_label = self._first_screen_panel:text(total_loot_params)
	local total_loot_description_params = {
		vertical = "center",
		name = "total_loot",
		align = "center",
		x = self._first_screen_panel:w() / 2,
		y = self._total_loot_label:y() + self._total_loot_label:h(),
		w = LootScreenGui.TOTAL_LOOT_W,
		h = LootScreenGui.TOTAL_LOOT_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.LOOT_DESCRIPTION_FONT_SIZE,
		color = LootScreenGui.LOOT_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_total_loot", true)
	}
	local total_loot_description = self._first_screen_panel:text(total_loot_description_params)
	local acquired_loot_params = {
		name = "acquired_loot",
		vertical = "center",
		align = "center",
		text = "0000",
		y = self._total_loot_label:y(),
		w = LootScreenGui.ACQUIRED_LOOT_W,
		h = LootScreenGui.ACQUIRED_LOOT_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.LOOT_FONT_SIZE,
		color = LootScreenGui.LOOT_COLOR
	}
	self._acquired_loot_label = self._first_screen_panel:text(acquired_loot_params)

	self._acquired_loot_label:set_right(self._first_screen_panel:w() / 2)

	local acquired_loot_description_params = {
		name = "total_loot",
		vertical = "center",
		align = "center",
		y = total_loot_description:y(),
		w = LootScreenGui.ACQUIRED_LOOT_W,
		h = LootScreenGui.ACQUIRED_LOOT_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.LOOT_DESCRIPTION_FONT_SIZE,
		color = LootScreenGui.LOOT_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_acquired_loot", true)
	}
	local acquired_loot_description = self._first_screen_panel:text(acquired_loot_description_params)

	acquired_loot_description:set_right(self._first_screen_panel:w() / 2)

	local bracket_unlocked_title_params = {
		vertical = "top",
		name = "bracket_unlocked_title",
		w = 400,
		align = "left",
		alpha = 0,
		x = 0,
		y = LootScreenGui.BRACKET_UNLOCKED_TITLE_Y,
		h = LootScreenGui.BRACKET_UNLOCKED_TITLE_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.BRACKET_UNLOCKED_TITLE_FONT_SIZE,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true),
		color = LootScreenGui.BRACKET_UNLOCKED_TITLE_COLOR
	}
	self._bracket_unlocked_title = self._first_screen_panel:text(bracket_unlocked_title_params)
	local bracket_unlocked_label_params = {
		vertical = "center",
		name = "bracket_unlocked_label",
		w = 100,
		align = "center",
		alpha = 0,
		text = "",
		x = 0,
		y = self._bracket_unlocked_title:y() + self._bracket_unlocked_title:h(),
		h = LootScreenGui.BRACKET_UNLOCKED_LABEL_H,
		font = LootScreenGui.FONT,
		font_size = LootScreenGui.BRACKET_UNLOCKED_LABEL_FONT_SIZE,
		color = LootScreenGui.BRACKET_UNLOCKED_LABEL_COLOR
	}
	self._bracket_unlocked_label = self._first_screen_panel:text(bracket_unlocked_label_params)
end

function LootScreenGui:_layout_second_screen()
	local second_screen_panel_params = {
		name = "second_screen_panel",
		y = 0,
		x = 0,
		w = self._root_panel:w(),
		h = self._root_panel:h()
	}
	self._second_screen_panel = self._root_panel:panel(second_screen_panel_params)
	self._local_loot_panel = self._second_screen_panel:panel({
		visible = false,
		name = "local_loot_panel",
		layer = 10,
		x = LootScreenGui.LOCAL_LOOT_X,
		y = LootScreenGui.LOCAL_LOOT_Y,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	})
	self._peer_loot_panel = self._second_screen_panel:panel({
		visible = false,
		name = "peer_loot_panel",
		alpha = 0,
		x = LootScreenGui.PEER_LOOT_PANEL_X,
		y = LootScreenGui.PEER_LOOT_PANEL_Y,
		w = LootScreenGui.PEER_LOOT_PANEL_W,
		h = LootScreenGui.PEER_LOOT_PANEL_H
	})
	local customization_reward_params = {
		y = 0,
		name = "customization_reward",
		visible = false,
		x = 0,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H,
		redeem_customization_callback = callback(self, self, "redeem_customization_xp")
	}
	self._customization_details = self._local_loot_panel:create_custom_control(RaidGUIControlCharacterCustomizationDetails, customization_reward_params)
	local customization = tweak_data.character_customization.customizations.russian_default_head

	self._customization_details:set_customization(customization)

	local card_pack_reward_params = {
		y = 0,
		name = "card_pack_reward",
		visible = false,
		x = 0,
		layer = 15,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	}
	self._card_pack_reward = self._local_loot_panel:create_custom_control(RaidGUIControlRewardCardPack, card_pack_reward_params)
	local xp_reward_params = {
		y = 0,
		name = "xp_reward",
		visible = false,
		x = 0,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	}
	self._xp_reward = self._local_loot_panel:create_custom_control(RaidGUIControlXPRewardDetails, xp_reward_params)
	local weapon_point_reward_params = {
		y = 0,
		name = "weapon_point_reward",
		visible = false,
		x = 0,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	}
	self._weapon_point_reward = self._local_loot_panel:create_custom_control(RaidGUIControlWeaponPointRewardDetails, weapon_point_reward_params)
	local melee_weapon_reward_params = {
		y = 0,
		name = "melee_weapon_reward",
		visible = false,
		x = 0,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	}
	self._melee_weapon_reward = self._local_loot_panel:create_custom_control(RaidGUIControlMeleeWeaponRewardDetails, melee_weapon_reward_params)
	local gold_bar_reward_params = {
		y = 0,
		name = "gold_bar_reward",
		visible = false,
		x = 0,
		w = LootScreenGui.LOCAL_LOOT_W,
		h = LootScreenGui.LOCAL_LOOT_H
	}
	self._gold_bar_reward = self._local_loot_panel:create_custom_control(RaidGUIControlGoldBarRewardDetails, gold_bar_reward_params)
end

function LootScreenGui:_get_loot_point_data()
	local tree = {
		{
			activated = false,
			tier = "bronze",
			points_needed = LootDropTweakData.BRONZE_POINT_REQUIREMENT
		},
		{
			activated = false,
			tier = "silver",
			points_needed = LootDropTweakData.SILVER_POINT_REQUIREMENT
		},
		{
			activated = false,
			tier = "gold",
			points_needed = LootDropTweakData.GOLD_POINT_REQUIREMENT
		}
	}

	return tree
end

function LootScreenGui:data_source_branching_progress_bar()
	return self:_get_loot_point_data()
end

function LootScreenGui:_show_local_loot_display()
	local drop = self.current_state.local_player_loot_drop

	Application:trace("[LootScreenGui:_show_local_loot_display] drop ", inspect(drop))

	if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		self._card_pack_reward:set_cards(managers.challenge_cards:get_temp_steam_loot())
		self._card_pack_reward:show()

		if not managers.raid_menu:is_pc_controller() then
			self._card_pack_reward:set_selected(true)
			self:bind_controller_inputs_card_rewards()
		end
	elseif drop.reward_type == LootDropTweakData.REWARD_XP then
		self._xp_reward:set_xp_reward(drop.awarded_xp)
		self._xp_reward:show()
	elseif drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		self._customization_details:set_customization(drop.character_customization)
		self._customization_details:show()

		if drop.duplicate then
			self._customization_details:set_duplicate()
		end
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		self._weapon_point_reward:show()
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		self._melee_weapon_reward:set_melee_weapon(drop.weapon_id)
		self._melee_weapon_reward:show()
	elseif drop.reward_type == LootDropTweakData.REWARD_GOLD_BARS then
		self._gold_bar_reward:set_gold_bar_reward(drop.awarded_gold_bars)
		self._gold_bar_reward:show()
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		self._melee_weapon_reward:set_melee_weapon(drop.weapon_id)
		self._melee_weapon_reward:show()
	end
end

function LootScreenGui:refresh_peers_loot_display()
	local peer_drops = self.current_state.peers_loot_drops

	for _, drop in ipairs(peer_drops) do
		self:on_loot_dropped_for_peer(drop)
	end
end

function LootScreenGui:_continue_button_on_click()
	if not self.showing_loot then
		self._root_panel:get_engine_panel():stop()
		self._root_panel:get_engine_panel():animate(callback(self, self, "_animate_show_loot"))
	elseif not self.local_loot_shown then
		return
	else
		managers.raid_menu:close_menu()
	end
end

function LootScreenGui:redeem_card_xp()
	managers.menu:close_menu("raid_menu_loot_screen")
end

function LootScreenGui:redeem_customization_xp()
	managers.menu:close_menu("raid_menu_loot_screen")
end

function LootScreenGui:show_gamercard(i)
	local peer_id = self._peer_slots[i].peer_id
	local peer = managers.network:session():peer(peer_id)

	Application:trace("[LootScreenGui:show_gamercard] showing gamercard for peer " .. tostring(peer:name()))
	Application:debug("[LootScreenGui:show_gamercard]", inspect(peer))
	self._callback_handler:view_gamer_card(peer:xuid())
end

function LootScreenGui:close()
	self._root_panel:get_engine_panel():stop()

	if self._closing then
		return
	end

	self._closing = true

	if game_state_machine:current_state_name() == "event_complete_screen" then
		game_state_machine:current_state():continue()
	end

	managers.lootdrop:remove_listener(LootScreenGui.EVENT_KEY_PEER_LOOT_RECEIVED)

	self.peer_loot_shown = false
	self.showing_loot = false
	self.local_loot_shown = false
	self._peer_slots = {}

	Overlay:gui():destroy_workspace(self._full_workspace)
	LootScreenGui.super.close(self)

	if not managers.raid_menu:is_pc_controller() then
		self._card_pack_reward:set_selected(false)
	end
end

function LootScreenGui:on_loot_dropped_for_peer(drop)
	local slot = nil

	for i_slot, peer_slot in ipairs(self._peer_slots) do
		if peer_slot.peer_id == drop.peer_id then
			slot = peer_slot

			return
		end
	end

	if not slot then
		slot = {
			peer_id = drop.peer_id,
			peer_name = drop.peer_name,
			index = #self._peer_slots + 1
		}

		table.insert(self._peer_slots, slot)
	end

	local peer_loot_params = {
		text = "",
		visible = true,
		x = 0,
		name = "peer_reward_" .. slot.peer_id,
		y = (slot.index - 1) * self._peer_loot_panel:h() / 3
	}

	if drop.reward_type == LootDropTweakData.REWARD_XP then
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlExperiencePeerLoot, peer_loot_params)

		slot.control:set_xp(drop.awarded_xp)
	elseif drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlPeerRewardCardPack, peer_loot_params)
	elseif drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		peer_loot_params.customization = drop.character_customization
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlCharacterCustomizationPeerLoot, peer_loot_params)

		slot.control:set_customization(drop.character_customization)
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlWeaponPointPeerLoot, peer_loot_params)
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		peer_loot_params.weapon_id = drop.weapon_id
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlMeleeWeaponPeerLoot, peer_loot_params)

		slot.control:set_melee_weapon(drop.weapon_id)
	elseif drop.reward_type == LootDropTweakData.REWARD_GOLD_BARS then
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlGoldBarPeerLoot, peer_loot_params)

		slot.control:set_gold_bar_reward(drop.awarded_gold_bars)
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		peer_loot_params.weapon_id = drop.weapon_id
		slot.control = self._peer_loot_panel:create_custom_control(RaidGUIControlMeleeWeaponPeerLoot, peer_loot_params)

		slot.control:set_melee_weapon(drop.weapon_id)
	end

	local player_name = nil

	if drop and drop.peer_name then
		player_name = drop.peer_name
	else
		player_name = "ERROR: no peer id for player"
	end

	slot.control:set_player_name(utf8.to_upper(player_name))

	if self.peer_loot_shown then
		local drop = self.current_state.local_player_loot_drop

		if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
			self:bind_controller_inputs_card_rewards()
		else
			self:bind_controller_inputs()
		end
	end
end

function LootScreenGui:give_points(points_acquired, points_total)
	self._root_panel:get_engine_panel():animate(callback(self, self, "_animate_giving_points"), points_acquired, points_total)
end

function LootScreenGui:set_points(points_acquired, points_total)
	self._acquired_loot_label:set_text(string.format("%04.0f", math.ceil(points_acquired)))

	for index, bracket in pairs(self._brackets) do
		if bracket.points_needed <= points_acquired and not bracket.activated then
			bracket.activated = true
		end
	end
end

function LootScreenGui:_loot_counter_timer_value(percentage)
	local longest_timer = 0.07
	local shortest_timer = 0.055

	return longest_timer * math.sin(2 * math.deg(math.pi) * (percentage + 1) + 90) + longest_timer + shortest_timer
end

function LootScreenGui:_crate_shown_for_points_given(points)
	local loot_total = math.max(1, self._loot_total or 0)
	local points_percentage = math.clamp(points / loot_total, 0, 1)
	local crate_index = 1

	for _, group_requirement in pairs(LootDropTweakData.POINT_REQUIREMENTS) do
		if group_requirement < points_percentage then
			crate_index = crate_index + 1
		end
	end

	return crate_index
end

function LootScreenGui:_animate_change_crate(panel, new_crate_index)
	local duration = 0.25
	local fade_out_duration_percentage = 0.6
	local fade_in_duration_percentage = 0.6
	local t = 0
	local old_crate_index = self._crate_image_shown
	self._crate_image_shown = new_crate_index
	local old_image_w, old_image_h = self._crate_images[old_crate_index]:size()
	local new_image_w, new_image_h = self._crate_images[new_crate_index]:size()

	managers.menu_component:post_event(LootScreenGui.CRATE_CHANGE_SOUND_EFFECT)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local old_image_alpha = Easing.quartic_in(t, 1, -1, duration * fade_out_duration_percentage)

		self._crate_images[old_crate_index]:set_alpha(old_image_alpha)

		local old_image_scale = Easing.quartic_in(t, 1, -0.3, duration * fade_out_duration_percentage)

		self._crate_images[old_crate_index]:set_size(old_image_w * old_image_scale, old_image_h * old_image_scale)
		self._crate_images[old_crate_index]:set_center_x(self._loot_crate_panel:w() / 2)
		self._crate_images[old_crate_index]:set_center_y(self._loot_crate_panel:h() / 2)

		if t >= (1 - fade_in_duration_percentage) * duration then
			local new_image_alpha = Easing.quintic_in_out(t - (1 - fade_in_duration_percentage) * duration, 0, 1, duration * fade_in_duration_percentage)

			self._crate_images[new_crate_index]:set_alpha(new_image_alpha)

			local new_image_scale = Easing.quintic_in_out(t - (1 - fade_in_duration_percentage) * duration, 1.5, -0.5, duration * fade_in_duration_percentage)

			self._crate_images[new_crate_index]:set_size(new_image_w * new_image_scale, new_image_h * new_image_scale)
			self._crate_images[new_crate_index]:set_center_x(self._loot_crate_panel:w() / 2)
			self._crate_images[new_crate_index]:set_center_y(self._loot_crate_panel:h() / 2)
		end
	end

	self._crate_images[old_crate_index]:set_alpha(0)
	self._crate_images[new_crate_index]:set_alpha(1)
end

function LootScreenGui:_animate_crate_hide(panel)
	local duration = 0.2
	local t = 0
	local initial_w, initial_h = self._crate_images[self._crate_image_shown]:size()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local crate_alpha = Easing.quartic_in(t, 1, -1, duration)

		self._crate_images[self._crate_image_shown]:set_alpha(crate_alpha)

		local crate_scale = Easing.quartic_in(t, 1, -0.4, duration)

		self._crate_images[self._crate_image_shown]:set_size(initial_w * crate_scale, initial_h * crate_scale)
		self._crate_images[self._crate_image_shown]:set_center_x(self._loot_crate_panel:w() / 2)
		self._crate_images[self._crate_image_shown]:set_center_y(self._loot_crate_panel:h() / 2)
	end

	self._crate_images[self._crate_image_shown]:set_alpha(0)

	self._crate_image_shown = nil
end

function LootScreenGui:_animate_giving_points(panel, points_acquired, points_total)
	local t = 0
	self._given_points = false
	self._started_lens_flares = false

	if (not managers.raid_job:current_job() or not managers.raid_job:current_job().consumable) and not managers.challenge_cards.forced_loot_card then
		wait(0.6)

		local points_given_total = 0

		for index, loot_item in pairs(self._loot_breakdown_items) do
			local points_given = 0
			local points_acquired = loot_item:acquired()

			if index ~= 1 then
				for i = 1, index - 1 do
					self._loot_breakdown_items[i]:animate_move_right(loot_item:w())
				end

				wait(0.1)
				managers.menu_component:post_event(LootScreenGui.SLIDE_SOUND_EFFECT)
				wait(0.2)
			end

			loot_item:animate_show()

			local t = nil

			if points_acquired > 7 then
				t = self:_loot_counter_timer_value(0)
			else
				t = 0.12
			end

			if points_acquired <= 0 then
				loot_item:animate_empty()

				t = 0
			end

			while points_given < points_acquired do
				local dt = coroutine.yield()
				t = t - dt

				if t <= 0 then
					if points_acquired > 7 then
						t = self:_loot_counter_timer_value(points_given / points_acquired)
					else
						t = 0.12
					end

					managers.menu_component:post_event(LootScreenGui.ONE_POINT_SOUND_EFFECT)
					loot_item:add_point(math.clamp(t, 0.15, 100))

					points_given = points_given + 1
					points_given_total = points_given_total + 1
					local shown_crate_index = self:_crate_shown_for_points_given(points_given_total)

					if shown_crate_index ~= self._crate_image_shown and self._crate_images[1] then
						self._crate_images[1]:stop()
						self._crate_images[1]:animate(callback(self, self, "_animate_change_crate"), shown_crate_index)
					end
				end
			end

			loot_item:stop_animating_icon()

			if points_acquired > 0 then
				wait(1)
			end
		end

		self._given_points = true
	elseif managers.challenge_cards.forced_loot_card then
		wait(1)
	end

	self:_animate_show_loot(panel)
end

function LootScreenGui:_finalize_giving_points()
	local shown_crate_index = self:_crate_shown_for_points_given(self._loot_acquired)
	self._crate_image_shown = shown_crate_index

	for index, crate_image in ipairs(self._crate_images) do
		if index == shown_crate_index then
			crate_image:set_alpha(1)
			crate_image:set_center_x(self._loot_crate_panel:w() / 2)
			crate_image:set_center_y(self._loot_crate_panel:h() / 2)

			if not managers.challenge_cards.forced_loot_card then
				local crate_w = tweak_data.gui:icon_w(LootScreenGui.LOOT_BOXES_IMAGES[index])
				local crate_h = tweak_data.gui:icon_h(LootScreenGui.LOOT_BOXES_IMAGES[index])

				crate_image:set_size(crate_w, crate_h)
			else
				crate_image:show()
			end
		else
			crate_image:set_alpha(0)
		end
	end

	local center_x = self._loot_data_panel:w() / 2

	for i = #self._loot_breakdown_items, 1, -1 do
		local loot_item = self._loot_breakdown_items[i]

		loot_item:finalize()
		loot_item:check_state()
		loot_item:set_center_x(center_x)

		center_x = center_x + loot_item:w()

		if i ~= #self._loot_breakdown_items then
			loot_item:fade()
		end
	end
end

function LootScreenGui:_animate_lens_flares()
	local fade_in_duration = 1.1
	local t = 0
	local icon_w = self._lens_glint:w()
	local icon_h = self._lens_glint:h()

	while t < fade_in_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.65, fade_in_duration)

		self._lens_glint:set_alpha(current_alpha)
		self._lens_orbs:set_alpha(current_alpha)
		self._lens_shimmer:set_alpha(current_alpha)
		self._lens_spike_ball:set_alpha(current_alpha)

		local current_scale = Easing.quartic_in_out(t, 0.6, 0.4, fade_in_duration)

		self._lens_glint:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_orbs:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_shimmer:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_spike_ball:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_glint:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_orbs:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_shimmer:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_spike_ball:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_glint:rotate(math.random() * 0.06 + 0.1)
		self._lens_shimmer:rotate(math.random() * -0.08 - 0.13)
		self._lens_spike_ball:rotate(math.random() * 0.11 + 0.06)
	end

	while true do
		local dt = coroutine.yield()
		t = t + dt

		self._lens_glint:rotate(math.random() * 0.06 + 0.1)
		self._lens_shimmer:rotate(math.random() * -0.08 - 0.13)
		self._lens_spike_ball:rotate(math.random() * 0.11 + 0.06)
	end
end

function LootScreenGui:_animate_hide_lens_flares()
	local fade_out_duration = 0.2
	local t = 0

	wait(0.1)

	local icon_w = self._lens_glint:w()
	local icon_h = self._lens_glint:h()

	while t < fade_out_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.65, -0.65, fade_out_duration)

		self._flare_panel:set_alpha(current_alpha)

		local current_scale = Easing.quartic_in_out(t, 1, -0.7, fade_out_duration)

		self._lens_glint:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_orbs:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_shimmer:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_spike_ball:set_size(icon_w * current_scale, icon_h * current_scale)
		self._lens_glint:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_orbs:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_shimmer:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
		self._lens_spike_ball:set_center(self._flare_panel:w() / 2, self._flare_panel:h() / 2)
	end

	self._flare_panel:set_alpha(0)
end

function LootScreenGui:_animate_show_loot(panel)
	self.showing_loot = true

	self._first_screen_panel:set_alpha(0)
	self:_finalize_giving_points()

	if not self._started_lens_flares then
		self._lens_glint:animate(callback(self, self, "_animate_lens_flares"))

		self._started_lens_flares = true
	end

	if not self._given_points then
		wait(1)
	end

	self.current_state:drop_loot_for_player()

	for index, loot_item in pairs(self._loot_breakdown_items) do
		loot_item:hide((index - 1) * 0.08)
	end

	wait(1)

	while not self.current_state.local_player_loot_drop do
		coroutine.yield()
	end

	if not managers.challenge_cards.forced_loot_card then
		self._crate_images[1]:stop()
		self._crate_images[1]:animate(callback(self, self, "_animate_crate_hide"))
	else
		wait(1.5)
		self._crate_images[1]:hide()
	end

	self._local_loot_panel:set_visible(true)
	managers.menu_component:post_event(LootScreenGui.REWARD_SOUND_EFFECT)
	wait(0.1)
	self._lens_glint:animate(callback(self, self, "_animate_hide_lens_flares"))
	self:_show_local_loot_display()

	self.local_loot_shown = true

	wait(0.5)
	self._peer_loot_panel:set_visible(true)

	self.peer_loot_shown = true
	local t = 0
	local peer_loot_fade_in_duration = 0.6

	while t < peer_loot_fade_in_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, peer_loot_fade_in_duration)

		self._peer_loot_panel:set_alpha(current_alpha)
	end

	self._peer_loot_panel:set_alpha(1)

	local drop = self.current_state.local_player_loot_drop

	if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		self:bind_controller_inputs_card_rewards()
	else
		self:bind_controller_inputs()
	end
end

function LootScreenGui:_animate_bracket_unlocked_label(label, new_bracket)
	local fade_out_duration = 0.15
	local t = (1 - self._bracket_unlocked_label:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._bracket_unlocked_label:set_alpha(current_alpha)
	end

	self._bracket_unlocked_title:set_alpha(0)
	self._bracket_unlocked_label:set_alpha(0)

	local text = managers.localization:text("menu_loot_screen_bracket_unlocked", {
		BRACKET = managers.localization:text("menu_loot_screen_bracket_" .. tostring(new_bracket))
	})

	self._bracket_unlocked_label:set_text(utf8.to_upper(text))

	local _, _, w, h = self._bracket_unlocked_label:text_rect()

	self._bracket_unlocked_label:set_w(w)
	self._bracket_unlocked_label:set_h(h)
	self._bracket_unlocked_label:set_center_x(self._first_screen_panel:w() / 2)
	self._bracket_unlocked_title:set_x(self._bracket_unlocked_label:x())
	managers.menu_component:post_event("bronze_silver_gold_prize")

	local fade_in_duration = 0.2
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._bracket_unlocked_title:set_alpha(current_alpha)
		self._bracket_unlocked_label:set_alpha(current_alpha)
	end

	self._bracket_unlocked_title:set_alpha(1)
	self._bracket_unlocked_label:set_alpha(1)
end

function LootScreenGui:_reveal_challenge_card()
	self._card_pack_reward:confirm_pressed()
	self:bind_controller_inputs_card_rewards()
end

function LootScreenGui:move_left()
	local drop = self.current_state.local_player_loot_drop

	if not drop then
		return false
	end

	if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		self._card_pack_reward:move_left()
		self:bind_controller_inputs_card_rewards()
	end

	return true
end

function LootScreenGui:move_right()
	local drop = self.current_state.local_player_loot_drop

	if not drop then
		return false
	end

	if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		self._card_pack_reward:move_right()
		self:bind_controller_inputs_card_rewards()
	end

	return true
end

function LootScreenGui:confirm_pressed()
	local selected_card_idx = self._card_pack_reward:selected_item_idx()

	if selected_card_idx == nil then
		self:_continue_button_on_click()
	elseif self._card_pack_reward:is_selected_card_revealed() then
		self:_continue_button_on_click()
	else
		self:_reveal_challenge_card()
	end
end

function LootScreenGui:on_escape()
	return true
end

function LootScreenGui:bind_controller_inputs()
	local bindings = {}
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
	bindings, legend = self:_check_gamercard_prompts(bindings, legend)

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function LootScreenGui:bind_controller_inputs_card_rewards()
	local bindings = {}
	local legend = {
		controller = {},
		keyboard = {
			{
				key = "footer_continue",
				callback = callback(self, self, "_continue_button_on_click", nil)
			}
		}
	}

	if self._card_pack_reward:is_selected_card_revealed() then
		table.insert(legend.controller, "menu_legend_continue")

		self._confirm_pressed_flag = "continue"
	else
		table.insert(legend.controller, {
			translated_text = utf8.to_upper(managers.localization:text("menu_legend_loot_reward_reveal_challenge_card", {
				BTN_Y = managers.localization:get_default_macros().BTN_A
			}))
		})

		self._confirm_pressed_flag = "reveal_card"
	end

	bindings, legend = self:_check_gamercard_prompts(bindings, legend)

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function LootScreenGui:_check_gamercard_prompts(bindings, legend)
	if SystemInfo:platform() == Idstring("XB1") and self.peer_loot_shown then
		local gamercard_prompts_shown = 0

		for i = 1, #self._peer_slots do
			local keybind = {
				key = Idstring(LootScreenGui.GAMERCARD_BUTTONS[i][1]),
				callback = callback(self, self, "show_gamercard", i)
			}

			table.insert(bindings, keybind)

			local translated_text = managers.localization:get_default_macros()[LootScreenGui.GAMERCARD_BUTTONS[i][2]]
			translated_text = translated_text .. utf8.to_upper(self._peer_slots[i].peer_name)

			table.insert(legend.controller, {
				translated_text = translated_text
			})

			gamercard_prompts_shown = gamercard_prompts_shown + 1
		end

		if gamercard_prompts_shown > 0 then
			table.insert(legend.controller, #legend.controller - gamercard_prompts_shown + 1, "menu_legend_gamercards_label")
		end
	end

	return bindings, legend
end
