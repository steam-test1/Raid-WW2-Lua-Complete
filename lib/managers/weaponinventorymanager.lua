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

function WeaponInventoryManager.get_instance()
	if not Global.weapon_inventory_manager then
		Global.weapon_inventory_manager = WeaponInventoryManager:new()

		Global.weapon_inventory_manager:setup()
	end

	setmetatable(Global.weapon_inventory_manager, WeaponInventoryManager)

	return Global.weapon_inventory_manager
end

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

function WeaponInventoryManager:setup()
	self.version_character_slot = WeaponInventoryManager.VERSION_CHARACTER_SLOT
	self.version_account_wide = WeaponInventoryManager.VERSION_ACCOUNT_WIDE
	self._weapons = {}

	self:_setup_initial_weapons()
	self:_setup_weapon_challenges()
	self:_setup_skins()
end

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

function WeaponInventoryManager:_setup_skins()
	self._owned_skins = {}
	self._applied_skins = {}
end

function WeaponInventoryManager:_setup_weapon_challenges()
	for _, skin_data in pairs(tweak_data.weapon.weapon_skins) do
		if skin_data.challenge then
			local challenge_tasks = {
				tweak_data.challenge[skin_data.challenge.id]
			}
			local challenge_data = {
				unlock = skin_data.name_id
			}

			if managers.challenge:challenge_exists(skin_data.challenge.category, skin_data.challenge.id) then
				local challenge = managers.challenge:get_challenge(skin_data.challenge.category, skin_data.challenge.id)
				local tasks = challenge:tasks()

				challenge:set_data(challenge_data)

				if not tasks or #tasks == 0 then
					challenge:set_tasks(challenge_tasks)
				end
			else
				managers.challenge:create_challenge(skin_data.challenge.category, skin_data.challenge.id, skin_data.challenge, challenge_tasks, nil, challenge_data)
			end
		end
	end
end

function WeaponInventoryManager:get_all_weapons_from_category(category_name)
	local category_data = self._categories[category_name]
	local result = {}

	for weapon_index, weapon_data in pairs(category_data.index_table) do
		table.insert(result, weapon_data)
	end

	return result
end

function WeaponInventoryManager:get_melee_weapon_loot_drop_candidates()
	local all_melee_weapons = self:get_all_weapons_from_category(WeaponInventoryManager.CATEGORY_NAME_MELEE)
	local result = {}

	for _, weapon_data in pairs(all_melee_weapons) do
		if weapon_data.droppable and not weapon_data.is_challenge_reward then
			table.insert(result, clone(weapon_data))
		end
	end

	return result
end

function WeaponInventoryManager:is_drop_inventory_complete_melee()
	local all_melee_weapons = self:get_all_weapons_from_category(WeaponInventoryManager.CATEGORY_NAME_MELEE)

	for _, weapon_data in pairs(all_melee_weapons) do
		local valid = weapon_data.droppable and not weapon_data.is_challenge_reward

		if valid and not self:is_melee_weapon_owned(weapon_data.weapon_id) then
			return false
		end
	end

	return true
end

function WeaponInventoryManager:add_melee_weapon_as_drop(drop)
	Application:trace("[WeaponInventoryManager:add_melee_weapon_as_drop] drop ", inspect(drop))

	self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE][drop.weapon_id].unlocked = true

	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_WEAPON_MELEE, {
		drop.weapon_id
	})
end

function WeaponInventoryManager:remove_melee_weapon_as_drop(drop)
	Application:trace("[WeaponInventoryManager:remove_melee_weapon_as_drop] drop ", inspect(drop))

	self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE][drop.weapon_id].unlocked = false
end

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

function WeaponInventoryManager:get_weapon_blueprint(bm_weapon_category_id, weapon_id)
	local weapon_slot = self:get_weapon_slot_by_weapon_id(weapon_id, bm_weapon_category_id)
	local bm_weapon_category_name = self:get_bm_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	local weapon_blueprint = managers.blackmarket:get_weapon_blueprint(bm_weapon_category_name, weapon_slot)

	return weapon_blueprint
