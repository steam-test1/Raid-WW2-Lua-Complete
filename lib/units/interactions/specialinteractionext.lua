SpecialInteractionExt = SpecialInteractionExt or class(UseInteractionExt)

function SpecialInteractionExt:_interact_blocked(player)
	return false
end

function SpecialInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	SpecialInteractionExt.super.super.interact(self, player)

	local params = deep_clone(self._tweak_data)
	local pm = managers.player
	params.target_unit = self._unit

	managers.player:upgrade_minigame_params(params)

	self._player = player
	self._unit:unit_data()._interaction_done = false

	Application:debug("[SpecialInteractionExt:interact]", inspect(self._tweak_data))
	game_state_machine:change_state_by_name("ingame_special_interaction", params)

	return true
end

function SpecialInteractionExt:special_interaction_done(data)
	SpecialInteractionExt.super.interact(self, self._player)

	if data then
		if self._tweak_data.minigame_type == tweak_data.interaction.MINIGAME_CUT_FUSE and not table.empty(data) then
			local max_cuts = self._tweak_data.max_cuts or 9
			local cuts = math.min(data.successful_cuts, max_cuts)

			self:_show_fuse_sfx_and_waypoint(cuts)
			managers.network:session():send_to_peers("special_interaction_dynamite_done", self._unit, cuts)
		else
			managers.network:session():send_to_peers("special_interaction_done", self._unit)
		end
	end
end

function SpecialInteractionExt:set_special_interaction_done()
	Application:debug("[SpecialInteractionExt:set_special_interaction_done()]")

	self._unit:unit_data()._interaction_done = true
end

function SpecialInteractionExt:set_special_interaction_dynamite_done(cuts)
	self:set_special_interaction_done()
	self:_show_fuse_sfx_and_waypoint(cuts)
end

function SpecialInteractionExt:_show_fuse_sfx_and_waypoint(cuts)
	local spark_seq = "spark_" .. tostring(cuts)

	if self._unit:damage() and self._unit:damage():has_sequence(spark_seq) then
		Application:debug("[SpecialInteractionExt:special_interaction_done] Starting sequence '" .. spark_seq .. "'.")
		self._unit:damage():run_sequence_simple(spark_seq)
	else
		Application:error("[SpecialInteractionExt:special_interaction_done] Did not have sequence for '" .. spark_seq .. "'!")
	end

	self._wp_id = self._wp_id or "SpecialInteractionExtCutFuse" .. self._unit:id()
	local timer = self._tweak_data.cut_timers[cuts] or 0
	local icon = "waypoint_special_explosive"

	managers.hud:add_waypoint(self._wp_id, {
		distance = true,
		waypoint_type = "revive",
		text = "BoomBoom",
		icon = icon,
		unit = self._unit,
		timer = timer,
		lifetime = timer,
		position = self._unit:position() + Vector3(0, 0, 35)
	})
end
