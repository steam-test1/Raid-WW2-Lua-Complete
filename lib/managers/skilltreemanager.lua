SkillTreeManager = SkillTreeManager or class()
SkillTreeManager.VERSION = 29
SkillTreeManager.REWORK_VERSION = 29

function SkillTreeManager:init()
	self:_setup()
	self:_verify()
end

function SkillTreeManager:_setup(reset)
	if not Global.skilltree_manager or reset then
		Global.skilltree_manager = {
			VERSION = SkillTreeManager.VERSION,
			reset_message = false
		}
		self._global = Global.skilltree_manager
	end

	self._global = Global.skilltree_manager
end

function SkillTreeManager:_verify()
	local character_skilltree = self:get_character_skilltree()

	if not character_skilltree then
		return
	end

	local save_required = false
	local skill_tree_tweakdata = tweak_data.skilltree:get_skills_organised(self:get_character_profile_class())

	for i, skill_tree_data in ipairs(character_skilltree) do
		for skill_id, skill_data in pairs(skill_tree_tweakdata[i]) do
			if not skill_tree_data[skill_id] then
				skill_tree_data[skill_id] = deep_clone(skill_data)

				Application:debug("[SkillTreeManager:_verify] Added '" .. skill_id .. "' to save data skills!", inspect(skill_data))

				save_required = true
			end
		end
	end

	if save_required then
		managers.savefile:set_resave_required()
	end
end

function SkillTreeManager:_required_save_data(real_save_data)
	local save_data_skilltree = deep_clone(real_save_data)
	local t_filter = {
		gold_requirements = true,
		exp_requirements = true,
		exp_progression = true,
		exp_tier = true,
		active = true,
		warcry_id = true,
		upgrades_type = true
	}

	for type_idx, type_group_data in pairs(save_data_skilltree) do
		if type_idx == SkillTreeTweakData.TYPE_WARCRY or type_idx == SkillTreeTweakData.TYPE_BOOSTS or type_idx == SkillTreeTweakData.TYPE_TALENT then
			for skill_id, skill_data in pairs(type_group_data) do
				for key, _ in pairs(skill_data) do
					if not t_filter[key] then
						skill_data[key] = nil
					end
				end
			end
		end
	end

	return save_data_skilltree
end

function SkillTreeManager:save_profile_slot(data)
	local state = {
		version = SkillTreeManager.VERSION,
		purchased_skills = self._global.main_profile_purchased_skills,
		purchased_profiles = self._global.main_profile_purchased_profiles
	}
	data.SkillTreeManager = state
end

function SkillTreeManager:load_profile_slot(data, version)
	local state = data.SkillTreeManager
	local purchased_skills = state and state.purchased_skills or {}

	for skill_id, purchased in pairs(purchased_skills) do
		if not tweak_data.skilltree.skills[skill_id] then
			Application:error("[SkillTreeManager:load_profile_slot] Loaded skill doesn't exist in tweak data, removing: ", skill_id)

			purchased_skills[skill_id] = nil
		end
	end

	self._global.main_profile_purchased_skills = purchased_skills
	local purchased_profiles = state and state.purchased_profiles or {}

	for profile_index, cost in ipairs(tweak_data.skilltree.skill_profiles) do
		if cost == 0 then
			purchased_profiles[profile_index] = true
		end
	end

	self._global.main_profile_purchased_profiles = purchased_profiles
end

function SkillTreeManager:save_character_slot(data)
	local cleaned_save_data_skilltree = self:_required_save_data(self:get_character_skilltree())
	local display_stats = self:calculate_stats(self._global.character_profile_base_class)
	local state = {
		version = SkillTreeManager.VERSION,
		character_profile_base_class = self._global.character_profile_base_class,
		base_class_skill_tree = cleaned_save_data_skilltree,
		base_class_automatic_unlock_progression = self._global.base_class_automatic_unlock_progression,
		display_stats = self:calculate_stats(self._global.character_profile_base_class),
		skill_profiles = self._global.character_skill_profiles,
		active_skill_profile = self._global.character_active_skill_profile
	}
	data.SkillTreeManager = state
end

function SkillTreeManager:load_character_slot(data, version)
	self:reset_skills()

	local state = data.SkillTreeManager

	if not state then
		return
	end

	if state.version and state.version < SkillTreeManager.VERSION then
		self:_version_migrate_skilltree_data(state)

		return
	end

	self._global.character_profile_base_class = state.character_profile_base_class or SkillTreeTweakData.CLASS_RECON
	self._global.base_class_skill_tree = state.base_class_skill_tree or deep_clone(tweak_data.skilltree:get_skills_organised(self._global.character_profile_base_class))
	self._global.base_class_automatic_unlock_progression = state.base_class_automatic_unlock_progression or deep_clone(tweak_data.skilltree.automatic_unlock_progressions[self._global.character_profile_base_class])
	self._global.character_active_skill_profile = state.active_skill_profile or 1
	self._global.character_skill_profiles = state.skill_profiles

	self:_update_skill_profile_set()
	self:_verify_skilltree_data()

	if self._global.base_class_skill_tree then
		self:_activate_skill_tree(self._global.base_class_skill_tree, true)
	end

	if managers.player then
		self:apply_automatic_unlocks_for_levels_up_to(managers.experience:current_level(), nil, true)
	end
