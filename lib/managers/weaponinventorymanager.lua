WeaponInventoryManager = WeaponInventoryManager or class()
WeaponInventoryManager.VERSION_CHARACTER_SLOT = 1
WeaponInventoryManager.VERSION_ACCOUNT_WIDE = 23
WeaponInventoryManager.SAVE_TYPE_CHARACTER = "save_character"
WeaponInventoryManager.SAVE_TYPE_ACCOUNT = "save_account"
WeaponInventoryManager.DEFAULT_MELEE_WEAPON = "m3_knife"
WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID = tweak_data.WEAPON_SLOT_SECONDARY
WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID = tweak_data.WEAPON_SLOT_PRIMARY
WeaponInventoryManager.BM_CATEGORY_GRENADES_ID = tweak_data.WEAPON_SLOT_GRENADE
WeaponInventoryManager.BM_CATEGORY_MELEE_ID = tweak_data.WEAPON_SLOT_MELEE
WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME = "primaries"
WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME = "secondaries"
WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME = "grenades"
WeaponInventoryManager.BM_CATEGORY_MELEE_NAME = "melee_weapons"
WeaponInventoryManager.CATEGORY_NAME_PRIMARY = "primary_weapons"
WeaponInventoryManager.CATEGORY_NAME_SECONDARY = "secondary_weapons"
WeaponInventoryManager.CATEGORY_NAME_GRENADES = "grenades"
WeaponInventoryManager.CATEGORY_NAME_MELEE = "melee_weapons"

-- Lines 37-46
function WeaponInventoryManager.get_instance()
	if not Global.weapon_inventory_manager then
		Global.weapon_inventory_manager = WeaponInventoryManager:new()

		Global.weapon_inventory_manager:setup()
	end

	setmetatable(Global.weapon_inventory_manager, WeaponInventoryManager)

	return Global.weapon_inventory_manager
end

-- Lines 48-85
function WeaponInventoryManager:init()
	self._categories = {
		[WeaponInventoryManager.CATEGORY_NAME_MELEE] = {
			save = WeaponInventoryManager.SAVE_TYPE_ACCOUNT,
			bm_name = WeaponInventoryManager.BM_CATEGORY_MELEE_NAME,
			bm_id = WeaponInventoryManager.BM_CATEGORY_MELEE_ID,
			index_table = tweak_data.weapon_inventory.weapon_melee_index
		}
	}
end

-- Lines 87-96
function WeaponInventoryManager:setup()
	self.version_character_slot = WeaponInventoryManager.VERSION_CHARACTER_SLOT
	self.version_account_wide = WeaponInventoryManager.VERSION_ACCOUNT_WIDE
	self._weapons = {}

	self:_setup_initial_weapons()
	self:_setup_initial_weapon_skins()
end

-- Lines 98-155
function WeaponInventoryManager:_setup_initial_weapons()
	local unlocked_melee_weapons = tweak_data.dlc:get_unlocked_melee_weapons()

	for category_name, category_data in pairs(self._categories) do
		self._weapons[category_name] = {}

		for _, weapon_data in pairs(category_data.index_table) do
			if category_name == WeaponInventoryManager.CATEGORY_NAME_MELEE then
				local weapon_id = weapon_data.weapon_id
				local weapon_tweaks = tweak_data.blackmarket.melee_weapons[weapon_id]

				if weapon_data.default then
					self._weapons[category_name][weapon_id] = {
						owned = true,
						unlocked = true,
						slot = weapon_data.slot,
						droppable = weapon_data.droppable,
						redeemed_xp = weapon_data.redeemed_xp,
						default = weapon_data.default,
						is_challenge_reward = weapon_data.is_challenge_reward
					}
				elseif weapon_tweaks.dlc and unlocked_melee_weapons[weapon_data.weapon_id] then
					self._weapons[category_name][weapon_id] = {
						owned = true,
						unlocked = true,
						slot = weapon_data.slot,
						droppable = weapon_data.droppable,
						redeemed_xp = weapon_data.redeemed_xp,
						default = weapon_data.default,
						is_challenge_reward = weapon_data.is_challenge_reward
					}
				else
					self._weapons[category_name][weapon_id] = {
						owned = true,
						unlocked = false,
						slot = weapon_data.slot,
						droppable = weapon_data.droppable,
						redeemed_xp = weapon_data.redeemed_xp,
						default = weapon_data.default,
						is_challenge_reward = weapon_data.is_challenge_reward
					}
				end
			end
		end
	end
end

-- Lines 157-160
function WeaponInventoryManager:_setup_initial_weapon_skins()
	self._weapon_skins = {
		_applied = {}
	}
