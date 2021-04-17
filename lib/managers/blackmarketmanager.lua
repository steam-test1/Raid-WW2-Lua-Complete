BlackMarketManager = BlackMarketManager or class()
BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID = "thompson"
BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID = "m1911"
BlackMarketManager.DEFAULT_PRIMARY_FACTORY_ID = "wpn_fps_smg_thompson"
BlackMarketManager.DEFAULT_SECONDARY_FACTORY_ID = "wpn_fps_pis_m1911"
local INV_TO_CRAFT = Idstring("inventory_to_crafted")
local CRAFT_TO_INV = Idstring("crafted_to_inventroy")
local CRAFT_ADD = Idstring("add_to_crafted")
local CRAFT_REMOVE = Idstring("remove_from_crafted")

function BlackMarketManager:init()
	self:_setup()
end

function BlackMarketManager:_setup()
	self._defaults = {
		character = "american",
		armor = "level_1",
		preferred_character = "american",
		grenade = "m24",
		melee_weapon = "m3_knife"
	}

	if not Global.blackmarket_manager then
		Global.blackmarket_manager = {}

		self:_setup_armors()
		self:_setup_weapons()
		self:_setup_characters()
		self:_setup_unlocked_weapon_slots()
		self:_setup_grenades()
		self:_setup_melee_weapons()

		Global.blackmarket_manager.crafted_items = {}
	end

	self._global = Global.blackmarket_manager
	self._preloading_list = {}
	self._preloading_index = 0
	self._category_resource_loaded = {}
end

function BlackMarketManager:init_finalize()
	print("BlackMarketManager:init_finalize()")
	managers.network.account:inventory_load()
end

function BlackMarketManager:_setup_armors()
	local armors = {}
	Global.blackmarket_manager.armors = armors

	for armor, _ in pairs(tweak_data.blackmarket.armors) do
		armors[armor] = {
			owned = false,
			unlocked = false,
			equipped = false
		}
	end

	armors[self._defaults.armor].owned = true
	armors[self._defaults.armor].equipped = true
	armors[self._defaults.armor].unlocked = true
end

function BlackMarketManager:_setup_grenades()
	local grenades = {}
	Global.blackmarket_manager.grenades = grenades

	for grenade_id, grenade in pairs(tweak_data.projectiles) do
		if grenade.throwable then
			grenades[grenade_id] = {
				equipped = false,
				amount = 0,
				unlocked = true,
				skill_based = false,
				level = 0
			}
			local is_default, weapon_level = managers.upgrades:get_value(grenade_id, self._defaults.grenade)
			grenades[grenade_id].level = weapon_level
			grenades[grenade_id].skill_based = not is_default and weapon_level == 0 and not tweak_data.projectiles[grenade_id].dlc
		end
	end

	grenades[self._defaults.grenade].equipped = false
	grenades[self._defaults.grenade].unlocked = true
	grenades[self._defaults.grenade].amount = 0
end

function BlackMarketManager:_setup_melee_weapons()
	local melee_weapons = {}
	Global.blackmarket_manager.melee_weapons = melee_weapons

	for melee_weapon, _ in pairs(tweak_data.blackmarket.melee_weapons) do
		melee_weapons[melee_weapon] = {
			unlocked = true,
			owned = true,
			durability = 1,
			equipped = false,
			skill_based = false,
			level = 0
		}
	end

	melee_weapons[self._defaults.melee_weapon].unlocked = true
	melee_weapons[self._defaults.melee_weapon].equipped = true
	melee_weapons[self._defaults.melee_weapon].owned = true
	melee_weapons[self._defaults.melee_weapon].level = 0
end

function BlackMarketManager:_setup_characters()
	local characters = {}
	Global.blackmarket_manager.characters = characters

	for character, _ in pairs(tweak_data.blackmarket.characters) do
		characters[character] = {
			owned = true,
			unlocked = true,
			equipped = false
		}
	end

	characters[self._defaults.character].owned = true
	characters[self._defaults.character].equipped = true
	Global.blackmarket_manager._preferred_character = self._defaults.preferred_character
	Global.blackmarket_manager._preferred_characters = {
		Global.blackmarket_manager._preferred_character
	}
end

function BlackMarketManager:_setup_unlocked_weapon_slots()
	local unlocked_weapon_slots = {}
	Global.blackmarket_manager.unlocked_weapon_slots = unlocked_weapon_slots
	unlocked_weapon_slots.primaries = unlocked_weapon_slots.primaries or {}
	unlocked_weapon_slots.secondaries = unlocked_weapon_slots.secondaries or {}

	for i = 1, #tweak_data.weapon_inventory.weapon_primaries_index do
		unlocked_weapon_slots.primaries[i] = true
	end

	for i = 1, #tweak_data.weapon_inventory.weapon_secondaries_index do
		unlocked_weapon_slots.secondaries[i] = true
	end
end

function BlackMarketManager:_setup_weapons()
	local weapons = {}
	Global.blackmarket_manager.weapons = weapons

	for weapon, data in pairs(tweak_data.weapon) do
		if data.autohit then
			local selection_index = data.use_data.selection_index
			local equipped = weapon == managers.player:weapon_in_slot(selection_index)
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon)
			weapons[weapon] = {
				owned = true,
				unlocked = true,
				factory_id = factory_id,
				selection_index = selection_index
			}
			local is_default, weapon_level, got_parent = managers.upgrades:get_value(weapon)
			weapons[weapon].level = weapon_level
			weapons[weapon].skill_based = got_parent or not is_default and weapon_level == 0 and not tweak_data.weapon[weapon].global_value
		end
	end
end

BlackMarketManager.weapons_to_buy = {
	mac11 = true,
	raging_bull = true
}

function BlackMarketManager:weapon_unlocked(weapon_id)
	return Global.blackmarket_manager.weapons[weapon_id].unlocked
end

function BlackMarketManager:weapon_unlocked_by_crafted(category, slot)
	local crafted = self._global.crafted_items[category][slot]
	local weapon_id = crafted.weapon_id
	local unlocked = Global.blackmarket_manager.weapons[weapon_id].unlocked

	return unlocked
end

function BlackMarketManager:weapon_level(weapon_id)
	for level, level_data in pairs(tweak_data.upgrades.level_tree) do
		for _, upgrade in ipairs(level_data.upgrades) do
			if upgrade == weapon_id then
				return level
			end
		end
	end

	return 0
end

function BlackMarketManager:equipped_item(category)
	if category == "primaries" then
		return self:equipped_primary()
	elseif category == "secondaries" then
		return self:equipped_secondary()
	elseif category == "character" then
		return self:equipped_character()
	elseif category == "armors" then
		return self:equipped_armor()
	elseif category == "melee_weapons" then
		return self:equipped_melee_weapon()
	elseif category == "grenades" then
		return self:equipped_grenade()
	end
end

function BlackMarketManager:equipped_character()
	for character_id, data in pairs(tweak_data.blackmarket.characters) do
		if Global.blackmarket_manager.characters[character_id].equipped then
			return character_id
		end
	end
end

function BlackMarketManager:equipped_deployable()
	return managers.player and managers.player:equipment_in_slot(1)
end

function BlackMarketManager:equipped_armor(chk_armor_kit, chk_player_state)
	if chk_player_state and managers.player:current_state() == "civilian" then
		return self._defaults.armor
	end

	if chk_armor_kit then
		local equipped_deployable = Global.player_manager.kit.equipment_slots[1]

		if equipped_deployable == "armor_kit" and (not managers.player:has_equipment(equipped_deployable) or managers.player:has_deployable_left(equipped_deployable)) then
			return self._defaults.armor
		end
	end

	local armor = nil

	for armor_id, data in pairs(tweak_data.blackmarket.armors) do
		armor = Global.blackmarket_manager.armors[armor_id]

		if armor.equipped and armor.unlocked and armor.owned then
			return armor_id
		end
	end

	return self._defaults.armor
end

function BlackMarketManager:equipped_projectile()
	return self:equipped_grenade()
end

function BlackMarketManager:equipped_grenade()
	local grenade = nil

	for grenade_id, data in pairs(tweak_data.projectiles) do
		grenade = Global.blackmarket_manager.grenades[grenade_id]

		if data.throwable and grenade.equipped and grenade.unlocked then
			return grenade_id, grenade.amount or 0
		end
	end

	return self._defaults.grenade, Global.blackmarket_manager.grenades[self._defaults.grenade].amount
end

function BlackMarketManager:equipped_melee_weapon()
	local melee_weapon = nil

	for melee_weapon_id, data in pairs(tweak_data.blackmarket.melee_weapons) do
		melee_weapon = Global.blackmarket_manager.melee_weapons[melee_weapon_id]

		if melee_weapon.equipped and melee_weapon.unlocked then
			return melee_weapon_id
		end
	end

	return self._defaults.melee_weapon
end

function BlackMarketManager:equipped_melee_weapon_damage_info(lerp_value)
	lerp_value = lerp_value or 0
	local melee_entry = self:equipped_melee_weapon()
	local stats = tweak_data.blackmarket.melee_weapons[melee_entry].stats
	local dmg = math.lerp(stats.min_damage, stats.max_damage, lerp_value)
	local dmg_effect = dmg * math.lerp(stats.min_damage_effect, stats.max_damage_effect, lerp_value)

	return dmg, dmg_effect
end

function BlackMarketManager:equipped_secondary()
	if not Global.blackmarket_manager.crafted_items.secondaries then
		return
	end

	for slot, data in pairs(Global.blackmarket_manager.crafted_items.secondaries) do
		if data.equipped then
			return data
		end
	end
end

function BlackMarketManager:equipped_primary()
	if not Global.blackmarket_manager.crafted_items.primaries then
		return
	end

	for slot, data in pairs(Global.blackmarket_manager.crafted_items.primaries) do
		if data.equipped then
			return data
		end
	end
end

function BlackMarketManager:equipped_weapon_slot(category)
	if not Global.blackmarket_manager.crafted_items[category] then
		return nil
	end

	for slot, data in pairs(Global.blackmarket_manager.crafted_items[category]) do
		if data.equipped then
			return slot
		end
	end

	return nil
end

function BlackMarketManager:equipped_armor_slot()
	if not Global.blackmarket_manager.armors then
		return nil
	end

	for slot, data in pairs(Global.blackmarket_manager.armors) do
		if data.equipped then
			return slot
		end
	end

	return nil
end

function BlackMarketManager:equipped_grenade_slot()
	if not Global.blackmarket_manager.grenades then
		return nil
	end

	for slot, data in pairs(Global.blackmarket_manager.grenades) do
		if data.equipped then
			return slot
		end
	end

	return nil
end

function BlackMarketManager:equipped_melee_weapon_slot()
	if not Global.blackmarket_manager.melee_weapons then
		return nil
	end

	for slot, data in pairs(Global.blackmarket_manager.melee_weapons) do
		if data.equipped then
			return slot
		end
	end

	return nil
end

function BlackMarketManager:equip_weapon(category, slot)
	if not Global.blackmarket_manager.crafted_items[category] then
		return false
	end

	for s, data in pairs(Global.blackmarket_manager.crafted_items[category]) do
		data.equipped = s == slot
	end

	if managers.blackmarket._menu_crate_unit and managers.blackmarket._menu_crate_unit:menu_crate_ext() then
		local data = category == "primaries" and self:equipped_primary() or self:equipped_secondary()

		managers.blackmarket._menu_crate_unit:menu_crate_ext():set_weapon(nil, data.factory_id, data.blueprint, category == "primaries" and "primary" or "secondary")
	end

	MenuCallbackHandler:_update_outfit_information()
	managers.statistics:publish_equipped_to_steam()

	if managers.hud then
		managers.hud:recreate_weapon_firemode(HUDManager.PLAYER_PANEL)
	end

	return true
end

function BlackMarketManager:equip_deployable(deployable_id, loading)
	Global.player_manager.kit.equipment_slots[1] = deployable_id

	if not loading then
		MenuCallbackHandler:_update_outfit_information()
	end

	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:equip_character(character_id)
	for s, data in pairs(Global.blackmarket_manager.characters) do
		data.equipped = s == character_id
	end

	MenuCallbackHandler:_update_outfit_information()
	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:equip_armor(armor_id)
	for s, data in pairs(Global.blackmarket_manager.armors) do
		data.equipped = s == armor_id
	end

	MenuCallbackHandler:_update_outfit_information()
	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:equip_grenade(grenade_id)
	for s, data in pairs(Global.blackmarket_manager.grenades) do
		data.equipped = s == grenade_id
	end

	MenuCallbackHandler:_update_outfit_information()
	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:equip_melee_weapon(melee_weapon_id)
	for s, data in pairs(Global.blackmarket_manager.melee_weapons) do
		data.equipped = s == melee_weapon_id
	end

	MenuCallbackHandler:_update_outfit_information()
	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:_outfit_string_mask()
	local s = ""
	s = s .. " " .. "none"
	s = s .. " " .. "nothing"
	s = s .. " " .. "no_color_no_material"
	s = s .. " " .. "plastic"

	return s
end

