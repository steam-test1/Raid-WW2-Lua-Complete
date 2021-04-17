SpecialInteractionExt = SpecialInteractionExt or class(UseInteractionExt)

-- Lines 3-5
function SpecialInteractionExt:_interact_blocked(player)
	return false
end

-- Lines 7-28
function SpecialInteractionExt:interact(player)
	if not self:can_interact(player) then
		return
	end

	SpecialInteractionExt.super.super.interact(self, player)

	local params = deep_clone(self._tweak_data)
	local pm = managers.player
	params.target_unit = self._unit
	params.number_of_circles = math.max(params.number_of_circles - pm:upgrade_value("interaction", "wheel_amount_decrease", 0), 1)
	local count = params.number_of_circles

	for i = 1, count do
		params.circle_difficulty[i] = params.circle_difficulty[i] * pm:upgrade_value("interaction", "wheel_hotspot_increase", 1)
		params.circle_rotation_speed[i] = params.circle_rotation_speed[i] * pm:upgrade_value("interaction", "wheel_rotation_speed_increase", 1)
	end

	self._player = player
	self._unit:unit_data()._interaction_done = false

	Application:debug("[SpecialInteractionExt:interact]", inspect(self._tweak_data))
	game_state_machine:change_state_by_name("ingame_special_interaction", params)

	return true
end

-- Lines 30-33
function SpecialInteractionExt:special_interaction_done()
	SpecialInteractionExt.super.interact(self, self._player)
	managers.network:session():send_to_peers("special_interaction_done", self._unit)
end

-- Lines 36-40
function SpecialInteractionExt:set_special_interaction_done()
	Application:debug("[SpecialInteractionExt:set_special_interaction_done()]")

	self._unit:unit_data()._interaction_done = true
end