end

function SkillTreeManager:get_team_buff_upgrades()
	local tweak_data_skilltree = tweak_data.skilltree:get_skills_organised(self._global.character_profile_base_class)
	local save_data_skilltree = self:get_character_skilltree()
	local t = {}

	for type_idx, skilltree_data in ipairs(save_data_skilltree) do
		for skill_id, skill_data in pairs(skilltree_data) do
			local tweakdata_skill_data = tweak_data_skilltree[type_idx][skill_id]

			if tweakdata_skill_data and tweakdata_skill_data.upgrades_team_buff and skill_data.active and skill_data.exp_tier then
				t[skill_id] = t[skill_id] or {}

				for i = 1, skill_data.exp_tier do
					local upgs = tweakdata_skill_data.upgrades_team_buff[i] or {}

					for _, upgrade in ipairs(upgs) do
						table.insert(t[skill_id], upgrade)
					end
				end
			end
		end
	end

	return t
end

function SkillTreeManager:debug_reset_active_skills()
	local tweak_data_skilltree = tweak_data.skilltree:get_skills_organised(self._global.character_profile_base_class)
	local save_data_skilltree = self._global.base_class_skill_tree

	for type_idx, skilltree_data in ipairs(tweak_data_skilltree) do
		for skill_id, skill_data in pairs(skilltree_data) do
			save_data_skilltree[type_idx][skill_id] = deep_clone(skill_data)
		end
	end
end

function SkillTreeManager:_verify_skilltree_data()
	Application:debug("[SkillTreeManager:_verify_skilltree_data] Checking...")

	local tweak_data_skilltree = tweak_data.skilltree:get_skills_organised(self._global.character_profile_base_class)
	local save_data_skilltree = self:get_character_skilltree()

	for type_idx, skilltree_data in pairs(save_data_skilltree) do
		for skill_id, skill_data in pairs(skilltree_data) do
			if not tweak_data.skilltree.skills[skill_id] or tweak_data.skilltree.skills[skill_id].upgrades_type ~= skill_data.upgrades_type then
				if not tweak_data.skilltree.skills[skill_id] and skill_data.gold_requirements and self:is_skill_purchased(skill_id) then
					managers.gold_economy:add_loyalty_reward(GoldEconomyManager.LOYALTY_REMOVED_SKILL, skill_data.gold_requirements)
				end

				save_data_skilltree[type_idx][skill_id] = nil
				self._global.main_profile_purchased_skills[skill_id] = nil
			end
		end
	end

	local has_boost_active = false
	local current_level = managers.experience:current_level()

	for type_idx, skilltree_data in ipairs(tweak_data_skilltree) do
		for skill_id, skill_data in pairs(skilltree_data) do
			local save_data_skill = save_data_skilltree[type_idx][skill_id]

			if save_data_skill then
				local active = save_data_skill.active or nil
				local exp_tier = save_data_skill.exp_tier or nil
				local exp_progression = save_data_skill.exp_progression or nil
				local gold_requirements = save_data_skill.gold_requirements or nil
				local exp_requirements = save_data_skill.exp_requirements or nil

				if save_data_skill.upgrades_type == SkillTreeTweakData.TYPE_BOOSTS then
					if has_boost_active then
						Application:warn("[SkillTreeManager:_verify_skilltree_data] DEACTIVATING EXTRA BOOST")

						active = nil
					elseif active then
						has_boost_active = true
					end
				end

				if skill_data.level_required and current_level < skill_data.level_required then
					active = nil
				end

				save_data_skill = deep_clone(skill_data)
				save_data_skill.active = active
				save_data_skill.exp_tier = exp_tier
				save_data_skill.exp_progression = exp_progression
				save_data_skill.gold_requirements = gold_requirements or skill_data.gold_requirements

				if save_data_skill.exp_requirements ~= exp_requirements then
					-- Nothing
				end

				save_data_skilltree[type_idx][skill_id] = save_data_skill

				if self:is_skill_purchased(skill_id) then
					save_data_skill.exp_tier = math.max(save_data_skill.exp_tier or 1, 1)
					save_data_skill.exp_progression = save_data_skill.exp_progression or 0
				elseif exp_tier and exp_tier > 0 then
					self._global.main_profile_purchased_skills[skill_id] = true
				end
			else
				local t = {
					"Warcry",
					"Boost",
					"Talent"
				}

				Application:warn("[SkillTreeManager:_verify_skilltree_data] Skill was invalid - Type/Skill:", type_idx <= 3 and t[type_idx] or "Other", skill_id)

				save_data_skilltree[type_idx][skill_id] = deep_clone(skill_data)
			end
		end
	end

	local unlock_levels = tweak_data.skilltree:get_weapon_unlock_levels()
	local current_level = managers.experience:current_level()
	local current_class = self._global.character_profile_base_class
	local save_data_weapons = save_data_skilltree[SkillTreeTweakData.TYPE_WEAPON]

	for _, weapon_data in pairs(save_data_weapons) do
		if weapon_data.active then
			for _, weapon_id in ipairs(weapon_data.upgrades) do
				local weapon_unlock_level = unlock_levels[weapon_id] and unlock_levels[weapon_id][current_class]

				if not weapon_unlock_level or current_level < weapon_unlock_level then
					Application:warn("[SkillTreeManager:_verify_skilltree_data] Incorrectly unlocked weapon", weapon_id)

					weapon_data.active = nil
				end
			end
		end
	end

	Application:debug("[SkillTreeManager:_verify_skilltree_data] Done checking!")
