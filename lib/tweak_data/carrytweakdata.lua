CarryTweakData = CarryTweakData or class()
CarryTweakData.default_throw_power = 600
CarryTweakData.corpse_throw_power = 180

-- Lines 6-377
function CarryTweakData:init(tweak_data)
	self:_init_shared_multipliers()

	self.default_lootbag = "units/vanilla/dev/dev_lootbag/dev_lootbag"
	self.default_visual_unit = "units/vanilla/dev/dev_player_loot_bag/dev_player_loot_bag"
	self.default_visual_unit_joint_array = {
		"Spine1"
	}
	self.default_visual_unit_root_joint = "Hips"
	self.default_bag_delay = 0.1
	self.default_bag_weight = 2
	self.default_bag_icon = "carry_bag"
	self.backup_corpse_body_id = "corpse_body"
	self.types = {
		being = {}
	}
	self.types.being.move_speed_modifier = {
		0.7,
		0.7
	}
	self.types.being.jump_modifier = {
		0.8,
		0.8
	}
	self.types.being.stamina_consume_multi = {
		1.5,
		1.5
	}
	self.types.being.throw_distance_multiplier = {
		1,
		1
	}
	self.types.being.can_run = false
	self.types.normal = {
		move_speed_modifier = {
			1,
			0.8
		},
		jump_modifier = {
			1,
			0.8
		},
		stamina_consume_multi = {
			1,
			1.5
		},
		throw_distance_multiplier = {
			1,
			1
		},
		can_run = true
	}
	local unit_painting_bag = "units/vanilla/starbreeze_units/sto_units/pickups/pku_painting_bag/pku_painting_bag"
	local unit_painting_bag_acc = "units/vanilla/starbreeze_units/sto_units/characters/npc_acc_painting_bag/npc_acc_painting_bag"
	local unit_painting_bag_static = "units/vanilla/starbreeze_units/sto_units/pickups/pku_painting_bag/pku_canvasbag_static"
	self.painting_sto = {
		type = "normal",
		name_id = "hud_carry_painting",
		loot_value = 3,
		loot_outlaw_value = 3,
		loot_greed_value = tweak_data.greed.item_value.carry_painting,
		unit = unit_painting_bag,
		visual_unit_name = unit_painting_bag_acc,
		unit_static = unit_painting_bag_static,
		visual_unit_root_joint = "body_bag_spawn",
		AI_carry = {
			SO_category = "enemies"
		},
		hud_icon = "carry_painting",
		throw_rotations = Rotation(0, 0, 66),
		upgrade_throw_multiplier = self.TRHROW_MULTIPLIERS_GENERIC,
		weight = 2,
		show_objects = {
			g_sticker = true
		}
	}
	self.painting_sto_cheap = deep_clone(self.painting_sto)
	self.painting_sto_cheap.name_id = "hud_carry_painting"
	self.painting_sto_cheap.hud_icon = "carry_painting_cheap"
	self.painting_sto_cheap.loot_value = 1
	self.painting_sto_cheap.loot_outlaw_value = 1
	self.painting_sto_cheap.loot_greed_value = tweak_data.greed.item_value.carry_painting_cheap
	self.painting_sto_cheap.show_objects = {
		g_sticker = false
	}
	self.wine_crate = {
		type = "normal",
		name_id = "hud_carry_wine_crate",
		loot_value = 3,
		loot_outlaw_value = 4,
		loot_greed_value = tweak_data.greed.item_value.carry_high_end,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crate_wine_bag/pku_crate_wine_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		},
		upgrade_throw_multiplier = self.TRHROW_MULTIPLIERS_GENERIC,
		weight = 3,
		hud_icon = "carry_artefact"
	}
	self.cigar_crate = deep_clone(self.wine_crate)
	self.cigar_crate.name_id = "hud_carry_cigar_crate"
	self.cigar_crate.unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crate_cigar_bag/pku_crate_cigar_bag"
	self.baptismal_font = deep_clone(self.wine_crate)
	self.baptismal_font.name_id = "hud_carry_baptismal_font"
	self.baptismal_font.unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_baptismal_font_bag/pku_baptismal_font_bag"
	self.chocolate_box = {
		type = "normal",
		name_id = "hud_carry_chocolate_box",
		loot_value = 2,
		loot_outlaw_value = 3,
		loot_greed_value = tweak_data.greed.item_value.carry_mid_end,
		unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_chocolate_box_bag/pku_chocolate_box_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		},
		upgrade_throw_multiplier = self.TRHROW_MULTIPLIERS_GENERIC,
		weight = 2,
		hud_icon = "carry_artefact"
	}
	self.crucifix = deep_clone(self.chocolate_box)
	self.crucifix.name_id = "hud_carry_crucifix"
	self.crucifix.unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_crucifix_bag/pku_crucifix_bag"
	self.religious_figurine = deep_clone(self.chocolate_box)
	self.religious_figurine.name_id = "hud_carry_religious_figurine"
	self.religious_figurine.unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_religious_figurine_bag/pku_religious_figurine_bag"
	self.candelabrum = deep_clone(self.chocolate_box)
	self.candelabrum.name_id = "hud_carry_candleabrum"
	self.candelabrum.unit = "units/vanilla/starbreeze_units/cvy_units/pickups/pku_candelabrum_bag/pku_candelabrum_bag"
	self.flak_shell = {
		type = "normal",
		name_id = "hud_carry_flak_shell",
		skip_exit_secure = true,
		unit = "units/vanilla/pickups/pku_flak_shell_bag/pku_flak_shell_bag",
		hud_icon = "carry_flak_shell",
		throw_sound = "flakshell_throw",
		upgrade_weight_multiplier = self.WEIGHT_MULTIPLIERS_SHELL,
		weight = 4
	}
	self.flak_shell_explosive = deep_clone(self.flak_shell)
	self.flak_shell_explosive.type = "normal"
	self.flak_shell_explosive.unit = "units/vanilla/pickups/pku_88_flak_shell_bag/pku_88_flak_shell_bag"
	self.flak_shell_explosive.hud_icon = "carry_flak_shell"
	self.flak_shell_explosive.can_explode = true
	self.flak_shell_explosive.throw_sound = "flakshell_throw"
	self.flak_shell_shot_explosive = deep_clone(self.flak_shell)
	self.flak_shell_shot_explosive.type = "normal"
	self.flak_shell_shot_explosive.unit = "units/vanilla/pickups/pku_88_flak_shell_explosive_bag/pku_88_flak_shell_explosive_bag"
	self.flak_shell_shot_explosive.hud_icon = "carry_flak_shell"
	self.flak_shell_shot_explosive.throw_sound = "flakshell_throw"
	self.flak_shell_shot_explosive.can_explode = true
	self.flak_shell_pallete = {
		type = "normal",
		name_id = "hud_carry_flak_shell_pallete",
		skip_exit_secure = true,
		throw_sound = "flakshell_throw",
		upgrade_weight_multiplier = self.WEIGHT_MULTIPLIERS_SHELL,
		weight = 4
	}
	self.tank_shells = {
		type = "normal",
		name_id = "hud_carry_tank_shells",
		skip_exit_secure = true,
		throw_sound = "flakshell_throw",
		hud_icon = "carry_flak_shell",
		upgrade_weight_multiplier = self.WEIGHT_MULTIPLIERS_SHELL,
		weight = 4
	}
	self.tank_shell_explosive = deep_clone(self.tank_shells)
	self.tank_shell_explosive.name_id = "hud_tank_shell"
	self.tank_shell_explosive.unit = "units/vanilla/pickups/pku_tank_shell_bag/pku_tank_shell_bag"
	self.tank_shell_explosive.can_explode = true
	self.plank = {
		type = "normal",
		name_id = "hud_carry_plank",
		skip_exit_secure = true,
		unit = "units/vanilla/pickups/pku_plank_bag/pku_plank_bag",
		hud_icon = "carry_planks",
		cannot_stack = true
	}
	self.crate_explosives = {
		hud_icon = "carry_planks",
		cannot_stack = true,
		unit_static = "units/upd_fb/pickups/pku_crate_explosives/pku_crate_explosives_static",
		type = "normal",
		name_id = "hud_carry_plank",
		unit = "units/upd_fb/pickups/pku_crate_explosives/pku_crate_explosives_bag",
		skip_exit_secure = true
	}
	self.parachute = {
		type = "normal",
		name_id = "hud_carry_parachute",
		skip_exit_secure = true,
		cannot_stack = true
	}
	self.gold_bar = {
		type = "normal",
		name_id = "hud_carry_gold_bar",
		loot_value = 2,
		loot_outlaw_value = 2,
		loot_greed_value = tweak_data.greed.item_value.carry_gold_bar,
		unit = "units/vanilla/pickups/pku_gold_bar_bag/pku_gold_bar_bag",
		unit_static = "units/vanilla/pickups/pku_gold_bar_bag/pku_gold_bar_bag_static",
		hud_icon = "carry_gold",
		AI_carry = {
			SO_category = "enemies"
		},
		throw_rotations = Rotation(2, 40, 8),
		upgrade_throw_multiplier = self.TRHROW_MULTIPLIERS_GENERIC,
		weight = 1
	}
	self.gold = {
		type = "normal",
		name_id = "hud_carry_gold",
		loot_value = self.gold_bar.loot_value * 3,
		loot_outlaw_value = self.gold_bar.loot_outlaw_value * 3,
		loot_greed_value = tweak_data.greed.item_value.carry_gold,
		unit = "units/vanilla/pickups/pku_gold_crate_bag/pku_gold_crate_bag",
		unit_static = "units/vanilla/pickups/pku_gold_crate_bag/pku_gold_crate_bag_static",
		hud_icon = "carry_gold",
		AI_carry = {
			SO_category = "enemies"
		},
		throw_rotations = Rotation(0, 20, 0),
		upgrade_throw_multiplier = self.TRHROW_MULTIPLIERS_GENERIC,
		weight = self.gold_bar.weight * 3
	}
	self.corpse_body = {
		type = "being",
		name_id = "hud_carry_body",
		carry_item_id = "carry_item_corpse",
		hud_icon = "carry_corpse",
		throw_power = CarryTweakData.corpse_throw_power,
		upgrade_weight_multiplier = self.WEIGHT_MULTIPLIERS_CORPSE,
		skip_exit_secure = true,
		needs_headroom_to_drop = true,
		is_corpse = true,
		cannot_stack = true,
		cannot_secure = true
	}
	self.german_spy = deep_clone(self.corpse_body)
	self.german_spy.name_id = "hud_carry_spy"
	self.german_spy.prompt_text = "hud_carry_put_down_prompt"
	self.german_spy.carry_item_id = "carry_item_spy"
	self.german_spy.hud_icon = "carry_alive"
	self.german_spy.visual_unit_root_joint = "body_bag_spawn"
	self.german_spy.visual_unit_name = "units/vanilla/characters/npc/models/raid_npc_spy/body_bag/raid_npc_spy_body_bag"
	self.german_spy.unit_static = "units/vanilla/characters/npc/models/raid_npc_spy/raid_npc_spy_static"
	self.german_spy.unit = "units/vanilla/characters/npc/models/raid_npc_spy/raid_npc_spy_corpse"
	self.german_spy.ignore_corpse_cleanup = true

	self:_build_missing_corpse_bags(tweak_data)

	self.codemachine_part_01 = {
		type = "normal",
		name_id = "hud_carry_codemachine_part_01",
		skip_exit_secure = true,
		weight = 1
	}
	self.codemachine_part_02 = deep_clone(self.codemachine_part_01)
	self.codemachine_part_02.name_id = "hud_carry_codemachine_part_02"
	self.codemachine_part_03 = deep_clone(self.codemachine_part_01)
	self.codemachine_part_03.name_id = "hud_carry_codemachine_part_03"
	self.codemachine_part_04 = deep_clone(self.codemachine_part_01)
	self.codemachine_part_04.name_id = "hud_carry_codemachine_part_04"
	self.contraband_jewelry = {
		type = "normal",
		name_id = "hud_carry_contraband_jewelry",
		skip_exit_secure = true,
		weight = 1
	}
	self.dev_pku_carry_light = {
		type = "normal",
		name_id = "dev_pku_carry_light",
		hud_icon = "carry_gold",
		loot_value = 3,
		loot_outlaw_value = 1,
		loot_greed_value = 1,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 1
	}
	self.dev_pku_carry_medium = {
		type = "normal",
		name_id = "dev_pku_carry_medium",
		hud_icon = "carry_gold",
		loot_value = 2,
		loot_outlaw_value = 1,
		loot_greed_value = 1,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 2
	}
	self.dev_pku_carry_heavy = {
		type = "normal",
		name_id = "dev_pku_carry_heavy",
		hud_icon = "carry_gold",
		loot_value = 1,
		loot_outlaw_value = 1,
		loot_greed_value = 1,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 3
	}
	self.crate_of_fuel_canisters = {
		type = "normal",
		name_id = "hud_carry_crate_of_fuel_canisters",
		skip_exit_secure = false,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 3
	}
	self.spiked_wine_barrel = {
		type = "normal",
		name_id = "hud_carry_spiked_wine",
		unit = "units/vanilla/pickups/pku_barrel_bag/pku_barrel_bag",
		skip_exit_secure = true,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 3
	}
	self.bonds_stack = {
		type = "normal",
		name_id = "hud_carry_bonds",
		loot_value = 2,
		AI_carry = {
			SO_category = "enemies"
		},
		weight = 2
	}
	self.torch_tank = {
		type = "normal",
		name_id = "hud_carry_torch_tank",
		skip_exit_secure = true,
		cannot_stack = true
	}
	self.turret_m2_gun = {
		type = "normal",
		name_id = "hud_carry_turret_m2_gun",
		skip_exit_secure = true,
		cannot_stack = true
	}
	self.money_print_plate = {
		type = "normal",
		name_id = "hud_carry_money_print_plate",
		skip_exit_secure = true,
		weight = 2
	}
	self.ladder_4m = {
		type = "normal",
		name_id = "hud_carry_ladder",
		skip_exit_secure = true,
		cannot_stack = true
	}
