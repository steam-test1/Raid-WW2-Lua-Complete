HUDNotification = HUDNotification or class()
HUDNotificationCardFail = HUDNotificationCardFail or class(HUDNotification)
HUDNotificationProgress = HUDNotificationProgress or class(HUDNotification)
HUDNotificationIcon = HUDNotificationIcon or class(HUDNotification)
HUDNotification.GENERIC = "generic"
HUDNotification.ICON = "icon"
HUDNotification.RAID_UNLOCKED = "raid_unlocked"
HUDNotification.CARD_FAIL = "card_fail"
HUDNotification.GREED_ITEM = "greed_item_pickup"
HUDNotification.DOG_TAG = "dog_tag"
HUDNotification.WEAPON_CHALLENGE = "weapon_challenge"
HUDNotification.CONSUMABLE_MISSION_PICKED_UP = "consumable_mission_picked_up"
HUDNotification.ACTIVE_DUTY_BONUS = "active_duty_bonus"
HUDNotification.ACTIVE_DUTY_BONUS_OUTLAW = "active_duty_bonus_outlaw"
HUDNotification.TYPES = {
	[HUDNotification.GENERIC] = HUDNotification,
	[HUDNotification.ICON] = HUDNotificationIcon,
	[HUDNotification.CARD_FAIL] = HUDNotificationCardFail
}
HUDNotification.ANIMATION_MOVE_X_DISTANCE = 30
HUDNotification.DEFAULT_DISTANCE_FROM_BOTTOM = 130

function HUDNotification.create(notification_data)
	local notification_type = notification_data.notification_type or HUDNotification.GENERIC
	local notification_class = HUDNotification.TYPES[notification_type]

	return notification_class:new(notification_data)
end

function HUDNotification:init(notification_data)
	self._hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	self._safe_rect_offset = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:x()
	self._font_size = 24
	self._font = tweak_data.gui.fonts.din_compressed_outlined_24
	self._panel_shape_x = 1344
	self._panel_shape_y = 728
	self._panel_shape_h = 84
	self._panel_shape_w = 384
	local padding = 0.2
	self._object = self._hud_panel:panel({
		visible = true,
		x = nil,
		name = "notification_panel",
		layer = 100,
		y = nil,
		h = nil,
		w = nil,
		w = self._panel_shape_w,
		h = self._panel_shape_h,
		x = self._panel_shape_x,
		y = self._panel_shape_y
	})
	self._bg_texture = self._object:bitmap({
		texture = nil,
		y = 0,
		name = "bg_texture",
		w = nil,
		layer = 1,
		texture_rect = nil,
		h = nil,
		x = 0,
		texture = tweak_data.gui.icons.backgrounds_chat_bg.texture,
		texture_rect = tweak_data.gui.icons.backgrounds_chat_bg.texture_rect,
		w = self._panel_shape_w,
		h = self._panel_shape_h
	})

	self._bg_texture:set_y(self._object:h() - self._panel_shape_h)

	local notification_text = notification_data.text

	if notification_data.prompt then
		notification_text = notification_text .. "\n" .. notification_data.prompt
	end

	if notification_data.sound_effect then
		self._sound_effect = notification_data.sound_effect
	end

	self._text = self._object:text({
		halign = "scale",
		wrap = true,
		vertical = "center",
		text = nil,
		align = "center",
		font_size = nil,
		font = nil,
		layer = 2,
		name = "text",
		valign = "scale",
		font = self._font,
		font_size = self._font_size,
		text = notification_text
	})

	self._text:set_x(self._object:h() * padding * 0.5)
	self._text:set_y(self._object:h() * padding * 0.5)
	self._text:set_w(self._object:w() - self._object:h() * padding)
	self._text:set_h(self._object:h() * (1 - padding))

	self._initial_right_x = self._object:right()

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotification:hide()
	self._removed = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotification:cancel_execution()
	if self._object then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_cancel"))
	end
end

function HUDNotification:execute()
	if self._object then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_hide"))
	end
end

function HUDNotification:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)
end

function HUDNotification:update_data(data)
	if data.text and alive(self._text) and not self._removed then
		self._text:set_text(data.text)
	end
end

function HUDNotification:set_progress(progress)
	local scale = 1 - 0.15 * progress

	self._object:stop()
	self._object:set_size(self._panel_shape_w * scale, self._panel_shape_h * scale)
	self._object:set_x(self._panel_shape_x + self._panel_shape_w * (1 - scale) * 0.5)
	self._object:set_y(self._panel_shape_y + self._panel_shape_h * (1 - scale) * 0.5)
	self._text:set_font_size(self._font_size * scale)

	self._progress = progress
end

function HUDNotification:get_progress()
	return self._progress
end

function HUDNotification:set_full_progress()
	self._progress = 1

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_full_progress"))
end

function HUDNotificationCardFail:init(notification_data)
	self._hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	self._hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	self._safe_rect_offset = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:x()
	self._font = tweak_data.gui.fonts.din_compressed_outlined_24
	self._font_size = 24
	self._panel_shape_x = 1344
	self._panel_shape_y = 362
	self._panel_shape_w = 384
	self._panel_shape_h = 432
	local params_root_panel = {
		visible = true,
		x = nil,
		name = "notification_panel",
		is_root_panel = true,
		layer = 100,
		y = nil,
		h = nil,
		w = nil,
		w = self._panel_shape_w,
		h = self._panel_shape_h,
		x = self._panel_shape_x,
		y = self._panel_shape_y
	}
	self._object = RaidGUIPanel:new(self._hud_panel, params_root_panel)
	local padding = 0.1
	self._bg_texture = self._object:bitmap({
		texture = nil,
		name = "bg_texture",
		layer = 1,
		texture_rect = nil,
		h = nil,
		w = nil,
		texture = tweak_data.gui.icons.backgrounds_chat_bg.texture,
		texture_rect = tweak_data.gui.icons.backgrounds_chat_bg.texture_rect,
		w = self._panel_shape_w,
		h = self._panel_shape_h
	})

	self._bg_texture:set_y(self._object:h() - self._bg_texture:h())
	self._bg_texture:set_x(0)

	self._card = tweak_data.challenge_cards:get_card_by_key_name(notification_data.card)
	self._card_name = managers.localization:text(self._card.name)
	self._card_fail_text = managers.localization:text("hud_challenge_card_failed", {
		CARD = nil,
		CARD = string.upper(self._card_name)
	})
	self._card_rarity = managers.challenge_cards:get_active_card()
	self._upper_text = self._object:text({
		halign = "scale",
		wrap = true,
		vertical = "center",
		text = nil,
		align = "right",
		font_size = nil,
		font = nil,
		layer = 2,
		name = "card_fail_text",
		valign = "scale",
		font = self._font,
		font_size = self._font_size,
		text = self._card_fail_text
	})

	self._upper_text:set_x(32)
	self._upper_text:set_h(96)
	self._upper_text:set_y(0)
	self._upper_text:set_w(self._panel_shape_w - 64)

	local card_params = {
		item_h = 248,
		name = "player_card",
		item_w = 184,
		y = 96,
		x = 168
	}
	self._card_control = self._object:create_custom_control(RaidGUIControlCardBase, card_params)

	self._card_control:set_card(self._card)

	local prompt_text = notification_data.prompt
	self._text = self._object:text({
		halign = "scale",
		wrap = true,
		vertical = "center",
		text = nil,
		align = "right",
		font_size = nil,
		font = nil,
		layer = 2,
		name = "text",
		valign = "scale",
		font = self._font,
		font_size = self._font_size,
		text = prompt_text
	})

	self._text:set_x(32)
	self._text:set_y(self._object:h() - 96)
	self._text:set_w(self._object:w() - 64)
	self._text:set_h(96)

	self._initial_right_x = self._object:right()

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotificationCardFail:hide()
	if self._object then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_hide"))
	end
