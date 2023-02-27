WeaponSkillsManager = WeaponSkillsManager or class()
WeaponSkillsManager.VERSION = 94
WeaponSkillsManager.SCOPE_WEAPON_PART_TYPE = "scope"
WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE = "activate"
WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE = "deactivate"

function WeaponSkillsManager:init()
	self:_setup()
end

function WeaponSkillsManager:_setup(reset)
	if not Global.weapon_skills_manager or reset then
		Global.weapon_skills_manager = {
			version = WeaponSkillsManager.VERSION,
			reset_message = false,
			available_weapon_skill_points = 0,
			gained_weapon_skill_points = 0,
			weapon_skills_skill_tree = {}
		}

		self:set_character_default_weapon_skills()

		self._global = Global.weapon_skills_manager
	end

	self._global = Global.weapon_skills_manager
end

function WeaponSkillsManager:set_character_default_weapon_skills()
	Global.weapon_skills_manager.weapon_skills_skill_tree = deep_clone(tweak_data.weapon_skills.skill_trees)

	self:_initialize_weapon_skill_challenges()
	self:_goldm1_convert_weapon_skill_challenges()
end

function WeaponSkillsManager:set_hide_cosmetic_parts(weapon_id, weapon_parts, invisible)
	local hidden_parts = nil
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

	if weapon_skill_tree and weapon_skill_tree.hidden_parts then
		hidden_parts = weapon_skill_tree.hidden_parts
	else
		weapon_skill_tree.hidden_parts = {}
		hidden_parts = weapon_skill_tree.hidden_parts
	end

	if not invisible then
		for _, weapon_part_id in ipairs(weapon_parts) do
			for i, v in ipairs(deep_clone(hidden_parts)) do
				if v == weapon_part_id then
					if hidden_parts then
						table.remove(hidden_parts, i)
					else
						hidden_parts = {
							i
						}
					end
				end
			end
		end
	else
		for _, weapon_part_id in ipairs(weapon_parts) do
			if not self:get_hide_cosmetic_part(weapon_part_id) then
				table.insert(hidden_parts, weapon_part_id)
			end
		end
	end
end

function WeaponSkillsManager:get_hide_cosmetic_part(weapon_id, weapon_part_id)
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]
	local hidden_parts = nil

	if weapon_skill_tree and weapon_skill_tree.hidden_parts then
		hidden_parts = weapon_skill_tree.hidden_parts

		for _, v in ipairs(hidden_parts) do
			if v == weapon_part_id then
				return true
			end
		end
	end

	return false
end

function WeaponSkillsManager:_initialize_weapon_skill_challenges()
	local function get_challenge_id(wep_id, skill_name, tier_idx)
		return wep_id .. "_" .. skill_name .. "_" .. tostring(tier_idx)
	end

	for weapon_id, skill_tree in pairs(Global.weapon_skills_manager.weapon_skills_skill_tree) do
		for tier_index = 1, #skill_tree do
			local tier_skills = skill_tree[tier_index]

			for skill_index, skills in pairs(tier_skills) do
				local skill = skills[1]

				if skill.challenge_tasks then
					local challenge_id = get_challenge_id(weapon_id, skill.skill_name, tostring(tier_index))

					if not managers.challenge:challenge_exists(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_id) then
						local challenge_tasks = skill.challenge_tasks
						local challenge_callback = {
							target = "managers.weapon_skills",
							method = "on_weapon_challenge_completed",
							params = {
								weapon_id,
								tier_index,
								skill_index
							}
						}
						local challenge_data = {
							weapon = weapon_id,
							tier = tier_index,
							skill_index = skill_index
						}

						managers.challenge:create_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_id, challenge_tasks, challenge_callback, challenge_data)
					else
						local tasks = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_id):tasks()

						for task_index, task in pairs(tasks) do
							local reminders = skill.challenge_tasks[task_index].reminders or {}

							task:set_reminders(reminders)

							local modifiers = skill.challenge_tasks[task_index].modifiers or {}

							task:set_modifiers(modifiers)
						end
					end

					skill.challenge_id = challenge_id
					skill.weapon_id = weapon_id
					skill.tier = tier_index
					skill.index_in_tier = skill_index

					local function is_previous_challenge_unlocked(idx)
						local previous_tier = tier_skills[idx]

						if previous_tier then
							local previous_challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, tier_skills[idx][1].challenge_id)

							return tier_skills[idx] and previous_challenge:completed()
						end

						return false
					end

					if tier_index == 1 or is_previous_challenge_unlocked(skill_index - 1) then
						skill.challenge_unlocked = true
					elseif skill_tree[tier_index - 1][skill_index] == nil then
						skill.challenge_unlocked = true
					else
						skill.challenge_unlocked = false
					end
				end
			end
		end
	end
end

