core:import("CoreMenuManager")
core:import("CoreMenuCallbackHandler")
require("lib/managers/menu/MenuSceneManager")
require("lib/managers/menu/MenuComponentManager")
require("lib/managers/menu/items/MenuItemDivider")
core:import("CoreEvent")

function MenuManager:update(t, dt, ...)
	MenuManager.super.update(self, t, dt, ...)
	managers.menu_component:update(t, dt)
end

function MenuManager:on_view_character(user)
	local outfit = user:rich_presence("outfit")

	if outfit ~= "" then
		if managers.menu:active_menu().logic:selected_node_name() ~= "view_character" then
			managers.menu:active_menu().logic:select_node("view_character", true, {})
		end

		managers.menu_component:create_view_character_profile_gui(user, 0, 300)
	end
end

function MenuManager:on_enter_lobby()
	Application:debug("[MenuManager:on_enter_lobby]")

	if managers and managers.menu and managers.menu:active_menu() and managers.menu:active_menu().logic then
		managers.menu:active_menu().logic:select_node("lobby", true, {})
	end

	managers.network:session():on_entered_lobby()
	self:setup_local_lobby_character()

	if Global.exe_argument_level then
		MenuCallbackHandler:start_the_game()
	end
end

function MenuManager:on_leave_active_job()
	managers.statistics:stop_session({
		quit = true
	})
	managers.raid_job:deactivate_current_job()
	managers.worldcollection:on_simulation_ended()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	self._sound_source:post_event("menu_exit")
	managers.menu:close_menu("lobby_menu")
	managers.menu:close_menu("menu_pause")
end

function MenuManager:setup_local_lobby_character()
	local local_peer = managers.network:session():local_peer()
	local level = managers.experience:current_level()
	local character = local_peer:character()
	local player_class = managers.skilltree:get_character_profile_class()

	local_peer:set_outfit_string(managers.blackmarket:outfit_string())
	local_peer:set_class(player_class)
	managers.network:session():send_to_peers_loaded("sync_profile", level, player_class)
	managers.network:session():check_send_outfit()
end

function MenuManager:set_cash_safe_scene_done(done, silent)
	self._cash_safe_scene_done = done

	if not silent then
		local logic = managers.menu:active_menu().logic

		if logic then
			logic:refresh_node()
		end
	end
end

function MenuManager:cash_safe_scene_done()
	return self._cash_safe_scene_done
end

function MenuManager:http_test()
	Steam:http_request("http://www.overkillsoftware.com/?feed=rss", callback(self, self, "http_test_result"))
end

function MenuManager:http_test_result(success, body)
	print("success", success)
	print("body", body)
	print(inspect(self:_get_text_block(body, "<title>", "</title>")))
	print(inspect(self:_get_text_block(body, "<link>", "</link>")))
end

MenuMarketItemInitiator = MenuMarketItemInitiator or class()

function MenuMarketItemInitiator:modify_node(node)
	local node_name = node:parameters().name
	local armor_item = node:item("armor")

	self:_add_expand_armor(armor_item)

	local submachine_guns_item = node:item("submachine_guns")

	self:_add_expand_weapon(submachine_guns_item, 3)

	local assault_rifles_item = node:item("assault_rifles")

	self:_add_expand_weapon(assault_rifles_item, 2)

	local handguns_item = node:item("handguns")

	self:_add_expand_weapon(handguns_item, 1)

	local support_equipment_item = node:item("support_equipment")

	if support_equipment_item and self:_uses_owned_stats() then
		support_equipment_item:set_parameter("current", 1)
		support_equipment_item:set_parameter("total", 4)
	end

	local miscellaneous_item = node:item("miscellaneous")

	if miscellaneous_item and self:_uses_owned_stats() then
		miscellaneous_item:set_parameter("current", 0)
		miscellaneous_item:set_parameter("total", 6)
	end

	local masks_item = node:item("masks")

	self:_add_expand_mask(masks_item)

	local character_item = node:item("character")

	self:_add_expand_character(character_item)

	return node
end

function MenuMarketItemInitiator:_add_weapon(bm_data)
	return true
end

function MenuMarketItemInitiator:_add_character(bm_data)
	return true
end

function MenuMarketItemInitiator:_add_mask(bm_data)
	return true
end

function MenuMarketItemInitiator:_add_armor(bm_data)
	return true
end

function MenuMarketItemInitiator:_uses_owned_stats()
	return true
end

function MenuMarketItemInitiator:_add_weapon_params()
	return
end

function MenuMarketItemInitiator:_add_mask_params(params)
	return
end

function MenuMarketItemInitiator:_add_character_params(params)
	return