end

function HUDNotificationCardFail:destroy()
	if self._object then
		self._object:stop()
		self._object:close()
		self._object:parent():remove(self._object:get_engine_panel())
	end

	self = nil
end

function HUDNotificationIcon:init()
	Application:error("HUDNotificationIcon has not been implemented yet!")
end

HUDNotificationRaidUnlocked = HUDNotificationRaidUnlocked or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.RAID_UNLOCKED] = HUDNotificationRaidUnlocked
HUDNotificationRaidUnlocked.BOTTOM = 800
HUDNotificationRaidUnlocked.WIDTH = 352
HUDNotificationRaidUnlocked.FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDNotificationRaidUnlocked.FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDNotificationRaidUnlocked.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDNotificationRaidUnlocked.FOLDER_ICON = "folder_mission_hud_notification_raid"
HUDNotificationRaidUnlocked.BACKGROUND_IMAGE = "backgrounds_chat_bg"

function HUDNotificationRaidUnlocked:init(notification_data)
	self:_create_panel()
	self:_create_folder_image()
	self:_create_description()

	self._sound_effect = "selected_new_raid"
	self._sound_delay = 0.4

	self:_fit_size()

	self._initial_right_x = self._object:right()

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotificationRaidUnlocked:hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotificationRaidUnlocked:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)

	self = nil
end

function HUDNotificationRaidUnlocked:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		name = "notification_raid_unlocked",
		w = nil,
		w = HUDNotificationRaidUnlocked.WIDTH
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()
	local background_params = {
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[HUDNotificationRaidUnlocked.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationRaidUnlocked.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationRaidUnlocked:_create_folder_image()
	local folder_image_params = {
		texture = nil,
		texture_rect = nil,
		name = "notification_raid_unlocked_folder_image",
		layer = 3,
		texture = tweak_data.gui.icons[HUDNotificationRaidUnlocked.FOLDER_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationRaidUnlocked.FOLDER_ICON].texture_rect
	}
	self._folder_image = self._object:bitmap(folder_image_params)

	self._folder_image:set_right(self._object:w() - 32)
end

function HUDNotificationRaidUnlocked:_create_description()
	local is_at_last_step = managers.progression:mission_progression_completion_pending()
	local description_text = is_at_last_step and "raid_final_unlocked_title" or "raid_next_unlocked_title"
	local description_params = {
		text = nil,
		wrap = true,
		vertical = "center",
		layer = 3,
		align = "right",
		font_size = nil,
		font = nil,
		w = nil,
		name = "notification_raid_unlocked_description",
		color = nil,
		font = HUDNotificationRaidUnlocked.FONT,
		font_size = HUDNotificationRaidUnlocked.FONT_SIZE,
		w = self._object:w() - 64,
		color = HUDNotificationRaidUnlocked.DESCRIPTION_COLOR,
		text = utf8.to_upper(managers.localization:text(description_text))
	}
	self._description = self._object:text(description_params)
	local _, _, _, h = self._description:text_rect()

	self._description:set_h(h)
	self._description:set_right(self._object:w() - 32)
end

function HUDNotificationRaidUnlocked:_fit_size()
	local top_padding = 32
	local middle_padding = 32
	local bottom_padding = 32
	local notification_h = top_padding + self._folder_image:h() + middle_padding + self._description:h() + bottom_padding

	self._object:set_h(notification_h)
	self._folder_image:set_y(top_padding)
	self._description:set_bottom(self._object:h() - bottom_padding)
	self._object:set_bottom(HUDNotificationRaidUnlocked.BOTTOM)
end

HUDNotificationConsumablePickup = HUDNotificationConsumablePickup or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.CONSUMABLE_MISSION_PICKED_UP] = HUDNotificationConsumablePickup
HUDNotificationConsumablePickup.BOTTOM = 800
HUDNotificationConsumablePickup.WIDTH = 352
HUDNotificationConsumablePickup.FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDNotificationConsumablePickup.FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDNotificationConsumablePickup.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDNotificationConsumablePickup.BACKGROUND_IMAGE = "backgrounds_chat_bg"

function HUDNotificationConsumablePickup:init(notification_data)
	self._doc_icon = notification_data.doc_icon or "notification_consumable"
	self._doc_text = notification_data.doc_text or "hud_hint_consumable_mission_secured"

	self:_create_panel()
	self:_create_document_image()
	self:_create_description()

	self._sound_effect = "selected_new_raid"
	self._sound_delay = 0.4

	self:_fit_size()

	self._initial_right_x = self._object:right()

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotificationConsumablePickup:hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotificationConsumablePickup:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)

	self = nil
end

function HUDNotificationConsumablePickup:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		name = "notification_outlaw_raid_unlocked",
		w = nil,
		w = HUDNotificationConsumablePickup.WIDTH
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()
	local background_params = {
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[HUDNotificationConsumablePickup.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationConsumablePickup.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationConsumablePickup:_create_document_image()
	local folder_image_params = {
		texture = nil,
		texture_rect = nil,
		name = "notification_outlaw_raid_unlocked_document_image",
		layer = 3,
		texture = tweak_data.gui.icons[self._doc_icon].texture,
		texture_rect = tweak_data.gui.icons[self._doc_icon].texture_rect
	}
	self._folder_image = self._object:bitmap(folder_image_params)

	self._folder_image:set_center_x(self._object:w() / 2)
end

function HUDNotificationConsumablePickup:_create_description()
	local description_params = {
		text = nil,
		wrap = true,
		vertical = "center",
		layer = 3,
		align = "center",
		font_size = nil,
		font = nil,
		w = nil,
		name = "notification_outlaw_raid_unlocked_description",
		color = nil,
		font = HUDNotificationConsumablePickup.FONT,
		font_size = HUDNotificationConsumablePickup.FONT_SIZE,
		w = self._object:w() - 64,
		color = HUDNotificationConsumablePickup.DESCRIPTION_COLOR,
		text = utf8.to_upper(managers.localization:text(self._doc_text))
	}
	self._description = self._object:text(description_params)
	local _, _, _, h = self._description:text_rect()

	self._description:set_h(h)
	self._description:set_center_x(self._object:w() / 2)
end

function HUDNotificationConsumablePickup:_fit_size()
	local top_padding = 32
	local middle_padding = 32
	local bottom_padding = 32
	local notification_h = top_padding + self._folder_image:h() + middle_padding + self._description:h() + bottom_padding

	self._object:set_h(notification_h)
	self._folder_image:set_y(top_padding)
	self._description:set_bottom(self._object:h() - bottom_padding)
	self._object:set_bottom(HUDNotificationConsumablePickup.BOTTOM)
end

HUDNotificationGreedItem = HUDNotificationGreedItem or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.GREED_ITEM] = HUDNotificationGreedItem
HUDNotificationGreedItem.BOTTOM = 830
HUDNotificationGreedItem.WIDTH = 352
HUDNotificationGreedItem.HEIGHT = 160
HUDNotificationGreedItem.BACKGROUND_IMAGE = "backgrounds_chat_bg"
HUDNotificationGreedItem.FRAME_ICON = "rewards_extra_loot_frame"
HUDNotificationGreedItem.FILL_ICON = "rewards_extra_loot_fill"
HUDNotificationGreedItem.LOOT_ICON = "rewards_extra_loot_middle_loot"
HUDNotificationGreedItem.GOLD_ICON = "rewards_extra_loot_middle_gold"
HUDNotificationGreedItem.TITLE_STRING = "menu_save_info_loot_title"
HUDNotificationGreedItem.GOLD_ACQUIRED_STRING = "hud_greed_gold_bar_acquired"
HUDNotificationGreedItem.ITEMS_MAX = 6
HUDNotificationGreedItem.ITEMS_HEIGHT = 40
HUDNotificationGreedItem.ITEMS_MARGIN = 5
HUDNotificationGreedItem.ITEMS_PADDING = 30
HUDNotificationGreedItem.ICON_HIDDEN_OFFSET = 40

function HUDNotificationGreedItem:init(notification_data)
	self:_create_panel()
	self:_create_icons()
	self:_create_right_panel()
	self:_create_items_panel()
	self:_create_title()

	self._initial_progress = notification_data.initial_progress
	self._current_progress = notification_data.initial_progress
	self._updated_progress = notification_data.new_progress

	self:_set_progress(self._initial_progress % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar())
	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
	self._items = {}
	self._progress_queue = {
		notification_data
	}

	managers.queued_tasks:queue("greed_notification_animate", self.animate_progress_change, self, nil, 0.5, nil, false)

	if notification_data.item then
		self:_create_item(notification_data.item)
	end
end

function HUDNotificationGreedItem:hide()
	self._gold_icon:stop()
	self._icons_panel:stop()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotificationGreedItem:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)
	self._items_panel:parent():remove(self._items_panel)

	self._items = {}
	self = nil
