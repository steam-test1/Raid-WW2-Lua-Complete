ChallengeManager = ChallengeManager or class()
ChallengeManager.VERSION = 3
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

-- Lines 43-52
function ChallengeManager:create_challenge(challenge_category, challenge_id, tasks, complete_callback, challenge_data)
	challenge_category = challenge_category or ChallengeManager.CATEGORY_GENERIC
	local challenge = Challenge:new(challenge_category, challenge_id, tasks, complete_callback, challenge_data)

	if not self._challenges[challenge_category] then
		self._challenges[challenge_category] = {}
	end

	self._challenges[challenge_category][challenge_id] = challenge
end

-- Lines 54-62
function ChallengeManager:activate_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT ACTIVATE CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:activate()
end

-- Lines 64-72
function ChallengeManager:deactivate_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT DEACTIVATE CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:deactivate()
end

-- Lines 74-80
function ChallengeManager:deactivate_all_challenges()
	for category_index, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			self:deactivate_challenge(category_index, challenge_id)
		end
	end
end

-- Lines 82-90
function ChallengeManager:reset_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		debug_pause("CANNOT RESET CHALLENGE", challenge_category, challenge_id)

		return
	end

	self._challenges[challenge_category][challenge_id]:reset()
end

-- Lines 92-98
function ChallengeManager:reset_all_challenges()
	for category_index, category in pairs(self._challenges) do
		for challenge_id, challenge in pairs(category) do
			self:reset_challenge(category_index, challenge_id)
		end
	end
end

-- Lines 100-110
function ChallengeManager:get_challenge(challenge_category, challenge_id)
	if not self._challenges[challenge_category] or not self._challenges[challenge_category][challenge_id] then
		return
	end

	return self._challenges[challenge_category][challenge_id]
end

-- Lines 112-114
function ChallengeManager:challenge_exists(challenge_category, challenge_id)
	return self._challenges[challenge_category] and self._challenges[challenge_category][challenge_id] and true or false
end

-- Lines 138-139
function ChallengeManager:save_character_slot(data)
end

-- Lines 142-143
function ChallengeManager:load_character_slot(data, version)
end

-- Lines 146-152
function ChallengeManager:save_profile_slot(data)
	local state = {
		version = ChallengeManager.VERSION,
		challenges = self._challenges
	}
	data.ChallengeManager = state
end

-- Lines 155-174
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
