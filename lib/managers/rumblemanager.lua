core:module("RumbleManager")
core:import("CoreRumbleManager")
core:import("CoreClass")

RumbleManager = RumbleManager or class(CoreRumbleManager.RumbleManager)

function RumbleManager:init()
	RumbleManager.super.init(self)
	_G.tweak_data:add_reload_callback(self, callback(self, self, "setup_preset_rumbles"))
	self:setup_preset_rumbles()
end

function RumbleManager:setup_preset_rumbles()
	self:add_preset_rumbles("weapon_fire", {
		engine = "both",
		cumulative = false,
		release = 0.05,
		sustain = 0.1,
		peak = 0.5
	})
	self:add_preset_rumbles("land", {
		engine = "both",
		cumulative = false,
		release = 0.1,
		sustain = 0.1,
		peak = 0.5
	})
	self:add_preset_rumbles("hard_land", {
		engine = "both",
		cumulative = false,
		release = 0.1,
		sustain = 0.3,
		peak = 1
	})
	self:add_preset_rumbles("electrified", {
		cumulative = false,
		engine = "both",
		release = 0.05,
		peak = 0.5
	})
	self:add_preset_rumbles("electric_shock", {
		engine = "both",
		cumulative = true,
		release = 0.1,
		sustain = 0.2,
		peak = 1
	})
	self:add_preset_rumbles("incapacitated_shock", {
		engine = "both",
		cumulative = true,
		release = 0.1,
		sustain = 0.2,
		peak = 0.75
	})
	self:add_preset_rumbles("damage_bullet", {
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.2,
		peak = 1
	})
	self:add_preset_rumbles("damage_bullet_turret", {
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.1,
		peak = 0.5
	})
	self:add_preset_rumbles("bullet_whizby", {
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.075,
		peak = 1
	})
	self:add_preset_rumbles("melee_hit", {
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.15,
		peak = 1
	})
	self:add_preset_rumbles("mission_triggered", {
		attack = 0.1,
		engine = "both",
		cumulative = true,
		release = 2.1,
		sustain = 0.3,
		peak = 1
	})
end

CoreClass.override_class(CoreRumbleManager.RumbleManager, RumbleManager)
