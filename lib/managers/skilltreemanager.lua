SkillTreeManager = SkillTreeManager or class()
SkillTreeManager.VERSION = 21

function SkillTreeManager:init()
	self:_setup()
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

function SkillTreeManager:get_character_profile_class()
	if self._global.character_profile_subclass then
		return self._global.character_profile_subclass
	end

	return self._global.character_profile_base_class
end

function SkillTreeManager:get_character_profile_class_data()
	if self._global.character_profile_subclass then
		return tweak_data.skilltree.classes[self._global.character_profile_base_class].subclasses[self._global.character_profile_subclass]
	end

	return tweak_data.skilltree.classes[self._global.character_profile_base_class]
end

function SkillTreeManager:get_character_skilltree()
	local skill_tree = nil

	if self._global.character_profile_subclass then
		skill_tree = self._global.subclass_skill_tree
	else
		skill_tree = self._global.base_class_skill_tree
	end

	return skill_tree
end

function SkillTreeManager:get_character_automatic_unlock_progression(class)
	class = class or self:get_character_profile_class()
	local automatic_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[class]

	return automatic_unlock_progression
end

function SkillTreeManager:calculate_stats(character_class, applied_skills, pending_skills)
	local applied_skills_filtered = {}

	if applied_skills then
		for index, skill in pairs(applied_skills) do
			local skill_tweak_data = tweak_data.skilltree.skills[skill]

			if skill_tweak_data and skill_tweak_data.upgrades and skill_tweak_data.upgrades[1] then
				for upgrade_index, upgrade in pairs(skill_tweak_data.upgrades) do
					local upgrade_definition = tweak_data.upgrades.definitions[upgrade]

					if upgrade_definition and (not applied_skills_filtered[upgrade_definition.upgrade.upgrade] or applied_skills_filtered[upgrade_definition.upgrade.upgrade] < upgrade_definition.upgrade.value) then
						applied_skills_filtered[upgrade_definition.upgrade.upgrade] = upgrade_definition.upgrade.value
					end
				end
			end
		end
	end

	local pending_skills_filtered = {}

	if pending_skills then
		for index, skill in pairs(pending_skills) do
			local skill_tweak_data = tweak_data.skilltree.skills[skill]

			if skill_tweak_data and skill_tweak_data.upgrades and skill_tweak_data.upgrades[1] then
				for upgrade_index, upgrade in pairs(skill_tweak_data.upgrades) do
					local upgrade_definition = tweak_data.upgrades.definitions[upgrade]

					if upgrade_definition and not pending_skills_filtered[upgrade_definition.upgrade.upgrade] then
						pending_skills_filtered[upgrade_definition.upgrade.upgrade] = 1 + (applied_skills_filtered[upgrade_definition.upgrade.upgrade] or 0)
					elseif upgrade_definition and pending_skills_filtered[upgrade_definition.upgrade.upgrade] then
						pending_skills_filtered[upgrade_definition.upgrade.upgrade] = pending_skills_filtered[upgrade_definition.upgrade.upgrade] + 1
					end
				end
			end
		end
	end

	local health_base, health_pending = self:_calculate_health_stat(character_class, applied_skills_filtered, pending_skills_filtered)
	local speed_base, speed_pending = self:_calculate_speed_stat(character_class, applied_skills_filtered, pending_skills_filtered)
	local stamina_base, stamina_pending = self:_calculate_stamina_stat(character_class, applied_skills_filtered, pending_skills_filtered)
	local stats = {
		health = {
			base = health_base,
			pending = health_pending
		},
		speed = {
			base = speed_base,
			pending = speed_pending
		},
		stamina = {
			base = stamina_base,
			pending = stamina_pending
		}
	}

	return stats
end

function SkillTreeManager:_calculate_health_stat(character_class, applied_skills, pending_skills)
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(character_class)
	local health_stat_base_rating = class_tweak_data.damage.BASE_HEALTH
	local max_health_multiplier = managers.player:health_skill_multiplier() - 1
	local health_base_rating_multiplier = 1 + max_health_multiplier
	local max_health_pending_multiplier = 0

	if pending_skills.max_health_multiplier then
		max_health_pending_multiplier = tweak_data.upgrades.values.player.max_health_multiplier[pending_skills.max_health_multiplier] - 1 - max_health_multiplier
	end

	local health_pending_multiplier = max_health_pending_multiplier

	return health_stat_base_rating * health_base_rating_multiplier, health_stat_base_rating * health_pending_multiplier