end

-- Lines 166-177
function WeaponInventoryManager:get_all_weapons_from_category(category_name)
	local category_data = self._categories[category_name]
	local result = {}

	for weapon_index, weapon_data in pairs(category_data.index_table) do
		table.insert(result, weapon_data)
	end

	return result
end

-- Lines 181-194
function WeaponInventoryManager:get_melee_weapon_loot_drop_candidates()
	local all_melee_weapons = self:get_all_weapons_from_category(WeaponInventoryManager.CATEGORY_NAME_MELEE)
	local result = {}

	for weapon_index, weapon_data in pairs(all_melee_weapons) do
		if weapon_data.droppable then
			table.insert(result, clone(weapon_data))
		end
	end

	return result
end

-- Lines 199-205
function WeaponInventoryManager:add_melee_weapon_as_drop(drop)
	Application:trace("[WeaponInventoryManager:add_melee_weapon_as_drop] drop ", inspect(drop))

	self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE][drop.weapon_id].unlocked = true

	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_WEAPON_MELEE, {
		drop.weapon_id
	})
end

-- Lines 209-213
function WeaponInventoryManager:remove_melee_weapon_as_drop(drop)
	Application:trace("[WeaponInventoryManager:remove_melee_weapon_as_drop] drop ", inspect(drop))

	self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE][drop.weapon_id].unlocked = false
end

-- Lines 217-227
function WeaponInventoryManager:get_weapon_data(weapon_category_name, weapon_id)
	local result = nil
	local weapon_category_data = self._categories[weapon_category_name]

	for _, weapon_data in pairs(weapon_category_data.index_table) do
		if weapon_data.weapon_id == weapon_id then
			result = weapon_data
		end
	end

	return result
end

-- Lines 230-237
function WeaponInventoryManager:get_weapon_blueprint(bm_weapon_category_id, weapon_id)
	local weapon_slot = self:get_weapon_slot_by_weapon_id(weapon_id, bm_weapon_category_id)
	local bm_weapon_category_name = self:get_bm_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	local weapon_blueprint = managers.blackmarket:get_weapon_blueprint(bm_weapon_category_name, weapon_slot)

	return weapon_blueprint
end

-- Lines 240-248
function WeaponInventoryManager:get_weapon_default_blueprint(bm_weapon_category_id, weapon_id)
	local weapon_slot = self:get_weapon_slot_by_weapon_id(weapon_id, bm_weapon_category_id)
	local bm_weapon_category_name = self:get_bm_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local weapon_blueprint = tweak_data.weapon.factory[weapon_factory_id].default_blueprint

	return weapon_blueprint
end

-- Lines 252-262
function WeaponInventoryManager:get_weapon_category_name_by_bm_category_name(bm_weapon_category_name)
	if bm_weapon_category_name == WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME then
		return WeaponInventoryManager.CATEGORY_NAME_PRIMARY
	elseif bm_weapon_category_name == WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME then
		return WeaponInventoryManager.CATEGORY_NAME_SECONDARY
	elseif bm_weapon_category_name == WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME then
		return WeaponInventoryManager.CATEGORY_NAME_GRENADES
	elseif bm_weapon_category_name == WeaponInventoryManager.BM_CATEGORY_MELEE_NAME then
		return WeaponInventoryManager.CATEGORY_NAME_MELEE
	end
end

-- Lines 264-274
function WeaponInventoryManager:get_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	if bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		return WeaponInventoryManager.CATEGORY_NAME_PRIMARY
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		return WeaponInventoryManager.CATEGORY_NAME_SECONDARY
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		return WeaponInventoryManager.CATEGORY_NAME_GRENADES
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		return WeaponInventoryManager.CATEGORY_NAME_MELEE
	end
end

-- Lines 276-286
function WeaponInventoryManager:get_bm_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	if bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		return WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		return WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		return WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		return WeaponInventoryManager.BM_CATEGORY_MELEE_NAME
	end
end

-- Lines 290-297
function WeaponInventoryManager:save_account_wide_info(data)
	local state = {
		version_account_wide = self.version_account_wide,
		melee_weapons = self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE],
		weapon_skins = self._weapon_skins
	}
	data.WeaponInventoryManager = state
end

