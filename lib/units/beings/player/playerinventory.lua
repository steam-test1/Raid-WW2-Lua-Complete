PlayerInventory = PlayerInventory or class()
PlayerInventory._all_event_types = {
	"add",
	"equip",
	"unequip"
}
PlayerInventory.SLOT_1 = 1
PlayerInventory.SLOT_2 = 2
PlayerInventory.SLOT_3 = 3
PlayerInventory.SLOT_4 = 4
PlayerInventory.SEND_WEAPON_TYPE_PLAYER_PRIMARY_SECONDARY = "send_type_player_primary_secondary"
PlayerInventory.SEND_WEAPON_TYPE_PLAYER_MELEE_GRENADE = "send_type_player_melee_grenade"
PlayerInventory.SEND_WEAPON_TYPE_TEAMAI_COPS = "send_type_teamai_cops"

function PlayerInventory:init(unit)
	self._unit = unit
	self._available_selections = {}
	self._equipped_selection = nil
	self._latest_addition = nil
	self._selected_primary = nil
	self._use_data_alias = "player"
	self._align_places = {
		right_hand = {
			on_body = false,
			obj3d_name = Idstring("a_weapon_right")
		},
		left_hand = {
			on_body = false,
			obj3d_name = Idstring("a_weapon_left")
		}
	}
	self._listener_id = "PlayerInventory" .. tostring(unit:key())
	self._listener_holder = EventListenerHolder:new()
	self._mask_unit = nil
	self._melee_weapon_unit = nil
	self._melee_weapon_unit_name = nil
end

function PlayerInventory:pre_destroy(unit)
	if self._weapon_add_clbk then
		managers.enemy:remove_delayed_clbk(self._weapon_add_clbk)

		self._weapon_add_clbk = nil
	end

	self:destroy_all_items()
end

function PlayerInventory:destroy_all_items()
	for i_sel, selection_data in pairs(self._available_selections) do
		if selection_data.unit and selection_data.unit:base() then
			selection_data.unit:base():remove_destroy_listener(self._listener_id)
			selection_data.unit:base():set_slot(selection_data.unit, 0)
		else
			debug_pause_unit(self._unit, "[PlayerInventory:destroy_all_items] broken inventory unit", selection_data.unit, selection_data.unit:base())
		end
	end

	self._equipped_selection = nil
	self._available_selections = {}

	if alive(self._mask_unit) then
		for _, linked_unit in ipairs(self._mask_unit:children()) do
			linked_unit:unlink()
			World:delete_unit(linked_unit)
		end

		World:delete_unit(self._mask_unit)

		self._mask_unit = nil
	end

	if self._melee_weapon_unit_name then
		managers.dyn_resource:unload(Idstring("unit"), self._melee_weapon_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._melee_weapon_unit_name = nil
	end
end

function PlayerInventory:equipped_selection()
	return self._equipped_selection
end

function PlayerInventory:equipped_unit()
	return self._equipped_selection and self._available_selections[self._equipped_selection].unit
end

function PlayerInventory:unit_by_selection(selection)
	return self._available_selections[selection] and self._available_selections[selection].unit
end

function PlayerInventory:is_selection_available(selection_index)
	return self._available_selections[selection_index] and true or false
end

function PlayerInventory:add_unit(new_unit, is_equip, equip_is_instant)
	local new_selection = {}
	local use_data = new_unit:base():get_use_data(self._use_data_alias)
	new_selection.use_data = use_data
	new_selection.unit = new_unit

	new_unit:base():add_destroy_listener(self._listener_id, callback(self, self, "clbk_weapon_unit_destroyed"))

	local selection_index = use_data.selection_index

	if self._available_selections[selection_index] then
		local old_weapon_unit = self._available_selections[selection_index].unit
		is_equip = is_equip or old_weapon_unit == self:equipped_unit()

		old_weapon_unit:base():remove_destroy_listener(self._listener_id)
		old_weapon_unit:base():set_slot(old_weapon_unit, 0)
		World:delete_unit(old_weapon_unit)

		if self._equipped_selection == selection_index then
			self._equipped_selection = nil
		end
	end

	self._available_selections[selection_index] = new_selection
	self._latest_addition = selection_index
	self._selected_primary = self._selected_primary or selection_index

	self:_call_listeners("add")

	if is_equip then
		self:equip_latest_addition(equip_is_instant)
	else
		self:_place_selection(selection_index, is_equip)
	end
end

function PlayerInventory:clbk_weapon_unit_destroyed(weap_unit)
	local weapon_key = weap_unit:key()

	for i_sel, sel_data in pairs(self._available_selections) do
		if sel_data.unit:key() == weapon_key then
			if i_sel == self._equipped_selection then
				self:_call_listeners("unequip")
			end

			self:remove_selection(i_sel, true)

			break
		end
	end
end

function PlayerInventory:get_latest_addition_hud_data()
	local unit = self._available_selections[self._latest_addition].unit
	local _, _, amount = unit:base():ammo_info()

	return {
		is_equip = self._latest_addition == self._selected_primary,
		amount = amount,
		inventory_index = self._latest_addition,
		unit = unit
	}
end

function PlayerInventory:add_unit_by_name(new_unit_name, equip, instant)
	for _, selection in pairs(self._available_selections) do
		if selection.unit:name() == new_unit_name then
			return
		end
	end

	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = true,
		autoaim = true,
		alert_AI = true,
		alert_filter = self._unit:movement():SO_access()
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)
end