function BlackMarketManager:outfit_string_index(type)
	if type == "armor" then
		return 5
	end

	if type == "character" then
		return 6
	end

	if type == "primary" then
		return 7
	end

	if type == "primary_blueprint" then
		return 8
	end

	if type == "secondary" then
		return 9
	end

	if type == "secondary_blueprint" then
		return 10
	end

	if type == "deployable" then
		return 11
	end

	if type == "deployable_amount" then
		return 12
	end

	if type == "concealment_modifier" then
		return 13
	end

	if type == "melee_weapon" then
		return 14
	end

	if type == "grenade" then
		return 15
	end

	if type == "skills" then
		return 16
	end

	if type == "primary_cosmetics" then
		return 17
	end

	if type == "secondary_cosmetics" then
		return 18
	end

	if type == "character_customization_head" then
		return 19
	end

	if type == "character_customization_upper" then
		return 20
	end

	if type == "character_customization_lower" then
		return 21
	end

	if type == "character_customization_nationality" then
		return 22
	end
end

function BlackMarketManager:unpack_outfit_from_string(outfit_string)
	local data = string.split(outfit_string or "", " ")
	local outfit = {
		character = data[self:outfit_string_index("character")] or self._defaults.character
	}
	local armor_string = data[self:outfit_string_index("armor")] or tostring(self._defaults.armor)
	local armor_data = string.split(armor_string, "-")
	outfit.armor = armor_data[1]
	outfit.armor_current = armor_data[2] or outfit.armor
	outfit.armor_current_state = armor_data[3] or outfit.armor_current
	outfit.primary = {
		factory_id = data[self:outfit_string_index("primary")] or BlackMarketManager.DEFAULT_PRIMARY_FACTORY_ID
	}
	local primary_blueprint_string = data[self:outfit_string_index("primary_blueprint")]

	if primary_blueprint_string then
		primary_blueprint_string = string.gsub(primary_blueprint_string, "_", " ")
		outfit.primary.blueprint = managers.weapon_factory:unpack_blueprint_from_string(outfit.primary.factory_id, primary_blueprint_string)
	else
		outfit.primary.blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(outfit.primary.factory_id)
	end

	outfit.secondary = {
		factory_id = data[self:outfit_string_index("secondary")] or BlackMarketManager.DEFAULT_SECONDARY_FACTORY_ID
	}
	local secondary_blueprint_string = data[self:outfit_string_index("secondary_blueprint")]

	if secondary_blueprint_string then
		secondary_blueprint_string = string.gsub(secondary_blueprint_string, "_", " ")
		outfit.secondary.blueprint = managers.weapon_factory:unpack_blueprint_from_string(outfit.secondary.factory_id, secondary_blueprint_string)
	else
		outfit.secondary.blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(outfit.secondary.factory_id)
	end

	outfit.melee_weapon = data[self:outfit_string_index("melee_weapon")] or self._defaults.melee_weapon
	outfit.grenade = data[self:outfit_string_index("grenade")] or self._defaults.grenade
	outfit.deployable = data[self:outfit_string_index("deployable")] or nil
	outfit.deployable_amount = tonumber(data[self:outfit_string_index("deployable_amount")] or "0")
	outfit.concealment_modifier = data[self:outfit_string_index("concealment_modifier")] or 0
	outfit.skills = managers.skilltree:unpack_from_string(data[self:outfit_string_index("skills")])
	outfit.character_customization_head = data[self:outfit_string_index("character_customization_head")]
	outfit.character_customization_upper = data[self:outfit_string_index("character_customization_upper")]
	outfit.character_customization_lower = data[self:outfit_string_index("character_customization_lower")]
	outfit.character_customization_nationality = data[self:outfit_string_index("character_customization_nationality")]

	return outfit
end

function BlackMarketManager:outfit_string()
	local s = ""
	s = s .. self:_outfit_string_mask()
	local armor_id = tostring(self:equipped_armor(false))
	local current_armor_id = tostring(self:equipped_armor(true))
	local current_state_armor_id = tostring(self:equipped_armor(true, true))
	s = s .. " " .. armor_id .. "-" .. current_armor_id .. "-" .. current_state_armor_id

	for character_id, data in pairs(tweak_data.blackmarket.characters) do
		if Global.blackmarket_manager.characters[character_id].equipped then
			s = s .. " " .. character_id
		end
	end

	local equipped_primary = self:equipped_primary()

	if equipped_primary then
		local primary_string = managers.weapon_factory:blueprint_to_string(equipped_primary.factory_id, equipped_primary.blueprint)
		primary_string = string.gsub(primary_string, " ", "_")
		s = s .. " " .. equipped_primary.factory_id .. " " .. primary_string
	else
		s = s .. " " .. "nil" .. " " .. "0"
	end

	local equipped_secondary = self:equipped_secondary()

	if equipped_secondary then
		local secondary_string = managers.weapon_factory:blueprint_to_string(equipped_secondary.factory_id, equipped_secondary.blueprint)
		secondary_string = string.gsub(secondary_string, " ", "_")
		s = s .. " " .. equipped_secondary.factory_id .. " " .. secondary_string
	else
		s = s .. " " .. "nil" .. " " .. "0"
	end

	local equipped_deployable = Global.player_manager.kit.equipment_slots[1]

	if equipped_deployable then
		s = s .. " " .. tostring(equipped_deployable)
		local deployable_tweak_data = tweak_data.equipments[equipped_deployable]
		local amount = (deployable_tweak_data.quantity or 0) + managers.player:equiptment_upgrade_value(equipped_deployable, "quantity")
		s = s .. " " .. tostring(amount)
	else
		s = s .. " " .. "nil" .. " " .. "0"
	end

	local concealment_modifier = -self:visibility_modifiers() or 0
	s = s .. " " .. tostring(concealment_modifier)
	local equipped_melee_weapon = self:equipped_melee_weapon()
	s = s .. " " .. tostring(equipped_melee_weapon)
	local equipped_grenade = self:equipped_grenade()
	s = s .. " " .. tostring(equipped_grenade)
	s = s .. " " .. tostring(managers.skilltree:pack_to_string())

	if equipped_primary and equipped_primary.cosmetics then
		local entry = tostring(equipped_primary.cosmetics.id)
		local quality = "1"
		local bonus = equipped_primary.cosmetics.bonus and "1" or "0"
		s = s .. " " .. entry .. "-" .. quality .. "-" .. bonus
	else
		s = s .. " " .. "nil-1-0"
	end

	if equipped_secondary and equipped_secondary.cosmetics then
		local entry = tostring(equipped_secondary.cosmetics.id)
		local quality = "1"
		local bonus = equipped_secondary.cosmetics.bonus and "1" or "0"
		s = s .. " " .. entry .. "-" .. quality .. "-" .. bonus
	else
		s = s .. " " .. "nil-1-0"
	end

	s = s .. " " .. managers.player:get_customization_equiped_head_name()
	s = s .. " " .. managers.player:get_customization_equiped_upper_name()
	s = s .. " " .. managers.player:get_customization_equiped_lower_name()
	s = s .. " " .. managers.player:get_character_profile_nation()

	return s
end

function BlackMarketManager:outfit_string_from_list(outfit)
	local s = ""
	s = s .. outfit.mask.mask_id
	s = s .. " " .. outfit.mask.blueprint.color.id
	s = s .. " " .. outfit.mask.blueprint.pattern.id
	s = s .. " " .. outfit.mask.blueprint.material.id
	s = s .. " " .. outfit.armor .. "-" .. outfit.armor_current .. "-" .. outfit.armor_current_state
	s = s .. " " .. outfit.character
	local primary_string = managers.weapon_factory:blueprint_to_string(outfit.primary.factory_id, outfit.primary.blueprint)
	primary_string = string.gsub(primary_string, " ", "_")
	s = s .. " " .. outfit.primary.factory_id .. " " .. primary_string
	local secondary_string = managers.weapon_factory:blueprint_to_string(outfit.secondary.factory_id, outfit.secondary.blueprint)
	secondary_string = string.gsub(secondary_string, " ", "_")
	s = s .. " " .. outfit.secondary.factory_id .. " " .. secondary_string
	local equipped_deployable = outfit.deployable

	if equipped_deployable then
		s = s .. " " .. outfit.deployable
		s = s .. " " .. tostring(outfit.deployable_amount)
	else
		s = s .. " " .. "nil" .. " " .. "0"
	end

	s = s .. " " .. tostring(outfit.concealment_modifier)
	s = s .. " " .. tostring(outfit.melee_weapon)
	s = s .. " " .. tostring(outfit.grenade)
	s = s .. " " .. managers.skilltree:pack_to_string_from_list(outfit.skills)

	if outfit.primary.cosmetics then
		local entry = tostring(outfit.primary.cosmetics.id)
		local quality = "1"
		local bonus = outfit.primary.cosmetics.bonus and "1" or "0"
		s = s .. " " .. entry .. "-" .. quality .. "-" .. bonus
	else
		s = s .. " " .. "nil-1-0"
	end

	if outfit.secondary.cosmetics then
		local entry = tostring(outfit.secondary.cosmetics.id)
		local quality = "1"
		local bonus = outfit.secondary.cosmetics.bonus and "1" or "0"
		s = s .. " " .. entry .. "-" .. quality .. "-" .. bonus
	else
		s = s .. " " .. "nil-1-0"
	end

	s = s .. " " .. managers.player:get_customization_equiped_head_name()
	s = s .. " " .. managers.player:get_customization_equiped_upper_name()
	s = s .. " " .. managers.player:get_customization_equiped_lower_name()
	s = s .. " " .. managers.player:get_character_profile_nation()

	return s
end

function BlackMarketManager:signature()
	return managers.network.account:inventory_outfit_signature()
end

function BlackMarketManager:load_equipped_weapons()
	local weapon = self:equipped_primary()

	managers.weapon_factory:preload_blueprint(weapon.factory_id, weapon.blueprint, false, callback(self, self, "resource_loaded_callback", "primaries"), false)

	local weapon = self:equipped_secondary()

	managers.weapon_factory:preload_blueprint(weapon.factory_id, weapon.blueprint, false, callback(self, self, "resource_loaded_callback", "secondaries"), false)
end

function BlackMarketManager:load_all_crafted_weapons()
	print("--PRIMARIES-------------------------")

	for i, weapon in pairs(self._global.crafted_items.primaries) do
		print("loading crafted weapon", "index", i, "weapon", weapon)
		managers.weapon_factory:preload_blueprint(weapon.factory_id, weapon.blueprint, false, callback(self, self, "resource_loaded_callback", "primaries" .. tostring(i)), false)
	end

	print("--SECONDARIES-----------------------")

	for i, weapon in pairs(self._global.crafted_items.secondaries) do
		print("loading crafted weapon", "index", i, "weapon", weapon)
		managers.weapon_factory:preload_blueprint(weapon.factory_id, weapon.blueprint, false, callback(self, self, "resource_loaded_callback", "secondaries" .. tostring(i)), false)
	end
end

function BlackMarketManager:preload_equipped_weapons()
	self:preload_primary_weapon()
	self:preload_secondary_weapon()
end

function BlackMarketManager:preload_primary_weapon()
	local weapon = self:equipped_primary()

	self:preload_weapon_blueprint("primaries", weapon.factory_id, weapon.blueprint)
end

function BlackMarketManager:preload_secondary_weapon()
	local weapon = self:equipped_secondary()

	self:preload_weapon_blueprint("secondaries", weapon.factory_id, weapon.blueprint)
end