-- Lines 299-352
function WeaponInventoryManager:load_account_wide_info(data, version_account_wide)
	self:setup(true)

	local state = data.WeaponInventoryManager

	if not state then
		return
	end

	self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE] = state.melee_weapons

	for index, melee_weapon_data in ipairs(tweak_data.weapon_inventory.weapon_melee_index) do
		local weapon_id = melee_weapon_data.weapon_id

		if not self._weapons.melee_weapons[weapon_id] then
			self._weapons.melee_weapons[weapon_id] = {
				owned = true,
				unlocked = false,
				slot = melee_weapon_data.slot,
				droppable = melee_weapon_data.droppable,
				redeemed_xp = melee_weapon_data.redeemed_xp,
				default = melee_weapon_data.default,
				is_challenge_reward = melee_weapon_data.is_challenge_reward
			}

			managers.savefile:set_resave_required()
		end
	end

	local unlocked_melee_weapons = tweak_data.dlc:get_unlocked_melee_weapons()
	local locked_melee_weapons = tweak_data.dlc:get_locked_melee_weapons()

	for weapon_id, melee_weapon in pairs(self._weapons.melee_weapons) do
		local weapon_tweaks = tweak_data.blackmarket.melee_weapons[weapon_id]

		if weapon_tweaks.dlc then
			if unlocked_melee_weapons[weapon_id] then
				melee_weapon.unlocked = true
				melee_weapon.owned = true
			elseif locked_melee_weapons[weapon_id] then
				melee_weapon.unlocked = false
				melee_weapon.owned = false
			end
		end
	end

	self._weapon_skins = state.weapon_skins
end

-- Lines 357-363
function WeaponInventoryManager:get_weapon_category_by_weapon_category_id(weapon_category_id)
	if weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		return WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		return WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		return WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		return WeaponInventoryManager.BM_CATEGORY_MELEE_NAME
	end
end

-- Lines 365-373
function WeaponInventoryManager:add_all_weapons_to_player_inventory()
	for _, weapon_data in pairs(tweak_data.weapon_inventory.weapon_primaries_index) do
		managers.blackmarket:on_buy_weapon_platform(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME, weapon_data.weapon_id, weapon_data.slot, true)
	end

	for _, weapon_data in pairs(tweak_data.weapon_inventory.weapon_secondaries_index) do
		managers.blackmarket:on_buy_weapon_platform(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME, weapon_data.weapon_id, weapon_data.slot, true)
	end
end

-- Lines 376-393
function WeaponInventoryManager:get_weapon_slot_by_weapon_id(weapon_id, bm_weapon_category_id)
	local weapon_source = {}

	if bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		weapon_source = tweak_data.weapon_inventory.weapon_primaries_index
	elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		weapon_source = tweak_data.weapon_inventory.weapon_secondaries_index
	end

	if weapon_source then
		for _, weapon_data in ipairs(weapon_source) do
			if weapon_data.weapon_id == weapon_id then
				return weapon_data.slot
			end
		end
	end

	return 0
end

-- Lines 396-426
function WeaponInventoryManager:get_owned_weapons(weapon_category_id)
	local result = {}
	local data_source = {}

	if weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		data_source = tweak_data.weapon_inventory.weapon_primaries_index
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		data_source = tweak_data.weapon_inventory.weapon_secondaries_index
	end

	local unlocked_weapons = tweak_data.dlc:get_unlocked_weapons()

	for index, weapon_data in pairs(data_source) do
		local weapon_tweaks = tweak_data.weapon[weapon_data.weapon_id]

		if weapon_tweaks and (not weapon_tweaks.dlc or unlocked_weapons[weapon_data.weapon_id]) then
			weapon_data.unlocked = managers.upgrades:aquired(weapon_data.weapon_id)

			if weapon_tweaks and weapon_tweaks.use_data and weapon_tweaks.use_data.selection_index and weapon_tweaks.use_data.selection_index == weapon_category_id then
				table.insert(result, weapon_data)
			end
		end
	end

	return result
end

-- Lines 431-457
function WeaponInventoryManager:get_owned_melee_weapons()
	local result = {}
	local unlocked_weapons = tweak_data.dlc:get_unlocked_melee_weapons()

	if self._weapons.melee_weapons then
		for weapon_id, weapon_data in pairs(self._weapons.melee_weapons) do
			local weapon_tweaks = tweak_data.blackmarket.melee_weapons[weapon_id]

			if not weapon_tweaks.dlc or unlocked_weapons[weapon_id] then
				local unlocked = weapon_data.unlocked or unlocked_weapons[weapon_id]

				table.insert(result, {
					weapon_id = weapon_id,
					owned = weapon_data.owned,
					unlocked = unlocked,
					slot = weapon_data.slot,
					droppable = weapon_data.droppable,
					redeemed_xp = weapon_data.redeemed_xp,
					default = weapon_data.default,
					is_challenge_reward = weapon_data.is_challenge_reward
				})
			end
		end
	end

	return result
