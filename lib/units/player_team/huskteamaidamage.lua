HuskTeamAIDamage = HuskTeamAIDamage or class(TeamAIDamage)
TeamAIDamage._RESULT_NAME_TABLE = {
	"hurt",
	"bleedout",
	"death",
	"light_hurt",
	"heavy_hurt"
}
TeamAIDamage._ATTACK_VARIANTS = CopDamage._ATTACK_VARIANTS

function HuskTeamAIDamage:update(unit, t, dt)
end

function HuskTeamAIDamage:damage_bullet(attack_data)
	if self._dead then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		self._unit:network():send_to_host("friendly_fire_hit")

		return
	end

	local damage = attack_data.damage

	if self._unit:anim_data().revive then
		damage = damage * (self._char_tweak.damage.reviving_damage_mul or 1)
	end

	local damage_abs, damage_percent = self:_clamp_health_percentage(damage, true)

	if damage_percent > 0 then
		local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		self._unit:network():send_to_host("damage_bullet", attacker, damage_percent, body_index, hit_offset_height, false)
		self:_send_damage_drama(attack_data, damage_abs)
	end
end

function HuskTeamAIDamage:damage_explosion(attack_data)
	if self._dead then
		return
	end

	local damage = attack_data.damage
	damage = damage * (self._char_tweak.damage.explosion_damage_mul or 1)

	if self._unit:anim_data().revive then
		damage = damage * (self._char_tweak.damage.reviving_damage_mul or 1)
	end

	local damage_abs, damage_percent = self:_clamp_health_percentage(damage, true)

	if damage_percent > 0 then
		local attacker = attack_data.attacker_unit
		local attack_variant = CopDamage._get_attack_variant_index(self, "explosion")

		if attacker and attacker:id() == -1 then
			attacker = self._unit
		end

		self._unit:network():send_to_host("damage_explosion_fire", attacker, damage_percent, attack_variant, self._dead and true or false, attack_data.col_ray.ray)
		self:_send_damage_drama(attack_data, damage_abs)
	end
end

function HuskTeamAIDamage:damage_fire(attack_data)
	if self._dead then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if PlayerDamage.is_friendly_fire(self, attacker_unit) then
		self._unit:network():send_to_host("friendly_fire_hit")

		return
	end

	local damage = attack_data.damage
	damage = damage * (self._char_tweak.damage.fire_damage_mul or 1)

	if self._unit:anim_data().revive then
		damage = damage * (self._char_tweak.damage.reviving_damage_mul or 1)
	end

	local damage_abs, damage_percent = self:_clamp_health_percentage(damage, true)

	if not damage_percent > 0 then
		return
	end

	local attacker = attack_data.attacker_unit
	local attack_variant = CopDamage._get_attack_variant_index(self, "fire")

	if attacker and attacker:id() == -1 then
		attacker = self._unit
	end

	self._unit:network():send_to_host("damage_explosion_fire", attacker, damage_percent, attack_variant, self._dead and true or false, attack_data.col_ray.ray)
	self:_send_damage_drama(attack_data, damage_abs)
end

function HuskTeamAIDamage:damage_melee(attack_data)
	if self._dead then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return
	end

	local damage = attack_data.damage

	if self._unit:anim_data().revive then
		damage = damage * (self._char_tweak.damage.reviving_damage_mul or 1)
	end

	local damage_abs, damage_percent = self:_clamp_health_percentage(damage, true)

	if damage_percent > 0 then
		local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
		local attacker = attack_data.attacker_unit

		if attacker:id() == -1 then
			attacker = self._unit
		end

		self._unit:network():send_to_host("damage_melee", attacker, damage_percent, 1, 0, hit_offset_height, 0, self._dead and true or false)
		self:_send_damage_drama(attack_data, damage_abs)
	end
end

