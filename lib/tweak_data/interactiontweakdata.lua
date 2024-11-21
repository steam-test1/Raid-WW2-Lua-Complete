InteractionTweakData = InteractionTweakData or class()

function InteractionTweakData:get_interaction(key)
	if self[key] then
		return self[key]
	else
		Application:warn("[InteractionTweakData:get_interaction] Interaction '" .. tostring(key) .. "' does not exist!")

		return self.temp_interact_box
	end
end

function InteractionTweakData:init()
	self.DEFAULT_INTERACTION_DOT = 0.9
	self.CULLING_DISTANCE = 2000
	self.INTERACT_DISTANCE = 200
	self.POWERUP_INTERACTION_DISTANCE = 270
	self.CARRY_DROP_INTERACTION_DISTANCE = 270
	self.SMALL_OBJECT_INTERACTION_DISTANCE = 165
	self.INTERACT_DELAY_COMPLETED = 0.04
	self.INTERACT_DELAY_INTERRUPTED = 0.12
	self.INTERACT_TIMER_INSTA = 0
	self.INTERACT_TIMER_VERY_SHORT = 0.5
	self.INTERACT_TIMER_SHORT = 1
	self.INTERACT_TIMER_MEDIUM = 2
	self.INTERACT_TIMER_LONG = 4
	self.INTERACT_TIMER_CARRY = 1.5
	self.INTERACT_TIMER_CARRY_PAINTING = 1
	self.INTERACT_TIMER_CORPSE = 2
	self.MINIGAME_PICK_LOCK = "pick_lock"
	self.MINIGAME_CUT_FUSE = "cut_fuse"
	self.MINIGAME_REWIRE = "rewire"
	self.MINIGAME_REVIVE = "revive"
	self.MINIGAME_SELF_REVIE = "si_revive"
	self.MINIGAME_CC_ROULETTE = "roulette"

	self:_init_shared_multipliers()
	self:_init_shared_sounds()
	self:_init_interactions()
	self:_init_carry()
	self:_init_comwheels()
	self:_init_minigames()
end

function InteractionTweakData:_init_shared_multipliers()
	self.TIMER_MULTIPLIERS_GENERIC = {
		{
			category = "interaction",
			upgrade = "handyman_generic_speed_multiplier"
		}
	}
	self.TIMER_MULTIPLIERS_DYNAMITE = {
		{
			category = "interaction",
			upgrade = "saboteur_dynamite_speed_multiplier"
		}
	}
	self.TIMER_MULTIPLIERS_CROWBAR = {
		{
			category = "interaction",
			upgrade = "sapper_crowbar_speed_multiplier"
		}
	}
	self.TIMER_MULTIPLIERS_CORPSE = {
		{
			category = "interaction",
			upgrade = "predator_corpse_speed_multiplier"
		}
	}
	self.TIMER_MULTIPLIERS_CARRY = {
		{
			category = "interaction",
			upgrade = "strongback_carry_pickup_multiplier"
		}
	}
	self.TIMER_MULTIPLIERS_REWIRE = {
		{
			category = "interaction",
			upgrade = "handyman_rewire_speed_multipler"
		}
	}
end

function InteractionTweakData:_init_shared_sounds()
	self.LOCKPICK_SOUNDS = {
		dialog_success = "player_gen_lock_picked",
		dialog_enter = "player_gen_picking_lock",
		failed = "lock_fail",
		success = "success",
		dialog_fail = "player_gen_lockpick_fail",
		circles = {
			{
				mechanics = "lock_mechanics_a",
				lock = "lock_a"
			},
			{
				mechanics = "lock_mechanics_b",
				lock = "lock_b"
			},
			{
				mechanics = "lock_mechanics_c",
				lock = "lock_c"
			},
			{
				mechanics = "lock_mechanics_b",
				lock = "lock_b"
			}
		}
	}
	self.DYNAMITE_SOUNDS = {
		dialog_success = "player_gen_fuse_rigged",
		finish = "plant_dynamite_finish",
		dialog_enter = "player_gen_rigging_fuse",
		failed = "lock_fail",
		success = "success",
		tick = "lock_mechanics_a",
		start = "plant_dynamite_start",
		apply = "lock_a"
	}
	self.REWIRE_SOUNDS = {
		dialog_success = "player_gen_lock_picked",
		apply = "lock_a",
		dialog_enter = "player_gen_picking_lock",
		failed = "lock_fail",
		success = "success",
		tick = "lock_mechanics_a",
		dialog_fail = "player_gen_lockpick_fail"
	}
end

