DropLootManager = DropLootManager or class()
DropLootManager.DROPED_LOOT_DESPAWN_TIME = 120

-- Lines 6-9
function DropLootManager:init()
	self._enabled = true
	self._spawned_units = {}
end

-- Lines 11-40
function DropLootManager:_choose_item(current_level_table, level, multiplier)
	local chance = math.random()
	local chance_interval = {
		upper = 0,
		lower = 0
	}

	for u_key, u_data in pairs(current_level_table) do
		local drop_rate = u_data.drop_rate / 100

		if multiplier ~= nil then
			drop_rate = drop_rate * multiplier
		end

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_HEALTH) and u_key == "health" then
			drop_rate = drop_rate * managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_HEALTH)
		elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_AMMO) and u_key == "ammo" then
			drop_rate = drop_rate * managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE_AMMO)
		elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) and (u_key == "ammo" or u_key == "grenade") then
			drop_rate = 0
		end

		chance_interval.upper = chance_interval.upper + drop_rate

		if chance_interval.lower < chance and chance <= chance_interval.upper then
			if u_data.subtypes == nil then
				return u_data.unit
			else
				return self:_choose_item(u_data.subtypes, level + 1)
			end
		end

		chance_interval.lower = chance_interval.upper
	end
end

-- Lines 42-80
function DropLootManager:drop_item(tweak_table, position, rotation)
	if not self._enabled then
		return nil
	end

	if not Network:is_server() then
		managers.network:session():send_to_host("spawn_loot", tweak_table, position, rotation:yaw(), rotation:pitch(), rotation:roll())

		return
	end

	if self._difficulty_index == nil then
		self._difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	end

	local loot_tweak = tweak_table or "demo_tier"
	local drop_loot_multiplier = 1

	if tweak_data.drop_loot[loot_tweak].difficulty_multipliers ~= nil then
		drop_loot_multiplier = tweak_data.drop_loot[loot_tweak].difficulty_multipliers[self._difficulty_index]
	end

	if tweak_data.drop_loot[loot_tweak].buff_effects_applied then
		for effect, value in pairs(tweak_data.drop_loot[loot_tweak].buff_effects_applied) do
			if managers.buff_effect:is_effect_active(effect) then
				drop_loot_multiplier = drop_loot_multiplier * (managers.buff_effect:get_effect_value(effect) or 1)
			end
		end
	end

	local item = self:_choose_item(tweak_data.drop_loot[loot_tweak].units, 1, drop_loot_multiplier)

	if item then
		local spawned_unit = managers.game_play_central:spawn_pickup({
			name = item,
			position = position,
			rotation = rotation
		})

		table.insert(self._spawned_units, spawned_unit)

		return spawned_unit
	end

	return nil
end

-- Lines 82-84
function DropLootManager:clear()
	self._spawned_units = {}
end

-- Lines 86-88
function DropLootManager:set_enabled(enabled)
	self._enabled = enabled
end

-- Lines 90-92
function DropLootManager:on_simulation_ended()
	self._difficulty_index = nil
end

-- Lines 94-101
function DropLootManager:despawn_item(unit)
	for index, spawned_unit in pairs(self._spawned_units) do
		if alive(spawned_unit) and unit == spawned_unit then
			spawned_unit:set_slot(0)
			table.remove(self._spawned_units, index)
		end
	end
end
