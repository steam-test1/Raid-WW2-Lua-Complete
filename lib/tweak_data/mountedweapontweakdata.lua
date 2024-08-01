MountedWeaponTweakData = MountedWeaponTweakData or class()

-- Lines 5-9
function MountedWeaponTweakData:init(tweak_data)
	self:_init_data_sherman()
	self:_init_data_tiger()
	self:_init_data_luchs()
end

-- Lines 12-38
function MountedWeaponTweakData:_init_data_sherman()
	self.sherman = {
		sound = {
			main_cannon_fire = "Play_sherman_canon",
			main_cannon_fire_hit = ""
		},
		effect = {
			main_cannon_fire = "effects/vanilla/explosions/vehicle_explosion",
			main_cannon_fire_hit = "effects/vanilla/explosions/vehicle_explosion"
		},
		turret = {
			gun_locator = "anim_gun",
			range = 20000,
			damage = 25,
			locator = "anim_turret",
			damage_radius = 750,
			traverse_time = 10,
			player_damage = 15,
			armor_piercing = true
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 10
	}
end

-- Lines 41-67
function MountedWeaponTweakData:_init_data_tiger()
	self.tiger = {
		sound = {
			main_cannon_fire = "Play_tiger_canon",
			main_cannon_fire_hit = ""
		},
		effect = {
			main_cannon_fire = "effects/vanilla/explosions/vehicle_explosion",
			main_cannon_fire_hit = "effects/vanilla/explosions/vehicle_explosion"
		},
		turret = {
			gun_locator = "anim_gun",
			range = 20000,
			damage = 75,
			locator = "anim_turret",
			damage_radius = 750,
			traverse_time = 10,
			player_damage = 15,
			armor_piercing = true
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 10
	}
end

-- Lines 70-96
function MountedWeaponTweakData:_init_data_luchs()
	self.luchs = {
		sound = {
			main_cannon_fire = "Play_luchs_canon",
			main_cannon_fire_hit = ""
		},
		effect = {
			main_cannon_fire = "effects/vanilla/explosions/vehicle_explosion",
			main_cannon_fire_hit = "effects/vanilla/explosions/vehicle_explosion"
		},
		turret = {
			gun_locator = "anim_turret_pitch",
			range = 20000,
			damage = 35,
			locator = "anim_turret_heading",
			damage_radius = 750,
			traverse_time = 10,
			player_damage = 15,
			armor_piercing = true
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 8
	}
end
