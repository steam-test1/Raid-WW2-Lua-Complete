FireTweakData = FireTweakData or class()
FireTweakData.FIRE_TYPE_SINGLE = "single"
FireTweakData.FIRE_TYPE_PARENTED = "parented"
FireTweakData.FIRE_TYPE_HEX = "hex"
FireTweakData.FIRE_TYPE_LINE = "line"
FireTweakData.NETWORK_DAMAGE_MULTIPLIER = 163.84
FireTweakData.NETWORK_DAMAGE_LIMIT = 32768
FireTweakData.PROP_DAMAGE_LIMIT = 200
FireTweakData.PROP_DAMAGE_PRECISION = 0.25

function FireTweakData:init(tweak_data)
	self:_init_effects()
	self:_init_dot_types()
	self:_init_fires()

	self.character_fire_bones = {
		Idstring("Spine"),
		Idstring("LeftArm"),
		Idstring("RightArm"),
		Idstring("LeftLeg"),
		Idstring("RightLeg")
	}
	self.death_effects = {
		default = {
			{
				effect = "character_9s",
				duration = 9
			},
			{
				effect = "character_5s",
				duration = 5
			},
			{
				effect = "character_5s",
				duration = 5
			},
			{
				effect = "character_7s",
				duration = 7
			},
			default = {
				effect = "character",
				duration = 3
			}
		}
	}
end

function FireTweakData:_init_effects()
	self.effects = {
		character = Idstring("effects/vanilla/fire/fire_character_burning_001"),
		character_5s = Idstring("effects/vanilla/fire/fire_character_burning_001_5s"),
		character_7s = Idstring("effects/vanilla/fire/fire_character_burning_001_7s"),
		character_9s = Idstring("effects/vanilla/fire/fire_character_burning_001_9s"),
		character_endless = Idstring("effects/vanilla/fire/fire_character_burning_001_endless"),
		molotov = Idstring("effects/vanilla/fire/fire_molotov_grenade_001"),
		thermite = Idstring("effects/upd_blaze/thermite_grenade_burn"),
		thermite_detonate = Idstring("effects/upd_blaze/thermite_grenade_explode")
	}
end

function FireTweakData:_init_dot_types()
	self.dot_types = {
		default = {
			damage = 10,
			variant = "fire",
			duration = 2,
			trigger_chance = 35,
			trigger_max_distance = 3000,
			tick_interval = 0.5
		},
		thermite = {
			damage = 10,
			variant = "fire",
			duration = 13,
			trigger_chance = 68,
			trigger_max_distance = 3000,
			tick_interval = 0.5
		}
	}
end

function FireTweakData:_init_fires()
	self.explosive_barrel = {
		range = 65,
		player_damage = 5,
		sound_impact = "grenade_explode",
		sound_burning_stop = "burn_loop_body_stop",
		sound_impact_duration = 0.6,
		tick_interval = 0.665,
		damage = 15,
		sound_burning = "burn_loop_body",
		duration = 20,
		alert_radius = 1500,
		dot_type = "default",
		iterations = 4,
		type = self.FIRE_TYPE_HEX,
		effect_name = self.effects.molotov
	}
	self.flamer_tank = clone(self.explosive_barrel)
	self.flamer_tank.duration = 10
	self.flamer_tank.iterations = 6
	self.flamer_tank.range = 75
	self.flamer_tank.sound_impact = nil
	self.flamer_tank.sound_impact_duration = 0.3
	self.thermite_grenade = {
		range = 380,
		player_damage = 3,
		sound_burning_stop = "thermite_grenade_stop",
		tick_interval = 0.875,
		damage = 10,
		sound_burning = "thermite_grenade",
		duration = 35,
		alert_radius = 750,
		dot_type = "thermite",
		type = self.FIRE_TYPE_PARENTED,
		effect_name = self.effects.thermite
	}
	self.thermite_detonate = {
		range = 500,
		player_damage = 5,
		tick_interval = 0.3333,
		damage = 30,
		duration = 1,
		alert_radius = 1400,
		dot_type = "thermite",
		type = self.FIRE_TYPE_SINGLE,
		effect_name = self.effects.thermite_detonate
	}
	self.flamer_incendiary = {
		range = 100,
		player_damage = 4,
		sound_impact = "flamer_grenade_explode",
		sound_burning_stop = "burn_loop_body_stop",
		sound_impact_duration = 0.6,
		tick_interval = 0.25,
		damage = 5,
		sound_burning = "burn_loop_body",
		duration = 8,
		alert_radius = 1500,
		dot_type = "default",
		iterations = 6,
		type = self.FIRE_TYPE_HEX,
		effect_name = self.effects.molotov
	}
end
