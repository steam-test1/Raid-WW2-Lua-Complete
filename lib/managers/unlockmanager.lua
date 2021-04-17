UnlockManager = UnlockManager or class()
UnlockManager.CHARACTER_VERSION = 1
UnlockManager.PROFILE_VERSION = 1
UnlockManager.SLOT_CHARACTER = "character"
UnlockManager.SLOT_PROFILE = "profile"
UnlockManager.CATEGORY_CONTROL_ARCHIVE = "control_archive"

-- Lines 16-24
function UnlockManager.get_instance()
	if not Global.unlock_manager then
		Global.unlock_manager = UnlockManager:new()
	end

	setmetatable(Global.unlock_manager, UnlockManager)

	return Global.unlock_manager
end

-- Lines 26-29
function UnlockManager:init()
	self:reset()
end

-- Lines 31-36
function UnlockManager:reset()
	self._categories = {
		[UnlockManager.SLOT_CHARACTER] = {},
		[UnlockManager.SLOT_PROFILE] = {}
	}
end

-- Lines 38-56
function UnlockManager:unlock(category, identifiers)
	if not self._categories[category.slot][category.identifier] then
		self._categories[category.slot][category.identifier] = {}
	end

	local current_level_data = self._categories[category.slot][category.identifier]

	for counter = 1, #identifiers do
		if counter < #identifiers then
			current_level_data[identifiers[counter]] = {}
			current_level_data = current_level_data[identifiers[counter]]
		else
			current_level_data[identifiers[counter]] = identifiers[counter]
		end
	end
end

-- Lines 58-82
function UnlockManager:is_unlocked(category, identifiers)
	local result = false

	if not self._categories[category.slot][category.identifier] then
		return false
	end

	local current_level_data = self._categories[category.slot][category.identifier]

	for counter = 1, #identifiers do
		if counter < #identifiers then
			if not current_level_data[identifiers[counter]] then
				return false
			end

			current_level_data = current_level_data[identifiers[counter]]
		elseif current_level_data[identifiers[counter]] then
			return true
		end
	end

	return result
end

-- Lines 85-91
function UnlockManager:save_profile_slot(data)
	local state = {
		version = UnlockManager.PROFILE_VERSION,
		profile_unlocks = self._categories[UnlockManager.SLOT_PROFILE]
	}
	data.UnlockManager = state
end

-- Lines 94-102
function UnlockManager:load_profile_slot(data)
	local state = data.UnlockManager

	if not state then
		return
	end

	self.version = state.version or UnlockManager.PROFILE_VERSION
	self._categories[UnlockManager.SLOT_PROFILE] = state.profile_unlocks or {}
end
