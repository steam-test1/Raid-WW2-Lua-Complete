CivilianActionWalk = CivilianActionWalk or class(CopActionWalk)
CivilianActionWalk._walk_anim_velocities = {
	stand = {
		ntl = {
			walk = {
				l = 136.1,
				bwd = 111.3,
				fwd = 129,
				r = 136.1
			},
			run = {
				l = 436,
				bwd = 222,
				fwd = 421,
				r = 419
			}
		},
		hos = {
			walk = {
				l = 170,
				bwd = 170,
				fwd = 170,
				r = 170
			},
			run = {
				l = 436,
				bwd = 222,
				fwd = 421,
				r = 419
			}
		}
	}
}
CivilianActionWalk._walk_anim_velocities.stand.cbt = CivilianActionWalk._walk_anim_velocities.stand.hos
CivilianActionWalk._anim_movement = {
	stand = {
		run_stop_r = 80,
		run_stop_l = 110,
		run_stop_fwd = 120,
		run_start_turn_bwd = {
			ds = Vector3(49, -161, 0)
		},
		run_start_turn_l = {
			ds = Vector3(-250, 90, 0)
		},
		run_start_turn_r = {
			ds = Vector3(240, 68, 0)
		}
	}
}
