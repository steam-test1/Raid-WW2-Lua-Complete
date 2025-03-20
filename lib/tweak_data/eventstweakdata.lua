EventsTweakData = EventsTweakData or class()
EventsTweakData.REWARD_TYPE_GOLD = "REWARD_TYPE_GOLD"
EventsTweakData.REWARD_TYPE_OUTLAW = "REWARD_TYPE_OUTLAW"
EventsTweakData.REWARD_TYPE_CARD = "REWARD_TYPE_CARD"
EventsTweakData.REWARD_ICON_SINGLE = "gold_bar_single"
EventsTweakData.REWARD_ICON_FEW = "gold_bar_3"
EventsTweakData.REWARD_ICON_MANY = "gold_bar_box"
EventsTweakData.REWARD_ICON_OUTLAW = "outlaw_raid_hud_item"

function EventsTweakData:init(tweak_data)
	self.login_rewards = {}

	self:_init_active_duty_rewards()
	self:_init_halloween_rewards()

	self.special_events = {}

	self:_init_trick_or_treat_event(tweak_data)
end

function EventsTweakData:_init_active_duty_rewards()
	self.login_rewards.active_duty = {
		{
			amount = 5,
			reward = EventsTweakData.REWARD_TYPE_GOLD,
			icon = EventsTweakData.REWARD_ICON_SINGLE
		},
		{
			amount = 10,
			reward = EventsTweakData.REWARD_TYPE_GOLD,
			icon = EventsTweakData.REWARD_ICON_FEW
		},
		{
			amount = 20,
			reward = EventsTweakData.REWARD_TYPE_GOLD,
			icon = EventsTweakData.REWARD_ICON_FEW
		},
		{
			amount = 30,
			reward = EventsTweakData.REWARD_TYPE_GOLD,
			icon = EventsTweakData.REWARD_ICON_MANY
		},
		{
			amount = 50,
			reward = EventsTweakData.REWARD_TYPE_OUTLAW,
			icon_outlaw = EventsTweakData.REWARD_ICON_OUTLAW,
			icon = EventsTweakData.REWARD_ICON_MANY
		}
	}
end

function EventsTweakData:_init_halloween_rewards()
	self.login_rewards.halloween = {
		{
			amount = 10,
			reward = self.REWARD_TYPE_CARD,
			generator_id = ChallengeCardsTweakData.PACK_TYPE_HALLOWEEN,
			icon = self.REWARD_ICON_SINGLE
		},
		{
			amount = 20,
			reward = self.REWARD_TYPE_CARD,
			generator_id = ChallengeCardsTweakData.PACK_TYPE_HALLOWEEN,
			icon = self.REWARD_ICON_SINGLE
		},
		{
			amount = 40,
			reward = self.REWARD_TYPE_CARD,
			generator_id = ChallengeCardsTweakData.PACK_TYPE_HALLOWEEN,
			icon = self.REWARD_ICON_SINGLE
		}
	}
end

function EventsTweakData:_init_trick_or_treat_event(tweak_data)
	self.special_events.trick_or_treat = {
		name_id = "hud_trick_or_treat_title",
		package = "packages/halloween_candy",
		challenge_id = "candy_gold_bar",
		card_id = "ra_trick_or_treat",
		camp_continent = "event_halloween",
		accent_color = "progress_orange",
		login_rewards = "halloween",
		game_logo = tweak_data.gui.icons.raid_hw_logo_small,
		date = {
			finish = 1110,
			start = 1023
		},
		upgrades = {
			"temporary_candy_health_regen",
			"temporary_candy_god_mode",
			"temporary_candy_armor_pen",
			"temporary_candy_unlimited_ammo",
			"temporary_candy_sprint_speed",
			"temporary_candy_jump_boost",
			"temporary_candy_attack_damage",
			"temporary_candy_critical_hit_chance"
		},
		milestones = {
			40,
			80,
			130,
			190
		},
		bonus_effects = {
			refill_health = "hud_trick_or_treat_buff_health",
			undead = "hud_trick_or_treat_buff_undead",
			refill_ammo = "hud_trick_or_treat_buff_ammo",
			refill_warcry = "hud_trick_or_treat_buff_warcry",
			refill_down = "hud_trick_or_treat_buff_down"
		},
		malus_effects = {
			{
				desc_id = "effect_set_bleedout_timer",
				value = 15,
				name = BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER,
				desc_params = {
					EFFECT_VALUE_1 = "15"
				}
			},
			{
				desc_id = "effect_player_slower_reload",
				value = 0.8,
				name = BuffEffectManager.EFFECT_PLAYER_RELOAD_SPEED,
				desc_params = {
					EFFECT_VALUE_1 = "20%"
				}
			},
			{
				desc_id = "effect_health_drain_per_minute",
				value = -0.005,
				name = BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN,
				desc_params = {
					EFFECT_VALUE_1 = "30%"
				}
			},
			{
				value = 4,
				name = BuffEffectManager.EFFECT_ENEMIES_MELEE_DAMAGE_INCREASE,
				desc_id = BuffEffectManager.EFFECT_ENEMIES_MELEE_DAMAGE_INCREASE,
				desc_params = {
					EFFECT_VALUE_1 = "400%"
				}
			},
			{
				value = 1.15,
				stage = 3,
				desc_id = "effect_enemies_deal_increased_damage",
				name = BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE,
				desc_params = {
					EFFECT_VALUE_1 = "15%"
				},
				blocked_by = BuffEffectManager.EFFECT_ENEMY_HEALTH
			},
			{
				value = 1.2,
				stage = 3,
				desc_id = "effect_enemies_health_increased",
				name = BuffEffectManager.EFFECT_ENEMY_HEALTH,
				desc_params = {
					EFFECT_VALUE_1 = "20%"
				},
				blocked_by = BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE
			},
			{
				value = true,
				stage = 4,
				desc_id = "effect_warcries_disabled",
				chance = 50,
				name = BuffEffectManager.EFFECT_WARCRIES_DISABLED
			},
			{
				value = true,
				stage = 4,
				desc_id = "effect_enemies_vulnerable_only_to_headshots",
				chance = 30,
				name = BuffEffectManager.EFFECT_ENEMIES_DIE_ONLY_ON_HEADSHOT,
				blocked_by = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DOESNT_DO_DAMAGE
			},
			{
				value = true,
				stage = 4,
				desc_id = "effect_headshot_doesnt_do_damage",
				chance = 30,
				name = BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DOESNT_DO_DAMAGE,
				blocked_by = BuffEffectManager.EFFECT_ENEMIES_DIE_ONLY_ON_HEADSHOT
			},
			{
				desc_id = "effect_shooting_your_primary_weapon_consumes_both_ammos",
				stage = 5,
				value = true,
				name = BuffEffectManager.EFFECT_SHOOTING_PRIMARY_WEAPON_CONSUMES_BOTH_AMMOS
			},
			{
				value = true,
				stage = 5,
				desc_id = "effect_player_can_only_walk_backwards_or_sideways",
				chance = 5,
				name = BuffEffectManager.EFFECT_PLAYER_CAN_MOVE_ONLY_BACK_AND_SIDE
			}
		}
	}
end
