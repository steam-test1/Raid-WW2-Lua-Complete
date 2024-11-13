Warcry = Warcry or class()

require("lib/managers/warcries/WarcryBerserk")
require("lib/managers/warcries/WarcryClustertruck")
require("lib/managers/warcries/WarcryGhost")
require("lib/managers/warcries/WarcrySharpshooter")
require("lib/managers/warcries/WarcrySilverBullet")
require("lib/managers/warcries/WarcrySentry")
require("lib/managers/warcries/WarcryPainTrain")
require("lib/managers/warcries/WarcryHoldTheLine")

local ids_empty = Idstring("empty")
Warcry.BERSERK = "berserk"
Warcry.CLUSTERTRUCK = "clustertruck"
Warcry.GHOST = "ghost"
Warcry.SHARPSHOOTER = "sharpshooter"
Warcry.SILVER_BULLET = "silver_bullet"
Warcry.SENTRY = "sentry"
Warcry.PAIN_TRAIN = "pain_train"
Warcry.HOLD_THE_LINE = "hold_the_line"
Warcry.TYPES = {
	[Warcry.BERSERK] = WarcryBerserk,
	[Warcry.CLUSTERTRUCK] = WarcryClustertruck,
	[Warcry.GHOST] = WarcryGhost,
	[Warcry.SHARPSHOOTER] = WarcrySharpshooter,
	[Warcry.SILVER_BULLET] = WarcrySilverBullet,
	[Warcry.SENTRY] = WarcrySentry,
	[Warcry.PAIN_TRAIN] = WarcryPainTrain,
	[Warcry.HOLD_THE_LINE] = WarcryHoldTheLine
}

function Warcry.get_metatable(warcry_name)
	local class = Warcry.TYPES[warcry_name] or WarcryBerserk

	return class
end

Warcry.team_buffs = {}

function Warcry.create(warcry_name)
	Application:debug("[Warcry] create " .. (warcry_name or "NIL 'warcry_name'!"))

	local warcry = Warcry.get_metatable(warcry_name):new(warcry_name)

	return warcry
end

function Warcry:init()
	Application:debug("[Warcry:init]", self:get_type())

	self._level = 1
	self._active = false
end

function Warcry:update(dt)
	local remaining = managers.warcry:remaining()
	local duration = managers.warcry:duration()
	local lerp = duration - remaining
	local lerp_duration = self._tweak_data.lerp_duration

	if lerp <= lerp_duration then
		return lerp / lerp_duration
	elseif remaining <= lerp_duration then
		return (duration - lerp) / lerp_duration
	end

	return 1
end

function Warcry:get_type()
	return tostring(self._type)
end

function Warcry:set_level(level)
	self._level = level
end

function Warcry:get_level()
	return self._level
end

function Warcry:is_active()
	return self._active
end

function Warcry:distorts_lense()
	return self._tweak_data.distorts_lense or false
end

function Warcry:activate()
	Application:debug("[WARCRY] activate")
	self:_acquire_buffs()

	self._local_player = managers.player:local_player()
	self._active = true

	managers.environment_controller:set_last_life_mod(0)

	if self._tweak_data.ids_effect_name then
		managers.warcry:set_warcry_post_effect(self._tweak_data.ids_effect_name)
	end

	if alive(self._local_player) then
		if self._tweak_data.activation_spawn_unit then
			self._activation_spawned_unit = managers.game_play_central:spawn_warcry_unit({
				world_id = 0,
				rotation = nil,
				position = nil,
				name = nil,
				level = nil,
				name = self._tweak_data.activation_spawn_unit,
				position = self._local_player:position(),
				rotation = self._local_player:rotation(),
				level = self._level
			})
		end

		if self._tweak_data.activation_equip_weapon then
			managers.player:set_temporary_grenade(self._tweak_data.activation_equip_weapon)
		end

		self._local_player:character_damage():set_health_effects_blocked(true)
	end
end

function Warcry:deactivate()
	Application:debug("[WARCRY] deactivate")

	if not self:is_active() then
		return
	end

	self:_unacquire_buffs()

	self._active = false

	managers.environment_controller:set_last_life_mod(1)

	if managers.warcry then
		managers.warcry:set_warcry_post_effect(ids_empty)
	end

	if self._tweak_data.activation_spawn_unit and alive(self._activation_spawned_unit) then
		if self._activation_spawned_unit:damage() then
			self._activation_spawned_unit:damage():run_sequence_simple("deactivate")
		else
			self._activation_spawned_unit:set_slot(0)
		end

		self._activation_spawned_unit = nil
	end

	if alive(self._local_player) then
		self._local_player:character_damage():set_health_effects_blocked(false)

		if self._tweak_data.activation_equip_weapon then
			self._local_player:inventory():remove_listener("warcry_weapon_unequipped")
			managers.player:clear_temporary_grenade()
		end
	end
end

function Warcry:_get_upgrade_definition_name(upgrade_definition_name)
	if tweak_data.upgrades:upgrade_has_levels(upgrade_definition_name) then
		local upgrade_level = self._level

		while not tweak_data.upgrades.definitions[upgrade_definition_name .. "_" .. tostring(upgrade_level)] do
			upgrade_level = upgrade_level - 1
		end

		upgrade_definition_name = upgrade_definition_name .. "_" .. tostring(upgrade_level)
	end

	return upgrade_definition_name