end

function SkillTreeManager:_calculate_speed_stat(character_class, applied_skills, pending_skills)
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(character_class)
	local base_speed_total = 0
	local number_of_speed_values = 0

	for index, value in pairs(class_tweak_data.movement.speed) do
		base_speed_total = base_speed_total + value
		number_of_speed_values = number_of_speed_values + 1
	end

	local base_speed_average = 0

	if number_of_speed_values > 0 then
		base_speed_average = base_speed_total / number_of_speed_values
	end

	local speed_stat_base_rating = base_speed_average / 5
	local general_movement_speed_increase_multiplier = 0

	if applied_skills.all_movement_speed_increase then
		general_movement_speed_increase_multiplier = tweak_data.upgrades.values.player.all_movement_speed_increase[applied_skills.all_movement_speed_increase] - 1
	end

	local speed_base_rating_multiplier = 1 + general_movement_speed_increase_multiplier
	local general_movement_speed_pending_multiplier = 0

	if pending_skills.all_movement_speed_increase then
		general_movement_speed_pending_multiplier = tweak_data.upgrades.values.player.all_movement_speed_increase[pending_skills.all_movement_speed_increase] - 1 - general_movement_speed_increase_multiplier
	end

	local speed_pending_multiplier = general_movement_speed_pending_multiplier

	return speed_stat_base_rating * speed_base_rating_multiplier, speed_stat_base_rating * speed_pending_multiplier
end

function SkillTreeManager:_calculate_stamina_stat(character_class, applied_skills, pending_skills)
	local class_tweak_data = tweak_data.player:get_tweak_data_for_class(character_class)
	local base_stamina_rating = 0

	for index, value in pairs(class_tweak_data.movement.stamina) do
		base_stamina_rating = base_stamina_rating + value
	end

	base_stamina_rating = base_stamina_rating * 2
	local stamina_reserve_multiplier = 0

	if applied_skills.stamina_multiplier then
		stamina_reserve_multiplier = tweak_data.upgrades.values.player.stamina_multiplier[applied_skills.stamina_multiplier] - 1
	end

	local stamina_base_rating_multiplier = 1 + stamina_reserve_multiplier
	local stamina_reserve_pending_multiplier = 0

	if pending_skills.stamina_multiplier then
		stamina_reserve_pending_multiplier = tweak_data.upgrades.values.player.stamina_multiplier[pending_skills.stamina_multiplier] - 1 - stamina_reserve_multiplier
	end

	local stamina_pending_multiplier = stamina_reserve_pending_multiplier

	return base_stamina_rating * stamina_base_rating_multiplier, base_stamina_rating * stamina_pending_multiplier
end

function SkillTreeManager:respec()
	local skill_tree = managers.skilltree:get_character_skilltree()
	local temp = {}

	for record_key, skill_tree_record in ipairs(skill_tree) do
		for skill_key, skill in pairs(skill_tree_record) do
			if type(skill) == "table" and skill.active then
				local skill_data = tweak_data.skilltree.skills[skill.skill_name]

				table.insert(temp, {
					record_key = record_key,
					skill_key = skill_key
				})

				if skill_data.acquires[1] and skill_data.acquires[1].warcry_level then
					managers.warcry:increase_warcry_level(nil, -skill_data.acquires[1].warcry_level)
				end

				for _, upgrade in ipairs(skill_data.upgrades) do
					managers.upgrades:unaquire(upgrade, UpgradesManager.AQUIRE_STRINGS[2])
				end
			end
		end
	end

	self:set_character_profile_base_class(managers.skilltree._global.character_profile_base_class, true)
	self:on_respec_tree()
end

function SkillTreeManager:set_character_profile_base_class(character_profile_base_class, skip_aquire)
	local skill_tree = tweak_data.skilltree.skill_trees[character_profile_base_class]

	self:reset_skills()

	self._global.character_profile_base_class = character_profile_base_class
	self._global.base_class_skill_tree = deep_clone(tweak_data.skilltree.skill_trees[character_profile_base_class])
	self._global.base_class_automatic_unlock_progression = deep_clone(tweak_data.skilltree.automatic_unlock_progressions[character_profile_base_class])

	for level, skills in ipairs(self._global.base_class_skill_tree) do
		skills.level_required = level
	end

	self:activate_skill_by_index(1, 1, not skip_aquire)
	self:_equip_class_default_weapons()

	if not skip_aquire then
		self:apply_automatic_unlocks_for_level(1)
	end
