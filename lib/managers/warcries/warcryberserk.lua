WarcryBerserk = WarcryBerserk or class(Warcry)

-- Lines 3-13
function WarcryBerserk:init()
	WarcryBerserk.super.init(self)
	managers.system_event_listener:add_listener("warcry_berserk_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))

	self._active = false
	self._type = Warcry.BERSERK
	self._tweak_data = tweak_data.warcry[self._type]
end

local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")

-- Lines 17-39
function WarcryBerserk:update(dt)
	local lerp = WarcryBerserk.super.update(self, dt)
	local distortion_a = managers.environment_controller:get_default_lens_distortion_value()
	local distortion_b = self._tweak_data.lens_distortion_value
	local distortion = math.lerp(distortion_a, distortion_b, lerp)

	managers.environment_controller:set_lens_distortion_power(distortion)

	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)

		local f = self._tweak_data.overlay_pulse_freq
		local A = self._tweak_data.overlay_pulse_ampl
		local t = managers.warcry:duration() - managers.warcry:remaining()
		local animation_factor = 0.5 * A * (math.sin(360 * t * f) - 1) + 1

		material:set_variable(ids_layer1_animate_factor, animation_factor)
	end
end

-- Lines 41-51
function WarcryBerserk:activate()
	WarcryBerserk.super.activate(self)

	self._ammo_consumption_counter = managers.player:upgrade_value("player", "warcry_ammo_consumption", 1)
	local health_restoration_percentage = self._tweak_data.base_team_heal_percentage
	health_restoration_percentage = health_restoration_percentage * managers.player:upgrade_value("player", "warcry_team_heal_bonus", 1)

	managers.player:player_unit():character_damage():restore_health(health_restoration_percentage / 100)
	managers.network:session():send_to_peers_synched("restore_health_by_percentage", health_restoration_percentage)
end

-- Lines 53-57
function WarcryBerserk:deactivate()
	WarcryBerserk.super.deactivate(self)
	managers.environment_controller:reset_lens_distortion_value()

	self._ammo_consumption_counter = nil
end

-- Lines 59-61
function WarcryBerserk:duration()
	return self._tweak_data.base_duration * managers.player:upgrade_value("player", "warcry_duration", 1)
end

-- Lines 63-70
function WarcryBerserk:get_level_description(level)
	level = math.clamp(level, 1, #self._tweak_data.buffs)

	if level >= 2 then
		return managers.localization:text("skill_warcry_berserk_level_" .. tostring(level) .. "_desc")
	end

	return "warcry_berserk_desc"
end

-- Lines 72-81
function WarcryBerserk:check_ammo_consumption()
	self._ammo_consumption_counter = self._ammo_consumption_counter - 1

	if self._ammo_consumption_counter == 0 then
		self._ammo_consumption_counter = managers.player:upgrade_value("player", "warcry_ammo_consumption", 1)

		return true
	end

	return false
end

-- Lines 83-108
function WarcryBerserk:_on_enemy_killed(params)
	local unit = managers.player:player_unit()

	if self._active or not alive(unit) or not unit:character_damage() or unit:character_damage():is_downed() then
		return
	end

	local health_ratio = managers.player:player_unit():character_damage():health_ratio()
	local multiplier = 1

	if health_ratio < self._tweak_data.low_health_multiplier_activation_percentage then
		local low_health_multiplier = math.lerp(self._tweak_data.low_health_multiplier_min, self._tweak_data.low_health_multiplier_max, 1 - health_ratio / self._tweak_data.low_health_multiplier_activation_percentage)
		multiplier = multiplier + low_health_multiplier * managers.player:upgrade_value("player", "warcry_low_health_multiplier_bonus", 1)
	end

	if params.dismemberment_occured then
		multiplier = multiplier + self._tweak_data.dismemberment_multiplier * managers.player:upgrade_value("player", "warcry_dismemberment_multiplier_bonus", 1)
	end

	local base_fill_value = self._tweak_data.base_kill_fill_amount

	managers.warcry:fill_meter_by_value(base_fill_value * multiplier, true)
end

-- Lines 110-112
function WarcryBerserk:cleanup()
	managers.system_event_listener:remove_listener("warcry_berserk_enemy_killed")
end
