ExplosionTweakData = ExplosionTweakData or class()

function ExplosionTweakData:init(tweak_data)
	self.explosive_barrel = {
		curve_pow = 3,
		range = 650,
		player_damage = 80,
		damage = 650,
		effect_params = {
			effect = "effects/vanilla/explosions/exp_fire_barrel_001",
			camera_shake_mul = 4
		}
	}
	self.explosive_barrel_small = {
		curve_pow = 2,
		range = 550,
		player_damage = 65,
		damage = 550
	}
	self.flamer_tank = {
		curve_pow = 3,
		range = 500,
		player_damage = 100,
		damage = 3000,
		effect_params = {
			sound_event = "explosive_barrel_destruction"
		}
	}
	self.thermite_detonate = {
		curve_pow = 0.1,
		range = 600,
		player_damage = 0,
		damage = 60,
		effect_params = {
			camera_shake_mul = 2,
			sound_event = "thermite_grenade_explode",
			effect = "effects/upd_blaze/thermite_grenade_explode"
		}
	}
end