end

function WeaponInventoryManager:get_weapon_default_blueprint(bm_weapon_category_id, weapon_id)
	local weapon_slot = self:get_weapon_slot_by_weapon_id(weapon_id, bm_weapon_category_id)
	local bm_weapon_category_name = self:get_bm_weapon_category_name_by_bm_category_id(bm_weapon_category_id)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local weapon_blueprint = tweak_data.weapon.factory[weapon_factory_id].default_blueprint

	return weapon_blueprint
end

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

function WeaponInventoryManager:save_profile_slot(data)
	local state = {
		version_account_wide = self.version_account_wide,
		melee_weapons = self._weapons[WeaponInventoryManager.CATEGORY_NAME_MELEE],
		owned_skins = self._owned_skins
	}
	data.WeaponInventoryManager = state
end

function WeaponInventoryManager:save(data)
	local state = {
		applied_skins = self._applied_skins
	}
	data.WeaponInventoryManager = state
end

function WeaponInventoryManager:load_profile_slot(data)
	self:setup()

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

	self._owned_skins = state.owned_skins or {}

	for skin_id, gold_price in pairs(self._owned_skins) do
		if not tweak_data.weapon.weapon_skins[skin_id] then
			self._owned_skins = nil
		end
	end
end

function WeaponInventoryManager:load(data)
	local state = data.WeaponInventoryManager
	self._applied_skins = state and state.applied_skins or {}

	for weapon_id, skin_id in pairs(self._applied_skins) do
		if not self:is_weapon_skin_owned(skin_id) then
			self._applied_skins[weapon_id] = nil
		end
	end
end

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

function WeaponInventoryManager:add_all_weapons_to_player_inventory()
	for _, weapon_data in pairs(tweak_data.weapon_inventory.weapon_primaries_index) do
		managers.blackmarket:on_buy_weapon_platform(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME, weapon_data.weapon_id, weapon_data.slot, true)
	end

	for _, weapon_data in pairs(tweak_data.weapon_inventory.weapon_secondaries_index) do
		managers.blackmarket:on_buy_weapon_platform(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME, weapon_data.weapon_id, weapon_data.slot, true)
	end
end

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

function WeaponInventoryManager:is_melee_weapon_owned(weapon_id)
	local melee_weapon_data = managers.weapon_inventory._weapons.melee_weapons[weapon_id]

	return melee_weapon_data and melee_weapon_data.unlocked or false
end

function WeaponInventoryManager:unlock_skin(skin_id)
	local skin_data = tweak_data.weapon.weapon_skins[skin_id]

	if not skin_data then
		return false
	end

	if skin_data.dlc and (type(skin_data.dlc) == "table" and not managers.dlc:is_any_dlc_unlocked(skin_data.dlc) or not managers.dlc:is_dlc_unlocked(skin_data.dlc)) then
		return false
	end

	if skin_data.gold_price and managers.gold_economy:current() < skin_data.gold_price then
		return false
	end

	self._owned_skins[skin_id] = skin_data.gold_price or 0
end

function WeaponInventoryManager:get_owned_weapon_skins()
	local result = {}
	local unlocked_items = tweak_data.dlc:get_unlocked_weapon_skins()

	for skin_id, skin_data in pairs(self._owned_skins) do
		local item_tweaks = tweak_data.weapon.weapon_skins[skin_id]

		if not item_tweaks.dlc or unlocked_items[skin_id] then
			table.insert(result, {
				owned = true,
				unlocked = true,
				skin_id = skin_id
			})
		end
	end

	return result
end

function WeaponInventoryManager:is_weapon_skin_owned(skin_id)
	local skin_data = tweak_data.weapon.weapon_skins[skin_id]

	if not skin_data then
		return false
	end

	if skin_data.dlc then
		if type(skin_data.dlc) == "table" then
			return managers.dlc:is_any_dlc_unlocked(skin_data.dlc)
		else
			return managers.dlc:is_dlc_unlocked(skin_data.dlc)
		end
	elseif self._owned_skins[skin_id] then
		return true
	elseif skin_data.challenge then
		local challenge = managers.challenge:get_challenge(skin_data.challenge.category, skin_data.challenge.id)

		return challenge and challenge:completed()
	end
