VehicleTweakData = VehicleTweakData or class()
VehicleTweakData.AI_TELEPORT_DISTANCE = 2000
VehicleTweakData.FADE_DISTANCE = 3800
VehicleTweakData.FADE_DISTANCE_START = 3800

function VehicleTweakData:init(tweak_data)
	self:_init_data_jeep_willy()
	self:_init_data_kubelwagen()
	self:_init_data_truck()
	self:_init_data_foxhole()
end

function VehicleTweakData:_init_data_jeep_willy()
	self.jeep_willy = {
		unit = "units/vehicles/willy_jeep/fps_vehicle_jeep_willy",
		name = "hud_vehicle_jeep",
		hud_label_offset = 150,
		animations = {
			passenger_back_right = "drive_kubelwagen_back_right",
			driver = "drive_kubelwagen_driver",
			vehicle_id = "kubelwagen",
			passenger_back_left = "drive_kubelwagen_back_left",
			passenger_front = "drive_kubelwagen_passanger"
		},
		sound = {
			horn_start = "kubel_horn_start",
			engine_start = "muscle_engine_start",
			horn_stop = "kubel_horn_stop",
			broken_engine = "kubel_engine_break",
			engine_sound_event = "muscle",
			longitudal_slip_treshold = 0.8,
			lateral_slip_treshold = 0.35,
			bump_treshold = 8,
			engine_rpm_rtpc = "car_falcogini_rpm",
			engine_speed_rtpc = "car_falcogini_speed",
			hit_enemy = "car_hit_body_01",
			hit_rtpc = "TRD_hit",
			hit = "car_hits_something",
			bump_locator = "anim_tire_front_left",
			bump_rtpc = "TRD_bump",
			bump = "car_bumper_01",
			slip_locator = "anim_tire_front_left",
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			door_close = "car_door_open",
			gear_shift = "gear_shift"
		},
		seats = {
			driver = {
				next_seat = "passenger_front",
				driving = true,
				name = "driver"
			},
			passenger_front = {
				allow_shooting = true,
				next_seat = "passenger_back_right",
				driving = false,
				has_shooting_mode = false,
				name = "passenger_front"
			},
			passenger_back_right = {
				allow_shooting = true,
				next_seat = "passenger_back_left",
				driving = false,
				has_shooting_mode = false,
				name = "passenger_back_right"
			},
			passenger_back_left = {
				allow_shooting = true,
				next_seat = "driver",
				driving = false,
				has_shooting_mode = false,
				name = "passenger_back_left"
			}
		},
		loot_points = {
			loot = {
				name = "loot"
			}
		},
		repair_point = "v_repair_engine",
		trunk_point = "interact_trunk",
		damage = {
			max_health = 1250
		},
		max_speed = 160,
		max_rpm = 8000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 4,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0.2, 2.5)
	}
end