function PlayerInventory:add_unit_by_factory_name(factory_name, equip, instant, blueprint, cosmetics, texture_switches)
	local factory_weapon = tweak_data.weapon.factory[factory_name]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	local new_unit = World:spawn_unit(ids_unit_name, Vector3(), Rotation())

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():set_texture_switches(texture_switches)

	if blueprint then
		new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	else
		new_unit:base():assemble(factory_name)
	end

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = true,
		autoaim = true,
		alert_AI = true,
		alert_filter = self._unit:movement():SO_access(),
		timer = managers.player:player_timer()
	}

	if blueprint then
		setup_data.panic_suppression_skill = not managers.weapon_factory:has_perk("silencer", factory_name, blueprint) and managers.player:has_category_upgrade("player", "panic_suppression") or false
	end

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun()
	end
end

function PlayerInventory:remove_selection(selection_index, instant)
	selection_index = selection_index or self._equipped_selection
	local weap_unit = self._available_selections[selection_index].unit

	if alive(weap_unit) then
		weap_unit:base():remove_destroy_listener(self._listener_id)
	end

	self._available_selections[selection_index] = nil

	if self._equipped_selection == selection_index then
		self._equipped_selection = nil
	end

	if selection_index == self._selected_primary then
		self._selected_primary = self:_select_new_primary()
	end
end

function PlayerInventory:equip_latest_addition(instant)
	return self:equip_selection(self._latest_addition, instant)
end

function PlayerInventory:equip_selected_primary(instant)
	return self:equip_selection(self._selected_primary, instant)
end

function PlayerInventory:equip_next(instant)
	local i = self._selected_primary

	for i = self._selected_primary, self._selected_primary + 9 do
		local selection = 1 + math.mod(i, 10)

		if self._available_selections[selection] then
			return self:equip_selection(selection, instant)
		end
	end

	return false
end

function PlayerInventory:equip_previous(instant)
	local i = self._selected_primary

	for i = self._selected_primary, self._selected_primary - 9, -1 do
		local selection = 1 + math.mod(8 + i, 10)

		if self._available_selections[selection] then
			return self:equip_selection(selection, instant)
		end
	end

	return false
end

