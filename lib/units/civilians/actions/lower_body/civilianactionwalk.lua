CivilianActionWalk = CivilianActionWalk or class(CopActionWalk)
CivilianActionWalk._walk_anim_velocities = {
	stand = nil,
	stand = {
		hos = nil,
		ntl = nil,
		ntl = {
			walk = nil,
			run = nil,
			walk = {
				r = 136.1,
				l = 136.1,
				bwd = 111.3,
				fwd = 129
			},
			run = {
				r = 419,
				l = 436,
				bwd = 222,
				fwd = 421
			}
		},
		hos = {
			walk = nil,
			run = nil,
			walk = {
				r = 170,
				l = 170,
				bwd = 170,
				fwd = 170
			},
			run = {
				r = 419,
				l = 436,
				bwd = 222,
				fwd = 421
			}
		}
	}
}
CivilianActionWalk._walk_anim_velocities.stand.cbt = CivilianActionWalk._walk_anim_velocities.stand.hos
CivilianActionWalk._anim_movement = {
	stand = nil,
	stand = {
		run_stop_r = 80,
		run_stop_l = 110,
		run_stop_fwd = 120,
		run_start_turn_r = nil,
		run_start_turn_l = nil,
		run_start_turn_bwd = nil,
		run_start_turn_bwd = {
			ds = nil,
			ds = Vector3(49, -161, 0)
		},
		run_start_turn_l = {
			ds = nil,
			ds = Vector3(-250, 90, 0)
		},
		run_start_turn_r = {
			ds = nil,
			ds = Vector3(240, 68, 0)
		}
	}
}
