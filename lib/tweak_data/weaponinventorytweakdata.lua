WeaponInventoryTweakData = WeaponInventoryTweakData or class()

function WeaponInventoryTweakData:init()
	self.weapon_primaries_index = {
		{
			slot = 1,
			weapon_id = "thompson"
		},
		{
			slot = 2,
			weapon_id = "mp38"
		},
		{
			slot = 3,
			weapon_id = "sterling"
		},
		{
			slot = 4,
			weapon_id = "garand"
		},
		{
			slot = 5,
			weapon_id = "mp44"
		},
		{
			slot = 6,
			weapon_id = "m1918"
		},
		{
			slot = 7,
			weapon_id = "mg42"
		},
		{
			slot = 8,
			weapon_id = "m1903"
		},
		{
			slot = 9,
			weapon_id = "mosin"
		},
		{
			slot = 10,
			weapon_id = "m1912"
		},
		{
			slot = 11,
			weapon_id = "sten"
		},
		{
			slot = 12,
			weapon_id = "carbine"
		},
		{
			slot = 13,
			weapon_id = "geco"
		},
		{
			slot = 14,
			weapon_id = "dp28"
		},
		{
			slot = 15,
			weapon_id = "kar_98k"
		},
		{
			slot = 16,
			weapon_id = "bren"
		},
		{
			slot = 17,
			weapon_id = "lee_enfield"
		},
		{
			slot = 18,
			weapon_id = "ithaca"
		},
		{
			slot = 19,
			weapon_id = "browning"
		}
	}
	self.weapon_secondaries_index = {
		{
			slot = 1,
			weapon_id = "m1911"
		},
		{
			slot = 2,
			weapon_id = "c96"
		},
		{
			slot = 3,
			weapon_id = "webley"
		},
		{
			slot = 4,
			weapon_id = "tt33"
		},
		{
			slot = 5,
			weapon_id = "shotty"
		},
		{
			slot = 6,
			weapon_id = "welrod"
		}
	}
	self.weapon_grenades_index = {
		{
			default = true,
			slot = 1,
			weapon_id = "m24"
		},
		{
			slot = 2,
			weapon_id = "concrete"
		},
		{
			slot = 3,
			weapon_id = "d343"
		},
		{
			slot = 4,
			weapon_id = "mills"
		},
		{
			slot = 5,
			weapon_id = "decoy_coin"
		},
		{
			slot = 6,
			weapon_id = "betty"
		},
		{
			slot = 7,
			weapon_id = "gold_bar"
		}
	}
	self.weapon_melee_index = {
		{
			default = true,
			slot = 1,
			weapon_id = "m3_knife",
			redeemed_gold = 5,
			redeemed_xp = 0,
			droppable = false
		},
		{
			slot = 2,
			weapon_id = "robbins_dudley_trench_push_dagger",
			redeemed_gold = 5,
			redeemed_xp = 20,
			droppable = true
		},
		{
			slot = 3,
			weapon_id = "german_brass_knuckles",
			redeemed_gold = 5,
			redeemed_xp = 30,
			droppable = true
		},
		{
			slot = 4,
			weapon_id = "lockwood_brothers_push_dagger",
			redeemed_gold = 5,
			redeemed_xp = 40,
			droppable = true
		},
		{
			slot = 5,
			weapon_id = "bc41_knuckle_knife",
			redeemed_gold = 5,
			redeemed_xp = 50,
			droppable = true
		},
		{
			slot = 6,
			weapon_id = "km_dagger",
			redeemed_gold = 5,
			redeemed_xp = 60,
			droppable = false
		},
		{
			slot = 7,
			weapon_id = "marching_mace",
			redeemed_gold = 5,
			redeemed_xp = 70,
			droppable = false
		},
		{
			is_challenge_reward = true,
			slot = 8,
			weapon_id = "lc14b",
			redeemed_gold = 5,
			redeemed_xp = 80,
			droppable = false
		}
	}
end
