RaidGUIControlSaveInfo = RaidGUIControlSaveInfo or class(RaidGUIControl)
RaidGUIControlSaveInfo.DOG_TAG_LABEL_X = 76

-- Lines 5-15
function RaidGUIControlSaveInfo:init(parent, params)
	RaidGUIControlSaveInfo.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback

	self:_create_panel()
	self:_create_info_icons()
	self:_create_separator()
	self:_create_peer_details_title()
	self:_create_peer_details()
end

-- Lines 17-27
function RaidGUIControlSaveInfo:_create_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = panel_params.layer or self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or self._panel:w()
	panel_params.h = self._params.h or self._panel:h()
	self._object = self._panel:panel(panel_params)
end

-- Lines 29-83
function RaidGUIControlSaveInfo:_create_info_icons()
	local info_icons_panel_params = {
		name = "info_icons_panel",
		h = 96,
		y = 18,
		x = 0,
		w = self._object:w() * 0.78
	}
	self._info_icons_panel = self._object:panel(info_icons_panel_params)

	self._info_icons_panel:set_center_x(self._object:w() / 2)

	local h = self._info_icons_panel:h()
	local dog_tag_panel_params = {
		name = "dog_tag_panel",
		h = 64,
		y = 23,
		w = 180,
		x = 0
	}
	self._dog_tag_panel = self._info_icons_panel:panel(dog_tag_panel_params)
	local dog_tag_icon_params = {
		name = "dog_tag_icon",
		texture = tweak_data.gui.icons.rewards_dog_tags_small.texture,
		texture_rect = tweak_data.gui.icons.rewards_dog_tags_small.texture_rect,
		color = tweak_data.gui.colors.raid_black
	}
	local dog_tag_icon = self._dog_tag_panel:bitmap(dog_tag_icon_params)

	dog_tag_icon:set_center_y(self._dog_tag_panel:h() / 2)

	local dog_tag_count_params = {
		vertical = "center",
		name = "dog_tag_count",
		h = 32,
		align = "center",
		text = "120 / 140",
		y = 0,
		x = RaidGUIControlSaveInfo.DOG_TAG_LABEL_X,
		font = RaidGUIControlPeerDetails.FONT,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_black
	}
	self._dog_tag_count = self._dog_tag_panel:text(dog_tag_count_params)
	local dog_tag_label_params = {
		name = "dog_tag_label",
		vertical = "center",
		h = 32,
		align = "center",
		y = 32,
		font = RaidGUIControlPeerDetails.FONT,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_black,
		text = self:translate("menu_loot_screen_dog_tags", true)
	}
	self._dog_tag_label = self._dog_tag_panel:text(dog_tag_label_params)
	local _, _, w, _ = self._dog_tag_label:text_rect()

	self._dog_tag_label:set_w(w)
	self._info_icons_panel:set_h(h)
end

-- Lines 85-93
function RaidGUIControlSaveInfo:_create_separator()
	local separator_params = {
		name = "separator",
		h = 2,
		y = 123,
		w = 446,
		x = 34,
		color = tweak_data.gui.colors.raid_black
	}
	self._separator = self._object:rect(separator_params)
end

-- Lines 95-108
function RaidGUIControlSaveInfo:_create_peer_details_title()
	local peer_details_title_params = {
		name = "peer_details_title",
		h = 32,
		vertical = "center",
		align = "left",
		y = 137,
		x = self._info_icons_panel:x(),
		w = self._info_icons_panel:w(),
		font = RaidGUIControlPeerDetails.FONT,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_light_red,
		text = self:translate("operation_save_details_teammates_title", true)
	}
	self._peer_details_title = self._object:text(peer_details_title_params)
end