end

function MenuMarketItemInitiator:_add_armor_params(params)
	return
end

function MenuMarketItemInitiator:_add_expand_weapon(item, selection_index)
	if not item then
		return
	end

	local i = 0
	local j = 0

	for weapon, data in pairs(tweak_data.weapon) do
		if data.autohit and data.use_data.selection_index == selection_index then
			i = i + 1

			local bm_data = Global.blackmarket_manager.weapons[weapon]
			local unlocked = bm_data.unlocked
			local owned = bm_data.owned

			if owned and unlocked then
				j = j + 1
			end

			local equipped = bm_data.equipped
			local condition = bm_data.condition

			if self:_add_weapon(bm_data) then
				local weapon_item = item:get_item(weapon)

				if not weapon_item then
					local params = {
						callback = "test_clicked_weapon",
						type = "MenuItemWeaponExpand",
						name = weapon,
						text_id = data.name_id,
						weapon_id = weapon,
						unlocked = unlocked and true or false,
						condition = condition,
						weapon_slot = selection_index
					}

					self:_add_weapon_params(params)

					weapon_item = CoreMenuNode.MenuNode.create_item(item, params)

					item:add_item(weapon_item)
				end

				weapon_item:parameters().unlocked = unlocked
				weapon_item:parameters().equipped = equipped and true or false
				weapon_item:parameters().owned = owned
				weapon_item:parameters().condition = condition
			end
		end
	end

	if self:_uses_owned_stats() then
		item:set_parameter("current", j)
		item:set_parameter("total", i)
	end

	item:_show_items(nil)

	return i
end

function MenuMarketItemInitiator:_add_expand_mask(item)
	local i = 0
	local j = 0

	for mask_id, data in pairs(tweak_data.blackmarket.masks) do
		i = i + 1

		local bm_data = Global.blackmarket_manager.masks[mask_id]
		local unlocked = bm_data.unlocked
		local owned = bm_data.owned
		local equipped = bm_data.equipped

		if owned then
			j = j + 1
		end

		if self:_add_mask(bm_data) then
			local mask_item = item:get_item(mask_id)

			if not mask_item then
				local params = {
					callback = "test_clicked_mask",
					type = "MenuItemMaskExpand",
					name = mask_id,
					text_id = data.name_id,
					unlocked = unlocked and true or false,
					mask_id = mask_id
				}

				self:_add_mask_params(params)

				mask_item = CoreMenuNode.MenuNode.create_item(item, params)

				item:add_item(mask_item)
			end

			mask_item:parameters().equipped = equipped and true or false
			mask_item:parameters().owned = owned
		end
	end

	if self:_uses_owned_stats() then
		item:set_parameter("current", j)
		item:set_parameter("total", i)
	end

	item:_show_items(nil)

	return i
end

function MenuMarketItemInitiator:_add_expand_character(item)
	local i = 0
	local j = 0

	for character_id, data in pairs(tweak_data.blackmarket.characters) do
		i = i + 1

		local bm_data = Global.blackmarket_manager.characters[character_id]
		local unlocked = bm_data.unlocked
		local owned = bm_data.owned
		local equipped = bm_data.equipped

		if owned then
			j = j + 1
		end

		if self:_add_character(bm_data) then
			local character_item = item:get_item(character_id)

			if not character_item then
				local params = {
					callback = "clicked_character",
					type = "MenuItemCharacterExpand",
					name = character_id,
					text_id = data.name_id,
					unlocked = unlocked and true or false,
					character_id = character_id
				}

				self:_add_character_params(params)

				character_item = CoreMenuNode.MenuNode.create_item(item, params)

				item:add_item(character_item)
			end

			character_item:parameters().equipped = equipped and true or false
			character_item:parameters().owned = owned
		end
	end

	if self:_uses_owned_stats() then
		item:set_parameter("current", j)
		item:set_parameter("total", i)
	end

	item:_show_items(nil)

	return i
end

function MenuMarketItemInitiator:_add_expand_armor(item)
	if not item then
		return
	end

	local i = 0
	local j = 0

	for armor_id, data in pairs(tweak_data.blackmarket.armors) do
		i = i + 1

		local bm_data = Global.blackmarket_manager.armors[armor_id]
		local unlocked = bm_data.unlocked
		local owned = bm_data.owned
		local equipped = bm_data.equipped
		local condition = bm_data.condition

		if owned then
			j = j + 1
		end

		if self:_add_armor(bm_data) then
			local armor_item = item:get_item(armor_id)

			if not armor_item then
				local params = {
					callback = "test_clicked_armor",
					type = "MenuItemArmorExpand",
					name = armor_id,
					text_id = data.name_id,
					armor_id = armor_id,
					condition = condition
				}

				self:_add_armor_params(params)

				armor_item = CoreMenuNode.MenuNode.create_item(item, params)

				item:add_item(armor_item)
			end

			armor_item:parameters().equipped = equipped
			armor_item:parameters().unlocked = unlocked
			armor_item:parameters().owned = owned
			armor_item:parameters().condition = condition
		end
	end

	if self:_uses_owned_stats() then
		item:set_parameter("current", j)
		item:set_parameter("total", i)
	end

	item:_show_items(nil)

	return i
