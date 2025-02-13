WarcrySilverBullet = WarcrySilverBullet or class(Warcry)
local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")
local ids_contour_post_processor = Idstring("contour_post_processor")
local ids_contour = Idstring("contour")
local ids_empty = Idstring("empty")
local ids_tint = Idstring("tint")
local ids_time = Idstring("time")
local ids_contour_color = Idstring("contour_color")

function WarcrySilverBullet:init()
	WarcrySilverBullet.super.init(self)

	self._type = Warcry.SILVER_BULLET
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

function WarcrySilverBullet:update(dt)
	local FADE_TIME = 0.2
	local FADE_TIME_CHEAT = 0.05
	local lerp = WarcrySilverBullet.super.update(self, dt)
	local remain = managers.warcry:remaining()
	local material = managers.warcry:warcry_post_material()

	if material then
		local t = Application:time()

		material:set_variable(ids_blend_factor, lerp)
		material:set_variable(ids_time, t)

		if FADE_TIME > remain - FADE_TIME_CHEAT then
			material:set_variable(ids_tint, tweak_data.contour.character.silver_bullet_warcry * (remain - FADE_TIME_CHEAT) / FADE_TIME)
		elseif FADE_TIME > self:duration() - remain then
			material:set_variable(ids_tint, tweak_data.contour.character.silver_bullet_warcry * (self:duration() - remain) / FADE_TIME)
		end
	end

	local enemies = self:_find_enemies_in_view()

	if enemies then
		for _, enemy in ipairs(enemies) do
			if enemy:contour() then
				if remain < FADE_TIME_CHEAT then
					enemy:contour():remove("mark_enemy_silver_bullet", false)
				else
					enemy:contour():add("mark_enemy_silver_bullet")
				end
			end
		end
	end
end

function WarcrySilverBullet:_find_enemies_in_view()
	if not alive(self._local_player) then
		return
	end

	local fov = tweak_data.player.stances.default.standard.FOV * managers.user:get_setting("fov_multiplier")
	local cone_radius = 2 * self._tint_distance * math.tan((self._tweak_data.tint_fov or 0.2) * fov)
	local player_camera = self._local_player:camera()
	local cone_tip = player_camera:position()
	local cone_base = player_camera:forward():normalized() * self._tint_distance + cone_tip
	local enemies_in_cone = World:find_units_quick("cone", cone_tip, cone_base, cone_radius, managers.slot:get_mask("enemies"))
	local enemies = {}

	for _, enemy in ipairs(enemies_in_cone) do
		if alive(enemy) and enemy:character_damage() then
			local damage_ext = enemy:character_damage()
			local distance = mvector3.distance(cone_tip, enemy:position())

			if distance < self._tint_distance and not damage_ext:is_invulnerable() and not damage_ext:is_immortal() then
				table.insert(enemies, enemy)
			end
		end
	end

	return enemies
end

function WarcrySilverBullet:activate()
	WarcrySilverBullet.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_contour_color, tweak_data.contour.character.sharpshooter_warcry)
	else
		Application:error("[WarcrySilverBullet:activate] No material from warcry post material!")
	end

	self._tint_distance = managers.player:upgrade_value("player", "warcry_silver_bullet_tint_distance", 10) * 1000
	self._fill_drain_multiplier = self._tweak_data.fill_drain_multiplier * managers.player:upgrade_value("player", "warcry_silver_bullet_drain_reduction", 1)
	self._killshot_duration_bonus = managers.player:upgrade_value("player", "warcry_killshot_duration_bonus", false)
	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_empty)
	end

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_fired_weapon", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_FIRED_WEAPON
	}, callback(self, self, "_on_fired_weapon"))
end

function WarcrySilverBullet:deactivate()
	WarcrySilverBullet.super.deactivate(self)

	if not alive(self._local_player) then
		return
	end

	self._local_player = nil
	self._tint_distance = nil
	self._fill_drain_multiplier = nil
	self._killshot_refund_drain = nil

	managers.player:get_current_state():reset_aim_assist_look_multiplier()

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_contour)
	end

	managers.enemy:unmark_dead_enemies()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_fired_weapon")
end

function WarcrySilverBullet:_on_fired_weapon(params)
	Application:debug("[WarcrySilverBullet:_on_fired_weapon]", inspect(params))
	managers.warcry:add_remaining(-(params.damage or 0) * self._fill_drain_multiplier)
end

function WarcrySilverBullet:_on_enemy_killed(params)
	if self:is_active() then
		if params.damage_type == WeaponTweakData.DAMAGE_TYPE_BULLET and self._killshot_duration_bonus then
			managers.warcry:add_remaining(self._killshot_duration_bonus)

			self._killshot_duration_bonus = self._killshot_duration_bonus * self._tweak_data.duration_bonus_diminish
		end
	else
		self:_fill_charge_on_enemy_killed(params)
	end
end

function WarcrySilverBullet:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
