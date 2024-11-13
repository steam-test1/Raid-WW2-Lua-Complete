FlamerTank = FlamerTank or class()
FlamerTank.DETONATE_EVENT_ID = 1
FlamerTank.EXTENSION = "base"
FlamerTank.EXPLOSION_TYPE = "flamer_death_fake"

function FlamerTank:init(unit)
	self._unit = unit
	self._kill_parent = self.kill_parent
end

function FlamerTank:detonate(in_pos, range, damage, player_damage, attacker_unit)
	if self._already_detonated then
		Application:warn("[FlamerTank:detonate] Attempting to explode after already detonated!", self._unit)
	else
		self._already_detonated = true

		Application:trace("[FlamerTank:detonate] kill_parent:", self._kill_parent, attacker_unit)

		local rot = self._unit:rotation()
		local pos = self._unit:position() + rot:y() * -25

		if Network:is_server() then
			if self._kill_parent and self._unit:parent() and self._unit:parent():character_damage() then
				local attack_data = {
					damage = nil,
					damage = self._unit:parent():character_damage():health() * 10
				}

				if attacker_unit then
					Application:debug("[FlamerTank:detonate] attacker_unit detonated flamer tank:", inspect(attacker_unit))

					attack_data.attacker_unit = attacker_unit
					attack_data.weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
				end

				self._unit:parent():character_damage():damage_mission(attack_data)
			end

			local index = tweak_data.blackmarket:get_index_from_projectile_id(FlamerTank.EXPLOSION_TYPE)

			ProjectileBase.throw_projectile(index, pos, rot:z() * 0.01)
		end

		managers.explosion:detect_and_give_dmg({
			collision_slotmask = nil,
			hit_pos = nil,
			player_damage = nil,
			damage = nil,
			range = nil,
			ignite_character = true,
			no_raycast_check_characters = true,
			ignore_unit = nil,
			curve_pow = 3,
			hit_pos = pos,
			range = range,
			collision_slotmask = managers.slot:get_mask("explosion_targets"),
			damage = damage,
			player_damage = player_damage,
			ignore_unit = self._unit
		})
	end
end