function WeaponSkillsManager:_goldm1_convert_weapon_skill_challenges()
	local changed_any_skills = false
	local skills = Global.weapon_skills_manager.weapon_skills_skill_tree
	local norm_garand = skills.garand
	local gold_garand = skills.garand_golden

	if norm_garand and gold_garand then
		for tier_index = 1, #gold_garand do
			local gold_tier_skills = gold_garand[tier_index]
			local norm_tier_skills = norm_garand[tier_index]

			for skill_index, skill in pairs(gold_tier_skills) do
				if managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill[1].challenge_id):completed() then
					Application:debug("[WeaponSkillsManager:_goldm1_convert_weapon_skill_challenges()] Unlocking Garand Skill, Tier", tier_index, ": Skill IDX", skill_index, norm_tier_skills[skill_index][1].skill_name)
					managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, norm_tier_skills[skill_index][1].challenge_id):force_complete()

					changed_any_skills = true
				end
			end
		end
	end

	if not changed_any_skills then
		Application:debug("[WeaponSkillsManager:_goldm1_convert_weapon_skill_challenges()] No skills were affected.")
	end
end

function WeaponSkillsManager:activate_current_challenges_for_weapon(weapon_id)
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

	if not weapon_skill_tree then
		return
	end

	for tier_index = 1, #weapon_skill_tree do
		local tier_skills = weapon_skill_tree[tier_index]
		local tier_unlocked = managers.weapon_skills:is_weapon_tier_unlocked(weapon_id, tier_index)

		if tier_unlocked then
			for skill_index, skill in pairs(tier_skills) do
				if skill[1].challenge_unlocked == true and not skill[1].active then
					managers.challenge:activate_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill[1].challenge_id)
				end
			end
		end
	end
end

function WeaponSkillsManager:deactivate_challenges_for_weapon(weapon_id)
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

	if not weapon_skill_tree then
		return
	end

	for tier_index = 1, #weapon_skill_tree do
		local tier_skills = weapon_skill_tree[tier_index]

		for skill_index, skill in pairs(tier_skills) do
			if skill[1].challenge_id then
				managers.challenge:deactivate_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill[1].challenge_id)
			end
		end
	end
end

function WeaponSkillsManager:get_active_weapon_challenges_for_weapon(weapon_id)
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

	if not weapon_skill_tree then
		return
	end

	local active_weapon_challenges = {}

	for tier_index = #weapon_skill_tree, 1, -1 do
		local tier_skills = weapon_skill_tree[tier_index]
		local tier_unlocked = managers.weapon_skills:is_weapon_tier_unlocked(weapon_id, tier_index)

		if tier_unlocked then
			for skill_index, skill in pairs(tier_skills) do
				if skill[1].challenge_unlocked and not managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill[1].challenge_id):completed() then
					table.insert(active_weapon_challenges, skill[1])
				end
			end
		end
	end

	return #active_weapon_challenges > 0 and active_weapon_challenges or nil
end

function WeaponSkillsManager:update_weapon_challenges(weapon_id)
	if Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] then
		local skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

		for tier_index = 1, #skill_tree do
			local tier_skills = skill_tree[tier_index]

			for skill_index, skill in pairs(tier_skills) do
				if skill[1].challenge_id then
					local challenge_from_manager = managers.challenge._challenges[ChallengeManager.CATEGORY_WEAPON_UPGRADE][skill[1].challenge_id]

					if challenge_from_manager._state and challenge_from_manager._state ~= "completed" then
						local tweak_data_challenge_data = tweak_data.weapon_skills.skill_trees[weapon_id][tier_index][skill_index][1].challenge_tasks[1]
						skill[1].challenge_tasks[1].target = tweak_data_challenge_data.target
						skill[1].challenge_tasks[1].reminders = tweak_data_challenge_data.reminders
						challenge_from_manager._tasks[1]._target = tweak_data_challenge_data.target
						challenge_from_manager._tasks[1]._reminders = tweak_data_challenge_data.reminders

						if tweak_data_challenge_data.modifiers then
							challenge_from_manager._tasks[1]._modifiers = tweak_data_challenge_data.modifiers
							skill[1].challenge_tasks[1].modifiers = tweak_data_challenge_data.modifiers
						end

						if challenge_from_manager._tasks[1]._target <= challenge_from_manager._tasks[1]._count then
							Application:trace("[WeaponSkillsManager:update_weapon_challenges] Target for new Weapon challenge already met! Challenge_id: " .. skill[1].challenge_id .. ", Count is: " .. challenge_from_manager._tasks[1]._count .. " ,  New target is: " .. challenge_from_manager._tasks[1]._target .. ", Forcing a challenge completetion")

							challenge_from_manager._tasks[1]._count = challenge_from_manager._tasks[1]._target

							challenge_from_manager:force_complete()
						end
					end
				end
			end
		end
	end

	managers.savefile:set_resave_required()
end

