GoldEconomyManager = GoldEconomyManager or class()
GoldEconomyManager.THOUSAND_SEPARATOR = ","
GoldEconomyManager.VERSION = 8
GoldEconomyManager.ACHIEVEMENT_CAMP_ROYALTY = 1000
GoldEconomyManager.LOYALTY_SKILL_REWORK = "SkillRework"
GoldEconomyManager.LOYALTY_REMOVED_SKILL = "RemovedSkill"

function GoldEconomyManager:init()
	self:_setup()
end

function GoldEconomyManager:_setup()
	if not Global.gold_economy_manager then
		Global.gold_economy_manager = {
			total = Application:digest_value(0, true),
			current = Application:digest_value(0, true),
			applied_upgrades = deep_clone(tweak_data.camp_customization.default_camp),
			owned_upgrades = tweak_data.camp_customization:get_applyable_upgrades(),
			gold_awards = {}
		}
	end

	self._global = Global.gold_economy_manager
	self._camp_units = {}
	self._automatic_camp_units = {}
end

function GoldEconomyManager:total()
	return Application:digest_value(self._global.total, false)
end

function GoldEconomyManager:_set_total(value)
	self._global.total = Application:digest_value(value, true)
end

function GoldEconomyManager:current()
	return Application:digest_value(self._global.current, false)
end

function GoldEconomyManager:_set_current(value)
	if GoldEconomyManager.ACHIEVEMENT_CAMP_ROYALTY <= value then
		managers.achievment:award("camp_royalty")
	end

	self._global.current = Application:digest_value(value, true)

	if IS_PC then
		managers.statistics:publish_gold_to_steam()
	end
end

function GoldEconomyManager:save(data)
	local state = {
		version = GoldEconomyManager.VERSION,
		total = self._global.total,
		current = self._global.current,
		applied_upgrades = self._global.applied_upgrades,
		owned_upgrades = self._global.owned_upgrades,
		gold_awards = self._global.gold_awards,
		loyalty_rewards = self._global.pending_loyalty_rewards
	}
	data.GoldEconomyManager = state
end

function GoldEconomyManager:load(data)
	Application:trace("[GoldEconomyManager:load] data ", inspect(data))
	self:reset()

	local state = data.GoldEconomyManager

	if state then
		self._global.total = state.total or 0
		self._global.current = state.current or 0
		self._global.pending_loyalty_rewards = state.loyalty_rewards
	end

	local needs_upgrade = false

	if not state or not state.version then
		needs_upgrade = true

		managers.savefile:set_resave_required()
	elseif state and state.version ~= GoldEconomyManager.VERSION then
		needs_upgrade = true

		self:_refund_upgrades(state.owned_upgrades)
		managers.savefile:set_resave_required()
	else
		self._global.applied_upgrades = state.applied_upgrades
		self._global.owned_upgrades = state.owned_upgrades
	end

	self:append_camp_upgrades()

	needs_upgrade = needs_upgrade or self:filter_camp_upgrades()

	if needs_upgrade then
		self:upgrade_player_camp()
	end

	self._global.gold_awards = state and state.gold_awards or {}
end

function GoldEconomyManager:_refund_upgrades(upgrades)
	for _, upgrade in pairs(upgrades) do
		self:_refund_upgrade(upgrade.upgrade, upgrade.level)
	end
end

function GoldEconomyManager:_refund_upgrade(upgrade, level)
	local amount = tweak_data.camp_customization.camp_upgrades[upgrade].levels[level].gold_price or 0

	Application:debug("[GoldEconomyManager:_refund_upgrade] REFUNDED: ", upgrade, level, amount)
	self:add_gold(amount)
end

function GoldEconomyManager:append_camp_upgrades()
	local applyable_upgrades = tweak_data.camp_customization:get_applyable_upgrades()

	for _, upgrade in pairs(applyable_upgrades) do
		if not self:is_upgrade_owned(upgrade.upgrade, upgrade.level) then
			table.insert(self._global.owned_upgrades, upgrade)
		end
	end
end