end

function HUDNotificationGreedItem:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		h = nil,
		name = "notification_greed_item_picked_up",
		w = nil,
		w = HUDNotificationGreedItem.WIDTH,
		h = HUDNotificationGreedItem.HEIGHT
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()

	self._object:set_bottom(HUDNotificationGreedItem.BOTTOM)

	local background_params = {
		texture = nil,
		texture_rect = nil,
		halign = "scale",
		valign = "scale",
		y = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h() / 2,
		y = self._object:h() / 4,
		texture = tweak_data.gui.icons[HUDNotificationGreedItem.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationGreedItem.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationGreedItem:_create_icons()
	local icons_panel_params = {
		halign = "left",
		valign = "scale",
		name = "icons_panel",
		h = nil,
		w = 160,
		h = self._object:h()
	}
	self._icons_panel = self._object:panel(icons_panel_params)
	local frame_icon_params = {
		texture = nil,
		halign = "center",
		name = "frame_icon",
		layer = 10,
		texture_rect = nil,
		valign = "center",
		texture = tweak_data.gui.icons[HUDNotificationGreedItem.FRAME_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationGreedItem.FRAME_ICON].texture_rect
	}
	self._frame_icon = self._icons_panel:bitmap(frame_icon_params)

	self._frame_icon:set_center_x(self._icons_panel:w() / 2)
	self._frame_icon:set_center_y(self._icons_panel:h() / 2)

	local frame_fill_params = {
		halign = "center",
		render_template = "VertexColorTexturedRadial",
		texture = nil,
		position_z = 0.76,
		layer = 5,
		name = "frame_fill",
		color = nil,
		texture_rect = nil,
		valign = "center",
		texture = tweak_data.gui.icons[HUDNotificationGreedItem.FILL_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationGreedItem.FILL_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_gold
	}
	self._frame_fill = self._icons_panel:bitmap(frame_fill_params)

	self._frame_fill:set_center_x(self._icons_panel:w() / 2)
	self._frame_fill:set_center_y(self._icons_panel:h() / 2)

	local loot_icon_params = {
		texture = nil,
		halign = "center",
		name = "loot_icon",
		layer = 10,
		texture_rect = nil,
		valign = "center",
		texture = tweak_data.gui.icons[HUDNotificationGreedItem.LOOT_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationGreedItem.LOOT_ICON].texture_rect
	}
	self._loot_icon = self._icons_panel:bitmap(loot_icon_params)

	self._loot_icon:set_center_x(self._icons_panel:w() / 2)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)

	local gold_icon_params = {
		texture = nil,
		halign = "center",
		name = "gold_icon",
		alpha = 0,
		layer = 10,
		texture_rect = nil,
		valign = "center",
		color = nil,
		texture = tweak_data.gui.icons[HUDNotificationGreedItem.GOLD_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationGreedItem.GOLD_ICON].texture_rect,
		color = tweak_data.gui.colors.raid_gold
	}
	self._gold_icon = self._icons_panel:bitmap(gold_icon_params)

	self._gold_icon:set_center_x(self._icons_panel:w() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
end

function HUDNotificationGreedItem:_create_right_panel()
	local right_panel_params = {
		h = 96,
		is_root_panel = true,
		name = "right_panel",
		x = nil,
		x = self._icons_panel:x() + self._icons_panel:w() - 10
	}
	self._right_panel = RaidGUIPanel:new(self._object, right_panel_params)

	self._right_panel:set_w(self._object:w() - self._right_panel:x() - 32)
	self._right_panel:set_center_y(self._object:h() / 2)
end

function HUDNotificationGreedItem:_create_title()
	self._title = self._right_panel:text({
		halign = "left",
		h = 64,
		vertical = "center",
		text = nil,
		align = "left",
		font_size = nil,
		font = nil,
		w = 90,
		name = "greed_item_notification_title",
		color = nil,
		valign = "center",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_56),
		font_size = tweak_data.gui.font_sizes.size_56,
		text = managers.localization:to_upper_text(HUDNotificationGreedItem.TITLE_STRING),
		color = tweak_data.gui.colors.raid_dirty_white
	})

	self._title:set_center_y(self._right_panel:h() / 2)

	local _, _, w = self._title:text_rect()

	if self._title:w() < w then
		self._title:set_font_size(tweak_data.gui.font_sizes.size_56 * self._title:w() / w)
	end

	local progress_amount_text_params = {
		halign = "left",
		h = 64,
		vertical = "center",
		text = nil,
		align = "right",
		font_size = nil,
		font = nil,
		name = "greed_item_notification_amount_progress",
		color = nil,
		valign = "center",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_56),
		font_size = tweak_data.gui.font_sizes.size_46,
		color = tweak_data.gui.colors.raid_gold,
		text = utf8.to_upper(managers.localization:text(HUDNotificationGreedItem.GOLD_ACQUIRED_STRING))
	}
	self._gold_progress = self._right_panel:text(progress_amount_text_params)

	self._gold_progress:set_center_y(self._right_panel:h() / 2)

	local title_params = {
		halign = "left",
		wrap = true,
		vertical = "center",
		w = nil,
		align = "center",
		y = 0,
		h = nil,
		x = 0,
		font_size = nil,
		font = nil,
		name = "greed_item_notification_gold_acquired",
		text = nil,
		color = nil,
		alpha = 0,
		valign = "center",
		h = self._right_panel:h(),
		w = self._right_panel:w(),
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_56),
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_gold,
		text = utf8.to_upper(managers.localization:text(HUDNotificationGreedItem.GOLD_ACQUIRED_STRING))
	}
	self._gold_acquired = self._right_panel:text(title_params)
end

function HUDNotificationGreedItem:_create_items_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	self._items_panel = hud.panel:panel({
		h = nil,
		name = "notification_greed_item_secured",
		w = nil,
		w = HUDNotificationGreedItem.WIDTH,
		h = (HUDNotificationGreedItem.ITEMS_HEIGHT + HUDNotificationGreedItem.ITEMS_MARGIN) * HUDNotificationGreedItem.ITEMS_MAX
	})

	self._items_panel:set_right(hud.panel:w())
	self._items_panel:set_bottom(self._object:top() + HUDNotificationGreedItem.ITEMS_HEIGHT / 2)
end

