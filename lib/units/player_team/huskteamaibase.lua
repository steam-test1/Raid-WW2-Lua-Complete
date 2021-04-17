HuskTeamAIBase = HuskTeamAIBase or class(HuskCopBase)

-- Lines 3-5
function HuskTeamAIBase:default_weapon_name()
	return TeamAIBase.default_weapon_name(self)
end

-- Lines 9-18
function HuskTeamAIBase:post_init()
	self._ext_anim = self._unit:anim_data()

	self._unit:movement():post_init()
	self:set_anim_lod(1)

	self._lod_stage = 1
	self._allow_invisible = true

	TeamAIBase._register(self)
	managers.occlusion:remove_occlusion(self._unit)
end

-- Lines 22-24
function HuskTeamAIBase:nick_name()
	return TeamAIBase.nick_name(self)
end

-- Lines 28-32
function HuskTeamAIBase:on_death_exit()
	HuskTeamAIBase.super.on_death_exit(self)
	TeamAIBase.unregister(self)
	self:set_slot(self._unit, 0)
end

-- Lines 36-39
function HuskTeamAIBase:pre_destroy(unit)
	TeamAIBase.unregister(self)
	UnitBase.pre_destroy(self, unit)
end

-- Lines 43-55
function HuskTeamAIBase:load(data)
	self._tweak_table = data.base.tweak_table or self._tweak_table
	local character_name = self._tweak_table

	if character_name then
		local old_unit = managers.criminals:character_unit_by_name(character_name)

		if old_unit then
			local peer = managers.network:session():peer_by_unit(old_unit)

			if peer then
				managers.network:session():on_peer_lost(peer, peer:id())
			end
		end
	end
end

-- Lines 59-60
function HuskTeamAIBase:chk_freeze_anims()
end

-- Lines 64-66
function HuskTeamAIBase:unregister()
	TeamAIBase.unregister(self)
end