end

function SkillTreeManager:_version_migrate_skilltree_data(state)
	Application:trace("[SkillTreeManager:_version_migrate_skilltree_data] Saved skilltree version: ", state.version, ", current version: ", SkillTreeManager.VERSION)

	if state.version < SkillTreeManager.REWORK_VERSION then
		Application:trace("[SkillTreeManager:_version_migrate_skilltree_data] Migrating from old skills system")

		local character_profile_base_class = state.character_profile_base_class or SkillTreeTweakData.CLASS_RECON

		self:set_character_profile_base_class(character_profile_base_class)

		local current_level = managers.experience:current_level()

		self:apply_automatic_unlocks_for_levels_up_to(current_level, nil, true)

		local level_tiers = math.ceil(current_level / 5)
		local gold_bonus = tweak_data.skilltree.migration_reward * level_tiers

		managers.gold_economy:add_loyalty_reward(GoldEconomyManager.LOYALTY_SKILL_REWORK, gold_bonus)
		managers.savefile:set_resave_required()
		self:_version_update_skilltree_data()
	end

	Application:trace("[SkillTreeManager:_version_migrate_skilltree_data] Done rebuilding skilltree manager save data")
end

function SkillTreeManager:_version_update_skilltree_data()
	local tweak_data_ref = tweak_data.skilltree:get_skills_organised(self._global.character_profile_base_class)
	local save_data_ref = self:get_character_skilltree()

	for type_idx, type_group_data in pairs(tweak_data_ref) do
		for skill_id, skill_data in pairs(type_group_data) do
			local save_data_skill_data = save_data_ref[type_idx] and save_data_ref[type_idx][skill_id]

			if not save_data_skill_data then
				Application:debug("[SkillTreeManager:_version_update_skilltree_data] not save_data_skill_data", type_idx, skill_id)
			end
		end
	end

	for type_idx, type_group_data in pairs(save_data_ref) do
		for skill_id, skill_data in pairs(type_group_data) do
			local tweak_data_skill_data = tweak_data_ref[type_idx] and tweak_data_ref[type_idx][skill_id]

			if tweak_data_skill_data and tweak_data_skill_data.exp_requirements then
				skill_data.exp_requirements = tweak_data_skill_data.exp_requirements

				if skill_data.exp_tier and skill_data.exp_tier < #skill_data.exp_requirements then
					skill_data.exp_progression = math.min(skill_data.exp_requirements[skill_data.exp_tier] - 1, skill_data.exp_progression)
				end
			end
		end
	end
end

function SkillTreeManager:unpack_from_string(packed_string)
	return packed_string
end

function SkillTreeManager:get_character_profile_class_data()
	return tweak_data.skilltree.classes[self._global.character_profile_base_class]
end

function SkillTreeManager:get_character_automatic_unlock_progression(class)
	return tweak_data.skilltree.automatic_unlock_progressions[class or self:get_character_profile_class()]
end

function SkillTreeManager:has_character_profile_class()
	return not not self._global.character_profile_base_class
end

function SkillTreeManager:get_character_profile_class()
	return self._global.character_profile_base_class
end

function SkillTreeManager:get_character_skilltree()
	return self._global.base_class_skill_tree
end

function SkillTreeManager:get_character_skill(type_idx, skill_id)
	if self._global.base_class_skill_tree[type_idx] then
		return self._global.base_class_skill_tree[type_idx][skill_id]
	end

	return nil
end

function SkillTreeManager:get_skills_applied()
	local skills_applied = {}
	local character_skilltree = self:get_character_skilltree()

	for skill_type, group_list in pairs(character_skilltree) do
		for id, skill in pairs(group_list) do
			if skill.active then
				skills_applied[id] = skill
			end
		end
	end

	return skills_applied
end

function SkillTreeManager:get_skills_applied_grouped()
	local skills_applied_grouped = {}
	local character_skilltree = self:get_character_skilltree()

	for skill_type, group_list in pairs(character_skilltree) do
		skills_applied_grouped[skill_type] = skills_applied_grouped[skill_type] or {}

		for id, skill in pairs(group_list) do
			if skill.active then
				skills_applied_grouped[skill_type][id] = skill
			end
		end
	end

	return skills_applied_grouped
end

