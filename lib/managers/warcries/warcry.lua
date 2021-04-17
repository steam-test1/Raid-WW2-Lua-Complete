Warcry = Warcry or class()
Warcry.BERSERK = "berserk"
Warcry.CLUSTERTRUCK = "clustertruck"
Warcry.GHOST = "ghost"
Warcry.SHARPSHOOTER = "sharpshooter"
Warcry.team_buffs = {}

-- Lines 10-20
function Warcry.create(warcry_name)
	if warcry_name == "berserk" then
		return WarcryBerserk:new()
	elseif warcry_name == "clustertruck" then
		return WarcryClustertruck:new()
	elseif warcry_name == "ghost" then
		return WarcryGhost:new()
	elseif warcry_name == "sharpshooter" then
		return WarcrySharpshooter:new()
	end
end

-- Lines 22-32
function Warcry.get_metatable(warcry_name)
	if warcry_name == "berserk" then
		return WarcryBerserk
	elseif warcry_name == "clustertruck" then
		return WarcryClustertruck
	elseif warcry_name == "ghost" then
		return WarcryGhost
	elseif warcry_name == "sharpshooter" then
		return WarcrySharpshooter
	end
end

-- Lines 34-36
function Warcry:init()
	self._level = 1
end

-- Lines 39-53
function Warcry:update(dt)
	local remaining = managers.warcry:remaining()
	local duration = managers.warcry:duration()
	local lerp = duration - remaining
	local lerp_duration = self._tweak_data.lerp_duration

	if lerp <= lerp_duration then
		return lerp / lerp_duration
	elseif remaining <= lerp_duration then
		return (duration - lerp) / lerp_duration
	end

	return 1
end

-- Lines 55-57
function Warcry:get_type()
	return self._type
end

-- Lines 59-61
function Warcry:set_level(level)
	self._level = level
end

-- Lines 63-65
function Warcry:get_level()
	return self._level
end

-- Lines 67-68
function Warcry:get_level_description(level)
end

-- Lines 70-89
function Warcry:activate()
	local current_buffs = nil

	if self._level > #self._tweak_data.buffs then
		current_buffs = self._tweak_data.buffs[#self._tweak_data.buffs]
	else
		current_buffs = self._tweak_data.buffs[self._level]
	end

	for index, buff in pairs(current_buffs) do
		self:_acquire_buff(buff)
	end

	self:_acquire_team_buffs()

	self._active = true

	managers.environment_controller:set_last_life_mod(0)
	managers.warcry:set_warcry_post_effect(self._tweak_data.ids_effect_name)
end

-- Lines 91-93
function Warcry:_buff_identifier(buff)
	return "warcry_" .. tostring(self._type) .. "_buff_" .. tostring(buff)
end

-- Lines 95-97
function Warcry:_acquire_buff(buff)
	managers.upgrades:aquire(buff, nil, self:_buff_identifier(buff))
end

local ids_empty = Idstring("empty")

-- Lines 100-126
function Warcry:deactivate()
	if not self._active then
		return
	end

	local current_buffs = nil

	if self._level > #self._tweak_data.buffs then
		current_buffs = self._tweak_data.buffs[#self._tweak_data.buffs]
	else
		current_buffs = self._tweak_data.buffs[self._level]
	end

	for index, buff in pairs(current_buffs) do
		self:_unacquire_buff(buff)
	end

	self:_unacquire_team_buffs()

	self._active = false

	managers.environment_controller:set_last_life_mod(1)

	if managers.warcry then
		managers.warcry:set_warcry_post_effect(ids_empty)
	end
end

-- Lines 128-130
function Warcry:_unacquire_buff(buff)
	managers.upgrades:unaquire(buff, self:_buff_identifier(buff))
end

-- Lines 132-143
function Warcry:_get_upgrade_definition_name(upgrade_definition_name)
	if tweak_data.upgrades:upgrade_has_levels(upgrade_definition_name) then
		local upgrade_level = self._level

		while not tweak_data.upgrades.definitions[upgrade_definition_name .. "_" .. tostring(upgrade_level)] do
			upgrade_level = upgrade_level - 1
		end

		upgrade_definition_name = upgrade_definition_name .. "_" .. tostring(upgrade_level)
	end

	return upgrade_definition_name
end

-- Lines 145-146
function Warcry:duration()
end

-- Lines 148-150
function Warcry:cleanup()
	self:_unacquire_team_buffs()
end

-- Lines 154-171
function Warcry:_acquire_team_buffs()
	if self.team_buffs then
		for _, buff in ipairs(self.team_buffs) do
			if managers.player:has_team_category_upgrade(buff.category, buff.id) then
				if buff.use_levels then
					local level = managers.player:team_upgrade_value(buff.category, buff.id, 0)

					if level > 0 then
						self:_acquire_team_buff(buff.upgrade .. "_" .. tostring(level))
					end
				else
					self:_acquire_team_buff(buff.upgrade)
				end
			end
		end
	end
end

-- Lines 173-178
function Warcry:_acquire_team_buff(id)
	self:_acquire_buff(id)

	if managers.network and managers.network:session() then
		managers.network:session():send_to_peers("sync_warcry_team_buff", id, self:_buff_identifier(id), true)
	end
end

-- Lines 180-199
function Warcry:_unacquire_team_buffs()
	if self.team_buffs then
		for _, buff in ipairs(self.team_buffs) do
			if buff.use_levels then
				local buff_values = tweak_data.upgrades.values.team[buff.category] and tweak_data.upgrades.values.team[buff.category][buff.id]

				if buff_values then
					for level = 1, #buff_values do
						self:_unacquire_team_buff(buff.upgrade .. "_" .. tostring(level))
					end
				end
			else
				self:_unacquire_team_buff(buff.upgrade)
			end
		end
	end
end

-- Lines 201-206
function Warcry:_unacquire_team_buff(id)
	self:_unacquire_buff(id)

	if managers.network and managers.network:session() then
		managers.network:session():send_to_peers("sync_warcry_team_buff", id, self:_buff_identifier(id), false)
	end
end