function VehicleTweakData:_init_data_kubelwagen()
	self.kubelwagen = {
		unit = "units/vanilla/vehicles/fps_vehicle_kubelwagen/fps_vehicle_kubelwagen",
		name = "hud_vehicle_kubelwagen",
		hud_label_offset = 150,
		waypoint_hud_icon = "waypoint_special_vehicle_kugelwagen",
		waypoint_map_icon = "map_waypoint_map_kugelwagen",
		animations = {
			passenger_back_right = "drive_kubelwagen_back_right",
			driver = "drive_kubelwagen_driver",
			vehicle_id = "kubelwagen",
			passenger_back_left = "drive_kubelwagen_back_left",
			passenger_front = "drive_kubelwagen_passanger"
		},
		sound = {
			engine_stop = "kubel_final_engine_stop",
			engine_start = "kubel_final_engine_start",
			horn_start = "kubel_horn_start",
			broken_engine = "kubel_engine_break",
			horn_stop = "kubel_horn_stop",
			engine_sound_event = "kubel_final_engine",
			longitudal_slip_treshold = 0.8,
			lateral_slip_treshold = 0.35,
			bump_treshold = 8,
			engine_rpm_rtpc = "TRD",
			engine_speed_rtpc = "TRD_speed",
			hit_enemy = "car_hit_body_01",
			hit_rtpc = "TRD_hit",
			hit = "car_hits_something",
			bump_locator = "anim_tire_front_left",
			bump_rtpc = "TRD_bump",
			bump = "car_bumper_01",
			slip_locator = "anim_tire_front_left",
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			door_close = "car_door_open",
			gear_shift = "gear_shift"
		},
		seats = {
			driver = {
				allow_shooting = false,
				next_seat = "passenger_front",
				driving = true,
				has_shooting_mode = false,
				name = "driver",
				camera_limits = {
					50,
					45
				}
			},
			passenger_front = {
				allow_shooting = true,
				next_seat = "passenger_back_right",
				driving = false,
				has_shooting_mode = false,
				name = "passenger_front",
				shooting_pos = Vector3(40, -20, 50),
				camera_limits = {
					90,
					45
				}
			},
			passenger_back_right = {
				allow_shooting = false,
				next_seat = "passenger_back_left",
				driving = false,
				has_shooting_mode = true,
				name = "passenger_back_right",
				shooting_pos = Vector3(30, -20, 50),
				camera_limits = {
					90,
					45
				}
			},
			passenger_back_left = {
				allow_shooting = false,
				next_seat = "driver",
				driving = false,
				has_shooting_mode = true,
				name = "passenger_back_left",
				shooting_pos = Vector3(-40, -20, 50),
				camera_limits = {
					90,
					45
				}
			}
		},
		loot_points = {
			loot = {
				name = "loot"
			}
		},
		secure_loot = false,
		loot_filter = {
			german_spy_body = true,
			conspiracy_board = true,
			gold = true
		},
		allow_only_filtered = true,
		repair_point = "v_repair_engine",
		trunk_point = "interact_trunk",
		damage = {
			max_health = 1250
		},
		max_speed = 120,
		max_rpm = 6000,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 8,
		interact_distance = 350,
		skins = {}
	}
	self.kubelwagen.skins.special_edition = {
		sequence = "state_collector_edition_skin",
		dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION
	}
	self.kubelwagen.driver_camera_offset = Vector3(0, 2, 22)
end