end

function SkillTreeManager:_equip_class_default_weapons()
	managers.blackmarket:equip_class_default_primary()
	managers.blackmarket:equip_class_default_secondary()
	managers.blackmarket:equip_generic_default_grenade()
end

function SkillTreeManager:set_character_profile_subclass(character_profile_subclass)
	local base_class = tweak_data.skilltree.classes[self._global.character_profile_base_class]
	local subclass = base_class.subclasses[character_profile_subclass]
	local skill_tree = tweak_data.skilltree.skill_trees[character_profile_subclass]
	self._global.character_profile_subclass = character_profile_subclass
	self._global.subclass_skill_tree = deep_clone(tweak_data.skilltree.skill_trees[character_profile_subclass])
	self._global.subclass_automatic_unlock_progression = deep_clone(tweak_data.skilltree.automatic_unlock_progressions[character_profile_subclass])

	for level, skills in ipairs(self._global.subclass_skill_tree) do
		skills.level_required = level + SkillTreeTweakData.STARTING_SUBCLASS_LEVEL
	end

	self:activate_skill_by_index(1, 1, true)
end

function SkillTreeManager:reset_skills()
	Global.skilltree_manager = {
		VERSION = SkillTreeManager.VERSION,
		reset_message = false
	}
	self._global = Global.skilltree_manager
end

function SkillTreeManager:activate_skill_by_index(level, skill_index, apply_acquires)
	local skill_tree = self:get_character_skilltree()
	local level_skills = skill_tree[level]
	local skill_entry = level_skills[skill_index]
	local skill = tweak_data.skilltree.skills[skill_entry.skill_name]

	self:_activate_skill(skill_entry, skill, apply_acquires)
end

function SkillTreeManager:unlock_weapons_for_level(level)
	local weapon_progression = self:get_character_automatic_unlock_progression()

	if weapon_progression and weapon_progression[level] then
		for index, weapon in ipairs(weapon_progression[level].weapons) do
			local weapon_unlock_skill = tweak_data.skilltree.skills[weapon]

			if not managers.upgrades:aquired(weapon_unlock_skill, UpgradesManager.AQUIRE_STRINGS[2]) then
				self:_activate_skill(weapon_progression[level], weapon_unlock_skill, true)
			end
		end
	end
end

function SkillTreeManager:create_breadcrumbs_for_level(level)
	local character_skilltree = self:get_character_skilltree()

	if not character_skilltree[level] then
		debug_pause("[SkillTreeManager:create_breadcrumbs_for_level] Trying to create breadcrumbs for non-existent character level!")
	end

	for index, skill in pairs(character_skilltree[level]) do
		if type(skill) == "table" and skill.skill_name then
			managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_RANK_REWARD, {
				skill.skill_name
			})
		end
	end
end

function SkillTreeManager:apply_automatic_unlocks_for_levels_up_to(level, category_to_apply)
	for i = 1, level do
		self:apply_automatic_unlocks_for_level(i, category_to_apply)
	end
end

function SkillTreeManager:apply_automatic_unlocks_for_all_levels(category_to_apply)
	local level_cap = managers.experience:level_cap()

	for i = 1, level_cap do
		self:apply_automatic_unlocks_for_level(i, category_to_apply)
	end
end

function SkillTreeManager:apply_automatic_unlocks_for_level(level, category_to_apply)
	local character_unlock_progression = self:get_character_automatic_unlock_progression()
	local character_skilltree = self:get_character_skilltree()

	if character_unlock_progression and character_unlock_progression[level] then
		for category_index, category in pairs(character_unlock_progression[level]) do
			if category_index ~= "active" and (category_to_apply and category_index == category_to_apply or not category_to_apply) then
				for index, unlock in ipairs(character_unlock_progression[level][category_index]) do
					local unlock_skill = tweak_data.skilltree.skills[unlock]

					if not managers.upgrades:aquired(unlock_skill, UpgradesManager.AQUIRE_STRINGS[2]) then
						self:_activate_skill(nil, unlock_skill, true)
					end
				end
			end

			if category_index == "weapons" then
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
end

function SkillTreeManager:_activate_skill(skill_entry, skill, apply_acquires)
	if skill_entry then
		skill_entry.active = true
	end

	self:_apply_skill(skill, apply_acquires)
end