function PlayerInventory:equip_selection(selection_index, instant)
	if selection_index and selection_index ~= self._equipped_selection and self._available_selections[selection_index] then
		if self._equipped_selection then
			if self._equipped_selection == PlayerInventory.SLOT_1 or self._equipped_selection == PlayerInventory.SLOT_2 then
				managers.weapon_skills:deactivate_challenges_for_weapon(self:equipped_unit():base():get_name_id())
			end

			self:unequip_selection(nil, instant)
		end

		self._equipped_selection = selection_index

		self:_place_selection(selection_index, true)

		self._selected_primary = selection_index

		self:_send_equipped_weapon()

		if self:equipped_unit():base().fire_mode then
			managers.hud:set_firemode_for_weapon(self:equipped_unit():base():weapon_tweak_data().name_id, self:equipped_unit():base():fire_mode())
		end

		self:_call_listeners("equip")

		if self._unit:unit_data().mugshot_id then
			local hud_icon_id = self:equipped_unit():base():weapon_tweak_data().hud_icon

			managers.hud:set_mugshot_weapon(self._unit:unit_data().mugshot_id, hud_icon_id, self:equipped_unit():base():weapon_tweak_data().use_data.selection_index)
		end

		if self:equipped_unit():base().set_flashlight_enabled then
			self:equipped_unit():base():set_flashlight_enabled(true)
		end

		if not self._unit:brain() then
			if self:equipped_unit():base().out_of_ammo and self:equipped_unit():base():out_of_ammo() then
				managers.hud:set_prompt("hud_no_ammo_prompt", utf8.to_upper(managers.localization:text("hint_no_ammo")))
			elseif self:equipped_unit():base().can_reload and self:equipped_unit():base():can_reload() and self:equipped_unit():base().clip_empty and self:equipped_unit():base():clip_empty() then
				managers.hud:set_prompt("hud_reload_prompt", utf8.to_upper(managers.localization:text("hint_reload", {
					BTN_RELOAD = managers.localization:btn_macro("reload")
				})))
			else
				managers.hud:hide_prompt("hud_reload_prompt")
				managers.hud:hide_prompt("hud_no_ammo_prompt")
			end
		end

		if self._equipped_selection == PlayerInventory.SLOT_1 or self._equipped_selection == PlayerInventory.SLOT_2 then
			managers.weapon_skills:activate_current_challenges_for_weapon(self:equipped_unit():base():get_name_id())
		end

		return true
	end

	return false
end

function PlayerInventory:_send_equipped_weapon(send_equipped_weapon_type)
	send_equipped_weapon_type = send_equipped_weapon_type or PlayerInventory.SEND_WEAPON_TYPE_PLAYER_PRIMARY_SECONDARY
	local equipped_weapon_category_id = self:equipped_selection()
	local equipped_weapon_identifier = self:equipped_unit():base():get_name_id()

	if equipped_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID or equipped_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		send_equipped_weapon_type = PlayerInventory.SEND_WEAPON_TYPE_PLAYER_MELEE_GRENADE
	end

	if send_equipped_weapon_type == PlayerInventory.SEND_WEAPON_TYPE_TEAMAI_COPS then
		for i, weap_name in ipairs(tweak_data.character.weap_unit_names) do
			if weap_name == self:equipped_unit():name() then
				equipped_weapon_identifier = tostring(i)
			end
		end
	end

	local blueprint_string = self:equipped_unit():base().blueprint_to_string and self:equipped_unit():base():blueprint_to_string() or ""
	local cosmetics_string = ""
	local cosmetics_id = self:equipped_unit():base().get_cosmetics_id and self:equipped_unit():base():get_cosmetics_id() or nil

	if cosmetics_id then
		local cosmetics_quality = self:equipped_unit():base().get_cosmetics_quality and self:equipped_unit():base():get_cosmetics_quality() or nil
		local cosmetics_bonus = self:equipped_unit():base().get_cosmetics_bonus and self:equipped_unit():base():get_cosmetics_bonus() or nil
		local entry = tostring(cosmetics_id)
		local quality = "1"
		local bonus = cosmetics_bonus and "1" or "0"
		cosmetics_string = entry .. "-" .. quality .. "-" .. bonus
	else
		cosmetics_string = "nil-1-0"
	end

	self._unit:network():send("set_equipped_weapon", send_equipped_weapon_type, equipped_weapon_category_id, equipped_weapon_identifier, blueprint_string, cosmetics_string)
