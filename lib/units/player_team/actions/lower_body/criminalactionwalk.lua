CriminalActionWalk = CriminalActionWalk or class(CopActionWalk)
CriminalActionWalk._anim_block_presets = {
	block_none = nil,
	block_all = nil,
	block_upper = nil,
	block_lower = nil,
	block_all = {
		light_hurt = -1,
		turn = -1,
		shoot = -1,
		dodge = -1,
		stand = -1,
		crouch = -1,
		walk = -1,
		action = -1,
		idle = -1,
		death = -1,
		act = -1,
		heavy_hurt = -1,
		hurt = -1
	},
	block_lower = {
		light_hurt = -1,
		turn = -1,
		dodge = -1,
		stand = -1,
		crouch = -1,
		walk = -1,
		idle = -1,
		death = -1,
		act = -1,
		heavy_hurt = -1,
		hurt = -1
	},
	block_upper = {
		stand = -1,
		crouch = -1,
		shoot = -1,
		action = -1
	},
	block_none = {
		stand = -1,
		crouch = -1
	}
}
CriminalActionWalk._walk_anim_velocities = HuskPlayerMovement._walk_anim_velocities
CriminalActionWalk._walk_anim_lengths = HuskPlayerMovement._walk_anim_lengths