function SkillTreeManager:get_warcries_applied()
	local skills_applied_grouped = {}
	local group_list = self:get_character_skilltree()[SkillTreeTweakData.TYPE_WARCRY]

	for id, skill in pairs(group_list) do
		if skill.active then
			skills_applied_grouped[id] = skill
		end
	end

	return skills_applied_grouped
end

function SkillTreeManager:get_warcry_id()
	local character_skilltree = self:get_character_skilltree()
	local group_list = character_skilltree[SkillTreeTweakData.TYPE_WARCRY]

	for id, skill in pairs(group_list) do
		if skill.active and skill.warcry_id then
			return skill.warcry_id
		end
	end

	debug_pause("[SkillTreeManager:get_warcry_id] Did not have a valid active warcry equipped!")

	return nil
end

function SkillTreeManager:get_amount_talents_applied()
	local amount = 0
	local character_skilltree = self:get_character_skilltree()
	local group_list = character_skilltree[SkillTreeTweakData.TYPE_TALENT]

	for skill_index, skill in pairs(group_list) do
		if skill.active then
			amount = amount + 1
		end
	end

	return amount
end

function SkillTreeManager:is_type_applied(skill_type)
	local character_skilltree = self:get_character_skilltree()
	local group_list = character_skilltree[skill_type]

	for skill_index, skill in pairs(group_list) do
		if skill.active then
			return true
		end
	end

	return false
end

function SkillTreeManager:get_skill_tier(skill_id)
	local character_skilltree = self:get_character_skilltree()

	for skill_type, group_list in pairs(character_skilltree) do
		for id, skill in pairs(group_list) do
			if skill_id == id then
				return skill.exp_tier or 1
			end
		end
	end
end

function SkillTreeManager:get_skill_button_status(skill_type, skill_id)
	local tweakdata_skill_data = tweak_data.skilltree.skills[skill_id]

	if not tweakdata_skill_data then
		Application:warn("[SkillTreeManager:get_skill_button_status] skill tweakdata not found!", skill_type, skill_id)

		return RaidGUIControlGridItemSkill.STATE_LOCKED
	end

	local skill_entries = self:get_character_skilltree()
	local skill_entry = skill_entries[skill_type] and skill_entries[skill_type][skill_id]

	if not skill_entry then
		Application:warn("[SkillTreeManager:get_skill_button_status] skill not found!", skill_type, skill_id)

		return RaidGUIControlGridItemSkill.STATE_LOCKED
	end

	if tweakdata_skill_data.level_required and managers.experience:current_level() < tweakdata_skill_data.level_required then
		return RaidGUIControlGridItemSkill.STATE_LOCKED
	end

	local skill_purchased = self:is_skill_purchased(skill_id)

	if skill_purchased or tweakdata_skill_data.default_unlocked then
		return skill_entry.active and RaidGUIControlGridItemSkill.STATE_APPLIED or RaidGUIControlGridItemSkill.STATE_NORMAL
	end

	if tweakdata_skill_data.dlc then
		return RaidGUIControlGridItemSkill.STATE_LOCKED
	end

	if tweakdata_skill_data.gold_requirements then
		return RaidGUIControlGridItemSkill.STATE_PURCHASABLE
	end

	Application:warn("[SkillTreeManager:get_skill_button_status] no conditions were met!", inspect(tweakdata_skill_data))

	return RaidGUIControlGridItemSkill.STATE_LOCKED
end

function SkillTreeManager:add_skill_points(points)
	Application:debug("[SkillTreeManager:add_skill_points] Giving:", points)

	if points <= 0 then
		return
	end

	local exp_reduction = tweak_data.skilltree.exp_overlevel_penalty

	for id, data in pairs(self:get_skills_applied()) do
		local tweak_skill = tweak_data.skilltree.skills[id]

		if tweak_skill and tweak_skill.exp_requirements then
			local tier_cap = #tweak_skill.exp_requirements
			data.exp_tier = data.exp_tier and math.min(data.exp_tier, tier_cap) or 1
			local xp_cap = tweak_skill.exp_requirements[data.exp_tier]
			local remaining_percent = (data.exp_progression or 0) / xp_cap
			local levelup_penalty = math.lerp(exp_reduction.min, exp_reduction.max, remaining_percent)
			data.exp_progression = data.exp_progression and math.round(data.exp_progression + points) or points or 0

			if data.exp_tier == tier_cap then
				data.exp_progression = math.min(data.exp_progression, xp_cap)
			else
				while xp_cap < data.exp_progression do
					data.exp_tier = math.min(data.exp_tier + 1, tier_cap)
					xp_cap = tweak_skill.exp_requirements[data.exp_tier]
					data.exp_progression = data.exp_progression - xp_cap
					data.exp_progression = math.round(data.exp_progression * levelup_penalty)
					levelup_penalty = exp_reduction.min

					if data.upgrades then
						local upgrades = {}

						for _, s in ipairs(data.upgrades[data.exp_tier]) do
							table.insert(upgrades, s)
						end

						Application:debug("[SkillTreeManager:add_skill_points] Upgrading applies:", id, inspect(upgrades))
						self:_apply_upgrades(upgrades, true, true)
					else
						Application:error("[SkillTreeManager:add_skill_points] data upgrades is missing!", inspect(data))
					end
				end
			end

			Application:debug("[SkillTreeManager:add_skill_points] id/currentxp", id, data.exp_progression)
		end
	end