end

function WeaponInventoryManager:set_weapons_skin(weapon_id, skin_id)
	Application:trace("[WeaponInventoryManager:set_weapons_skin]", weapon_id, skin_id)

	self._applied_skins[weapon_id] = skin_id
end

function WeaponInventoryManager:get_applied_weapon_skin(weapon_id)
	if not self._applied_skins then
		Application:trace("[WeaponInventoryManager:get_applied_weapon_skin] FAILED")

		return nil
	end

	local skin_id = self._applied_skins[weapon_id]

	if not skin_id then
		return
	end

	local skin_data = tweak_data.weapon.weapon_skins[skin_id]

	return skin_id, skin_data
end

function WeaponInventoryManager:get_weapon_skin_reward_by_rarity(rarity)
	local collection = {}

	for skin_id, skin_data in pairs(tweak_data.weapon.weapon_skins) do
		if skin_data.rarity == rarity and skin_data.droppable then
			local locked = skin_data.dlc or skin_data.challenge
			local owned = self:is_weapon_skin_owned(skin_id)

			if not locked and not owned then
				table.insert(collection, skin_id)
			end
		end
	end

	return collection
end

function WeaponInventoryManager:is_drop_inventory_complete_skins(rarity)
	for skin_id, skin_data in pairs(tweak_data.weapon.weapon_skins) do
		if (not rarity or skin_data.rarity == rarity) and skin_data.droppable then
			local locked = skin_data.dlc or skin_data.challenge
			local owned = self:is_weapon_skin_owned(skin_id)

			if not locked and not owned then
				return false
			end
		end
	end

	return true
end

function WeaponInventoryManager:add_weapon_skin_as_drop(drop)
	self._owned_skins[drop.skin_id] = 0

	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_WEAPON_SKIN, {
		drop.weapon_id,
		drop.skin_id
	})
end

function WeaponInventoryManager:get_owned_grenades()
	local result = {}

	if tweak_data.weapon_inventory.weapon_grenades_index then
		for index, weapon_data in pairs(tweak_data.weapon_inventory.weapon_grenades_index) do
			local weapon_stats = tweak_data.projectiles[weapon_data.weapon_id]
			weapon_data.unlocked = weapon_data.default or managers.upgrades:aquired(weapon_data.weapon_id)

			if weapon_data.challenge and weapon_data.unlocked then
				local challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_GENERIC, weapon_data.challenge)
				weapon_data.unlocked = challenge:completed()
			end

			if weapon_stats then
				table.insert(result, weapon_data)
			end
		end
	end

	return result
end

function WeaponInventoryManager:get_equipped_primary_weapon()
	return managers.blackmarket:equipped_item(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME)
end

function WeaponInventoryManager:get_equipped_secondary_weapon()
	return managers.blackmarket:equipped_item(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME)
end

function WeaponInventoryManager:get_equipped_primary_weapon_id()
	return self:get_equipped_primary_weapon().weapon_id
end

function WeaponInventoryManager:get_equipped_secondary_weapon_id()
	return self:get_equipped_secondary_weapon().weapon_id
end

function WeaponInventoryManager:get_equipped_melee_weapon_id()
	return managers.blackmarket:equipped_melee_weapon()
end

function WeaponInventoryManager:get_equipped_grenade_id()
	return managers.blackmarket:equipped_projectile()
end

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