function GoldEconomyManager:filter_camp_upgrades()
	for index = #self._global.owned_upgrades, 1, -1 do
		local upgrade = self._global.owned_upgrades[index]

		if tweak_data.camp_customization.camp_upgrades[upgrade.upgrade] then
			local upgrade_data = tweak_data.camp_customization.camp_upgrades[upgrade.upgrade].levels[upgrade.level]

			if upgrade_data and not tweak_data.camp_customization:is_upgrade_unlocked(upgrade_data) then
				table.remove(self._global.owned_upgrades, index)
			end
		end
	end

	local needs_layout = false

	for index = #self._global.applied_upgrades, 1, -1 do
		local upgrade = self._global.applied_upgrades[index]

		if not self:is_upgrade_owned(upgrade.upgrade, upgrade.level) then
			local default_level = tweak_data.camp_customization:get_default_upgrade_level(upgrade.upgrade)

			if upgrade.level ~= default_level then
				upgrade.level = default_level
				needs_layout = true
			end
		end
	end

	return needs_layout
end

function GoldEconomyManager:reset_camp_units()
	self._camp_units = {}
	self._automatic_camp_units = {}
end

function GoldEconomyManager:get_store_items_data()
	local result = {}
	local is_host = Network:is_server()

	for upgrade_slot_name, upgrade_slot in pairs(tweak_data.camp_customization.camp_upgrades) do
		for upgrade_level, upgrade in ipairs(upgrade_slot.levels) do
			local is_default = tweak_data.camp_customization:is_default_upgrade(upgrade_slot_name, upgrade_level)

			if is_default or tweak_data.camp_customization:is_upgrade_unlocked(upgrade) then
				local store_upgrade_data = clone(upgrade)
				store_upgrade_data.upgrade_name = upgrade_slot_name
				store_upgrade_data.level = upgrade_level

				if is_default or self:is_upgrade_owned(upgrade_slot_name, upgrade_level) then
					store_upgrade_data.status = RaidGUIControlGridItem.STATUS_OWNED_OR_PURCHASED
				elseif upgrade.gold_price <= self:current() then
					store_upgrade_data.status = RaidGUIControlGridItem.STATUS_PURCHASABLE
				else
					store_upgrade_data.status = RaidGUIControlGridItem.STATUS_NOT_ENOUGHT_RESOURCES
				end

				if not is_host then
					store_upgrade_data.status = RaidGUIControlGridItem.STATUS_OWNED_OR_PURCHASED
				end

				table.insert(result, store_upgrade_data)
			end
		end
	end

	GoldEconomyManager.store = result

	return result
end

function GoldEconomyManager:is_upgrade_owned(upgrade_slot_name, upgrade_level)
	for _, upgrade in ipairs(self._global.owned_upgrades) do
		if upgrade.upgrade == upgrade_slot_name and upgrade.level == upgrade_level then
			return true
		end
	end

	return false
end

function GoldEconomyManager:is_upgrade_applied(upgrade_slot_name, upgrade_level)
	for _, upgrade in ipairs(self._global.applied_upgrades) do
		if upgrade.upgrade == upgrade_slot_name and upgrade.level == upgrade_level then
			return true
		end
	end

	return false
end

function GoldEconomyManager:_get_current_camp_upgrade_data(upgrade_slot_name)
	for _, upgrade_slot_name in pairs(self._global.applied_upgrades) do
		if upgrade_slot_name == camp_upgrade_data.upgrade then
			return camp_upgrade_data
		end
	end

	return nil
end

function GoldEconomyManager:update_camp_upgrade(upgrade_slot_name, upgrade_level)
	if not upgrade_slot_name or not upgrade_level then
		return
	end

	for _, camp_upgrade_data in pairs(self._global.applied_upgrades) do
		if camp_upgrade_data.upgrade == upgrade_slot_name and camp_upgrade_data.level ~= upgrade_level then
			camp_upgrade_data.level = upgrade_level
		end
	end

	if not self:is_upgrade_owned(upgrade_slot_name, upgrade_level) then
		table.insert(self._global.owned_upgrades, {
			upgrade = upgrade_slot_name,
			level = upgrade_level
		})
	end
end

function GoldEconomyManager:layout_camp()
	if not managers.player:local_player_in_camp() then
		return
	end

	self:get_gold_awards()

	for upgrade_name, unit in pairs(self._automatic_camp_units) do
		local gold_spread = tweak_data.camp_customization.camp_upgrades_automatic[upgrade_name].gold
		local gold_level = self:_calculate_gold_pile_level(gold_spread)

		unit:gold_asset():apply_upgrade_level(gold_level)
	end

	for _, data in ipairs(self._global.applied_upgrades) do
		local levels = self._camp_units[data.upgrade]
		local asset_level = nil
		asset_level = data.level

		if levels then
			for level, units in pairs(levels) do
				for _, unit in pairs(units) do
					if level == asset_level then
						unit:gold_asset():apply_upgrade_level(asset_level)
					else
						unit:gold_asset():apply_upgrade_level(0)
					end
				end
			end
		end
	end
