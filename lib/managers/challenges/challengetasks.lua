ChallengeTask = ChallengeTask or class()
ChallengeTask.STATE_INACTIVE = "inactive"
ChallengeTask.STATE_ACTIVE = "active"
ChallengeTask.STATE_COMPLETED = "completed"
ChallengeTask.STATE_FAILED = "failed"

function ChallengeTask.create(task_type, challenge_category, challenge_id, task_data)
	if task_type == ChallengeTweakData.TASK_KILL_ENEMIES then
		return ChallengeTaskKillEnemies:new(challenge_category, challenge_id, task_data)
	elseif task_type == ChallengeTweakData.TASK_COLLECT_AMMO then
		return ChallengeTaskCollectAmmo:new(challenge_category, challenge_id, task_data)
	end
end

function ChallengeTask.get_metatable(task_type)
	if task_type == ChallengeTweakData.TASK_KILL_ENEMIES then
		return ChallengeTaskKillEnemies
	elseif task_type == ChallengeTweakData.TASK_COLLECT_AMMO then
		return ChallengeTaskCollectAmmo
	end
end

function ChallengeTask:init()
	self._state = ChallengeTask.STATE_INACTIVE
end

function ChallengeTask:setup()
	if self._state == ChallengeTask.STATE_ACTIVE then
		self._state = ChallengeTask.STATE_INACTIVE

		self:activate()
	end
end

function ChallengeTask:activate()
	self._state = ChallengeTask.STATE_ACTIVE
end

function ChallengeTask:deactivate()
	self._state = ChallengeTask.STATE_INACTIVE
end

function ChallengeTask:reset()
	if self._state == Challenge.STATE_COMPLETED or self._state == Challenge.STATE_FAILED then
		self._state = Challenge.STATE_INACTIVE
	end
end

function ChallengeTask:active()
	return self._state == ChallengeTask.STATE_ACTIVE and true or false
end

function ChallengeTask:completed()
	return self._state == ChallengeTask.STATE_COMPLETED and true or false
end

function ChallengeTask:id()
	return self._id
end

function ChallengeTask:type()
	return self._type
end

function ChallengeTask:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
end

ChallengeTaskKillEnemies = ChallengeTaskKillEnemies or class(ChallengeTask)

function ChallengeTaskKillEnemies:init(challenge_category, challenge_id, task_data)
	ChallengeTaskKillEnemies.super.init(self)

	self._count = 0
	self._target = task_data.target
	self._min_range = task_data.min_range
	self._parent_challenge_category = challenge_category
	self._parent_challenge_id = challenge_id
	self._id = self._parent_challenge_id .. "_kill_enemies"
	self._type = ChallengeTweakData.TASK_KILL_ENEMIES
	self._modifiers = task_data.modifiers or {}
	self._reminders = task_data.reminders or {}
end

function ChallengeTaskKillEnemies:activate()
	ChallengeTaskKillEnemies.super.activate(self)
	managers.system_event_listener:add_listener(self._id, {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "on_enemy_killed"))
end

function ChallengeTaskKillEnemies:deactivate()
	ChallengeTaskKillEnemies.super.deactivate(self)
	managers.system_event_listener:remove_listener(self._id)
end

function ChallengeTaskKillEnemies:reset()
	ChallengeTaskKillEnemies.super.reset(self)

	self._count = 0
end

function ChallengeTaskKillEnemies:current_count()
	return self._count
end

function ChallengeTaskKillEnemies:target()
	return self._target
end

function ChallengeTaskKillEnemies:min_range()
	return self._modifiers.min_range or 0
end

function ChallengeTaskKillEnemies:set_reminders(reminders)
	self._reminders = reminders
end

function ChallengeTaskKillEnemies:set_modifiers(modifiers)
	self._modifiers = modifiers
end

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

	if self._modifiers.min_range and kill_data.enemy_distance < self._modifiers.min_range then
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

function ChallengeTaskKillEnemies:_check_status()
	if self._target <= self._count then
		self:_on_completed()
	end
end

function ChallengeTaskKillEnemies:_on_completed()
	self._state = ChallengeTask.STATE_COMPLETED

	managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):on_task_completed()
	managers.system_event_listener:remove_listener(self._id)
end

function ChallengeTaskKillEnemies:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
	self._count = self._target

	managers.system_event_listener:remove_listener(self._id)
end

ChallengeTaskCollectAmmo = ChallengeTaskCollectAmmo or class(ChallengeTask)

function ChallengeTaskCollectAmmo:init(challenge_category, challenge_id, task_data)
	ChallengeTaskCollectAmmo.super.init(self)

	self._count = 0
	self._target = task_data.target
	self._parent_challenge_category = challenge_category
	self._parent_challenge_id = challenge_id
	self._id = self._parent_challenge_id .. "_collect_ammo"
	self._type = ChallengeTweakData.TASK_COLLECT_AMMO
	self._reminders = task_data.reminders or {}
end

function ChallengeTaskCollectAmmo:activate()
	ChallengeTaskCollectAmmo.super.activate(self)
	managers.system_event_listener:add_listener(self._id, {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_PICKED_UP_AMMO
	}, callback(self, self, "on_ammo_collected"))
end

function ChallengeTaskCollectAmmo:deactivate()
	ChallengeTaskCollectAmmo.super.deactivate(self)
	managers.system_event_listener:remove_listener(self._id)
end

function ChallengeTaskCollectAmmo:reset()
	ChallengeTaskKillEnemies.super.reset(self)

	self._count = 0
end

function ChallengeTaskCollectAmmo:current_count()
	return self._count
end

function ChallengeTaskCollectAmmo:target()
	return self._target
end

function ChallengeTaskCollectAmmo:min_range()
	return 0
end

function ChallengeTaskCollectAmmo:set_reminders(reminders)
	self._reminders = reminders
end

function ChallengeTaskCollectAmmo:set_modifiers(modifiers)
	self._modifiers = modifiers
end

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

function ChallengeTaskCollectAmmo:_check_status()
	if self._target <= self._count then
		self:_on_completed()
	end
end

function ChallengeTaskCollectAmmo:_on_completed()
	self._state = ChallengeTask.STATE_COMPLETED

	managers.challenge:get_challenge(self._parent_challenge_category, self._parent_challenge_id):on_task_completed()
	managers.system_event_listener:remove_listener(self._id)
end

function ChallengeTaskCollectAmmo:force_complete()
	if self:completed() then
		return
	end

	self._state = ChallengeTask.STATE_COMPLETED
	self._count = self._target

	managers.system_event_listener:remove_listener(self._id)
end
