BlackMarketManager = BlackMarketManager or class()
BlackMarketManager.DEFAULT_PRIMARY_WEAPON_ID = "thompson"
BlackMarketManager.DEFAULT_SECONDARY_WEAPON_ID = "m1911"
BlackMarketManager.DEFAULT_PRIMARY_FACTORY_ID = "wpn_fps_smg_thompson"
BlackMarketManager.DEFAULT_SECONDARY_FACTORY_ID = "wpn_fps_pis_m1911"
BlackMarketManager.OUTFIT_INDEX_MAP = {
	secondary_blueprint = 6,
	secondary = 5,
	primary_blueprint = 4,
	primary = 3,
	character = 2,
	armor = 1,
	character_customization_nationality = 17,
	character_customization_lower = 16,
	character_customization_upper = 15,
	character_customization_head = 14,
	warcry_weapon = 13,
	grenade_cosmetic = 12,
	grenade = 11,
	melee_weapon = 10,
	concealment_modifier = 9,
	deployable_amount = 8,
	deployable = 7
}

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
	managers.network.account:inventory_load()
end

function BlackMarketManager:_setup_armors()
	local armors = {}
	Global.blackmarket_manager.armors = armors

	for armor, _ in pairs(tweak_data.blackmarket.armors) do
		armors[armor] = {
			unlocked = false,
			equipped = false,
			owned = false
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
				unlocked = true,
				equipped = false,
				amount = 0,
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
			skill_based = false,
			equipped = false,
			owned = true,
			durability = 1,
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
			unlocked = true,
			equipped = false,
			owned = true
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

	for k, v in pairs(tweak_data.weapon_inventory.weapon_primaries_index) do
		unlocked_weapon_slots.primaries[v.slot] = true
	end

	for k, v in pairs(tweak_data.weapon_inventory.weapon_secondaries_index) do
		unlocked_weapon_slots.secondaries[v.slot] = true
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
				unlocked = true,
				owned = true,
				factory_id = factory_id,
				selection_index = selection_index
			}
			local is_default, weapon_level, got_parent = managers.upgrades:get_value(weapon)
			weapons[weapon].level = weapon_level
			weapons[weapon].skill_based = got_parent or not is_default and weapon_level == 0 and not tweak_data.weapon[weapon].global_value
		end
	end
end

function BlackMarketManager:weapon_unlocked(weapon_id)
	return Global.blackmarket_manager.weapons[weapon_id] and Global.blackmarket_manager.weapons[weapon_id].unlocked or false
end

function BlackMarketManager:weapon_unlocked_by_crafted(category, slot)
	local crafted = self._global.crafted_items[category][slot]
	local weapon_id = crafted.weapon_id

	return self:weapon_unlocked(weapon_id)
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

		if melee_weapon.equipped and melee_weapon.unlocked and (not data.dlc or data.dlc and tweak_data.dlc:is_melee_weapon_unlocked(melee_weapon_id)) then
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

function BlackMarketManager:equipped_customization()
	local nationality = managers.player:get_character_profile_nation()

	if managers.network and managers.network:session() then
		local peer = managers.network:session():local_peer()
		local peer_character = peer:character()

		if nationality ~= peer_character then
			local customization = managers.player:get_customization_for_nationality(peer_character)

			return customization
		end
	end

	local customization = {
		equiped_head_name = managers.player:get_customization_equiped_head_name(),
		equiped_upper_name = managers.player:get_customization_equiped_upper_name(),
		equiped_lower_name = managers.player:get_customization_equiped_lower_name(),
		nationality = nationality
	}

	return customization
end

function BlackMarketManager:equip_weapon(category, slot)
	if not Global.blackmarket_manager.crafted_items[category] then
		return false
	end

	for s, data in pairs(Global.blackmarket_manager.crafted_items[category]) do
		data.equipped = s == slot
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

function BlackMarketManager:outfit_string_index(type)
	return BlackMarketManager.OUTFIT_INDEX_MAP[type]
end