function BlackMarketManager:preload_weapon_blueprint(category, factory_id, blueprint, spawn_workbench)
	Application:debug("[BlackMarketManager] preload_weapon_blueprint():", "category", category, "factory_id", factory_id, "blueprint", inspect(blueprint))

	local parts = managers.weapon_factory:preload_blueprint(factory_id, blueprint, false, function ()
	end, true)
	local factory_weapon = tweak_data.weapon.factory[factory_id]
	local ids_unit_name = Idstring(factory_weapon.unit)

	table.insert(self._preloading_list, {
		load_me = {
			name = ids_unit_name
		}
	})

	local loading_parts = {}

	for part_id, part in pairs(parts) do
		if part.package or not managers.dyn_resource:is_resource_ready(Idstring("unit"), part.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
			local new_loading = {}

			if part.package then
				new_loading = {
					package = part.package
				}
			else
				new_loading = {
					load_me = part
				}
			end

			if Application:production_build() then
				new_loading.part_id = part_id
			end

			table.insert(self._preloading_list, new_loading)

			loading_parts[part_id] = part
		end
	end

	table.insert(self._preloading_list, {
		category,
		loading_parts
	})
end

function BlackMarketManager:resource_loaded_callback(category, loaded_table, parts)
	local loaded_category = self._category_resource_loaded[category]

	if loaded_category then
		for part_id, unload in pairs(loaded_category) do
			if unload.package then
				managers.weapon_factory:unload_package(unload.package)
			else
				managers.dyn_resource:unload(Idstring("unit"), unload.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
			end
		end
	end

	self._category_resource_loaded[category] = loaded_table
end

function BlackMarketManager:release_preloaded_category(category)
	if self._category_resource_loaded[category] then
		for part_id, unload in pairs(self._category_resource_loaded[category]) do
			if unload.package then
				managers.weapon_factory:unload_package(unload.package)
			else
				managers.dyn_resource:unload(Idstring("unit"), unload.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
			end
		end

		self._category_resource_loaded[category] = nil
	end
end

function BlackMarketManager:release_preloaded_blueprints()
	for category, data in pairs(self._category_resource_loaded) do
		for part_id, unload in pairs(data) do
			if unload.package then
				managers.weapon_factory:unload_package(unload.package)
			else
				managers.dyn_resource:unload(Idstring("unit"), unload.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
			end
		end
	end

	self._category_resource_loaded = {}
end

function BlackMarketManager:is_preloading_weapons()
	return #self._preloading_list > 0
end

function BlackMarketManager:create_preload_ws()
	if self._preload_ws then
		return
	end

	self._preload_ws = managers.gui_data:create_fullscreen_workspace()
	local panel = self._preload_ws:panel()

	panel:set_layer(tweak_data.gui.DIALOG_LAYER)

	local new_script = {
		progress = 1
	}

	function new_script.step_progress()
		new_script.set_progress(new_script.progress + 1)
	end

	function new_script.set_progress(progress)
		new_script.progress = progress
		local square_panel = panel:child("square_panel")
		local progress_rect = panel:child("progress")

		if progress == 0 then
			progress_rect:hide()
		end

		for i, child in ipairs(square_panel:children()) do
			child:set_color(i < progress and Color.white or Color(0.3, 0.3, 0.3))

			if i == progress then
				progress_rect:set_world_center(child:world_center())
				progress_rect:show()
			end
		end
	end

	panel:set_script(new_script)

	local square_panel = panel:panel({
		layer = 1,
		name = "square_panel"
	})
	local num_squares = 0

	for i, preload in ipairs(self._preloading_list) do
		if preload.package or preload.load_me then
			num_squares = num_squares + 1
		end
	end

	local rows = math.max(1, math.ceil(num_squares / 8))
	local next_row_at = math.ceil(num_squares / rows)
	local row_index = 0
	local x = 0
	local y = 0
	local last_rect = nil
	local max_w = 0
	local max_h = 0

	for i = 1, num_squares do
		row_index = row_index + 1
		last_rect = square_panel:rect({
			blend_mode = "add",
			h = 15,
			w = 15,
			x = x,
			y = y,
			color = Color(0.3, 0.3, 0.3)
		})
		x = x + 24
		max_w = math.max(max_w, last_rect:right())
		max_h = math.max(max_h, last_rect:bottom())

		if row_index == next_row_at then
			row_index = 0
			y = y + 24
			x = 0
		end
	end

	square_panel:set_size(max_w, max_h)
	panel:rect({
		blend_mode = "add",
		name = "progress",
		h = 19,
		w = 19,
		layer = 2,
		color = Color(0.3, 0.3, 0.3)
	})

	local bg = panel:rect({
		alpha = 0.8,
		color = Color.black
	})
	local width = square_panel:w() + 19
	local height = square_panel:h() + 19

	bg:set_size(width, height)
	bg:set_center(panel:w() / 2, panel:h() / 2)
	square_panel:set_center(bg:center())

	local box_panel = panel:panel({
		layer = 2
	})

	box_panel:set_shape(bg:shape())
	BoxGuiObject:new(box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
	panel:script().set_progress(1)

	local function fade_in_animation(panel)
		panel:hide()
		coroutine.yield()
		panel:show()
	end

	panel:animate(fade_in_animation)
end

function BlackMarketManager:is_weapon_slot_unlocked(category, slot)
	return self._global.unlocked_weapon_slots and self._global.unlocked_weapon_slots[category] and self._global.unlocked_weapon_slots[category][slot] or false
end

function BlackMarketManager:is_weapon_modified(factory_id, blueprint)
	local weapon = tweak_data.weapon.factory[factory_id]

	if not weapon then
		Application:error("BlackMarketManager:is_weapon_modified", "factory_id", factory_id, "blueprint", inspect(blueprint))

		return false
	end

	local default_blueprint = weapon.default_blueprint

	for _, part_id in ipairs(blueprint) do
		if not table.contains(default_blueprint, part_id) then
			return true
		end
	end

	return false
end

function BlackMarketManager:update(t, dt)
	if not self._force_paused and Global and Global.blackmarket_manager and Global.blackmarket_manager.crafted_items and Global.blackmarket_manager.crafted_items.primaries and #Global.blackmarket_manager.crafted_items.primaries > 1 then
		for bm_weapon_index, bm_weapon_data in ipairs(managers.blackmarket._global.crafted_items.primaries) do
			local bm_weapon_name = bm_weapon_data.weapon_id
			local tw_weapon_name = tweak_data.weapon_inventory.weapon_primaries_index[bm_weapon_index].weapon_id

			if bm_weapon_name ~= tw_weapon_name then
				debug_pause("[BlackMarketManager:update] CALL PROGRAMMING DEPARTMENT AND REMEMBER WHAT YOU DID BEFORE THIS ERROR !!!! ", bm_weapon_index, bm_weapon_name, tw_weapon_name)

				self._force_paused = true
			end
		end
	end

	if #self._preloading_list > 0 then
		if not self._preload_ws then
			self:create_preload_ws()

			self._streaming_preload = nil
		elseif not self._streaming_preload then
			self._preloading_index = self._preloading_index + 1

			if self._preloading_index > #self._preloading_list then
				self._preloading_list = {}
				self._preloading_index = 0

				if self._preload_ws then
					Overlay:gui():destroy_workspace(self._preload_ws)

					self._preload_ws = nil
				end
			else
				local next_in_line = self._preloading_list[self._preloading_index]
				local is_load = (next_in_line.package or next_in_line.load_me) and true or false
				local is_done_cb = not is_load and next_in_line.done_cb and true or false

				if is_load then
					if next_in_line.part_id then
						-- Nothing
					end

					if self._preload_ws then
						self._preload_ws:panel():script().step_progress()
					end

					if next_in_line.package then
						managers.weapon_factory:load_package(next_in_line.package)
					else
						local function f()
							self._streaming_preload = nil
						end

						self._streaming_preload = true

						managers.dyn_resource:load(Idstring("unit"), next_in_line.load_me.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, f)
					end
				elseif is_done_cb then
					if self._preload_ws then
						self._preload_ws:panel():script().set_progress(self._preloading_index)
					end

					next_in_line.done_cb()
				else
					if self._preload_ws then
						self._preload_ws:panel():script().set_progress(self._preloading_index)
					end

					self:resource_loaded_callback(unpack(next_in_line))
				end
			end
		end
	end
end

function BlackMarketManager:get_crafted_category(category)
	if not self._global.crafted_items then
		return
	end

	return self._global.crafted_items[category]
end

function BlackMarketManager:get_crafted_category_slot(category, slot)
	if not self._global.crafted_items then
		return
	end

	if not self._global.crafted_items[category] then
		return
	end

	return self._global.crafted_items[category][slot]
end

function BlackMarketManager:get_weapon_data(weapon_id)
	return self._global.weapons[weapon_id]
end

function BlackMarketManager:get_crafted_custom_name(category, slot, add_quotation)
	local crafted_slot = self:get_crafted_category_slot(category, slot)
	local custom_name = crafted_slot and crafted_slot.custom_name

	if custom_name then
		if add_quotation then
			return "\"" .. custom_name .. "\""
		end

		return custom_name
	end
end

function BlackMarketManager:set_crafted_custom_name(category, slot, custom_name)
	local crafted_slot = self:get_crafted_category_slot(category, slot)

	if crafted_slot.customize_locked then
		return
	end

	crafted_slot.custom_name = custom_name ~= "" and custom_name
end

function BlackMarketManager:get_weapon_name_by_category_slot(category, slot)
	local crafted_slot = self:get_crafted_category_slot(category, slot)

	if crafted_slot then
		local cosmetics = crafted_slot.cosmetics
		local cosmetic_name = cosmetics and cosmetics.id and tweak_data.blackmarket.weapon_skins[cosmetics.id] and tweak_data.blackmarket.weapon_skins[cosmetics.id].unique_name_id and managers.localization:text(tweak_data.blackmarket.weapon_skins[cosmetics.id].unique_name_id)
		local custom_name = cosmetic_name or crafted_slot.custom_name

		if cosmetic_name and crafted_slot.customize_locked then
			return utf8.to_upper(cosmetic_name)
		end

		if custom_name then
			return "\"" .. custom_name .. "\""
		end

		return managers.weapon_factory:get_weapon_name_by_factory_id(crafted_slot.factory_id)
	end

	return ""
end

function BlackMarketManager:get_weapon_category(category)
	local weapon_index = {
		primaries = 2,
		secondaries = 1
	}
	local selection_index = weapon_index[category] or 1
	local t = {}

	for weapon_name, weapon_data in pairs(self._global.weapons) do
		if weapon_data.selection_index == selection_index then
			table.insert(t, weapon_data)

			t[#t].weapon_id = weapon_name
		end
	end

	return t
end

function BlackMarketManager:get_weapon_names_category(category)
	local weapon_index = {
		primaries = 2,
		secondaries = 1
	}
	local selection_index = weapon_index[category] or 1
	local t = {}

	for weapon_name, weapon_data in pairs(self._global.weapons) do
		if weapon_data.selection_index == selection_index then
			t[weapon_name] = true
		end
	end

	return t
end

function BlackMarketManager:get_weapon_blueprint(category, slot)
	if not self._global.crafted_items then
		return
	end

	if not self._global.crafted_items[category] then
		return
	end

	if not self._global.crafted_items[category][slot] then
		return
	end

	return self._global.crafted_items[category][slot].blueprint
end

function BlackMarketManager:get_perks_from_weapon_blueprint(factory_id, blueprint)
	return managers.weapon_factory:get_perks(factory_id, blueprint)
end

function BlackMarketManager:get_perks_from_part(part_id)
	return managers.weapon_factory:get_perks_from_part_id(part_id)
end

function BlackMarketManager:get_melee_weapon_stats(melee_weapon_id)
	local data = self:get_melee_weapon_data(melee_weapon_id)

	if data then
		return data.stats
	end

	return {}
end

function BlackMarketManager:_get_weapon_stats(weapon_id, blueprint, cosmetics)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local weapon_tweak_data = tweak_data.weapon[weapon_id] or {}
	local weapon_stats = managers.weapon_factory:get_stats(factory_id, blueprint)
	local bonus_stats = {}

	if cosmetics and cosmetics.id and cosmetics.bonus then
		bonus_stats = tweak_data:get_raw_value("economy", "bonuses", tweak_data.blackmarket.weapon_skins[cosmetics.id].bonus, "stats") or {}
	end

	for stat, value in pairs(weapon_tweak_data.stats) do
		weapon_stats[stat] = (weapon_stats[stat] or 0) + weapon_tweak_data.stats[stat]
	end

	for stat, value in pairs(bonus_stats) do
		weapon_stats[stat] = (weapon_stats[stat] or 0) + value
	end

	return weapon_stats
end

function BlackMarketManager:get_weapon_stats(category, slot, blueprint)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:get_weapon_stats] Trying to get weapon stats on weapon that doesn't exist", category, slot)

		return
	end

	blueprint = blueprint or self:get_weapon_blueprint(category, slot)
	local crafted = self._global.crafted_items[category][slot]

	if not blueprint or not crafted then
		return
	end

	return self:_get_weapon_stats(crafted.weapon_id, blueprint, crafted.cosmetics)
end

function BlackMarketManager:get_weapon_stats_without_mod(category, slot, part_id)
	return self:get_weapon_stats_with_mod(category, slot, part_id, true)
end

function BlackMarketManager:get_weapon_stats_with_mod(category, slot, part_id, remove_mod)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:get_weapon_stats_with_mod] Trying to get weapon stats on weapon that doesn't exist", category, slot)

		return
	end

	local blueprint = deep_clone(self:get_weapon_blueprint(category, slot))
	local crafted = self._global.crafted_items[category][slot]

	if not blueprint or not crafted then
		return
	end

	managers.weapon_factory:change_part_blueprint_only(crafted.factory_id, part_id, blueprint, remove_mod)

	return self:_get_weapon_stats(crafted.weapon_id, blueprint, crafted.cosmetics)
end

function BlackMarketManager:_get_stats(name, category, slot, blueprint)
	local equipped_mods = nil
	local silencer = false
	local single_mod = false
	local auto_mod = false
	blueprint = blueprint or managers.blackmarket:get_weapon_blueprint(category, slot)
	local bonus_stats = {}

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		if equipped_mods then
			silencer = managers.weapon_factory:has_perk("silencer", factory_id, equipped_mods)
			single_mod = managers.weapon_factory:has_perk("fire_mode_single", factory_id, equipped_mods)
			auto_mod = managers.weapon_factory:has_perk("fire_mode_auto", factory_id, equipped_mods)
		end
	end

	local base_stats = self:_get_base_stats(name)
	local mods_stats = self:_get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local skill_stats = self:_get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local clip_ammo, max_ammo, ammo_data = self:get_weapon_ammo_info(name, tweak_data.weapon[name].stats.extra_ammo, base_stats.totalammo.index + mods_stats.totalammo.index)
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

function BlackMarketManager:_get_base_stats(name)
	local base_stats = {}
	local index = nil
	local tweak_stats = tweak_data.weapon.stats
	local modifier_stats = tweak_data.weapon[name].stats_modifiers
	self._stats_shown = {
		{
			round_value = true,
			name = "magazine",
			stat_name = "extra_ammo"
		},
		{
			round_value = true,
			name = "totalammo",
			stat_name = "total_ammo_mod"
		},
		{
			round_value = true,
			name = "fire_rate"
		},
		{
			name = "damage"
		},
		{
			visual_multiplier = 0.5,
			name = "spread",
			percent = true,
			one_minus = true,
			revert = true
		},
		{
			percent = true,
			name = "recoil",
			offset = true,
			revert = true
		},
		{
			index = true,
			name = "concealment"
		},
		{
			offset = true,
			name = "suppression"
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

function BlackMarketManager:_get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
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
				skill_stats[stat.name].value = managers.player:upgrade_value(name, "clip_ammo_increase", 0)

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks.weapon or not table.contains(weapon_tweak.upgrade_blocks.weapon, "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks[weapon_tweak.category] or not table.contains(weapon_tweak.upgrade_blocks[weapon_tweak.category], "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value(weapon_tweak.category, "clip_ammo_increase", 0)
				end

				if managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("primary_weapon", "magazine_upgrade", 0)
				elseif managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("secondary_weapon", "magazine_upgrade", 0)
				end

				skill_stats[stat.name].skill_in_effect = managers.player:has_category_upgrade(name, "clip_ammo_increase") or managers.player:has_category_upgrade("weapon", "clip_ammo_increase")
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

function BlackMarketManager:_get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
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

function BlackMarketManager:get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod)
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value(weapon_tweak_data.category, "extra_ammo_multiplier", 1)

	if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
		ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
	end

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
		local clip_skill = managers.player:upgrade_value(weapon_id, "clip_ammo_increase")

		if not upgrade_blocked("weapon", "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		if not upgrade_blocked(weapon_tweak_data.category, "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value(weapon_tweak_data.category, "clip_ammo_increase", 0)
		end

		return clip_base + clip_mod + clip_skill
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
	ammo_data.skill_in_effect = managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or managers.player:has_category_upgrade(weapon_tweak_data.category, "extra_ammo_multiplier") or managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul")

	return ammo_max_per_clip, ammo_max, ammo_data
end

function BlackMarketManager:_get_melee_weapon_stats(name)
	self._mweapon_stats_shown = {
		{
			range = true,
			name = "damage"
		},
		{
			range = true,
			name = "damage_effect",
			multiple_of = "damage"
		},
		{
			inverse = true,
			name = "charge_time",
			num_decimals = 1,
			suffix = managers.localization:text("menu_seconds_suffix_short")
		},
		{
			range = true,
			name = "range"
		},
		{
			index = true,
			name = "concealment"
		}
	}
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local stats_data = managers.blackmarket:get_melee_weapon_stats(name)
	local multiple_of = {}
	local has_non_special = managers.player:has_category_upgrade("player", "non_special_melee_multiplier")
	local has_special = managers.player:has_category_upgrade("player", "melee_damage_multiplier")
	local non_special = managers.player:upgrade_value("player", "non_special_melee_multiplier", 1) - 1
	local special = managers.player:upgrade_value("player", "melee_damage_multiplier", 1) - 1

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
			local gst_skill = managers.player:upgrade_value("player", "melee_knockdown_mul", 1) - 1
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

function BlackMarketManager:calculate_weapon_visibility(weapon)
	return #tweak_data.weapon.stats.concealment - self:calculate_weapon_concealment(weapon)
end

function BlackMarketManager:calculate_armor_visibility(armor)
	return #tweak_data.weapon.stats.concealment - self:_calculate_armor_concealment(armor or self:equipped_armor(true))
end

function BlackMarketManager:calculate_melee_weapon_visibility(melee_weapon)
	return #tweak_data.weapon.stats.concealment - self:_calculate_melee_weapon_concealment(melee_weapon or self:equipped_melee_weapon())
end

function BlackMarketManager:calculate_weapon_concealment(weapon)
	if type(weapon) == "string" then
		weapon = weapon == "primaries" and self:equipped_primary() or weapon == "secondaries" and self:equipped_secondary()
	end

	return self:_calculate_weapon_concealment(weapon)
end

function BlackMarketManager:calculate_armor_concealment(armor)
	return self:_calculate_armor_concealment(armor or self:equipped_armor(true))
end

function BlackMarketManager:_calculate_weapon_concealment(weapon)
	local factory_id = weapon.factory_id
	local weapon_id = weapon.weapon_id or managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
	local blueprint = weapon.blueprint
	local base_stats = tweak_data.weapon[weapon_id].stats
	local modifiers_stats = tweak_data.weapon[weapon_id].stats_modifiers

	if not base_stats or not base_stats.concealment then
		return 0
	end

	local bonus_stats = {}

	if weapon.cosmetics and weapon.cosmetics.id and weapon.cosmetics.bonus and not managers.weapon_factory:has_perk("bonus", factory_id, blueprint) then
		bonus_stats = tweak_data:get_raw_value("economy", "bonuses", tweak_data.blackmarket.weapon_skins[weapon.cosmetics.id].bonus, "stats") or {}
	end

	local parts_stats = managers.weapon_factory:get_stats(factory_id, blueprint)

	return (base_stats.concealment + (parts_stats.concealment or 0) + (bonus_stats.concealment or 0)) * (modifiers_stats and modifiers_stats.concealment or 1)
end

function BlackMarketManager:_calculate_armor_concealment(armor)
	local armor_data = tweak_data.blackmarket.armors[armor]

	return managers.player:body_armor_value("concealment", armor_data.upgrade_level)
end

function BlackMarketManager:_calculate_melee_weapon_concealment(melee_weapon)
	local melee_weapon_data = tweak_data.blackmarket.melee_weapons[melee_weapon].stats

	return melee_weapon_data.concealment or #tweak_data.weapon.stats.concealment
end

function BlackMarketManager:_get_concealment(primary, secondary, armor, melee_weapon, modifier)
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility(primary)
	local secondary_visibility = self:calculate_weapon_visibility(secondary)
	local armor_visibility = self:calculate_armor_visibility(armor)
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(melee_weapon)
	local modifier = modifier or 0
	local total_visibility = math.clamp(primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier, 1, #stats_tweak_data.concealment)
	local total_concealment = math.clamp(#stats_tweak_data.concealment - total_visibility, 1, #stats_tweak_data.concealment)

	return stats_tweak_data.concealment[total_concealment], total_concealment
end

function BlackMarketManager:_get_concealment_from_local_player(ignore_armor_kit)
	return self:_get_concealment(self:equipped_primary(), self:equipped_secondary(), self:equipped_armor(not ignore_armor_kit), self:equipped_melee_weapon(), self:visibility_modifiers())
end

function BlackMarketManager:_get_concealment_from_outfit_string(outfit_string)
	return self:_get_concealment(outfit_string.primary, outfit_string.secondary, outfit_string.armor_current or outfit_string.armor, outfit_string.melee_weapon, -outfit_string.concealment_modifier)
end

function BlackMarketManager:_get_concealment_from_peer(peer)
	local outfit = peer:blackmarket_outfit()

	return self:_get_concealment(outfit.primary, outfit.secondary, outfit.armor_current or outfit.armor, outfit.melee_weapon, -outfit.concealment_modifier)
end

function BlackMarketManager:get_real_visibility_index_from_custom_data(data)
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility(data.primaries or "primaries")
	local secondary_visibility = self:calculate_weapon_visibility(data.secondaries or "secondaries")
	local armor_visibility = self:calculate_armor_visibility(data.armors)
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(data.melee_weapon)
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier
	local total_concealment = #stats_tweak_data.concealment - total_visibility

	return total_concealment
end

function BlackMarketManager:get_real_visibility_index_of_local_player()
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility("primaries")
	local secondary_visibility = self:calculate_weapon_visibility("secondaries")
	local armor_visibility = self:calculate_armor_visibility()
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility()
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier
	local total_concealment = #stats_tweak_data.concealment - total_visibility

	return total_concealment
end

function BlackMarketManager:get_suspicion_of_local_player()
	return self:_get_concealment_from_local_player()
end

function BlackMarketManager:get_concealment_of_peer(peer)
	return self:_get_concealment_from_peer(peer)
end

function BlackMarketManager:_get_concealment_of_outfit_string(outfit_string)
	return self:_get_concealment_from_outfit_string(outfit_string)
end

function BlackMarketManager:_calculate_suspicion_offset(index, lerp)
	local con_val = tweak_data.weapon.stats.concealment[index]
	local min_val = tweak_data.weapon.stats.concealment[1]
	local max_val = tweak_data.weapon.stats.concealment[#tweak_data.weapon.stats.concealment]
	local max_ratio = max_val / min_val
	local mul_ratio = math.max(1, con_val / min_val)
	local susp_lerp = math.clamp(1 - (con_val - min_val) / (max_val - min_val), 0, 1)

	return math.lerp(0, lerp, susp_lerp)
end

function BlackMarketManager:get_suspicion_offset_of_outfit_string(outfit_string, lerp)
	local con_mul, index = self:_get_concealment_of_outfit_string(outfit_string)

	return self:_calculate_suspicion_offset(index, lerp), index == 1
end

function BlackMarketManager:get_suspicion_offset_of_peer(peer, lerp)
	local con_mul, index = self:get_concealment_of_peer(peer)

	return self:_calculate_suspicion_offset(index, lerp)
end

function BlackMarketManager:get_suspicion_offset_of_local(lerp, ignore_armor_kit)
	local con_mul, index = self:_get_concealment_from_local_player(ignore_armor_kit)
	local val = self:_calculate_suspicion_offset(index, lerp or 1)

	return val, index == 1, index == #tweak_data.weapon.stats.concealment - 1
end

function BlackMarketManager:get_suspicion_offset_from_custom_data(data, lerp)
	local index = self:get_real_visibility_index_from_custom_data(data)
	index = math.clamp(index, 1, #tweak_data.weapon.stats.concealment)
	local val = self:_calculate_suspicion_offset(index, lerp or 1)

	return val, index == 1, index == #tweak_data.weapon.stats.concealment - 1
end

function BlackMarketManager:visibility_modifiers()
	local skill_bonuses = 0
	skill_bonuses = skill_bonuses - managers.player:upgrade_value("player", "passive_concealment_modifier", 0)
	skill_bonuses = skill_bonuses - managers.player:upgrade_value("player", "concealment_modifier", 0)
	skill_bonuses = skill_bonuses - managers.player:upgrade_value("player", "melee_concealment_modifier", 0)

	return skill_bonuses
end

function BlackMarketManager:concealment_modifier(type)
	local modifier = 0

	if type == "armors" then
		modifier = modifier + managers.player:upgrade_value("player", "passive_concealment_modifier", 0)
		modifier = modifier + managers.player:upgrade_value("player", "concealment_modifier", 0)
	elseif type == "melee_weapons" then
		modifier = modifier + managers.player:upgrade_value("player", "melee_concealment_modifier", 0)
	end

	return modifier
end

function BlackMarketManager:has_parts_for_blueprint(category, blueprint)
	for category, data in pairs(blueprint) do
		if not self:has_item(data.global_value, category, data.id) then
			print("misses part", data.global_value, category, data.id)

			return false
		end
	end

	print("has all parts")

	return true
end

function BlackMarketManager:get_crafted_item_amount(category, id)
	local crafted_category = self._global.crafted_items[category]

	if not crafted_category then
		print("[BlackMarketManager:get_crafted_item_amount] No such category", category)

		return 0
	end

	local item_amount = 0

	for _, item in pairs(crafted_category) do
		if category == "primaries" or category == "secondaries" then
			if item.weapon_id == id then
				item_amount = item_amount + 1
			end
		elseif category == "character" then
			-- Nothing
		elseif category ~= "armors" then
			break
		end
	end

	return item_amount
end

function BlackMarketManager:get_crafted_part_global_value(category, slot, part_id)
	local global_values = self._global.crafted_items[category][slot].global_values

	if global_values then
		return global_values[part_id]
	end
end

function BlackMarketManager:craft_item(category, slot, blueprint)
	if not self:has_parts_for_blueprint(category, blueprint) then
		Application:error("[BlackMarketManager:craft_item] Blueprint not valid", category)

		return
	end

	self._global.crafted_items[category] = self._global.crafted_items[category] or {}
	self._global.crafted_items[category][slot] = blueprint
end

function BlackMarketManager:_get_free_weapon_slot(category)
	if not self._global.crafted_items[category] then
		return 1
	end

	local max_items = tweak_data.gui.MAX_WEAPON_SLOTS or 72

	for i = 1, max_items do
		if self:is_weapon_slot_unlocked(category, i) and not self._global.crafted_items[category][i] then
			return i
		end
	end
end

function BlackMarketManager:equip_previous_weapon(category)
	if not Global.blackmarket_manager.crafted_items[category] then
		return nil
	end

	local equipped_slot = self:equipped_weapon_slot(category)
	local max_slots = tweak_data.gui.MAX_WEAPON_SLOTS or 72
	local crafted = nil

	for slot = equipped_slot - 1, 1, -1 do
		crafted = self._global.crafted_items[category][slot]

		if crafted and self:weapon_unlocked(crafted.weapon_id) then
			return self:equip_weapon(category, slot)
		end
	end

	for slot = max_slots, equipped_slot + 1, -1 do
		crafted = self._global.crafted_items[category][slot]

		if crafted and self:weapon_unlocked(crafted.weapon_id) then
			return self:equip_weapon(category, slot)
		end
	end
end

function BlackMarketManager:equip_next_weapon(category)
	if not Global.blackmarket_manager.crafted_items[category] then
		return nil
	end

	local equipped_slot = self:equipped_weapon_slot(category)
	local max_slots = tweak_data.gui.MAX_WEAPON_SLOTS or 72
	local crafted = nil

	for slot = equipped_slot + 1, max_slots do
		crafted = self._global.crafted_items[category][slot]

		if crafted and self:weapon_unlocked(crafted.weapon_id) then
			return self:equip_weapon(category, slot)
		end
	end

	for slot = 1, equipped_slot - 1 do
		crafted = self._global.crafted_items[category][slot]

		if crafted and self:weapon_unlocked(crafted.weapon_id) then
			return self:equip_weapon(category, slot)
		end
	end
end

function BlackMarketManager:get_sorted_melee_weapons(hide_locked)
	local items = {}
	local global_value, td, category = nil

	for id, item in pairs(Global.blackmarket_manager.melee_weapons) do
		td = tweak_data.blackmarket.melee_weapons[id]
		global_value = td.dlc or td.global_value or "normal"
		category = td.type or "unknown"

		if item.unlocked or item.equipped or not hide_locked and not tweak_data:get_raw_value("lootdrop", "global_values", global_value, "hide_unavailable") then
			table.insert(items, {
				id,
				item
			})
		end
	end

	local xd, yd, x_td, y_td, x_sn, y_sn, x_gv, y_gv = nil
	local m_tweak_data = tweak_data.blackmarket.melee_weapons
	local l_tweak_data = tweak_data.lootdrop.global_values

	local function sort_func(x, y)
		xd = x[2]
		yd = y[2]
		x_td = m_tweak_data[x[1]]
		y_td = m_tweak_data[y[1]]

		if xd.unlocked ~= yd.unlocked then
			return xd.unlocked
		end

		if not xd.unlocked and xd.level ~= yd.level then
			return xd.level < yd.level
		end

		if x_td.instant ~= y_td.instant then
			return x_td.instant
		end

		if xd.skill_based ~= yd.skill_based then
			return xd.skill_based
		end

		if x_td.free ~= y_td.free then
			return x_td.free
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = l_tweak_data[x_gv]
		y_sn = l_tweak_data[y_gv]
		x_sn = x_sn and x_sn.sort_number or 1
		y_sn = y_sn and y_sn.sort_number or 1

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		if xd.level ~= yd.level then
			return xd.level < yd.level
		end

		return x[1] < y[1]
	end

	table.sort(items, sort_func)

	local sorted_categories = {}
	local item_categories = {}
	local category = nil

	for index, item in ipairs(items) do
		category = math.max(1, math.ceil(index / 16))
		item_categories[category] = item_categories[category] or {}

		table.insert(item_categories[category], item)
	end

	for i = 1, #item_categories do
		table.insert(sorted_categories, i)
	end

	return sorted_categories, item_categories
end

function BlackMarketManager:equip_next_melee_weapon()
	local sorted_categories, item_categories = self:get_sorted_melee_weapons(true)
	local equipped_melee_weapon = self:equipped_melee_weapon()
	local equipped_category = nil

	for category, items in ipairs(item_categories or {}) do
		for _, item in ipairs(items) do
			if item[1] == equipped_melee_weapon then
				equipped_category = category

				break
			end
		end
	end

	if not equipped_category then
		return
	end

	local equipped_index, equipped_category_index = nil

	for index, data in ipairs(item_categories[equipped_category] or {}) do
		if data[1] == equipped_melee_weapon then
			equipped_index = index

			break
		end
	end

	for index, category in ipairs(sorted_categories) do
		if equipped_category == category then
			equipped_category_index = index

			break
		end
	end

	local next_melee_weapon = nil

	if equipped_category_index and equipped_index then
		local next_category = equipped_index == #item_categories[equipped_category] and equipped_category_index % #sorted_categories + 1 or equipped_category_index
		local next_index = equipped_index % #item_categories[equipped_category] + 1
		next_melee_weapon = item_categories[sorted_categories[next_category]][next_index][1]
	end

	if next_melee_weapon and next_melee_weapon ~= equipped_melee_weapon then
		self:equip_melee_weapon(next_melee_weapon)

		return true
	end
end

function BlackMarketManager:equip_previous_melee_weapon()
	local sorted_categories, item_categories = self:get_sorted_melee_weapons(true)
	local equipped_melee_weapon = self:equipped_melee_weapon()
	local equipped_category = nil

	for category, items in ipairs(item_categories or {}) do
		for _, item in ipairs(items) do
			if item[1] == equipped_melee_weapon then
				equipped_category = category

				break
			end
		end
	end

	if not equipped_category then
		return
	end

	local equipped_index, equipped_category_index = nil

	for index, data in ipairs(item_categories[equipped_category] or {}) do
		if data[1] == equipped_melee_weapon then
			equipped_index = index

			break
		end
	end

	for index, category in ipairs(sorted_categories) do
		if equipped_category == category then
			equipped_category_index = index

			break
		end
	end

	local previous_melee_weapon = nil

	if equipped_category_index and equipped_index then
		local previous_category = equipped_index == 1 and equipped_category_index - 1 or equipped_category_index
		local previous_index = equipped_index - 1

		if previous_category == 0 then
			previous_category = #sorted_categories or previous_category
		end

		if previous_index == 0 then
			previous_index = #item_categories[sorted_categories[previous_category]] or previous_index
		end

		previous_melee_weapon = item_categories[sorted_categories[previous_category]][previous_index][1]
	end

	if previous_melee_weapon and previous_melee_weapon ~= equipped_melee_weapon then
		self:equip_melee_weapon(previous_melee_weapon)

		return true
	end
end

function BlackMarketManager:equip_previous_grenade()
	local sort_data = self:get_sorted_grenades(true)
	local equipped_grenade = self:equipped_grenade()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data[1] == equipped_grenade then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local previous_grenade = sort_data[equipped_index == 1 and #sort_data or equipped_index - 1][1]

		if previous_grenade and previous_grenade ~= equipped_grenade then
			self:equip_grenade(previous_grenade)

			return true
		end
	end
end

function BlackMarketManager:equip_next_grenade()
	local sort_data = self:get_sorted_grenades(true)
	local equipped_grenade = self:equipped_grenade()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data[1] == equipped_grenade then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local next_grenade = sort_data[equipped_index % #sort_data + 1][1]

		if next_grenade and next_grenade ~= equipped_grenade then
			self:equip_grenade(next_grenade)

			return true
		end
	end
end

function BlackMarketManager:equip_previous_armor()
	local sort_data = self:get_sorted_armors(true)
	local equipped_armor = self:equipped_armor()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data == equipped_armor then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local previous_armor = sort_data[equipped_index == 1 and #sort_data or equipped_index - 1]

		if previous_armor and previous_armor ~= equipped_armor then
			self:equip_armor(previous_armor)

			return true
		end
	end
end

function BlackMarketManager:equip_next_armor()
	local sort_data = self:get_sorted_armors(true)
	local equipped_armor = self:equipped_armor()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data == equipped_armor then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local next_armor = sort_data[equipped_index % #sort_data + 1]

		if next_armor and next_armor ~= equipped_armor then
			self:equip_armor(next_armor)

			return true
		end
	end
end

function BlackMarketManager:equip_previous_deployable()
	local sort_data = self:get_sorted_deployables(true)
	local equipped_deployable = self:equipped_deployable()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data[1] == equipped_deployable then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local previous_deployable = sort_data[equipped_index == 1 and #sort_data or equipped_index - 1][1]

		if previous_deployable and previous_deployable ~= equipped_deployable then
			self:equip_deployable(previous_deployable)

			return true
		end
	end
end

function BlackMarketManager:equip_next_deployable()
	local sort_data = self:get_sorted_deployables(true)
	local equipped_deployable = self:equipped_deployable()
	local equipped_index = nil

	for index, data in ipairs(sort_data or {}) do
		if data[1] == equipped_deployable then
			equipped_index = index

			break
		end
	end

	if equipped_index then
		local next_deployable = sort_data[equipped_index % #sort_data + 1][1]

		if next_deployable and next_deployable ~= equipped_deployable then
			self:equip_deployable(next_deployable)

			return true
		end
	end
end

function BlackMarketManager:on_aquired_weapon_platform(upgrade, id, loading)
	if not self._global.weapons[id] then
		Application:error("[BlackMarketManager] attempting to acquire unknown weapon: ", id, upgrade.factory_id)

		return
	end

	self._global.weapons[id].unlocked = true
	local category = tweak_data.weapon[upgrade.weapon_id].use_data.selection_index == 2 and "primaries" or "secondaries"

	if upgrade.free then
		local slot = self:_get_free_weapon_slot(category)

		if slot then
			self:on_buy_weapon_platform(category, upgrade.weapon_id, slot, true)
		end
	end
end

function BlackMarketManager:on_unaquired_weapon_platform(upgrade, id)
	self._global.weapons[id].unlocked = false
	local equipped_primariy = managers.blackmarket:equipped_primary()

	if equipped_primariy and equipped_primariy.weapon_id == id then
		equipped_primariy.equipped = false

		self:_verfify_equipped_category("primaries")
	end

	local equipped_secondary = managers.blackmarket:equipped_secondary()

	if equipped_secondary and equipped_secondary.weapon_id == id then
		equipped_secondary.equipped = false

		self:_verfify_equipped_category("secondaries")
	end
end

function BlackMarketManager:on_aquired_melee_weapon(upgrade, id, loading)
	if not self._global.melee_weapons[id] then
		Application:error("[BlackMarketManager:on_aquired_melee_weapon] Melee weapon do not exist in blackmarket", "melee_weapon_id", id)

		return
	end

	self._global.melee_weapons[id].unlocked = true
	self._global.melee_weapons[id].owned = true
end

function BlackMarketManager:on_unaquired_melee_weapon(upgrade, id)
	self._global.melee_weapons[id].unlocked = false
	self._global.melee_weapons[id].owned = false
	local equipped_melee_weapon = managers.blackmarket:equipped_melee_weapon()

	if equipped_melee_weapon and equipped_melee_weapon == id then
		equipped_melee_weapon.equipped = false

		self:_verfify_equipped_category("melee_weapons")
	end
end

function BlackMarketManager:on_aquired_grenade(upgrade, id, loading)
	if not self._global.grenades[id] then
		Application:error("[BlackMarketManager:on_aquired_grenade] Grenade do not exist in blackmarket", "grenade_id", id)

		return
	end

	self._global.grenades[id].unlocked = true
	self._global.grenades[id].owned = true
end

function BlackMarketManager:on_unaquired_grenade(upgrade, id)
	self._global.grenades[id].unlocked = false
	self._global.grenades[id].owned = false
	local equipped_grenade = managers.blackmarket:equipped_grenade()

	if equipped_grenade and equipped_grenade == id then
		equipped_grenade.equipped = false

		self:_verfify_equipped_category("grenades")
	end
end

function BlackMarketManager:aquire_default_weapons(only_enable)
	Application:debug("[BlackMarketManager:aquire_default_weapons]")

	local character_class = managers.skilltree:get_character_profile_class()

	if character_class then
		self:_aquire_class_default_secondary(character_class, only_enable)
		self:_aquire_class_default_primary(character_class, only_enable)
	else
		self:_aquire_generic_default_secondary(only_enable)
		self:_aquire_generic_default_primary(only_enable)
	end

	self:_aquire_generic_default_melee(only_enable)
	self:_aquire_generic_default_grenade(only_enable)
end

function BlackMarketManager:equip_class_default_primary()
	local character_class = managers.skilltree:get_character_profile_class()
	local class_primary = tweak_data.skilltree.default_weapons[character_class].primary
	local owned_primaries = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)

	if owned_primaries then
		for _, weapon_data in pairs(owned_primaries) do
			if weapon_data.weapon_id == class_primary then
				self:equip_weapon(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME, weapon_data.slot)

				return true
			end
		end
	end

	return false
end

function BlackMarketManager:equip_class_default_secondary()
	local character_class = managers.skilltree:get_character_profile_class()
	local class_secondary = tweak_data.skilltree.default_weapons[character_class].secondary
	local owned_secondaries = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)

	if owned_secondaries then
		for _, weapon_data in pairs(owned_secondaries) do
			if weapon_data.weapon_id == class_secondary then
				self:equip_weapon(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME, weapon_data.slot)

				return true
			end
		end
	end

	return false
end

function BlackMarketManager:equip_generic_default_grenade()
	managers.blackmarket:equip_grenade(self._defaults.grenade)
end

function BlackMarketManager:_aquire_class_default_secondary(class, only_enable)
	local class_secondary = tweak_data.skilltree.default_weapons[class].secondary
	local weapon = self._global and self._global.weapons and self._global.weapons[class_secondary]

	if not managers.upgrades:aquired(class_secondary, UpgradesManager.AQUIRE_STRINGS[1]) then
		if managers.upgrades:aquired(BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1]) then
			managers.upgrades:unaquire(BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1])
		end

		if only_enable then
			managers.upgrades:enable_weapon(class_secondary, UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons[class_secondary].unlocked = true
		else
			managers.upgrades:aquire(class_secondary, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:_aquire_class_default_primary(class, only_enable)
	local class_primary = tweak_data.skilltree.default_weapons[class].primary
	local weapon = self._global and self._global.weapons and self._global.weapons[class_primary]

	if not managers.upgrades:aquired(class_primary, UpgradesManager.AQUIRE_STRINGS[1]) then
		if managers.upgrades:aquired(BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1]) then
			managers.upgrades:unaquire(BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1])
		end

		if only_enable then
			managers.upgrades:enable_weapon(class_primary, UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons[class_primary].unlocked = true
		else
			managers.upgrades:aquire(class_primary, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:_aquire_generic_default_secondary(only_enable)
	local m1911 = self._global and self._global.weapons and self._global.weapons.m1911

	if m1911 and (not self._global.crafted_items.secondaries or not m1911.unlocked) and not managers.upgrades:aquired(BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			managers.upgrades:enable_weapon(BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons[BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID].unlocked = true
		else
			managers.upgrades:aquire(BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:_aquire_generic_default_primary(only_enable)
	local thompson = self._global and self._global.weapons and self._global.weapons.thompson

	if thompson and (not self._global.crafted_items.primaries or not thompson.unlocked) and not managers.upgrades:aquired(BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			managers.upgrades:enable_weapon(BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID, UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons[BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID].unlocked = true
		else
			managers.upgrades:aquire(BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:_aquire_generic_default_melee(only_enable)
	local melee_weapon = self._global and self._global.melee_weapons and self._global.melee_weapons[self._defaults.melee_weapon]

	if melee_weapon and not melee_weapon.unlocked and not managers.upgrades:aquired(self._defaults.melee_weapon, UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			self._global.melee_weapons[self._defaults.melee_weapon].unlocked = true
		else
			managers.upgrades:aquire(self._defaults.melee_weapon, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:_aquire_generic_default_grenade(only_enable)
	local grenade = self._global and self._global.grenades and self._global.grenades[self._defaults.grenade]

	if grenade and not grenade.unlocked and not managers.upgrades:aquired(self._defaults.grenade, UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			self._global.grenades[self._defaults.grenade].unlocked = true
		else
			managers.upgrades:aquire(self._defaults.grenade, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end

function BlackMarketManager:on_buy_weapon_platform(category, weapon_id, slot, free)
	if category ~= "primaries" and category ~= "secondaries" then
		return
	end

	local weapon_data = tweak_data.weapon[weapon_id]
	local unlocked = not weapon_data.dlc or managers.dlc:is_dlc_unlocked(weapon_data.dlc)
	local existing_slot = self._global and self._global.crafted_items and self._global.crafted_items[category] and self._global.crafted_items[category][slot]

	if existing_slot and existing_slot.weapon_id == weapon_id then
		existing_slot.unlocked = unlocked
		existing_slot.equipped = existing_slot.equipped and existing_slot.unlocked

		return
	end

	self._global.crafted_items[category] = self._global.crafted_items[category] or {}
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
	self._global.crafted_items[category][slot] = {
		weapon_id = weapon_id,
		factory_id = factory_id,
		blueprint = blueprint,
		unlocked = unlocked,
		global_values = {}
	}
end

function BlackMarketManager:get_melee_weapon_data(melee_weapon_id)
	return tweak_data.blackmarket.melee_weapons[melee_weapon_id]
end

function BlackMarketManager:set_melee_weapon_favorite(melee_weapon_id, favorite)
	local weapon_data = self._global.melee_weapons[melee_weapon_id]

	if weapon_data then
		weapon_data.is_favorite = favorite
	end
end

function BlackMarketManager:get_sorted_grenades(hide_locked)
	local sort_data = {}
	local xd, yd, x_td, y_td, x_sn, y_sn, x_gv, y_gv = nil
	local m_tweak_data = tweak_data.projectiles
	local l_tweak_data = tweak_data.lootdrop.global_values

	for id, d in pairs(Global.blackmarket_manager.grenades) do
		if not hide_locked or d.unlocked then
			table.insert(sort_data, {
				id,
				d
			})
		end
	end

	table.sort(sort_data, function (x, y)
		xd = x[2]
		yd = y[2]
		x_td = m_tweak_data[x[1]]
		y_td = m_tweak_data[y[1]]

		if xd.unlocked ~= yd.unlocked then
			return xd.unlocked
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = l_tweak_data[x_gv]
		y_sn = l_tweak_data[y_gv]
		x_sn = x_sn and x_sn.sort_number or 1
		y_sn = y_sn and y_sn.sort_number or 1

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		return x[1] < y[1]
	end)

	return sort_data
end

function BlackMarketManager:get_sorted_armors(hide_locked)
	local sort_data = {}

	for id, d in pairs(Global.blackmarket_manager.armors) do
		if not hide_locked or d.unlocked then
			table.insert(sort_data, id)
		end
	end

	local armor_level_data = {}

	for level, data in pairs(tweak_data.upgrades.level_tree) do
		if data.upgrades then
			for _, upgrade in ipairs(data.upgrades) do
				local def = tweak_data.upgrades.definitions[upgrade]

				if not def then
					Application:error("Upgrade listed in level tree, but not defined:   ", upgrade)
				elseif def.armor_id then
					armor_level_data[def.armor_id] = level
				end
			end
		end
	end

	table.sort(sort_data, function (x, y)
		local x_level = x == "level_1" and 0 or armor_level_data[x] or 100
		local y_level = y == "level_1" and 0 or armor_level_data[y] or 100

		return x_level < y_level
	end)

	return sort_data, armor_level_data
end

function BlackMarketManager:get_sorted_deployables(hide_locked)
	local sort_data = {}

	for id, d in pairs(tweak_data.blackmarket.deployables) do
		if not hide_locked or table.contains(managers.player:availible_equipment(1), id) then
			table.insert(sort_data, {
				id,
				d
			})
		end
	end

	table.sort(sort_data, function (x, y)
		return x[1] < y[1]
	end)

	return sort_data
end

function BlackMarketManager:get_hold_crafted_item()
	return self._hold_crafted_item
end

function BlackMarketManager:drop_hold_crafted_item()
	self._hold_crafted_item = nil
end

function BlackMarketManager:pickup_crafted_item(category, slot)
	self._hold_crafted_item = {
		category = category,
		slot = slot
	}
end

function BlackMarketManager:place_crafted_item(category, slot)
	if not self._hold_crafted_item then
		return
	end

	if self._hold_crafted_item.category ~= category then
		return
	end

	local tmp = self:get_crafted_category_slot(category, slot)
	self._global.crafted_items[category][slot] = self:get_crafted_category_slot(self._hold_crafted_item.category, self._hold_crafted_item.slot)
	self._global.crafted_items[self._hold_crafted_item.category][self._hold_crafted_item.slot] = tmp
	tmp, self._hold_crafted_item = nil
end

function BlackMarketManager:on_aquired_armor(upgrade, id, loading)
	if not self._global.armors[upgrade.armor_id] then
		Application:error("[BlackMarketManager:on_aquired_armor] Armor do not exist in blackmarket", "armor_id", upgrade.armor_id)

		return
	end

	self._global.armors[upgrade.armor_id].unlocked = true
	self._global.armors[upgrade.armor_id].owned = true
end

function BlackMarketManager:on_unaquired_armor(upgrade, id)
	self._global.armors[upgrade.armor_id].unlocked = false
	self._global.armors[upgrade.armor_id].owned = false

	if self._global.armors[upgrade.armor_id].equipped then
		self._global.armors[upgrade.armor_id].equipped = false
		self._global.armors[self._defaults.armor].owned = true
		self._global.armors[self._defaults.armor].equipped = true
		self._global.armors[self._defaults.armor].unlocked = true

		MenuCallbackHandler:_update_outfit_information()
	end
end

function BlackMarketManager:_verify_preferred_characters()
	local used_characters = {}
	local preferred_characters = {}
	local character, new_name, char_tweak = nil

	for i = 1, CriminalsManager.MAX_NR_CRIMINALS do
		character = self._global._preferred_characters[i]

		if not character or used_characters[character] then
			break
		end

		new_name = CriminalsManager.convert_old_to_new_character_workname(character)
		char_tweak = tweak_data.blackmarket.characters.american[new_name] or tweak_data.blackmarket.characters[new_name]

		if char_tweak.dlc and not managers.dlc:is_dlc_unlocked(char_tweak.dlc) then
			break
		end

		preferred_characters[i] = self._global._preferred_characters[i]
		used_characters[self._global._preferred_characters[i]] = true
	end

	self._global._preferred_characters = preferred_characters
	self._global._preferred_characters[1] = self._global._preferred_characters[1] or self._defaults.preferred_character
end

function BlackMarketManager:_update_preferred_character(update_character)
	self:_verify_preferred_characters()

	if update_character then
		local character = self._global._preferred_characters[1]
		local new_name = CriminalsManager.convert_old_to_new_character_workname(character)
		self._global._preferred_character = character

		if tweak_data.blackmarket.characters.american[new_name] then
			if self:equipped_character() ~= "american" then
				self:equip_character("american")
			end
		elseif self:equipped_character() ~= character then
			self:equip_character(character)
		end
	end

	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:swap_preferred_character(first_index, second_index)
	local temp = self._global._preferred_characters[first_index]
	self._global._preferred_characters[first_index] = self._global._preferred_characters[second_index]
	self._global._preferred_characters[second_index] = temp

	self:_update_preferred_character(first_index == 1 or second_index == 1)
end

function BlackMarketManager:clear_preferred_characters()
	local update_menu_scene = self._global._preferred_characters[1] == self._defaults.preferred_character
	self._global._preferred_characters = {}

	self:_update_preferred_character(update_menu_scene)
end

function BlackMarketManager:set_preferred_character(character, index)
	local new_name = CriminalsManager.convert_old_to_new_character_workname(character)
	local char_tweak = tweak_data.blackmarket.characters.american[new_name] or tweak_data.blackmarket.characters[new_name]

	if char_tweak.dlc and not managers.dlc:is_dlc_unlocked(char_tweak.dlc) then
		return
	end

	index = index or 1

	if not character and index == 1 then
		character = self._defaults.preferred_character or character
	end

	self._global._preferred_characters[index] = character

	self:_update_preferred_character(index == 1)
end

function BlackMarketManager:get_character_id_by_character_name(character_name)
	local new_name = CriminalsManager.convert_old_to_new_character_workname(character_name)

	if tweak_data.blackmarket.characters.american[new_name] then
		return "american"
	end

	return character_name
end

function BlackMarketManager:get_preferred_characters_list()
	return clone(self._global._preferred_characters)
end

function BlackMarketManager:num_preferred_characters()
	return #self._global._preferred_characters
end

function BlackMarketManager:get_preferred_character(index)
	return self._global._preferred_characters and self._global._preferred_characters[index or 1] or self._global._preferred_character or self._defaults.preferred_character
end

function BlackMarketManager:get_preferred_character_string()
	if not self._global._preferred_characters then
		return self._global._preferred_character or self._defaults.preferred_character
	end

	local s = ""

	for i, character in ipairs(self._global._preferred_characters) do
		s = s .. character

		if i < #self._global._preferred_characters then
			s = s .. " "
		end
	end

	return s
end

function BlackMarketManager:get_preferred_character_real_name(index)
	return managers.localization:text("menu_" .. tostring(self:get_preferred_character(index) or self._defaults.preferred_character))
end

function BlackMarketManager:get_category_default(category)
	return self._defaults and self._defaults[category]
end

function BlackMarketManager:get_weapon_texture_switches(category, slot, weapon)
	weapon = weapon or self._global.crafted_items[category] and self._global.crafted_items[category][slot]

	if not weapon then
		return
	end

	return weapon.texture_switches
end

function BlackMarketManager:character_sequence_by_character_id(character_id, peer_id)
	if not peer_id and character_id ~= "american" then
		return tweak_data.blackmarket.characters[character_id].sequence
	end

	local character = self:get_preferred_character()

	if managers.network and managers.network:session() and peer_id then
		print("character_sequence_by_character_id", managers.network:session(), peer_id, character)

		local peer = managers.network:session():peer(peer_id)

		if peer then
			character = peer:character() or character

			if not peer:character() then
				Application:error("character_sequence_by_character_id: Peer missing character", "peer_id", peer_id)
				print(inspect(peer))
			end
		end
	end

	character = CriminalsManager.convert_old_to_new_character_workname(character)

	print("character_sequence_by_character_id", "character", character, "character_id", character_id)

	if tweak_data.blackmarket.characters.american[character] then
		return tweak_data.blackmarket.characters.american[character].sequence
	end

	return tweak_data.blackmarket.characters[character].sequence
end

function BlackMarketManager:character_sequence_by_character_name(character, peer_id)
	if managers.network and managers.network:session() and peer_id then
		print("character_sequence_by_character_name", managers.network:session(), peer_id, character_name)

		local peer = managers.network:session():peer(peer_id)

		if peer then
			character = peer:character() or character

			if not peer:character() then
				Application:error("character_sequence_by_character_name: Peer missing character", "peer_id", peer_id)
				print(inspect(peer))
			end
		end
	end

	character = CriminalsManager.convert_old_to_new_character_workname(character)

	if tweak_data.blackmarket.characters.american[character] then
		return tweak_data.blackmarket.characters.american[character].sequence
	end

	return tweak_data.blackmarket.characters[character].sequence
end

function BlackMarketManager:tradable_outfit()
	local outfit = {}
	local primary = self:equipped_primary()

	if primary and primary.cosmetics then
		table.insert(outfit, primary.cosmetics.instance_id)
	end

	local secondary = self:equipped_secondary()

	if secondary and secondary.cosmetics then
		table.insert(outfit, secondary.cosmetics.instance_id)
	end

	return outfit
end

function BlackMarketManager:reset()
	self._global.crafted_items = {}

	self:_setup_weapons()
	self:_setup_characters()
	self:_setup_armors()
	self:_setup_grenades()
	self:_setup_melee_weapons()
	self:_setup_unlocked_weapon_slots()
	self:_verfify_equipped()
end

function BlackMarketManager:reset_equipped()
	self:_setup_weapons()
	self:_setup_armors()
	self:_setup_grenades()
	self:_setup_melee_weapons()
	managers.dlc:give_dlc_package()
	self:_verify_dlc_items()
	self:_verfify_equipped()
end

function BlackMarketManager:save(data)
	local save_data = deep_clone(self._global)
	save_data.equipped_armor = self:equipped_armor()
	save_data.equipped_grenade = self:equipped_grenade()
	save_data.equipped_melee_weapon = self:equipped_melee_weapon()
	save_data.armors = nil
	save_data.grenades = nil
	save_data.melee_weapons = nil
	save_data.weapon_upgrades = nil
	save_data.weapons = nil
	data.blackmarket = save_data
end

function BlackMarketManager:load(data)
	self:_setup()

	if not data.blackmarket then
		return
	end

	local default_global = self._global or {}
	Global.blackmarket_manager = data.blackmarket
	self._global = Global.blackmarket_manager

	if self._global.equipped_armor and type(self._global.equipped_armor) ~= "string" then
		self._global.equipped_armor = nil
	end

	self._global.armors = default_global.armors or {}

	for armor, _ in pairs(tweak_data.blackmarket.armors) do
		if not self._global.armors[armor] then
			self._global.armors[armor] = {
				owned = false,
				unlocked = false,
				equipped = false
			}
		else
			self._global.armors[armor].equipped = false
		end
	end

	if not self._global.equipped_armor or not self._global.armors[self._global.equipped_armor] then
		self._global.equipped_armor = self._defaults.armor
	end

	self._global.armors[self._global.equipped_armor].equipped = true
	self._global.equipped_armor = nil
	self._global.grenades = default_global.grenades or {}

	if self._global.grenades[self._defaults.grenade] then
		self._global.grenades[self._defaults.grenade].equipped = false
	end

	local equipped_grenade_id = self._global.equipped_grenade or self._defaults.grenade

	for grenade, data in pairs(self._global.grenades) do
		self._global.grenades[grenade].skill_based = false
		self._global.grenades[grenade].equipped = grenade == equipped_grenade_id
	end

	self._global.equipped_grenade = nil
	self._global.melee_weapons = default_global.melee_weapons or {}

	if self._global.melee_weapons[self._defaults.melee_weapon] then
		self._global.melee_weapons[self._defaults.melee_weapon].equipped = false
	end

	if self._global.melee_weapons[self._global.equipped_melee_weapon] then
		self._global.melee_weapons[self._global.equipped_melee_weapon].equipped = true
	else
		self._global.melee_weapons[self._defaults.melee_weapon].equipped = true
	end

	for melee_weapon, data in pairs(self._global.melee_weapons) do
		local is_default, melee_weapon_level = managers.upgrades:get_value(melee_weapon)
		self._global.melee_weapons[melee_weapon].level = melee_weapon_level
		self._global.melee_weapons[melee_weapon].skill_based = not is_default and melee_weapon_level == 0 and not tweak_data.blackmarket.melee_weapons[melee_weapon].dlc and not tweak_data.blackmarket.melee_weapons[melee_weapon].free
	end

	self._global.equipped_melee_weapon = nil
	self._global.weapons = default_global.weapons or {}

	for weapon, data in pairs(tweak_data.weapon) do
		if not self._global.weapons[weapon] and data.autohit then
			local selection_index = data.use_data.selection_index
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon)
			self._global.weapons[weapon] = {
				owned = false,
				equipped = false,
				unlocked = false,
				factory_id = factory_id,
				selection_index = selection_index
			}
		end
	end

	for weapon, data in pairs(self._global.weapons) do
		local is_default, weapon_level, got_parent = managers.upgrades:get_value(weapon)
		self._global.weapons[weapon].level = weapon_level
		self._global.weapons[weapon].skill_based = got_parent or not is_default and weapon_level == 0 and not tweak_data.weapon[weapon].global_value
	end

	self._global._preferred_character = self._global._preferred_character or self._defaults.preferred_character
	local character_name = CriminalsManager.convert_old_to_new_character_workname(self._global._preferred_character)

	if not tweak_data.blackmarket.characters.american[character_name] and not tweak_data.blackmarket.characters[character_name] then
		self._global._preferred_character = self._defaults.preferred_character
	end

	self._global._preferred_characters = self._global._preferred_characters or {
		self._global._preferred_character
	}

	for i, character in pairs(clone(self._global._preferred_characters)) do
		local character_name = CriminalsManager.convert_old_to_new_character_workname(character)

		if not tweak_data.blackmarket.characters.american[character_name] and not tweak_data.blackmarket.characters[character_name] then
			self._global._preferred_characters[i] = self._defaults.preferred_character
		end
	end

	for character, _ in pairs(tweak_data.blackmarket.characters) do
		if not self._global.characters[character] then
			self._global.characters[character] = {
				owned = true,
				unlocked = true,
				equipped = false
			}
		end
	end

	for character, _ in pairs(clone(self._global.characters)) do
		if not tweak_data.blackmarket.characters[character] then
			self._global.characters[character] = nil
		end
	end

	if not self:equipped_character() then
		self._global.characters[self._defaults.character].equipped = true
	end

	managers.weapon_inventory:add_all_weapons_to_player_inventory()

	if not self._global.unlocked_weapon_slots then
		self:_setup_unlocked_weapon_slots()
	end

	local list_of_weapons_factory_ids = {}

	for bm_weapon_index, bm_weapon_data in ipairs(self._global.crafted_items.primaries) do
		if not list_of_weapons_factory_ids[bm_weapon_data.factory_id] then
			list_of_weapons_factory_ids[bm_weapon_data.factory_id] = true
		else
			table.remove(self._global.crafted_items.primaries, bm_weapon_index)
			table.remove(Global.blackmarket_manager.crafted_items.primaries, bm_weapon_index)
			managers.savefile:set_resave_required()
		end
	end
end

function BlackMarketManager:_load_done()
	Application:debug("BlackMarketManager:_load_done()")

	if managers.savefile:get_active_characters_count() == 0 then
		self:aquire_default_weapons()
	end

	self:_verfify_equipped()
	MenuCallbackHandler:_update_outfit_information()
end

function BlackMarketManager:verify_dlc_items()
	self:_cleanup_blackmarket()

	if self._refill_global_values then
		self._refill_global_values = nil
	end

	self:_verify_dlc_items()
	self:_load_done()
end

function BlackMarketManager:_cleanup_blackmarket()
	local crafted_items = self._global.crafted_items

	for category, data in pairs(crafted_items) do
		if not data or type(data) ~= "table" then
			Application:error("BlackMarketManager:_cleanup_blackmarket() Crafted items category invalid", "category", category, "data", inspect(data))

			self._global.crafted_items[category] = {}
		end
	end

	local function chk_global_value_func(global_value)
		return tweak_data.lootdrop.global_values[global_value or "normal"] and true or false
	end

	local invalid_weapons = {}
	local invalid_parts = {}

	local function invalid_add_weapon_remove_parts_func(slot, item, part_id)
		table.insert(invalid_weapons, slot)
		Application:error("BlackMarketManager:_cleanup_blackmarket() Part non-existent, weapon invalid", "weapon_id", item.weapon_id, "slot", slot)

		for i = #invalid_parts, 1, -1 do
			if invalid_parts[i] and invalid_parts[i].slot == slot then
				Application:error("removing part from invalid_parts", "part_id", part_id)
				table.remove(invalid_parts, i)
			end
		end
	end

	local factory = tweak_data.weapon.factory

	for _, category in ipairs({
		"primaries",
		"secondaries"
	}) do
		local crafted_category = self._global.crafted_items[category]
		invalid_weapons = {}
		invalid_parts = {}

		if crafted_category then
			for slot, item in pairs(crafted_category) do
				local factory_id = item.factory_id
				local weapon_id = item.weapon_id
				local blueprint = item.blueprint
				local global_values = item.global_values or {}
				local texture_switches = item.texture_switches
				local cosmetics = item.cosmetics
				local index_table = {}
				local weapon_invalid = not tweak_data.weapon[weapon_id] or not tweak_data.weapon.factory[factory_id] or managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id) ~= factory_id or managers.weapon_factory:get_weapon_id_by_factory_id(factory_id) ~= weapon_id or not chk_global_value_func(tweak_data.weapon[weapon_id].global_value)

				if weapon_invalid then
					table.insert(invalid_weapons, slot)
				else
					item.global_values = item.global_values or {}

					for i, part_id in ipairs(factory[factory_id].uses_parts) do
						index_table[part_id] = i
					end

					for i, part_id in ipairs(blueprint) do
						if not index_table[part_id] or not chk_global_value_func(item.global_values[part_id]) then
							Application:error("BlackMarketManager:_cleanup_blackmarket() Weapon part no longer in uses parts or bad global value", "part_id", part_id, "weapon_id", item.weapon_id, "part_global_value", item.global_values[part_id])

							local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

							if table.contains(default_blueprint, part_id) then
								invalid_add_weapon_remove_parts_func(slot, item, part_id)

								break
							else
								local default_mod = nil

								if tweak_data.weapon.factory.parts[part_id] then
									local ids_id = Idstring(tweak_data.weapon.factory.parts[part_id].type)

									for i, d_mod in ipairs(default_blueprint) do
										if Idstring(tweak_data.weapon.factory.parts[d_mod].type) == ids_id then
											default_mod = d_mod

											break
										end
									end

									if default_mod then
										table.insert(invalid_parts, {
											global_value = "normal",
											slot = slot,
											default_mod = default_mod,
											part_id = part_id
										})
									else
										table.insert(invalid_parts, {
											slot = slot,
											global_value = item.global_values[part_id] or "normal",
											part_id = part_id
										})
									end
								else
									invalid_add_weapon_remove_parts_func(slot, item, part_id)

									break
								end
							end
						end
					end
				end
			end
		end
	end
end

function BlackMarketManager:test_clean()
end

function BlackMarketManager:_verify_dlc_items()
	return

	local equipped_primary = self:equipped_primary()
	local equipped_secondary = self:equipped_secondary()
	local equipped_primary_slot = self:equipped_weapon_slot("primaries")
	local equipped_secondary_slot = self:equipped_weapon_slot("secondaries")
	local locked_equipped = {
		secondaries = false,
		primaries = false
	}
	local locked_weapons = {
		primaries = {},
		secondaries = {}
	}
	local owns_dlc = nil

	for package_id, data in pairs(tweak_data.dlc.descriptions) do
		if tweak_data.lootdrop.global_values[package_id] then
			owns_dlc = not tweak_data.lootdrop.global_values[package_id].dlc or managers.dlc:is_dlc_unlocked(package_id) or false

			print("owns_dlc", owns_dlc, "dlc", package_id, "is a dlc", tweak_data.lootdrop.global_values[package_id].dlc, "is free", data.free, "is_dlc_unlocked", managers.dlc:is_dlc_unlocked(package_id))

			if owns_dlc then
				-- Nothing
			elseif self._global.global_value_items[package_id] then
				print("You do not own " .. package_id .. ", will lock all related items.")

				local all_crafted_items = self._global.global_value_items[package_id].crafted_items or {}
				local primaries = all_crafted_items.primaries or {}
				local secondaries = all_crafted_items.secondaries or {}

				for slot, parts in pairs(primaries) do
					locked_weapons.primaries[slot] = true
					locked_equipped.primaries = locked_equipped.primaries or equipped_primary_slot == slot
				end

				for slot, parts in pairs(secondaries) do
					locked_weapons.secondaries[slot] = true
					locked_equipped.secondaries = locked_equipped.secondaries or equipped_secondary_slot == slot
				end
			end
		end
	end

	self._global._preferred_character = self._global._preferred_character or self._defaults.preferred_character
	local character_name = CriminalsManager.convert_old_to_new_character_workname(self._global._preferred_character)
	local char_tweak = tweak_data.blackmarket.characters.american[character_name] or tweak_data.blackmarket.characters[character_name]

	if char_tweak.dlc and not managers.dlc:is_dlc_unlocked(char_tweak.dlc) then
		self._global._preferred_character = self._defaults.preferred_character
	end

	self:_verify_preferred_characters()

	local player_level = managers.experience:current_level()
	local unlocked, level, skill_based, weapon_def, weapon_dlc, has_dlc = nil

	for weapon_id, weapon in pairs(Global.blackmarket_manager.weapons) do
		unlocked = weapon.unlocked
		level = weapon.level
		skill_based = weapon.skill_based

		if not unlocked and level <= player_level and not skill_based then
			weapon_def = tweak_data.upgrades.definitions[weapon_id]

			if weapon_def then
				weapon_dlc = weapon_def.dlc

				if weapon_dlc then
					managers.upgrades:aquire(weapon_id, nil, UpgradesManager.AQUIRE_STRINGS[1])

					Global.blackmarket_manager.weapons[weapon_id].unlocked = managers.dlc:is_dlc_unlocked(weapon_dlc) or false
				else
					Application:error("[BlackMarketManager] Weapon locked by unknown source: " .. tostring(weapon_id))
				end
			else
				Application:error("[BlackMarketManager] Missing definition for weapon: " .. tostring(weapon_id))
			end
		end
	end

	local found_new_weapon = nil

	for category, locked in pairs(locked_equipped) do
		if locked then
			found_new_weapon = false

			for slot, crafted in pairs(self._global.crafted_items[category]) do
				if not locked_weapons[category][slot] and Global.blackmarket_manager.weapons[crafted.weapon_id].unlocked then
					found_new_weapon = true

					self:equip_weapon(category, slot)

					break
				end
			end

			if not found_new_weapon then
				local free_slot = self:_get_free_weapon_slot(category) or 1
				local weapon_id = category == "primaries" and BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID or BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID
				local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
				local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
				self._global.crafted_items[category][free_slot] = {
					equipped = true,
					weapon_id = weapon_id,
					factory_id = factory_id,
					blueprint = blueprint
				}

				managers.statistics:publish_equipped_to_steam()
			end
		end
	end
end

function BlackMarketManager:_verfify_equipped()
	self:_verfify_equipped_category("secondaries")
	self:_verfify_equipped_category("primaries")
	self:_verfify_equipped_category("armors")
	self:_verfify_equipped_category("grenades")
	self:_verfify_equipped_category("melee_weapons")
end

function BlackMarketManager:_verfify_equipped_category(category)
	if category == "armors" then
		local armor_id = self._defaults.armor

		for armor, craft in pairs(Global.blackmarket_manager.armors) do
			if craft.equipped and craft.unlocked and craft.owned then
				armor_id = armor
			end
		end

		for s, data in pairs(Global.blackmarket_manager.armors) do
			data.equipped = s == armor_id
		end

		managers.statistics:publish_equipped_to_steam()

		return
	end

	if category == "grenades" then
		local grenade_id = self._defaults.grenade

		for grenade, craft in pairs(Global.blackmarket_manager.grenades) do
			if craft.equipped and craft.unlocked then
				grenade_id = grenade
			end

			local grenade_data = tweak_data.projectiles[grenade] or {}
			craft.amount = (not grenade_data.dlc or managers.dlc:is_dlc_unlocked(grenade_data.dlc)) and managers.player:get_max_grenades(grenade) or 0
		end

		for s, data in pairs(Global.blackmarket_manager.grenades) do
			data.equipped = s == grenade_id
		end

		managers.statistics:publish_equipped_to_steam()

		return
	end

	if category == "melee_weapons" then
		local melee_weapon_id = self._defaults.melee_weapon

		for melee_weapon, craft in pairs(Global.blackmarket_manager.melee_weapons) do
			local melee_weapon_data = tweak_data.blackmarket.melee_weapons[melee_weapon] or {}

			if craft.equipped and craft.unlocked and (not melee_weapon_data.dlc or tweak_data.dlc:is_melee_weapon_unlocked(melee_weapon)) then
				melee_weapon_id = melee_weapon
			end
		end

		for s, data in pairs(Global.blackmarket_manager.melee_weapons) do
			data.equipped = s == melee_weapon_id
		end

		managers.statistics:publish_equipped_to_steam()

		return
	end

	if not self._global.crafted_items[category] then
		return
	end

	local is_weapon = category == "secondaries" or category == "primaries"

	if not is_weapon then
		for slot, craft in pairs(self._global.crafted_items[category]) do
			if craft.equipped then
				return
			end
		end

		local slot, craft = next(self._global.crafted_items[category])

		print("  Equip", category, slot)

		craft.equipped = true

		return
	end

	for slot, craft in pairs(self._global.crafted_items[category]) do
		if craft.equipped then
			if self:weapon_unlocked_by_crafted(category, slot) then
				return
			else
				craft.equipped = false
			end
		end
	end

	local character_class = managers.skilltree:get_character_profile_class()

	if character_class then
		local equipped = false

		if category == "primaries" then
			equipped = self:equip_class_default_primary()
		elseif category == "secondaries" then
			equipped = self:equip_class_default_secondary()
		end

		if equipped then
			return
		end
	end

	for slot, craft in pairs(self._global.crafted_items[category]) do
		if self:weapon_unlocked_by_crafted(category, slot) then
			print("  Equip", category, slot)

			craft.equipped = true

			return
		end
	end

	local free_slot = self:_get_free_weapon_slot(category) or 1
	local weapon_id = category == "primaries" and BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID or BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
	self._global.crafted_items[category][free_slot] = {
		equipped = true,
		weapon_id = weapon_id,
		factory_id = factory_id,
		blueprint = blueprint
	}

	managers.statistics:publish_equipped_to_steam()
end

function BlackMarketManager:_convert_add_to_mul(value)
	if value > 1 then
		return 1 / value
	elseif value < 1 then
		return math.abs(value - 1) + 1
	else
		return 1
	end
end

function BlackMarketManager:fire_rate_multiplier(name, category, silencer, detection_risk, current_state, blueprint)
	local multiplier = managers.player:upgrade_value(category, "fire_rate_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(name, "fire_rate_multiplier", 1)

	return multiplier
end

function BlackMarketManager:damage_addend(name, category, silencer, detection_risk, current_state, blueprint)
	local value = 0

	if tweak_data.weapon[name] and tweak_data.weapon[name].ignore_damage_upgrades then
		return value
	end

	value = value + managers.player:upgrade_value("player", "damage_addend", 0)
	value = value + managers.player:upgrade_value("weapon", "damage_addend", 0)
	value = value + managers.player:upgrade_value(category, "damage_addend", 0)
	value = value + managers.player:upgrade_value(name, "damage_addend", 0)

	return value
end

function BlackMarketManager:damage_multiplier(name, category, silencer, detection_risk, current_state, blueprint)
	local multiplier = 1

	if tweak_data.weapon[name] and tweak_data.weapon[name].ignore_damage_upgrades then
		return multiplier
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value(category, "damage_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(name, "damage_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("player", "passive_damage_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_damage_multiplier", 1)

	if silencer then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "silencer_damage_multiplier", 1)
	end

	if managers.player and managers.player:local_player() and managers.player:local_player():inventory() then
		if managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
			multiplier = multiplier + 1 - managers.player:upgrade_value("primary_weapon", "damage_multiplier", 1)
		elseif managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			multiplier = multiplier + 1 - managers.player:upgrade_value("secondary_weapon", "damage_multiplier", 1)
		end
	end

	local detection_risk_damage_multiplier = managers.player:upgrade_value("player", "detection_risk_damage_multiplier")
	multiplier = multiplier - managers.player:get_value_from_risk_upgrade(detection_risk_damage_multiplier, detection_risk)

	if managers.player:has_category_upgrade("player", "overkill_health_to_damage_multiplier") then
		local damage_ratio = managers.player:upgrade_value("player", "overkill_health_to_damage_multiplier", 1) - 1
		multiplier = multiplier + damage_ratio
	end

	if current_state then
		if not current_state:in_steelsight() then
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "hip_fire_damage_multiplier", 1)
		end
	end

	if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "modded_damage_multiplier", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "revived_damage_bonus") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "revived_damage_bonus", 1)
	end

	if managers.player:has_active_temporary_property("dmg_mul") then
		multiplier = multiplier + 1 - managers.player:get_temporary_property("dmg_mul")
	end

	return self:_convert_add_to_mul(multiplier)
end

function BlackMarketManager:threat_multiplier(name, category, silencer)
	local multiplier = 1
	multiplier = multiplier + 1 - managers.player:upgrade_value("player", "suppression_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("player", "suppression_multiplier2", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("player", "passive_suppression_multiplier", 1)

	return self:_convert_add_to_mul(multiplier)
end

function BlackMarketManager:accuracy_addend(name, category, spread_index, silencer, current_state, fire_mode, blueprint)
	local addend = 0

	if spread_index and spread_index >= 1 and spread_index <= (current_state and current_state._moving and #tweak_data.weapon.stats.spread_moving or #tweak_data.weapon.stats.spread) then
		local index = spread_index
		index = index + managers.player:upgrade_value("weapon", "spread_index_addend", 0)
		index = index + managers.player:upgrade_value(category, "spread_index_addend", 0)
		index = index + managers.player:upgrade_value("weapon", fire_mode .. "_spread_index_addend", 0)
		index = index + managers.player:upgrade_value(category, fire_mode .. "_spread_index_addend", 0)

		if silencer then
			index = index + managers.player:upgrade_value("weapon", "silencer_spread_index_addend", 0)
			index = index + managers.player:upgrade_value(category, "silencer_spread_index_addend", 0)
		end

		if current_state and current_state._moving then
			index = index + managers.player:upgrade_value("weapon", "move_spread_index_addend", 0)
			index = index + managers.player:upgrade_value(category, "move_spread_index_addend", 0)
		end

		index = math.clamp(index, 1, #tweak_data.weapon.stats.spread)

		if index ~= spread_index then
			local diff = tweak_data.weapon.stats.spread[index] - tweak_data.weapon.stats.spread[spread_index]
			addend = addend + diff
		end
	end

	return addend
end

function BlackMarketManager:accuracy_multiplier(name, category, silencer, current_state, spread_moving, fire_mode, blueprint)
	local multiplier = 1

	if current_state then
		if current_state._moving then
			multiplier = multiplier * managers.player:upgrade_value(category, "move_spread_multiplier", 1)
			multiplier = multiplier * managers.player:team_upgrade_value("weapon", "move_spread_multiplier", 1)
		end

		if current_state:in_steelsight() then
			multiplier = multiplier * tweak_data.weapon[name].spread[current_state._moving and "moving_steelsight" or "steelsight"]
		else
			multiplier = multiplier * managers.player:upgrade_value(category, "hip_fire_spread_multiplier", 1)

			if current_state._state_data.ducking and not current_state._unit_deploy_position then
				if current_state._moving then
					multiplier = multiplier * tweak_data.weapon[name].spread.moving_crouching
				else
					multiplier = multiplier * tweak_data.weapon[name].spread.crouching
				end
			elseif current_state._moving then
				multiplier = multiplier * tweak_data.weapon[name].spread.moving_standing
			else
				multiplier = multiplier * tweak_data.weapon[name].spread.standing
			end
		end
	end

	multiplier = multiplier * managers.player:upgrade_value("weapon", "spread_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(category, "spread_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("weapon", fire_mode .. "_spread_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(name, "spread_multiplier", 1)

	if managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		multiplier = multiplier * managers.player:upgrade_value("primary_weapon", "spread_multiplier", 1)
	elseif managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		multiplier = multiplier * managers.player:upgrade_value("secondary_weapon", "spread_multiplier", 1)
	end

	if silencer then
		multiplier = multiplier * managers.player:upgrade_value("weapon", "silencer_spread_multiplier", 1)
		multiplier = multiplier * managers.player:upgrade_value(category, "silencer_spread_multiplier", 1)
	end

	if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
		multiplier = multiplier * managers.player:upgrade_value("weapon", "modded_spread_multiplier", 1)
	end

	return multiplier
end

function BlackMarketManager:recoil_addend(name, category, recoil_index, silencer, blueprint)
	local addend = 0

	if recoil_index and recoil_index >= 1 and recoil_index <= #tweak_data.weapon.stats.recoil then
		local index = recoil_index
		index = index + managers.player:upgrade_value("weapon", "recoil_index_addend", 0)
		index = index + managers.player:upgrade_value(category, "recoil_index_addend", 0)
		index = index + managers.player:upgrade_value(name, "recoil_index_addend", 0)

		if managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
			if managers.player:has_team_category_upgrade(category, "suppression_recoil_index_addend") then
				index = index + managers.player:team_upgrade_value(category, "suppression_recoil_index_addend", 0)
			end

			if managers.player:has_team_category_upgrade("weapon", "suppression_recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "suppression_recoil_index_addend", 0)
			end
		else
			if managers.player:has_team_category_upgrade(category, "recoil_index_addend") then
				index = index + managers.player:team_upgrade_value(category, "recoil_index_addend", 0)
			end

			if managers.player:has_team_category_upgrade("weapon", "recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "recoil_index_addend", 0)
			end
		end

		if silencer then
			index = index + managers.player:upgrade_value("weapon", "silencer_recoil_index_addend", 0)
			index = index + managers.player:upgrade_value(category, "silencer_recoil_index_addend", 0)
		end

		if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
			index = index + managers.player:upgrade_value("weapon", "modded_recoil_index_addend", 0)
		end

		index = math.clamp(index, 1, #tweak_data.weapon.stats.recoil)

		if index ~= recoil_index then
			local diff = tweak_data.weapon.stats.recoil[index] - tweak_data.weapon.stats.recoil[recoil_index]
			addend = addend + diff
		end
	end

	return addend
end

function BlackMarketManager:recoil_multiplier(name, category, silencer, blueprint)
	local multiplier = 1
	multiplier = multiplier + 1 - managers.player:upgrade_value(category, "recoil_reduction", 1)

	if managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
		if managers.player:has_team_category_upgrade(category, "suppression_recoil_multiplier") then
			multiplier = multiplier + 1 - managers.player:team_upgrade_value(category, "suppression_recoil_multiplier", 1)
		end

		if managers.player:has_team_category_upgrade("weapon", "suppression_recoil_multiplier") then
			multiplier = multiplier + 1 - managers.player:team_upgrade_value("weapon", "suppression_recoil_multiplier", 1)
		end
	else
		if managers.player:has_team_category_upgrade(category, "recoil_multiplier") then
			multiplier = multiplier + 1 - managers.player:team_upgrade_value(category, "recoil_multiplier", 1)
		end

		if managers.player:has_team_category_upgrade("weapon", "recoil_multiplier") then
			multiplier = multiplier + 1 - managers.player:team_upgrade_value("weapon", "recoil_multiplier", 1)
		end
	end

	if managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		multiplier = multiplier + 1 - managers.player:upgrade_value("primary_weapon", "recoil_reduction", 1)
	elseif managers.player:local_player():inventory():equipped_selection() == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		multiplier = multiplier + 1 - managers.player:upgrade_value("secondary_weapon", "recoil_reduction", 1)
	end

	if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "modded_recoil_multiplier", 1)
	end

	return self:_convert_add_to_mul(multiplier)
end