function WeaponSkillsManager:check_weapon_challenges_for_changes(weapon_id)
	local challenges_changed = false

	if Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] then
		local skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

		for tier_index = 1, #skill_tree do
			local tier_skills = skill_tree[tier_index]

			for skill_index, skill in pairs(tier_skills) do
				if skill[1].challenge_id then
					local tweak_data_challenge_data = tweak_data.weapon_skills.skill_trees[weapon_id][tier_index][skill_index][1].challenge_tasks[1]
					local challenge_from_manager = managers.challenge._challenges[ChallengeManager.CATEGORY_WEAPON_UPGRADE][skill[1].challenge_id]

					for i = 1, #tweak_data_challenge_data.reminders do
						if skill[1].challenge_tasks[1].reminders[i] ~= tweak_data_challenge_data.reminders[i] then
							challenges_changed = true

							print(inspect(skill[1].challenge_tasks[1].reminders[i]) .. ", " .. inspect(tweak_data_challenge_data.reminders[i]))
						end

						if challenge_from_manager._tasks[1]._reminders[i] ~= tweak_data_challenge_data.reminders[i] then
							challenges_changed = true

							print(challenge_from_manager._tasks[1]._reminders[i] .. ", " .. tweak_data_challenge_data.reminders[i])
						end
					end

					if tweak_data_challenge_data.modifiers then
						for modifier, _ in pairs(tweak_data_challenge_data.modifiers) do
							if modifier ~= "enemy_type" then
								if challenge_from_manager._tasks[1]._modifiers[modifier] ~= tweak_data_challenge_data.modifiers[modifier] then
									challenges_changed = true

									print(inspect(challenge_from_manager._tasks[1]._modifiers[modifier]) .. ", " .. inspect(tweak_data_challenge_data.modifiers[modifier]))
								end

								if skill[1].challenge_tasks[1].modifiers[modifier] ~= tweak_data_challenge_data.modifiers[modifier] then
									challenges_changed = true

									print(inspect(skill[1].challenge_tasks[1].modifiers[modifier]) .. ", " .. inspect(skill[1].challenge_tasks[1].modifiers[modifier]))
								end
							else
								if challenge_from_manager._tasks[1]._modifiers[modifier][1] ~= tweak_data_challenge_data.modifiers[modifier][1] then
									challenges_changed = true

									print(inspect(challenge_from_manager._tasks[1]._modifiers[modifier]) .. ", " .. inspect(tweak_data_challenge_data.modifiers[modifier]))
								end

								if skill[1].challenge_tasks[1].modifiers[modifier][1] ~= tweak_data_challenge_data.modifiers[modifier][1] then
									challenges_changed = true

									print(inspect(skill[1].challenge_tasks[1].modifiers[modifier]) .. ", " .. inspect(skill[1].challenge_tasks[1].modifiers[modifier]))
								end
							end
						end
					end

					if skill[1].challenge_tasks[1].target ~= tweak_data_challenge_data.target then
						challenges_changed = true

						print(skill[1].challenge_tasks[1].target .. ", " .. tweak_data_challenge_data.target)
					end

					if challenge_from_manager._tasks[1]._target ~= tweak_data_challenge_data.target then
						challenges_changed = true

						print(challenge_from_manager._tasks[1]._target .. ", " .. tweak_data_challenge_data.target)
					end
				end
			end
		end
	end

	return challenges_changed
end

function WeaponSkillsManager:remind_weapon_challenge(weapon_id, tier_index, skill_index)
	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]
	local notification_data = {
		priority = 1,
		duration = 4,
		id = weapon_skill_tree[tier_index][skill_index][1],
		notification_type = HUDNotification.WEAPON_CHALLENGE,
		challenge = weapon_skill_tree[tier_index][skill_index][1]
	}

	managers.notification:add_notification(notification_data)
end

function WeaponSkillsManager:on_weapon_challenge_completed(weapon_id, tier_index, skill_index)
	if not tweak_data.weapon[weapon_id] then
		Application:error("[WeaponSkillsManager:on_weapon_challenge_completed] weapon_id doesnt exist, ignoring", weapon_id, tier_index, skill_index)

		return
	end

	local weapon_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]
	local notification_data = {
		priority = 1,
		duration = 4,
		id = weapon_skill_tree[tier_index][skill_index][1],
		notification_type = HUDNotification.WEAPON_CHALLENGE,
		challenge = weapon_skill_tree[tier_index][skill_index][1]
	}

	managers.notification:add_notification(notification_data)

	local weapon_selection_index = tweak_data.weapon[weapon_id].use_data.selection_index
	local weapon_category = managers.weapon_inventory:get_weapon_category_name_by_bm_category_id(weapon_selection_index)

	managers.hud._sound_source:post_event("weapon_challenge_complete")
	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_WEAPON_UPGRADE, {
		weapon_category,
		weapon_id,
		tier_index,
		skill_index
	})
	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