end

function Warcry:_fill_charge_on_enemy_killed(params)
	local player = managers.player:player_unit()

	if self._active or not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():is_perseverating() then
		return
	end

	local multiplier = 1

	if params.headshot then
		multiplier = multiplier + managers.player:upgrade_value("player", "steadiness_headshot_warcry_fill_multiplier", 1) - 1
	end

	if managers.player:has_category_upgrade("player", "farsighted_long_range_warcry_fill_multiplier") then
		local activation_distance = tweak_data.upgrades.farsighted_activation_distance

		if params.enemy_distance and activation_distance < params.enemy_distance then
			multiplier = multiplier + managers.player:upgrade_value("player", "farsighted_long_range_warcry_fill_multiplier", 1) - 1
		end
	end

	if managers.player:has_category_upgrade("player", "toughness_low_health_warcry_fill_multiplier") then
		local health_ratio = player:character_damage():health_ratio()
		local activation_ratio = tweak_data.upgrades.toughness_activation_ratio

		if health_ratio < activation_ratio then
			local upgrade = managers.player:upgrade_value("player", "toughness_low_health_warcry_fill_multiplier", 1) - 1
			local low_health_multiplier = math.max(tweak_data.upgrades.toughness_multiplier_min, 1 - health_ratio / activation_ratio)
			multiplier = multiplier + low_health_multiplier * upgrade
		end
	end

	if params.dismemberment_occured then
		multiplier = multiplier + managers.player:upgrade_value("player", "brutality_dismemberment_warcry_fill_multiplier", 1) - 1
	end

	if params.damage_type == "melee" then
		multiplier = multiplier + managers.player:upgrade_value("player", "boxer_melee_warcry_fill_multiplier", 1) - 1
		multiplier = multiplier + managers.player:upgrade_value("player", "do_die_melee_warcry_fill_multiplier", 1) - 1
	elseif params.damage_type == "explosion" then
		multiplier = multiplier + managers.player:upgrade_value("player", "grenadier_explosive_warcry_fill_multiplier", 1) - 1
	end

	multiplier = multiplier * (managers.player:upgrade_value("player", "helpcry_warcry_fill_multiplier", 2) - 1)

	if multiplier > 0 then
		local kill_fill_amount = self._tweak_data.base_kill_fill_amount * multiplier

		managers.warcry:fill_meter_by_value(kill_fill_amount, true)
	end
end

function Warcry:duration()
	return self._tweak_data.base_duration or 10
end

function Warcry:base_kill_fill_amount()
	return self._tweak_data.base_kill_fill_amount
end

function Warcry:drain_rate()
	return 1
end

function Warcry:cleanup()
	self:_unacquire_buffs()
end

function Warcry:get_activation_callout()
	return self._tweak_data.activation_callout or tostring("warcry_" .. tostring(self:get_type()))
end

function Warcry:get_sound_switch()
	return self._tweak_data.sound_switch
end

function Warcry:special_unit()
	return self._tweak_data.activation_equip_weapon or self._tweak_data.activation_spawn_unit
end

function Warcry:_on_enemy_killed(params)
end

function Warcry:can_activate()
	return true
end

function Warcry:activation_threshold()
	return self._tweak_data.activation_threshold
end

function Warcry:interrupt_penalty()
	return self._tweak_data.interrupt_penalty_percentage, self._tweak_data.interrupt_penalty_multiplier
end

function Warcry:_buff_identifier(buff)
	return "warcry_" .. self:get_type() .. "_buff_" .. tostring(buff)
end

function Warcry:get_buff_upgrades()
	return managers.skilltree:get_team_buff_upgrades()
end

function Warcry:_acquire_buffs()
	self._active_buffs = self._active_buffs or {}
	local skillbuffs = self:get_buff_upgrades()
	local save_data_skilltree = managers.skilltree:get_character_skilltree()

	for skill_id, buffs in pairs(skillbuffs) do
		for _, buff in ipairs(buffs) do
			self:_acquire_buff(buff, true)
		end
	end

	local level = math.min(self._level, #self._tweak_data.buffs)

	for i = 1, level do
		local buffs = self._tweak_data.buffs[i]

		for _, buff in ipairs(buffs) do
			self:_acquire_buff(buff, false)
		end
	end
end

function Warcry:_acquire_buff(buff, team)
	Application:debug("[WARCRY]   + Acquire buff:", buff)
	managers.upgrades:aquire(buff, nil, self:_buff_identifier(buff))

	self._active_buffs[buff] = team

	if team and managers.network and managers.network:session() then
		managers.network:session():send_to_peers("sync_warcry_team_buff", buff, self:_buff_identifier(buff), true)
	end
end

function Warcry:_unacquire_buffs()
	if self._active_buffs then
		for buff, team_sync in pairs(self._active_buffs) do
			self:_unacquire_buff(buff, team_sync)
		end
	end

	self._active_buffs = nil
end

function Warcry:_unacquire_buff(buff, team)
	Application:debug("[WARCRY]   - UN-Acquire buff:", buff)
	managers.upgrades:unaquire(buff, self:_buff_identifier(buff))

	if team and managers.network and managers.network:session() then
		managers.network:session():send_to_peers("sync_warcry_team_buff", buff, self:_buff_identifier(buff), false)
	end
end
