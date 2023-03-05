ChallengeTweakData = ChallengeTweakData or class()
ChallengeTweakData.TASK_GENERIC = "task_generic"
ChallengeTweakData.TASK_KILL_ENEMIES = "task_kill_enemies"
ChallengeTweakData.TASK_COLLECT_AMMO = "task_collect_ammo"

function ChallengeTweakData:init()
	self.tighter_spread_easy = {
		challenge_done_text_id = "weapon_skill_headshot_kill_completed",
		challenge_briefing_id = "weapon_skill_headshot_kill_briefing",
		target = 25,
		type = ChallengeTweakData.TASK_KILL_ENEMIES,
		reminders = {
			10,
			20
		},
		modifiers = {
			headshot = true,
			damage_type = WeaponTweakData.DAMAGE_TYPE_BULLET
		}
	}
	self.tighter_spread_medium = deep_clone(self.tighter_spread_easy)
	self.tighter_spread_medium.target = 35
	self.tighter_spread_medium.reminders = {
		15,
		25,
		30
	}
	self.tighter_spread_hard = deep_clone(self.tighter_spread_easy)
	self.tighter_spread_hard.target = 45
	self.tighter_spread_hard.reminders = {
		15,
		25,
		35
	}
	self.increase_magazine_easy = {
		challenge_done_text_id = "weapon_skill_collect_ammo_completed",
		challenge_briefing_id = "weapon_skill_collect_ammo_briefing",
		target = 175,
		type = ChallengeTweakData.TASK_COLLECT_AMMO,
		reminders = {
			100,
			150
		}
	}
	self.increase_magazine_medium = deep_clone(self.increase_magazine_easy)
	self.increase_magazine_medium.target = 230
	self.increase_magazine_medium.reminders = {
		100,
		200
	}
	self.increase_magazine_hard = deep_clone(self.increase_magazine_easy)
	self.increase_magazine_hard.target = 300
	self.increase_magazine_hard.reminders = {
		100,
		200,
		250
	}
	self.kill_enemies_hipfire_easy = {
		challenge_done_text_id = "weapon_skill_hip_fire_kill_completed",
		challenge_briefing_id = "weapon_skill_hip_fire_kill_briefing",
		target = 100,
		type = ChallengeTweakData.TASK_KILL_ENEMIES,
		reminders = {
			40,
			70,
			90
		},
		modifiers = {
			hip_fire = true,
			damage_type = WeaponTweakData.DAMAGE_TYPE_BULLET
		}
	}
	self.kill_enemies_hipfire_medium = deep_clone(self.kill_enemies_hipfire_easy)
	self.kill_enemies_hipfire_medium.target = 165
	self.kill_enemies_hipfire_medium.reminders = {
		50,
		100,
		125,
		150
	}
	self.kill_enemies_hipfire_hard = deep_clone(self.kill_enemies_hipfire_easy)
	self.kill_enemies_hipfire_hard.target = 215
	self.kill_enemies_hipfire_hard.reminders = {
		50,
		100,
		150,
		200
	}
	self.kill_enemies_basic_easy = {
		challenge_done_text_id = "weapon_skill_generic_kill_completed",
		challenge_briefing_id = "weapon_skill_generic_kill_briefing",
		target = 200,
		type = ChallengeTweakData.TASK_KILL_ENEMIES,
		reminders = {
			60,
			125,
			150,
			180
		}
	}
	self.kill_enemies_basic_medium = deep_clone(self.kill_enemies_basic_easy)
	self.kill_enemies_basic_medium.target = 325
	self.kill_enemies_basic_medium.reminders = {
		50,
		100,
		200,
		300
	}
	self.kill_enemies_basic_hard = deep_clone(self.kill_enemies_basic_easy)
	self.kill_enemies_basic_hard.target = 425
	self.kill_enemies_basic_hard.reminders = {
		100,
		200,
		300,
		400
	}
	self.c96_kill_enemies_basic_easy = deep_clone(self.kill_enemies_basic_easy)
	self.c96_kill_enemies_basic_easy.target = 200
	self.c96_kill_enemies_basic_easy.reminders = {
		50,
		100,
		150
	}
	self.c96_kill_enemies_hipfire_easy = deep_clone(self.kill_enemies_hipfire_easy)
	self.c96_kill_enemies_hipfire_easy.target = 80
	self.c96_kill_enemies_hipfire_easy.reminders = {
		20,
		40,
		60
	}
	self.c96_increase_magazine_easy = deep_clone(self.increase_magazine_easy)
	self.c96_increase_magazine_easy.target = 150
	self.c96_increase_magazine_easy.reminders = {
		80,
		100,
		130
	}
	self.c96_kill_enemies_basic_medium = deep_clone(self.kill_enemies_basic_medium)
	self.c96_kill_enemies_basic_medium.target = 150
	self.c96_kill_enemies_basic_medium.reminders = {
		80,
		100,
		130
	}
	self.c96_kill_enemies_hipfire_medium = deep_clone(self.kill_enemies_hipfire_medium)
	self.c96_kill_enemies_hipfire_medium.target = 125
	self.c96_kill_enemies_hipfire_medium.reminders = {
		40,
		80,
		100
	}
	self.c96_increase_magazine_medium = deep_clone(self.increase_magazine_medium)
	self.c96_tighter_spread_medium = deep_clone(self.tighter_spread_medium)
	self.webley_kill_enemies_basic_easy = deep_clone(self.kill_enemies_basic_easy)
	self.webley_kill_enemies_basic_easy.target = 250
	self.webley_kill_enemies_basic_easy.reminders = {
		60,
		125,
		185,
		225
	}
	self.webley_kill_enemies_headshot_easy = deep_clone(self.tighter_spread_easy)
	self.webley_kill_enemies_headshot_easy.target = 25
	self.webley_kill_enemies_headshot_easy.reminders = {
		10,
		20
	}
	self.webley_kill_enemies_basic_medium = deep_clone(self.kill_enemies_basic_easy)
	self.webley_kill_enemies_basic_medium.target = 325
	self.webley_kill_enemies_basic_medium.reminders = {
		100,
		170,
		260,
		300
	}
	self.webley_kill_enemies_headshot_medium = deep_clone(self.tighter_spread_easy)
	self.webley_kill_enemies_headshot_medium.target = 35
	self.webley_kill_enemies_headshot_medium.reminders = {
		10,
		20,
		30
	}
	self.webley_kill_enemies_basic_hard = deep_clone(self.kill_enemies_basic_easy)
	self.webley_kill_enemies_basic_hard.target = 165
	self.webley_kill_enemies_basic_hard.reminders = {
		30,
		60,
		90,
		130
	}
	self.welrod_kill_enemies_basic_easy = deep_clone(self.kill_enemies_basic_easy)
	self.welrod_kill_enemies_basic_easy.target = 75
	self.welrod_kill_enemies_basic_easy.reminders = {
		25,
		50,
		60
	}
	self.welrod_kill_enemies_headshot_easy = deep_clone(self.tighter_spread_easy)
	self.welrod_kill_enemies_headshot_easy.target = 25
	self.welrod_kill_enemies_headshot_easy.reminders = {
		10,
		20
	}
	self.welrod_kill_enemies_basic_medium = deep_clone(self.kill_enemies_basic_medium)
	self.welrod_kill_enemies_basic_medium.target = 150
	self.welrod_kill_enemies_basic_medium.reminders = {
		40,
		60,
		120
	}
	self.welrod_kill_enemies_headshot_medium = deep_clone(self.tighter_spread_medium)
	self.welrod_kill_enemies_headshot_medium.target = 35
	self.welrod_kill_enemies_headshot_medium.reminders = {
		10,
		20,
		30
	}
	self.welrod_kill_enemies_hipfire_medium = deep_clone(self.kill_enemies_hipfire_medium)
	self.welrod_kill_enemies_hipfire_medium.target = 75
	self.welrod_kill_enemies_hipfire_medium.reminders = {
		25,
		50,
		60
	}
end