function WeaponSkillsManager:has_new_weapon_upgrades(params)
	if not params or not params.weapon_category or params.weapon_category == WeaponInventoryManager.CATEGORY_NAME_PRIMARY then
		local owned_primary_weapons = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)

		for index, weapon in pairs(owned_primary_weapons) do
			if weapon.unlocked and managers.breadcrumb:category_has_breadcrumbs(BreadcrumbManager.CATEGORY_WEAPON_UPGRADE, {
				WeaponInventoryManager.CATEGORY_NAME_PRIMARY,
				weapon.weapon_id
			}) and (not params or not params.weapon_id or params.weapon_id == weapon.weapon_id) then
				return true
			end
		end
	end

	if not params or not params.weapon_category or params.weapon_category == WeaponInventoryManager.CATEGORY_NAME_SECONDARY then
		local owned_secondary_weapons = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)

		for index, weapon in pairs(owned_secondary_weapons) do
			if weapon.unlocked and managers.breadcrumb:category_has_breadcrumbs(BreadcrumbManager.CATEGORY_WEAPON_UPGRADE, {
				WeaponInventoryManager.CATEGORY_NAME_SECONDARY,
				weapon.weapon_id
			}) and (not params or not params.weapon_id or params.weapon_id == weapon.weapon_id) then
				return true
			end
		end
	end

	return false
end

function WeaponSkillsManager:is_weapon_skills_tree_empty()
	local result = true

	if Global.weapon_skills_manager and Global.weapon_skills_manager.weapon_skills_skill_tree then
		for index, data in pairs(Global.weapon_skills_manager.weapon_skills_skill_tree) do
			result = false

			break
		end
	end

	return result
end

function WeaponSkillsManager:get_weapon_skills(weapon_id)
	local skill_tree = self._global.weapon_skills_skill_tree[weapon_id]

	return skill_tree
end

function WeaponSkillsManager:get_available_weapon_skill_points()
	return Global.weapon_skills_manager.available_weapon_skill_points
end

function WeaponSkillsManager:set_available_weapon_skill_points(value)
	Global.weapon_skills_manager.available_weapon_skill_points = value
end

function WeaponSkillsManager:add_available_weapon_skill_points(value)
	if not Global.weapon_skills_manager.available_weapon_skill_points then
		Global.weapon_skills_manager.available_weapon_skill_points = 0
	end

	Global.weapon_skills_manager.available_weapon_skill_points = Global.weapon_skills_manager.available_weapon_skill_points + value
end

function WeaponSkillsManager:add_weapon_skill_points_as_drops(value)
	if not Global.weapon_skills_manager.gained_weapon_skill_points then
		Global.weapon_skills_manager.gained_weapon_skill_points = 0
	end

	Global.weapon_skills_manager.gained_weapon_skill_points = Global.weapon_skills_manager.gained_weapon_skill_points + value

	self:add_available_weapon_skill_points(value)
end

function WeaponSkillsManager:remove_weapon_skill_points_as_drops(value)
	Global.weapon_skills_manager.gained_weapon_skill_points = Global.weapon_skills_manager.gained_weapon_skill_points - value

	if Global.weapon_skills_manager.gained_weapon_skill_points < 0 then
		Global.weapon_skills_manager.gained_weapon_skill_points = 0
	end

	self:set_available_weapon_skill_points(Global.weapon_skills_manager.available_weapon_skill_points - value)

	if self:get_available_weapon_skill_points() < 0 then
		self:set_available_weapon_skill_points(0)
	end
end

function WeaponSkillsManager:apply_skill(weapon_id, tier_number, tier_skill_number)
	local weapon_skills = self._global.weapon_skills_skill_tree[weapon_id][tier_number][tier_skill_number]
	weapon_skills[1].active = true

	if self._global.weapon_skills_skill_tree[weapon_id][tier_number + 1] and self._global.weapon_skills_skill_tree[weapon_id][tier_number + 1][tier_skill_number] then
		self._global.weapon_skills_skill_tree[weapon_id][tier_number + 1][tier_skill_number][1].challenge_unlocked = true
	end
end

function WeaponSkillsManager:activate_skill(weapon_skill, bm_weapon_category_id)
	weapon_skill.active = true
	local weapon_id = weapon_skill.weapon_id
	local tier = weapon_skill.tier
	local index_in_tier = weapon_skill.index_in_tier

	if self._global.weapon_skills_skill_tree[weapon_id][tier + 1] and self._global.weapon_skills_skill_tree[weapon_id][tier + 1][index_in_tier] then
		self._global.weapon_skills_skill_tree[weapon_id][tier + 1][index_in_tier][1].challenge_unlocked = true
	end

	managers.achievment:award("ach_weap_apply_upgrade")

	local is_weapon_fully_upgraded, weapon_tier_count = managers.weapon_skills:is_weapon_fully_upgraded(weapon_id)

	if is_weapon_fully_upgraded then
		if bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID and weapon_tier_count == 4 then
			managers.achievment:award("ach_weap_prim_apply_all_upgrades")
		elseif bm_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			managers.achievment:award("ach_weap_sec_apply_all_upgrades")
		end
	end
end

function WeaponSkillsManager:deactivate_skill(weapon_skill)
	weapon_skill.active = nil
end

function WeaponSkillsManager:is_skill_active(weapon_id, tier_number, tier_skill_number)
	local weapon_skill = self._global.weapon_skills_skill_tree[weapon_id][tier_number][tier_skill_number]

	return weapon_skill and weapon_skill.active