function HUDNotificationGreedItem:_create_item(data)
	local item_panel = self._items_panel:panel({
		h = nil,
		name = "notification_greed_item_pickup",
		w = nil,
		w = HUDNotificationGreedItem.WIDTH,
		h = HUDNotificationGreedItem.ITEMS_HEIGHT
	})

	item_panel:set_right(self._items_panel:w())
	item_panel:set_bottom(self._items_panel:h() - #self._items * (HUDNotificationGreedItem.ITEMS_HEIGHT + HUDNotificationGreedItem.ITEMS_MARGIN))

	local icon_data = tweak_data.gui:get_full_gui_data(HUDNotificationGreedItem.BACKGROUND_IMAGE)
	local background = item_panel:bitmap({
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = item_panel:w(),
		h = item_panel:h(),
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect
	})
	icon_data = tweak_data.gui:get_full_gui_data(data.icon)
	local loot_icon = item_panel:bitmap({
		halign = "center",
		w = nil,
		texture = nil,
		layer = nil,
		h = nil,
		x = nil,
		name = "loot_icon",
		texture_rect = nil,
		valign = "center",
		x = HUDNotificationGreedItem.ITEMS_PADDING,
		w = item_panel:h(),
		h = item_panel:h(),
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect,
		layer = background:layer() + 1
	})
	local loot_title = item_panel:text({
		halign = "left",
		h = nil,
		vertical = "center",
		text = nil,
		align = "left",
		font_size = nil,
		font = nil,
		layer = nil,
		name = "loot_title",
		color = nil,
		valign = "center",
		h = item_panel:h(),
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.small),
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white,
		text = utf8.to_upper(managers.localization:text(data.name_id)),
		layer = background:layer() + 1
	})

	loot_title:set_x(loot_icon:right() + 4)

	local value_label = item_panel:text({
		halign = "left",
		h = nil,
		vertical = "center",
		text = nil,
		align = "right",
		font_size = nil,
		font = nil,
		layer = nil,
		name = "value_label",
		color = nil,
		valign = "center",
		h = item_panel:h(),
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.small),
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_gold,
		text = "+" .. tostring(data.value) .. "g",
		layer = background:layer() + 1
	})
	local w = select(3, value_label:text_rect())

	value_label:set_w(w)
	value_label:set_right(item_panel:w() - HUDNotificationGreedItem.ITEMS_PADDING)

	local col = tweak_data.gui.colors.raid_white
	local attention_grabber = self._items_panel:gradient({
		halign = "center",
		h = nil,
		name = "attention_grabber",
		orientation = "horizontal",
		layer = nil,
		valign = "center",
		w = nil,
		w = item_panel:w() / 2,
		h = item_panel:h(),
		layer = background:layer() + 5
	})

	attention_grabber:set_world_right(item_panel:world_x())
	attention_grabber:set_world_y(item_panel:world_y())
	attention_grabber:set_gradient_points({
		0,
		col:with_alpha(0),
		0.3,
		col:with_alpha(1),
		0.7,
		col:with_alpha(1),
		1,
		col:with_alpha(0)
	})
	table.insert(self._items, item_panel)
	item_panel:stop()
	item_panel:animate(callback(self, self, "_animate_show_item", attention_grabber))
end

function HUDNotificationGreedItem:_set_progress(progress)
	local grams = math.ceil(progress * tweak_data.greed.item_value.complete_gold_bar)

	self._gold_progress:set_text(tostring(grams) .. "g")
	self._frame_fill:set_position_z(progress)
end

function HUDNotificationGreedItem:update_data(data)
	table.insert(self._progress_queue, data)
	self:_check_item_queued()

	if not self._animating_progress_change then
		self:animate_progress_change()

		if self._removed and alive(self._object) then
			self._object:stop()
			self._object:animate(callback(self, self, "_animate_reshow"))

			self._removed = false
		end
	end
end

function HUDNotificationGreedItem:animate_progress_change()
	if alive(self._gold_icon) then
		self._gold_icon:stop()
		self._gold_icon:animate(callback(self, self, "_animate_progress_change"))
	end
end

function HUDNotificationGreedItem:_animate_progress_change(o)
	self._animating_progress_change = true
	local t = 0

	while #self._progress_queue > 0 do
		self._updated_progress = self._progress_queue[1].new_progress
		local points_per_second = self._updated_progress - self._current_progress

		while self._updated_progress - self._current_progress > 0 do
			local dt = coroutine.yield()
			t = t + dt
			self._current_progress = self._current_progress + points_per_second * dt
			local current_percentage = self._current_progress % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar()

			self:_set_progress(current_percentage)

			if self._previous_percentage and current_percentage < self._previous_percentage then
				self._icons_panel:stop()
				self._icons_panel:animate(callback(self, self, "_animate_gold_bar"))
				managers.hud:post_event("greed_item_picked_up")
			end

			self._previous_percentage = current_percentage
		end

		local current_percentage = self._updated_progress % managers.greed:loot_needed_for_gold_bar() / managers.greed:loot_needed_for_gold_bar()

		self:_set_progress(current_percentage)

		local duration = 0.3
		t = 0

		while duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_offset = Easing.quartic_in_out(t, -20, 20, duration)

			self._gold_progress:set_center_y(self._title:center_y() + current_offset)

			local current_r = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.r, tweak_data.gui.colors.raid_gold.r - tweak_data.gui.colors.raid_light_gold.r, duration)
			local current_g = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.g, tweak_data.gui.colors.raid_gold.g - tweak_data.gui.colors.raid_light_gold.g, duration)
			local current_b = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.b, tweak_data.gui.colors.raid_gold.b - tweak_data.gui.colors.raid_light_gold.b, duration)

			self._gold_progress:set_color(Color(current_r, current_g, current_b))
		end

		wait(0.5)

		if #self._items > 0 then
			self._items_panel:stop()
			self._items_panel:animate(callback(self, self, "_animate_cycle_items", self._items[1]))
			table.remove(self._items, 1)
			wait(0.2)
		end

		table.remove(self._progress_queue, 1)
	end

	self._animating_progress_change = false

	wait(2)
	self:_check_hide()
end