end

MenuBlackMarketInitiator = MenuBlackMarketInitiator or class(MenuMarketItemInitiator)
MenuBuyUpgradesInitiator = MenuBuyUpgradesInitiator or class()

function MenuBuyUpgradesInitiator:modify_node(original_node, weapon_id, p2, p3)
	local node = deep_clone(original_node)
	local node_name = node:parameters().name

	node:parameters().topic_id = tweak_data.weapon[weapon_id].name_id

	local scopes_item = node:item("scopes")

	self:_add_expand_upgrade(scopes_item, weapon_id, "scopes")

	local barrels_item = node:item("barrels")

	self:_add_expand_upgrade(barrels_item, weapon_id, "barrels")

	local grips_item = node:item("grips")

	self:_add_expand_upgrade(grips_item, weapon_id, "grips")

	return node
end

function MenuBuyUpgradesInitiator:_add_expand_upgrade(item, weapon_id, upgrade)
	return
end

MenuComponentInitiator = MenuComponentInitiator or class()

function MenuComponentInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	if data and data.back_callback then
		table.insert(node:parameters().back_callback, data.back_callback)
	end

	node:parameters().menu_component_data = data

	return node
end

MenuLoadoutInitiator = MenuLoadoutInitiator or class()

function MenuLoadoutInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	node:parameters().menu_component_data = data
	node:parameters().menu_component_next_node_name = "loadout"

	return node
end

MenuCharacterCustomizationInitiator = MenuCharacterCustomizationInitiator or class(MenuMarketItemInitiator)

function MenuCharacterCustomizationInitiator:_add_weapon(bm_data)
	return bm_data.owned and bm_data.unlocked
end

function MenuCharacterCustomizationInitiator:_add_character(bm_data)
	return bm_data.owned and bm_data.unlocked
end

function MenuCharacterCustomizationInitiator:_add_mask(bm_data)
	return bm_data.owned and bm_data.unlocked
end

function MenuCharacterCustomizationInitiator:_add_armor(bm_data)
	return bm_data.owned and bm_data.unlocked
end

function MenuCharacterCustomizationInitiator:_uses_owned_stats()
	return false
end

function MenuCharacterCustomizationInitiator:_add_weapon_params(params)
	params.customize = true
end

function MenuCharacterCustomizationInitiator:_add_mask_params(params)
	params.customize = true
end

function MenuCharacterCustomizationInitiator:_add_character_params(params)
	params.customize = true
end

function MenuCharacterCustomizationInitiator:_add_armor_params(params)
	params.customize = true
end

function MenuManager:show_repair_weapon(params, weapon, cost)
	local dialog_data = {}

	dialog_data.title = managers.localization:text("dialog_repair_weapon_title")
	dialog_data.text = managers.localization:text("dialog_repair_weapon_message", {
		WEAPON = weapon,
		COST = cost
	})

	local yes_button = {}

	yes_button.text = managers.localization:text("dialog_yes")
	yes_button.callback_func = params.yes_func

	local no_button = {}

	no_button.text = managers.localization:text("dialog_no")
	no_button.class = RaidGUIControlButtonShortSecondary
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_buy_weapon(params, weapon, cost)
	local dialog_data = {}

	dialog_data.title = managers.localization:text("dialog_buy_weapon_title")
	dialog_data.text = managers.localization:text("dialog_buy_weapon_message", {
		WEAPON = weapon,
		COST = cost
	})

	local yes_button = {}

	yes_button.text = managers.localization:text("dialog_yes")
	yes_button.callback_func = params.yes_func

	local no_button = {}

	no_button.text = managers.localization:text("dialog_no")
	no_button.class = RaidGUIControlButtonShortSecondary
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

FbiFilesInitiator = FbiFilesInitiator or class()