end

function WeaponSkillsManager:get_weapon_skills_skill_tree()
	return Global.weapon_skills_manager.weapon_skills_skill_tree
end

function WeaponSkillsManager:is_weapon_fully_upgraded(weapon_id)
	local weapon_skill_tree = managers.weapon_skills._global.weapon_skills_skill_tree[weapon_id]
	local result = true
	local weapon_tier_count = 0

	if weapon_skill_tree then
		for tier_counter, tier_data in ipairs(weapon_skill_tree) do
			for tier_skill_counter, tier_skill_data in pairs(tier_data) do
				local skill_data = tier_skill_data[1]

				if not skill_data or skill_data and not skill_data.active then
					result = false

					break
				end
			end

			weapon_tier_count = weapon_tier_count + 1
		end
	end

	return result, weapon_tier_count
end

function WeaponSkillsManager:update_weapon_skills(weapon_category_id, weapon_id, action)
	local weapon_skills = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

	if not weapon_skills then
		Application:error("[WeaponSkillsManager:update_weapon_skills] Trying to update weapons skills for a weapon without a skill tree: ", weapon_category_id, weapon_id, action)

		return
	end

	for tier_counter = 1, #weapon_skills do
		for tier_skill_counter = 1, #weapon_skills[tier_counter] do
			if weapon_skills[tier_counter] and weapon_skills[tier_counter][tier_skill_counter] then
				local skill_data = weapon_skills[tier_counter][tier_skill_counter][1]

				if not self._temp_weapon_skills then
					self._temp_weapon_skills = {}
				end

				if skill_data.active then
					if not self._temp_weapon_skills[skill_data.skill_name] then
						self._temp_weapon_skills[skill_data.skill_name] = {
							value = skill_data.value
						}
					else
						self._temp_weapon_skills[skill_data.skill_name].value = skill_data.value
					end
				end
			end
		end
	end

	if self._temp_weapon_skills then
		for upgrade_name, count_data in pairs(self._temp_weapon_skills) do
			self:update_weapon_skill(upgrade_name, count_data, weapon_category_id, action)
		end
	end

	self._temp_weapon_skills = nil
end

function WeaponSkillsManager:_clear_all_weapon_part_animation_weights()
	if not managers.player:local_player() then
		return
	end

	for _, weapon_part_anim in ipairs(tweak_data.weapon._all_fps_animation_weights) do
		managers.player:local_player():camera():camera_unit():anim_state_machine():set_global(weapon_part_anim, 0)
		Application:trace("TURNING OFF WEAPON PART ANIM: ", weapon_part_anim)
	end
end

function WeaponSkillsManager:update_weapon_part_animation_weights()
	if not managers.player:local_player() then
		return
	end

	self:_clear_all_weapon_part_animation_weights()

	local equipped_primary_weapon_data = managers.weapon_inventory:get_equipped_primary_weapon()
	local equipped_secondary_weapon_data = managers.weapon_inventory:get_equipped_secondary_weapon()

	for _, weapon_part_name in ipairs(equipped_primary_weapon_data.blueprint) do
		local weapon_part_data = tweak_data.weapon.factory.parts[weapon_part_name]

		if weapon_part_data and weapon_part_data.fps_animation_weight then
			managers.player:local_player():camera():camera_unit():anim_state_machine():set_global(weapon_part_data.fps_animation_weight, 1)
			Application:trace("TURNING ON WEAPON PART ANIM: ", weapon_part_data.fps_animation_weight)
		end
	end

	for _, weapon_part_name in ipairs(equipped_secondary_weapon_data.blueprint) do
		local weapon_part_data = tweak_data.weapon.factory.parts[weapon_part_name]

		if weapon_part_data and weapon_part_data.fps_animation_weight then
			managers.player:local_player():camera():camera_unit():anim_state_machine():set_global(weapon_part_data.fps_animation_weight, 1)
			Application:trace("TURNING ON WEAPON PART ANIM: ", weapon_part_data.fps_animation_weight)
		end
	end
end

function WeaponSkillsManager:update_weapon_skill(raid_stat_name, data, weapon_category_id, action)
	local upgrade_name = self:get_upgrade_name_from_raid_stat_name(raid_stat_name)
	local weapon_category_string = weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID and "primary_weapon" or "secondary_weapon"
	local upgrade_full_name = weapon_category_string .. "_" .. upgrade_name .. "_" .. (data.value or "")

	if action == WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE then
		local upgrade_level = self:get_weapon_skills_current_upgrade_level(raid_stat_name, weapon_category_id)

		if upgrade_level > 0 then
			self:update_weapon_skill(raid_stat_name, data, weapon_category_id, WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE)
		end

		Application:trace("ACTIVATE UPGRADE: >>" .. upgrade_full_name .. "<<")
		managers.upgrades:aquire(upgrade_full_name, nil, UpgradesManager.AQUIRE_STRINGS[6])
	elseif action == WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE then
		Application:trace("DEACTIVATE UPGRADE: >>" .. upgrade_full_name .. "<<")
		managers.upgrades:unaquire(upgrade_full_name, UpgradesManager.AQUIRE_STRINGS[6])
	end
