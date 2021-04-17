CharacterCustomizationManager = CharacterCustomizationManager or class()
CharacterCustomizationManager.VERSION = 16
CharacterCustomizationManager.LOCKED_NATIONALITY = "character_customization_locked_nationality"
CharacterCustomizationManager.LOCKED_NOT_OWNED = "character_customization_locked_not_owned"
CharacterCustomizationManager.LOCKED_GOLD_NOT_OWNED = "character_customization_locked_gold_not_owned"
CharacterCustomizationManager.LOCKED_DLC_SPECIFIC = "character_customization_locked_dlc_specific"

-- Lines 11-24
function CharacterCustomizationManager:init()
	self._tweak_data = tweak_data.character_customization.customizations

	if not Global.character_customization_manager then
		Global.character_customization_manager = {
			VERSION = CharacterCustomizationManager.VERSION,
			owned_customizations = tweak_data.character_customization:get_defaults(),
			random_customization_awards = {}
		}
	end

	self._global = Global.character_customization_manager
	self._character_customization_version_to_attach = 1
end

-- Lines 28-30
function CharacterCustomizationManager:get_current_version_to_attach()
	return self._character_customization_version_to_attach
end

-- Lines 32-34
function CharacterCustomizationManager:reset_current_version_to_attach()
	self._character_customization_version_to_attach = 1
end

-- Lines 36-38
function CharacterCustomizationManager:increase_current_version_to_attach()
	self._character_customization_version_to_attach = self._character_customization_version_to_attach + 1
end

-- Lines 43-49
function CharacterCustomizationManager:get_all_owned_customizations()
	if self._global.owned_customizations == nil then
		self._global.owned_customizations = tweak_data.character_customization:get_defaults()
	end

	return self._global.owned_customizations
end

-- Lines 51-56
function CharacterCustomizationManager:set_all_owned_customizations(customizations)
	self:_filter_customizations(customizations)
	self:_append_customizations(customizations, tweak_data.character_customization:get_defaults())

	self._global.owned_customizations = customizations

	self:_award_random_customizations()
end

-- Lines 58-66
function CharacterCustomizationManager:_filter_customizations(customizations)
	local locked_customizations = tweak_data.dlc:get_locked_customizations()

	for name, _ in pairs(locked_customizations) do
		customizations[name] = nil
	end
end

-- Lines 68-76
function CharacterCustomizationManager:_append_customizations(customizations, to_append)
	for name, data in pairs(to_append) do
		if not customizations[name] then
			customizations[name] = data
			customizations[name].key_name = name
		end
	end
end