end

function GoldEconomyManager:upgrade_player_camp()
	for _, data in ipairs(tweak_data.camp_customization.default_camp) do
		local found = false

		for __, camp in ipairs(self._global.applied_upgrades) do
			if camp.upgrade == data.upgrade then
				found = true

				break
			end
		end

		if not found then
			Application:debug("[GoldEconomyManager:upgrade_player_camp()] Adding new camp asset", data.upgrade)
			table.insert(self._global.applied_upgrades, {
				level = data.level,
				upgrade = data.upgrade
			})
		end
	end
end

function GoldEconomyManager:spend_gold(amount)
	if amount <= 0 then
		return
	end

	self:_set_current(self:current() - amount)
	managers.raid_menu:refresh_footer_gold_amount()
end

function GoldEconomyManager:add_gold(amount)
	if amount <= 0 then
		return
	end

	self:_set_current(self:current() + amount)
	self:_set_total(self:total() + amount)
	managers.raid_menu:refresh_footer_gold_amount()
end

function GoldEconomyManager:gold_string(amount)
	local total = tostring(math.round(math.abs(amount)))
	local reverse = string.reverse(total)
	local s = ""

	for i = 1, string.len(reverse) do
		s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and GoldEconomyManager.THOUSAND_SEPARATOR or "")
	end

	s = string.reverse(s)

	if amount < 0 then
		s = "-" .. s
	end

	return s
end

function GoldEconomyManager:get_gold_awards()
	local eligible_awards = tweak_data.dlc:get_eligible_gold_awards()

	for _, award in pairs(eligible_awards) do
		if not self._global.gold_awards[award.item] then
			Application:debug("[GoldEconomyManager:get_gold_awards] - Awarding gold", award.amount)

			self._global.gold_awards[award.item] = true

			self:add_gold(award.amount)
			managers.savefile:set_resave_required()
		end
	end
end

function GoldEconomyManager:_calculate_gold_pile_level(gold_spread)
	if self:current() == 0 then
		return 0
	end

	local index = #gold_spread + 1

	for i, value in ipairs(gold_spread) do
		if self:current() < value then
			index = i - 1

			break
		end
	end

	return index
end

function GoldEconomyManager:reset()
	Global.gold_economy_manager = nil

	self:_setup()
end

function GoldEconomyManager:get_difficulty_multiplier(difficulty)
	local multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty)

	return multiplier or 0
end

function GoldEconomyManager:register_camp_upgrade_unit(name, unit, level)
	self._camp_units[name] = self._camp_units[name] or {}

	if not self._camp_units[name][level] then
		self._camp_units[name][level] = {}
	end

	table.insert(self._camp_units[name][level], unit)
end

function GoldEconomyManager:register_automatic_camp_upgrade_unit(name, unit)
	self._automatic_camp_units[name] = self._automatic_camp_units[name] or {}

	if not self._automatic_camp_units[name] then
		self._automatic_camp_units[name] = {}
	end

	self._automatic_camp_units[name] = unit
end

function GoldEconomyManager:add_loyalty_reward(category, amount)
	self._global.pending_loyalty_rewards = self._global.pending_loyalty_rewards or {}
	self._global.pending_loyalty_rewards[category] = self._global.pending_loyalty_rewards[category] or 0
	self._global.pending_loyalty_rewards[category] = self._global.pending_loyalty_rewards[category] + amount
end

function GoldEconomyManager:loyalty_reward_pending(category)
	return self._global.pending_loyalty_rewards and self._global.pending_loyalty_rewards[category]
end

function GoldEconomyManager:grant_loyalty_reward(category)
	if not self:loyalty_reward_pending(category) then
		Application:trace("[GoldEconomyManager:grant_loyalty_reward] no pending reward for category:", category)

		return
	end

	local amount = self._global.pending_loyalty_rewards[category]
	self._global.pending_loyalty_rewards[category] = nil

	if table.size(self._global.pending_loyalty_rewards) == 0 then
		self._global.pending_loyalty_rewards = nil
	end

	self:add_gold(amount)
	managers.savefile:set_resave_required()
end