end

function PlayerInventory:unequip_selection(selection_index, instant)
	if not selection_index or selection_index == self._equipped_selection then
		if self:equipped_unit():base().set_flashlight_enabled then
			self:equipped_unit():base():set_flashlight_enabled(false)
		end

		selection_index = selection_index or self._equipped_selection

		self:_place_selection(selection_index, false)

		self._equipped_selection = nil

		self:_call_listeners("unequip")
	end
end

function PlayerInventory:is_equipped(index)
	return index == self._equipped_selection
end

function PlayerInventory:available_selections()
	return self._available_selections
end

function PlayerInventory:num_selections()
	return table.size(self._available_selections)
end

function PlayerInventory:_place_selection(selection_index, is_equip)
	local selection = self._available_selections[selection_index]
	local unit = selection.unit
	local weap_align_data = selection.use_data[is_equip and "equip" or "unequip"]
	local align_place = self._align_places[weap_align_data.align_place]

	if align_place then
		if is_equip then
			unit:set_enabled(true)
			unit:base():on_enabled()
		end

		local res = self:_link_weapon(unit, align_place)
	else
		unit:unlink()
		unit:set_enabled(false)
		unit:base():on_disabled()

		if unit:base().gadget_on and self._unit:movement().set_cbt_permanent then
			self._unit:movement():set_cbt_permanent(false)
		end
	end
end

function PlayerInventory:_link_weapon(unit, align_place)
	local parent_unit = align_place.on_body and self._unit or self._unit:camera()._camera_unit
	local res = parent_unit:link(align_place.obj3d_name, unit, unit:orientation_object():name())

	return res
end

function PlayerInventory:_select_new_primary()
	for index, use_data in pairs(self._available_selections) do
		return index
	end
end

function PlayerInventory:add_listener(key, events, clbk)
	events = events or self._all_event_types

	self._listener_holder:add(key, events, clbk)
end

function PlayerInventory:remove_listener(key)
	self._listener_holder:remove(key)
end

function PlayerInventory:_call_listeners(event)
	self._listener_holder:call(event, self._unit, event)
end

function PlayerInventory:on_death_exit()
	for i, selection in pairs(self._available_selections) do
		selection.unit:unlink()
	end
end

function PlayerInventory._chk_create_w_factory_indexes()
	if PlayerInventory._weapon_factory_indexed then
		return
	end

	local weapon_factory_indexed = {}
	PlayerInventory._weapon_factory_indexed = weapon_factory_indexed

	for id, data in pairs(tweak_data.weapon.factory) do
		if id ~= "parts" and data.unit then
			table.insert(weapon_factory_indexed, id)
		end
	end

	table.sort(weapon_factory_indexed, function (a, b)
		return a < b
	end)
end

function PlayerInventory._get_weapon_sync_index(wpn)
	local wanted_weap_name = wpn

	if wpn:key() and tweak_data.character.hack_weap_unit_names[wpn:key()] then
		wanted_weap_name = tweak_data.character.hack_weap_unit_names[wpn:key()]
	end

	if type_name(wanted_weap_name) == "Idstring" then
		for i, test_weap_name in ipairs(tweak_data.character.weap_unit_names) do
			if test_weap_name == wanted_weap_name then
				return i
			end
		end
	end

	PlayerInventory._chk_create_w_factory_indexes()

	local start_index = #tweak_data.character.weap_unit_names

	for i, factory_id in ipairs(PlayerInventory._weapon_factory_indexed) do
		if wanted_weap_name == factory_id then
			return start_index + i
		end
	end
