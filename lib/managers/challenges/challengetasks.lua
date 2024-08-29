ChallengeTask = ChallengeTask or class()
ChallengeTask.STATE_INACTIVE = "inactive"
ChallengeTask.STATE_ACTIVE = "active"
ChallengeTask.STATE_COMPLETED = "completed"
ChallengeTask.STATE_FAILED = "failed"

-- Lines 8-14
function ChallengeTask.create(task_type, challenge_category, challenge_id, task_data)
	if task_type == ChallengeTweakData.TASK_KILL_ENEMIES then
		return ChallengeTaskKillEnemies:new(challenge_category, challenge_id, task_data)
	elseif task_type == ChallengeTweakData.TASK_COLLECT_AMMO then
		return ChallengeTaskCollectAmmo:new(challenge_category, challenge_id, task_data)
	end
end

-- Lines 16-22
function ChallengeTask.get_metatable(task_type)
	if task_type == ChallengeTweakData.TASK_KILL_ENEMIES then
		return ChallengeTaskKillEnemies
	elseif task_type == ChallengeTweakData.TASK_COLLECT_AMMO then
		return ChallengeTaskCollectAmmo
	end
end

-- Lines 24-26
function ChallengeTask:init()
	self._state = ChallengeTask.STATE_INACTIVE
end

-- Lines 28-33
function ChallengeTask:setup()
	if self._state == ChallengeTask.STATE_ACTIVE then
		self._state = ChallengeTask.STATE_INACTIVE

		self:activate()
	end
end

-- Lines 35-37
function ChallengeTask:activate()
	self._state = ChallengeTask.STATE_ACTIVE
end

-- Lines 39-41
function ChallengeTask:deactivate()
	self._state = ChallengeTask.STATE_INACTIVE
end

-- Lines 43-47
function ChallengeTask:reset()
	if self._state == Challenge.STATE_COMPLETED or self._state == Challenge.STATE_FAILED then
		self._state = Challenge.STATE_INACTIVE
	end
end

-- Lines 49-51
function ChallengeTask:active()
	return self._state == ChallengeTask.STATE_ACTIVE and true or false
end

-- Lines 53-55
function ChallengeTask:completed()
	return self._state == ChallengeTask.STATE_COMPLETED and true or false
end

-- Lines 57-59
function ChallengeTask:id()
	return self._id
end

-- Lines 61-63
function ChallengeTask:type()
	return self._type
end

-- Lines 66-68
function ChallengeTask:briefing_id()
	return self._briefing_id
end

-- Lines 70-72
function ChallengeTask:done_text_id()
	return self._done_text_id
end

-- Lines 74-80
function ChallengeTask:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
end

ChallengeTaskKillEnemies = ChallengeTaskKillEnemies or class(ChallengeTask)

-- Lines 91-105
function ChallengeTaskKillEnemies:init(challenge_category, challenge_id, task_data)
	ChallengeTaskKillEnemies.super.init(self)

	self._count = 0
	self._target = task_data.target
	self._min_range = task_data.min_range
	self._parent_challenge_category = challenge_category
	self._parent_challenge_id = challenge_id
	self._id = self._parent_challenge_id .. "_kill_enemies"
	self._type = ChallengeTweakData.TASK_KILL_ENEMIES
	self._briefing_id = task_data.challenge_briefing_id
	self._done_text_id = task_data.challenge_done_text_id
	self._modifiers = task_data.modifiers or {}
	self._reminders = task_data.reminders or {}
end

-- Lines 107-113
function ChallengeTaskKillEnemies:activate()
	ChallengeTaskKillEnemies.super.activate(self)
	managers.system_event_listener:add_listener(self._id, {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "on_enemy_killed"))
end

-- Lines 115-119
function ChallengeTaskKillEnemies:deactivate()
	ChallengeTaskKillEnemies.super.deactivate(self)
	managers.system_event_listener:remove_listener(self._id)
end

-- Lines 121-125
function ChallengeTaskKillEnemies:reset()
	ChallengeTaskKillEnemies.super.reset(self)

	self._count = 0
end

-- Lines 127-129
function ChallengeTaskKillEnemies:current_count()
	return self._count
end

-- Lines 131-133
function ChallengeTaskKillEnemies:target()
	return self._target
end

-- Lines 135-137
function ChallengeTaskKillEnemies:min_range()
	return self._modifiers.min_range or 0
end

-- Lines 139-141
function ChallengeTaskKillEnemies:max_range()
	return self._modifiers.max_range or 0
end

-- Lines 143-145
function ChallengeTaskKillEnemies:set_reminders(reminders)
	self._reminders = reminders
end

-- Lines 147-149
function ChallengeTaskKillEnemies:set_modifiers(modifiers)
	self._modifiers = modifiers
end

