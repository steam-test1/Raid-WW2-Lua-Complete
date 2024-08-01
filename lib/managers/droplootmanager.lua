DropLootManager = DropLootManager or class()
DropLootManager.DROPED_LOOT_DESPAWN_TIME = 120

function DropLootManager:init()
	self._enabled = true
	self._spawned_units = {}
	self._crate_pattern_idx = 1
	self._crate_pattern = {}

	self:_setup_crate_pattern()
end

function DropLootManager:_choose_item(current_level_table, level, multiplier)
	local chance = math.random()
	local chance_interval = {
		upper = 0,
		lower = 0
	}

	for u_key, u_data in pairs(current_level_table) do
		local drop_rate = u_data.drop_rate / 100

		if multiplier and multiplier[u_key] then
			drop_rate = math.min(drop_rate * multiplier[u_key], 1)
		end

		chance_interval.upper = chance_interval.upper + drop_rate

		if chance_interval.lower < chance and chance <= chance_interval.upper then
			local item = nil

			if not u_data.subtypes then
				item = u_data.unit
			else
				item = self:_choose_item(u_data.subtypes, level + 1)
			end

			return item
		end

		chance_interval.lower = chance_interval.upper
	end
end

function DropLootManager:drop_item(tweak_table, position, rotation, world_id, weight_multiplier)
	if not self._enabled then
		return nil
	end

	if not Network:is_server() then
		managers.network:session():send_to_host("spawn_loot", tweak_table, position, rotation:yaw(), rotation:pitch(), rotation:roll())

		return nil
	end

	if self._difficulty_index == nil then
		self._difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	end

	local loot_tweak = tweak_table or "default_tier"

	if not weight_multiplier then
		local multiplier = 1

		if tweak_data.drop_loot[loot_tweak].difficulty_multipliers then
			multiplier = tweak_data.drop_loot[loot_tweak].difficulty_multipliers[self._difficulty_index]
		end

		weight_multiplier = {
			health = multiplier,
			ammo = multiplier,
			grenade = multiplier
		}
	end

	if tweak_data.drop_loot[loot_tweak].buff_effects_applied then
		for effect, value in pairs(tweak_data.drop_loot[loot_tweak].buff_effects_applied) do
			if managers.buff_effect:is_effect_active(effect) then
				local effect_multiplier = managers.buff_effect:get_effect_value(effect) or 1
				weight_multiplier.health = (weight_multiplier.health or 1) * effect_multiplier
				weight_multiplier.ammo = (weight_multiplier.ammo or 1) * effect_multiplier
				weight_multiplier.grenade = (weight_multiplier.grenade or 1) * effect_multiplier
			end
		end
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_HEALTH) then
		local effect_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_HEALTH)
		weight_multiplier.health = weight_multiplier.health * effect_multiplier
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_AMMO) then
		local effect_multiplier = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_AMMO)
		weight_multiplier.ammo = weight_multiplier.ammo * effect_multiplier
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) then
		weight_multiplier.ammo = 0
		weight_multiplier.grenade = 0
	end

	local item = self:_choose_item(tweak_data.drop_loot[loot_tweak].units, 1, weight_multiplier)

	if item then
		local spawned_unit = managers.game_play_central:spawn_pickup({
			name = item,
			position = position,
			rotation = rotation,
			world_id = world_id
		})
		self._spawned_units[spawned_unit:key()] = spawned_unit

		return spawned_unit
	end

	return nil
end

function DropLootManager:enemy_drop_item(tweak_table, killer_unit, position, rotation)
	local multipliers = {}

	if alive(killer_unit) and killer_unit:base() and killer_unit:base().thrower_unit then
		killer_unit = killer_unit:base():thrower_unit()
	end

	if alive(killer_unit) and killer_unit:character_damage() then
		local character_data = managers.criminals:character_data_by_unit(killer_unit)

		if character_data and not character_data.ai then
			local peer_id = managers.criminals:character_peer_id_by_unit(killer_unit)

			if not killer_unit:movement():downed() then
				local health_ratio = killer_unit:character_damage():health_ratio()
				multipliers.health = tweak_data.drop_loot:get_drop_rate_multiplier("health", health_ratio)
			end

			local current_grenades = managers.player:get_grenade_amount(peer_id)
			local max_grenades = managers.player:get_max_grenades_by_peer_id(peer_id)
			local grenades_ratio = current_grenades / max_grenades
			multipliers.grenade = tweak_data.drop_loot:get_drop_rate_multiplier("grenade", grenades_ratio)
		end
	end

	local spawned_pickup = self:drop_item(tweak_table, position, rotation, nil, multipliers)

	if alive(spawned_pickup) then
		spawned_pickup:damage():run_sequence_simple("show_beam")

		local despawn_time = self.DROPED_LOOT_DESPAWN_TIME
		local pickup_type = spawned_pickup:pickup() and spawned_pickup:pickup():get_pickup_type() or ""

		if pickup_type == "health" and managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_HEALTH) then
			despawn_time = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_HEALTH) or despawn_time
		elseif pickup_type == "ammo" and managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_AMMO) then
			despawn_time = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_AMMO) or despawn_time
		end

		managers.queued_tasks:queue("spawned_pickup", self.despawn_item, self, spawned_pickup, despawn_time)
	end
end

function DropLootManager:clear()
	if self._spawned_units then
		for _, spawned_unit in pairs(self._spawned_units) do
			if alive(spawned_unit) then
				spawned_unit:set_slot(0)
			end
		end
	end

	self._spawned_units = {}

	self:_setup_crate_pattern()
end

function DropLootManager:set_enabled(enabled)
	self._enabled = enabled
end

function DropLootManager:on_simulation_ended()
	self._difficulty_index = nil

	self:clear()
end

function DropLootManager:despawn_item(unit)
	local ukey = unit:key()
	local sp_unit = self._spawned_units[ukey]

	if sp_unit then
		if alive(sp_unit) then
			sp_unit:set_slot(0)
		end

		self._spawned_units[ukey] = nil
	end
end

function DropLootManager:_setup_crate_pattern()
	Application:debug("[CRATES] setup crate patt. #Tier123:", tweak_data.lootcrate_tiers[1], tweak_data.lootcrate_tiers[2], tweak_data.lootcrate_tiers[3], "#Tot.", tweak_data.lootcrate_pattern_total)

	self._crate_pattern_idx = 999999
	self._crate_pattern = {}

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ALL_CHESTS_ARE_TIER3) then
		table.fill_with_item(self._crate_pattern, 3, tweak_data.lootcrate_tiers[3])
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ALL_CHESTS_ARE_LOCKED) then
		table.fill_with_item(self._crate_pattern, 2, tweak_data.lootcrate_tiers[2])
	else
		for tier, amount in ipairs(tweak_data.lootcrate_tiers) do
			table.fill_with_item(self._crate_pattern, tier, amount)
		end
	end

	table.fill_with_item(self._crate_pattern, 0, math.floor(tweak_data.lootcrate_pattern_total - #self._crate_pattern))
end

function DropLootManager:crate_pick_tier(static)
	self._crate_pattern_idx = self._crate_pattern_idx + 1

	if self._crate_pattern_idx > #self._crate_pattern then
		self._crate_pattern_idx = 1
		self._crate_pattern = table.shuffled(self._crate_pattern)
	end

	local pick = self._crate_pattern[self._crate_pattern_idx]

	if static and pick == 0 then
		pick = self:crate_pick_tier(true)
	end

	return pick
end