end

function PlayerInventory._get_weapon_name_from_sync_index(w_index)
	if w_index <= #tweak_data.character.weap_unit_names then
		return tweak_data.character.weap_unit_names[w_index]
	end

	w_index = w_index - #tweak_data.character.weap_unit_names

	PlayerInventory._chk_create_w_factory_indexes()

	return PlayerInventory._weapon_factory_indexed[w_index]
end

function PlayerInventory:hide_equipped_unit()
	local unit = self._equipped_selection and self._available_selections[self._equipped_selection].unit

	if unit then
		self._was_gadget_on = unit:base().is_gadget_on and unit:base():is_gadget_on() or false

		unit:set_visible(false)
		unit:base():on_disabled()
	end
end

function PlayerInventory:show_equipped_unit()
	if self._equipped_selection and self._available_selections[self._equipped_selection].unit then
		self._available_selections[self._equipped_selection].unit:set_visible(true)
		self._available_selections[self._equipped_selection].unit:base():on_enabled()

		if self._was_gadget_on then
			self._available_selections[self._equipped_selection].unit:base():set_gadget_on(self._was_gadget_on)

			self._was_gadget_on = nil
		end
	end
end

function PlayerInventory:save(data)
	if self._equipped_selection then
		local eq_weap_name = self:equipped_unit():base()._factory_id or self:equipped_unit():name()
		local index = self._get_weapon_sync_index(eq_weap_name)
		data.equipped_weapon_index = index
		data.mask_visibility = self._mask_visibility
		data.blueprint_string = self:equipped_unit():base().blueprint_to_string and self:equipped_unit():base():blueprint_to_string() or nil
		data.gadget_on = self:equipped_unit():base().gadget_on and self:equipped_unit():base()._gadget_on
		local cosmetics_string = ""
		local cosmetics_id = self:equipped_unit():base().get_cosmetics_id and self:equipped_unit():base():get_cosmetics_id() or nil

		if cosmetics_id then
			local cosmetics_quality = self:equipped_unit():base().get_cosmetics_quality and self:equipped_unit():base():get_cosmetics_quality() or nil
			local cosmetics_bonus = self:equipped_unit():base().get_cosmetics_bonus and self:equipped_unit():base():get_cosmetics_bonus() or nil
			local entry = tostring(cosmetics_id)
			local quality = "1"
			local bonus = cosmetics_bonus and "1" or "0"
			cosmetics_string = entry .. "-" .. quality .. "-" .. bonus
		else
			cosmetics_string = "nil-1-0"
		end

		data.cosmetics_string = cosmetics_string
	end
end

function PlayerInventory:cosmetics_string_from_peer(peer, weapon_name)
	if peer then
		local outfit = peer:blackmarket_outfit()
		local cosmetics = outfit.primary.factory_id .. "_npc" == weapon_name and outfit.primary.cosmetics or outfit.secondary.factory_id .. "_npc" == weapon_name and outfit.secondary.cosmetics

		if cosmetics then
			local quality = "1"

			return cosmetics.id .. "-" .. quality .. "-" .. (cosmetics.bonus and "1" or "0")
		else
			return "nil-1-0"
		end
	end
end

function PlayerInventory:load(data)
	if data.equipped_weapon_index then
		self._weapon_add_clbk = "playerinventory_load"
		local delayed_data = {
			equipped_weapon_index = data.equipped_weapon_index,
			blueprint_string = data.blueprint_string,
			cosmetics_string = data.cosmetics_string,
			gadget_on = data.gadget_on
		}

		self:_clbk_weapon_add(delayed_data)
	end

	self._mask_visibility = data.mask_visibility and true or false
end

