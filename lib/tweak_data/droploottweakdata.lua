DropLootTweakData = DropLootTweakData or class()

function DropLootTweakData:init(tweak_data)
	self:_init_pickups_properties()
	self:_init_drop_rate_multipliers()
	self:_init_default_tier()
	self:_init_basic_crate_tier()
	self:_init_lockpick_crate_tier()
	self:_init_crowbar_crate_tier()
	self:_init_basic_shelf_tier()
	self:_init_camp_shelf_tier()
	self:_init_easy_enemy()
	self:_init_normal_enemy()
	self:_init_hard_enemy()
	self:_init_elite_enemy()
	self:_init_special_enemy()
	self:_init_flamer_enemy()
end

function DropLootTweakData:_init_pickups_properties()
	self.health_big = {
		health_restored = 420,
		restore_down = true,
		player_voice_over = "player_gain_huge_health"
	}
	self.health_medium = {
		health_restored = 75,
		player_voice_over = "player_gain_moderate_health"
	}
	self.health_small = {
		health_restored = 35
	}
	self.grenades_big = {
		grenades_amount = 3
	}
	self.grenades_medium = {
		grenades_amount = 2
	}
	self.grenades_small = {
		grenades_amount = 1
	}
	self.ammo_big = {
		ammo_multiplier = 6
	}
	self.ammo_medium = {
		ammo_multiplier = 3
	}
	self.ammo_small = {
		ammo_multiplier = 1
	}
end

