GoldEconomyManager = GoldEconomyManager or class()
GoldEconomyManager.THOUSAND_SEPARATOR = "."
GoldEconomyManager.VERSION = 7

function GoldEconomyManager:init()
	self:_setup()
end

function GoldEconomyManager:_setup()
	if not Global.gold_economy_manager then
		Global.gold_economy_manager = {
			total = Application:digest_value(0, true),
			current = Application:digest_value(0, true),
			respec_cost_multiplier = Application:digest_value(0, true),
			respec_reset = Application:digest_value(10, true),
			applied_upgrades = deep_clone(tweak_data.camp_customization.default_camp),
			owned_upgrades = tweak_data.camp_customization:get_applyable_upgrades(),
			gold_awards = {}
		}
	end

	self._global = Global.gold_economy_manager
	self._camp_units = {}
	self._automatic_camp_units = {}
end

function GoldEconomyManager:debug_add_gold(amount)
	self:add_gold(amount, true)
end

function GoldEconomyManager:spend_gold(amount, is_debug)
	if amount <= 0 then
		return
	end

	self:_set_current(self:current() - amount)
	managers.raid_menu:refresh_footer_gold_amount()
end

function GoldEconomyManager:add_gold(amount, is_debug)
	if amount <= 0 then
		return
	end

	self:_set_current(self:current() + amount)
	self:_set_total(self:total() + amount)
	managers.raid_menu:refresh_footer_gold_amount()
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
	self._global.current = Application:digest_value(value, true)
end

function GoldEconomyManager:respec()
	self:spend_gold(self:respec_cost())

	local old = Application:digest_value(self._global.respec_cost_multiplier, false)
	self._global.respec_cost_multiplier = Application:digest_value(old + 1, true)
end

function GoldEconomyManager:decrease_respec_reset()
	local old = Application:digest_value(self._global.respec_reset, false)
	local new = old - 1

	if new == 1 then
		local old_multiplier = Application:digest_value(self._global.respec_cost_multiplier, false)
		local new_multiplier = old_multiplier - 1

		if new_multiplier < 0 then
			new_multiplier = 0
		end

		self._global.respec_cost_multiplier = Application:digest_value(new_multiplier, true)
		new = 10
	end

	self._global.respec_reset = Application:digest_value(new, true)
end

function GoldEconomyManager:respec_reset_value()
	return Application:digest_value(self._global.respec_reset, false)
end

function GoldEconomyManager:respec_cost()
	local multiplier = Application:digest_value(self._global.respec_cost_multiplier, false)
	local char_level = managers.experience:current_level()
	local cost = math.ceil(char_level * (1 + multiplier) * TweakData.RESPEC_COST_CONSTANT)

	return cost
end

function GoldEconomyManager:respec_cost_string()
	return self:gold_string(self:respec_cost())
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

function GoldEconomyManager:save(data)
	local state = {
		version = GoldEconomyManager.VERSION,
		total = self._global.total,
		current = self._global.current,
		respec_cost_multiplier = self._global.respec_cost_multiplier,
		respec_reset = self._global.respec_reset,
		applied_upgrades = self._global.applied_upgrades,
		owned_upgrades = self._global.owned_upgrades,
		gold_awards = self._global.gold_awards
	}
	data.GoldEconomyManager = state
end

function GoldEconomyManager:load(data)
	self:reset()

	local state = data.GoldEconomyManager

	if state then
		self._global.total = state.total or 0
		self._global.current = state.current or 0

		if state.respec_cost_multiplier then
			self._global.respec_cost_multiplier = state.respec_cost_multiplier
		end

		if state.respec_reset then
			self._global.respec_reset = state.respec_reset
		end
	end

	local needs_upgrade = false

	if not state or not state.version or state.version ~= GoldEconomyManager.VERSION then
		needs_upgrade = true

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

	self:get_gold_awards()
end

function GoldEconomyManager:get_gold_awards()
	local eligible_awards = tweak_data.dlc:get_eligible_gold_awards()

	for _, award in pairs(eligible_awards) do
		if not self._global.gold_awards[award.item] then
			self._global.gold_awards[award.item] = true

			self:add_gold(award.amount)
			managers.savefile:set_resave_required()
		end
	end
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
		local upgrade_data = tweak_data.camp_customization.camp_upgrades[upgrade.upgrade].levels[upgrade.level]

		if upgrade_data and not tweak_data.camp_customization:is_upgrade_unlocked(upgrade_data) then
			table.remove(self._global.owned_upgrades, index)
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

function GoldEconomyManager:layout_camp()
	if not managers.player:local_player_in_camp() then
		return
	end

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

function GoldEconomyManager:_calculate_gold_pile_level(gold_spread)
	local index = #gold_spread + 1

	if self:current() == 0 then
		return 0
	end

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
	self:get_gold_awards()
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

function GoldEconomyManager:reset_camp_units()
	self._camp_units = {}
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