end

function WeaponSkillsManager:update_weapon_skill_by_upgrade_name(upgrade_category, upgrade_name, upgrade_level, action)
	local upgrade_full_name = upgrade_category .. "_" .. upgrade_name .. "_" .. upgrade_level

	if action == WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE then
		local upgrade_level = managers.player:upgrade_level(upgrade_category, upgrade_name, 0)

		if upgrade_level > 0 then
			managers.upgrades:unaquire(upgrade_full_name, UpgradesManager.AQUIRE_STRINGS[6])
		end

		managers.upgrades:aquire(upgrade_full_name, nil, UpgradesManager.AQUIRE_STRINGS[6])
	elseif action == WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE then
		managers.upgrades:unaquire(upgrade_full_name, UpgradesManager.AQUIRE_STRINGS[6])
	end
end

function WeaponSkillsManager:get_upgrade_name_from_raid_stat_name(raid_stat_name)
	local upgrade_name = ""

	if raid_stat_name == WeaponSkillsTweakData.SKILL_INCREASE_DAMAGE then
		upgrade_name = "damage_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_DECREASE_RECOIL then
		upgrade_name = "recoil_reduction"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_FASTER_RELOAD then
		upgrade_name = "reload_speed_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_FASTER_ADS then
		upgrade_name = "enter_steelsight_speed_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_FASTER_ROF then
		upgrade_name = "firerate_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_TIGHTER_SPREAD then
		upgrade_name = "spread_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_WIDER_SPREAD then
		upgrade_name = "spread_multiplier"
	elseif raid_stat_name == WeaponSkillsTweakData.SKILL_INCREASE_MAGAZINE then
		upgrade_name = "magazine_upgrade"
	end

	return upgrade_name
end

function WeaponSkillsManager:get_character_level_needed_for_tier(weapon_id, tier)
	local skill_tree = self:get_weapon_skills_skill_tree()
	local upgrade_name = skill_tree[weapon_id] and skill_tree[weapon_id].tier_unlock and skill_tree[weapon_id].tier_unlock[tier] or ""

	if tier < WeaponSkillsTweakData.MAX_TIERS then
		upgrade_name = upgrade_name .. "_" .. tostring(tier)
	end

	local max_level = 0
	local character_automatic_progression = managers.skilltree:get_character_automatic_unlock_progression()

	for level, level_unlocks in pairs(character_automatic_progression) do
		for category_name, category in pairs(level_unlocks) do
			for index, unlock in pairs(category) do
				if unlock == upgrade_name then
					return level
				end
			end
		end

		max_level = math.max(max_level, level)
	end

	local current_character_class = managers.skilltree:get_character_profile_class()

	for index, class_name_id in ipairs(tweak_data.skilltree.base_classes) do
		if class_name_id ~= current_character_class then
			local class_name = managers.localization:text(tweak_data.skilltree.classes[class_name_id].name_id)
			local class_automatic_progression = managers.skilltree:get_character_automatic_unlock_progression(class_name_id)

			for level, level_unlocks in pairs(class_automatic_progression) do
				for category_name, category in pairs(level_unlocks) do
					for index, unlock in pairs(category) do
						if unlock == upgrade_name then
							return level, class_name
						end
					end
				end
			end
		end
	end

	Application:error("[WeaponSkillsManager] Could not find unlock level for weapon: ", weapon_id, tier)

	return max_level
end

function WeaponSkillsManager:is_weapon_tier_unlocked(weapon_id, tier)
	local result = false
	local skill_tree = self:get_weapon_skills_skill_tree()
	local upgrade_name = skill_tree[weapon_id] and skill_tree[weapon_id].tier_unlock and skill_tree[weapon_id].tier_unlock[tier] or ""

	if upgrade_name == "" then
		result = true
	elseif upgrade_name == "weapon_tier_unlocked" then
		local unlocked_tier = managers.player:upgrade_value("player", "weapon_tier_unlocked", 1)

		if tier <= unlocked_tier then
			result = true
		end
	elseif upgrade_name == "recon_tier_4_unlocked" or upgrade_name == "assault_tier_4_unlocked" or upgrade_name == "infiltrator_tier_4_unlocked" or upgrade_name == "demolitions_tier_4_unlocked" then
		local tier_4_result = managers.player:upgrade_value("player", upgrade_name, false)
		result = tier_4_result ~= 0
	end

	return result
end

function WeaponSkillsManager:get_weapon_skills_current_upgrade_level(raid_stat_name, weapon_category_id)
	local weapon_category_string = weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID and "primary_weapon" or "secondary_weapon"
	local upgrade_name = self:get_upgrade_name_from_raid_stat_name(raid_stat_name)
	local upgrade_level = managers.player:upgrade_level(weapon_category_string, upgrade_name, 0)

	return upgrade_level
end