function HuskTeamAIDamage:sync_damage_bullet(attacker_unit, hit_offset_height, result_index)
	if self._dead then
		return
	end

	local result_type = result_index ~= 0 and self._RESULT_NAME_TABLE[result_index] or nil
	local result = {
		variant = "bullet",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "bullet",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "bleedout" then
		self:_on_bleedout()
	end

	self:_call_listeners(attack_data)
end

function HuskTeamAIDamage:sync_damage_explosion(attacker_unit, result_index, i_attack_variant)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local result_type = result_index ~= 0 and self._RESULT_NAME_TABLE[result_index] or nil
	local result = {
		variant = variant,
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "bleedout" then
		self:_on_bleedout()
	end

	self:_call_listeners(attack_data)
end

function HuskTeamAIDamage:sync_damage_fire(attacker_unit, result_index, i_attack_variant)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local result_type = result_index ~= 0 and self._RESULT_NAME_TABLE[result_index] or nil
	local result = {
		variant = variant,
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "bleedout" then
		self:_on_bleedout()
	end

	self:_call_listeners(attack_data)
end

function HuskTeamAIDamage:sync_damage_melee(attacker_unit, hit_offset_height, result_index)
	if self._dead then
		return
	end

	local result_type = result_index ~= 0 and self._RESULT_NAME_TABLE[result_index] or nil
	local result = {
		variant = "melee",
		type = result_type
	}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 130)

	local attack_dir = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()

		mvector3.negate(attack_dir)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit,
		attack_dir = attack_dir,
		pos = hit_pos,
		result = result
	}

	if result_type == "bleedout" then
		self:_on_bleedout()
	end

	self:_call_listeners(attack_data)
end

function HuskTeamAIDamage:sync_damage_bleeding()
	local dmg_info = {
		variant = "bleeding",
		result = {
			type = "death"
		}
	}

	self:_die()
	self:_call_listeners(dmg_info)
	self:_unregister_unit()
end

function HuskTeamAIDamage:sync_damage_tase()
	self:damage_tase()
end

function HuskTeamAIDamage:_schedule_regen()
end

function HuskTeamAIDamage:sync_unit_recovered()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	self._bleed_out = nil

	self._unit:interaction():set_active(false, false)
	managers.groupai:state():on_criminal_recovered(self._unit)
	managers.hud:on_teammate_revived(self._unit:unit_data().teammate_panel_id, self._unit:unit_data().name_label_id)
end

function HuskTeamAIDamage:revive(reviving_unit)
	if self._dead then
		return
	end

	self._unit:network():send_to_host("revive_unit", reviving_unit)
end

function HuskTeamAIDamage:pause_bleed_out()
	if self._dead then
		return
	end

	self._unit:network():send_to_host("pause_bleed_out")
end

function HuskTeamAIDamage:unpause_bleed_out()
	if self._dead then
		return
	end

	if self._unit:id() == -1 then
		return
	end

	self._unit:network():send_to_host("unpause_bleed_out")
end

function HuskTeamAIDamage:_on_bleedout(from_dropin)
	self._bleed_out = true

	if not from_dropin then
		self._unit:interaction():set_tweak_data("revive")
		self._unit:interaction():set_active(true, false)
		managers.hud:on_teammate_downed(self._unit:unit_data().teammate_panel_id, self._unit:unit_data().name_label_id)

		self._health = 0

		self:_update_health_hud()
	end
end

function HuskTeamAIDamage:_on_death()
	self._dead = true
	self._bleed_out = nil

	self._unit:interaction():set_active(false, false)
	self:_unregister_unit()
end

function HuskTeamAIDamage:load(data)
	if not data.char_dmg then
		return
	end

	self._health = data.char_dmg.health
	self._health_ratio = self._health / self._HEALTH_INIT

	if data.char_dmg.bleedout then
		self._queued_teammate_panel_update = "bleedout"
	end
end

function HuskTeamAIDamage:run_queued_teammate_panel_update()
	if self._queued_teammate_panel_update and self._queued_teammate_panel_update == "bleedout" then
		self:_on_bleedout()
	end

	self._queued_teammate_panel_update = false

	self:_update_health_hud()
end