end

function SkillTreeManager:purchase_skill(skill_id)
	if self._global.main_profile_purchased_skills[skill_id] then
		return false
	end

	local tweak_skill = tweak_data.skilltree.skills[skill_id]
	local save_skill = self:get_character_skilltree()[tweak_skill.upgrades_type][skill_id]

	if not save_skill then
		return false
	end

	if tweak_skill and tweak_skill.gold_requirements and tweak_skill.gold_requirements <= managers.gold_economy:current() then
		if tweak_skill.gold_requirements > 0 then
			managers.gold_economy:spend_gold(tweak_skill.gold_requirements, false)
		else
			Application:warn("[SkillTreeManager:purchase_skill] Bought a skill that was free somehow! " .. skill_id)
		end

		if tweak_skill.purchase_group then
			for _, unlock_id in ipairs(tweak_skill.purchase_group) do
				self._global.main_profile_purchased_skills[unlock_id] = true
			end
		else
			self._global.main_profile_purchased_skills[skill_id] = true
		end

		save_skill.exp_progression = 0
		save_skill.exp_tier = 1

		managers.savefile:save_game(SavefileManager.SETTING_SLOT)

		return true
	end

	return false
end

function SkillTreeManager:is_skill_purchased(skill_id)
	return self._global.main_profile_purchased_skills[skill_id]
end

function SkillTreeManager:calculate_stats(character_class)
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(character_class)
	local stats = {
		health = self:_calculate_health_stat(class_tweak_data),
		stamina = self:_calculate_stamina_stat(class_tweak_data),
		stamina_regen = self:_calculate_stamina_regen_stat(class_tweak_data),
		stamina_delay = class_tweak_data.movement.stamina.STAMINA_REGENERATION_DELAY,
		speed_walk = class_tweak_data.movement.speed.WALKING_SPEED * managers.player:movement_speed_multiplier(),
		speed_run = class_tweak_data.movement.speed.RUNNING_SPEED * managers.player:movement_speed_multiplier(true),
		carry_limit = self:_calculate_carry_limit_stat(character_class)
	}

	return stats
end

function SkillTreeManager:_calculate_health_stat(class_tweak_data)
	local health_stat_base_rating = class_tweak_data.damage.BASE_HEALTH + managers.player:health_skill_addition_on_top()
	local max_health_multiplier = managers.player:health_skill_multiplier()

	return health_stat_base_rating * max_health_multiplier
end

function SkillTreeManager:_calculate_speed_walk_stat(class_tweak_data)
	local base_speed_total = class_tweak_data.movement.speed.WALKING_SPEED
	local speed_base_multiplier = 1

	return base_speed_total * speed_base_multiplier, base_speed_total
end

function SkillTreeManager:_calculate_speed_run_stat(class_tweak_data)
	local base_speed_total = class_tweak_data.movement.speed.RUNNING_SPEED
	local speed_base_multiplier = 1

	return base_speed_total * speed_base_multiplier, base_speed_total
end

function SkillTreeManager:_calculate_stamina_stat(class_tweak_data)
	local base_stamina_rating = class_tweak_data.movement.stamina.BASE_STAMINA
	local stamina_multiplier = managers.player:stamina_multiplier()

	return base_stamina_rating * stamina_multiplier, base_stamina_rating
end

function SkillTreeManager:_calculate_stamina_regen_stat(class_tweak_data)
	local base_stamina_regen = class_tweak_data.movement.stamina.BASE_STAMINA_REGENERATION_RATE
	local regen_multiplier = managers.player:stamina_regen_multiplier()

	return base_stamina_regen * regen_multiplier, base_stamina_regen
end

function SkillTreeManager:_calculate_carry_limit_stat(character_class)
	local base_carry_limit = managers.player:get_my_carry_weight_limit(false, character_class)

	return base_carry_limit, base_carry_limit
end

function SkillTreeManager:set_character_profile_base_class(character_profile_base_class, skip_aquire)
	Application:debug("[SkillTreeManager:set_character_profile_base_class]", character_profile_base_class, ", skip_aquire:", skip_aquire)

	local skill_tree = tweak_data.skilltree:get_skills_organised(character_profile_base_class)

	self:reset_skills()

	self._global.character_profile_base_class = character_profile_base_class
	self._global.base_class_skill_tree = self:_required_save_data(deep_clone(skill_tree))
	self._global.base_class_automatic_unlock_progression = deep_clone(self:get_character_automatic_unlock_progression(character_profile_base_class))

	self:_update_skill_profile_set()

	local apply_acquires = not skip_aquire
	local default_warcry = "warcry_" .. tweak_data.skilltree.class_warcry_data[character_profile_base_class][1]

	self:toggle_skill_by_id(SkillTreeTweakData.TYPE_WARCRY, default_warcry, apply_acquires, true)

	if apply_acquires then
		self:apply_automatic_unlocks_for_level(1)
	end

	self:_equip_class_default_weapons()
