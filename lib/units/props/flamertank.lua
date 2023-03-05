FlamerTank = FlamerTank or class()
FlamerTank.DETONATE_EVENT_ID = 1
FlamerTank.EXTENSION = "base"
FlamerTank.EXPLOSION_TYPE = "flamer_death_fake"

function FlamerTank:init(unit)
	self._unit = unit
end

function FlamerTank:detonate(in_pos, range, damage, player_damage, attacker_unit)
	Application:trace("[FlamerTank:detonate]")

	if not Network:is_server() then
		return
	end

	if not self._already_detonated then
		local rot = self._unit:rotation()
		local pos = self._unit:position() + rot:y() * -60
		local index = tweak_data.blackmarket:get_index_from_projectile_id(FlamerTank.EXPLOSION_TYPE)

		ProjectileBase.throw_projectile(index, pos, rot:z() * 0.01)

		local normal = math.UP
		local slot_mask = managers.slot:get_mask("explosion_targets")
		local damage_params = {
			curve_pow = 3,
			no_raycast_check_characters = true,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			damage = damage,
			player_damage = player_damage,
			ignore_unit = self._unit
		}

		managers.explosion:detect_and_give_dmg(damage_params)

		self._already_detonated = true

		if self._unit:parent() then
			local attack_data = {
				damage = self._unit:parent():character_damage():health() * 2
			}

			if attacker_unit then
				Application:debug("[FlamerTank:detonate] attacker_unit detonated flamer tank:", inspect(attacker_unit))

				attack_data.attacker_unit = attacker_unit
				attack_data.weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
			end

			self._unit:parent():character_damage():damage_mission(attack_data)
		end
	end
end