function HUDNotificationGreedItem:_animate_gold_bar(o)
	self._animating_gold_bar = true
	local frame_default_w = tweak_data.gui:icon_w(HUDNotificationGreedItem.FRAME_ICON)
	local frame_default_h = tweak_data.gui:icon_h(HUDNotificationGreedItem.FRAME_ICON)
	local duration_in = 0.5
	local t = 0

	while duration_in > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_frame_scale = Easing.quartic_out(t, 1.4, -0.4, duration_in)

		self._frame_icon:set_w(frame_default_w * current_frame_scale)
		self._frame_icon:set_h(frame_default_h * current_frame_scale)
		self._frame_icon:set_center_x(self._icons_panel:w() / 2)
		self._frame_icon:set_center_y(self._icons_panel:h() / 2)
		self._frame_fill:set_w(frame_default_w * current_frame_scale)
		self._frame_fill:set_h(frame_default_h * current_frame_scale)
		self._frame_fill:set_center_x(self._icons_panel:w() / 2)
		self._frame_fill:set_center_y(self._icons_panel:h() / 2)

		local current_r = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.r, tweak_data.gui.colors.raid_gold.r - tweak_data.gui.colors.raid_light_gold.r, duration_in)
		local current_g = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.g, tweak_data.gui.colors.raid_gold.g - tweak_data.gui.colors.raid_light_gold.g, duration_in)
		local current_b = Easing.quartic_out(t, tweak_data.gui.colors.raid_light_gold.b, tweak_data.gui.colors.raid_gold.b - tweak_data.gui.colors.raid_light_gold.b, duration_in)

		self._frame_icon:set_color(Color(current_r, current_g, current_b))

		local current_offset = Easing.quartic_in_out(t, 0, HUDNotificationGreedItem.ICON_HIDDEN_OFFSET, duration_in)
		local current_loot_icon_alpha = Easing.quartic_in_out(t, 1, -1, duration_in / 2)

		self._loot_icon:set_alpha(current_loot_icon_alpha)
		self._loot_icon:set_center_y(self._icons_panel:h() / 2 - current_offset)
		self._frame_fill:set_alpha(current_loot_icon_alpha)

		if t >= duration_in / 2 then
			local current_gold_icon_alpha = Easing.quartic_in_out(t - duration_in / 2, 0, 1, duration_in / 2)

			self._gold_icon:set_alpha(current_gold_icon_alpha)
		end

		self._gold_icon:set_center_y(self._icons_panel:h() / 2 + HUDNotificationGreedItem.ICON_HIDDEN_OFFSET - current_offset)
	end

	self._frame_icon:set_color(tweak_data.gui.colors.raid_gold)
	self._frame_icon:set_w(frame_default_w)
	self._frame_icon:set_h(frame_default_h)
	self._frame_fill:set_w(frame_default_w)
	self._frame_fill:set_h(frame_default_h)
	self._loot_icon:set_alpha(0)
	self._gold_icon:set_alpha(1)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
	self._frame_icon:set_center_x(self._icons_panel:w() / 2)
	self._frame_icon:set_center_y(self._icons_panel:h() / 2)
	self._frame_fill:set_center_x(self._icons_panel:w() / 2)
	self._frame_fill:set_center_y(self._icons_panel:h() / 2)
	wait(1)

	local duration_out = 0.7
	t = 0

	while duration_out > t do
		local dt = coroutine.yield()
		t = t + dt

		self._frame_icon:set_center_x(self._icons_panel:w() / 2)
		self._frame_icon:set_center_y(self._icons_panel:h() / 2)
		self._frame_fill:set_center_x(self._icons_panel:w() / 2)
		self._frame_fill:set_center_y(self._icons_panel:h() / 2)

		local current_r = Easing.quartic_out(t, tweak_data.gui.colors.raid_gold.r, 1 - tweak_data.gui.colors.raid_gold.r, duration_in)
		local current_g = Easing.quartic_out(t, tweak_data.gui.colors.raid_gold.g, 1 - tweak_data.gui.colors.raid_gold.g, duration_in)
		local current_b = Easing.quartic_out(t, tweak_data.gui.colors.raid_gold.b, 1 - tweak_data.gui.colors.raid_gold.b, duration_in)

		self._frame_icon:set_color(Color(current_r, current_g, current_b))

		local current_offset = Easing.quartic_in_out(t, 0, HUDNotificationGreedItem.ICON_HIDDEN_OFFSET, duration_in)
		local current_gold_icon_alpha = Easing.quartic_in_out(t, 1, -1, duration_in / 2)

		self._gold_icon:set_alpha(current_gold_icon_alpha)
		self._gold_icon:set_center_y(self._icons_panel:h() / 2 - current_offset)

		if t >= duration_in / 2 then
			local current_loot_icon_alpha = Easing.quartic_in_out(t - duration_in / 2, 0, 1, duration_in / 2)

			self._loot_icon:set_alpha(current_loot_icon_alpha)
			self._frame_fill:set_alpha(current_loot_icon_alpha)
		end

		self._loot_icon:set_center_y(self._icons_panel:h() / 2 + HUDNotificationGreedItem.ICON_HIDDEN_OFFSET - current_offset)
	end

	self._frame_icon:set_color(Color.white)
	self._frame_icon:set_center_x(self._icons_panel:w() / 2)
	self._frame_icon:set_center_y(self._icons_panel:h() / 2)
	self._frame_fill:set_center_x(self._icons_panel:w() / 2)
	self._frame_fill:set_center_y(self._icons_panel:h() / 2)
	self._loot_icon:set_alpha(1)
	self._gold_icon:set_alpha(0)
	self._loot_icon:set_center_y(self._icons_panel:h() / 2)
	self._gold_icon:set_center_y(self._icons_panel:h() / 2)
	wait(0.8)

	self._animating_gold_bar = false

	self:_check_hide()
end

function HUDNotificationGreedItem:_animate_show_item(attention, panel)
	panel:set_alpha(0)

	local panel_right = panel:parent():w()
	local attention_right = attention:parent():w() + attention:w()
	local duration = 0.35
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quadratic_in(t, 0, 1, duration)

		panel:set_alpha(curr_alpha)

		local current_x_offset = -(1 - curr_alpha) * HUDNotification.ANIMATION_MOVE_X_DISTANCE

		panel:set_right(panel_right + current_x_offset)
		attention:set_right(attention_right * curr_alpha)
		attention:set_world_y(panel:world_y())
	end

	panel:set_alpha(1)
	panel:set_right(panel_right)
	attention:parent():remove(attention)
end

function HUDNotificationGreedItem:_animate_cycle_items(first_item, panel)
	local h = HUDNotificationGreedItem.ITEMS_HEIGHT + HUDNotificationGreedItem.ITEMS_MARGIN
	local duration = 0.2
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quadratic_in(t, 1, -1, duration)

		first_item:set_alpha(curr_alpha)

		for i = 1, #self._items do
			local curr_y = Easing.quadratic_in(t, i * h, -h, duration)

			self._items[i]:set_bottom(panel:h() - curr_y)
		end
	end

	panel:remove(first_item)
	self:_check_item_queued()
end

function HUDNotificationGreedItem:_check_item_queued()
	if #self._items < HUDNotificationGreedItem.ITEMS_MAX and alive(self._items_panel) then
		local data = self._progress_queue[#self._items + 1]

		if data and data.item then
			self:_create_item(data.item)
		end
	end
end

function HUDNotificationGreedItem:_check_hide()
	if not self._animating_progress_change and not self._animating_gold_bar then
		self._removed = true

		managers.notification:hide_current_notification()
	end
end

HUDNotificationDogTag = HUDNotificationDogTag or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.DOG_TAG] = HUDNotificationDogTag
HUDNotificationDogTag.BOTTOM = 800
HUDNotificationDogTag.WIDTH = 550
HUDNotificationDogTag.HEIGHT = 160
HUDNotificationDogTag.BACKGROUND_IMAGE = "backgrounds_chat_bg"
HUDNotificationDogTag.DOG_TAG_ICON = "rewards_dog_tags"
HUDNotificationDogTag.TITLE_STRING = "hud_dog_tags"

function HUDNotificationDogTag:init(notification_data)
	self:_create_panel()
	self:_create_icon()
	self:_create_right_panel()
	self:_create_progress()
	self:_create_title()
	self:_set_progress(notification_data.acquired, notification_data.total)
	self._object:animate(callback(self, self, "_animate_show"))
end

function HUDNotificationDogTag:hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotificationDogTag:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)

	self = nil
end