function WeaponSkillsManager:deactivate_all_upgrades_for_bm_weapon_category_id(weapon_category_id)
	local upgrades_table = nil
	local weapon_category_name = ""

	if weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		upgrades_table = tweak_data.upgrades.values.primary_weapon
		weapon_category_name = "primary_weapon"
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		upgrades_table = tweak_data.upgrades.values.secondary_weapon
		weapon_category_name = "secondary_weapon"
	end

	if not upgrades_table or weapon_category_name == "" then
		return
	end

	for upgrade_name, upgrade_values in pairs(upgrades_table) do
		local current_upgrade_level = managers.player:upgrade_level(weapon_category_name, upgrade_name, 0)

		if current_upgrade_level > 0 then
			local upgrade_full_name = weapon_category_name .. "_" .. upgrade_name .. "_" .. current_upgrade_level

			managers.upgrades:unaquire(upgrade_full_name, UpgradesManager.AQUIRE_STRINGS[6])
			Application:trace("WeaponSkillsManager:deactivate_all_upgrades_for_bm_weapon_category_id] unaquire upgrade_full_name ")
		end
	end
end

function WeaponSkillsManager:get_player_using_scope(weapon_id)
	return true
end

function WeaponSkillsManager:set_player_using_scope(weapon_id, flag)
	Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id].use_scope = true
end

function WeaponSkillsManager:get_scope_weapon_part_name(weapon_id)
	local result = nil

	if weapon_id == "mp44" and managers.weapon_skills:get_weapon_skills("mp44")[2][4][1].active ~= true then
		return result
	end

	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)

	if tweak_data.weapon.factory[factory_id] and tweak_data.weapon.factory[factory_id].uses_parts then
		for _, weapon_part_name in ipairs(tweak_data.weapon.factory[factory_id].uses_parts) do
			if tweak_data.weapon.factory.parts[weapon_part_name].type == WeaponSkillsManager.SCOPE_WEAPON_PART_TYPE then
				result = weapon_part_name

				break
			end
		end
	end

	return result
end

function WeaponSkillsManager:save(data)
	local state = {
		version = Global.weapon_skills_manager.version,
		available_weapon_skill_points = Global.weapon_skills_manager.available_weapon_skill_points,
		weapon_skills_skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree,
		gained_weapon_skill_points = Global.weapon_skills_manager.gained_weapon_skill_points
	}
	data.WeaponSkillsManager = state
end

function WeaponSkillsManager:load(data, version)
	Application:trace("[WeaponSkillsManager:load] data.WeaponSkillsManager ", inspect(data.WeaponSkillsManager.weapon_skills_skill_tree.thompson))
	self:_setup(true)

	local state = data.WeaponSkillsManager

	if not state then
		return
	end

	if not state.version or state.version and state.version ~= WeaponSkillsManager.VERSION then
		Application:trace("[WeaponSkillsManager:load] The save data and manager version are mismatched! Migrating...")

		Global.weapon_skills_manager.version = WeaponSkillsManager.VERSION
		Global.weapon_skills_manager.available_weapon_skill_points = state.gained_weapon_skill_points or 0
		Global.weapon_skills_manager.gained_weapon_skill_points = state.gained_weapon_skill_points or 0

		self:set_character_default_weapon_skills()
		managers.savefile:set_resave_required()
	else
		Global.weapon_skills_manager.version = state.version or 1
		Global.weapon_skills_manager.available_weapon_skill_points = state.available_weapon_skill_points or 0
		Global.weapon_skills_manager.gained_weapon_skill_points = state.gained_weapon_skill_points or 0
		Global.weapon_skills_manager.weapon_skills_skill_tree = state.weapon_skills_skill_tree or deep_clone(tweak_data.weapon_skills.skill_trees)
		local new_weapon_added = false

		for weapon_id, weapon_skill_tree_data in pairs(tweak_data.weapon_skills.skill_trees) do
			if not Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] then
				Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] = deep_clone(weapon_skill_tree_data)
				local skill_tree = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id]

				for tier_index = 1, #skill_tree do
					local tier_skills = skill_tree[tier_index]

					for skill_index, skill in pairs(tier_skills) do
						if skill[1].challenge_tasks then
							local challenge_id = weapon_id .. "_" .. skill[1].skill_name .. "_" .. tostring(tier_index)
							local challenge_tasks = skill[1].challenge_tasks
							local challenge_callback = {
								target = "managers.weapon_skills",
								method = "on_weapon_challenge_completed",
								params = {
									weapon_id,
									tier_index,
									skill_index
								}
							}
							local challenge_data = {
								weapon = weapon_id,
								tier = tier_index,
								skill_index = skill_index
							}

							managers.challenge:create_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, challenge_id, challenge_tasks, challenge_callback, challenge_data)

							skill[1].challenge_id = challenge_id
							skill[1].weapon_id = weapon_id
							skill[1].tier = tier_index
							skill[1].index_in_tier = skill_index
							local previous_challenge_unlocked = tier_skills[skill_index - 1] and managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, tier_skills[skill_index - 1][1].challenge_id):completed()

							if tier_index == 1 or previous_challenge_unlocked then
								skill[1].challenge_unlocked = true
							elseif skill_tree[tier_index - 1][skill_index] == nil then
								skill[1].challenge_unlocked = true
							else
								skill[1].challenge_unlocked = false
							end
						end
					end
				end

				new_weapon_added = true
			elseif managers.weapon_skills:check_weapon_challenges_for_changes(weapon_id) then
				Application:trace("[WeaponSkillsManager:load] Weapon challenges for " .. weapon_id .. " are mismatched, Updating...")
				managers.weapon_skills:update_weapon_challenges(weapon_id)
			end
		end

		if new_weapon_added then
			managers.savefile:set_resave_required()
		end
	end

	self:_force_complete_stuck_weapon_challenges()
	self:update_weapon_skills(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID, managers.weapon_inventory:get_equipped_primary_weapon_id(), "activate")
	self:update_weapon_skills(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID, managers.weapon_inventory:get_equipped_secondary_weapon_id(), "activate")
