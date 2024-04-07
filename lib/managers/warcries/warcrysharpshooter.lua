WarcrySharpshooter = WarcrySharpshooter or class(Warcry)

function WarcrySharpshooter:init()
	WarcrySharpshooter.super.init(self)
	managers.system_event_listener:add_listener("warcry_sharpshooter_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))

	self._active = false
	self._type = Warcry.SHARPSHOOTER
	self._tweak_data = tweak_data.warcry[self._type]
end

local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")

function WarcrySharpshooter:update(dt)
	local lerp = WarcrySharpshooter.super.update(self, dt)
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)

		local f = self._tweak_data.overlay_pulse_freq
		local A = self._tweak_data.overlay_pulse_ampl
		local t = managers.warcry:duration() - managers.warcry:remaining()
		local animation_factor = 0.5 * A * (math.sin(360 * t * f) - 1) + 1

		material:set_variable(ids_layer1_animate_factor, animation_factor)
	end

	local player_unit = managers.player:player_unit()

	if player_unit then
		local locked_enemy = player_unit:camera():camera_unit():base():locked_unit()

		if alive(locked_enemy) then
			locked_enemy:contour():add("mark_enemy_sharpshooter")
		end
	end
end

local ids_contour_post_processor = Idstring("contour_post_processor")
local ids_contour = Idstring("contour")
local ids_empty = Idstring("empty")
local ids_contour_color = Idstring("contour_color")

function WarcrySharpshooter:activate()
	WarcrySharpshooter.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_contour_color, tweak_data.contour.character.sharpshooter_warcry)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_empty)
	end
end

function WarcrySharpshooter:deactivate()
	WarcrySharpshooter.super.deactivate(self)

	if not managers.player:player_unit() then
		return
	end

	managers.player:get_current_state():reset_aim_assist_look_multiplier()

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_contour)
	end

	managers.enemy:disable_countours_on_dead_enemies()
end

function WarcrySharpshooter:duration()
	return self._tweak_data.base_duration * managers.player:upgrade_value("player", "warcry_duration", 1)
end

function WarcrySharpshooter:get_level_description(level)
	level = math.clamp(level, 1, #self._tweak_data.buffs)

	return managers.localization:text("skill_warcry_sharpshooter_level_" .. tostring(level) .. "_desc")
end

function WarcrySharpshooter:_on_enemy_killed(params)
	local unit = managers.player:player_unit()

	if self._active or not alive(unit) or not unit:character_damage() or unit:character_damage():is_downed() then
		return
	end

	local multiplier = 1

	if params.headshot == true then
		multiplier = multiplier + self._tweak_data.headshot_multiplier * managers.player:upgrade_value("player", "warcry_headshot_multiplier_bonus", 1)
	end

	local activation_distance = self._tweak_data.distance_multiplier_activation_distance

	if params.enemy_distance and activation_distance < params.enemy_distance then
		local wc_long_range_multi_bonus = managers.player:upgrade_value("player", "warcry_long_range_multiplier_bonus", 1)

		multiplier = multiplier + self._tweak_data.distance_multiplier_addition_per_meter * (params.enemy_distance - activation_distance) / 100 * wc_long_range_multi_bonus
	end

	local base_fill_value = self._tweak_data.base_kill_fill_amount

	managers.warcry:fill_meter_by_value(base_fill_value * multiplier, true)
end

function WarcrySharpshooter:cleanup()
	managers.system_event_listener:remove_listener("warcry_sharpshooter_enemy_killed")
end