function HUDNotificationDogTag:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		h = nil,
		name = "notification_dog_tag_picked_up",
		w = nil,
		w = HUDNotificationDogTag.WIDTH,
		h = HUDNotificationDogTag.HEIGHT
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()

	self._object:set_bottom(HUDNotificationDogTag.BOTTOM)

	local background_params = {
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[HUDNotificationDogTag.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationDogTag.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationDogTag:_create_icon()
	local icon_panel_params = {
		halign = "left",
		w = 160,
		name = "icon_panel",
		valign = "scale",
		h = nil,
		x = 32,
		h = self._object:h()
	}
	self._icon_panel = self._object:panel(icon_panel_params)
	local dog_tag_icon_params = {
		texture = nil,
		halign = "center",
		name = "dog_tag_icon",
		layer = 10,
		texture_rect = nil,
		valign = "center",
		texture = tweak_data.gui.icons[HUDNotificationDogTag.DOG_TAG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationDogTag.DOG_TAG_ICON].texture_rect
	}
	self._dog_tag_icon = self._icon_panel:bitmap(dog_tag_icon_params)

	self._dog_tag_icon:set_center_x(self._icon_panel:w() / 2)
	self._dog_tag_icon:set_center_y(self._icon_panel:h() / 2)
end

function HUDNotificationDogTag:_create_right_panel()
	local right_panel_params = {
		h = 96,
		is_root_panel = true,
		name = "right_panel",
		x = nil,
		x = self._icon_panel:x() + self._icon_panel:w() - 16
	}
	self._right_panel = RaidGUIPanel:new(self._object, right_panel_params)

	self._right_panel:set_w(self._object:w() - self._right_panel:x() - 16)
	self._right_panel:set_center_y(self._object:h() / 2)
end

function HUDNotificationDogTag:_create_title()
	local title_params = {
		halign = "left",
		h = 64,
		vertical = "center",
		text = nil,
		align = "center",
		font_size = nil,
		font = nil,
		name = "dog_tag_notification_title",
		color = nil,
		valign = "center",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_grey_effects,
		text = utf8.to_upper(managers.localization:text(HUDNotificationDogTag.TITLE_STRING))
	}
	self._title = self._right_panel:text(title_params)

	self._title:set_center_y(80)
end

function HUDNotificationDogTag:_create_progress()
	local progress_text_params = {
		halign = "left",
		wrap = true,
		vertical = "center",
		h = 64,
		align = "center",
		font_size = nil,
		font = nil,
		text = "",
		name = "dog_tag_notification_progress_text",
		color = nil,
		valign = "center",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_56),
		font_size = tweak_data.gui.font_sizes.size_56,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._progress_text = self._right_panel:text(progress_text_params)

	self._progress_text:set_center_x(self._right_panel:w() / 2)
	self._progress_text:set_center_y(32)
end

function HUDNotificationDogTag:_set_progress(acquired, total)
	if alive(self._progress_text) then
		self._progress_text:set_text(tostring(acquired) .. " / " .. tostring(total))
	end
end

function HUDNotificationDogTag:update_data(data)
	self:_set_progress(data.acquired, data.total)

	if alive(self._object) then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_reshow"))
	else
		Application:error("[HUDNotificationDogTag:update_data] Tried stopping on a dead notification.")
	end
end

HUDNotificationWeaponChallenge = HUDNotificationWeaponChallenge or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.WEAPON_CHALLENGE] = HUDNotificationWeaponChallenge
HUDNotificationWeaponChallenge.Y = 544
HUDNotificationWeaponChallenge.WIDTH = 384
HUDNotificationWeaponChallenge.HEIGHT = 224
HUDNotificationWeaponChallenge.BACKGROUND_IMAGE = "backgrounds_chat_bg"
HUDNotificationWeaponChallenge.RIGHT_SIDE_X = 64
HUDNotificationWeaponChallenge.PADDING_RIGHT = 32
HUDNotificationWeaponChallenge.TITLE_Y = 28
HUDNotificationWeaponChallenge.TITLE_H = 32
HUDNotificationWeaponChallenge.TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDNotificationWeaponChallenge.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDNotificationWeaponChallenge.TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDNotificationWeaponChallenge.TITLE_DISTANCE_FROM_DESCRIPTION = 12
HUDNotificationWeaponChallenge.DESCRIPTION_Y = 80
HUDNotificationWeaponChallenge.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
HUDNotificationWeaponChallenge.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDNotificationWeaponChallenge.DESCRIPTION_COLOR = Color("b8b8b8")
HUDNotificationWeaponChallenge.DESCRIPTION_DISTANCE_FROM_PROGRESS_BAR = 23
HUDNotificationWeaponChallenge.PROGRESS_BAR_DISTANCE_FROM_BOTTOM = 32

function HUDNotificationWeaponChallenge:init(notification_data)
	self:_create_panel()
	self:_create_title()
	self:_create_tier_label()
	self:_create_icon()
	self:_create_description()
	self:_create_progress_bar()

	if notification_data.challenge then
		self:_set_challenge(notification_data.challenge)
	end

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotificationWeaponChallenge:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		name = "notification_weapon_challenge",
		y = nil,
		h = nil,
		w = nil,
		y = HUDNotificationWeaponChallenge.Y,
		w = HUDNotificationWeaponChallenge.WIDTH,
		h = HUDNotificationWeaponChallenge.HEIGHT
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()
	local background_params = {
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[HUDNotificationWeaponChallenge.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationWeaponChallenge.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationWeaponChallenge:_create_title()
	local title_params = {
		font_size = nil,
		font = nil,
		vertical = "center",
		w = nil,
		align = "left",
		y = nil,
		h = nil,
		x = nil,
		text = "INCREASE ACCURACY",
		layer = 3,
		name = "notification_weapon_challenge_title",
		color = nil,
		x = HUDNotificationWeaponChallenge.RIGHT_SIDE_X,
		y = HUDNotificationWeaponChallenge.TITLE_Y,
		w = self._object:w() - HUDNotificationWeaponChallenge.RIGHT_SIDE_X,
		h = HUDNotificationWeaponChallenge.TITLE_H,
		font = tweak_data.gui:get_font_path(HUDNotificationWeaponChallenge.TITLE_FONT, HUDNotificationWeaponChallenge.TITLE_FONT_SIZE),
		font_size = HUDNotificationWeaponChallenge.TITLE_FONT_SIZE,
		color = HUDNotificationWeaponChallenge.TITLE_COLOR
	}
	self._title = self._object:text(title_params)
end

function HUDNotificationWeaponChallenge:_create_tier_label()
	local tier_label_params = {
		font_size = nil,
		h = nil,
		vertical = "center",
		text = "TI",
		align = "left",
		y = nil,
		font = nil,
		layer = 3,
		name = "weapon_challenge_tier",
		color = nil,
		h = HUDNotificationWeaponChallenge.TITLE_H,
		y = HUDNotificationWeaponChallenge.TITLE_Y,
		font = tweak_data.gui:get_font_path(HUDNotificationWeaponChallenge.TITLE_FONT, HUDNotificationWeaponChallenge.TITLE_FONT_SIZE),
		font_size = HUDNotificationWeaponChallenge.TITLE_FONT_SIZE,
		color = HUDNotificationWeaponChallenge.TITLE_COLOR
	}
	self._tier = self._object:text(tier_label_params)
end

function HUDNotificationWeaponChallenge:_create_icon()
	local default_icon = "wpn_skill_accuracy"
	local icon_params = {
		texture = nil,
		y = nil,
		name = "weapon_challenge_icon",
		layer = 3,
		texture_rect = nil,
		y = HUDNotificationWeaponChallenge.DESCRIPTION_Y,
		texture = tweak_data.gui.icons[default_icon].texture,
		texture_rect = tweak_data.gui.icons[default_icon].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)
end

function HUDNotificationWeaponChallenge:_create_description()
	local description_params = {
		name = "weapon_challenge_description",
		wrap = true,
		w = nil,
		font_size = nil,
		layer = 3,
		y = nil,
		font = nil,
		x = nil,
		text = "You have see too much.",
		color = nil,
		x = HUDNotificationWeaponChallenge.RIGHT_SIDE_X,
		y = HUDNotificationWeaponChallenge.DESCRIPTION_Y,
		w = self._object:w() - HUDNotificationWeaponChallenge.RIGHT_SIDE_X - HUDNotificationWeaponChallenge.PADDING_RIGHT,
		font = tweak_data.gui:get_font_path(HUDNotificationWeaponChallenge.DESCRIPTION_FONT, HUDNotificationWeaponChallenge.DESCRIPTION_FONT_SIZE),
		font_size = HUDNotificationWeaponChallenge.DESCRIPTION_FONT_SIZE,
		color = HUDNotificationWeaponChallenge.DESCRIPTION_COLOR
	}
	self._description = self._object:text(description_params)
end

function HUDNotificationWeaponChallenge:_create_progress_bar()
	local texture_center = "slider_large_center"
	local texture_left = "slider_large_left"
	local texture_right = "slider_large_right"
	local progress_bar_panel_params = {
		w = nil,
		vertical = "bottom",
		name = "weapon_challenge_progress_bar_panel",
		is_root_panel = true,
		layer = 3,
		h = nil,
		x = 0,
		w = self._object:w(),
		h = tweak_data.gui:icon_h(texture_center)
	}
	self._progress_bar_panel = RaidGUIPanel:new(self._object, progress_bar_panel_params)

	self._progress_bar_panel:set_bottom(self._object:h() - HUDNotificationWeaponChallenge.PROGRESS_BAR_DISTANCE_FROM_BOTTOM)

	local progress_bar_background_params = {
		center = nil,
		right = nil,
		name = "weapon_challenge_progress_bar_background",
		left = nil,
		color = nil,
		layer = 1,
		h = nil,
		w = nil,
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = Color.white:with_alpha(0.5)
	}
	local progress_bar_background = self._progress_bar_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_foreground_panel_params = {
		halign = "scale",
		w = nil,
		name = "weapon_challenge_progress_bar_foreground_panel",
		valign = "scale",
		layer = 2,
		y = 0,
		h = nil,
		x = 0,
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h()
	}
	self._progress_bar_foreground_panel = self._progress_bar_panel:panel(progress_bar_foreground_panel_params)
	local progress_bar_background_params = {
		center = nil,
		right = nil,
		name = "weapon_challenge_progress_bar_background",
		left = nil,
		color = nil,
		h = nil,
		w = nil,
		w = self._progress_bar_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = tweak_data.gui.colors.raid_red
	}
	local progress_bar_background = self._progress_bar_foreground_panel:three_cut_bitmap(progress_bar_background_params)
	local progress_bar_text_params = {
		font_size = nil,
		font = nil,
		vertical = "center",
		w = nil,
		align = "center",
		y = -2,
		h = nil,
		x = 0,
		text = "123/456",
		layer = 5,
		name = "weapon_challenge_progress_bar_text",
		color = nil,
		w = self._progress_bar_panel:w(),
		h = self._progress_bar_panel:h(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._progress_text = self._progress_bar_panel:label(progress_bar_text_params)
end

function HUDNotificationWeaponChallenge:_set_challenge(challenge_data)
	local challenge, count, target, min_range, max_range, briefing_id = nil

	if challenge_data.challenge_id then
		challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_data.challenge_id)
		local tasks = challenge:tasks()
		briefing_id = tasks[1]:briefing_id()
		count = tasks[1]:current_count()
		target = tasks[1]:target()
		min_range = math.round(tasks[1]:min_range() / 100)
		max_range = math.round(tasks[1]:max_range() / 100)
	end

	briefing_id = briefing_id or challenge_data.challenge_briefing_id
	local skill_tweak_data = tweak_data.weapon_skills.skills[challenge_data.skill_name]

	self._title:set_text(utf8.to_upper(managers.localization:text(skill_tweak_data.name_id)))

	local tier_text = utf8.to_upper(managers.localization:text("menu_weapons_stats_tier_abbreviation")) .. RaidGUIControlWeaponSkills.ROMAN_NUMERALS[challenge_data.tier]

	self._tier:set_text(tier_text)

	local _, _, w, _ = self._tier:text_rect()

	self._tier:set_w(w)
	self._tier:set_center_x(self._icon:center_x())

	local icon = tweak_data.gui.icons[skill_tweak_data.icon]

	self._icon:set_image(icon.texture, unpack(icon.texture_rect))
	self._progress_bar_foreground_panel:set_w(self._progress_bar_panel:w() * count / target)

	local progress_text, description_text = nil

	if count ~= target then
		progress_text = tostring(count) .. "/" .. tostring(target)
		description_text = briefing_id
	else
		progress_text = utf8.to_upper(managers.localization:text("menu_weapon_challenge_completed"))
		description_text = briefing_id
	end

	local range = max_range > 0 and max_range or min_range

	self._description:set_text(managers.localization:text(description_text, {
		WEAPON = nil,
		RANGE = nil,
		AMOUNT = nil,
		AMOUNT = target,
		RANGE = range,
		WEAPON = managers.localization:text(tweak_data.weapon[challenge_data.weapon_id].name_id)
	}))
	self._progress_text:set_text(progress_text)
	self:_fit_size()
end

function HUDNotificationWeaponChallenge:_fit_size()
	local notification_height = HUDNotificationWeaponChallenge.PROGRESS_BAR_DISTANCE_FROM_BOTTOM
	notification_height = notification_height + self._progress_bar_panel:h()
	local _, _, _, h = self._description:text_rect()
	h = math.max(h, self._icon:h())

	self._description:set_h(h)

	notification_height = notification_height + HUDNotificationWeaponChallenge.DESCRIPTION_DISTANCE_FROM_PROGRESS_BAR + h
	notification_height = notification_height + HUDNotificationWeaponChallenge.TITLE_DISTANCE_FROM_DESCRIPTION + self._title:h() + HUDNotificationWeaponChallenge.TITLE_Y

	self._object:set_h(notification_height)
	self._progress_bar_panel:set_bottom(self._object:h() - HUDNotificationWeaponChallenge.PROGRESS_BAR_DISTANCE_FROM_BOTTOM)
	self._description:set_bottom(self._progress_bar_panel:y() - HUDNotificationWeaponChallenge.DESCRIPTION_DISTANCE_FROM_PROGRESS_BAR)
	self._icon:set_y(self._description:y() + 2)
	self._title:set_bottom(self._description:y() - HUDNotificationWeaponChallenge.TITLE_DISTANCE_FROM_DESCRIPTION)
	self._tier:set_center_y(self._title:center_y())
	self._object:set_bottom(self._object:parent():h() - HUDNotification.DEFAULT_DISTANCE_FROM_BOTTOM)
end

HUDNotificationActiveDuty = HUDNotificationActiveDuty or class(HUDNotification)
HUDNotification.TYPES[HUDNotification.ACTIVE_DUTY_BONUS] = HUDNotificationActiveDuty
HUDNotification.TYPES[HUDNotification.ACTIVE_DUTY_BONUS_OUTLAW] = HUDNotificationActiveDuty
HUDNotificationActiveDuty.BOTTOM = 800
HUDNotificationActiveDuty.WIDTH = 500
HUDNotificationActiveDuty.FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDNotificationActiveDuty.FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDNotificationActiveDuty.DESRIPTION_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDNotificationActiveDuty.FONT_TITLE = tweak_data.gui.fonts.din_compressed_outlined_32
HUDNotificationActiveDuty.FONT_TITLE_SIZE = tweak_data.gui.font_sizes.size_32
HUDNotificationActiveDuty.TITLE_COLOR = tweak_data.gui.colors.raid_red
HUDNotificationActiveDuty.BACKGROUND_IMAGE = "backgrounds_chat_bg"

function HUDNotificationActiveDuty:init(notification_data)
	self:_create_panel()
	self:_create_image(notification_data.icon)
	self:_create_description(notification_data)

	self._sound_effect = "daily_login_reward"
	self._sound_delay = 0.4

	self:_fit_size()

	self._initial_right_x = self._object:right()

	self._object:animate(callback(self, self, "_animate_show"))

	self._progress = 0
end

function HUDNotificationActiveDuty:hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDNotificationActiveDuty:destroy()
	self._object:stop()
	self._object:parent():remove(self._object)

	self = nil
end

function HUDNotificationActiveDuty:_create_panel()
	local hud = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT)
	local hud_panel = managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT).panel:root()
	local panel_params = {
		visible = true,
		name = "notification_active_duty",
		w = nil,
		w = HUDNotificationActiveDuty.WIDTH
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_right(hud.panel:w())

	self._initial_right_x = self._object:right()
	local background_params = {
		texture = nil,
		halign = "scale",
		valign = "scale",
		texture_rect = nil,
		h = nil,
		w = nil,
		w = self._object:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[HUDNotificationRaidUnlocked.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDNotificationRaidUnlocked.BACKGROUND_IMAGE].texture_rect
	}

	self._object:bitmap(background_params)
end

function HUDNotificationActiveDuty:_create_image(icon)
	local image_params = {
		texture = nil,
		height = 352,
		name = "notification_active_duty_gold_image",
		layer = 3,
		texture_rect = nil,
		width = 352,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = {
			0,
			0,
			512,
			512
		}
	}
	self._image = self._object:bitmap(image_params)

	self._image:set_right(self._object:w())
end

function HUDNotificationActiveDuty:_create_description(notification_data)
	local notification_type = notification_data.notification_type
	local text = ""
	text = utf8.to_upper(managers.localization:text("hud_active_duty_bonus"))
	text = text .. " (" .. notification_data.consecutive .. "/" .. notification_data.total .. "): "

	if notification_type == HUDNotification.ACTIVE_DUTY_BONUS then
		local amount = notification_data.amount

		if amount == 1 then
			text = text .. utf8.to_upper(managers.localization:text("menu_loot_screen_gold_bars_single"))
		else
			text = text .. (amount or 0) .. " " .. utf8.to_upper(managers.localization:text("menu_loot_screen_gold_bars"))
		end
	elseif notification_type == HUDNotification.ACTIVE_DUTY_BONUS_OUTLAW then
		text = text .. utf8.to_upper(managers.localization:text("menu_mission_selected_mission_type_consumable"))
	end

	local description_params = {
		text = nil,
		wrap = true,
		vertical = "center",
		layer = 3,
		align = "right",
		font_size = nil,
		font = nil,
		w = nil,
		name = "notification_raid_unlocked_description",
		color = nil,
		font = HUDNotificationActiveDuty.FONT,
		font_size = HUDNotificationActiveDuty.FONT_SIZE,
		w = self._object:w() - 64,
		color = HUDNotificationActiveDuty.DESCRIPTION_COLOR,
		text = text
	}
	self._description = self._object:text(description_params)
	local _, _, _, h = self._description:text_rect()

	self._description:set_h(h)
	self._description:set_right(self._object:w() - 32)
end

function HUDNotificationActiveDuty:_fit_size()
	local top_padding = 32
	local middle_padding = 32
	local bottom_padding = 32
	local notification_h = top_padding + self._image:h() + middle_padding + self._description:h() + bottom_padding

	self._object:set_h(notification_h)
	self._image:set_y(top_padding)
	self._description:set_y(self._image:y() + self._image:h() + middle_padding - bottom_padding)
	self._object:set_bottom(HUDNotificationActiveDuty.BOTTOM)
end

function HUDNotification:_animate_show(panel)
	panel:set_alpha(0)

	local duration = 0.4
	local t = 0

	if self._sound_effect then
		self._sound_delay = self._sound_delay or 0
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt

		if self._sound_effect and not self._played_sound_effect and self._sound_delay < t then
			managers.hud:post_event(self._sound_effect)

			self._played_sound_effect = true
		end

		local curr_alpha = Easing.quintic_in_out(t, 0, 1, duration)

		panel:set_alpha(curr_alpha)

		local current_x_offset = -(1 - curr_alpha) * HUDNotification.ANIMATION_MOVE_X_DISTANCE

		self._object:set_right(self._initial_right_x + current_x_offset)
	end

	panel:set_alpha(1)
	self._object:set_right(self._initial_right_x)
end

function HUDNotification:_animate_reshow(panel)
	local duration = 0.4
	local t = self._object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quintic_in_out(t, 0, 1, duration)

		panel:set_alpha(curr_alpha)

		local current_x_offset = -(1 - curr_alpha) * HUDNotification.ANIMATION_MOVE_X_DISTANCE

		self._object:set_right(self._initial_right_x + current_x_offset)
	end

	panel:set_alpha(1)
	self._object:set_right(self._initial_right_x)
end

function HUDNotification:_animate_full_progress()
	local t = 0
	local starting_scale = self._object:w() / self._panel_shape_w

	while t < 0.1 do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quintic_out(t, starting_scale, 0.75 - starting_scale, 0.1)

		self._object:set_size(self._panel_shape_w * scale, self._panel_shape_h * scale)
		self._object:set_x(self._panel_shape_x + self._panel_shape_w * (1 - scale) * 0.5)
		self._object:set_y(self._panel_shape_y + self._panel_shape_h * (1 - scale) * 0.5)
		self._text:set_font_size(self._font_size * scale)
	end
end

function HUDNotification:_animate_execute()
	local t = 0

	if self._progress < 1 then
		while t < 0.025 do
			local dt = coroutine.yield()
			t = t + dt
			local scale = Easing.linear(t, 1, -0.1, 0.025)

			self._object:set_size(self._panel_shape_w * scale, self._panel_shape_h * scale)
			self._object:set_x(self._panel_shape_x + self._panel_shape_w * (1 - scale) * 0.5)
			self._object:set_y(self._panel_shape_y + self._panel_shape_h * (1 - scale) * 0.5)
			self._text:set_font_size(self._font_size * scale)
		end
	end

	self._object:set_size(self._panel_shape_w * 0.6, self._panel_shape_h * 0.6)
	self._object:set_x(self._panel_shape_x + self._panel_shape_w * 0.4 * 0.5)
	self._object:set_y(self._panel_shape_y + self._panel_shape_h * 0.4 * 0.5)
	self._text:set_font_size(self._font_size * 0.6)
	wait(0.03)

	t = 0

	while t < 0.5 do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quintic_out(t, 0.6, 0.6, 0.5)

		self._object:set_size(self._panel_shape_w * scale, self._panel_shape_h * scale)
		self._object:set_x(self._panel_shape_x + self._panel_shape_w * (1 - scale) * 0.5)
		self._object:set_y(self._panel_shape_y + self._panel_shape_h * (1 - scale) * 0.5)
		self._text:set_font_size(self._font_size * scale)

		if t >= 0.1 then
			local alpha = Easing.quintic_out(t - 0.1, 1, -1, 0.3)

			self._object:set_alpha(alpha)
		end
	end

	self._object:set_alpha(0)
	self._hud_panel:remove(self._object)
	managers.queued_tasks:queue("notification_done", managers.notification.notification_done, managers.notification, nil, 0.1, nil, true)
end

function HUDNotification:_animate_cancel()
	local t = 0
	local starting_progress = self._progress

	while t < 0.1 do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quintic_out(t, starting_progress, -starting_progress, 0.1)
		local scale = 1 - 0.2 * progress

		self._object:set_size(self._panel_shape_w * scale, self._panel_shape_h * scale)
		self._object:set_x(self._panel_shape_x + self._panel_shape_w * (1 - scale) * 0.5)
		self._object:set_y(self._panel_shape_y + self._panel_shape_h * (1 - scale) * 0.5)
		self._text:set_font_size(self._font_size * scale)

		self._progress = progress
	end

	self._object:set_size(self._panel_shape_w, self._panel_shape_h)

	self._progress = 0

	if managers.notification._delayed_hide then
		managers.queued_tasks:queue("hide_current_notification", managers.notification.hide_current_notification, managers.notification, nil, 0.1, nil, true)
	end
end

function HUDNotification:_animate_hide(panel)
	local t = 0

	while t < 0.75 do
		local dt = coroutine.yield()
		t = t + dt

		if t >= 0.1 and t < 0.6 then
			local curr_alpha = Easing.quintic_in_out(t - 0.1, 1, -1, 0.5)

			panel:set_alpha(curr_alpha)

			local current_x_offset = -(1 - curr_alpha) * HUDNotification.ANIMATION_MOVE_X_DISTANCE

			self._object:set_right(self._initial_right_x + current_x_offset)
		end
	end

	panel:set_alpha(0)
	self:destroy()
	managers.queued_tasks:queue("notification_done", managers.notification.notification_done, managers.notification, nil, 0.1, nil, true)
end
