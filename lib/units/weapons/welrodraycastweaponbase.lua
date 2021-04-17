WelrodRaycastWeaponBase = WelrodRaycastWeaponBase or class(NewRaycastWeaponBase)

-- Lines 4-51
function WelrodRaycastWeaponBase:tweak_data_anim_play(anim, speed_multiplier, noJump)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[anim] then
		if anim == "reload" or anim == "reload_not_empty" then
			self:tweak_data_anim_play("fire", 1, true)
			print("sadasdasev asfasfsfsdfvsd ")
		end

		local anim_name = data.animations[anim]
		local length = self._unit:anim_length(Idstring(anim_name))
		speed_multiplier = speed_multiplier or 1
		local recoillength = self._unit:anim_length(Idstring(anim_name))

		if (anim == "fire" or anim == "fire_steelsight") and not noJump then
			speed_multiplier = 0.97

			self._unit:anim_set_time(Idstring(anim_name), 2.6)
			self._unit:anim_pause(Idstring(anim_name))
		else
			self._unit:anim_stop(Idstring(anim_name))
		end

		self._unit:anim_play_to(Idstring(anim_name), length, speed_multiplier)
	end

	for part_id, part_data in pairs(self._parts) do
		if not part_data.unit then
			break
		end

		if part_data.animations and part_data.animations[anim] then
			local anim_name = part_data.animations[anim]
			local length = part_data.unit:anim_length(Idstring(anim_name))
			speed_multiplier = speed_multiplier or 1

			part_data.unit:anim_stop(Idstring(anim_name))
			part_data.unit:anim_play_to(Idstring(anim_name), length, speed_multiplier)
		end
	end

	NewRaycastWeaponBase.super.tweak_data_anim_play(self, anim, speed_multiplier)

	return true
end