function DropLootTweakData:_init_elite_enemy()
	self.elite_enemy = {
		units = {},
		buff_effects_applied = {}
	}
	self.elite_enemy.buff_effects_applied[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
	self.elite_enemy.units.health = {
		drop_rate = 10,
		subtypes = {}
	}
	self.elite_enemy.units.health.subtypes.medium = {
		drop_rate = 1,
		unit = "health_medium_beam"
	}
	self.elite_enemy.units.health.subtypes.small = {
		drop_rate = 1,
		unit = "health_small_beam"
	}
	self.elite_enemy.units.grenade = {
		drop_rate = 5,
		unit = "grenade_medium_beam"
	}
	self.elite_enemy.units.ammo = {
		drop_rate = 40,
		unit = "ammo_medium_beam"
	}
end

function DropLootTweakData:_init_easy_enemy()
	self.easy_enemy = {
		units = {},
		buff_effects_applied = {}
	}
	self.easy_enemy.buff_effects_applied[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
	self.easy_enemy.units.health = {
		drop_rate = 15,
		subtypes = {}
	}
	self.easy_enemy.units.health.subtypes.medium = {
		drop_rate = 10,
		unit = "health_medium_beam"
	}
	self.easy_enemy.units.health.subtypes.small = {
		drop_rate = 90,
		unit = "health_small_beam"
	}
	self.easy_enemy.units.grenade = {
		drop_rate = 5,
		unit = "grenade_small_beam"
	}
	self.easy_enemy.units.ammo = {
		drop_rate = 45,
		subtypes = {}
	}
	self.easy_enemy.units.ammo.subtypes.medium = {
		drop_rate = 25,
		unit = "ammo_medium_beam"
	}
	self.easy_enemy.units.ammo.subtypes.small = {
		drop_rate = 75,
		unit = "ammo_small_beam"
	}
end

function DropLootTweakData:_init_normal_enemy()
	self.normal_enemy = {
		units = {},
		buff_effects_applied = {}
	}
	self.normal_enemy.buff_effects_applied[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
	self.normal_enemy.units.health = {
		drop_rate = 10,
		subtypes = {}
	}
	self.normal_enemy.units.health.subtypes.medium = {
		drop_rate = 20,
		unit = "health_medium_beam"
	}
	self.normal_enemy.units.health.subtypes.small = {
		drop_rate = 80,
		unit = "health_small_beam"
	}
	self.normal_enemy.units.grenade = {
		drop_rate = 2,
		unit = "grenade_small_beam"
	}
	self.normal_enemy.units.ammo = {
		drop_rate = 40,
		subtypes = {}
	}
	self.normal_enemy.units.ammo.subtypes.medium = {
		drop_rate = 50,
		unit = "ammo_medium_beam"
	}
	self.normal_enemy.units.ammo.subtypes.small = {
		drop_rate = 50,
		unit = "ammo_small_beam"
	}
end

function DropLootTweakData:_init_hard_enemy()
	self.hard_enemy = {
		units = {},
		buff_effects_applied = {}
	}
	self.hard_enemy.buff_effects_applied[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
	self.hard_enemy.units.health = {
		drop_rate = 20,
		subtypes = {}
	}
	self.hard_enemy.units.health.subtypes.medium = {
		drop_rate = 30,
		unit = "health_medium_beam"
	}
	self.hard_enemy.units.health.subtypes.small = {
		drop_rate = 70,
		unit = "health_small_beam"
	}
	self.hard_enemy.units.grenade = {
		drop_rate = 3,
		unit = "grenade_small_beam"
	}
	self.hard_enemy.units.ammo = {
		drop_rate = 30,
		subtypes = {}
	}
	self.hard_enemy.units.ammo.subtypes.medium = {
		drop_rate = 75,
		unit = "ammo_medium_beam"
	}
	self.hard_enemy.units.ammo.subtypes.small = {
		drop_rate = 25,
		unit = "ammo_small_beam"
	}
end

function DropLootTweakData:_init_special_enemy()
	self.special_enemy = {
		units = {},
		buff_effects_applied = {}
	}
	self.special_enemy.buff_effects_applied[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
	self.special_enemy.units.health = {
		drop_rate = 65,
		subtypes = {}
	}
	self.special_enemy.units.health.subtypes.medium = {
		drop_rate = 100,
		unit = "health_medium_beam"
	}
	self.special_enemy.units.ammo = {
		drop_rate = 35,
		subtypes = {}
	}
	self.special_enemy.units.ammo.subtypes.medium = {
		drop_rate = 100,
		unit = "ammo_medium_beam"
	}
end

function DropLootTweakData:_init_flamer_enemy()
	self.flamer_enemy = {
		buff_effects_applied = {
			[BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE] = true
		},
		units = {
			health = {
				drop_rate = 60,
				subtypes = {
					large = {
						drop_rate = 15,
						unit = "health_big_beam"
					},
					medium = {
						drop_rate = 85,
						unit = "health_medium_beam"
					}
				}
			},
			ammo = {
				drop_rate = 40,
				subtypes = {
					large = {
						drop_rate = 15,
						unit = "ammo_big_beam"
					},
					medium = {
						drop_rate = 85,
						unit = "ammo_medium_beam"
					}
				}
			}
		}
	}
end

function DropLootTweakData:_init_basic_crate_tier()
	self.basic_crate_tier = {
		units = {}
	}
	self.basic_crate_tier.units.health = {
		drop_rate = 50,
		subtypes = {}
	}
	self.basic_crate_tier.units.health.subtypes.medium = {
		drop_rate = 30,
		unit = "health_medium"
	}
	self.basic_crate_tier.units.health.subtypes.small = {
		drop_rate = 60,
		unit = "health_small"
	}
	self.basic_crate_tier.units.grenade = {
		drop_rate = 20,
		subtypes = {}
	}
	self.basic_crate_tier.units.grenade.subtypes.medium = {
		drop_rate = 50,
		unit = "grenade_medium"
	}
	self.basic_crate_tier.units.grenade.subtypes.small = {
		drop_rate = 25,
		unit = "grenade_small"
	}
	self.basic_crate_tier.units.ammo = {
		drop_rate = 55,
		subtypes = {}
	}
	self.basic_crate_tier.units.ammo.subtypes.medium = {
		drop_rate = 30,
		unit = "ammo_medium"
	}
	self.basic_crate_tier.units.ammo.subtypes.small = {
		drop_rate = 60,
		unit = "ammo_small"
	}
end

function DropLootTweakData:_init_lockpick_crate_tier()
	self.lockpick_crate_tier = {
		units = {}
	}
	self.lockpick_crate_tier.units.health = {
		drop_rate = 40,
		subtypes = {}
	}
	self.lockpick_crate_tier.units.health.subtypes.large = {
		drop_rate = 6,
		unit = "health_big"
	}
	self.lockpick_crate_tier.units.health.subtypes.medium = {
		drop_rate = 47,
		unit = "health_medium"
	}
	self.lockpick_crate_tier.units.health.subtypes.small = {
		drop_rate = 47,
		unit = "health_small"
	}
	self.lockpick_crate_tier.units.grenade = {
		drop_rate = 20,
		subtypes = {}
	}
	self.lockpick_crate_tier.units.grenade.subtypes.large = {
		drop_rate = 50,
		unit = "grenade_big"
	}
	self.lockpick_crate_tier.units.grenade.subtypes.medium = {
		drop_rate = 50,
		unit = "grenade_medium"
	}
	self.lockpick_crate_tier.units.ammo = {
		drop_rate = 40,
		subtypes = {}
	}
	self.lockpick_crate_tier.units.ammo.subtypes.medium = {
		drop_rate = 50,
		unit = "ammo_medium"
	}
	self.lockpick_crate_tier.units.ammo.subtypes.small = {
		drop_rate = 50,
		unit = "ammo_small"
	}
end

function DropLootTweakData:_init_crowbar_crate_tier()
	self.crowbar_crate_tier = {
		units = {}
	}
	self.crowbar_crate_tier.units.health = {
		drop_rate = 40,
		unit = "health_big"
	}
	self.crowbar_crate_tier.units.grenade = {
		drop_rate = 15,
		unit = "grenade_big"
	}
	self.crowbar_crate_tier.units.ammo = {
		drop_rate = 45,
		unit = "ammo_big"
	}
end

function DropLootTweakData:_init_basic_shelf_tier()
	self.basic_shelf_tier = {
		units = {},
		difficulty_multipliers = {
			0.7,
			0.6,
			0.4,
			0.3
		}
	}
	self.basic_shelf_tier.units.health = {
		drop_rate = 20,
		subtypes = {}
	}
	self.basic_shelf_tier.units.health.subtypes.large = {
		drop_rate = 5,
		unit = "health_big"
	}
	self.basic_shelf_tier.units.health.subtypes.medium = {
		drop_rate = 60,
		unit = "health_medium"
	}
	self.basic_shelf_tier.units.health.subtypes.small = {
		drop_rate = 35,
		unit = "health_small"
	}
	self.basic_shelf_tier.units.grenade = {
		drop_rate = 5,
		subtypes = {}
	}
	self.basic_shelf_tier.units.grenade.subtypes.large = {
		drop_rate = 15,
		unit = "grenade_big"
	}
	self.basic_shelf_tier.units.grenade.subtypes.medium = {
		drop_rate = 60,
		unit = "grenade_medium"
	}
	self.basic_shelf_tier.units.grenade.subtypes.small = {
		drop_rate = 15,
		unit = "grenade_small"
	}
	self.basic_shelf_tier.units.ammo = {
		drop_rate = 20,
		subtypes = {}
	}
	self.basic_shelf_tier.units.ammo.subtypes.large = {
		drop_rate = 30,
		unit = "ammo_big"
	}
	self.basic_shelf_tier.units.ammo.subtypes.medium = {
		drop_rate = 50,
		unit = "ammo_medium"
	}
	self.basic_shelf_tier.units.ammo.subtypes.small = {
		drop_rate = 10,
		unit = "ammo_small"
	}
end

function DropLootTweakData:_init_camp_shelf_tier()
	self.camp_shelf_tier = {
		units = {}
	}
	self.camp_shelf_tier.units.health = {
		drop_rate = 10,
		subtypes = {}
	}
	self.camp_shelf_tier.units.health.subtypes.large = {
		drop_rate = 50,
		unit = "health_big"
	}
	self.camp_shelf_tier.units.health.subtypes.medium = {
		drop_rate = 30,
		unit = "health_medium"
	}
	self.camp_shelf_tier.units.health.subtypes.small = {
		drop_rate = 20,
		unit = "health_small"
	}
	self.camp_shelf_tier.units.grenade = {
		drop_rate = 30,
		subtypes = {}
	}
	self.camp_shelf_tier.units.grenade.subtypes.large = {
		drop_rate = 70,
		unit = "grenade_big"
	}
	self.camp_shelf_tier.units.grenade.subtypes.medium = {
		drop_rate = 20,
		unit = "grenade_medium"
	}
	self.camp_shelf_tier.units.grenade.subtypes.small = {
		drop_rate = 10,
		unit = "grenade_small"
	}
	self.camp_shelf_tier.units.ammo = {
		drop_rate = 60,
		subtypes = {}
	}
	self.camp_shelf_tier.units.ammo.subtypes.large = {
		drop_rate = 70,
		unit = "ammo_big"
	}
	self.camp_shelf_tier.units.ammo.subtypes.medium = {
		drop_rate = 20,
		unit = "ammo_medium"
	}
	self.camp_shelf_tier.units.ammo.subtypes.small = {
		drop_rate = 10,
		unit = "ammo_small"
	}
end

function DropLootTweakData:_init_default_tier()
	self.default_tier = {
		unit = "ammo_small"
	}
end

function DropLootTweakData:_init_drop_rate_multipliers()
	self.drop_rate_multipliers = {
		health = {
			min_multiplier = 2,
			max_multiplier = 1.5,
			max_ratio = 0.5,
			min_ratio = 0.2
		},
		grenade = {
			min_multiplier = 5,
			max_multiplier = 1.5,
			max_ratio = 0.5,
			min_ratio = 0.01
		}
	}
end

function DropLootTweakData:get_drop_rate_multiplier(type, ratio)
	local multiplier = 1
	local modifier = self.drop_rate_multipliers[type]

	if modifier and ratio < modifier.max_ratio then
		ratio = math.clamp(ratio, modifier.min_ratio, modifier.max_ratio)
		local ratio_normalized = (ratio - modifier.min_ratio) / (modifier.max_ratio - modifier.min_ratio)
		multiplier = math.lerp(modifier.min_multiplier, modifier.max_multiplier, ratio_normalized)
	end

	return multiplier
end
