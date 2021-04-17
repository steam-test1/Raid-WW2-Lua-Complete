WarcryGhost = WarcryGhost or class(Warcry)

-- Lines 3-13
function WarcryGhost:init()
	WarcryGhost.super.init(self)
	managers.system_event_listener:add_listener("warcry_ghost_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))

	self._active = false
	self._type = Warcry.GHOST
	self._tweak_data = tweak_data.warcry[self._type]
end

-- Lines 15-45
function WarcryGhost:_find_enemies_in_view()
	local player_unit = managers.player:player_unit()

	if not alive(player_unit) then
		return
	end

	local fov = tweak_data.player.stances.default.standard.FOV * managers.user:get_setting("fov_multiplier")
	local cone_radius = 2 * self._tweak_data.tint_distance * math.tan(0.5 * fov)
	local player_camera = player_unit:camera()
	local cone_tip = player_camera:position()
	local cone_base = player_camera:forward():normalized() * self._tweak_data.tint_distance + cone_tip
	local enemies_in_cone = World:find_units_quick("cone", cone_tip, cone_base, cone_radius, managers.slot:get_mask("enemies"))
	local enemies = {}

	for _, enemy in ipairs(enemies_in_cone) do
		if mvector3.distance(cone_tip, enemy:position()) < self._tweak_data.tint_distance then
			table.insert(enemies, enemy)
		end
	end

	return enemies
end

local ids_blend_factor = Idstring("blend_factor")
local ids_time = Idstring("time")

-- Lines 49-68
function WarcryGhost:update(dt)
	local lerp = WarcryGhost.super.update(self, dt)
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)
		material:set_variable(ids_time, managers.warcry:remaining())
	end

	local enemies = self:_find_enemies_in_view()

	if enemies then
		for _, enemy in ipairs(enemies) do
			enemy:contour():add("mark_enemy_ghost")
		end
	end
end

-- Lines 70-72
function WarcryGhost:duration()
	return self._tweak_data.base_duration * managers.player:upgrade_value("player", "warcry_duration", 1)
end

-- Lines 74-82
function WarcryGhost:get_level_description(level)
	level = math.clamp(level, 1, #self._tweak_data.buffs)

	if level >= 2 then
		local percentage = tostring(tweak_data.upgrades.values.player.warcry_dodge[level] * 100) .. "%"

		return managers.localization:text("skill_warcry_ghost_level_" .. tostring(level) .. "_desc", {
			PERCENTAGE = percentage
		})
	end

	return "warcry_ghost_team_desc"
end

local ids_desaturation = Idstring("desaturation")
local ids_contour_post_processor = Idstring("contour_post_processor")
local ids_contour = Idstring("contour")
local ids_empty = Idstring("empty")
local ids_tint = Idstring("tint")
local ids_noise_strength = Idstring("noise_strength")

-- Lines 90-103
function WarcryGhost:activate()
	WarcryGhost.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_desaturation, self._tweak_data.desaturation)
	material:set_variable(ids_tint, tweak_data.contour.character.ghost_warcry)
	material:set_variable(ids_noise_strength, self._tweak_data.grain_noise_strength)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_empty)
	end
end

-- Lines 105-113
function WarcryGhost:deactivate()
	WarcryGhost.super.deactivate(self)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_contour)
	end
end

-- Lines 115-134
function WarcryGhost:_on_enemy_killed(params)
	local unit = managers.player:player_unit()

	if self._active or not alive(unit) or not unit:character_damage() or unit:character_damage():is_downed() then
		return
	end

	local multiplier = 1

	if params.damage_type == "melee" then
		multiplier = multiplier + self._tweak_data.melee_multiplier * managers.player:upgrade_value("player", "warcry_melee_multiplier_bonus", 1)
	end

	if params.damage_type == "bullet" and params.enemy_distance and params.enemy_distance < self._tweak_data.distance_multiplier_activation_distance then
		multiplier = multiplier + self._tweak_data.distance_multiplier_addition_per_meter * (self._tweak_data.distance_multiplier_activation_distance - params.enemy_distance) / 100 * managers.player:upgrade_value("player", "warcry_short_range_multiplier_bonus", 1)
	end

	local base_fill_value = self._tweak_data.base_kill_fill_amount

	managers.warcry:fill_meter_by_value(base_fill_value * multiplier, true)
end

-- Lines 136-138
function WarcryGhost:cleanup()
	managers.system_event_listener:remove_listener("warcry_ghost_enemy_killed")
end
