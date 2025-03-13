HuskTeamAIBase = HuskTeamAIBase or class(HuskCopBase)
HuskTeamAIBase.set_visible = HuskPlayerBase.set_visible

function HuskTeamAIBase:default_weapon_name()
	return TeamAIBase.default_weapon_name(self)
end

function HuskTeamAIBase:post_init()
	self._ext_anim = self._unit:anim_data()

	self._unit:movement():post_init()
	self:set_anim_lod(1)

	self._lod_stage = 1
	self._allow_invisible = true

	TeamAIBase._register(self)
	managers.occlusion:remove_occlusion(self._unit)
end

function HuskTeamAIBase:nick_name()
	return TeamAIBase.nick_name(self)
end

function HuskTeamAIBase:on_death_exit()
	HuskTeamAIBase.super.on_death_exit(self)
	TeamAIBase.unregister(self)
	self:set_slot(self._unit, 0)
end

function HuskTeamAIBase:pre_destroy(unit)
	if self._unit:customization() then
		self._unit:customization():destroy_all_parts_on_character()
	end

	TeamAIBase.unregister(self)
	UnitBase.pre_destroy(self, unit)
end

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

function HuskTeamAIBase:chk_freeze_anims()
end

function HuskTeamAIBase:unregister()
	TeamAIBase.unregister(self)
end