function InteractionTweakData:_init_interactions()
	self.temp_interact_box = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		timer = 1,
		interact_distance = 350
	}
	self.temp_interact_box_long = deep_clone(self.temp_interact_box)
	self.temp_interact_box_long.timer = 4
	self.copy_machine_smuggle = {
		icon = "equipment_thermite",
		text_id = "debug_interact_copy_machine",
		interact_distance = 305
	}
	self.grenade_crate = {
		icon = "equipment_ammo_bag",
		text_id = "hud_interact_grenade_crate_take_grenades",
		contour = "crate_loot_pickup",
		blocked_hint_sound = "no_more_grenades",
		action_text_id = "hud_action_taking_grenades",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.grenade_pickup_new = deep_clone(self.grenade_crate)
	self.grenade_pickup_new.start_active = true
	self.grenade_pickup_new.keep_active = true
	self.projectile_collect = deep_clone(self.grenade_crate)
	self.projectile_collect.force_update_position = true
	self.projectile_collect.start_active = false
	self.projectile_collect.keep_active = false
	self.grenade_crate_small = {
		icon = self.grenade_crate.icon,
		text_id = self.grenade_crate.text_id,
		contour = self.grenade_crate.contour,
		blocked_hint = self.grenade_crate.blocked_hint,
		blocked_hint_sound = self.grenade_crate.blocked_hint_sound,
		sound_start = self.grenade_crate.sound_start,
		sound_interupt = self.grenade_crate.sound_interupt,
		sound_done = self.grenade_crate.sound_done,
		action_text_id = self.grenade_crate.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.grenade_crate_big = {
		icon = self.grenade_crate.icon,
		text_id = self.grenade_crate.text_id,
		contour = self.grenade_crate.contour,
		blocked_hint = self.grenade_crate.blocked_hint,
		blocked_hint_sound = self.grenade_crate.blocked_hint_sound,
		sound_start = self.grenade_crate.sound_start,
		sound_interupt = self.grenade_crate.sound_interupt,
		sound_done = self.grenade_crate.sound_done,
		action_text_id = self.grenade_crate.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag = {
		icon = "equipment_ammo_bag",
		text_id = "hud_interact_ammo_bag_take_ammo",
		contour = "deployable",
		blocked_hint = "hint_full_ammo",
		blocked_hint_sound = "no_more_ammo",
		action_text_id = "hud_action_taking_ammo",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag_small = {
		icon = self.ammo_bag.icon,
		text_id = self.ammo_bag.text_id,
		contour = self.ammo_bag.contour,
		blocked_hint = self.ammo_bag.blocked_hint,
		blocked_hint_sound = self.ammo_bag.blocked_hint_sound,
		sound_start = self.ammo_bag.sound_start,
		sound_interupt = self.ammo_bag.sound_interupt,
		sound_done = self.ammo_bag.sound_done,
		action_text_id = self.ammo_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.ammo_bag_big = {
		icon = self.ammo_bag.icon,
		text_id = self.ammo_bag.text_id,
		contour = self.ammo_bag.contour,
		blocked_hint = self.ammo_bag.blocked_hint,
		blocked_hint_sound = self.ammo_bag.blocked_hint_sound,
		sound_start = self.ammo_bag.sound_start,
		sound_interupt = self.ammo_bag.sound_interupt,
		sound_done = self.ammo_bag.sound_done,
		action_text_id = self.ammo_bag.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.health_bag = {
		action_text_id = "hud_action_healing",
		blocked_hint = "hint_full_health",
		text_id = "hud_interact_doctor_bag_heal",
		blocked_hint_sound = "no_more_health",
		icon = "equipment_doctor_bag",
		contour = "deployable",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.health_bag_small = clone(self.health_bag)
	self.health_bag_big = clone(self.health_bag)
	self.health_bag_big.text_id = "hud_interact_hold_doctor_bag_heal"
	self.health_bag_big.timer = 0.2
	self.resupply_all_equipment = {
		start_active = true,
		keep_active = true,
		icon = self.ammo_bag_big.icon,
		text_id = "hud_interact_resupply_all",
		contour = self.ammo_bag_big.contour,
		timer = 0.5,
		blocked_hint = self.ammo_bag_big.blocked_hint,
		blocked_hint_sound = self.ammo_bag_big.blocked_hint_sound,
		sound_start = self.ammo_bag_big.sound_start,
		sound_interupt = self.ammo_bag_big.sound_interupt,
		sound_done = self.ammo_bag_big.sound_done,
		action_text_id = self.ammo_bag_big.action_text_id,
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.empty_interaction = {
		interact_distance = 0
	}
	self.driving_drive = {
		icon = "develop",
		text_id = "hud_int_driving_drive",
		timer = 1,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 500
	}
	self.driving_willy = {
		icon = "develop",
		text_id = "hud_int_driving_drive",
		timer = 1,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 200
	}
	self.foxhole = {
		icon = "develop",
		text_id = "hud_int_enter_foxhole",
		timer = 1,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 500,
		sound_start = "cvy_foxhole_start",
		sound_interupt = "cvy_foxhole_cancel",
		sound_done = "cvy_foxhole_finish"
	}
	self.main_menu_select_interaction = {
		text_id = "hud_menu_crate_select",
		interact_distance = 300,
		sound_done = "paper_shuffle"
	}
	self.interaction_ball = {
		icon = "develop",
		text_id = "debug_interact_interaction_ball",
		timer = 5,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "cft_hose_loop",
		sound_interupt = "cft_hose_cancel",
		sound_done = "cft_hose_end"
	}
	self.invisible_interaction_open = {
		icon = "develop",
		text_id = "hud_int_invisible_interaction_open",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		timer = 0.5
	}
	self.sewer_manhole = {
		icon = "develop",
		text_id = "debug_interact_sewer_manhole",
		timer = 3,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 200,
		equipment_text_id = "hud_interact_equipment_crowbar"
	}
	self.open_trunk = {
		icon = "develop",
		text_id = "debug_interact_open_trunk",
		timer = 0.5,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		axis = "x",
		action_text_id = "hud_action_opening_trunk",
		sound_start = "truck_back_door_opening",
		sound_done = "truck_back_door_open",
		sound_interupt = "stop_truck_back_door_opening"
	}
	self.take_gold_bar = {
		icon = "interaction_gold",
		text_id = "hud_take_gold_bar",
		start_active = true,
		sound_done = "gold_crate_drop",
		timer = self.INTERACT_TIMER_CARRY / 4,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.take_gold_bar_bag = {
		icon = "develop",
		text_id = "hud_take_gold_bar",
		action_text_id = "hud_action_taking_gold_bar",
		timer = self.INTERACT_TIMER_CARRY / 4,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		force_update_position = true,
		sound_start = "gold_crate_pickup",
		sound_interupt = "gold_crate_drop",
		sound_done = "gold_crate_drop"
	}
	self.gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_gold_bag",
		start_active = false,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		special_equipment_block = "gold_bag_equip",
		action_text_id = "hud_action_taking_gold"
	}
	self.requires_gold_bag = {
		icon = "interaction_gold",
		text_id = "debug_interact_requires_gold_bag",
		equipment_text_id = "debug_interact_equipment_requires_gold_bag",
		special_equipment = "gold_bag_equip",
		start_active = true,
		equipment_consume = true,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		axis = "x"
	}
	self.break_open = {
		icon = "develop",
		text_id = "hud_int_break_open",
		start_active = false
	}
	self.cut_fence = {
		text_id = "hud_int_hold_cut_fence",
		action_text_id = "hud_action_cutting_fence",
		timer = self.INTERACT_TIMER_SHORT,
		dot_limit = 0.8,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_start = "bar_cut_fence",
		sound_interupt = "bar_cut_fence_cancel",
		sound_done = "bar_cut_fence_finished"
	}
	self.use_flare = {
		text_id = "hud_int_use_flare",
		start_active = false,
		dot_limit = 0.8,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.disable_flare = deep_clone(self.use_flare)
	self.disable_flare.text_id = "hud_int_disable_flare"
	self.extinguish_flare = deep_clone(self.use_flare)
	self.extinguish_flare.text_id = "hud_int_estinguish_flare"
	self.extinguish_flare.contour = "interactable_danger"
	self.open_from_inside = {
		text_id = "hud_int_invisible_interaction_open",
		start_active = true,
		interact_distance = 100,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		axis = "x"
	}
	self.gen_pku_crowbar = {
		text_id = "hud_int_take_crowbar",
		special_equipment_block = "crowbar",
		sound_done = "crowbar_pickup"
	}
	self.crate_loot = {
		text_id = "hud_int_hold_crack_crate",
		action_text_id = "hud_action_cracking_crate",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "bar_open_crate",
		sound_interupt = "bar_open_crate_cancel",
		sound_done = "bar_open_crate_finished"
	}
	self.crate_loot_crowbar = deep_clone(self.crate_loot)
	self.crate_loot_crowbar.equipment_text_id = "hud_interact_equipment_crowbar"
	self.crate_loot_crowbar.special_equipment = "crowbar"
	self.crate_loot_crowbar.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CROWBAR
	self.crate_loot_crowbar.sound_start = "bar_crowbar"
	self.crate_loot_crowbar.sound_interupt = "bar_crowbar_cancel"
	self.crate_loot_crowbar.sound_done = "bar_crowbar_end"
	self.crate_loot_crowbar.start_active = true
	self.crate_loot_close = {
		text_id = "hud_int_hold_close_crate",
		action_text_id = "hud_action_closing_crate",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "bar_close_crate",
		sound_interupt = "bar_close_crate_cancel",
		sound_done = "bar_close_crate_finished"
	}
	self.player_zipline = {
		text_id = "hud_int_use_zipline"
	}
	self.bag_zipline = {
		text_id = "hud_int_bag_zipline"
	}
	self.crane_joystick_lift = {
		text_id = "hud_int_crane_lift",
		start_active = false
	}
	self.crane_joystick_right = {
		text_id = "hud_int_crane_right",
		start_active = false
	}
	self.crane_joystick_release = {
		text_id = "hud_int_crane_release",
		start_active = false
	}
	self.take_bank_door_keys = {
		start_active = true,
		text_id = "hud_int_take_door_keys"
	}
	self.hold_unlock_bank_door = {
		text_id = "hud_int_hold_unlock_door",
		action_text_id = "hud_int_action_unlocking_door",
		special_equipment = "door_key",
		equipment_text_id = "hud_int_need_door_keys",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = false,
		start_active = false
	}
	self.take_car_keys = {
		text_id = "hud_int_take_car_keys",
		sound_done = "sps_inter_keys_pickup"
	}
	self.unlock_car_01 = {
		text_id = "hud_int_hold_unlock_car",
		action_text_id = "hud_unlocking_car",
		special_equipment = "car_key_01",
		equipment_text_id = "hud_int_need_car_keys",
		equipment_consume = true,
		start_active = false,
		timer = 2,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "sps_inter_unlock_truck_start_loop",
		sound_interupt = "sps_inter_unlock_truck_stop_loop",
		sound_done = "sps_inter_unlock_truck_success"
	}
	self.unlock_car_02 = deep_clone(self.unlock_car_01)
	self.unlock_car_02.special_equipment = "car_key_02"
	self.unlock_car_02.sound_start = "sps_inter_unlock_truck_start_loop"
	self.unlock_car_02.sound_interupt = "sps_inter_unlock_truck_stop_loop"
	self.unlock_car_02.sound_done = "sps_inter_unlock_truck_success"
	self.unlock_car_03 = deep_clone(self.unlock_car_01)
	self.unlock_car_03.special_equipment = "car_key_03"
	self.unlock_car_03.sound_start = "sps_inter_unlock_truck_start_loop"
	self.unlock_car_03.sound_interupt = "sps_inter_unlock_truck_stop_loop"
	self.unlock_car_03.sound_done = "sps_inter_unlock_truck_success"
	self.push_button = {
		text_id = "hud_int_push_button",
		axis = "z"
	}
	self.search_files_false = {
		text_id = "hud_int_search_files",
		action_text_id = "hud_action_searching_files",
		axis = "x",
		contour = "interactable_icon",
		timer = 4.5,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 200,
		sound_start = "bar_shuffle_papers",
		sound_interupt = "bar_shuffle_papers_cancel",
		sound_done = "bar_shuffle_papers_finished"
	}
	self.hold_open = {
		text_id = "hud_int_invisible_interaction_open",
		action_text_id = "hud_action_open_slash_close",
		start_active = false,
		axis = "y",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.place_flare = {
		text_id = "hud_int_place_flare",
		start_active = false,
		dot_limit = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.answer_call = {
		text_id = "hud_int_hold_answer_call",
		action_text_id = "hud_action_answering_call",
		timer = 0.5,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.cas_take_unknown = {
		text_id = "hud_take_???",
		action_text_id = "hud_action_taking_???",
		timer = 2,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 100,
		start_active = false
	}
	self.hold_pku_intelligence = {
		text_id = "hud_int_pickup_intelligence",
		action_text_id = "hud_action_pickup_intelligence",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 150
	}
	self.piano_key_instant_01 = {
		text_id = "hud_play_key_01",
		interact_distance = self.SMALL_OBJECT_INTERACTION_DISTANCE,
		contour = "interactable_look_at"
	}
	self.piano_key_instant_02 = {
		text_id = "hud_play_key_02",
		interact_distance = self.SMALL_OBJECT_INTERACTION_DISTANCE,
		contour = "interactable_look_at"
	}
	self.piano_key_instant_03 = {
		text_id = "hud_play_key_03",
		interact_distance = self.SMALL_OBJECT_INTERACTION_DISTANCE,
		contour = "interactable_look_at"
	}
	self.piano_key_instant_04 = {
		text_id = "hud_play_key_04",
		interact_distance = self.SMALL_OBJECT_INTERACTION_DISTANCE,
		contour = "interactable_look_at"
	}
	self.open_door_instant = {
		text_id = "hud_open_door_instant",
		interact_distance = 200,
		sound_done = "door_open_generic"
	}
	self.hold_open_crate_tut = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 300,
		dot_limit = 0.8,
		sound_start = "camp_unpack_stuff",
		sound_done = "camp_unpacked"
	}
	self.open_crate_1 = {
		text_id = "hud_open_crate_2",
		action_text_id = "hud_action_opening_crate_2",
		interact_distance = 200,
		timer = self.INTERACT_TIMER_INSTA,
		start_active = true,
		loot_table = {
			"basic_crate_tier"
		},
		sound_done = "crate_open",
		delay_completed = 0.34,
		redirect = Idstring("melee")
	}
	self.open_crate_2 = deep_clone(self.open_crate_1)
	self.open_crate_2.loot_table = {
		"lockpick_crate_tier"
	}
	self.open_crate_2.redirect = nil
	self.open_crate_2.timer = self.INTERACT_TIMER_INSTA
	self.open_crate_2.legend_exit_text_id = "hud_legend_lockpicking_exit"
	self.open_crate_2.legend_interact_text_id = "hud_legend_lockpicking_interact"
	self.open_crate_2.minigame_bypass = {
		category = "interaction",
		special_equipment = "crowbar",
		upgrade = "sapper_lockpick_crate_bypass"
	}
	self.open_crate_2.timer = self.INTERACT_TIMER_VERY_SHORT
	self.open_crate_2.minigame_type = self.MINIGAME_PICK_LOCK
	self.open_crate_2.number_of_circles = 1
	self.open_crate_2.circle_rotation_speed = {
		240
	}
	self.open_crate_2.circle_rotation_direction = {
		1
	}
	self.open_crate_2.circle_difficulty = {
		0.85
	}
	self.open_crate_2.sounds = self.LOCKPICK_SOUNDS
	self.open_crate_2.sound_start = "crowbarcrate_open"
	self.open_crate_2.sound_done = "crate_open"
	self.open_crate_2.sound_interupt = "stop_crowbarcrate_open"
	self.open_army_crate = {
		text_id = "hud_open_army_crate",
		action_text_id = "hud_action_opening_army_crate",
		special_equipment = "crowbar",
		equipment_text_id = "hud_int_need_crowbar",
		equipment_consume = false,
		start_active = false,
		interact_distance = 250,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CROWBAR,
		loot_table = {
			"crowbar_crate_tier"
		},
		sound_start = "crowbarcrate_open",
		sound_done = "crate_open",
		sound_interupt = "stop_crowbarcrate_open"
	}
	self.open_crate_3 = deep_clone(self.open_army_crate)
	self.open_metalbox = {
		text_id = "hud_open_crate_2",
		action_text_id = "hud_action_opening_crate_2",
		interact_distance = 300,
		start_active = false
	}
	self.take_document = {
		text_id = "hud_take_document",
		interact_distance = 300,
		start_active = true,
		sound_done = "paper_shuffle"
	}
	self.take_documents = {
		text_id = "hud_take_documents",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 300,
		start_active = true,
		sound_done = "paper_shuffle"
	}
	self.open_window = {
		text_id = "hud_open_window",
		action_text_id = "hud_action_opening_window",
		interact_distance = 300,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		axis = "y",
		start_active = false
	}
	self.take_thermite = {
		text_id = "hud_take_thermite",
		action_text_id = "hud_action_taking_thermite",
		special_equipment_block = "thermite",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_event = "cvy_pick_up_thermite"
	}
	self.set_up_radio = {
		text_id = "hud_int_set_up_radio",
		action_text_id = "hud_action_set_up_radio",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.anwser_radio = {
		text_id = "hud_int_answer_radio",
		action_text_id = "hud_action_answering_radio",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.tune_radio = deep_clone(self.anwser_radio)
	self.tune_radio.text_id = "hud_sii_tune_radio"
	self.tune_radio.action_text_id = "hud_action_sii_tune_radio"
	self.tune_radio.timer = self.INTERACT_TIMER_MEDIUM
	self.tune_radio.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	self.untie_zeppelin = {
		text_id = "hud_untie_zeppelin",
		action_text_id = "hud_action_untying_zeppelin",
		interact_distance = 300,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.take_tank_grenade = {
		text_id = "hud_take_tank_grenade",
		action_text_id = "hud_action_taking_tank_grenade",
		special_equipment_block = "tank_grenade",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.replace_tank_grenade = {
		text_id = "hud_replace_tank_grenade",
		action_text_id = "hud_action_replacing_tank_grenade",
		special_equipment = "tank_grenade",
		equipment_text_id = "hud_no_tank_grenade",
		equipment_consume = true,
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.take_tools = {
		text_id = "hud_take_tools",
		action_text_id = "hud_action_taking_tools",
		special_equipment_block = "repair_tools",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_done = "pickup_tools"
	}
	self.take_gas_tank = {
		text_id = "hud_take_gas_tank",
		action_text_id = "hud_action_taking_gas_tank",
		special_equipment_block = "gas_tank",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.hold_remove_latch = {
		text_id = "hud_int_remove_latch",
		action_text_id = "hud_action_remove_latch",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		axis = "y"
	}
	self.replace_gas_tank = {
		text_id = "hud_replace_gas_tank",
		action_text_id = "hud_action_replacing_gas_tank",
		special_equipment = "gas_tank",
		equipment_text_id = "hud_no_gas_tank",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.open_toolbox = {
		text_id = "hud_open_toolbox",
		action_text_id = "hud_action_opening_toolbox",
		start_active = false,
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 300,
		sound_start = "toolbox_interact_start",
		sound_done = "toolbox_interact_stop",
		sound_interupt = "toolbox_interact_stop"
	}
	self.take_safe_key = {
		text_id = "hud_take_safe_key",
		special_equipment_block = "safe_key",
		interact_distance = 300,
		start_active = true,
		sound_done = "sto_pick_up_key"
	}
	self.unlock_the_safe = {
		text_id = "hud_unlock_safe",
		action_text_id = "hud_action_unlocking_safe",
		special_equipment = "safe_key",
		equipment_text_id = "hud_no_safe_key",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.pour_acid = {
		text_id = "hud_pour_acid",
		action_text_id = "hud_action_pouring_acid",
		special_equipment = "acid",
		equipment_text_id = "hud_int_need_acid",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.take_acid = {
		text_id = "hud_take_acid",
		action_text_id = "hud_action_taking_acid",
		special_equipment_block = "acid",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.take_sps_briefcase = {
		text_id = "hud_take_briefcase",
		action_text_id = "hud_action_taking_briefcase",
		special_equipment_block = "briefcase",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_done = "sps_pick_up_briefcase"
	}
	self.take_thermite = {
		text_id = "hud_int_take_thermite",
		special_equipment_block = "thermite",
		start_active = true,
		sound_event = "cvy_pick_up_thermite"
	}
	self.open_lid = {
		text_id = "hud_int_open_lid",
		start_active = true,
		sound_event = "brh_holding_cells_door_lid"
	}
	self.pku_codemachine_part_01 = {
		text_id = "hud_take_codemachine_part_01",
		action_text_id = "hud_action_taking_codemachine_part_01",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.pku_codemachine_part_02 = {
		text_id = "hud_take_codemachine_part_02",
		action_text_id = "hud_action_taking_codemachine_part_03",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.pku_codemachine_part_03 = {
		text_id = "hud_take_codemachine_part_03",
		action_text_id = "hud_action_taking_codemachine_part_03",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.pku_codemachine_part_04 = {
		text_id = "hud_take_codemachine_part_04",
		action_text_id = "hud_action_taking_codemachine_part_04",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.take_gold_bar_mold = {
		text_id = "hud_take_gold_bar_mold",
		action_text_id = "hud_action_taking_gold_bar_mold",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		special_equipment_block = "gold_bar_mold",
		start_active = true
	}
	self.place_mold = {
		text_id = "hud_place_mold",
		action_text_id = "hud_action_placing_mold",
		special_equipment = "gold_bar_mold",
		equipment_text_id = "hud_int_need_gold_bar_mold",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.place_tank_shell = {
		text_id = "hud_place_tank_shell",
		action_text_id = "hud_action_placing_tank_shell",
		special_equipment = "tank_shell",
		equipment_text_id = "hud_int_need_tank_shell",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.graveyard_check_tank = {
		text_id = "hud_graveyard_check_tank",
		action_text_id = "hud_action_graveyard_check_tank",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		special_equipment_block = "gold_bar_mold"
	}
	self.graveyard_drag_pilot_1 = {
		text_id = "hud_graveyard_drag_pilot_1",
		action_text_id = "hud_action_graveyard_drag_pilot_1",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		special_equipment_block = "gold_bar_mold"
	}
	self.search_radio_parts = {
		text_id = "hud_search_radio_parts",
		action_text_id = "hud_action_searching_radio_parts",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		special_equipment_block = "radio_parts"
	}
	self.replace_radio_parts = {
		text_id = "hud_replace_radio_parts",
		action_text_id = "hud_action_replacing_radio_parts",
		special_equipment = "radio_parts",
		equipment_text_id = "hud_int_need_radio_parts",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.take_blacksmith_tong = {
		text_id = "hud_take_blacksmith_tong",
		start_active = false,
		special_equipment_block = "blacksmith_tong"
	}
	self.turret_m2 = {
		text_id = "hud_turret_m2",
		action_text_id = "hud_action_mounting_turret",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop",
		axis = "x"
	}
	self.turret_m2_placement = {
		text_id = "hud_turret_placement",
		action_text_id = "hud_action_placing_turret",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		carry_consume = true,
		required_carry = "turret_m2_gun",
		carry_text_id = "needs_carry_turret_m2_gun",
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop",
		axis = "x"
	}
	self.turret_flak_88 = {
		text_id = "hud_turret_88",
		action_text_id = "hud_action_mounting_turret",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop",
		interact_distance = 400,
		axis = "z"
	}
	self.turret_flakvierling = {
		text_id = "hud_int_hold_turret_flakvierling",
		action_text_id = "hud_action_turret_flakvierling",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop",
		interact_distance = 400
	}
	self.start_ladle = {
		start_active = "false",
		text_id = "hud_start_ladle"
	}
	self.stop_ladle = {
		start_active = "false",
		text_id = "hud_stop_ladle"
	}
	self.cool_gold_bar = {
		text_id = "hud_cool_gold_bar",
		action_text_id = "hud_action_cooling_gold_bar",
		special_equipment = "gold_bar",
		equipment_text_id = "hud_int_need_gold_bar",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.pour_iron = {
		text_id = "hud_pour_iron",
		start_active = false
	}
	self.open_chest = {
		text_id = "hud_open_chest",
		action_text_id = "hud_action_opening_chest",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.open_radio_hatch = {
		text_id = "hud_open_radio_hatch",
		action_text_id = "hud_action_opening_radio_hatch",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.open_tank_hatch = {
		text_id = "hud_open_tank_hatch",
		action_text_id = "hud_action_opening_tank_hatch",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.open_hatch = {
		text_id = "hud_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.break_open_door = {
		text_id = "hud_break_open_door",
		action_text_id = "hud_action_breaking_opening_door",
		special_equipment = "crowbar",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CROWBAR,
		equipment_text_id = "hud_int_need_crowbar",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = false,
		start_active = false,
		axis = "x"
	}
	self.open_vault_door = {
		text_id = "hud_open_vault_door",
		action_text_id = "hud_action_opening_vault_door",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.breach_open_door = {
		text_id = "hud_breach_door",
		action_text_id = "hud_action_breaching_door",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.take_blow_torch = {
		text_id = "hud_take_blow_torch",
		special_equipment_block = "blow_torch",
		equipment_consume = false,
		start_active = false
	}
	self.fill_blow_torch = {
		text_id = "hud_fill_blow_torch",
		action_text_id = "hud_action_filling_blow_torch",
		special_equipment = "blow_torch",
		special_equipment_block = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = false,
		start_active = false
	}
	self.cut_vault_bars = {
		text_id = "hud_cut_vault_bars",
		action_text_id = "hud_action_cutting_vault_bars",
		special_equipment = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch_fuel",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = true
	}
	self.take_torch_tank = {
		text_id = "hud_take_torch_tank",
		action_text_id = "hud_action_taking_torch_tank",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.take_turret_m2_gun = {
		text_id = "hud_take_turret_m2_gun",
		action_text_id = "hud_action_taking_turret_m2_gun",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop"
	}
	self.take_turret_m2_gun_enabled = {
		text_id = "hud_take_turret_m2_gun",
		action_text_id = "hud_action_taking_turret_m2_gun",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true,
		sound_start = "turret_pick_up",
		sound_interupt = "turret_pick_up_stop"
	}
	self.take_money_print_plate = {
		text_id = "hud_take_money_print_plate",
		action_text_id = "hud_action_taking_money_print_plate",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.signal_light = {
		text_id = "hud_signal_light",
		start_active = true,
		axis = "z"
	}
	self.take_safe_keychain = {
		text_id = "hud_take_safe_keychain",
		start_active = true,
		special_equipment_block = "safe_keychain",
		equipment_consume = false
	}
	self.unlock_the_safe_keychain = {
		text_id = "hud_unlock_safe",
		action_text_id = "hud_action_unlocking_safe",
		special_equipment = "safe_keychain",
		equipment_text_id = "hud_no_safe_keychain",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = false,
		start_active = false
	}
	self.take_gear = {
		text_id = "hud_take_gear",
		action_text_id = "hud_action_taking_gear",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		can_interact_in_civilian = true
	}
	self.activate_elevator = {
		text_id = "hud_activate_elevator",
		start_active = false,
		interact_distance = 250
	}
	self.lift_trap_door = {
		text_id = "hud_lift_trap_door",
		start_active = false,
		interact_distance = 300
	}
	self.open_drop_pod = {
		text_id = "hud_open_drop_pod",
		action_text_id = "hud_action_opening_drop_pod",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 300,
		sound_start = "open_drop_pod_start",
		sound_interupt = "open_drop_pod_interrupt"
	}
	self.pour_lava_ladle_01 = {
		text_id = "hud_pour_lava",
		action_text_id = "hud_action_pouring_lava",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250
	}
	self.open_fusebox = {
		text_id = "hud_open_fusebox",
		action_text_id = "hud_action_opening_fusebox",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250
	}
	self.activate_trigger = {
		text_id = "hud_activate_trigger",
		action_text_id = "hud_action_activating_trigger",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250
	}
	self.take_parachute = {
		text_id = "hud_take_parachute",
		start_active = false,
		interact_distance = 250
	}
	self.take_bolt_cutter = {
		text_id = "hud_take_bolt_cutter",
		start_active = false,
		interact_distance = 250,
		special_equipment_block = "bolt_cutter"
	}
	self.cut_chain_bolt_cutter = {
		text_id = "hud_cut_chain",
		action_text_id = "hud_action_cutting_chain",
		special_equipment = "bolt_cutter",
		equipment_text_id = "hud_int_need_bolt_cutter",
		equipment_consume = false,
		start_active = false,
		timer = 1
	}
	self.take_bonds = {
		text_id = "hud_take_bonds",
		action_text_id = "hud_action_taking_bonds",
		start_active = false,
		timer = 1,
		blocked_hint = "carry_block"
	}
	self.take_tank_crank = {
		text_id = "hud_take_tank_crank",
		start_active = false,
		interact_distance = 250,
		special_equipment_block = "tank_crank"
	}
	self.start_the_tank = {
		text_id = "hud_start_tank",
		action_text_id = "hud_action_starting_tank",
		start_active = false,
		interact_distance = 250,
		timer = 5
	}
	self.turn_searchlight = {
		text_id = "hud_turn_searchlight",
		action_text_id = "hud_action_turning_searchlight",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		sound_start = "searchlight_interaction_loop_start",
		sound_done = "searchlight_interaction_loop_stop",
		sound_interupt = "searchlight_interaction_loop_stop"
	}
	self.take_dynamite_bag = {
		text_id = "hud_int_take_dynamite",
		action_text_id = "hud_action_taking_dynamite",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 250,
		icon = "equipment_dynamite",
		special_equipment_block = "dynamite_bag",
		sound_done = "pickup_dynamite"
	}
	self.take_cable_instant = {
		text_id = "hud_take_cable",
		action_text_id = "hud_action_taking_cable",
		interact_distance = 200,
		force_update_position = true
	}
	self.take_cable = {
		text_id = "hud_take_cable",
		action_text_id = "hud_action_taking_cable",
		interact_distance = 200,
		timer = 2,
		force_update_position = true,
		sound_done = "el_cable_connected",
		sound_start = "el_cable_connect",
		sound_interupt = "el_cable_connect_stop"
	}
	self.open_cargo_door = {
		text_id = "hud_int_open_cargo_door",
		action_text_id = "hud_action_opening_cargo_door",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 200
	}
	self.close_cargo_door = deep_clone(self.open_cargo_door)
	self.close_cargo_door.text_id = "hud_int_close_cargo_door"
	self.close_cargo_door.action_text_id = "hud_action_closing_cargo_door"
	self.hold_couple_wagon = {
		text_id = "hud_int_hold_couple_wagon",
		action_text_id = "hud_action_coupling_wagon",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 300
	}
	self.hold_decouple_wagon = deep_clone(self.hold_couple_wagon)
	self.hold_decouple_wagon.text_id = "hud_int_hold_decouple_wagon"
	self.hold_decouple_wagon.action_text_id = "hud_action_decoupling_wagon"
	self.hold_pull_lever = {
		text_id = "hud_int_hold_pull_lever",
		action_text_id = "hud_action_pulling_lever",
		start_active = false,
		interact_distance = 200,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		dot_limit = 0.8,
		force_update_position = true,
		sound_start = "rail_switch_interaction_loop_start",
		sound_done = "rail_switch_interaction_loop_stop",
		sound_interupt = "rail_switch_interaction_loop_stop"
	}
	self.hold_get_gear = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 300
	}
	self.hold_get_gear_short_range = {
		text_id = "hud_int_hold_get_gear",
		action_text_id = "hud_action_get_gear",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 300
	}
	self.hold_remove_blocker = {
		text_id = "hud_int_hold_remove_blocker",
		action_text_id = "hud_action_removing_blocker",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		axis = "y",
		sound_start = "loco_blocker_remove_start",
		sound_done = "loco_blocker_remove_stop",
		sound_interupt = "loco_blocker_remove_stop"
	}
	self.hold_open_hatch = {
		text_id = "hud_open_hatch",
		action_text_id = "hud_action_opening_hatch",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_done = "open_hatch_done"
	}
	self.take_landmines = {
		text_id = "hud_take_landmines",
		action_text_id = "hud_action_taking_landmines",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		sound_start = "cvy_pick_up_mine",
		sound_interupt = "cvy_pick_up_mine_cancel_01",
		sound_done = "cvy_pick_up_mine_finish_01"
	}
	self.place_landmine = {
		text_id = "hud_place_landmine",
		action_text_id = "hud_action_placing_landmine",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		equipment_text_id = "hint_no_landmines",
		special_equipment = "landmine",
		equipment_consume = true
	}
	self.hold_start_locomotive = {
		text_id = "hud_int_signal_driver",
		action_text_id = "hud_action_signaling_driver",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.free_radio_tehnician = {
		text_id = "hud_untie_tehnician",
		action_text_id = "hud_action_untying_technician",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_distance = 250,
		sound_start = "untie_rope_loop_interact_start",
		sound_done = "untie_rope_interact_end",
		sound_interupt = "untie_rope_loop_interrupt"
	}
	self.hold_pull_down_ladder = {
		text_id = "hud_int_pull_down_ladder",
		action_text_id = "hud_action_pull_down_ladder",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "ladder_pull",
		interact_distance = 250
	}
	self.detonate_the_dynamite = {
		text_id = "hud_int_detonate_the_dynamite",
		action_text_id = "hud_action_detonate_the_dynamite",
		timer = 0,
		sound_done = "bridge_switch_start",
		interact_distance = 250
	}
	self.detonate_the_dynamite_panel = {
		text_id = "hud_int_detonate_the_dynamite",
		action_text_id = "hud_action_detonate_the_dynamite",
		timer = 0,
		sound_done = "bridge_switch_start",
		interact_distance = 120,
		start_active = false
	}
	self.generic_press_panel = deep_clone(self.detonate_the_dynamite_panel)
	self.generic_press_panel.text_id = "hud_hold_open_barrier"
	self.generic_press_panel.action_text_id = "hud_action_opening_barrier"
	self.hold_call_boat_driver = {
		text_id = "hud_int_hold_call_boat_driver",
		action_text_id = "hud_action_hold_call_boat_driver",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "",
		interact_distance = 250
	}
	self.cut_cage_lock = {
		text_id = "hud_cut_cage_lock",
		action_text_id = "hud_action_cutting_cage_lock",
		special_equipment = "blow_torch_fuel",
		equipment_text_id = "hud_int_need_blow_torch_fuel",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		start_active = false
	}
	self.vhc_move_wagon = {
		text_id = "hud_int_press_move_wagon",
		force_update_position = true
	}
	self.move_crane = {
		text_id = "hud_int_press_move_crane"
	}
	self.search_scrap_parts = {
		text_id = "hud_search_scrap_parts",
		action_text_id = "hud_action_searching_scrap_parts",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = true
	}
	self.hold_attach_cable = {
		text_id = "hud_int_hold_attach_cable",
		action_text_id = "hud_action_attaching_cable",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.hold_detach_cable = {
		text_id = "hud_int_hold_detach_cable",
		action_text_id = "hud_action_detaching_cable",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "cutting_cable_loop_start",
		sound_interupt = "cutting_cable_loop_interrupt",
		sound_done = "cutting_cable_loop_stop"
	}
	self.take_code_book = {
		text_id = "hud_take_code_book",
		action_text_id = "hud_action_taking_code_book",
		special_equipment_block = "code_book",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "codebook_pickup_done"
	}
	self.take_code_book_active = deep_clone(self.take_code_book)
	self.take_code_book_active.start_active = true
	self.take_code_book_empty = {
		text_id = "hud_take_code_book",
		action_text_id = "hud_action_taking_code_book",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "codebook_pickup_done"
	}
	self.hold_ignite_flag = {
		text_id = "hud_int_hold_ignite_flag",
		action_text_id = "hud_action_igniting_flag",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		axis = "y",
		sound_start = "flag_burn_interaction_start",
		sound_interupt = "flag_burn_interaction_interrupt",
		sound_done = "flag_burn_interaction_success"
	}
	self.train_yard_open_door = {
		text_id = "hud_open_door_instant",
		start_active = false,
		interact_distance = 250,
		sound_done = "generic_wood_door_opened"
	}
	self.hold_take_canister = {
		text_id = "hud_int_hold_take_canister",
		action_text_id = "hud_action_taking_canister",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		blocked_hint = "hud_hint_carry_block",
		sound_done = "canister_pickup"
	}
	self.hold_take_crate_canisters = {
		text_id = "hud_int_hold_take_crate_canisters",
		action_text_id = "hud_action_taking_crate_canisters",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.hold_take_empty_canister = deep_clone(self.hold_take_canister)
	self.hold_take_empty_canister.text_id = "hud_int_hold_empty_take_canister"
	self.hold_take_empty_canister.action_text_id = "hud_action_taking_empty_canister"
	self.hold_take_empty_canister.special_equipment_block = "empty_fuel_canister"
	self.hold_place_canister = {
		text_id = "hud_int_hold_place_canister",
		action_text_id = "hud_action_placing_canister",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "fuel_canister",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_done = "canister_pickup"
	}
	self.hold_fill_canister = {
		text_id = "hud_int_hold_fill_canister",
		action_text_id = "hud_action_filling_canister",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "empty_fuel_canister",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "canister_fill_loop_start",
		sound_interupt = "canister_fill_loop_stop",
		sound_done = "canister_fill_loop_stop"
	}
	self.hold_fill_jeep = {
		text_id = "hud_int_hold_fill_jeep",
		action_text_id = "hud_action_filling_jeep",
		equipment_text_id = "hud_hint_no_gasoline",
		special_equipment = "gas_x4",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_start = "car_refuel_start",
		sound_interupt = "car_refuel_stop",
		sound_done = "car_refuel_stop"
	}
	self.hold_fill_barrel_gasoline = deep_clone(self.hold_fill_jeep)
	self.hold_fill_barrel_gasoline.text_id = "hud_int_hold_fill_barrel_gasoline"
	self.hold_fill_barrel_gasoline.action_text_id = "hud_action_filling_barrel"
	self.hold_fill_barrel_gasoline.equipment_text_id = "hud_hint_no_gasoline"
	self.hold_fill_barrel_gasoline.special_equipment = "fuel_canister"
	self.give_tools_franz = {
		text_id = "hud_give_tools_franz",
		action_text_id = "hud_action_giving_tools_franz",
		special_equipment = "repair_tools",
		equipment_text_id = "hud_no_tools_franz",
		equipment_consume = true,
		start_active = false,
		dot_limit = 0.7,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "toolbox_pass"
	}
	self.hold_reinforce_door = {
		text_id = "hud_int_hold_reinforce_door",
		action_text_id = "hud_action_reinforcing_door",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		sound_start = "reinforce_door_interact",
		sound_done = "reinforce_door_success",
		sound_interupt = "reinforce_door_interact_interrupt"
	}
	self.hold_take_recording_device = {
		text_id = "hud_int_hold_take_recording_device",
		action_text_id = "hud_action_taking_recording_device",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "recording_device_pickup"
	}
	self.hold_place_recording_device = {
		text_id = "hud_int_hold_place_recording_device",
		action_text_id = "hud_action_placing_recording_device",
		equipment_text_id = "hud_hint_no_recording_device",
		special_equipment = "recording_device",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_done = "recording_device_placement"
	}
	self.hold_connect_cable = {
		text_id = "hud_int_hold_connect_cable",
		action_text_id = "hud_action_connecting_cable",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.press_collect_reward = {
		text_id = "hud_int_collect_reward",
		start_active = false,
		interact_distance = 500
	}
	self.start_recording = {
		text_id = "hud_int_start_recording",
		start_active = false
	}
	self.hold_place_codebook = {
		text_id = "hud_int_hold_place_codebook",
		action_text_id = "hud_action_placing_codebook",
		equipment_text_id = "hud_hint_no_codebook",
		special_equipment = "code_book",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_done = "codebook_pickup_done"
	}
	self.hold_repair_fusebox = {
		text_id = "hud_int_hold_repair_fusebox",
		action_text_id = "hud_action_repairing_fusebox",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		axis = "x",
		sound_start = "fusebox_repair_interact_start",
		sound_interupt = "fusebox_repair_interrupt",
		sound_done = "fusebox_repair_success"
	}
	self.hold_place_codemachine = {
		text_id = "hud_int_hold_place_codemachine",
		action_text_id = "hud_action_placing_codemachine",
		equipment_text_id = "hud_hint_no_codemachine",
		special_equipment = "enigma",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_done = "recording_device_placement"
	}
	self.pour_gas_generator = {
		text_id = "hud_pour_gas_generator",
		action_text_id = "hud_action_pouring_gas_generator",
		equipment_text_id = "hud_hint_no_canister",
		special_equipment = "fuel_canister",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true,
		sound_start = "canister_fill_loop_start",
		sound_interupt = "canister_fill_loop_stop"
	}
	self.start_generator = {
		text_id = "hud_start_generator",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.load_shell = {
		text_id = "hud_load_shell",
		action_text_id = "hud_action_loading_shell",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		interact_dont_interupt_on_distance = true
	}
	self.load_shell_use_carry = deep_clone(self.load_shell)
	self.load_shell_use_carry.required_carry = {
		"flak_shell",
		"flak_shell_explosive",
		"flak_shell_shot_explosive"
	}
	self.load_shell_use_carry.carry_text_id = "needs_carry_flak_shell"
	self.load_shell_use_carry.carry_consume = true
	self.place_shell_use_carry = deep_clone(self.load_shell)
	self.place_shell_use_carry.text_id = "hud_place_shell"
	self.place_shell_use_carry.action_text_id = "hud_action_placing_shell"
	self.place_shell_use_carry.required_carry = {
		"flak_shell",
		"flak_shell_explosive",
		"flak_shell_shot_explosive"
	}
	self.place_shell_use_carry.carry_text_id = "needs_carry_flak_shell"
	self.place_shell_use_carry.carry_consume = true
	self.pku_empty_bucket = {
		text_id = "hud_int_take_empty_bucket",
		special_equipment_block = "empty_bucket",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.pku_fill_bucket = {
		text_id = "hud_int_fill_bucket",
		equipment_text_id = "hud_hint_need_empty_bucket",
		special_equipment_block = "full_bucket",
		special_equipment = "empty_bucket",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true
	}
	self.hold_give_full_bucket = {
		text_id = "hud_int_hold_give_full_bucket",
		action_text_id = "hud_action_giving_full_bucket",
		equipment_text_id = "hud_hint_need_full_bucket",
		special_equipment = "full_bucket",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false,
		equipment_consume = true
	}
	self.hold_contact_mrs_white = {
		text_id = "hud_int_hold_contact_mrs_white",
		action_text_id = "hud_action_contacting_mrs_white",
		timer = self.INTERACT_TIMER_VERY_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		start_active = false
	}
	self.hold_contact_boat_driver = deep_clone(self.hold_contact_mrs_white)
	self.hold_contact_boat_driver.text_id = "hud_int_hold_contact_boat_driver"
	self.hold_contact_boat_driver.action_text_id = "hud_action_contacting_boat_driver"
	self.hold_request_dynamite_airdrop = deep_clone(self.hold_contact_mrs_white)
	self.hold_request_dynamite_airdrop.text_id = "hud_int_hold_request_dynamite_airdrop"
	self.hold_request_dynamite_airdrop.action_text_id = "hud_action_requesting_airdrop"
	self.take_code_machine_part = {
		text_id = "hud_take_code_machine_part",
		start_active = true,
		sound_done = "recording_device_placement"
	}
	self.hold_start_plane = {
		text_id = "hud_hold_start_plane",
		action_text_id = "hud_action_starting_plane",
		start_active = false,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.take_enigma = {
		text_id = "hud_take_enigma",
		action_text_id = "hud_action_taking_enigma",
		special_equipment_block = "enigma",
		start_active = false,
		timer = 3,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_done = "enigma_machine_pickup"
	}
	self.wake_up_spy = {
		text_id = "hud_wake_up_spy",
		action_text_id = "hud_action_waking_up_spy",
		start_active = false,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		dot_limit = 0.7
	}
	self.hold_open_barrier = {
		text_id = "hud_hold_open_barrier",
		action_text_id = "hud_action_opening_barrier",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.shut_off_valve = {
		text_id = "hud_shut_off_valve",
		action_text_id = "hud_action_shutting_off_valve",
		start_active = false,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "open_drop_pod_start",
		sound_interupt = "open_drop_pod_interrupt",
		sound_done = "elevator_switch"
	}
	self.turn_on_valve = {
		text_id = "hud_turn_on_valve",
		action_text_id = "hud_action_turning_on_valve",
		start_active = false,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "disconnect_hose_start",
		sound_interupt = "disconnect_hose_interrupt",
		sound_done = "disconnect_hose_interrupt"
	}
	self.destroy_valve = {
		text_id = "hud_desroy_valve",
		action_text_id = "hud_action_destroying_valve",
		start_active = false,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "gas_controller_destroy_interaction_start",
		sound_interupt = "gas_controller_destroy_interaction_stop",
		sound_done = "gas_controller_destroy"
	}
	self.replace_flag = {
		text_id = "hud_replace_flag",
		action_text_id = "hud_action_replacing_flag",
		start_active = false,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		dot_limit = 0.7,
		sound_done = "flag_replace"
	}
	self.open_container = {
		text_id = "hud_open_container",
		action_text_id = "hud_action_opening_container",
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.close_container = deep_clone(self.open_container)
	self.close_container.text_id = "hud_close_container"
	self.close_container.action_text_id = "hud_action_closing_container"
	self.press_take_dogtags = {
		start_active = true,
		sound_done = "dogtags_pickup",
		text_id = "hud_int_press_take_dogtags",
		interact_distance = self.SMALL_OBJECT_INTERACTION_DISTANCE,
		timer = self.INTERACT_TIMER_INSTA
	}
	self.hold_take_dogtags = deep_clone(self.press_take_dogtags)
	self.hold_take_dogtags.text_id = "hud_int_hold_take_dogtags"
	self.hold_take_dogtags.action_text_id = "hud_action_taking_dogtags"
	self.hold_take_dogtags.timer = self.INTERACT_TIMER_VERY_SHORT
	self.hold_take_dogtags.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	self.press_take_loot = {
		sound_done = "pickup_tools",
		start_active = true,
		text_id = "hud_int_press_take_loot",
		timer = self.INTERACT_TIMER_INSTA
	}
	self.hold_take_loot = deep_clone(self.press_take_loot)
	self.hold_take_loot.text_id = "hud_int_hold_take_loot"
	self.hold_take_loot.action_text_id = "hud_action_taking_loot"
	self.hold_take_loot.timer = self.INTERACT_TIMER_VERY_SHORT
	self.hold_take_loot.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	self.regular_cache_box = {
		text_id = "hud_int_regular_cache_box",
		action_text_id = "hud_action_taking_cache_loot",
		sound_done = "pickup_tools",
		start_active = true
	}
	self.disconnect_hose = {
		text_id = "hud_disconnect_hose",
		action_text_id = "hud_action_disconnecting_hose",
		start_active = false,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "disconnect_hose_start",
		sound_interupt = "disconnect_hose_interrupt",
		sound_done = "disconnect_hose_success"
	}
	self.push_truck_bridge = {
		text_id = "hud_push_truck_bridge",
		action_text_id = "hud_action_pushing_truck_bridge",
		start_active = false,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.connect_tank_truck = {
		text_id = "hud_connect_tank_truck",
		action_text_id = "hud_action_connecting_tank_truck",
		start_active = false,
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "fuel_tank_connect",
		sound_interupt = "fuel_tank_connect_stop"
	}
	self.set_fire_barrel = {
		text_id = "hud_interact_consumable_mission",
		action_text_id = "hud_action_consumable_mission",
		start_active = false,
		timer = 3,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "flag_burn_interaction_start",
		sound_interupt = "flag_burn_interaction_interrupt",
		sound_done = "barrel_fire_start"
	}
	self.open_door = {
		text_id = "hud_open_door_instant",
		interact_distance = 200,
		axis = "y"
	}
	self.open_truck_trunk = {
		text_id = "hud_open_truck_trunk",
		action_text_id = "hud_opening_truck_trunk",
		interact_distance = 200,
		start_active = false,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		axis = "y",
		sound_start = "truck_back_door_opening",
		sound_done = "truck_back_door_open"
	}
	self.folder_outlaw = {
		start_active = true,
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		text_id = "hud_interact_consumable_mission",
		action_text_id = "hud_action_consumable_mission",
		blocked_hint = "hud_hint_consumable_mission_block",
		reward_type = "outlaw",
		sound_done = "consumable_mission_unlocked"
	}
	self.request_recording_device = {
		text_id = "hud_request_recording_device",
		action_text_id = "hud_action_requesting_recording_device",
		start_active = true,
		timer = 2
	}
	self.thermite = {
		icon = "equipment_thermite",
		text_id = "debug_interact_thermite",
		equipment_text_id = "debug_interact_equipment_thermite",
		special_equipment = "thermite",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_consume = true,
		interact_distance = 300,
		timer = 3
	}
	self.apply_thermite_paste = {
		text_id = "hud_int_hold_ignite_thermite_paste",
		action_text_id = "hud_action_ignite_thermite_paste",
		special_equipment = "thermite_paste",
		equipment_text_id = "hud_int_need_thermite_paste",
		equipment_consume = true,
		start_active = false,
		contour = "interactable_icon",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "bar_thermal_lance_fix",
		sound_interupt = "bar_thermal_lance_fix_cancel",
		sound_done = "bar_thermal_lance_fix_finished"
	}
	self.ignite_thermite = {
		text_id = "hud_ignite_thermite",
		action_text_id = "hud_action_igniting_thermite",
		special_equipment = "thermite",
		equipment_text_id = "hud_int_need_thermite",
		equipment_consume = true,
		start_active = false,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC
	}
	self.use_thermite = {
		text_id = "hud_int_hold_use_thermite",
		action_text_id = "hud_action_hold_using_thermite",
		special_equipment = "thermite",
		equipment_text_id = "hud_int_need_thermite_cvy",
		equipment_consume = true,
		start_active = true,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		sound_start = "cvy_place_thermite",
		sound_interupt = "cvy_place_thermite_cancel",
		sound_done = "cvy_place_thermite_cancel"
	}
	self.take_portable_radio = {
		text_id = "hud_int_take_portable_radio",
		action_text_id = "hud_action_taking_portable_radio",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		interact_distance = 250,
		special_equipment_block = "portable_radio"
	}
	self.plant_portable_radio = {
		text_id = "hud_plant_portable_radio",
		action_text_id = "hud_action_planting_portable_radio",
		interact_distance = 250,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_GENERIC,
		equipment_text_id = "hint_no_portable_radio",
		special_equipment = "portable_radio",
		start_active = false,
		equipment_consume = true,
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.dynamite_x1_pku = {
		text_id = "hud_int_take_dynamite",
		action_text_id = "hud_action_taking_dynamite",
		timer = self.INTERACT_TIMER_SHORT,
		interact_distance = 220,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		icon = "equipment_dynamite",
		special_equipment_block = "dynamite",
		sound_done = "pickup_dynamite"
	}
	self.mine_pku = {
		text_id = "hud_int_take_mine",
		action_text_id = "hud_action_taking_mine",
		special_equipment_block = "landmine",
		timer = self.INTERACT_TIMER_SHORT,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		start_active = true,
		sound_start = "cvy_pick_up_mine",
		sound_interupt = "cvy_pick_up_mine_cancel_01",
		sound_done = "cvy_pick_up_mine_finish_01"
	}
	self.dynamite_x4_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x4_pku.special_equipment_block = "dynamite_x4"
	self.dynamite_x5_pku = deep_clone(self.dynamite_x1_pku)
	self.dynamite_x5_pku.special_equipment_block = "dynamite_x5"
	self.plant_dynamite = {
		text_id = "hud_plant_dynamite",
		action_text_id = "hud_action_planting_dynamite",
		interact_distance = 220,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		equipment_text_id = "hint_no_dynamite",
		special_equipment = "dynamite",
		start_active = false,
		equipment_consume = true,
		axis = "z",
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.plant_dynamite_x5 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x5.special_equipment = "dynamite_x5"
	self.plant_dynamite_x4 = deep_clone(self.plant_dynamite)
	self.plant_dynamite_x4.special_equipment = "dynamite_x4"
	self.plant_dynamite_from_bag = deep_clone(self.plant_dynamite)
	self.plant_dynamite_from_bag.equipment_consume = false
	self.plant_dynamite_from_bag.special_equipment = "dynamite_bag"
	self.plant_mine = {
		text_id = "hud_plant_mine",
		action_text_id = "hud_action_planting_mine",
		interact_distance = 220,
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		equipment_text_id = "hint_no_mine",
		special_equipment = "landmine",
		start_active = false,
		equipment_consume = true,
		axis = "z",
		sound_start = "cvy_plant_mine_loop_01",
		sound_done = "cvy_plant_mine_finish_01",
		sound_interupt = "cvy_plant_mine_cancel_01"
	}
	self.defuse_mine = deep_clone(self.plant_mine)
	self.defuse_mine.text_id = "hud_defuse_mine"
	self.defuse_mine.action_text_id = "hud_action_defusinging_mine"
	self.defuse_mine.equipment_text_id = nil
	self.defuse_mine.special_equipment = nil
	self.defuse_mine.equipment_consume = nil
	self.defuse_mine.contour = "interactable_danger"
	self.rig_dynamite = {
		text_id = "hud_int_rig_dynamite",
		action_text_id = "hud_action_rig_dynamite",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		interact_distance = 280,
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing",
		special_equipment = "dynamite",
		equipment_consume = true
	}
	self.plant_dynamite_bag = {
		text_id = "hud_plant_dynamite_bag",
		action_text_id = "hud_action_planting_dynamite_bag",
		interact_distance = 250,
		timer = self.INTERACT_TIMER_MEDIUM,
		equipment_text_id = "hint_no_dynamite_bag",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		special_equipment = "dynamite_bag",
		start_active = false,
		equipment_consume = true,
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.saboteur_turret = {
		text_id = "hud_saboteur_turret",
		action_text_id = "hud_action_saboteur_turret",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_DYNAMITE,
		requires_upgrade = {
			category = "interaction",
			upgrade = "saboteur_boobytrap_turret"
		},
		dot_limit = 0.95,
		interact_distance = 65,
		force_update_position = true,
		axis = "y",
		sound_start = "dynamite_placing",
		sound_done = "dynamite_placed",
		sound_interupt = "stop_dynamite_placing"
	}
	self.revive = {
		icon = "interaction_help",
		text_id = "hud_interact_revive",
		action_text_id = "hud_action_reviving",
		contour_preset = "teammate_downed",
		contour_preset_selected = "teammate_downed_selected",
		start_active = false,
		allowed_while_perservating = true,
		interact_distance = 300,
		dot_limit = 0.75,
		axis = "z",
		timer = 5,
		upgrade_timer_multipliers = {
			{
				category = "interaction",
				upgrade = "medic_revive_speed_multiplier"
			}
		},
		player_say_interacting = "player_gen_revive_start"
	}
	self.intimidate = {
		icon = "equipment_cable_ties",
		text_id = "debug_interact_intimidate",
		equipment_text_id = "debug_interact_equipment_cable_tie",
		action_text_id = "hud_action_cable_tying",
		start_active = false,
		equipment_consume = true,
		no_contour = true,
		timer = 2
	}
	self.pickpocket_steal = {
		text_id = "hud_int_skill_pickpocket",
		action_text_id = "hud_action_skill_pickpocketing",
		timer = self.INTERACT_TIMER_SHORT,
		no_contour = true,
		stealth_only = true,
		requires_upgrade = {
			category = "interaction",
			upgrade = "pickpocket_greed_steal"
		},
		interaction_obj = Idstring("Spine")
	}
	self.repair = {
		text_id = "hud_repair",
		action_text_id = "hud_action_repairing",
		special_equipment = "repair_tools",
		equipment_text_id = "hud_no_tools",
		equipment_consume = false,
		start_active = false,
		timer = self.INTERACT_TIMER_LONG
	}
	self.dead = {
		icon = "interaction_help",
		text_id = "hud_interact_revive",
		start_active = false,
		interact_distance = 300
	}
	self.free = {
		icon = "interaction_free",
		text_id = "debug_interact_free",
		start_active = false,
		interact_distance = 300,
		no_contour = true,
		timer = 1,
		sound_start = "bar_rescue",
		sound_interupt = "bar_rescue_cancel",
		sound_done = "bar_rescue_finished",
		action_text_id = "hud_action_freeing"
	}
	self.hostage_trade = {
		icon = "interaction_trade",
		text_id = "debug_interact_trade",
		start_active = true,
		timer = 3,
		requires_upgrade = {
			category = "player",
			upgrade = "hostage_trade"
		},
		action_text_id = "hud_action_trading",
		contour_preset = "generic_interactable",
		contour_preset_selected = "generic_interactable_selected"
	}
	self.hostage_move = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_move",
		start_active = true,
		timer = 1,
		action_text_id = "hud_action_standing_up",
		no_contour = true,
		interaction_obj = Idstring("Spine")
	}
	self.hostage_stay = {
		icon = "interaction_trade",
		text_id = "debug_interact_hostage_stay",
		start_active = true,
		timer = 0.4,
		action_text_id = "hud_action_getting_down",
		no_contour = true,
		interaction_obj = Idstring("Spine2")
	}
	self.hostage_convert = {
		icon = "develop",
		text_id = "hud_int_hostage_convert",
		blocked_hint = "convert_enemy_failed",
		timer = 1.5,
		requires_upgrade = {
			category = "player",
			upgrade = "convert_enemies"
		},
		upgrade_timer_multiplier = {
			category = "player",
			upgrade = "convert_enemies_interaction_speed_multiplier"
		},
		action_text_id = "hud_action_converting_hostage",
		no_contour = true
	}
	self.activate_switch = {
		icon = "develop",
		text_id = "hud_activate_switch",
		action_text_id = "hud_action_activate_switch",
		axis = "y",
		interact_distance = 200,
		timer = 2.335
	}
	self.activate_switch_easy = deep_clone(self.activate_switch)
	self.activate_switch_medium = deep_clone(self.activate_switch)
end

function InteractionTweakData:_init_carry()
	self.gold_pile = {
		icon = "interaction_gold",
		text_id = "hud_interact_gold_pile_take_money",
		action_text_id = "hud_action_taking_gold",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = true,
		sound_done = "gold_crate_drop"
	}
	self.gold_pile_inactive = deep_clone(self.gold_pile)
	self.gold_pile_inactive.start_active = false
	self.gold_pile_inactive_repeating = deep_clone(self.gold_pile_inactive)
	self.gold_pile_inactive_repeating.keep_active = true
	self.carry_drop_gold = {
		icon = "interaction_gold",
		text_id = "hud_interact_gold_pile_take_money",
		action_text_id = "hud_action_taking_gold",
		timer = self.INTERACT_TIMER_CARRY,
		distance = self.CARRY_DROP_INTERACTION_DISTANCE,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		force_update_position = true,
		sound_start = "gold_crate_pickup",
		sound_interupt = "gold_crate_drop",
		sound_done = "gold_crate_drop"
	}
	self.hold_take_wine_crate = {
		text_id = "hud_take_wine_crate",
		action_text_id = "hud_action_taking_wine_crate",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = true,
		interact_distance = 250
	}
	self.take_tank_shell = {
		text_id = "hud_take_tank_shell",
		action_text_id = "hud_action_taking_tank_shell",
		special_equipment_block = "tank_shell",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false
	}
	self.take_contraband_jewelry = {
		text_id = "hud_take_contraband_jewelry",
		action_text_id = "hud_action_taking_contraband_jewelry",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = true
	}
	self.carry_drop = {
		text_id = "hud_int_hold_grab_the_bag",
		action_text_id = "hud_action_grabbing_bag",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		force_update_position = true
	}
	self.take_spiked_wine = {
		text_id = "hud_take_spiked_wine",
		action_text_id = "hud_action_taking_spiked_wine",
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false
	}
	self.take_painting = {
		text_id = "hud_take_painting",
		action_text_id = "hud_action_taking_painting",
		timer = self.INTERACT_TIMER_MEDIUM,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		interact_distance = 250,
		start_active = false,
		sound_start = "sto_painting",
		sound_interupt = "sto_painting_cancel",
		sound_done = "sto_painting_finish"
	}
	self.take_painting_active = {
		text_id = "hud_take_painting",
		action_text_id = "hud_action_taking_painting",
		timer = self.INTERACT_TIMER_CARRY_PAINTING,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		interact_distance = self.CARRY_DROP_INTERACTION_DISTANCE,
		start_active = true,
		sound_done = "sto_pick_up_painting"
	}
	self.take_tank_shells = {
		text_id = "hud_take_tank_shells",
		action_text_id = "hud_action_taking_tank_shells",
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false,
		interact_distance = 250,
		timer = 5
	}
	self.hold_take_cigar_crate = deep_clone(self.hold_take_wine_crate)
	self.hold_take_cigar_crate.text_id = "hud_take_cigar_crate"
	self.hold_take_cigar_crate.action_text_id = "hud_action_taking_cigar_crate"
	self.hold_take_chocolate_box = deep_clone(self.hold_take_wine_crate)
	self.hold_take_chocolate_box.text_id = "hud_take_chocolate_box"
	self.hold_take_chocolate_box.action_text_id = "hud_action_taking_chocolate_box"
	self.hold_take_crucifix = deep_clone(self.hold_take_wine_crate)
	self.hold_take_crucifix.text_id = "hud_take_crucifix"
	self.hold_take_crucifix.action_text_id = "hud_action_taking_crucifix"
	self.hold_take_baptismal_font = deep_clone(self.hold_take_wine_crate)
	self.hold_take_baptismal_font.text_id = "hud_take_baptismal_font"
	self.hold_take_baptismal_font.action_text_id = "hud_action_taking_baptismal_font"
	self.hold_take_religious_figurine = deep_clone(self.hold_take_wine_crate)
	self.hold_take_religious_figurine.text_id = "hud_take_religious_figurine"
	self.hold_take_religious_figurine.action_text_id = "hud_action_taking_religious_figurine"
	self.hold_take_candelabrum = deep_clone(self.hold_take_wine_crate)
	self.hold_take_candelabrum.text_id = "hud_take_candelabrum"
	self.hold_take_candelabrum.action_text_id = "hud_action_taking_candelabrum"
	self.carry_drop_flak_shell = {
		text_id = "hud_take_flak_shell",
		action_text_id = "hud_action_taking_flak_shell",
		timer = self.INTERACT_TIMER_CARRY,
		distance = self.CARRY_DROP_INTERACTION_DISTANCE,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		force_update_position = true,
		sound_start = "flakshell_take",
		sound_done = "flakshell_packed",
		sound_interupt = "flakshell_take_stop"
	}
	self.carry_drop_tank_shell = deep_clone(self.carry_drop_flak_shell)
	self.carry_drop_tank_shell.text_id = "hud_take_tank_shell"
	self.carry_drop_tank_shell.action_text_id = "hud_action_taking_tank_shell"
	self.carry_drop_tank_shell.sound_start = "flakshell_take"
	self.carry_drop_tank_shell.sound_done = "flakshell_packed"
	self.carry_drop_tank_shell.sound_interupt = "flakshell_take_stop"
	self.carry_drop_barrel = deep_clone(self.carry_drop_flak_shell)
	self.carry_drop_barrel.text_id = "hud_take_barrel"
	self.carry_drop_barrel.action_text_id = "hud_action_taking_barrel"
	self.take_ladder = {
		text_id = "hud_take_ladder",
		action_text_id = "hud_action_taking_ladder",
		interact_distance = 250,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false,
		sound_start = "ladder_pickup_loop_start",
		sound_interupt = "ladder_pickup_complete",
		sound_done = "ladder_pickup_complete"
	}
	self.take_plank = {
		text_id = "hud_take_plank",
		action_text_id = "hud_action_taking_plank",
		interact_distance = 350,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false,
		sound_done = "take_plank"
	}
	self.take_plank_bag = deep_clone(self.take_plank)
	self.take_plank_bag.interact_distance = self.CARRY_DROP_INTERACTION_DISTANCE
	self.take_plank_bag.force_update_position = true
	self.take_plank_bag.start_active = true
	self.take_flak_shell = {
		text_id = "hud_take_flak_shell",
		action_text_id = "hud_action_taking_flak_shell",
		interact_distance = 300,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false,
		sound_start = "flakshell_take",
		sound_done = "flakshell_packed",
		sound_interupt = "flakshell_take_stop"
	}
	self.take_flak_shell_bag = deep_clone(self.take_flak_shell)
	self.take_flak_shell_bag.force_update_position = true
	self.take_flak_shell_bag.start_active = true
	self.take_flak_shell_bag.timer = self.INTERACT_TIMER_CARRY
	self.take_flak_shell_pallete = {
		text_id = "hud_take_flak_shell_pallete",
		action_text_id = "hud_action_taking_flak_shell_pallete",
		interact_distance = 250,
		timer = self.INTERACT_TIMER_CARRY,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CARRY,
		start_active = false
	}
	self.eat_candy = {
		text_id = "hud_interact_eat_candy",
		interact_distance = self.POWERUP_INTERACTION_DISTANCE
	}
	self.corpse_dispose = {
		icon = "develop",
		text_id = "hud_int_dispose_corpse",
		timer = self.INTERACT_TIMER_CORPSE,
		dot_limit = 0.7,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CORPSE,
		action_text_id = "hud_action_disposing_corpse",
		no_contour = true,
		stealth_only = true,
		player_say_interacting = "player_gen_carry_body"
	}
	self.carry_spy = {
		text_id = "hud_carry_spy",
		action_text_id = "hud_action_carring_spy",
		start_active = false,
		timer = self.INTERACT_TIMER_CORPSE,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CORPSE,
		dot_limit = 0.7,
		player_say_interacting = "or_op_spy_picked_up"
	}
	self.carry_drop_spy = deep_clone(self.carry_drop)
	self.carry_drop_spy.text_id = "hud_carry_spy"
	self.carry_drop_spy.action_text_id = "hud_action_carring_spy"
	self.carry_drop_spy.timer = self.INTERACT_TIMER_CORPSE
	self.carry_drop_spy.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_CORPSE
	self.carry_drop_spy.dot_limit = 0.7
	self.carry_drop_spy.player_say_interacting = "or_op_spy_picked_up"
end

function InteractionTweakData:_init_comwheels()
	local com_wheel_color = Color(1, 0.8, 0)

	local function com_wheel_clbk(say_target_id, default_say_id, post_prefix, past_prefix, waypoint_tech)
		local character = managers.network:session():local_peer()._character
		local nationality = CriminalsManager.comm_wheel_callout_from_nationality(character)
		local snd = post_prefix .. nationality .. past_prefix
		local text = nil
		local player = managers.player:player_unit()

		if not alive(player) then
			return
		end

		local target, target_nationality = player:movement():current_state():teammate_aimed_at_by_player()

		if target ~= nil then
			local target_char = CriminalsManager.comm_wheel_callout_from_nationality(target_nationality)

			if target_char == nationality and nationality ~= "amer" then
				target_char = "amer"
			elseif target_char == nationality and nationality == "amer" then
				target_char = "brit"
			end

			if nationality == "russian" then
				nationality = "rus"
			end

			text = say_target_id .. "~" .. target

			player:sound():say(nationality .. "_call_" .. target_char, true, true)
			player:sound():queue_sound("comm_wheel", post_prefix .. nationality .. past_prefix, nil, true)
		else
			text = default_say_id

			player:sound():say(post_prefix .. nationality .. past_prefix, true, true)
		end

		managers.chat:send_message(ChatManager.GAME, "Player", text)
	end

	self.com_wheel = {
		icon = "develop",
		color = com_wheel_color,
		text_id = "debug_interact_temp_interact_box",
		wheel_radius_inner = 120,
		wheel_radius_outer = 150,
		text_padding = 25,
		cooldown = 1.5,
		options = {
			{
				text_id = "com_wheel_yes",
				id = "yes",
				icon = "comm_wheel_yes",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_yes",
					"com_wheel_say_yes",
					"com_",
					"_yes"
				}
			},
			{
				text_id = "com_wheel_no",
				id = "no",
				icon = "comm_wheel_no",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_no",
					"com_wheel_say_no",
					"com_",
					"_no"
				}
			},
			{
				text_id = "com_wheel_found_it",
				id = "found_it",
				icon = "comm_wheel_found_it",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_found_it",
					"com_wheel_say_found_it",
					"com_",
					"_found"
				}
			},
			{
				text_id = "com_wheel_not_here",
				id = "not_here",
				icon = "comm_wheel_not_here",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_not_here",
					"com_wheel_say_not_here",
					"com_",
					"_notfound"
				}
			},
			{
				text_id = "com_wheel_follow_me",
				id = "follow_me",
				icon = "comm_wheel_follow_me",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_follow_me",
					"com_wheel_say_follow_me",
					"com_",
					"_follow"
				}
			},
			{
				text_id = "com_wheel_wait",
				id = "wait",
				icon = "comm_wheel_wait",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_wait",
					"com_wheel_say_wait",
					"com_",
					"_wait"
				}
			},
			{
				text_id = "com_wheel_assistance",
				id = "assistance",
				icon = "comm_wheel_assistance",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_assistance",
					"com_wheel_say_assistance",
					"com_",
					"_help"
				}
			},
			{
				text_id = "com_wheel_enemy",
				id = "enemy",
				icon = "comm_wheel_enemy",
				color = com_wheel_color,
				clbk = com_wheel_clbk,
				clbk_data = {
					"com_wheel_target_say_enemy",
					"com_wheel_say_enemy",
					"com_",
					"_enemy"
				}
			}
		}
	}
	self.carry_wheel = {
		icon = "develop",
		text_id = "debug_interact_temp_interact_box",
		cooldown = 0.35,
		options = {
			{
				multiplier = 2,
				text_id = "hud_carry_drop_all",
				id = "drop_all",
				icon = "comm_wheel_follow_me",
				clbk = function ()
					managers.player:drop_all_carry()
				end
			}
		}
	}
end

function InteractionTweakData:_init_minigames()
	self.minigame_icons = {
		pick_lock = "player_panel_status_lockpick",
		cut_fuse = "equipment_panel_dynamite"
	}
	self.si_revive = {
		icon = "develop",
		text_id = "skill_interaction_revive",
		action_text_id = "skill_interaction_revive",
		axis = "y",
		minigame_type = self.MINIGAME_SELF_REVIE,
		interact_distance = 200,
		number_of_circles = 1,
		circle_rotation_speed = {
			300
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.sii_tune_radio_easy = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 1,
		circle_rotation_speed = {
			220
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.84
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.sii_tune_radio_medium = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 2,
		circle_rotation_speed = {
			220,
			250
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.84,
			0.88
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.sii_tune_radio = {
		icon = "develop",
		text_id = "hud_sii_tune_radio",
		action_text_id = "hud_action_sii_tune_radio",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			220,
			250,
			280
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.84,
			0.88,
			0.92
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.sii_play_recordings = deep_clone(self.sii_tune_radio)
	self.sii_play_recordings.text_id = "hud_int_play_recordings"
	self.sii_play_recordings.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings.axis = "z"
	self.sii_change_channel = deep_clone(self.sii_play_recordings)
	self.sii_change_channel.text_id = "hud_int_change_channel"
	self.sii_change_channel.action_text_id = "hud_action_changing_channel"
	self.sii_play_recordings_easy = deep_clone(self.sii_tune_radio_easy)
	self.sii_play_recordings_easy.text_id = "hud_int_play_recordings"
	self.sii_play_recordings_easy.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings_easy.axis = "z"
	self.sii_play_recordings_medium = deep_clone(self.sii_tune_radio_medium)
	self.sii_play_recordings_medium.text_id = "hud_int_play_recordings"
	self.sii_play_recordings_medium.action_text_id = "hud_action_playing_recordings"
	self.sii_play_recordings_medium.axis = "z"
	self.sii_replay_last_message = deep_clone(self.sii_play_recordings)
	self.sii_replay_last_message.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message.action_text_id = "hud_action_replaying_message"
	self.sii_replay_last_message_easy = deep_clone(self.sii_play_recordings_easy)
	self.sii_replay_last_message_easy.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message_easy.action_text_id = "hud_action_replaying_message"
	self.sii_replay_last_message_medium = deep_clone(self.sii_play_recordings_medium)
	self.sii_replay_last_message_medium.text_id = "hud_int_replay_last_message"
	self.sii_replay_last_message_medium.action_text_id = "hud_action_replaying_message"
	self.sii_test = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		interact_distance = 500,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		}
	}
	self.sii_lockpick_easy = {
		minigame_type = self.MINIGAME_PICK_LOCK,
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		interact_distance = 200,
		number_of_circles = 1,
		circle_rotation_speed = {
			220
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.88
		},
		sounds = self.LOCKPICK_SOUNDS,
		loot_table = {
			"lockpick_crate_tier"
		}
	}
	self.sii_lockpick_easy_y_direction = deep_clone(self.sii_lockpick_easy)
	self.sii_lockpick_easy_y_direction.axis = "y"
	self.sii_lockpick_medium = {
		interact_distance = 200,
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		action_text_id = "hud_action_sii_lockpicking",
		text_id = "hud_sii_lockpick",
		icon = "develop",
		number_of_circles = 2,
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		minigame_type = self.MINIGAME_PICK_LOCK,
		circle_rotation_speed = {
			220,
			250
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.88,
			0.9
		},
		sounds = self.LOCKPICK_SOUNDS,
		loot_table = {
			"lockpick_crate_tier"
		}
	}
	self.sii_lockpick_medium_y_direction = deep_clone(self.sii_lockpick_medium)
	self.sii_lockpick_medium_y_direction.axis = "y"
	self.sii_lockpick_hard = {
		icon = "develop",
		text_id = "hud_sii_lockpick",
		action_text_id = "hud_action_sii_lockpicking",
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			220,
			250,
			280
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.88,
			0.9,
			0.92
		},
		sounds = self.LOCKPICK_SOUNDS,
		loot_table = {
			"lockpick_crate_tier"
		}
	}
	self.sii_lockpick_hard_y_direction = deep_clone(self.sii_lockpick_hard)
	self.sii_lockpick_hard_y_direction.axis = "y"
	self.picklock_door = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			160,
			180,
			190
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.picklock_door_easy = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 1,
		circle_rotation_speed = {
			160
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.picklock_door_medium = {
		icon = "develop",
		text_id = "hud_picklock_door",
		action_text_id = "hud_action_picklock_door",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 2,
		circle_rotation_speed = {
			160,
			180
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.93
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.picklock_window_easy = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 1,
		circle_rotation_speed = {
			200
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.85
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.picklock_window_medium = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 2,
		circle_rotation_speed = {
			200,
			230
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.85,
			0.9
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.picklock_window = {
		icon = "develop",
		text_id = "hud_picklock_window",
		action_text_id = "hud_action_picklock_window",
		axis = "y",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			200,
			230,
			260
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.85,
			0.9,
			0.95
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.call_mrs_white_easy = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 1,
		circle_rotation_speed = {
			200
		},
		circle_rotation_direction = {
			1
		},
		circle_difficulty = {
			0.9
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.call_mrs_white_medium = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 2,
		circle_rotation_speed = {
			200,
			220
		},
		circle_rotation_direction = {
			1,
			-1
		},
		circle_difficulty = {
			0.9,
			0.92
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.call_mrs_white = {
		icon = "develop",
		text_id = "hud_call_mrs_white",
		action_text_id = "hud_action_call_mrs_white",
		axis = "z",
		interact_distance = 200,
		minigame_type = self.MINIGAME_PICK_LOCK,
		number_of_circles = 3,
		circle_rotation_speed = {
			200,
			220,
			240
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.92,
			0.94
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.lockpick_cargo_door = deep_clone(self.open_cargo_door)
	self.lockpick_cargo_door.timer = self.INTERACT_TIMER_INSTA
	self.lockpick_cargo_door.minigame_type = self.MINIGAME_PICK_LOCK
	self.lockpick_cargo_door.number_of_circles = 1
	self.lockpick_cargo_door.circle_rotation_speed = {
		210,
		240,
		270
	}
	self.lockpick_cargo_door.circle_rotation_direction = {
		1,
		-1,
		1
	}
	self.lockpick_cargo_door.circle_difficulty = {
		0.84,
		0.87,
		0.9
	}
	self.lockpick_cargo_door.sounds = self.LOCKPICK_SOUNDS
	self.minigame_lockpicking_base = {
		interact_distance = 220,
		legend_exit_text_id = "hud_legend_lockpicking_exit",
		action_text_id = "hud_action_lockpicking",
		text_id = "hud_int_pick_lock",
		number_of_circles = 4,
		legend_interact_text_id = "hud_legend_lockpicking_interact",
		minigame_type = self.MINIGAME_PICK_LOCK,
		circle_rotation_speed = {
			240,
			260,
			280,
			300
		},
		circle_rotation_direction = {
			1,
			-1,
			1,
			-1
		},
		circle_difficulty = {
			0.84,
			0.88,
			0.91,
			0.94
		},
		sounds = self.LOCKPICK_SOUNDS
	}
	self.minigame_fusecutting_base = {
		minigame_type = self.MINIGAME_CUT_FUSE,
		text_id = "hud_int_cut_fuse",
		action_text_id = "hud_action_cutting_fuse",
		legend_interact_text_id = "hud_legend_fusecutting_interact",
		interact_distance = 240,
		circle_rotation_speed = 240,
		circle_difficulty = 0.13,
		circle_difficulty_mul = 0.83,
		circle_difficulty_deviation = {
			0.7,
			1.1
		},
		cut_timers = {
			90,
			80,
			70,
			60,
			50,
			45,
			40,
			35,
			30
		},
		max_cuts = 9,
		sounds = self.DYNAMITE_SOUNDS
	}
	self.minigame_fusecutting_dynamite_bag = deep_clone(self.minigame_fusecutting_base)
	self.minigame_fusecutting_dynamite_bag.equipment_text_id = "hint_no_dynamite_bag"
	self.minigame_fusecutting_dynamite_bag.special_equipment = "dynamite_bag"
	self.minigame_fusecutting_dynamite_bag.equipment_consume = true
	self.minigame_rewire_base = {
		minigame_type = self.MINIGAME_REWIRE,
		text_id = "hud_int_rewire",
		action_text_id = "hud_action_rewiring",
		legend_interact_text_id = "hud_legend_rewiring_interact",
		interact_distance = 220,
		fuse_radius = 256,
		fuse_walls = 8,
		fuse_gap_size = 0.1,
		fuse_rotation_speed = 160,
		sounds = self.REWIRE_SOUNDS,
		node_types = {
			dead = 2,
			trap = 2,
			bend = 5,
			line = 1
		},
		node_count_x = 3,
		node_count_y = 3,
		speed = {
			2.6,
			2.6,
			2.6,
			2.6,
			2.6
		}
	}
	self.rewire_fuse_pane = deep_clone(self.hold_attach_cable)
	self.rewire_fuse_pane.text_id = "hud_rewire_fuse_pane"
	self.rewire_fuse_pane.action_text_id = "hud_action_rewire_fuse_pane"
	self.rewire_fuse_pane.axis = "y"
	self.rewire_fuse_pane.timer = self.INTERACT_TIMER_LONG
	self.rewire_fuse_pane.upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_REWIRE
	self.rewire_fuse_pane.sound_done = "el_cable_connected"
	self.rewire_fuse_pane.sound_start = "el_cable_connect"
	self.rewire_fuse_pane.sound_interupt = "el_cable_connect_stop"
	self.rewire_fuse_pane.interact_distance = 200
	self.rewire_fuse_pane_easy = deep_clone(self.rewire_fuse_pane)
	self.rewire_fuse_pane_medium = deep_clone(self.rewire_fuse_pane)
	self.rewire_fuse_pane_hard = deep_clone(self.rewire_fuse_pane)
	self.activate_burners = {
		interact_distance = 200,
		action_text_id = "hud_action_activate_burners",
		text_id = "hud_activate_burners",
		axis = "y",
		sound_done = "el_cable_connected",
		sound_interupt = "el_cable_connect_stop",
		sound_start = "el_cable_connect",
		timer = self.INTERACT_TIMER_LONG,
		upgrade_timer_multipliers = self.TIMER_MULTIPLIERS_REWIRE
	}
	self.activate_burners_easy = deep_clone(self.activate_burners)
	self.activate_burners_easy.timer = self.INTERACT_TIMER_SHORT
	self.activate_burners_medium = deep_clone(self.activate_burners)
	self.activate_burners_medium.timer = self.INTERACT_TIMER_MEDIUM
	self.minigame_cc_roulette = {
		minigame_type = self.MINIGAME_CC_ROULETTE,
		text_id = "hud_test_minigame_cc_roulette",
		action_text_id = "hud_action_test_minigame_cc_roulette",
		axis = "y",
		circle_rotation_speed = 400,
		sounds = self.LOCKPICK_SOUNDS
	}
end
