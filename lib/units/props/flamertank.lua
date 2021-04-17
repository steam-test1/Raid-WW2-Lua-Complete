FlamerTank = FlamerTank or class()
FlamerTank.DETONATE_EVENT_ID = 1
FlamerTank.EXTENSION = "base"
FlamerTank.EXPLOSION_TYPE = "flamer_death_fake"

-- Lines 6-12
function FlamerTank:init(unit)
	self._unit = unit
end

-- Lines 15-44
function FlamerTank:detonate(in_pos, range, damage, player_damage)
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
			player_damage = 0,
			curve_pow = 3,
			no_raycast_check_characters = true,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			damage = damage,
			ignore_unit = self._unit
		}

		managers.explosion:detect_and_give_dmg(damage_params)

		self._already_detonated = true
	end
end
