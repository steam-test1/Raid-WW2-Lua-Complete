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
		peak = 0.5,
		engine = "both",
		cumulative = false,
		release = 0.05,
		sustain = 0.1
	})
	self:add_preset_rumbles("land", {
		peak = 0.5,
		engine = "both",
		cumulative = false,
		release = 0.1,
		sustain = 0.1
	})
	self:add_preset_rumbles("hard_land", {
		peak = 1,
		engine = "both",
		cumulative = false,
		release = 0.1,
		sustain = 0.3
	})
	self:add_preset_rumbles("electrified", {
		peak = 0.5,
		cumulative = false,
		engine = "both",
		release = 0.05
	})
	self:add_preset_rumbles("electric_shock", {
		peak = 1,
		engine = "both",
		cumulative = true,
		release = 0.1,
		sustain = 0.2
	})
	self:add_preset_rumbles("damage_bullet", {
		peak = 1,
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.2
	})
	self:add_preset_rumbles("damage_bullet_turret", {
		peak = 0.5,
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.1
	})
	self:add_preset_rumbles("bullet_whizby", {
		peak = 1,
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.075
	})
	self:add_preset_rumbles("melee_hit", {
		peak = 1,
		engine = "both",
		cumulative = true,
		release = 0,
		sustain = 0.15
	})
	self:add_preset_rumbles("mission_triggered", {
		peak = 1,
		engine = "both",
		attack = 0.1,
		cumulative = true,
		release = 2.1,
		sustain = 0.3
	})
end

CoreClass.override_class(CoreRumbleManager.RumbleManager, RumbleManager)