function FbiFilesInitiator:modify_node(node, up)
	node:clean_items()

	local params = {
		callback = "on_visit_fbi_files",
		name = "on_visit_fbi_files",
		help_id = "menu_visit_fbi_files_help",
		text_id = "menu_visit_fbi_files"
	}
	local new_item = node:create_item(nil, params)

	node:add_item(new_item)

	if managers.network:session() then
		local peer = managers.network:session():local_peer()
		local params = {
			localize_help = false,
			localize = false,
			to_upper = false,
			callback = "on_visit_fbi_files_suspect",
			name = peer:user_id(),
			text_id = peer:name() .. " (" .. (managers.experience:current_level() or "") .. ")",
			rpc = peer:rpc(),
			peer = peer
		}
		local new_item = node:create_item(nil, params)

		node:add_item(new_item)

		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				localize_help = false,
				localize = false,
				to_upper = false,
				callback = "on_visit_fbi_files_suspect",
				name = peer:user_id(),
				text_id = peer:name() .. " (" .. (peer:level() or "") .. ")",
				rpc = peer:rpc(),
				peer = peer
			}
			local new_item = node:create_item(nil, params)

			node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(node)

	return node
end

function FbiFilesInitiator:refresh_node(node)
	return self:modify_node(node)
end

MenuInitiatorBase = MenuInitiatorBase or class()

function MenuInitiatorBase:modify_node(original_node, data)
	return original_node
end

function MenuInitiatorBase:create_divider(node, id, text_id, size, color)
	local params = {
		name = "divider_" .. id,
		no_text = not text_id,
		text_id = text_id,
		size = size or 8,
		color = color
	}
	local data_node = {
		type = "MenuItemDivider"
	}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:create_toggle(node, params)
	local data_node = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "ui/main_menu/textures/debug_menu_tickbox",
			x = 24,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "ui/main_menu/textures/debug_menu_tickbox",
			x = 0,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:create_item(node, params)
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:create_multichoice(node, choices, params)
	if #choices == 0 then
		return
	end

	local data_node = {
		type = "MenuItemMultiChoice"
	}

	for _, choice in ipairs(choices) do
		table.insert(data_node, choice)
	end

	local new_item = node:create_item(data_node, params)

	new_item:set_value(choices[1].value)
	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:create_slider(node, params)
	local data_node = {
		type = "CoreMenuItemSlider.ItemSlider",
		show_value = params.show_value,
		min = params.min,
		max = params.max,
		step = params.step,
		show_value = params.show_value
	}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:create_input(node, params)
	local data_node = {
		type = "MenuItemInput"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)

	return new_item
end

function MenuInitiatorBase:add_back_button(node)
	node:delete_item("back")

	local params = {
		visible_callback = "is_pc_controller",
		name = "back",
		back = true,
		text_id = "menu_back",
		last_item = true,
		previous_node = true
	}
	local new_item = node:create_item(nil, params)

	node:add_item(new_item)

	return new_item
end

MenuChooseWeaponCosmeticInitiator = MenuChooseWeaponCosmeticInitiator or class(MenuInitiatorBase)

function MenuChooseWeaponCosmeticInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	node:clean_items()

	if not node:item("divider_end") then
		if data and data.instance_ids then
			local sort_items = {}

			for id, data in pairs(data.instance_ids) do
				table.insert(sort_items, id)
			end

			for _, instance_id in ipairs(sort_items) do
				self:create_item(node, {
					localize = false,
					enabled = true,
					name = instance_id,
					text_id = instance_id
				})
			end

			print(inspect(data.instance_ids))
		end

		self:create_divider(node, "end")
		self:add_back_button(node)
		node:set_default_item_name("back")
		node:select_item("back")
	end

	managers.menu_component:set_blackmarket_enabled(false)

	return node
end

function MenuChooseWeaponCosmeticInitiator:add_back_button(node)
	node:delete_item("back")

	local params = {
		visible_callback = "is_pc_controller",
		name = "back",
		halign = "right",
		text_id = "menu_back",
		last_item = "true",
		align = "right",
		previous_node = "true"
	}
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	return new_item
end

MenuOpenContainerInitiator = MenuOpenContainerInitiator or class(MenuInitiatorBase)

function MenuOpenContainerInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	node:parameters().container_data = data.container or {}

	managers.menu_component:set_blackmarket_enabled(false)
	self:update_node(node)

	return node
end

function MenuOpenContainerInitiator:refresh_node(node)
	self:update_node(node)

	return node
end

function MenuOpenContainerInitiator:update_node(node)
	local item = node:item("open_container")

	if item then
		item:set_enabled(MenuCallbackHandler:have_safe_and_drill_for_container(node:parameters().container_data))
	end
end

MenuEconomySafeInitiator = MenuEconomySafeInitiator or class()

function MenuEconomySafeInitiator:modify_node(node, safe_entry)
	node:parameters().safe_entry = safe_entry

	return node
end