end

-- Lines 459-464
function WeaponInventoryManager:is_melee_weapon_owned(weapon_id)
	local melee_weapon_data = managers.weapon_inventory._weapons.melee_weapons[weapon_id]

	return melee_weapon_data and melee_weapon_data.unlocked or false
end

-- Lines 468-488
function WeaponInventoryManager:get_owned_weapon_skins()
	local result = {}
	local unlocked_items = tweak_data.dlc:get_unlocked_weapon_skins()

	if self._weapon_skins then
		for skin_id, skin_data in pairs(self._weapon_skins) do
			local item_tweaks = tweak_data.weapon.weapon_skins[skin_id]

			if not item_tweaks.dlc or unlocked_items[skin_id] then
				table.insert(result, {
					skin_id = skin_id,
					owned = skin_data.owned,
					unlocked = skin_data.unlocked or unlocked_items[skin_id]
				})
			end
		end
	end

	return result
end

-- Lines 490-495
function WeaponInventoryManager:is_weapon_skin_owned(skin_id)
	Application:trace("[WeaponInventoryManager:is_weapon_skin_owned]")

	local item_data = managers.weapon_inventory._weapon_skins[skin_id]

	return item_data and item_data.unlocked or false
end

-- Lines 497-506
function WeaponInventoryManager:set_weapons_skin(weapon_factory_id, skin_id)
	Application:trace("[WeaponInventoryManager:set_weapons_skin]", weapon_factory_id, skin_id)

	if not managers.weapon_inventory._weapon_skins or not managers.weapon_inventory._weapon_skins._applied then
		managers.weapon_inventory._weapon_skins = {
			_applied = {}
		}
	end

	managers.weapon_inventory._weapon_skins._applied[weapon_factory_id] = skin_id
end

-- Lines 508-519
function WeaponInventoryManager:get_weapons_skin(factory_id)
	if not managers.weapon_inventory._weapon_skins or not managers.weapon_inventory._weapon_skins._applied then
		Application:trace("[WeaponInventoryManager:get_weapons_skin] FAILED")

		return nil
	end

	local skin = managers.weapon_inventory._weapon_skins._applied[factory_id]

	return skin
end

-- Lines 523-544
function WeaponInventoryManager:get_owned_grenades()
	local result = {}

	if tweak_data.weapon_inventory.weapon_grenades_index then
		for index, weapon_data in pairs(tweak_data.weapon_inventory.weapon_grenades_index) do
			local weapon_stats = tweak_data.projectiles[weapon_data.weapon_id]
			weapon_data.unlocked = weapon_data.default or managers.upgrades:aquired(weapon_data.weapon_id)

			if weapon_stats then
				table.insert(result, weapon_data)
			end
		end
	end

	return result
end

-- Lines 546-548
function WeaponInventoryManager:get_equipped_primary_weapon()
	return managers.blackmarket:equipped_item(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME)
end

-- Lines 550-552
function WeaponInventoryManager:get_equipped_secondary_weapon()
	return managers.blackmarket:equipped_item(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME)
end

-- Lines 554-556
function WeaponInventoryManager:get_equipped_primary_weapon_id()
	return self:get_equipped_primary_weapon().weapon_id
end

-- Lines 558-560
function WeaponInventoryManager:get_equipped_secondary_weapon_id()
	return self:get_equipped_secondary_weapon().weapon_id
end

-- Lines 562-564
function WeaponInventoryManager:get_equipped_melee_weapon_id()
	return managers.blackmarket:equipped_melee_weapon()
end

-- Lines 566-568
function WeaponInventoryManager:get_equipped_grenade_id()
	return managers.blackmarket:equipped_projectile()
end

-- Lines 570-586
function WeaponInventoryManager:equip_weapon(weapon_category_id, item_data)
	if weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		managers.blackmarket:equip_weapon(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME, item_data.slot)
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		managers.blackmarket:equip_weapon(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME, item_data.slot)
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		managers.blackmarket:equip_melee_weapon(item_data.weapon_id)
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		managers.blackmarket:equip_grenade(item_data.weapon_id)
	end
end

-- Lines 589-595
function WeaponInventoryManager:get_weapon_stats(weapon_id, weapon_category, slot, blueprint)
	return managers.blackmarket:_get_stats(weapon_id, weapon_category, slot, blueprint)
end

-- Lines 597-600
function WeaponInventoryManager:get_melee_weapon_stats(weapon_id)
	return managers.blackmarket:_get_melee_weapon_stats(weapon_id)
end