-- Lines 110-130
function RaidGUIControlSaveInfo:_create_peer_details()
	local peer_info_panel_params = {
		name = "peer_info_panel",
		h = 512,
		y = 202,
		x = self._info_icons_panel:x(),
		w = self._info_icons_panel:w()
	}
	self._peer_info_panel = self._object:panel(peer_info_panel_params)
	self._peer_info_details = {}
	local y = 0

	for i = 1, 4 do
		local params = {
			x = 0,
			y = y,
			w = self._peer_info_panel:w()
		}
		local peer_details = self._peer_info_panel:create_custom_control(RaidGUIControlPeerDetails, params)

		table.insert(self._peer_info_details, peer_details)

		y = y + 112
	end
end

-- Lines 132-204
function RaidGUIControlSaveInfo:set_save_info(slot_index)
	local save_slot = managers.raid_job:get_save_slots()[slot_index]

	if not save_slot then
		return
	end

	local event_data = save_slot.event_data[#save_slot.event_data]
	local loot_acquired = 0
	local loot_spawned = 0

	for _, data in pairs(save_slot.event_data) do
		if data.loot_data then
			loot_acquired = loot_acquired + data.loot_data.acquired
			loot_spawned = loot_spawned + data.loot_data.spawned
		end
	end

	if loot_spawned == 0 then
		self._dog_tag_count:set_text(tostring("--"))

		local _, _, w, _ = self._dog_tag_count:text_rect()

		self._dog_tag_count:set_w(w)
	else
		self._dog_tag_count:set_text(tostring(loot_acquired) .. " / " .. tostring(loot_spawned))

		local _, _, w, _ = self._dog_tag_count:text_rect()

		self._dog_tag_count:set_w(w)
	end

	local rotation = self._dog_tag_panel:rotation()

	self._dog_tag_panel:set_rotation(0)
	self._dog_tag_count:set_y(0)
	self._dog_tag_label:set_y(32)

	local actual_w = math.max(self._dog_tag_count:w(), self._dog_tag_label:w())

	self._dog_tag_count:set_w(actual_w)
	self._dog_tag_label:set_w(actual_w)
	self._dog_tag_count:set_x(RaidGUIControlSaveInfo.DOG_TAG_LABEL_X)
	self._dog_tag_label:set_x(RaidGUIControlSaveInfo.DOG_TAG_LABEL_X)
	self._dog_tag_panel:set_w(self._dog_tag_count:right())
	self._dog_tag_panel:set_rotation(rotation)

	if not event_data.peer_data then
		debug_pause("[RaidGUIControlSaveInfo][set_save_info] Operation save has no peer data: ", inspect(event_data))

		return
	end

	for i = 1, #self._peer_info_details do
		self._peer_info_details[i]:set_alpha(0)

		local peer_data = event_data.peer_data[i]

		if peer_data then
			local name = nil

			if peer_data.is_local_player then
				name = self:translate("menu_save_info_you", true) .. " (" .. peer_data.name .. ")"
			elseif SystemInfo:platform() == Idstring("XB1") then
				name = managers.hud:get_character_name_by_nationality(peer_data.nationality)
			else
				name = peer_data.name
			end

			self._peer_info_details[i]:set_profile_name(name)
			self._peer_info_details[i]:set_class(peer_data.class)
			self._peer_info_details[i]:set_nationality(peer_data.nationality)
			self._peer_info_details[i]:set_level(peer_data.level)
			self._peer_info_details[i]:set_alpha(1)
		end
	end
end

-- Lines 207-209
function RaidGUIControlSaveInfo:set_left(left)
	self._object:set_left(left)
end

-- Lines 211-213
function RaidGUIControlSaveInfo:set_right(right)
	self._object:set_right(right)
end

-- Lines 215-217
function RaidGUIControlSaveInfo:set_top(top)
	self._object:set_top(top)
end

-- Lines 219-221
function RaidGUIControlSaveInfo:set_bottom(bottom)
	self._object:set_bottom(bottom)
end

-- Lines 223-225
function RaidGUIControlSaveInfo:set_center_x(center_x)
	self._object:set_center_x(center_x)
end

-- Lines 227-229
function RaidGUIControlSaveInfo:set_center_y(center_y)
	self._object:set_center_y(center_y)
end

-- Lines 232-233
function RaidGUIControlSaveInfo:close()
end