function PlayerInventory:_clbk_weapon_add(data)
	self._weapon_add_clbk = nil

	if not alive(self._unit) then
		return
	end

	local eq_weap_name = self._get_weapon_name_from_sync_index(data.equipped_weapon_index)

	if type(eq_weap_name) == "string" then
		self:add_unit_by_factory_name(eq_weap_name, true, true, data.blueprint_string, self:cosmetics_string_from_peer(managers.network:session():peer_by_unit(self._unit), eq_weap_name) or data.cosmetics_string)
		self:synch_weapon_gadget_state(data.gadget_on)
	else
		self._unit:inventory():add_unit_by_name(eq_weap_name, true, true)
	end

	if self._unit:unit_data().mugshot_id then
		local icon = self:equipped_unit():base():weapon_tweak_data().hud_icon

		managers.hud:set_mugshot_weapon(self._unit:unit_data().mugshot_id, icon, self:equipped_unit():base():weapon_tweak_data().use_data.selection_index)
	end
end

function PlayerInventory:set_melee_weapon(melee_weapon_id, is_npc)
	Application:debug("[PlayerInventory:set_melee_weapon]", melee_weapon_id, is_npc)

	self._melee_weapon_data = managers.blackmarket:get_melee_weapon_data(melee_weapon_id)

	if is_npc then
		if self._melee_weapon_data.third_unit then
			self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.third_unit)
		end
	elseif self._melee_weapon_data.unit then
		self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.unit)
	end

	if self._melee_weapon_unit_name then
		Application:debug("[PlayerInventory:set_melee_weapon] spawning melee", melee_weapon_id, self._melee_weapon_unit_name)
		managers.dyn_resource:load(Idstring("unit"), self._melee_weapon_unit_name, "packages/dyn_resources", false)

		local unit = World:spawn_unit(self._melee_weapon_unit_name, Vector3(), Rotation())

		self:add_unit(unit)
	end
end

function PlayerInventory:set_grenade(grenade)
	local unit_name = tweak_data.projectiles[grenade].unit_hand

	Application:debug("[PlayerInventory:set_grenade(grenade)] spawning grenade", grenade, unit_name)

	local unit = World:spawn_unit(Idstring(unit_name), Vector3(), Rotation())

	unit:base():set_thrower_unit(self._unit)
	unit:base():set_thrower_peer_id(managers.network:session():local_peer():id())
	unit:base():set_hand_held(true)
	self:add_unit(unit)

	self.equipped_grenade = grenade
end

function PlayerInventory:set_melee_weapon_by_peer(peer)
end

function PlayerInventory:set_ammo(ammo)
	for id, weapon in pairs(self._available_selections) do
		if weapon.unit:base():uses_ammo() then
			weapon.unit:base():set_ammo(ammo)
			managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
		end
	end
end

function PlayerInventory:set_ammo_with_empty_clip(ammo)
	for id, weapon in pairs(self._available_selections) do
		if weapon.unit:base():uses_ammo() then
			weapon.unit:base():set_ammo_with_empty_clip(ammo)
			managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
		end
	end
end

function PlayerInventory:need_ammo()
	for _, weapon in pairs(self._available_selections) do
		if weapon.unit:base():uses_ammo() and not weapon.unit:base():ammo_full() then
			return true
		end
	end

	return false
end

function PlayerInventory:all_out_of_ammo()
	for _, weapon in pairs(self._available_selections) do
		if weapon.unit:base():uses_ammo() and not weapon.unit:base():out_of_ammo() then
			return false
		end
	end

	return true
end

function PlayerInventory:anim_clbk_equip_exit(unit)
end

function PlayerInventory:set_visibility_state(state)
	for i, sel_data in pairs(self._available_selections) do
		sel_data.unit:base():set_visibility_state(state)
	end

	if alive(self._shield_unit) then
		self._shield_unit:set_visible(state)
	end
end

function PlayerInventory:set_weapon_enabled(state)
	if self._equipped_selection then
		self:equipped_unit():set_enabled(state)
	end

	if alive(self._shield_unit) then
		self._shield_unit:set_enabled(state)
	end
end
