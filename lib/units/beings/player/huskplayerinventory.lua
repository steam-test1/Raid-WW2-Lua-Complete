HuskPlayerInventory = HuskPlayerInventory or class(PlayerInventory)

-- Lines 4-10
function HuskPlayerInventory:init(unit)
	HuskPlayerInventory.super.init(self, unit)

	self._align_places.right_hand = {
		on_body = true,
		obj3d_name = Idstring("a_weapon_right_front")
	}
	self._align_places.left_hand = {
		on_body = true,
		obj3d_name = Idstring("a_weapon_left_front")
	}
	self._peer_weapons = {}
end

-- Lines 14-15
function HuskPlayerInventory:_send_equipped_weapon()
end

-- Lines 20-60
function HuskPlayerInventory:synch_equipped_weapon(send_equipped_weapon_type, equipped_weapon_category_id, equipped_weapon_identifier, blueprint_string, cosmetics_string, peer)
	local weapon_name = ""

	if send_equipped_weapon_type == PlayerInventory.SEND_WEAPON_TYPE_PLAYER_PRIMARY_SECONDARY then
		weapon_name = managers.weapon_factory:get_factory_id_by_weapon_id(equipped_weapon_identifier)
		weapon_name = weapon_name .. "_npc"

		self:add_unit_by_factory_name(weapon_name, true, true, blueprint_string, self:cosmetics_string_from_peer(peer, weapon_name) or cosmetics_string)
	elseif send_equipped_weapon_type == PlayerInventory.SEND_WEAPON_TYPE_PLAYER_MELEE_GRENADE then
		if equipped_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
			local grenade_data = tweak_data.projectiles[equipped_weapon_identifier]
			weapon_name = Idstring(grenade_data.unit_dummy)

			self:add_unit_by_name(weapon_name, true, true)
		elseif equipped_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
			local melee_data = tweak_data.blackmarket.melee_weapons[equipped_weapon_identifier]
			weapon_name = Idstring(melee_data.third_unit)

			self:add_unit_by_name(weapon_name, true, true)
		end
	elseif send_equipped_weapon_type == PlayerInventory.SEND_WEAPON_TYPE_TEAMAI_COPS then
		weapon_name = tweak_data.character.weap_unit_names[tonumber(equipped_weapon_identifier)]

		self:add_unit_by_name(weapon_name, true, true)
	end
end

-- Lines 62-79
function HuskPlayerInventory:check_peer_weapon_spawn()
	if SystemInfo:platform() ~= Idstring("PS3") then
		return true
	end

	local next_in_line = self._peer_weapons[1]

	if next_in_line then
		if type(next_in_line) == "table" then
			print("[HuskPlayerInventory:check_peer_weapon_spawn()] Adding weapon to inventory.", inspect(next_in_line))
			self:add_unit_by_factory_blueprint(unpack(next_in_line))
		else
			print("[HuskPlayerInventory:check_peer_weapon_spawn()] waiting")
		end

		table.remove(self._peer_weapons, 1)
	else
		return true
	end
end

-- Lines 83-88
function HuskPlayerInventory:set_melee_weapon_by_peer(peer)
	local blackmarket_outfit = peer and peer:blackmarket_outfit()

	if blackmarket_outfit then
		self:set_melee_weapon(blackmarket_outfit.melee_weapon, true)
	end
end

-- Lines 92-108
function HuskPlayerInventory:add_unit_by_name(new_unit_name, equip, instant)
	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), new_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), new_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = false,
		autoaim = false,
		alert_AI = false,
		user_sound_variant = "1"
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)
end

-- Lines 110-114
function HuskPlayerInventory:add_unit_by_factory_name(factory_name, equip, instant, blueprint_string, cosmetics_string)
	local blueprint = managers.weapon_factory:unpack_blueprint_from_string(factory_name, blueprint_string)

	self:add_unit_by_factory_blueprint(factory_name, equip, instant, blueprint)
end

-- Lines 116-146
function HuskPlayerInventory:add_unit_by_factory_blueprint(factory_name, equip, instant, blueprint, cosmetics)
	local factory_weapon = tweak_data.weapon.factory[factory_name]

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), Idstring(factory_weapon.unit), DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
		print("[HuskPlayerInventory:add_unit_by_factory_blueprint]", "Weapon unit is not loaded, force loading it.", factory_weapon.unit)
		managers.dyn_resource:load(Idstring("unit"), Idstring(factory_weapon.unit), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
	end

	local new_unit = World:spawn_unit(Idstring(factory_weapon.unit), Vector3(), Rotation())

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	new_unit:base():check_npc()

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = false,
		autoaim = false,
		alert_AI = false,
		user_sound_variant = "1"
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun()
	end
end

-- Lines 148-157
function HuskPlayerInventory:synch_weapon_gadget_state(state)
	if self:equipped_unit():base().set_gadget_on then
		self:equipped_unit():base():set_gadget_on(state, true)

		if state and state > 0 then
			self._unit:movement():set_cbt_permanent(true)
		else
			self._unit:movement():set_cbt_permanent(false)
		end
	end
end

-- Lines 161-172
function HuskPlayerInventory:on_melee_item_shown()
	local selection = self._available_selections[self._equipped_selection]

	if not selection then
		return
	end

	if selection.use_data.equip.align_place == "left_hand" and alive(selection.unit) then
		self:_link_weapon(selection.unit, self._align_places.right_hand)
	end
end

-- Lines 174-184
function HuskPlayerInventory:on_melee_item_hidden()
	local selection = self._available_selections[self._equipped_selection]

	if not selection then
		return
	end

	if selection.use_data.equip.align_place == "left_hand" and alive(selection.unit) then
		self:_link_weapon(selection.unit, self._align_places.left_hand)
	end
end

-- Lines 188-203
function HuskPlayerInventory._get_weapon_name_from_sync_index(w_index)
	if w_index <= #tweak_data.character.weap_unit_names then
		return tweak_data.character.weap_unit_names[w_index]
	end

	w_index = w_index - #tweak_data.character.weap_unit_names

	HuskPlayerInventory._chk_create_w_factory_indexes()

	local fps_id = PlayerInventory._weapon_factory_indexed[w_index]

	if tweak_data.weapon.factory[fps_id .. "_npc"] then
		return fps_id .. "_npc"
	else
		return fps_id
	end
end
