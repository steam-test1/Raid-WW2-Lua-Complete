CivilianDamage = CivilianDamage or class(CopDamage)

function CivilianDamage:init(unit)
	CivilianDamage.super.init(self, unit)

	self._pickup = nil
end

function CivilianDamage:die(variant)
	self._unit:base():set_slot(self._unit, 17)
	self:drop_pickup()

	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)

		if not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end
	end

	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)
end

function CivilianDamage:_on_damage_received(damage_info)
	self:_call_listeners(damage_info)

	if damage_info.result.type == "death" then
		self:_unregister_from_enemy_manager(damage_info)

		if Network:is_client() then
			self._unit:interaction():set_active(false, false)
		end
	end

	local attacker_unit = damage_info and damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end
end

function CivilianDamage:print(...)
	cat_print("civ_damage", ...)
end

function CivilianDamage:_unregister_from_enemy_manager(damage_info)
	managers.enemy:on_civilian_died(self._unit, damage_info)
end

function CivilianDamage:damage_bullet(attack_data)
	attack_data.damage = 10

	return CopDamage.damage_bullet(self, attack_data)
end

function CivilianDamage:damage_explosion(attack_data)
	if attack_data.variant == "explosion" then
		attack_data.damage = 10
	end

	return CopDamage.damage_explosion(self, attack_data)
end

function CivilianDamage:damage_fire(attack_data)
	if attack_data.variant == "fire" then
		attack_data.damage = 10
	end

	return CopDamage.damage_fire(self, attack_data)
end

function CivilianDamage:damage_melee(attack_data)
	attack_data.damage = 10

	return CopDamage.damage_melee(self, attack_data)
end

function CivilianDamage:damage_tase(attack_data)
	attack_data.damage = 10

	return CopDamage.damage_tase(self, attack_data)
end
