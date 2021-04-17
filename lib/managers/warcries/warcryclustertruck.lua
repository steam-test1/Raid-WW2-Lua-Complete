WarcryClustertruck = WarcryClustertruck or class(Warcry)
WarcryClustertruck.team_buffs = {
	{
		id = "warcry_team_damage_reduction_bonus_on_activate",
		upgrade = "warcry_team_damage_reduction_bonus",
		use_levels = true,
		category = "player"
	}
}

-- Lines 7-18
function WarcryClustertruck:init()
	WarcryClustertruck.super.init(self)
	managers.system_event_listener:add_listener("warcry_clustertruck_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))

	self._active = false
	self._type = Warcry.CLUSTERTRUCK
	self._tweak_data = tweak_data.warcry[self._type]
	self._killstreak_list = {}
end

local ids_time = Idstring("time")
local ids_blend_factor = Idstring("blend_factor")
local ids_base_color_intensity = Idstring("base_color_intensity")

-- Lines 23-33
function WarcryClustertruck:update(dt)
	local lerp = WarcryClustertruck.super.update(self, dt)
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, math.min(lerp, self._tweak_data.fire_opacity))
		material:set_variable(ids_time, managers.warcry:remaining())
	end
end

-- Lines 35-37
function WarcryClustertruck:duration()
	return self._tweak_data.base_duration * managers.player:upgrade_value("player", "warcry_duration", 1)
end

-- Lines 39-46
function WarcryClustertruck:get_level_description(level)
	level = math.clamp(level, 1, #self._tweak_data.buffs)

	if level >= 2 then
		return managers.localization:text("skill_warcry_clustertruck_level_" .. tostring(level) .. "_desc")
	end

	return "warcry_clustertruck_desc"
end

-- Lines 48-60
function WarcryClustertruck:activate()
	WarcryClustertruck.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_base_color_intensity, self._tweak_data.fire_intensity)
	managers.player:refill_grenades(self._tweak_data.grenade_refill_amounts[self._level])
	managers.player:get_current_state():set_weapon_selection_wanted(PlayerInventory.SLOT_3)

	self._killstreak_list = {}
end

-- Lines 62-89
function WarcryClustertruck:_on_enemy_killed(params)
	local unit = managers.player:player_unit()

	if self._active or not alive(unit) or not unit:character_damage() or unit:character_damage():is_downed() then
		return
	end

	local multiplier = 1

	if params.damage_type == "explosion" then
		multiplier = multiplier + self._tweak_data.explosion_multiplier * managers.player:upgrade_value("player", "warcry_explosions_multiplier_bonus", 1)
	end

	table.insert(self._killstreak_list, Application:time())

	while self._tweak_data.killstreak_duration < Application:time() - self._killstreak_list[1] do
		table.remove(self._killstreak_list, 1)

		if #self._killstreak_list == 0 then
			break
		end
	end

	multiplier = multiplier + self._tweak_data.killstreak_multiplier_bonus_per_enemy * (#self._killstreak_list - 1) * managers.player:upgrade_value("player", "warcry_killstreak_multiplier_bonus", 1)
	local base_fill_value = self._tweak_data.base_kill_fill_amount

	managers.warcry:fill_meter_by_value(base_fill_value * multiplier, true)
end

-- Lines 91-94
function WarcryClustertruck:cleanup()
	WarcryClustertruck.super.cleanup(self)
	managers.system_event_listener:remove_listener("warcry_clustertruck_enemy_killed")
end