end

function WeaponSkillsManager:_force_complete_stuck_weapon_challenges()
	local need_resave = false

	for weapon_id, weapon_skill_tree in pairs(Global.weapon_skills_manager.weapon_skills_skill_tree) do
		for tier_index, tier_skill_data in ipairs(weapon_skill_tree) do
			for skill_index, skill_data in pairs(tier_skill_data) do
				for mod_index, mod_data in pairs(skill_data) do
					if mod_data.active == true then
						local challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, mod_data.challenge_id)

						if not challenge:completed() then
							debug_pause("[WeaponSkillsManager][_force_complete_stuck_weapon_challenges] Stuck weapon challenge found: ", weapon_id, tier_index, skill_index)
							challenge:force_complete()

							need_resave = true
						end
					end
				end
			end
		end
	end

	if need_resave then
		managers.savefile:save_game(SavefileManager.SETTING_SLOT)
	end
end

function WeaponSkillsManager:recreate_all_weapons_blueprints(weapon_category_id)
	local datasource = managers.weapon_inventory:get_owned_weapons(weapon_category_id)

	for index, weapon_data in pairs(datasource) do
		self:recreate_weapon_blueprint(weapon_data.weapon_id, weapon_category_id, nil, true)
	end
end

function WeaponSkillsManager:recreate_weapon_blueprint(weapon_id, weapon_category_id, temp_skills, apply_blueprint)
	local new_blueprint = nil

	if Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] then
		local tier_counter = 1

		for tier_counter = 1, #Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id] do
			local tier_skill_counter = 1

			for tier_skill_counter = 1, #Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id][tier_counter] do
				local skill_data = Global.weapon_skills_manager.weapon_skills_skill_tree[weapon_id][tier_counter][tier_skill_counter][1]

				if not self._temp_weapon_skills then
					self._temp_weapon_skills = {}
				end

				if (skill_data.active or temp_skills and temp_skills[skill_data]) and skill_data.weapon_parts then
					for index, weapon_part_name in ipairs(skill_data.weapon_parts) do
						local weapon_mod_hide = managers.weapon_skills:get_hide_cosmetic_part(weapon_id, weapon_part_name)

						if not weapon_mod_hide then
							local weapon_mod_type = tweak_data.weapon.factory.parts[weapon_part_name].type
							self._temp_weapon_skills[weapon_mod_type] = weapon_part_name
						end
					end
				end
			end
		end
	end

	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	new_blueprint = clone(managers.weapon_factory:get_default_blueprint_by_factory_id(weapon_factory_id))

	if self._temp_weapon_skills then
		for weapon_part_type, weapon_part_name in pairs(self._temp_weapon_skills) do
			local hide_part = managers.weapon_skills:get_hide_cosmetic_part(weapon_id, weapon_part_name)

			if not hide_part then
				managers.weapon_factory:change_part_blueprint_only(weapon_factory_id, weapon_part_name, new_blueprint, false)
			end
		end
	end

	if apply_blueprint then
		self:apply_weapon_blueprint(weapon_id, weapon_category_id, new_blueprint)
	end

	self._temp_weapon_skills = nil

	return new_blueprint
end

function WeaponSkillsManager:apply_weapon_blueprint(weapon_id, weapon_category_id, new_blueprint)
	local weapon_category_name = weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID and WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME or WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME

	if Global.blackmarket_manager.crafted_items and Global.blackmarket_manager.crafted_items[weapon_category_name] then
		for weapon_index, weapon_data in pairs(Global.blackmarket_manager.crafted_items[weapon_category_name]) do
			if weapon_data.weapon_id == weapon_id then
				Global.blackmarket_manager.crafted_items[weapon_category_name][weapon_index].blueprint = new_blueprint
				local local_peer = managers.network:session():local_peer()
				local outfit_version = local_peer:outfit_version()

				local_peer:set_outfit_string(managers.blackmarket:outfit_string(), outfit_version)

				break
			end
		end
	end
end