-- Lines 151-222
function ChallengeTaskKillEnemies:on_enemy_killed(kill_data)
	if kill_data.using_turret then
		return
	end

	if self._modifiers.damage_type and self._modifiers.damage_type ~= kill_data.damage_type then
		return
	end

	if self._modifiers.headshot and not kill_data.headshot then
		return
	end

	if self._modifiers.hip_fire and kill_data.player_used_steelsight then
		return
	end

	if self._modifiers.steelsight and not kill_data.player_used_steelsight then
		return
	end

	if self._modifiers.min_range and kill_data.enemy_distance < self._modifiers.min_range then
		return true
	end

	if self._modifiers.max_range and self._modifiers.max_range < kill_data.enemy_distance then
		return true
	end

	if self._modifiers.enemy_type then
		local is_correct_enemy_type = false

		for i, enemy_type in pairs(self._modifiers.enemy_type) do
			if kill_data.enemy_type == enemy_type or kill_data.special_enemy_type == enemy_type then
				is_correct_enemy_type = true
			end
		end

		if not is_correct_enemy_type then
			return
		end
	end

	if self._modifiers.last_round_in_magazine and kill_data.damage_type == "bullet" and kill_data.weapon_used:base():get_ammo_remaining_in_clip() > 0 then
		return
	end

	self._count = self._count + 1

	for i = 1, #self._reminders do
		if self._count == self._reminders[i] then
			local challenge_data = managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):data()

			managers.weapon_skills:remind_weapon_challenge(challenge_data.weapon, challenge_data.tier, challenge_data.skill_index)
		end
	end

	self:_check_status()
end

-- Lines 224-228
function ChallengeTaskKillEnemies:_check_status()
	if self._target <= self._count then
		self:_on_completed()
	end
end

-- Lines 230-235
function ChallengeTaskKillEnemies:_on_completed()
	self._state = ChallengeTask.STATE_COMPLETED

	managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):on_task_completed()
	managers.system_event_listener:remove_listener(self._id)
end

-- Lines 237-246
function ChallengeTaskKillEnemies:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
	self._count = self._target

	managers.system_event_listener:remove_listener(self._id)
end

ChallengeTaskCollectAmmo = ChallengeTaskCollectAmmo or class(ChallengeTask)

-- Lines 282-294
function ChallengeTaskCollectAmmo:init(challenge_category, challenge_id, task_data)
	ChallengeTaskCollectAmmo.super.init(self)

	self._count = 0
	self._target = task_data.target
	self._parent_challenge_category = challenge_category
	self._parent_challenge_id = challenge_id
	self._id = self._parent_challenge_id .. "_collect_ammo"
	self._briefing_id = task_data.challenge_briefing_id
	self._done_text_id = task_data.challenge_done_text_id
	self._type = ChallengeTweakData.TASK_COLLECT_AMMO
	self._reminders = task_data.reminders or {}
end

-- Lines 296-302
function ChallengeTaskCollectAmmo:activate()
	ChallengeTaskCollectAmmo.super.activate(self)
	managers.system_event_listener:add_listener(self._id, {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_PICKED_UP_AMMO
	}, callback(self, self, "on_ammo_collected"))
end

-- Lines 304-308
function ChallengeTaskCollectAmmo:deactivate()
	ChallengeTaskCollectAmmo.super.deactivate(self)
	managers.system_event_listener:remove_listener(self._id)
end

-- Lines 310-314
function ChallengeTaskCollectAmmo:reset()
	ChallengeTaskKillEnemies.super.reset(self)

	self._count = 0
end

-- Lines 316-318
function ChallengeTaskCollectAmmo:current_count()
	return self._count
end

-- Lines 320-322
function ChallengeTaskCollectAmmo:target()
	return self._target
end

-- Lines 324-326
function ChallengeTaskCollectAmmo:min_range()
	return 0
end

-- Lines 328-330
function ChallengeTaskCollectAmmo:max_range()
	return 0
end

-- Lines 332-334
function ChallengeTaskCollectAmmo:set_reminders(reminders)
	self._reminders = reminders
end

-- Lines 336-338
function ChallengeTaskCollectAmmo:set_modifiers(modifiers)
	self._modifiers = modifiers
end

-- Lines 340-359
function ChallengeTaskCollectAmmo:on_ammo_collected(ammo_info)
	if managers.raid_job:is_camp_loaded() then
		return
	end

	self._count = self._count + ammo_info.amount

	if self._target < self._count then
		self._count = self._target
	end

	for i = 1, #self._reminders do
		if self._count == self._reminders[i] then
			local challenge_data = managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):data()

			managers.weapon_skills:remind_weapon_challenge(challenge_data.weapon, challenge_data.tier, challenge_data.skill_index)
		end
	end

	self:_check_status()
end

-- Lines 361-365
function ChallengeTaskCollectAmmo:_check_status()
	if self._target <= self._count then
		self:_on_completed()
	end
end

-- Lines 367-372
function ChallengeTaskCollectAmmo:_on_completed()
	self._state = ChallengeTask.STATE_COMPLETED

	managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):on_task_completed()
	managers.system_event_listener:remove_listener(self._id)
end

-- Lines 374-383
function ChallengeTaskCollectAmmo:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
	self._count = self._target

	managers.system_event_listener:remove_listener(self._id)
end
