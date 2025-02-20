ExplosionTweakData = ExplosionTweakData or class()

function ExplosionTweakData:init(tweak_data)
	self.explosive_barrel = {
		range = 650,
		player_damage = 80,
		damage = 650,
		curve_pow = 3,
		effect_params = {
			camera_shake_mul = 4,
			effect = "effects/vanilla/explosions/exp_fire_barrel_001"
		}
	}
	self.explosive_barrel_small = {
		range = 550,
		player_damage = 65,
		damage = 550,
		curve_pow = 2
	}
	self.flamer_tank = {
		range = 450,
		player_damage = 75,
		damage = 3000,
		curve_pow = 3,
		effect_params = {
			sound_event = "explosive_barrel_destruction"
		}
	}
	self.thermite_detonate = {
		range = 600,
		player_damage = 0,
		damage = 60,
		curve_pow = 0.1,
		effect_params = {
			sound_event = "thermite_grenade_explode",
			effect = "effects/upd_blaze/thermite_grenade_explode",
			camera_shake_mul = 2
		}
	}
end
