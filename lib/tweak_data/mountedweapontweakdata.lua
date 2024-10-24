MountedWeaponTweakData = MountedWeaponTweakData or class()

function MountedWeaponTweakData:init(tweak_data)
	self:_init_data_sherman()
	self:_init_data_tiger()
	self:_init_data_luchs()
end

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
			player_damage = 15,
			gun_locator = "anim_gun",
			armor_piercing = true,
			locator = "anim_turret",
			traverse_time = 10,
			range = 20000,
			damage_radius = 750,
			damage = 25
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 10
	}
end

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
			player_damage = 15,
			gun_locator = "anim_gun",
			armor_piercing = true,
			locator = "anim_turret",
			traverse_time = 10,
			range = 20000,
			damage_radius = 750,
			damage = 75
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 10
	}
end

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
			player_damage = 15,
			gun_locator = "anim_turret_pitch",
			armor_piercing = true,
			locator = "anim_turret_heading",
			traverse_time = 10,
			range = 20000,
			damage_radius = 750,
			damage = 35
		},
		main_cannon_shell_speed = 60000,
		main_cannon_reload_speed = 8
	}
end
