BreadcrumbManager = BreadcrumbManager or class()
BreadcrumbManager.VERSION = 3
BreadcrumbManager.CRUMB_ID_COUNT_MAX = 100000
BreadcrumbManager.SLOT_CHARACTER = "character"
BreadcrumbManager.SLOT_PROFILE = "profile"
BreadcrumbManager.CATEGORY_NEW_RAID = {
	identifier = "new_raid",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_CONSUMABLE_MISSION = {
	identifier = "consumable_mission",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_OPERATIONS = {
	identifier = "operations",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_MISSIONS = {
	subcategories = {
		BreadcrumbManager.CATEGORY_NEW_RAID,
		BreadcrumbManager.CATEGORY_CONSUMABLE_MISSION,
		BreadcrumbManager.CATEGORY_OPERATIONS
	}
}
BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_UPPER = {
	slot = BreadcrumbManager.SLOT_PROFILE,
	identifier = CharacterCustomizationTweakData.PART_TYPE_UPPER
}
BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_LOWER = {
	slot = BreadcrumbManager.SLOT_PROFILE,
	identifier = CharacterCustomizationTweakData.PART_TYPE_LOWER
}
BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION = {
	subcategories = {
		BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_UPPER,
		BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_LOWER
	}
}
BreadcrumbManager.CATEGORY_WEAPON_PRIMARY = {
	identifier = "weapon_primary",
	slot = BreadcrumbManager.SLOT_CHARACTER
}
BreadcrumbManager.CATEGORY_WEAPON_SECONDARY = {
	identifier = "weapon_secondary",
	slot = BreadcrumbManager.SLOT_CHARACTER
}
BreadcrumbManager.CATEGORY_WEAPON_MELEE = {
	identifier = "weapon_melee",
	slot = BreadcrumbManager.SLOT_CHARACTER
}
BreadcrumbManager.CATEGORY_WEAPON_UPGRADE = {
	identifier = "weapon_upgrade",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_WEAPON = {
	subcategories = {
		BreadcrumbManager.CATEGORY_WEAPON_PRIMARY,
		BreadcrumbManager.CATEGORY_WEAPON_SECONDARY,
		BreadcrumbManager.CATEGORY_WEAPON_MELEE
	}
}
BreadcrumbManager.CATEGORY_CAMP_CUSTOMIZATION = {
	identifier = "camp_customization",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_RANK_REWARD = {
	identifier = "rank_reward",
	slot = BreadcrumbManager.SLOT_CHARACTER
}
BreadcrumbManager.CATEGORY_CHALLENGE_CARD_RAID = {
	identifier = "challenge_card_raid",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_CHALLENGE_CARD_OPERATION = {
	identifier = "challenge_card_operation",
	slot = BreadcrumbManager.SLOT_PROFILE
}
BreadcrumbManager.CATEGORY_CARD = {
	subcategories = {
		BreadcrumbManager.CATEGORY_CHALLENGE_CARD_RAID,
		BreadcrumbManager.CATEGORY_CHALLENGE_CARD_OPERATION
	}
}

function BreadcrumbManager.get_instance()
	if not Global.breadcrumb_manager then
		Global.breadcrumb_manager = BreadcrumbManager:new()
	end

	setmetatable(Global.breadcrumb_manager, BreadcrumbManager)

	return Global.breadcrumb_manager
end

function BreadcrumbManager:init()
	self:reset()
end

function BreadcrumbManager:reset()
	self._breadcrumbs = {
		[BreadcrumbManager.SLOT_CHARACTER] = {},
		[BreadcrumbManager.SLOT_PROFILE] = {}
	}
	self._unique_breadcrumb_ids = {}
end

function BreadcrumbManager:add_breadcrumb(category, identifiers)
	if not category or not identifiers then
		return
	end

	if self:category_has_breadcrumbs(category, identifiers) then
		return
	end

	if not self._breadcrumbs[category.slot][category.identifier] then
		self._breadcrumbs[category.slot][category.identifier] = {}
	end

	local current_tree_level = self._breadcrumbs[category.slot][category.identifier]

	for i = 1, #identifiers do
		if i < #identifiers then
			if not current_tree_level[identifiers[i]] then
				current_tree_level[identifiers[i]] = {}
			end

			current_tree_level = current_tree_level[identifiers[i]]
		else
			current_tree_level[identifiers[i]] = identifiers[i]
		end
	end
end

function BreadcrumbManager:remove_breadcrumb(category, identifiers)
	if not category or not identifiers then
		return
	end

	if not self._breadcrumbs[category.slot][category.identifier] then
		return
	end

	local current_tree_level = self._breadcrumbs[category.slot][category.identifier]
	local depth_to_remove = nil

	for i = 1, #identifiers do
		local elements_in_current_level = self:_count_tree_level_elements(current_tree_level)

		if elements_in_current_level < 2 and not depth_to_remove then
			depth_to_remove = i
		elseif elements_in_current_level >= 2 then
			depth_to_remove = nil
		end

		if i < #identifiers then
			if not current_tree_level[identifiers[i]] then
				return
			end

			current_tree_level = current_tree_level[identifiers[i]]
		else
			current_tree_level[identifiers[i]] = nil

			if self:_count_tree_level_elements(current_tree_level) > 0 then
				depth_to_remove = nil
			end
		end
	end

	if depth_to_remove then
		current_tree_level = self._breadcrumbs[category.slot]
		local index_to_remove = category.identifier

		for i = 1, depth_to_remove - 1 do
			if i == 1 then
				current_tree_level = current_tree_level[category.identifier]
			else
				current_tree_level = current_tree_level[identifiers[i - 1]]
			end

			index_to_remove = identifiers[i]
		end

		current_tree_level[index_to_remove] = nil
	end

	depth_to_remove = nil

	self:_notify_breadcrumb_change_listeners(category, identifiers)
end

function BreadcrumbManager:_count_tree_level_elements(tree_level)
	local count = 0

	for i, element in pairs(tree_level) do
		count = count + 1
	end

	return count
end

function BreadcrumbManager:category_has_breadcrumbs(category, identifiers)
	if not category then
		return
	end

	local category_has_breadcrumbs = false

	if category.subcategories then
		for index, subcategory in pairs(category.subcategories) do
			category_has_breadcrumbs = category_has_breadcrumbs or self:category_has_breadcrumbs(subcategory, identifiers)
		end
	else
		if self._breadcrumbs[category.slot][category.identifier] then
			for index, breadcrumb in pairs(self._breadcrumbs[category.slot][category.identifier]) do
				category_has_breadcrumbs = true

				break
			end
		end

		if category_has_breadcrumbs and identifiers then
			local current_tree_level = self._breadcrumbs[category.slot][category.identifier]

			for i = 1, #identifiers do
				if not current_tree_level[identifiers[i]] then
					category_has_breadcrumbs = false

					break
				end

				current_tree_level = current_tree_level[identifiers[i]]
			end
		end
	end

	return category_has_breadcrumbs or false
end

function BreadcrumbManager:get_unique_breadcrumb_id()
	local id = math.random(1, BreadcrumbManager.CRUMB_ID_COUNT_MAX)

	while self._unique_breadcrumb_ids[id] do
		id = math.random(1, BreadcrumbManager.CRUMB_ID_COUNT_MAX)
	end

	self._unique_breadcrumb_ids[id] = id

	return id
end

function BreadcrumbManager:clear_unique_breadcrumb_id(id)
	self._unique_breadcrumb_ids[id] = nil
end

function BreadcrumbManager:register_breadcrumb_change_listener(key, category, identifiers, callback)
	local event_id = self:_get_event_listener_id(category, identifiers)

	managers.system_event_listener:add_listener(key, {
		event_id
	}, callback)
end

function BreadcrumbManager:unregister_breadcrumb_change_listener(key)
	managers.system_event_listener:remove_listener(key)
end

function BreadcrumbManager:_notify_breadcrumb_change_listeners(category, identifiers)
	local event_id = self:_get_event_listener_id(category)

	managers.system_event_listener:call_listeners(event_id)

	for i = 1, #identifiers do
		local identifier_list = {}

		for j = 1, i do
			table.insert(identifier_list, identifiers[j])
		end

		event_id = self:_get_event_listener_id(category, identifier_list)

		managers.system_event_listener:call_listeners(event_id)
	end
end

function BreadcrumbManager:_get_event_listener_id(category, identifiers)
	local listener_id = "breadcrumb_"
	listener_id = listener_id .. tostring(category.identifier)

	if identifiers then
		for _, identifier in pairs(identifiers) do
			listener_id = listener_id .. "_" .. identifier
		end
	end

	return listener_id
end

function BreadcrumbManager:save_character_slot(data)
	local state = {
		version = self.version,
		slot_breadcrumbs = self._breadcrumbs[BreadcrumbManager.SLOT_CHARACTER]
	}
	data.BreadcrumbManager = state
end

function BreadcrumbManager:load_character_slot(data, version)
	local state = data.BreadcrumbManager

	if not state then
		return
	end

	if not state.version or state.version and state.version ~= BreadcrumbManager.VERSION then
		self.version = BreadcrumbManager.VERSION

		self:reset()
		managers.savefile:set_resave_required()
	else
		self.version = state.version or 1
		self._breadcrumbs[BreadcrumbManager.SLOT_CHARACTER] = state.slot_breadcrumbs or {}
	end
end

function BreadcrumbManager:save_profile_slot(data)
	local state = {
		version = self.version,
		profile_breadcrumbs = self._breadcrumbs[BreadcrumbManager.SLOT_PROFILE]
	}
	data.BreadcrumbManager = state
end

function BreadcrumbManager:load_profile_slot(data, version)
	local state = data.BreadcrumbManager

	if not state then
		return
	end

	if not state.version or state.version and state.version ~= BreadcrumbManager.VERSION then
		self.version = BreadcrumbManager.VERSION

		self:reset()
		managers.savefile:set_resave_required()
	else
		self.version = state.version or 1
		self._breadcrumbs[BreadcrumbManager.SLOT_PROFILE] = state.profile_breadcrumbs or {}
	end
end
