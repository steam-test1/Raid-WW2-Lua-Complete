CarryTweakData = CarryTweakData or class()
CarryTweakData.default_throw_power = 600
CarryTweakData.corpse_throw_power = 350

function CarryTweakData:init(tweak_data)
	self.default_lootbag = "units/vanilla/dev/dev_lootbag/dev_lootbag"
	self.default_visual_unit = "units/vanilla/dev/dev_player_loot_bag/dev_player_loot_bag"
	self.default_visual_unit_joint_array = {
		"Spine1"
	}
	self.default_visual_unit_root_joint = "Hips"
	self.default_bag_delay = 1
	self.dye = {
		chance = 0.5,
		value_multiplier = 60
	}
	self.types = {
		being = {}
	}
	self.types.being.move_speed_modifier = 0.45
	self.types.being.jump_modifier = 0.75
	self.types.being.can_run = false
	self.types.being.throw_distance_multiplier = 0.8
	self.types.being.stamina_consume_multi = 2
	self.types.mega_heavy = {
		move_speed_modifier = 0.3,
		jump_modifier = 0.3,
		can_run = false,
		stamina_consume_multi = 2,
		throw_distance_multiplier = 0.3
	}
	self.types.very_heavy = {
		move_speed_modifier = 0.4,
		jump_modifier = 0.4,
		can_run = false,
		stamina_consume_multi = 2,
		throw_distance_multiplier = 0.4
	}
	self.types.slightly_very_heavy = deep_clone(self.types.very_heavy)
	self.types.slightly_very_heavy.throw_distance_multiplier = 0.5
	self.types.slightly_very_heavy.move_speed_modifier = 0.5
	self.types.slightly_very_heavy.stamina_consume_multi = 1.5
	self.types.heavy = {
		move_speed_modifier = 0.6,
		jump_modifier = 0.6,
		can_run = true,
		throw_distance_multiplier = 0.5,
		stamina_consume_multi = 1.5
	}
	self.types.medium = {
		move_speed_modifier = 0.7,
		jump_modifier = 1,
		can_run = true,
		throw_distance_multiplier = 0.8,
		stamina_consume_multi = 1.25
	}
	self.types.slightly_medium = {
		move_speed_modifier = 0.8,
		jump_modifier = 1,
		can_run = true,
		throw_distance_multiplier = 0.9,
		stamina_consume_multi = 1.5
	}
	self.types.light = {
		move_speed_modifier = 0.9,
		jump_modifier = 1,
		can_run = true,
		throw_distance_multiplier = 1
	}
	self.types.explosives = deep_clone(self.types.medium)
	self.types.explosives.can_explode = true
	self.codemachine_part_01 = {
		type = "light",
		name_id = "hud_carry_codemachine_part_01",
		skip_exit_secure = true
	}
	self.codemachine_part_02 = {
		type = "light",
		name_id = "hud_carry_codemachine_part_02",
		skip_exit_secure = true
	}
	self.codemachine_part_03 = {
		type = "medium",
		name_id = "hud_carry_codemachine_part_03",
		skip_exit_secure = true
	}
	self.codemachine_part_04 = {
		type = "medium",
		name_id = "hud_carry_codemachine_part_04",
		skip_exit_secure = true
	}
	self.contraband_jewelry = {
		type = "light",
		name_id = "hud_carry_contraband_jewelry",
		skip_exit_secure = true
	}
	local unit_painting_bag = "units/vanilla/starbreeze_units/sto_units/pickups/pku_painting_bag/pku_painting_bag"
	local unit_painting_bag_acc = "units/vanilla/starbreeze_units/sto_units/characters/npc_acc_painting_bag/npc_acc_painting_bag"
	self.painting_sto = {
		type = "light",
		name_id = "hud_carry_painting",
		value_in_gold = 4,
		unit = unit_painting_bag,
		visual_unit_name = unit_painting_bag_acc,
		visual_unit_root_joint = "body_bag_spawn",
		AI_carry = {
			SO_category = "enemies"
		},
		hud_icon = "carry_painting"
	}
	self.painting_sto_cheap = {
		type = "light",
		name_id = "hud_carry_painting",
		value_in_gold = 1,
		unit = unit_painting_bag,
		visual_unit_name = unit_painting_bag_acc,
		visual_unit_root_joint = "body_bag_spawn",
		AI_carry = {
			SO_category = "enemies"
		},
		hud_icon = "carry_painting"
	}
	self.wine_crate = {
		type = "slightly_medium",
		name_id = "hud_carry_wine_crate",
		loot_value = 4,
		value_in_gold = 5,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crate_wine_bag/pku_crate_wine_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.cigar_crate = {
		type = "slightly_medium",
		name_id = "hud_carry_cigar_crate",
		loot_value = 3,
		value_in_gold = 4,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crate_cigar_bag/pku_crate_cigar_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.chocolate_box = {
		type = "slightly_medium",
		name_id = "hud_carry_chocolate_box",
		loot_value = 2,
		value_in_gold = 3,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_chocolate_box_bag/pku_chocolate_box_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.crucifix = {
		type = "slightly_medium",
		name_id = "hud_carry_crucifix",
		loot_value = 2,
		value_in_gold = 3,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crucifix_bag/pku_crucifix_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.baptismal_font = {
		type = "slightly_medium",
		name_id = "hud_carry_baptismal_font",
		loot_value = 4,
		value_in_gold = 5,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_baptismal_font_bag/pku_baptismal_font_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.religious_figurine = {
		type = "slightly_medium",
		name_id = "hud_carry_religious_figurine",
		loot_value = 2,
		value_in_gold = 3,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_religious_figurine_bag/pku_religious_figurine_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.candelabrum = {
		type = "slightly_medium",
		name_id = "hud_carry_candleabrum",
		loot_value = 3,
		value_in_gold = 4,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_candelabrum_bag/pku_candelabrum_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.torch_tank = {
		type = "light",
		name_id = "hud_carry_torch_tank",
		skip_exit_secure = true
	}
	self.turret_m2_gun = {
		type = "medium",
		name_id = "hud_carry_turret_m2_gun",
		skip_exit_secure = true
	}
	self.money_print_plate = {
		type = "medium",
		name_id = "hud_carry_money_print_plate",
		skip_exit_secure = true
	}
	self.ladder_4m = {
		type = "light",
		name_id = "hud_carry_ladder",
		skip_exit_secure = true
	}
	self.flak_shell = {
		type = "medium",
		name_id = "hud_carry_flak_shell",
		skip_exit_secure = true,
		unit = "units/vanilla/pickups/pku_flak_shell_bag/pku_flak_shell_bag",
		hud_icon = "carry_flak_shell",
		throw_sound = "flakshell_throw"
	}
	self.flak_shell_explosive = deep_clone(self.flak_shell)
	self.flak_shell_explosive.type = "explosives"
	self.flak_shell_explosive.unit = "units/vanilla/pickups/pku_88_flak_shell_bag/pku_88_flak_shell_bag"
	self.flak_shell_explosive.hud_icon = "carry_flak_shell"
	self.flak_shell_explosive.can_explode = true
	self.flak_shell_explosive.throw_sound = "flakshell_throw"
	self.flak_shell_shot_explosive = deep_clone(self.flak_shell)
	self.flak_shell_shot_explosive.type = "explosives"
	self.flak_shell_shot_explosive.unit = "units/vanilla/pickups/pku_88_flak_shell_explosive_bag/pku_88_flak_shell_explosive_bag"
	self.flak_shell_shot_explosive.hud_icon = "carry_flak_shell"
	self.flak_shell_shot_explosive.throw_sound = "flakshell_throw"
	self.flak_shell_pallete = {
		type = "medium",
		name_id = "hud_carry_flak_shell_pallete",
		skip_exit_secure = true,
		throw_sound = "flakshell_throw"
	}
	self.tank_shells = {
		type = "medium",
		name_id = "hud_carry_tank_shells",
		skip_exit_secure = true,
		throw_sound = "flakshell_throw"
	}
	self.tank_shell_explosive = deep_clone(self.flak_shell)
	self.tank_shell_explosive.name_id = "hud_tank_shell"
	self.tank_shell_explosive.type = "explosives"
	self.tank_shell_explosive.unit = "units/vanilla/pickups/pku_tank_shell_bag/pku_tank_shell_bag"
	self.tank_shell_explosive.hud_icon = "carry_flak_shell"
	self.tank_shell_explosive.can_explode = true
	self.tank_shell_explosive.throw_sound = "flakshell_throw"
	self.plank = {
		type = "medium",
		name_id = "hud_carry_plank",
		skip_exit_secure = true,
		unit = "units/vanilla/pickups/pku_plank_bag/pku_plank_bag",
		hud_icon = "carry_planks"
	}
	self.parachute = {
		type = "light",
		name_id = "hud_carry_parachute",
		skip_exit_secure = true
	}
	self.bonds_stack = {
		type = "light",
		name_id = "hud_carry_bonds",
		bag_value = "bonds",
		loot_value = 4,
		dye = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.gold = {
		type = "medium",
		name_id = "hud_carry_gold",
		bag_value = "gold",
		loot_value = 20,
		value_in_gold = 2,
		unit = "units/vanilla/pickups/pku_gold_crate_bag/pku_gold_crate_bag",
		hud_icon = "carry_gold",
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.gold_bar = {
		type = "light",
		name_id = "hud_carry_gold_bar",
		bag_value = "gold_bar",
		loot_value = 5,
		unit = "units/vanilla/pickups/pku_gold_bar_bag/pku_gold_bar_bag",
		hud_icon = "carry_gold",
		value_in_gold = 1,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.dev_pku_carry_light = {
		type = "light",
		name_id = "hud_carry_gold_bar",
		bag_value = "gold_bar",
		loot_value = 5,
		unit = "units/vanilla/dev/dev_pku_carry_light/dev_pku_carry_light_bag",
		hud_icon = "carry_gold",
		value_in_gold = 1,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.dev_pku_carry_medium = {
		type = "medium",
		name_id = "hud_carry_gold_bar",
		bag_value = "gold_bar",
		loot_value = 5,
		unit = "units/vanilla/dev/dev_pku_carry_medium/dev_pku_carry_medium_bag",
		hud_icon = "carry_gold",
		value_in_gold = 1,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.dev_pku_carry_heavy = {
		type = "heavy",
		name_id = "hud_carry_gold_bar",
		bag_value = "gold_bar",
		loot_value = 5,
		unit = "units/vanilla/dev/dev_pku_carry_heavy/dev_pku_carry_heavy_bag",
		hud_icon = "carry_gold",
		value_in_gold = 1,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.german_grunt_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_grunt_heavy/body_bag/german_grunt_heavy_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_grunt_light_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_grunt_heavy/body_bag/german_grunt_heavy_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_grunt_mid_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_grunt_mid/body_bag/german_grunt_mid_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.gebirgsjager_light_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_gebirgsjager_light/body_bag/german_gebirgsjager_light_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.gebirgsjager_heavy_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/body_bag/german_gebirgsjager_heavy_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_fallschirmjager_light_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_fallschirmjager_light/body_bag/german_fallschirmjager_light_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_fallschirmjager_heavy_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/body_bag/german_fallschirmjager_heavy_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_waffen_ss_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_waffen_ss/body_bag/german_waffen_ss_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_waffen_ss/german_waffen_ss_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_commander_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_commander/body_bag/german_commander_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_commander/german_commander_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_og_commander_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_og_commander/body_bag/german_og_commander_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_og_commander/german_og_commander_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
	self.german_black_waffen_sentry_light_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/body_bag/german_black_waffen_sentry_light_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse"
	}
	self.german_black_waffen_sentry_gasmask_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/body_bag/german_black_waffen_sentry_gasmask_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/german_black_waffen_sentry_gasmask_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse"
	}
	self.german_black_waffen_sentry_heavy_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/body_bag/german_black_waffen_sentry_heavy_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse"
	}
	self.german_black_waffen_sentry_heavy_commander_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/body_bag/german_black_waffen_sentry_light_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse"
	}
	self.german_black_waffen_sentry_light_commander_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/body_bag/german_black_waffen_sentry_light_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse"
	}
	self.crate_of_fuel_canisters = {
		type = "medium",
		name_id = "hud_carry_crate_of_fuel_canisters",
		skip_exit_secure = false,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.spiked_wine_barrel = {
		type = "medium",
		name_id = "hud_carry_spiked_wine",
		unit = "units/vanilla/pickups/pku_barrel_bag/pku_barrel_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		}
	}
	self.german_spy = {
		type = "being",
		name_id = "hud_carry_spy",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/npc/models/raid_npc_spy/body_bag/raid_npc_spy_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/npc/models/raid_npc_spy/raid_npc_spy_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		prompt_text = "hud_carry_put_down_prompt",
		carry_item_id = "carry_item_spy",
		hud_icon = "carry_alive"
	}
	self.soviet_nkvd_int_security_captain_body = {
		type = "being",
		name_id = "hud_carry_body",
		skip_exit_secure = true,
		visual_unit_name = "units/vanilla/characters/enemies/models/soviet_nkvd_int_security_captain/body_bag/soviet_nkvd_int_security_captain_body_bag",
		visual_unit_root_joint = "body_bag_spawn",
		unit = "units/vanilla/characters/enemies/models/soviet_nkvd_int_security_captain/soviet_nkvd_int_security_captain_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		needs_headroom_to_drop = true,
		is_corpse = true,
		hud_icon = "carry_corpse"
	}
end

function CarryTweakData:get_carry_ids()
	local t = {}

	for id, _ in pairs(tweak_data.carry) do
		if type(tweak_data.carry[id]) == "table" and tweak_data.carry[id].type then
			table.insert(t, id)
		end
	end

	table.sort(t)

	return t
end

function CarryTweakData:get_zipline_offset(carry_id)
	if self[carry_id] and not not self[carry_id].zipline_offset then
		return self[carry_id].zipline_offset
	end

	return Vector3(15, 0, -8)
end
