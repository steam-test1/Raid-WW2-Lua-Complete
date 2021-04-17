local enum = 0

-- Lines 5-8
local function set_enum()
	enum = enum + 1

	return enum
end

Message = {
	OnHeadShot = set_enum(),
	OnAmmoPickup = set_enum(),
	OnSwitchWeapon = set_enum(),
	OnEnemyKilled = set_enum(),
	OnPlayerDamage = set_enum(),
	SetWeaponStagger = set_enum(),
	OnEnemyShot = set_enum(),
	OnDoctorBagUsed = set_enum(),
	OnPlayerReload = set_enum(),
	RevivePlayer = set_enum(),
	ResetStagger = set_enum()
}