-- Lines 79-111
function CharacterCustomizationManager:_award_random_customizations()
	Application:debug("[CharacterCustomizationManager][_award_random_customizations]")

	local eligible_awards = tweak_data.dlc:get_eligible_random_customizations()

	if #eligible_awards == 0 then
		return
	end

	local droppable_customizations = tweak_data.character_customization:get_droppable_customizations()
	local awardable_customizations = {}

	for _, key in ipairs(droppable_customizations) do
		if not self._global.owned_customizations[key] and tweak_data.character_customization.customizations[key].part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
			table.insert(awardable_customizations, key)
		end
	end

	Application:debug("[CharacterCustomizationManager][_award_random_customizations] eligible_awards: ", inspect(eligible_awards))

	for _, award in pairs(eligible_awards) do
		local awarded_customization = self._global.random_customization_awards[award.item]

		if not awarded_customization then
			Application:debug("[CharacterCustomizationManager][_award_random_customizations]    awarding ", inspect(award))

			if #awardable_customizations > 0 then
				local random_index = math.random(#awardable_customizations)
				local customization = awardable_customizations[random_index]

				self:add_character_customization_to_inventory(customization, false)
				Application:debug("[CharacterCustomizationManager][_award_random_customizations]    giving ", customization)

				self._global.random_customization_awards[award.item] = customization

				managers.savefile:set_resave_required()
			end
		elseif not self._global.owned_customizations[awarded_customization] then
			self:add_character_customization_to_inventory(awarded_customization, false)
		end
	end
end

-- Lines 113-133
function CharacterCustomizationManager:get_owned_customizations_indexed(part_type, nationality)
	local result = {}
	local owned_customizations = self:get_all_owned_customizations()
	local counter = 1
	local indexed_parts = tweak_data.character_customization:get_index_table(part_type)

	for index, part_key_name in pairs(indexed_parts) do
		if owned_customizations[part_key_name] and self:_can_nationality_use_customization(owned_customizations[part_key_name], nationality) then
			result[counter] = {}
			local customization_data = clone(owned_customizations[part_key_name])
			customization_data.key_name = part_key_name
			customization_data.part_index = counter
			result[counter] = customization_data
			counter = counter + 1
		end
	end

	return result
end

-- Lines 135-148
function CharacterCustomizationManager:_can_nationality_use_customization(customization_data, nationality)
	local result = false

	if customization_data and customization_data.nationalities then
		for _, customization_nationality in ipairs(customization_data.nationalities) do
			if nationality == customization_nationality then
				result = true

				break
			end
		end
	end

	return result
end

-- Lines 150-169
function CharacterCustomizationManager:equipable_nationalities_to_string(part_key_name)
	local result = ""
	local item_data = tweak_data.character_customization.customizations[part_key_name]

	if item_data and item_data.nationalities then
		for _, nationality in pairs(item_data.nationalities) do
			if nationality == CharacterCustomizationTweakData.NATIONALITY_AMERICAN then
				result = result .. " " .. managers.localization:text("character_profile_creation_american")
			elseif nationality == CharacterCustomizationTweakData.NATIONALITY_GERMAN then
				result = result .. " " .. managers.localization:text("character_profile_creation_german")
			elseif nationality == CharacterCustomizationTweakData.NATIONALITY_BRITISH then
				result = result .. " " .. managers.localization:text("character_profile_creation_british")
			elseif nationality == CharacterCustomizationTweakData.NATIONALITY_RUSSIAN then
				result = result .. " " .. managers.localization:text("character_profile_creation_russian")
			end
		end
	end

	return result
end

-- Lines 171-203
function CharacterCustomizationManager:get_equiped_part_from_character_save_slot(slot_index, part_type)
	local result = nil
	local slot_cache_data = Global.savefile_manager.meta_data_list[slot_index].cache
	local player_manager_data = slot_cache_data.PlayerManager
	local character_nationality_name = player_manager_data.character_profile_nation
	local equiped_head_name = player_manager_data.customization_equiped_head_name
	local equiped_upper_name = player_manager_data.customization_equiped_upper_name
	local equiped_lower_name = player_manager_data.customization_equiped_lower_name

	if part_type == CharacterCustomizationTweakData.PART_TYPE_HEAD then
		if not self:get_all_owned_customizations()[equiped_head_name] then
			result = self:get_default_part_key_name(character_nationality_name, part_type)
		else
			result = equiped_head_name
		end
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		if not self:get_all_owned_customizations()[equiped_upper_name] then
			result = self:get_default_part_key_name(character_nationality_name, part_type)
		else
			result = equiped_upper_name
		end
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		if not self:get_all_owned_customizations()[equiped_lower_name] then
			result = self:get_default_part_key_name(character_nationality_name, part_type)
		else
			result = equiped_lower_name
		end
	end

	return result
end

-- Lines 205-232
function CharacterCustomizationManager:get_equiped_part_index(character_nationality_name, part_type, equiped_name)
	local parts_table = {}
	parts_table = self:get_owned_customizations_indexed(part_type, character_nationality_name)

	if parts_table then
		for index, value in pairs(parts_table) do
			if value.key_name == equiped_name then
				return index
			end
		end
	end

	local default_name = self:get_default_part_key_name(character_nationality_name, part_type)

	if parts_table then
		for index, value in pairs(parts_table) do
			if value.key_name == default_name then
				return index
			end
		end
	end

	debug_pause("[CharacterCustomizationManager][get_equiped_part_index] No customization part found, both equipped and default failed: ", character_nationality_name, part_type, equiped_name)

	return 1
end

-- Lines 234-242
function CharacterCustomizationManager:verify_customization_ownership(character_nationality_name, part_type, equiped_name)
	local owned_customizations = self:get_all_owned_customizations()

	if owned_customizations[equiped_name] then
		return equiped_name
	end

	return self:get_default_part_key_name(character_nationality_name, part_type)
end

-- Lines 245-247
function CharacterCustomizationManager:get_all_parts_indexed(part_type)
	return tweak_data.character_customization:get_all_parts_indexed(part_type)
end

-- Lines 249-251
function CharacterCustomizationManager:get_all_parts(part_type)
	return tweak_data.character_customization:get_all_parts(part_type)
end

-- Lines 255-316
function CharacterCustomizationManager:get_all_parts_indexed_filtered(part_type, nationality, owned_only)
	local data = tweak_data.character_customization:get_all_parts_indexed(part_type)
	local result = {}
	local owned_customizations = self:get_all_owned_customizations()
	local unlocked_customizations = tweak_data.dlc:get_unlocked_customizations()
	local counter = 1

	for index, part_data in pairs(data) do
		local new_data = clone(part_data)

		Application:trace("[CharacterCustomizationManager:get_all_parts_indexed_filtered] new_data ", inspect(new_data))

		if (not owned_only or owned_customizations[new_data.key_name]) and nationality and self:_can_nationality_use_customization(new_data, nationality) then
			local should_show = true

			if not owned_customizations[new_data.key_name] then
				if new_data.dlc and not unlocked_customizations[new_data.key_name] then
					if not new_data.dlc_show_if_locked then
						should_show = false
					end

					new_data.locked = CharacterCustomizationManager.LOCKED_DLC_SPECIFIC
					new_data.status = RaidGUIControlGridItem.STATUS_LOCKED_DLC
				elseif new_data.gold_price then
					new_data.locked = CharacterCustomizationManager.LOCKED_GOLD_NOT_OWNED
					new_data.status = RaidGUIControlGridItem.STATUS_PURCHASABLE
				else
					new_data.locked = CharacterCustomizationManager.LOCKED_NOT_OWNED
					new_data.status = RaidGUIControlGridItem.STATUS_LOCKED
				end
			else
				new_data.status = RaidGUIControlGridItem.STATUS_OWNED_OR_PURCHASED
			end

			if should_show then
				new_data.breadcrumb = {}
				local breadcrumb_category = nil

				for i, category in pairs(BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION.subcategories) do
					if category.identifier == new_data.part_type then
						breadcrumb_category = category

						break
					end
				end

				new_data.breadcrumb.category = breadcrumb_category
				new_data.breadcrumb.identifiers = {}

				table.insert(new_data.breadcrumb.identifiers, new_data.nationalities[1])
				table.insert(new_data.breadcrumb.identifiers, new_data.key_name)
				table.insert(result, new_data)
			end
		end
	end

	result = self:_sort_by_unlocked(result)

	return result
end

-- Lines 319-360
function CharacterCustomizationManager:_sort_by_unlocked(data)
	local result = {}

	if data then
		for index, part_data in pairs(data) do
			if not part_data.locked then
				table.insert(result, part_data)
			end
		end

		for index, part_data in pairs(data) do
			if part_data.locked == CharacterCustomizationManager.LOCKED_GOLD_NOT_OWNED then
				table.insert(result, part_data)
			end
		end

		for index, part_data in pairs(data) do
			if part_data.locked == CharacterCustomizationManager.LOCKED_NOT_OWNED and not part_data.dlc then
				table.insert(result, part_data)
			end
		end

		for index, part_data in pairs(data) do
			if part_data.locked == CharacterCustomizationManager.LOCKED_NOT_OWNED and part_data.dlc then
				table.insert(result, part_data)
			end
		end

		for index, part_data in pairs(data) do
			if part_data.locked == CharacterCustomizationManager.LOCKED_DLC_SPECIFIC then
				table.insert(result, part_data)
			end
		end
	end

	data = nil

	return result
end

-- Lines 365-374
function CharacterCustomizationManager:check_part_key_name(part_type, part_key_name, nationality)
	local result = part_key_name
	local all_parts = self:get_all_parts(part_type)

	if not all_parts[part_key_name] then
		result = self:get_default_part_key_name(nationality, part_type)
	end

	return result
end

-- Lines 376-388
function CharacterCustomizationManager:get_default_part_key_name(nationality, part_type)
	local result = ""

	if part_type == CharacterCustomizationTweakData.PART_TYPE_HEAD then
		result = nationality .. "_default_head"
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		result = nationality .. "_default_upper"
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		result = nationality .. "_default_lower"
	end

	return result
end

-- Lines 391-394
function CharacterCustomizationManager:reset()
	self:set_all_owned_customizations(tweak_data.character_customization:get_defaults())
end

-- Lines 397-409
function CharacterCustomizationManager:save(data)
	local state = {
		owned_customizations = self:get_all_owned_customizations(),
		random_customization_awards = self._global.random_customization_awards
	}

	if self._global.VERSION then
		state.VERSION = self._global.VERSION
	end

	data.CharacterCustomizationManager = state
end

-- Lines 412-424
function CharacterCustomizationManager:load(data)
	local state = data.CharacterCustomizationManager

	if state then
		self._global.random_customization_awards = state.random_customization_awards or {}

		if state.VERSION and state.VERSION == CharacterCustomizationManager.VERSION then
			self:set_all_owned_customizations(state.owned_customizations)
		else
			self:reset_customizations_on_load(state.owned_customizations)
			managers.savefile:set_resave_required()
		end
	end
end

-- Lines 426-443
function CharacterCustomizationManager:reset_customizations_on_load(previously_owned)
	local currently_owned = {}

	for customization_name, customization_data in pairs(previously_owned) do
		if tweak_data.character_customization.customizations[customization_name] then
			currently_owned[customization_name] = tweak_data.character_customization.customizations[customization_name]
		end
	end

	self:set_all_owned_customizations(currently_owned)
end

-- Lines 446-448
function CharacterCustomizationManager:is_character_customization_owned(part_key)
	return self._global.owned_customizations[part_key] ~= nil
end

-- Lines 450-481
function CharacterCustomizationManager:add_character_customization_to_inventory(part_key, bought)
	self._global.owned_customizations[part_key] = tweak_data.character_customization.customizations[part_key]
	local breadcrumb_category = nil

	for index, category in pairs(BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION.subcategories) do
		if category.identifier == tweak_data.character_customization.customizations[part_key].part_type then
			breadcrumb_category = category

			break
		end
	end

	for index, nationality in pairs(tweak_data.character_customization.customizations[part_key].nationalities) do
		local need_breadcrumb = false

		for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
			local slot_data = Global.savefile_manager.meta_data_list[slot_index]

			if slot_data and slot_data.cache and nationality == slot_data.cache.PlayerManager.character_profile_nation then
				need_breadcrumb = true

				break
			end
		end

		if need_breadcrumb and not bought then
			managers.breadcrumb:add_breadcrumb(breadcrumb_category, {
				nationality,
				part_key
			})
		end
	end
end

-- Lines 483-485
function CharacterCustomizationManager:remove_character_customization_from_inventory(part_key)
	self._global.owned_customizations[part_key] = nil
end

-- Lines 489-497
function CharacterCustomizationManager:reaply_character_criminal(preferred_character_name)
	if Network:is_server() then
		self:request_change_criminal_character(managers.network:session():local_peer():id(), preferred_character_name, managers.player:local_player())
	else
		managers.network:session():send_to_host("request_change_criminal_character", managers.network:session():local_peer():id(), preferred_character_name, managers.player:local_player())
	end
end

-- Lines 500-523
function CharacterCustomizationManager:request_change_criminal_character(peer_id, preferred_character_name, peer_unit)
	if not Network:is_server() then
		return
	end

	local remove_unit_in_source_slot = true
	local new_character_name = managers.network:session():check_peer_preferred_character(preferred_character_name)

	if not new_character_name then
		remove_unit_in_source_slot = false
		new_character_name = managers.criminals:character_name_by_peer_id(peer_id)
	end

	local existing_character_name = managers.criminals:character_name_by_peer_id(peer_id)

	if existing_character_name == preferred_character_name then
		new_character_name = preferred_character_name
		remove_unit_in_source_slot = false
	end

	managers.network:session():send_to_peers("change_criminal_character", peer_id, new_character_name, peer_unit)
	self:change_criminal_character(peer_id, new_character_name, peer_unit, remove_unit_in_source_slot)
end

-- Lines 525-554
function CharacterCustomizationManager:change_criminal_character(peer_id, new_character_name, peer_unit, remove_unit_in_source_slot)
	local unit_to_remove = managers.criminals:character_unit_by_name(new_character_name)

	managers.hud:_remove_name_label(peer_unit:unit_data().name_label_id)

	if unit_to_remove and remove_unit_in_source_slot then
		unit_to_remove:set_slot(0)
	end

	managers.criminals:remove_character_by_peer_id(peer_id)
	managers.criminals:add_character(new_character_name, peer_unit, peer_id, false)
	managers.network:session():peer(peer_id):set_character(new_character_name)

	local head_data = self:get_default_head_data(new_character_name)

	if peer_unit:customization() then
		self:increase_current_version_to_attach()
		peer_unit:customization():attach_head_for_husk(head_data.path)
	end

	if Global.game_settings.team_ai and Network:is_server() then
		managers.groupai:state():fill_criminal_team_with_AI(nil)
	end
end

-- Lines 556-570
function CharacterCustomizationManager:get_default_head_data(nationality)
	local result = {}

	if nationality == CharacterCustomizationTweakData.NATIONALITY_AMERICAN then
		result = tweak_data.character_customization.customizations.american_default_head
	elseif nationality == CharacterCustomizationTweakData.NATIONALITY_BRITISH then
		result = tweak_data.character_customization.customizations.british_default_head
	elseif nationality == CharacterCustomizationTweakData.NATIONALITY_GERMAN then
		result = tweak_data.character_customization.customizations.german_default_head
	elseif nationality == CharacterCustomizationTweakData.NATIONALITY_RUSSIAN then
		result = tweak_data.character_customization.customizations.russian_default_head
	end

	return result
end
