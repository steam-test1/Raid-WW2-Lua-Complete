WarcryGhost = WarcryGhost or class(Warcry)
local ids_blend_factor = Idstring("blend_factor")
local ids_time = Idstring("time")
local ids_desaturation = Idstring("desaturation")
local ids_contour_post_processor = Idstring("contour_post_processor")
local ids_contour = Idstring("contour")
local ids_empty = Idstring("empty")
local ids_tint = Idstring("tint")
local ids_noise_strength = Idstring("noise_strength")

-- Lines 15-25
function WarcryGhost:init()
	WarcryGhost.super.init(self)

	self._type = Warcry.GHOST
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

-- Lines 27-56
function WarcryGhost:_find_enemies_in_view()
	if not alive(self._local_player) then
		return
	end

	local fov = tweak_data.player.stances.default.standard.FOV * managers.user:get_setting("fov_multiplier")
	local cone_radius = 2 * self._tweak_data.tint_distance * math.tan(0.5 * fov)
	local player_camera = self._local_player:camera()
	local cone_tip = player_camera:position()
	local cone_base = player_camera:forward():normalized() * self._tweak_data.tint_distance + cone_tip
	local enemies_in_cone = World:find_units_quick("cone", cone_tip, cone_base, cone_radius, managers.slot:get_mask("enemies"))
	local enemies = {}

	for _, enemy in ipairs(enemies_in_cone) do
		if alive(enemy) and mvector3.distance(cone_tip, enemy:position()) < self._tweak_data.tint_distance then
			table.insert(enemies, enemy)
		end
	end

	return enemies
end

-- Lines 58-94
function WarcryGhost:update(dt)
	local FADE_TIME = 0.2
	local FADE_TIME_CHEAT = 0.05
	local lerp = WarcryGhost.super.update(self, dt)
	local remain = managers.warcry:remaining()
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)
		material:set_variable(ids_time, remain)

		if FADE_TIME > remain - FADE_TIME_CHEAT then
			material:set_variable(ids_tint, tweak_data.contour.character.ghost_warcry * (remain - FADE_TIME_CHEAT) / FADE_TIME)
		elseif FADE_TIME > self:duration() - remain then
			material:set_variable(ids_tint, tweak_data.contour.character.ghost_warcry * (self:duration() - remain) / FADE_TIME)
		end
	end

	local enemies = self:_find_enemies_in_view()

	if enemies then
		for _, enemy in ipairs(enemies) do
			if enemy:contour() then
				if remain < FADE_TIME_CHEAT then
					enemy:contour():remove("mark_enemy_ghost", false)
				else
					enemy:contour():add("mark_enemy_ghost")
				end
			end
		end
	end
end

-- Lines 96-109
function WarcryGhost:activate()
	WarcryGhost.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_desaturation, self._tweak_data.desaturation)
	material:set_variable(ids_noise_strength, self._tweak_data.grain_noise_strength)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_empty)
	end
end

-- Lines 111-121
function WarcryGhost:deactivate()
	WarcryGhost.super.deactivate(self)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_contour)
	end

	self._local_player = nil
end

-- Lines 125-127
function WarcryGhost:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

-- Lines 129-131
function WarcryGhost:cleanup()
	managers.system_event_listener:remove_listener("warcry_ghost_enemy_killed")
end