end

function SkillTreeManager:_equip_class_default_weapons()
	managers.blackmarket:equip_class_default_primary()
	managers.blackmarket:equip_class_default_secondary()
	managers.blackmarket:equip_generic_default_grenade()
end

function SkillTreeManager:reset_skills()
	Application:debug("[SkillTreeManager:reset_skills] ver.", SkillTreeManager.VERSION, "(was", Global.skilltree_manager and Global.skilltree_manager.VERSION, ")")

	local purchased_skills = self._global.main_profile_purchased_skills or {}
	local purchased_profiles = self._global.main_profile_purchased_profiles or {}
	Global.skilltree_manager = {
		reset_message = false,
		VERSION = SkillTreeManager.VERSION,
		main_profile_purchased_skills = purchased_skills,
		main_profile_purchased_profiles = purchased_profiles
	}
	self._global = Global.skilltree_manager
end

function SkillTreeManager:toggle_skill_by_id(skill_type, skill_id, apply_acquires, activate)
	Application:debug("[SkillTreeManager:toggle_skill_by_id] ---- ", skill_type, skill_id, apply_acquires, activate)

	local skill_entries = self._global.base_class_skill_tree[skill_type]
	local skill_entry = skill_entries[skill_id]
	local profile = self:get_active_skill_profile()
	local equipped_skills = profile.equipped_skills[skill_entry.upgrades_type]

	if activate then
		if not table.contains(equipped_skills, skill_id) then
			table.insert(equipped_skills, skill_id)
		end
	else
		table.delete(equipped_skills, skill_id)
	end

	if activate then
		if skill_type == SkillTreeTweakData.TYPE_TALENT then
			local unused_talent_slots_count = self.get_unused_talent_slots_count()
			local amount_talents_applied = self:get_amount_talents_applied()

			if unused_talent_slots_count <= amount_talents_applied then
				Application:warn("[SkillTreeManager:toggle_skill_by_id] There was no free slot to activate talent:", skill_id)

				return
			end
		elseif skill_type == SkillTreeTweakData.TYPE_WARCRY or skill_type == SkillTreeTweakData.TYPE_BOOSTS then
			for skill_id, entry in pairs(skill_entries) do
				if entry.active then
					self:_activate_skill(skill_id, entry, false, false)
					table.delete(equipped_skills, skill_id)
				end
			end
		end
	end

	self:_activate_skill(skill_id, skill_entry, apply_acquires, activate)
end

function SkillTreeManager:unlock_weapons_for_level(level)
	Application:debug("[SkillTreeManager:unlock_weapons_for_level]", level)

	local weapon_progression = self:get_character_automatic_unlock_progression()

	if weapon_progression and weapon_progression[level] then
		for index, weapon in ipairs(weapon_progression[level].weapons) do
			local weapon_unlock_skill = tweak_data.skilltree.skills[weapon]

			Application:debug("[SkillTreeManager:unlock_weapons_for_level] weapon_unlock_skill", weapon, inspect(weapon_unlock_skill))

			if not managers.upgrades:aquired(weapon_unlock_skill, UpgradesManager.AQUIRE_STRINGS[2]) then
				self:_activate_skill(weapon, weapon_progression[level], true)
			end
		end
	end
end

function SkillTreeManager:create_breadcrumbs_for_level(level)
	Application:warn("[SkillTreeManager:create_breadcrumbs_for_level] This may be non-functional during skilltree rework!")

	local character_skilltree = self:get_character_skilltree()

	if not character_skilltree then
		return
	end

	for _, group in ipairs(character_skilltree) do
		if group then
			for _, skill_id in ipairs(group) do
				local skill = tweak_data.skilltree.skills[skill_id]

				if skill.level_required and skill.level_required == level then
					Application:debug("[SkillTreeManager:create_breadcrumbs_for_level] Adding breadcrumb", skill_id)
					managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_RANK_REWARD, {
						skill_id
					})
				end
			end
		end
	end
end

function SkillTreeManager:apply_automatic_unlocks_for_levels_up_to(level, category_to_apply, skip_breadcrumbs)
	for i = 1, level do
		self:apply_automatic_unlocks_for_level(i, category_to_apply, skip_breadcrumbs)
	end
end

