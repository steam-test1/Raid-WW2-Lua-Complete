local enum = 0

local function set_enum()
	enum = enum + 1

	return enum
end

Message = {}
Message.OnHeadShot = set_enum()
Message.OnAmmoPickup = set_enum()
Message.OnSwitchWeapon = set_enum()
Message.OnEnemyKilled = set_enum()
Message.OnPlayerDamage = set_enum()
Message.SetWeaponStagger = set_enum()
Message.OnEnemyShot = set_enum()
Message.OnDoctorBagUsed = set_enum()
Message.OnPlayerReload = set_enum()
Message.RevivePlayer = set_enum()
Message.ResetStagger = set_enum()
