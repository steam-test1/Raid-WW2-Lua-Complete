ChallengeManager = ChallengeManager or class()
ChallengeManager.VERSION = 2
ChallengeManager.CATEGORY_GENERIC = "generic"
ChallengeManager.CATEGORY_WEAPON_UPGRADE = "weapon_upgrade"

-- Lines 8-18
function ChallengeManager.get_instance()
	if not Global.challenge_manager then
		Global.challenge_manager = ChallengeManager:new()
	end

	setmetatable(Global.challenge_manager, ChallengeManager)
	Global.challenge_manager:_setup()

	return Global.challenge_manager
end

-- Lines 20-22
function ChallengeManager:init()
	self._challenges = {}
end

-- Lines 24-31
function ChallengeManager:_setup()
	for category_id, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			setmetatable(challenge, Challenge)
			challenge:setup()
		end
	end
end

-- Lines 33-41
function ChallengeManager:reset()
	for category_id, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			challenge:deactivate()
		end
	end

	self._challenges = {}
end

-- Lines 43-51
function ChallengeManager:create_challenge(challenge_category, challenge_id, tasks, complete_callback, challenge_data)
	challenge_category = challenge_category or ChallengeManager.CATEGORY_GENERIC
	local challenge = Challenge:new(challenge_category, challenge_id, tasks, complete_callback, challenge_data)

	if not self._challenges[challenge_category] then
		self._challenges[challenge_category] = {}
	end

	self._challenges[challenge_category][challenge_id] = challenge
end

-- Lines 53-61
function ChallengeManager:activate_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT ACTIVATE CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:activate()
end

-- Lines 63-71
function ChallengeManager:deactivate_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT DEACTIVATE CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:deactivate()
end

-- Lines 73-79
function ChallengeManager:deactivate_all_challenges()
	for category_index, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			self:deactivate_challenge(category_index, challenge_id)
		end
	end
end

-- Lines 81-89
function ChallengeManager:reset_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT RESET CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:reset()
end

-- Lines 91-97
function ChallengeManager:reset_all_challenges()
	for category_index, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			self:reset_challenge(category_index, challenge_id)
		end
	end
end

-- Lines 99-105
function ChallengeManager:get_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		return
	end

	return self._challenges[challenge_category][challenge_id]
end

-- Lines 107-109
function ChallengeManager:challenge_exists(challenge_category, challenge_id)
	return self._challenges[challenge_category] and self._challenges[challenge_category][challenge_id] and true or false
end

-- Lines 133-134
function ChallengeManager:save_character_slot(data)
end

-- Lines 137-138
function ChallengeManager:load_character_slot(data, version)
end

-- Lines 141-147
function ChallengeManager:save_profile_slot(data)
	local state = {
		version = ChallengeManager.VERSION,
		challenges = self._challenges
	}
	data.ChallengeManager = state
end

-- Lines 150-165
function ChallengeManager:load_profile_slot(data, version)
	local state = data.ChallengeManager

	if not state then
		return
	end

	if not state.version or state.version and state.version ~= ChallengeManager.VERSION then
		self.version = ChallengeManager.VERSION

		self:reset()
	else
		self.version = state.version or 1
		self._challenges = state.challenges or {}

		self:_setup()
	end
end