function SkillTreeManager:_apply_skill(skill, apply_acquires)
	for _, upgrade in ipairs(skill.upgrades) do
		managers.upgrades:aquire(upgrade, nil, UpgradesManager.AQUIRE_STRINGS[2])
	end

	if apply_acquires then
		for _, acquire in ipairs(skill.acquires) do
			self:_acquire(acquire)
		end
	end
end

function SkillTreeManager:_acquire(acquire)
	if acquire.subclass then
		self:set_character_profile_subclass(acquire.subclass)
	elseif acquire.warcry then
		managers.warcry:acquire_warcry(acquire.warcry)
	elseif acquire.warcry_level then
		managers.warcry:increase_warcry_level(nil, acquire.warcry_level)
	end
end

function SkillTreeManager:on_respec_tree()
	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:platform() == Idstring("WIN32") then
		managers.statistics:publish_skills_to_steam()
	end
end

function SkillTreeManager:check_reset_message()
	local show_reset_message = self._global.reset_message and true or false

	if show_reset_message then
		managers.menu:show_skilltree_reseted()

		self._global.reset_message = false

		MenuCallbackHandler:save_progress()
	end
end

function SkillTreeManager:pack_to_string()
	local packed_string = managers.skilltree:get_character_profile_class()

	return packed_string
end

function SkillTreeManager:pack_to_string_from_list(list)
	local packed_string = managers.skilltree:get_character_profile_class()

	return packed_string
end

function SkillTreeManager:unpack_from_string(packed_string)
	return packed_string
end

function SkillTreeManager:save(data)
	local state = {
		version = SkillTreeManager.VERSION,
		character_profile_base_class = self._global.character_profile_base_class,
		base_class_skill_tree = self._global.base_class_skill_tree,
		base_class_automatic_unlock_progression = self._global.base_class_automatic_unlock_progression,
		character_profile_subclass = self._global.character_profile_subclass,
		subclass_skill_tree = self._global.subclass_skill_tree,
		subclass_automatic_unlock_progression = self._global.subclass_automatic_unlock_progression
	}
	data.SkillTreeManager = state
end

function SkillTreeManager:load(data, version)
	self:reset_skills()

	local state = data.SkillTreeManager

	if not state then
		return
	end

	if state.version and state.version < SkillTreeManager.VERSION then
		Application:trace("[SkillTreeManager:load] Saved skilltree version: ", state.version, ", current version: ", SkillTreeManager.VERSION, ". Resetting the skill tree.")
		self:set_character_profile_base_class(state.character_profile_base_class or SkillTreeTweakData.CLASS_RECON)
		self:apply_automatic_unlocks_for_levels_up_to(managers.experience:current_level())
		managers.savefile:set_resave_required()

		return
	end

	self._global.character_profile_base_class = state.character_profile_base_class or SkillTreeTweakData.CLASS_RECON
	self._global.base_class_skill_tree = state.base_class_skill_tree or deep_clone(tweak_data.skilltree.skill_trees[self._global.character_profile_base_class])
	self._global.base_class_automatic_unlock_progression = state.base_class_automatic_unlock_progression or deep_clone(tweak_data.skilltree.automatic_unlock_progressions[self._global.character_profile_base_class])
	self._global.character_profile_subclass = state.character_profile_subclass
	self._global.subclass_skill_tree = state.subclass_skill_tree
	self._global.subclass_automatic_unlock_progression = state.subclass_automatic_unlock_progression

	if state.base_class_skill_tree then
		self:_activate_skill_tree(state.base_class_skill_tree)
	end

	if state.subclass_skill_tree then
		self:_activate_skill_tree(state.subclass_skill_tree)
	end

	self:apply_automatic_unlocks_for_levels_up_to(managers.experience:current_level())
	managers.blackmarket:_verfify_equipped_category(WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME)
	managers.blackmarket:_verfify_equipped_category(WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME)
end

function SkillTreeManager:_activate_skill_tree(skill_tree)
	for level, skills in ipairs(skill_tree) do
		for index, skill_entry in ipairs(skills) do
			if skill_entry.active then
				local skill = tweak_data.skilltree.skills[skill_entry.skill_name]

				self:_activate_skill(skill_entry, skill, false)
			end
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

function SkillTreeManager:debug()
end

function SkillTreeManager:reset()
	Global.skilltree_manager = nil

	self:_setup()

	if SystemInfo:platform() == Idstring("WIN32") then
		managers.statistics:publish_skills_to_steam()
	end
end