function SkillTreeManager:apply_automatic_unlocks_for_level(level, category_to_apply, skip_breadcrumbs)
	local character_unlock_progression = self:get_character_automatic_unlock_progression()

	if not character_unlock_progression or not character_unlock_progression[level] then
		Application:warn("[SkillTreeManager:apply_automatic_unlocks_for_level] Nothing to unlock on this level of progression: Lv" .. tostring(level))

		return
	end

	for category_index, category in pairs(character_unlock_progression[level]) do
		if category_index ~= "active" and (category_to_apply and category_index == category_to_apply or not category_to_apply) then
			for index, unlock_id in ipairs(character_unlock_progression[level][category_index]) do
				local unlock_skill = nil

				if category_index == "weapons" then
					unlock_skill = self._global.base_class_skill_tree[SkillTreeTweakData.TYPE_WEAPON][unlock_id]
				elseif category_index == "unlocks" then
					unlock_skill = self._global.base_class_skill_tree[SkillTreeTweakData.TYPE_UNLOCKS][unlock_id]
				end

				if unlock_skill and not managers.upgrades:aquired(unlock_skill, UpgradesManager.AQUIRE_STRINGS[2]) then
					self:_activate_skill(unlock_id, unlock_skill, true, true)
				end
			end
		end

		if category_index == "weapons" and not skip_breadcrumbs then
			for index, unlock in ipairs(character_unlock_progression[level][category_index]) do
				local unlock_weapon = tweak_data.skilltree.skills[unlock].upgrades[1]
				local breadcrumb_category = tweak_data.weapon[unlock_weapon].use_data.selection_index == 2 and BreadcrumbManager.CATEGORY_WEAPON_PRIMARY or tweak_data.weapon[unlock_weapon].use_data.selection_index == 1 and BreadcrumbManager.CATEGORY_WEAPON_SECONDARY

				if breadcrumb_category then
					managers.breadcrumb:add_breadcrumb(breadcrumb_category, {
						unlock_weapon
					})
				end
			end
		end
	end
end

function SkillTreeManager:_activate_skill(skill_id, savedata_skill_data, apply_acquires, activate)
	savedata_skill_data.active = activate
	local tweakdata_skill_data = tweak_data.skilltree.skills[skill_id]
	local upgrades = {}
	local tiers = savedata_skill_data.exp_tier or 1

	for i = 1, tiers do
		if type(tweakdata_skill_data.upgrades[i]) == "table" then
			for _, s in ipairs(tweakdata_skill_data.upgrades[i]) do
				table.insert(upgrades, s)
			end
		else
			table.insert(upgrades, tweakdata_skill_data.upgrades[i])
		end
	end

	if tweakdata_skill_data.warcry_id then
		managers.warcry:set_active_warcry({
			name = tweakdata_skill_data.warcry_id,
			level = tiers
		})
	end

	if type(upgrades) == "table" then
		self:_apply_upgrades(upgrades, apply_acquires, activate)
	else
		Application:warn("[SkillTreeManager:_activate_skill] upgrades were bad: savedata_skill_data", upgrades, inspect(savedata_skill_data))
	end
end

function SkillTreeManager:_apply_upgrades(upgrades, apply_acquires, activate)
	for _, upgrade in ipairs(upgrades) do
		if activate then
			managers.upgrades:aquire(upgrade, nil, UpgradesManager.AQUIRE_STRINGS[2])
		else
			managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[2])
		end
	end
end

function SkillTreeManager:_activate_skill_tree(skill_tree, activate)
	local skill_tree_tweakdata = tweak_data.skilltree:get_skills_organised(self:get_character_profile_class())

	for type_idx, group in ipairs(skill_tree_tweakdata) do
		for skill_id, _ in pairs(group) do
			if skill_tree[type_idx] and skill_tree[type_idx][skill_id].active then
				self:_activate_skill(skill_id, skill_tree[type_idx][skill_id], false, activate)
			end
		end
	end
end

function SkillTreeManager:active_skill_profile(index)
	local skill_tree = self._global.base_class_skill_tree

	if self._global.character_active_skill_profile then
		local old_profile = self._global.character_skill_profiles[self._global.character_active_skill_profile]

		for type_idx, group in ipairs(old_profile.equipped_skills) do
			for _, skill_id in ipairs(group) do
				if skill_tree[type_idx] and skill_tree[type_idx][skill_id] then
					self:_activate_skill(skill_id, skill_tree[type_idx][skill_id], false, false)
				end
			end
		end
	end

	local profile = self._global.character_skill_profiles[index]

	if not profile or not profile.equipped_skills then
		return
	end

	self._global.character_active_skill_profile = index

	for type_idx, group in ipairs(profile.equipped_skills) do
		for _, skill_id in ipairs(group) do
			if skill_tree[type_idx] and skill_tree[type_idx][skill_id] then
				self:_activate_skill(skill_id, skill_tree[type_idx][skill_id], false, true)
			end
		end
	end

	self:_verify_skilltree_data()
end

function SkillTreeManager:purchase_skill_profile(index)
	if self._global.main_profile_purchased_profiles[index] then
		return false
	end

	local profile_cost = tweak_data.skilltree.skill_profiles[index]

	if profile_cost and profile_cost <= managers.gold_economy:current() then
		if profile_cost > 0 then
			managers.gold_economy:spend_gold(profile_cost, false)
		else
			Application:warn("[SkillTreeManager:purchase_skill_profile] Bought a skill profile that was free somehow! " .. index)
		end

		self._global.main_profile_purchased_profiles[index] = true

		managers.savefile:save_game(SavefileManager.SETTING_SLOT)

		return true
	end

	return false
