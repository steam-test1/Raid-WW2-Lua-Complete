NpcGrenade = NpcGrenade or class(GrenadeBase)

-- Lines 5-7
function NpcGrenade:_setup_from_tweak_data()
	self._tweak_data = tweak_data.weapon[self.name_id]
end

-- Lines 13-15
function NpcGrenade:weapon_tweak_data()
	return self._tweak_data
end
