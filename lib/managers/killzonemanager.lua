KillzoneManager = KillzoneManager or class()
KillzoneManager.TYPES = {
	"sniper",
	"gas",
	"fire",
	"inferno"
}

function KillzoneManager:init()
	self._units = {}
end

function KillzoneManager:update(t, dt)
	for _, data in pairs(self._units) do
		if alive(data.unit) then
			local kill_tweak = tweak_data.player.killzones[data.type]

			if data.type == "sniper" then
				data.timer = data.timer + dt

				if data.next_shot < data.timer then
					local warning_time = kill_tweak.warning_timer
					data.next_shot = data.timer + math.rand(warning_time < data.timer and kill_tweak.timer / 2 or kill_tweak.timer)
					local warning_shot = math.max(warning_time - data.timer, 1)
					warning_shot = kill_tweak.warning_chance < math.rand(warning_shot)

					if warning_shot then
						self:_warning_shot(data.unit)
					else
						self:_deal_damage(data.unit, kill_tweak.damage)
					end
				end
			elseif data.type == "gas" then
				data.timer = data.timer + dt

				if data.next_gas < data.timer then
					data.next_gas = data.timer + kill_tweak.timer

					self:_deal_gas_damage(data.unit, kill_tweak.damage)
				end
			elseif data.type == "fire" then
				data.timer = data.timer + dt

				if data.next_fire < data.timer then
					data.next_fire = data.timer + kill_tweak.timer

					self:_deal_fire_damage(data.unit, kill_tweak.damage)
				end
			elseif data.type == "inferno" then
				data.timer = data.timer + dt

				if data.next_inferno < data.timer then
					data.next_inferno = data.timer + kill_tweak.timer

					self:_deal_fire_damage(data.unit, kill_tweak.damage, kill_tweak.death_on_down)
				end
			end
		end
	end
end

function KillzoneManager:_warning_shot(unit)
	local rot = unit:camera():rotation()
	rot = Rotation(rot:yaw(), 0, 0)
	local pos = unit:position() + rot:y() * (100 + math.random(200))
	local dir = Rotation(math.rand(360), 0, 0):y()
	dir = dir:with_z(-0.4):normalized()
	local from_pos = pos + dir * -100
	local to_pos = pos + dir * 100
	local col_ray = World:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", unit)

	if col_ray and col_ray.unit then
		managers.game_play_central:play_impact_sound_and_effects({
			col_ray = nil,
			col_ray = col_ray
		})
	end
end

function KillzoneManager:_deal_damage(unit, damage)
	if unit:character_damage():need_revive() then
		return
	end

	local col_ray = {}
	local ray = Rotation(math.rand(360), 0, 0):y()
	ray = ray:with_z(-0.4):normalized()
	col_ray.ray = ray
	local attack_data = {
		col_ray = nil,
		damage = nil,
		damage = damage,
		col_ray = col_ray
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:_deal_gas_damage(unit, damage)
	local attack_data = {
		col_ray = nil,
		damage = nil,
		damage = damage,
		col_ray = {
			ray = nil,
			ray = math.UP
		}
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:_deal_fire_damage(unit, damage, death_on_down)
	local attack_data = {
		damage = nil,
		col_ray = nil,
		death_on_down = nil,
		damage = damage,
		col_ray = {
			ray = nil,
			ray = math.UP
		},
		death_on_down = death_on_down
	}

	unit:character_damage():damage_killzone(attack_data)
end

function KillzoneManager:set_unit(unit, type)
	if self._units[unit:key()] then
		self:_remove_unit(unit)
	else
		self:_add_unit(unit, type)
	end
end

function KillzoneManager:_add_unit(unit, type)
	if type == "sniper" then
		local next_shot = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = nil,
			unit = nil,
			next_shot = nil,
			type = type,
			next_shot = next_shot,
			unit = unit
		}
	elseif type == "gas" then
		local next_gas = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = nil,
			unit = nil,
			next_gas = nil,
			type = type,
			next_gas = next_gas,
			unit = unit
		}
	elseif type == "fire" then
		local next_fire = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = nil,
			next_fire = nil,
			unit = nil,
			type = type,
			next_fire = next_fire,
			unit = unit
		}
	elseif type == "inferno" then
		local next_inferno = math.rand(1)
		self._units[unit:key()] = {
			timer = 0,
			type = nil,
			unit = nil,
			next_inferno = nil,
			type = type,
			next_inferno = next_inferno,
			unit = unit
		}
	end
end

function KillzoneManager:_remove_unit(unit)
	self._units[unit:key()] = nil
end