function WeaponInventoryManager:get_weapon_stats(weapon_id, weapon_category, slot, blueprint)
	local equipped_mods = nil
	local silencer = false
	local single_mod = false
	local auto_mod = false
	blueprint = blueprint or managers.blackmarket:get_weapon_blueprint(weapon_category, slot)
	local bonus_stats = {}

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if equipped_mods then
			silencer = managers.weapon_factory:has_perk("silencer", factory_id, equipped_mods)
			single_mod = managers.weapon_factory:has_perk("fire_mode_single", factory_id, equipped_mods)
			auto_mod = managers.weapon_factory:has_perk("fire_mode_auto", factory_id, equipped_mods)
		end
	end

	local base_stats = self:_get_base_stats(weapon_id)
	local mods_stats = self:_get_mods_stats(weapon_id, base_stats, equipped_mods, bonus_stats)
	local skill_stats = self:_get_skill_stats(weapon_id, weapon_category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local clip_ammo, max_ammo, ammo_data = self:get_weapon_ammo_info(weapon_id, tweak_data.weapon[weapon_id].stats.extra_ammo, base_stats.totalammo.index + mods_stats.totalammo.index)
	base_stats.totalammo.value = ammo_data.base
	mods_stats.totalammo.value = ammo_data.mod
	skill_stats.totalammo.value = ammo_data.skill
	skill_stats.totalammo.skill_in_effect = ammo_data.skill_in_effect
	local my_clip = base_stats.magazine.value + mods_stats.magazine.value + skill_stats.magazine.value

	if max_ammo < my_clip then
		mods_stats.magazine.value = mods_stats.magazine.value + max_ammo - my_clip
	end

	return base_stats, mods_stats, skill_stats
end

function WeaponInventoryManager:get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod)
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value(weapon_tweak_data.category, "extra_ammo_multiplier", 1)

	local function get_ammo_max_per_clip(weapon_id)
		local function upgrade_blocked(category, upgrade)
			if not weapon_tweak_data.upgrade_blocks then
				return false
			end

			if not weapon_tweak_data.upgrade_blocks[category] then
				return false
			end

			return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
		end

		local clip_base = weapon_tweak_data.CLIP_AMMO_MAX
		local clip_mod = extra_ammo and tweak_data.weapon.stats.extra_ammo[extra_ammo] or 0

		return clip_base + clip_mod
	end

	local ammo_max_per_clip = get_ammo_max_per_clip(weapon_id)
	local ammo_max = tweak_data.weapon[weapon_id].AMMO_MAX
	local ammo_from_mods = ammo_max * (total_ammo_mod and tweak_data.weapon.stats.total_ammo_mod[total_ammo_mod] or 0)
	ammo_max = (ammo_max + ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_data = {
		base = tweak_data.weapon[weapon_id].AMMO_MAX,
		mod = ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip
	}
	ammo_data.skill = (ammo_data.base + ammo_data.mod) * ammo_max_multiplier - ammo_data.base - ammo_data.mod
	ammo_data.skill_in_effect = managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or managers.player:has_category_upgrade(weapon_tweak_data.category, "extra_ammo_multiplier")

	return ammo_max_per_clip, ammo_max, ammo_data
end

function WeaponInventoryManager:_get_base_stats(name)
	local base_stats = {}
	local index = nil
	local tweak_stats = tweak_data.weapon.stats
	local modifier_stats = tweak_data.weapon[name].stats_modifiers
	self._stats_shown = {
		{
			round_value = true,
			stat_name = "extra_ammo",
			name = "magazine"
		},
		{
			round_value = true,
			stat_name = "total_ammo_mod",
			name = "totalammo"
		},
		{
			name = "fire_rate",
			round_value = true
		},
		{
			name = "damage"
		},
		{
			revert = true,
			name = "spread",
			visual_multiplier = 0.5,
			percent = true,
			one_minus = true
		},
		{
			revert = true,
			percent = true,
			name = "recoil",
			offset = true
		},
		{
			name = "concealment",
			index = true
		},
		{
			name = "suppression",
			offset = true
		}
	}

	for _, stat in pairs(self._stats_shown) do
		base_stats[stat.name] = {}

		if stat.name == "damage" then
			if tweak_data.weapon[name].damage_profile then
				base_stats[stat.name].value = tweak_data.weapon[name].damage_profile[1].damage
			end
		elseif stat.name == "magazine" then
			base_stats[stat.name].index = 0
			base_stats[stat.name].value = tweak_data.weapon[name].CLIP_AMMO_MAX
		elseif stat.name == "totalammo" then
			index = math.clamp(tweak_data.weapon[name].stats.total_ammo_mod, 1, #tweak_stats.total_ammo_mod)
			base_stats[stat.name].index = tweak_data.weapon[name].stats.total_ammo_mod
			base_stats[stat.name].value = tweak_data.weapon[name].AMMO_MAX
		elseif stat.name == "fire_rate" then
			local fire_rate = 60 / tweak_data.weapon[name].fire_mode_data.fire_rate
			base_stats[stat.name].value = fire_rate / 10 * 10
		elseif tweak_stats[stat.name] then
			index = math.clamp(tweak_data.weapon[name].stats[stat.name], 1, #tweak_stats[stat.name])
			base_stats[stat.name].index = index
			base_stats[stat.name].value = stat.index and index or tweak_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier
			local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

			if stat.offset then
				base_stats[stat.name].value = base_stats[stat.name].value - offset
			end

			if stat.revert then
				local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					max_stat = max_stat - offset
				end

				base_stats[stat.name].value = max_stat - base_stats[stat.name].value
			end

			if modifier_stats and modifier_stats[stat.name] then
				local mod = modifier_stats[stat.name]

				if stat.revert and not stat.index then
					local real_base_value = tweak_stats[stat.name][index]
					local modded_value = real_base_value * mod
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

					if stat.offset then
						modded_value = modded_value - offset
					end

					local max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]])

					if stat.offset then
						max_stat = max_stat - offset
					end

					local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

					if mod ~= 0 and (tweak_stats[stat.name][1] < modded_value or modded_value < tweak_stats[stat.name][#tweak_stats[stat.name]]) then
						new_value = (new_value + base_stats[stat.name].value / mod) / 2
					end

					base_stats[stat.name].value = new_value
				else
					base_stats[stat.name].value = base_stats[stat.name].value * mod
				end
			end

			if stat.percent then
				local value = base_stats[stat.name].value
				local max_stat = tweak_stats[stat.name][#tweak_stats[stat.name]]

				if stat.index then
					max_stat = #tweak_stats[stat.name]
				elseif stat.revert then
					max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end
				end

				local ratio = base_stats[stat.name].value / max_stat
				base_stats[stat.name].value = ratio * 100
			end
		end
	end

	return base_stats
end

function WeaponInventoryManager:_get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local mods_stats = {}
	local modifier_stats = tweak_data.weapon[name].stats_modifiers

	for _, stat in pairs(self._stats_shown) do
		mods_stats[stat.name] = {
			index = 0,
			value = 0
		}
	end

	if equipped_mods then
		local tweak_stats = tweak_data.weapon.stats
		local tweak_factory = tweak_data.weapon.factory.parts
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if bonus_stats then
			for _, stat in pairs(self._stats_shown) do
				if stat.name == "magazine" then
					local ammo = mods_stats[stat.name].index
					ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
					mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0)
				elseif stat.name == "totalammo" then
					local ammo = bonus_stats.total_ammo_mod
					mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
				else
					mods_stats[stat.name].index = mods_stats[stat.name].index + (bonus_stats[stat.name] or 0)
				end
			end
		end

		local part_data = nil

		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data then
				for _, stat in pairs(self._stats_shown) do
					if part_data.stats then
						if stat.name == "magazine" then
							local ammo = part_data.stats.extra_ammo
							ammo = ammo and ammo + (tweak_data.weapon[name].stats.extra_ammo or 0)
							mods_stats[stat.name].value = mods_stats[stat.name].value + (ammo and tweak_data.weapon.stats.extra_ammo[ammo] or 0)
						elseif stat.name == "totalammo" then
							local ammo = part_data.stats.total_ammo_mod
							mods_stats[stat.name].index = mods_stats[stat.name].index + (ammo or 0)
						else
							mods_stats[stat.name].index = mods_stats[stat.name].index + (part_data.stats[stat.name] or 0)
						end
					end
				end
			end
		end

		local index, stat_name = nil

		for _, stat in pairs(self._stats_shown) do
			stat_name = stat.name

			if mods_stats[stat.name].index and base_stats[stat.name].index and tweak_stats[stat_name] then
				if stat.name == "concealment" then
					index = base_stats[stat.name].index + mods_stats[stat.name].index
				else
					index = math.clamp(base_stats[stat.name].index + mods_stats[stat.name].index, 1, #tweak_stats[stat_name])
				end

				mods_stats[stat.name].value = stat.index and index or tweak_stats[stat_name][index] * tweak_data.gui.stats_present_multiplier
				local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) * tweak_data.gui.stats_present_multiplier

				if stat.offset then
					mods_stats[stat.name].value = mods_stats[stat.name].value - offset
				end

				if stat.revert then
					local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]]) * tweak_data.gui.stats_present_multiplier

					if stat.offset then
						max_stat = max_stat - offset
					end

					mods_stats[stat.name].value = max_stat - mods_stats[stat.name].value
				end

				if modifier_stats and modifier_stats[stat.name] then
					local mod = modifier_stats[stat.name]

					if stat.revert and not stat.index then
						local real_base_value = tweak_stats[stat_name][index]
						local modded_value = real_base_value * mod
						local offset = math.min(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

						if stat.offset then
							modded_value = modded_value - offset
						end

						local max_stat = math.max(tweak_stats[stat_name][1], tweak_stats[stat_name][#tweak_stats[stat_name]])

						if stat.offset then
							max_stat = max_stat - offset
						end

						local new_value = (max_stat - modded_value) * tweak_data.gui.stats_present_multiplier

						if mod ~= 0 and (tweak_stats[stat_name][1] < modded_value or modded_value < tweak_stats[stat_name][#tweak_stats[stat_name]]) then
							new_value = (new_value + mods_stats[stat.name].value / mod) / 2
						end

						mods_stats[stat.name].value = new_value
					else
						mods_stats[stat.name].value = mods_stats[stat.name].value * mod
					end
				end

				if stat.percent then
					local value = mods_stats[stat.name].value
					local max_stat = tweak_stats[stat.name][#tweak_stats[stat.name]]

					if stat.index then
						max_stat = #tweak_stats[stat.name]
					elseif stat.revert then
						max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

						if stat.offset then
							max_stat = max_stat - offset
						end
					end

					local ratio = mods_stats[stat.name].value / max_stat
					mods_stats[stat.name].value = ratio * 100
				end

				mods_stats[stat.name].value = mods_stats[stat.name].value - base_stats[stat.name].value
			end
		end
	end

	return mods_stats
end

function WeaponInventoryManager:_get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local tweak_stats = tweak_data.weapon.stats
	local skill_stats = {}

	for _, stat in pairs(self._stats_shown) do
		skill_stats[stat.name] = {
			value = 0
		}
	end

	local detection_risk = 0

	if category then
		local custom_data = {
			[category] = managers.blackmarket:get_crafted_category_slot(category, slot)
		}
		detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data(custom_data, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection_risk = detection_risk * 100
	end

	local base_value, base_index, modifier, multiplier = nil
	local weapon_tweak = tweak_data.weapon[name]

	for _, stat in ipairs(self._stats_shown) do
		if weapon_tweak.stats[stat.stat_name or stat.name] or stat.name == "totalammo" or stat.name == "fire_rate" or stat.name == "damage" then
			if stat.name == "magazine" then
				local selection_index = weapon_tweak.use_data.selection_index
				local selection_category = selection_index == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID and "primary_weapon" or "secondary_weapon"
				local weapon_category = weapon_tweak.category
				local guess_upg_category = managers.player:upgrade_value(weapon_category, "magazine_upgrade", 0)

				if guess_upg_category ~= 0 then
					Application:debug("[BlackMarketManager:_get_skill_stats] Using class type", weapon_category, guess_upg_category)

					skill_stats[stat.name].value = skill_stats[stat.name].value + guess_upg_category
				else
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value(selection_category, "magazine_upgrade", 0)
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks[weapon_category] or not table.contains(weapon_tweak.upgrade_blocks[weapon_category], "clipazines_magazine_upgrade") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value(weapon_category, "clipazines_magazine_upgrade", 0)
				end
			elseif stat.name ~= "totalammo" then
				base_value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value, 0)

				if base_stats[stat.name].index and mods_stats[stat.name].index then
					base_index = base_stats[stat.name].index + mods_stats[stat.name].index
				end

				multiplier = 1
				modifier = 0

				if stat.name == "damage" then
					multiplier = managers.blackmarket:damage_multiplier(name, weapon_tweak.category, silencer, detection_risk, nil, blueprint)
					modifier = math.floor(managers.blackmarket:damage_addend(name, weapon_tweak.category, silencer, detection_risk, nil, blueprint) * multiplier)
				elseif stat.name == "spread" then
					local fire_mode = single_mod and "single" or auto_mod and "auto" or weapon_tweak.FIRE_MODE or "single"
					multiplier = managers.blackmarket:accuracy_multiplier(name, weapon_tweak.category, silencer, nil, nil, fire_mode, blueprint)
					modifier = managers.blackmarket:accuracy_addend(name, weapon_tweak.category, base_index, silencer, nil, fire_mode, blueprint) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "recoil" then
					multiplier = managers.blackmarket:recoil_multiplier(name, weapon_tweak.category, silencer, blueprint)
					modifier = managers.blackmarket:recoil_addend(name, weapon_tweak.category, base_index, silencer, blueprint) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "suppression" then
					multiplier = managers.blackmarket:threat_multiplier(name, weapon_tweak.category, silencer)
				elseif stat.name == "concealment" then
					-- Nothing
				elseif stat.name == "fire_rate" then
					multiplier = managers.blackmarket:fire_rate_multiplier(name, weapon_tweak.category, silencer, detection_risk, nil, blueprint)
				end

				if modifier ~= 0 then
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.revert then
						modifier = -modifier
					end

					if stat.percent then
						local max_stat = tweak_stats[stat.name][#tweak_stats[stat.name]]

						if stat.index then
							max_stat = #tweak_stats[stat.name]
						elseif stat.revert then
							max_stat = math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

							if stat.offset then
								max_stat = max_stat - offset
							end
						end

						local ratio = modifier / max_stat
						modifier = ratio * 100
					end
				end

				if stat.revert then
					if stat.one_minus then
						multiplier = 1 + 1 - multiplier
					else
						multiplier = 1 / math.max(multiplier, 0.01)
					end
				end

				skill_stats[stat.name].skill_in_effect = multiplier ~= 1 or modifier ~= 0
				skill_stats[stat.name].value = (modifier + base_value * multiplier - base_value) * (stat.visual_multiplier or 1)
			end
		end
	end

	return skill_stats
end

function WeaponInventoryManager:get_melee_weapon_stats(weapon_id)
	return self:_get_melee_weapon_stats(weapon_id)
end

function WeaponInventoryManager:_get_melee_weapon_stats(name)
	self._mweapon_stats_shown = {
		{
			name = "damage",
			range = true
		},
		{
			range = true,
			name = "damage_effect",
			multiple_of = "damage"
		},
		{
			inverse = true,
			num_decimals = 1,
			name = "charge_time",
			suffix = managers.localization:text("menu_seconds_suffix_short")
		},
		{
			name = "range",
			range = true
		},
		{
			name = "concealment",
			index = true
		}
	}
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local stats_data = managers.blackmarket:get_melee_weapon_stats(name)
	local multiple_of = {}
	local has_non_special = managers.player:has_category_upgrade("player", "non_special_melee_multiplier")
	local has_special = managers.player:has_category_upgrade("player", "boxer_melee_damage_multiplier")
	local non_special = managers.player:upgrade_value("player", "non_special_melee_multiplier", 1) - 1
	local special = managers.player:upgrade_value("player", "boxer_melee_damage_multiplier", 1) - 1

	for i, stat in ipairs(self._mweapon_stats_shown) do
		local skip_rounding = stat.num_decimals
		base_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		mods_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		skill_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}

		if stat.name == "damage" then
			local base_min = stats_data.min_damage
			local base_max = stats_data.max_damage
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1)
			local skill_mul = dmg_mul * ((has_non_special and has_special and math.max(non_special, special) or 0) + 1) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			skill_stats[stat.name] = {
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "damage_effect" then
			local base_min = stats_data.min_damage_effect
			local base_max = stats_data.max_damage_effect
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1) - 1
			local enf_skill = has_non_special and has_special and math.max(non_special, special) or 0
			local gst_skill = managers.player:upgrade_value("player", "holdbarred_melee_knockdown_multiplier", 1) - 1
			local skill_mul = (1 + dmg_mul) * (1 + enf_skill) * (1 + gst_skill) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			skill_stats[stat.name] = {
				skill_min = skill_min,
				skill_max = skill_max,
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "charge_time" then
			local base = stats_data.charge_time
			base_stats[stat.name] = {
				value = base,
				min_value = base,
				max_value = base
			}
		elseif stat.name == "range" then
			local base_min = stats_data.range
			local base_max = stats_data.range
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
		elseif stat.name == "concealment" then
			local base = managers.blackmarket:_calculate_melee_weapon_concealment(name)
			local skill = managers.blackmarket:concealment_modifier("melee_weapons")
			base_stats[stat.name] = {
				min_value = base,
				max_value = base,
				value = base
			}
			skill_stats[stat.name] = {
				min_value = skill,
				max_value = skill,
				value = skill,
				skill_in_effect = skill > 0
			}
		end

		if stat.multiple_of then
			table.insert(multiple_of, {
				stat.name,
				stat.multiple_of
			})
		end

		base_stats[stat.name].real_value = base_stats[stat.name].value
		mods_stats[stat.name].real_value = mods_stats[stat.name].value
		skill_stats[stat.name].real_value = skill_stats[stat.name].value
		base_stats[stat.name].real_min_value = base_stats[stat.name].min_value
		mods_stats[stat.name].real_min_value = mods_stats[stat.name].min_value
		skill_stats[stat.name].real_min_value = skill_stats[stat.name].min_value
		base_stats[stat.name].real_max_value = base_stats[stat.name].max_value
		mods_stats[stat.name].real_max_value = mods_stats[stat.name].max_value
		skill_stats[stat.name].real_max_value = skill_stats[stat.name].max_value
	end

	for i, data in ipairs(multiple_of) do
		local multiplier = data[1]
		local stat = data[2]
		base_stats[multiplier].min_value = base_stats[stat].real_min_value * base_stats[multiplier].real_min_value
		base_stats[multiplier].max_value = base_stats[stat].real_max_value * base_stats[multiplier].real_max_value
		base_stats[multiplier].value = (base_stats[multiplier].min_value + base_stats[multiplier].max_value) / 2
	end

	for i, stat in ipairs(self._mweapon_stats_shown) do
		if not stat.index then
			if skill_stats[stat.name].value and base_stats[stat.name].value then
				skill_stats[stat.name].value = base_stats[stat.name].value * skill_stats[stat.name].value
				base_stats[stat.name].value = base_stats[stat.name].value
			end

			if skill_stats[stat.name].min_value and base_stats[stat.name].min_value then
				skill_stats[stat.name].min_value = base_stats[stat.name].min_value * skill_stats[stat.name].min_value
				base_stats[stat.name].min_value = base_stats[stat.name].min_value
			end

			if skill_stats[stat.name].max_value and base_stats[stat.name].max_value then
				skill_stats[stat.name].max_value = base_stats[stat.name].max_value * skill_stats[stat.name].max_value
				base_stats[stat.name].max_value = base_stats[stat.name].max_value
			end
		end
	end

	return base_stats, mods_stats, skill_stats
end