end

-- Lines 380-385
function CarryTweakData:_init_shared_multipliers()
	self.WEIGHT_MULTIPLIERS_SHELL = {
		upgrade = "saboteur_shell_weight_multiplier",
		category = "carry"
	}
	self.WEIGHT_MULTIPLIERS_CORPSE = {
		upgrade = "predator_corpse_weight_multiplier",
		category = "carry"
	}
	self.TRHROW_MULTIPLIERS_GENERIC = {
		upgrade = "strongback_throw_distance_multiplier",
		category = "carry"
	}
end

-- Lines 389-436
function CarryTweakData:_build_missing_corpse_bags(tweak_data)
	local char_map = tweak_data.character.character_map()

	for _, data in pairs(char_map) do
		for _, character in ipairs(data.list) do
			if not self[character] then
				local bodybag_path = data.path .. character
				local character_path = bodybag_path .. "/" .. character
				local bag = deep_clone(self.corpse_body)
				bag.unit = character_path .. "_corpse"
				bag.visual_unit_name = bodybag_path .. "/body_bag/" .. character .. "_body_bag"
				bag.visual_unit_root_joint = "body_bag_spawn"
				self[character .. "_body"] = bag
			end
		end
	end
end

-- Lines 439-448
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

-- Lines 452-458
function CarryTweakData:get_zipline_offset(carry_id)
	if self[carry_id] and not not self[carry_id].zipline_offset then
		return self[carry_id].zipline_offset
	end

	return Vector3(15, 0, -8)
end

-- Lines 463-473
function CarryTweakData:get_type_value_weighted(type_id, get_id, weight)
	local type_data = self.types[type_id]

	if type_data then
		if type(type_data[1]) == "boolean" then
			return weight <= type_data[get_id][1] or type_data[get_id][2]
		else
			return math.lerp(type_data[get_id][1], type_data[get_id][2], weight)
		end
	end

	return nil
end