function BlackMarketManager:unpack_outfit_from_string(outfit_string)
	local outfit = {}
	local data = string.split(outfit_string or "", " ")
	local armor_string = data[self:outfit_string_index("armor")] or tostring(self._defaults.armor)
	local armor_data = string.split(armor_string, "-")
	outfit.armor = armor_data[1]
	outfit.armor_current = armor_data[2] or outfit.armor
	outfit.armor_current_state = armor_data[3] or outfit.armor_current
	outfit.character = data[self:outfit_string_index("character")] or self._defaults.character
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

	outfit.deployable = data[self:outfit_string_index("deployable")] or nil
	outfit.deployable_amount = tonumber(data[self:outfit_string_index("deployable_amount")] or "0")
	outfit.concealment_modifier = data[self:outfit_string_index("concealment_modifier")] or 0
	outfit.melee_weapon = data[self:outfit_string_index("melee_weapon")] or self._defaults.melee_weapon
	outfit.grenade = data[self:outfit_string_index("grenade")] or self._defaults.grenade
	outfit.grenade_cosmetic = data[self:outfit_string_index("grenade_cosmetic")]
	outfit.warcry_weapon = data[self:outfit_string_index("warcry_weapon")]
	outfit.character_customization_head = data[self:outfit_string_index("character_customization_head")]
	outfit.character_customization_upper = data[self:outfit_string_index("character_customization_upper")]
	outfit.character_customization_lower = data[self:outfit_string_index("character_customization_lower")]
	outfit.character_customization_nationality = data[self:outfit_string_index("character_customization_nationality")]

	return outfit
end

function BlackMarketManager:unpack_team_ai_customization_from_string(customization_string)
	local data = string.split(customization_string or "", " ")
	local customization = {
		equiped_head_name = data[1],
		equiped_upper_name = data[2],
		equiped_lower_name = data[3],
		nationality = data[4]
	}

	return customization
end

function BlackMarketManager:outfit_string()
	local s = ""
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
	local grenade_skin_id = managers.weapon_inventory:get_weapons_skin(tostring(equipped_grenade))
	s = s .. " " .. tostring(grenade_skin_id)
	local warcry = managers.warcry:get_active_warcry()
	s = s .. " " .. tostring(warcry and warcry:special_unit())
	local customization = self:equipped_customization()
	s = s .. " " .. customization.equiped_head_name
	s = s .. " " .. customization.equiped_upper_name
	s = s .. " " .. customization.equiped_lower_name
	s = s .. " " .. customization.nationality

	return s
end

function BlackMarketManager:team_ai_customization_string(customization)
	local s = ""
	s = s .. " " .. customization.equiped_head_name
	s = s .. " " .. customization.equiped_upper_name
	s = s .. " " .. customization.equiped_lower_name
	s = s .. " " .. customization.nationality

	return s
end

function BlackMarketManager:outfit_string_from_list(outfit)
	local s = ""
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
	s = s .. " " .. tostring(outfit.grenade_cosmetic)
	s = s .. " " .. tostring(outfit.warcry_weapon)
	local customization = self:equipped_customization()
	s = s .. " " .. customization.equiped_head_name
	s = s .. " " .. customization.equiped_upper_name
	s = s .. " " .. customization.equiped_lower_name
	s = s .. " " .. customization.nationality

	return s
end

function BlackMarketManager:signature()
	return managers.network.account:inventory_outfit_signature()
end