function VehicleTweakData:_init_data_truck()
	self.truck = {
		hud_label_offset = 250,
		unit = "units/vanilla/vehicles/fps_vehicle_truck_02/fps_vehicle_truck_02",
		waypoint_map_icon = "map_waypoint_map_truck",
		waypoint_hud_icon = "waypoint_special_vehicle_truck",
		name = "hud_vehicle_truck",
		animations = {
			passenger_back_right = "drive_truck_back_right",
			driver = "drive_truck_driver",
			vehicle_id = "truck",
			passenger_back_left = "drive_truck_back_left",
			passenger_front = "drive_truck_passanger"
		},
		sound = {
			lateral_slip_treshold = 0.35,
			engine_start = "truck_1p_engine_start",
			horn_start = "kubel_horn_start",
			broken_engine = "kubel_engine_break",
			horn_stop = "kubel_horn_stop",
			engine_sound_event = "truck_engine_event",
			longitudal_slip_treshold = 0.8,
			engine_stop = "truck_1p_engine_stop",
			bump_treshold = 8,
			engine_rpm_rtpc = "TRD",
			engine_speed_rtpc = "TRD_speed",
			hit_enemy = "car_hit_body_01",
			hit_rtpc = "TRD_hit",
			hit = "car_hits_something",
			bump_locator = "anim_tire_front_left",
			bump_rtpc = "TRD_bump",
			bump = "car_bumper_01",
			slip_locator = "anim_tire_front_left",
			slip_stop = "car_skid_stop_01",
			slip = "car_skid_01",
			door_close = "car_door_open",
			gear_shift = "gear_shift"
		},
		seats = {
			driver = {
				sound_environment_start = "enter_truck",
				next_seat = "passenger_front",
				driving = true,
				sound_environment_end = "leave_truck",
				name = "driver"
			},
			passenger_front = {
				allow_shooting = false,
				next_seat = "passenger_back_right",
				driving = false,
				sound_environment_end = "leave_truck",
				name = "passenger_front",
				sound_environment_start = "enter_truck",
				has_shooting_mode = true,
				shooting_pos = Vector3(50, -20, 50),
				camera_limits = {
					90,
					45
				}
			},
			passenger_back_right = {
				allow_shooting = true,
				next_seat = "passenger_back_left",
				driving = false,
				has_shooting_mode = true,
				name = "passenger_back_right",
				shooting_pos = Vector3(50, 0, 50)
			},
			passenger_back_left = {
				allow_shooting = true,
				next_seat = "driver",
				driving = false,
				has_shooting_mode = true,
				name = "passenger_back_left",
				shooting_pos = Vector3(-50, 0, 50)
			}
		},
		loot_points = {
			loot_1 = {
				name = "loot_1"
			},
			loot_2 = {
				name = "loot_2"
			},
			loot_3 = {
				name = "loot_3"
			},
			loot_4 = {
				name = "loot_4"
			},
			loot = {
				name = "loot"
			}
		},
		loot_filter = {
			gold_bar = true,
			painting_sto = true,
			crate_explosives = true,
			painting_sto_cheap = true,
			gold = true
		},
		repair_point = "v_repair_engine",
		damage = {
			max_health = 2500
		},
		max_speed = 85,
		max_rpm = 5000,
		loot_drop_point = "v_loot_drop",
		max_loot_bags = 200,
		interact_distance = 475,
		driver_camera_offset = Vector3(0, 2, 20)
	}
	self.truck_ss = deep_clone(self.truck)
	self.truck_ss.unit = "units/vanilla/vehicles/fps_vehicle_truck_ss/fps_vehicle_truck_ss"
	self.truck_ss.seats.passenger_back_right.has_shooting_mode = false
	self.truck_ss.seats.passenger_back_left.has_shooting_mode = false
end

function VehicleTweakData:_init_data_foxhole()
	self.foxhole = {
		unit = "units/vanilla/vehicles/fps_foxhole/fps_foxhole",
		name = "hud_foxhole",
		hud_label_offset = 950,
		animations = {
			driver = "drive_kubelwagen_driver",
			vehicle_id = "kubelwagen"
		},
		sound = {
			engine_stop = "occasional_silence",
			engine_start = "occasional_silence",
			going_reverse = "occasional_silence",
			broken_engine = "occasional_silence",
			engine_sound_event = "occasional_silence",
			longitudal_slip_treshold = 0.8,
			lateral_slip_treshold = 0.35,
			bump_treshold = 8,
			engine_rpm_rtpc = "occasional_silence",
			engine_speed_rtpc = "occasional_silence",
			hit_enemy = "car_hit_body_01",
			hit_rtpc = "occasional_silence",
			hit = "occasional_silence",
			going_reverse_stop = "occasional_silence",
			bump_rtpc = "occasional_silence",
			bump = "occasional_silence",
			slip_stop = "car_skid_stop_01",
			slip = "occasional_silence",
			door_close = "occasional_silence",
			gear_shift = "occasional_silence"
		},
		seats = {
			driver = {
				has_shooting_mode = false,
				next_seat = "driver",
				driving = false,
				name = "driver",
				camera_limits = {
					90,
					45
				}
			}
		},
		loot_points = {
			loot = {
				name = "loot"
			}
		},
		repair_point = "v_repair_engine",
		trunk_point = "interact_trunk",
		damage = {
			max_health = 100000
		},
		max_speed = 1,
		max_rpm = 2,
		loot_drop_point = "v_repair_engine",
		max_loot_bags = 0,
		interact_distance = 350,
		driver_camera_offset = Vector3(0, 0.2, 15.5)
	}
end
