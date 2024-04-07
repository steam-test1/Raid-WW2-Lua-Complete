WelrodRaycastWeaponBase = WelrodRaycastWeaponBase or class(NewRaycastWeaponBase)
WelrodRaycastWeaponBase.FIRE_PULL_KEYF = 2.6333333333333333
WelrodRaycastWeaponBase.RELOAD_KEYF_FASTISH = 0.306
WelrodRaycastWeaponBase.RELOAD_KEYF_FAST = 0.42
WelrodRaycastWeaponBase.RELOAD_KEYF_FASTER = 0.59
WelrodRaycastWeaponBase.RELOAD_KEYF_FASTEST = 1.595

function WelrodRaycastWeaponBase:tweak_data_anim_play(anim, speed_multiplier, noJump, keyOffset)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[anim] then
		if anim == "reload" or anim == "reload_not_empty" then
			local lerp_start = 0

			if speed_multiplier > 1 and speed_multiplier < 1.3 then
				lerp_start = WelrodRaycastWeaponBase.RELOAD_KEYF_FASTISH
			elseif speed_multiplier >= 1.3 and speed_multiplier < 1.5 then
				lerp_start = WelrodRaycastWeaponBase.RELOAD_KEYF_FAST
			elseif speed_multiplier >= 1.5 and speed_multiplier < 2 then
				lerp_start = WelrodRaycastWeaponBase.RELOAD_KEYF_FASTER
			elseif speed_multiplier >= 2 then
				lerp_start = WelrodRaycastWeaponBase.RELOAD_KEYF_FASTEST
			end

			local key_offset = math.lerp(lerp_start, WelrodRaycastWeaponBase.RELOAD_KEYF_FASTEST, speed_multiplier - 1)

			self:tweak_data_anim_play("fire", 1, true, key_offset)
		end

		local anim_name = data.animations[anim]
		local length = self._unit:anim_length(Idstring(anim_name))

		speed_multiplier = speed_multiplier or 1

		if (anim == "fire" or anim == "fire_steelsight") and not noJump or keyOffset and keyOffset ~= 0 then
			self._unit:anim_set_time(Idstring(anim_name), keyOffset or WelrodRaycastWeaponBase.FIRE_PULL_KEYF)
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