function BlackMarketManager:resource_loaded_callback(category, loaded_table, parts)
	local loaded_category = self._category_resource_loaded[category]

	if loaded_category then
		for part_id, unload in pairs(loaded_category) do
			if unload.package then
				managers.weapon_factory:unload_package(unload.package)
			else
				managers.dyn_resource:unload(IDS_UNIT, unload.name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
			end
		end
	end

	self._category_resource_loaded[category] = loaded_table
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
		name = "square_panel",
		layer = 1
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
			h = 15,
			w = 15,
			blend_mode = "add",
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
		h = 19,
		w = 19,
		layer = 2,
		name = "progress",
		blend_mode = "add",
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
		melees = 4,
		equipments = 3,
		secondaries = 1,
		primaries = 2
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
		melees = 4,
		equipments = 3,
		secondaries = 1,
		primaries = 2
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

function BlackMarketManager:calculate_weapon_visibility(weapon)
	return #tweak_data.weapon.stats.concealment - self:calculate_weapon_concealment(weapon)
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

function BlackMarketManager:_calculate_melee_weapon_concealment(melee_weapon)
	local melee_weapon_data = tweak_data.blackmarket.melee_weapons[melee_weapon].stats

	return melee_weapon_data.concealment or #tweak_data.weapon.stats.concealment
end

function BlackMarketManager:_get_concealment(primary, secondary, armor, melee_weapon, modifier)
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility(primary)
	local secondary_visibility = self:calculate_weapon_visibility(secondary)
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(melee_weapon)
	local modifier = modifier or 0
	local total_visibility = math.clamp(primary_visibility + secondary_visibility + melee_weapon_visibility + modifier, 1, #stats_tweak_data.concealment)
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
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(data.melee_weapon)
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + melee_weapon_visibility + modifier
	local total_concealment = #stats_tweak_data.concealment - total_visibility

	return total_concealment
end

function BlackMarketManager:get_real_visibility_index_of_local_player()
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility("primaries")
	local secondary_visibility = self:calculate_weapon_visibility("secondaries")
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility()
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + melee_weapon_visibility + modifier
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
	skill_bonuses = skill_bonuses - managers.player:upgrade_value("player", "concealment_modifier", 0)

	return skill_bonuses
end

function BlackMarketManager:concealment_modifier(type)
	local modifier = 0

	if type == "armors" then
		modifier = modifier + managers.player:upgrade_value("player", "concealment_modifier", 0)
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

		self:_verify_equipped_category("primaries")
	end

	local equipped_secondary = managers.blackmarket:equipped_secondary()

	if equipped_secondary and equipped_secondary.weapon_id == id then
		equipped_secondary.equipped = false

		self:_verify_equipped_category("secondaries")
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

		self:_verify_equipped_category("melee_weapons")
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

		self:_verify_equipped_category("grenades")
	end
end

function BlackMarketManager:aquire_default_weapons(only_enable)
	local character_class = managers.skilltree:has_character_profile_class()

	if character_class then
		character_class = managers.skilltree:get_character_profile_class()

		Application:debug("[BlackMarketManager:aquire_default_weapons] from class", character_class)
		self:_aquire_class_default_secondary(character_class, only_enable)
		self:_aquire_class_default_primary(character_class, only_enable)
	else
		Application:debug("[BlackMarketManager:aquire_default_weapons] no class, generic")
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

	if not weapon_data then
		Application:error("[BlackMarketManager:on_buy_weapon_platform] weapon_id does not exists in weapon tweakdata, ignoring:", weapon_id)

		return
	end

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

		new_name = character
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
		local new_name = character
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
	local new_name = character
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
	if tweak_data.blackmarket.characters.american[character_name] then
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

function BlackMarketManager:character_sequence_by_character_name(character, peer_id)
	if managers.network and managers.network:session() and peer_id then
		Application:debug("[BlackMarketManager:character_sequence_by_character_name]", managers.network:session(), peer_id, character_name)

		local peer = managers.network:session():peer(peer_id)

		if peer then
			if peer:character() then
				character = peer:character()
			else
				Application:error("[BlackMarketManager:character_sequence_by_character_name] Peer missing character", "peer_id", peer_id)
				Application:debug("[BlackMarketManager]", inspect(peer))
			end
		end
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
	self:_verify_equipped()
end

function BlackMarketManager:reset_equipped()
	self:_setup_weapons()
	self:_setup_armors()
	self:_setup_grenades()
	self:_setup_melee_weapons()
	managers.dlc:give_dlc_package()
	self:_verify_dlc_items()
	self:_verify_equipped()
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
	Global.blackmarket_manager = deep_clone(data.blackmarket)
	self._global = Global.blackmarket_manager

	if self._global.equipped_armor and type(self._global.equipped_armor) ~= "string" then
		self._global.equipped_armor = nil
	end

	self._global.armors = default_global.armors or {}

	for armor, _ in pairs(tweak_data.blackmarket.armors) do
		if not self._global.armors[armor] then
			self._global.armors[armor] = {
				unlocked = false,
				equipped = false,
				owned = false
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

	local equipped_grenade_id = self._global.equipped_grenade

	if not managers.upgrades:upgrade_exists(equipped_grenade_id) then
		equipped_grenade_id = self._defaults.grenade
	end

	for grenade, data in pairs(self._global.grenades) do
		self._global.grenades[grenade].skill_based = false
		self._global.grenades[grenade].equipped = grenade == equipped_grenade_id
	end

	self._global.equipped_grenade = nil
	local equipped_melee_id = self._global.equipped_melee_weapon or self._defaults.melee_weapon
	self._global.melee_weapons = default_global.melee_weapons or {}

	for melee_weapon, data in pairs(self._global.melee_weapons) do
		local is_default, melee_weapon_level = managers.upgrades:get_value(melee_weapon)
		self._global.melee_weapons[melee_weapon].level = melee_weapon_level
		self._global.melee_weapons[melee_weapon].skill_based = not is_default and melee_weapon_level == 0 and not tweak_data.blackmarket.melee_weapons[melee_weapon].dlc and not tweak_data.blackmarket.melee_weapons[melee_weapon].free
		self._global.melee_weapons[melee_weapon].equipped = melee_weapon == equipped_melee_id
	end

	self._global.equipped_melee_weapon = nil
	self._global.weapons = default_global.weapons or {}

	for weapon, data in pairs(tweak_data.weapon) do
		if not self._global.weapons[weapon] and data.autohit then
			local selection_index = data.use_data.selection_index
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon)
			self._global.weapons[weapon] = {
				equipped = false,
				owned = false,
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
	local character_name = self._global._preferred_character

	if not tweak_data.blackmarket.characters.american[character_name] and not tweak_data.blackmarket.characters[character_name] then
		self._global._preferred_character = self._defaults.preferred_character
	end

	self._global._preferred_characters = self._global._preferred_characters or {
		self._global._preferred_character
	}

	for i, character in pairs(clone(self._global._preferred_characters)) do
		local character_name = character

		if not tweak_data.blackmarket.characters.american[character_name] and not tweak_data.blackmarket.characters[character_name] then
			self._global._preferred_characters[i] = self._defaults.preferred_character
		end
	end

	for character, _ in pairs(tweak_data.blackmarket.characters) do
		if not self._global.characters[character] then
			self._global.characters[character] = {
				unlocked = true,
				equipped = false,
				owned = true
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
		end
	end
end

function BlackMarketManager:_load_done()
	Application:debug("BlackMarketManager:_load_done()")

	if managers.savefile:get_active_characters_count() == 0 then
		self:aquire_default_weapons()
	end

	self:_verify_equipped()
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
	local character_name = self._global._preferred_character
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

function BlackMarketManager:_verify_equipped()
	self:_verify_equipped_category("secondaries")
	self:_verify_equipped_category("primaries")
	self:_verify_equipped_category("armors")
	self:_verify_equipped_category("grenades")
	self:_verify_equipped_category("melee_weapons")
end

function BlackMarketManager:_verify_equipped_category(category)
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
		local eqp_melee_weapon_id = self:equipped_melee_weapon()

		for twk_melee_weapon_id, data in pairs(Global.blackmarket_manager.melee_weapons) do
			Application:debug("[BlackMarketManager:VerifyMelee] Equipped tgt '" .. eqp_melee_weapon_id .. "', checking '" .. twk_melee_weapon_id .. "'", twk_melee_weapon_id == eqp_melee_weapon_id)

			data.equipped = twk_melee_weapon_id == eqp_melee_weapon_id
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

	if managers.skilltree:has_character_profile_class() then
		local character_class = managers.skilltree:get_character_profile_class()
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

	if current_state then
		if not current_state:in_steelsight() then
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "hip_fire_damage_multiplier", 1)
		end
	end

	if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "modded_damage_multiplier", 1)
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
		local ducking = current_state:ducking()
		local moving = current_state:moving()

		if ducking then
			multiplier = multiplier * managers.player:upgrade_value("player", "scuttler_crouch_spread_multiplier", 1)
		end

		if moving then
			multiplier = multiplier * managers.player:upgrade_value(category, "move_spread_multiplier", 1)
			multiplier = multiplier * managers.player:team_upgrade_value("weapon", "move_spread_multiplier", 1)
			multiplier = multiplier * managers.player:upgrade_value("player", "agile_moving_spread_multiplier", 1)
		end

		if current_state:in_steelsight() then
			multiplier = multiplier * tweak_data.weapon[name].spread[moving and "moving_steelsight" or "steelsight"]
		else
			multiplier = multiplier * managers.player:upgrade_value(category, "hip_fire_spread_multiplier", 1)

			if ducking and not current_state._unit_deploy_position then
				if moving then
					multiplier = multiplier * tweak_data.weapon[name].spread.moving_crouching
				else
					multiplier = multiplier * tweak_data.weapon[name].spread.crouching
				end
			elseif moving then
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
