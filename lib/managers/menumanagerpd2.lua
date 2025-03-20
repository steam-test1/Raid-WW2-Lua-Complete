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

MenuComponentInitiator = MenuComponentInitiator or class()

function MenuComponentInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	if data and data.back_callback then
		table.insert(node:parameters().back_callback, data.back_callback)
	end

	node:parameters().menu_component_data = data

	return node
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
			_meta = "option",
			s_h = 24,
			s_w = 24,
			s_y = 24,
			s_x = 24,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox",
			h = 24,
			w = 24,
			y = 0,
			x = 24,
			value = "on",
			icon = "ui/main_menu/textures/debug_menu_tickbox"
		},
		{
			_meta = "option",
			s_h = 24,
			s_w = 24,
			s_y = 24,
			s_x = 0,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox",
			h = 24,
			w = 24,
			y = 0,
			x = 0,
			value = "off",
			icon = "ui/main_menu/textures/debug_menu_tickbox"
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
		last_item = true,
		text_id = "menu_back",
		visible_callback = "is_pc_controller",
		back = true,
		name = "back",
		previous_node = true
	}
	local new_item = node:create_item(nil, params)

	node:add_item(new_item)

	return new_item
end