end

function SkillTreeManager:is_skill_profile_purchased(index)
	return self._global.main_profile_purchased_profiles[index]
end

function SkillTreeManager:get_skill_profile(index)
	return self._global.character_skill_profiles[index]
end

function SkillTreeManager:get_skill_profile_name(index)
	local profile = self._global.character_skill_profiles[index]

	return profile.name or managers.localization:text("skill_profile_name", {
		NUMBER = index
	})
end

function SkillTreeManager:get_active_skill_profile()
	return self._global.character_skill_profiles[self._global.character_active_skill_profile]
end

function SkillTreeManager:get_active_skill_profile_index()
	return self._global.character_active_skill_profile or 1
end

function SkillTreeManager:get_active_skill_profile_name()
	local index = self:get_active_skill_profile_index()

	return self:get_skill_profile_name(index)
end

function SkillTreeManager:_update_skill_profile_set()
	if not self._global.character_skill_profiles then
		self._global.character_skill_profiles = {}
		self._global.character_active_skill_profile = 1
		local skill_tree = self:get_skills_applied_grouped()
		local profile = {
			equipped_skills = {}
		}

		for type_idx, group in ipairs(skill_tree) do
			if type_idx == SkillTreeTweakData.TYPE_WARCRY or type_idx == SkillTreeTweakData.TYPE_BOOSTS or type_idx == SkillTreeTweakData.TYPE_TALENT then
				local skill_group = {}
				profile.equipped_skills[type_idx] = skill_group

				for skill_id, skill in pairs(group) do
					if skill.active then
						local skill_tweak = tweak_data.skilltree.skills[skill_id]

						if skill_tweak and skill_tweak.upgrades_type == type_idx then
							table.insert(skill_group, skill_id)
						end
					end
				end
			end
		end

		table.insert(self._global.character_skill_profiles, profile)
	end

	local num_profiles = #self._global.character_skill_profiles

	if num_profiles < #tweak_data.skilltree.skill_profiles then
		local default_warcry = "warcry_" .. tweak_data.skilltree.class_warcry_data[self._global.character_profile_base_class][1]

		for i = num_profiles + 1, #tweak_data.skilltree.skill_profiles do
			local profile = {
				equipped_skills = {}
			}
			profile.equipped_skills[SkillTreeTweakData.TYPE_WARCRY] = {
				default_warcry
			}
			profile.equipped_skills[SkillTreeTweakData.TYPE_BOOSTS] = {}
			profile.equipped_skills[SkillTreeTweakData.TYPE_TALENT] = {}

			table.insert(self._global.character_skill_profiles, profile)
		end
	end
end

function SkillTreeManager:_verify_loaded_data(points_aquired_during_load)
end

function SkillTreeManager:digest_value(value, digest, default)
	if type(value) == "boolean" then
		return default or 0
	end

	if digest then
		if type(value) == "string" then
			return value
		else
			return Application:digest_value(value, true)
		end
	elseif type(value) == "number" then
		return value
	else
		return Application:digest_value(value, false)
	end

	return Application:digest_value(value, digest)
end

function SkillTreeManager:reset()
	self:reset_skills()

	if IS_PC then
		managers.statistics:publish_skills_to_steam()
	end
end

function SkillTreeManager.get_skill_warcry_level_lock(i)
	local stt = tweak_data.skilltree.skill_warcry_tiers

	return i <= #stt and stt[i]
end

function SkillTreeManager.get_skill_boost_level_lock(i)
	local stt = tweak_data.skilltree.skill_boost_tiers

	return i <= #stt and stt[i]
end

function SkillTreeManager.get_skill_talent_level_lock(i)
	local stt = tweak_data.skilltree.skill_talent_tiers

	return i <= #stt and stt[i]
end

function SkillTreeManager.get_unlocked_warcry_slots()
	local t = {}
	local level = managers.experience:current_level()
	local stt = tweak_data.skilltree.skill_warcry_tiers

	for i, v in ipairs(stt) do
		table.insert(t, v <= level)
	end

	return t
end

function SkillTreeManager.get_unlocked_boost_slots()
	local t = {}
	local level = managers.experience:current_level()
	local stt = tweak_data.skilltree.skill_boost_tiers

	for i, v in ipairs(stt) do
		table.insert(t, v <= level)
	end

	return t
end

function SkillTreeManager.get_unlocked_talent_slots()
	local t = {}
	local level = managers.experience:current_level()
	local stt = tweak_data.skilltree.skill_talent_tiers

	for i, v in ipairs(stt) do
		table.insert(t, v <= level)
	end

	return t
end

function SkillTreeManager.get_unused_talent_slots_count()
	local t = 0
	local level = managers.experience:current_level()
	local stt = tweak_data.skilltree.skill_talent_tiers

	for i, v in ipairs(stt) do
		if v <= level then
			t = t + 1
		end
	end

	return t
end
