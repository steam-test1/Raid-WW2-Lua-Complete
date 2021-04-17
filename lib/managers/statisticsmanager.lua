StatisticsManager = StatisticsManager or class()

function StatisticsManager:init()
	self:_setup()
	self:reset_session()

	self._track_session = false
end

function StatisticsManager:_setup(reset)
	self._defaults = {
		killed = {
			german_grunt_light = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_light_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_light_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_light_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_mid = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_mid_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_mid_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_mid_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_heavy = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_heavy_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_heavy_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_grunt_heavy_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_light = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_light_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_light_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_light_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_heavy = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_heavy_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_heavy_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gebirgsjager_heavy_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_light = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_light_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_light_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_heavy = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_heavy_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_heavy_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_heavy_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_light = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_light_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_light_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_light_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gasmask = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_gasmask_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_heavy = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_heavy_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_heavy_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_fallschirmjager_heavy_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_waffen_ss = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_waffen_ss_mp38 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_waffen_ss_kar98 = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_waffen_ss_shotgun = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_commander = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_og_commander = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_officer = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			soviet_nkvd_int_security_captain = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			soviet_nkvd_int_security_captain_b = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_flamer = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_sniper = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			german_spotter = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			other = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			},
			total = {
				melee = 0,
				dismembered = 0,
				count = 0,
				head_shots = 0,
				explosion = 0,
				tied = 0
			}
		},
		killed_by_melee = {},
		killed_by_weapon = {},
		killed_by_grenade = {},
		killed_by_turret = {
			count = 0
		},
		killed_by_vehicle = {
			count = 0
		},
		shots_by_weapon = {},
		sessions = {
			count = 0,
			time = 0
		}
	}
	self._defaults.sessions.levels = {}

	for _, lvl in ipairs(tweak_data.statistics:statistics_table()) do
		self._defaults.sessions.levels[lvl] = {
			from_beginning = 0,
			time = 0,
			started = 0,
			completed = 0,
			drop_in = 0,
			quited = 0
		}
	end

	self._defaults.sessions.jobs = {}
	self._defaults.revives = {
		npc_count = 0,
		player_count = 0
	}
	self._defaults.objectives = {
		count = 0
	}
	self._defaults.shots_fired = {
		total = 0,
		hits = 0
	}
	self._defaults.downed = {
		death = 0,
		bleed_out = 0,
		incapacitated = 0,
		fatal = 0
	}
	self._defaults.reloads = {
		count = 0
	}
	self._defaults.health = {
		amount_lost = 0
	}
	self._defaults.experience = {}
	self._defaults.misc = {}
	self._defaults.play_time = {
		minutes = 0
	}
	self._defaults.camp = {}
	self._defaults.challenge_cards = {
		complete_raid_common_count = 0,
		start_operation_rare_count = 0,
		start_raid_common_count = 0,
		start_operation_uncommon_count = 0,
		complete_operation_common_count = 0,
		complete_raid_rare_count = 0,
		complete_operation_uncommon_count = 0,
		complete_raid_uncommon_count = 0,
		complete_operation_rare_count = 0,
		complete_mission_grand_total = 0,
		complete_mission_rare_total = 0,
		start_operation_common_count = 0,
		start_raid_rare_count = 0,
		start_raid_uncommon_count = 0
	}
	self._defaults.tier_4_weapon_skill_bought = {}

	if not Global.statistics_manager or reset then
		Global.statistics_manager = deep_clone(self._defaults)
		self._global = Global.statistics_manager
		self._global.session = deep_clone(self._defaults)

		self:_calculate_average()
	end

	self._global = self._global or Global.statistics_manager
end

function StatisticsManager:reset()
	self:_setup(true)
end

function StatisticsManager:reset_session()
	if self._global then
		self._global.session = deep_clone(self._defaults)
	end
end

function StatisticsManager:is_session_in_progress()
	return self._session_started
end

function StatisticsManager:set_session_enabled(flag)
	self._track_session = flag
end

function StatisticsManager:_write_log_header()
	local file_handle = SystemFS:open(self._data_log_name, "w")

	file_handle:puts(managers.network.account:username())
	file_handle:puts(Network:is_server() and "true" or "false")
end

function StatisticsManager:_flush_log()
	if not self._data_log or #self._data_log == 0 then
		return
	end

	local file_handle = SystemFS:open(self._data_log_name, "a")

	for _, line in ipairs(self._data_log) do
		local type = line[1]
		local time = line[2]
		local pos = line[3]

		if type == 1 then
			file_handle:puts("1 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4])
		elseif type == 2 then
			file_handle:puts("2 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4] .. " " .. tostring(line[5]))
		elseif type == 3 then
			file_handle:puts("3 " .. time .. " " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " " .. line[4] .. " " .. line[5])
		end
	end

	self._data_log = {}
end

function StatisticsManager:update(t, dt)
	if self._data_log then
		self._log_timer = self._log_timer - dt

		if self._log_timer <= 0 and alive(managers.player:player_unit()) then
			self._log_timer = 0.25

			table.insert(self._data_log, {
				1,
				Application:time(),
				managers.player:player_unit():position(),
				1 / dt
			})

			if Network:is_server() then
				for u_key, u_data in pairs(managers.enemy:all_enemies()) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						1,
						u_key
					})
				end

				for u_key, u_data in pairs(managers.groupai:state()._ai_criminals) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						2,
						u_key
					})
				end

				for u_key, u_data in pairs(managers.enemy:all_civilians()) do
					table.insert(self._data_log, {
						2,
						Application:time(),
						u_data.unit:position(),
						3,
						u_key
					})
				end
			end

			if #self._data_log > 5000 then
				self:_flush_log()
			end
		end
	end
end

function StatisticsManager:start_session(data)
	if self._session_started then
		return
	end

	local current_level_id = managers.raid_job:current_level_id()

	if current_level_id and self._global.sessions.levels[current_level_id] then
		self._global.sessions.levels[current_level_id].started = self._global.sessions.levels[current_level_id].started + 1
		self._global.sessions.levels[current_level_id].from_beginning = self._global.sessions.levels[current_level_id].from_beginning + (Global.statistics_manager.playing_from_start and 1 or 0)
		self._global.sessions.levels[current_level_id].drop_in = self._global.sessions.levels[current_level_id].drop_in + (Global.statistics_manager.playing_from_start and 0 or 1)
	end

	local job_id = managers.raid_job:current_job_id()

	if managers.raid_job._current_job and job_id then
		local job_stat = tostring(job_id) .. "_part_" .. tostring(managers.raid_job._current_job.current_event)
		self._global.sessions.jobs[job_stat .. "_started"] = (self._global.sessions.jobs[job_stat .. "_started"] or 0) + 1
	end

	self._global.session = deep_clone(self._defaults)
	self._global.sessions.count = self._global.sessions.count + 1
	self._start_session_time = Application:time()
	self._start_session_from_beginning = Global.statistics_manager.playing_from_start
	self._start_session_drop_in = data.drop_in
	self._session_started = true

	managers.statistics:start_job_with_challenge_card(managers.raid_job:current_job_type(), managers.challenge_cards:get_active_card())
end

function StatisticsManager:get_session_time_seconds()
	local t = Application:time()

	return t - (self._start_session_time or t)
end

function StatisticsManager:clear_peer_statistics()
	for _, peer in pairs(managers.network:session():all_peers()) do
		peer:clear_statistics()
	end
end

function StatisticsManager:stop_session(data)
	if not self._session_started then
		if data and data.quit then
			Global.statistics_manager.playing_from_start = nil
		end

		return
	end

	local current_level_id = managers.raid_job:current_level_id()

	if not self._global.sessions.levels[current_level_id] then
		-- Nothing
	end

	self:_flush_log()

	self._data_log = nil
	self._session_started = nil
	local success = data and data.success
	local session_time = self:get_session_time_seconds()

	if current_level_id and self._global.sessions.levels[current_level_id] then
		self._global.sessions.levels[current_level_id].time = self._global.sessions.levels[current_level_id].time + session_time

		if success then
			self._global.sessions.levels[current_level_id].completed = self._global.sessions.levels[current_level_id].completed + 1
		else
			self._global.sessions.levels[current_level_id].quited = self._global.sessions.levels[current_level_id].quited + 1
		end
	end

	local completion = nil
	local job_id = managers.raid_job:current_job_id()

	if managers.raid_job._current_job and job_id and data then
		local job_stat = tostring(job_id) .. "_part_" .. tostring(managers.raid_job._current_job.current_event)

		if data.type == "victory" then
			self._global.sessions.jobs[job_stat .. "_victory"] = (self._global.sessions.jobs[job_stat .. "_victory"] or 0) + 1

			if Global.statistics_manager.playing_from_start then
				self._global.sessions.jobs[job_stat .. "_from_beginning"] = (self._global.sessions.jobs[job_stat .. "_from_beginning"] or 0) + 1
				completion = "win_begin"
			else
				self._global.sessions.jobs[job_stat .. "_drop_in"] = (self._global.sessions.jobs[job_stat .. "_drop_in"] or 0) + 1
				completion = "win_dropin"
			end
		elseif data.type == "gameover" then
			self._global.sessions.jobs[job_stat .. "_failed"] = (self._global.sessions.jobs[job_stat .. "_failed"] or 0) + 1

			if Global.statistics_manager.playing_from_start then
				self._global.sessions.jobs[job_stat .. "_from_beginning"] = (self._global.sessions.jobs[job_stat .. "_from_beginning"] or 0) + 1
			else
				self._global.sessions.jobs[job_stat .. "_drop_in"] = (self._global.sessions.jobs[job_stat .. "_drop_in"] or 0) + 1
			end

			completion = "fail"
		end
	end

	self._global.sessions.time = self._global.sessions.time + session_time
	self._global.session.sessions.time = session_time
	self._global.last_session = deep_clone(self._global.session)

	self:_calculate_average()

	if data and data.quit then
		Global.statistics_manager.playing_from_start = nil
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		self:publish_to_steam(self._global.session, success, completion)
	end
end

function StatisticsManager:started_session_from_beginning()
	return self._start_session_from_beginning
end

function StatisticsManager:_increment_misc(name, amount)
	if not self._global.misc then
		self._global.misc = {}
	end

	self._global.misc[name] = (self._global.misc[name] or 0) + amount

	if self._session_started then
		self._global.session.misc[name] = (self._global.session.misc[name] or 0) + amount
	end

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			name,
			amount
		})
	end
end

function StatisticsManager:_increment_camp_stat(name, amount)
	if not self._global.camp then
		self._global.camp = {}
	end

	self._global.camp[name] = (self._global.camp[name] or 0) + amount
end

function StatisticsManager:spend_weapon_points(value)
	self:_increment_camp_stat("ach_weap_points_spend", value)
end

function StatisticsManager:create_character()
	self:_increment_camp_stat("ach_create_character", 1)
end

function StatisticsManager:publish_camp_stats_to_steam()
	if Application:editor() then
		return
	end

	local camp_values = self._global.camp
	local stats = {}

	for stat_name, stat_value in pairs(camp_values) do
		stats[stat_name] = {
			method = "set",
			type = "int",
			value = tonumber(stat_value) or 0
		}
	end

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_top_stats_to_steam()
	if Application:editor() then
		return
	end

	local stats = {
		ach_top_stats_award = {
			method = "set",
			type = "int",
			value = self._global.misc.best_of_stats or 0
		},
		ach_all_3_top_stats_award = {
			method = "set",
			type = "int",
			value = self._global.misc.best_of_stats_all_3 or 0
		}
	}

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:_increment_challenge_card_stat(start_complete_flag, job_type, challenge_card_data)
	if not challenge_card_data then
		return false
	end

	if not self._global.challenge_cards then
		self._global.challenge_cards = {}
	end

	local job_type_name = "raid"

	if job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		job_type_name = "operation"
	end

	local card_rarity_name = ""

	if challenge_card_data.rarity == LootDropTweakData.RARITY_COMMON then
		card_rarity_name = "common"
	elseif challenge_card_data.rarity == LootDropTweakData.RARITY_UNCOMMON then
		card_rarity_name = "uncommon"
	elseif challenge_card_data.rarity == LootDropTweakData.RARITY_RARE then
		card_rarity_name = "rare"
	end

	local stat_name = start_complete_flag .. "_" .. job_type_name .. "_" .. card_rarity_name .. "_count"
	self._global.challenge_cards[stat_name] = (self._global.challenge_cards[stat_name] or 0) + 1
end

function StatisticsManager:start_job_with_challenge_card(job_type, challenge_card_data)
	self:_increment_challenge_card_stat("start", job_type, challenge_card_data)
end

function StatisticsManager:complete_job_with_challenge_card(job_type, challenge_card_data)
	self:_increment_challenge_card_stat("complete", job_type, challenge_card_data)

	self._global.challenge_cards.complete_mission_grand_total = (self._global.challenge_cards.complete_mission_grand_total or 0) + 1
end

function StatisticsManager:open_loot_crate()
	self:_increment_misc("open_loot_crate", 1)
end

function StatisticsManager:leveled_character_to_40()
	self:_increment_misc("character_level_40_count", 1)
end

function StatisticsManager:tier_4_weapon_skill_bought(weapon_id)
	if not self._global.tier_4_weapon_skill_bought then
		self._global.tier_4_weapon_skill_bought = {}
	end

	self._global.tier_4_weapon_skill_bought[weapon_id] = true
	local count = 0

	for weapon_id, _ in pairs(self._global.tier_4_weapon_skill_bought) do
		count = count + 1
	end

	if count >= 2 then
		managers.achievment:award("ach_weap_points_reach_tier_4_2")
	end
end

function StatisticsManager:received_best_of_stat(best_of_stat_count)
	Application:trace("[StatisticsManager:received_best_of_stat] best_of_stat_count ", best_of_stat_count)
	self:_increment_misc("best_of_stats", best_of_stat_count)

	if best_of_stat_count == 3 then
		self:_increment_misc("best_of_stats_all_3", 1)
	end

	self:publish_top_stats_to_steam()
end

function StatisticsManager:in_custody()
	self:_increment_misc("in_custody", 1)
end

function StatisticsManager:trade(data)
	self:_increment_misc("trade", 1)
end

function StatisticsManager:mission_stats(name)
	self._global.session.mission_stats = self._global.session.mission_stats or {}
	self._global.session.mission_stats[name] = (self._global.session.mission_stats[name] or 0) + 1
end

function StatisticsManager:write_level_stats(session, stats)
	for level_name, level_data in pairs(sessions.levels) do
		stats["level_" .. level_name .. "_completed"] = {
			type = "int",
			value = level_data.completed
		}
		stats["level_" .. level_name .. "_started"] = {
			type = "int",
			value = level_data.started
		}
		stats["level_" .. level_name .. "_drop_in"] = {
			type = "int",
			value = level_data.drop_in
		}
		stats["level_" .. level_name .. "_quit"] = {
			type = "int",
			value = level_data.quited
		}
		stats["level_" .. level_name .. "_from_beginning"] = {
			type = "int",
			value = level_data.from_beginning
		}
		stats["level_" .. level_name .. "_time"] = {
			type = "int",
			value = level_data.time
		}
	end
end

function StatisticsManager:publish_to_steam(session, success, completion)
	if Application:editor() or not managers.criminals:local_character_name() then
		return
	end

	local max_ranks = 25
	local session_time_seconds = self:get_session_time_seconds()
	local session_time_minutes = session_time_seconds / 60
	local session_time = session_time_minutes / 60

	if session_time_seconds == 0 or session_time_minutes == 0 or session_time == 0 then
		return
	end

	local level_list, job_list, weapon_list, melee_list, grenade_list, enemy_list, character_list = tweak_data.statistics:statistics_table()
	local stats = self:check_version()
	self._global.play_time.minutes = math.ceil(self._global.play_time.minutes + session_time_minutes)
	local current_time = math.floor(self._global.play_time.minutes / 60)
	local time_found = false
	local play_times = {
		1000,
		500,
		250,
		200,
		150,
		100,
		80,
		40,
		20,
		10,
		0
	}

	if completion then
		for weapon_name, weapon_data in pairs(session.shots_by_weapon) do
			if weapon_data.total > 0 and table.contains(weapon_list, weapon_name) then
				stats["weapon_used_" .. weapon_name] = {
					value = 1,
					type = "int"
				}
				stats["weapon_shots_" .. weapon_name] = {
					type = "int",
					value = weapon_data.total
				}
				stats["weapon_hits_" .. weapon_name] = {
					type = "int",
					value = weapon_data.hits
				}
			end
		end

		local melee_name = managers.blackmarket:equipped_melee_weapon()

		if table.contains(melee_list, melee_name) then
			stats["melee_used_" .. melee_name] = {
				value = 1,
				type = "int"
			}
		end

		stats[Global.game_settings.difficulty] = {
			value = 1,
			type = "int"
		}
	end

	for weapon_name, weapon_data in pairs(session.killed_by_weapon) do
		if weapon_data.count > 0 and table.contains(weapon_list, weapon_name) then
			stats["weapon_kills_" .. weapon_name] = {
				type = "int",
				value = weapon_data.count
			}
		end
	end

	for melee_name, melee_kill in pairs(session.killed_by_melee) do
		if melee_kill > 0 and table.contains(melee_list, melee_name) then
			stats["melee_kills_" .. melee_name] = {
				type = "int",
				value = melee_kill
			}
		end
	end

	for grenade_name, grenade_kill in pairs(session.killed_by_grenade) do
		if grenade_kill > 0 and table.contains(grenade_list, grenade_name) then
			stats["grenade_kills_" .. grenade_name] = {
				type = "int",
				value = grenade_kill
			}
		end
	end

	for enemy_name, enemy_data in pairs(session.killed) do
		if enemy_data.count > 0 and enemy_name ~= "total" and table.contains(enemy_list, enemy_name) then
			stats["enemy_kills_" .. enemy_name] = {
				type = "int",
				value = enemy_data.count
			}
		end
	end

	stats.ach_kill_enemies = {
		type = "int",
		value = session.killed.total.count
	}
	stats.ach_dismember_enemies = {
		type = "int",
		value = session.killed.total.dismembered
	}
	stats.ach_kill_enemies_with_headshot = {
		type = "int",
		value = session.killed.total.head_shots
	}
	stats.ach_kill_enemies_with_melee = {
		type = "int",
		value = self:session_killed_by_melee()
	}
	stats.ach_kill_enemies_with_grenades = {
		type = "int",
		value = self:session_killed_by_grenade()
	}
	stats.ach_kill_enemies_with_secondary_weap = {
		type = "int",
		value = self:session_killed_by_secondary_weapons()
	}
	stats.ach_kill_enemies_with_turret = {
		type = "int",
		value = session.killed_by_turret.count or 0
	}
	stats.ach_run_over_enemies_with_jeep = {
		type = "int",
		value = session.killed_by_vehicle.count or 0
	}
	stats.challenge_cards_complete_operation_common_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_operation_common_count or 0
	}
	stats.challenge_cards_complete_operation_rare_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_operation_rare_count or 0
	}
	stats.challenge_cards_complete_operation_uncommon_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_operation_uncommon_count or 0
	}
	stats.challenge_cards_complete_raid_common_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_raid_common_count or 0
	}
	stats.challenge_cards_complete_raid_rare_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_raid_rare_count or 0
	}
	stats.challenge_cards_complete_raid_uncommon_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_raid_uncommon_count or 0
	}
	stats.challenge_cards_start_operation_common_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_operation_common_count or 0
	}
	stats.challenge_cards_start_operation_rare_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_operation_rare_count or 0
	}
	stats.challenge_cards_start_operation_uncommon_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_operation_uncommon_count or 0
	}
	stats.challenge_cards_start_raid_common_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_raid_common_count or 0
	}
	stats.challenge_cards_start_raid_rare_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_raid_rare_count or 0
	}
	stats.challenge_cards_start_raid_uncommon_count = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.start_raid_uncommon_count or 0
	}
	stats.challenge_cards_complete_operation_total_count = {
		method = "set",
		type = "int",
		value = (self._global.challenge_cards.complete_operation_common_count or 0) + (self._global.challenge_cards.complete_operation_rare_count or 0) + (self._global.challenge_cards.complete_operation_uncommon_count or 0)
	}
	stats.challenge_cards_complete_raid_total_count = {
		method = "set",
		type = "int",
		value = (self._global.challenge_cards.complete_raid_common_count or 0) + (self._global.challenge_cards.complete_raid_rare_count or 0) + (self._global.challenge_cards.complete_raid_uncommon_count or 0)
	}
	stats.challenge_cards_start_operation_total_count = {
		method = "set",
		type = "int",
		value = (self._global.challenge_cards.start_operation_common_count or 0) + (self._global.challenge_cards.start_operation_rare_count or 0) + (self._global.challenge_cards.start_operation_uncommon_count or 0)
	}
	stats.challenge_cards_start_raid_total_count = {
		method = "set",
		type = "int",
		value = (self._global.challenge_cards.start_raid_common_count or 0) + (self._global.challenge_cards.start_raid_rare_count or 0) + (self._global.challenge_cards.start_raid_uncommon_count or 0)
	}
	stats.challenge_cards_complete_mission_grand_total = {
		method = "set",
		type = "int",
		value = self._global.challenge_cards.complete_mission_grand_total or 0
	}
	stats.challenge_cards_complete_mission_rare_total = {
		method = "set",
		type = "int",
		value = (self._global.challenge_cards.complete_operation_rare_count or 0) + (self._global.challenge_cards.complete_raid_rare_count or 0)
	}
	stats.ach_open_loot_crates = {
		type = "int",
		value = session.misc.open_loot_crate or 0
	}
	stats.ach_reach_level_40_count = {
		method = "set",
		type = "int",
		value = self._global.misc.character_level_40_count or 0
	}
	local count_revives = session.revives.player_count + session.revives.npc_count
	stats.ach_revive_teammates = {
		type = "int",
		value = count_revives
	}

	if completion == "win_begin" then
		if Network:is_server() then
			if Global.game_settings.kick_option == 1 then
				stats.option_decide_host = {
					value = 1,
					type = "int"
				}
			elseif Global.game_settings.kick_option == 2 then
				stats.option_decide_vote = {
					value = 1,
					type = "int"
				}
			elseif Global.game_settings.kick_option == 0 then
				stats.option_decide_none = {
					value = 1,
					type = "int"
				}
			end

			stats.info_playing_win_host = {
				value = 1,
				type = "int"
			}
		else
			stats.info_playing_win_client = {
				value = 1,
				type = "int"
			}
		end
	elseif completion == "win_dropin" then
		if not Network:is_server() then
			stats.info_playing_win_client_dropin = {
				value = 1,
				type = "int"
			}
		end
	elseif completion == "fail" then
		if Network:is_server() then
			stats.info_playing_fail_host = {
				value = 1,
				type = "int"
			}
		else
			stats.info_playing_fail_client = {
				value = 1,
				type = "int"
			}
		end
	end

	local level_id = managers.raid_job:current_job_id()

	if completion then
		-- Nothing
	end

	if table.contains(level_list, level_id) then
		for level_name, level_data in pairs(self._global.sessions.levels) do
			stats["level_" .. level_name .. "_completed"] = {
				type = "int",
				value = level_data.completed
			}
			stats["level_" .. level_name .. "_started"] = {
				type = "int",
				value = level_data.started
			}
			stats["level_" .. level_name .. "_drop_in"] = {
				type = "int",
				value = level_data.drop_in
			}
			stats["level_" .. level_name .. "_quit"] = {
				type = "int",
				value = level_data.quited
			}
			stats["level_" .. level_name .. "_from_beginning"] = {
				type = "int",
				value = level_data.from_beginning
			}
			stats["level_" .. level_name .. "_time"] = {
				type = "int",
				value = level_data.time
			}
		end
	end

	local job_id = managers.raid_job:current_job_id()

	if table.contains(job_list, job_id) then
		for job_name, job_data in pairs(self._global.sessions.jobs) do
			stats["jobs_" .. job_name] = {
				type = "int",
				value = job_data
			}
		end
	end

	if session.mission_stats then
		for name, count in pairs(session.mission_stats) do
			print("Mission Statistics: mission_" .. name, count)

			stats["mission_" .. name] = {
				type = "int",
				value = count
			}
		end
	end

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_level_to_steam()
	if Application:editor() then
		return
	end

	local max_ranks = 25
	local stats = {}
	local current_level = managers.experience:current_level()
	stats.player_level = {
		method = "set",
		type = "int",
		value = current_level
	}
	local max_level = Application:digest_value(RaidExperienceManager.LEVEL_CAP, false)

	for i = 0, max_level, 10 do
		stats["player_level_" .. i] = {
			value = 0,
			method = "set",
			type = "int"
		}
	end

	local level_range = max_level <= current_level and max_level or math.floor(current_level / 10) * 10
	stats["player_level_" .. level_range] = {
		value = 1,
		method = "set",
		type = "int"
	}

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_custom_stat_to_steam(name, value)
	if Application:editor() then
		return
	end

	local stats = {
		[name] = {
			type = "int"
		}
	}

	if value then
		stats[name].value = value
	else
		stats[name].method = "set"
		stats[name].value = 1
	end

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:_table_contains(list, item)
	for index, name in pairs(list) do
		if name == item then
			return index
		end
	end
end

function StatisticsManager:publish_equipped_to_steam()
	if Application:editor() then
		return
	end

	if not managers.blackmarket:equipped_primary() then
		return
	end

	local stats = {}
	local level_list, job_list, weapon_list, melee_list, grenade_list, enemy_list, character_list = tweak_data.statistics:statistics_table()
	local primary_name = managers.blackmarket:equipped_primary().weapon_id
	local primary_index = self:_table_contains(weapon_list, primary_name)

	if primary_index then
		stats.equipped_primary = {
			method = "set",
			type = "int",
			value = primary_index
		}
	end

	local secondary_name = managers.blackmarket:equipped_secondary().weapon_id
	local secondary_index = self:_table_contains(weapon_list, secondary_name)

	if secondary_index then
		stats.equipped_secondary = {
			method = "set",
			type = "int",
			value = secondary_index
		}
	end

	local melee_name = managers.blackmarket:equipped_melee_weapon()
	local melee_index = self:_table_contains(melee_list, melee_name)

	if melee_index then
		stats.equipped_melee = {
			method = "set",
			type = "int",
			value = melee_index
		}
	end

	local grenade_name = managers.blackmarket:equipped_grenade()
	local grenade_index = self:_table_contains(grenade_list, grenade_name)

	if grenade_index then
		stats.equipped_grenade = {
			method = "set",
			type = "int",
			value = grenade_index
		}
	end

	local character_name = managers.blackmarket:get_preferred_character()
	local character_index = self:_table_contains(character_list, character_name)

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:publish_skills_to_steam(skip_version_check)
	return

	if Application:editor() then
		return
	end

	local stats = skip_version_check and {} or self:check_version()

	managers.network.account:publish_statistics(stats)
end

function StatisticsManager:check_version()
	local CURRENT_VERSION = 2
	local stats = {}
	local resolution = string.format("%dx%d", RenderSettings.resolution.x, RenderSettings.resolution.y)
	local resolution_list = tweak_data.statistics:resolution_statistics_table()

	for _, res in pairs(resolution_list) do
		stats["option_resolution_" .. res] = {
			value = 0,
			method = "set",
			type = "int"
		}
	end

	stats.option_resolution_other = {
		value = 0,
		method = "set",
		type = "int"
	}
	stats[table.contains(resolution_list, resolution) and "option_resolution_" .. resolution or "option_resolution_other"] = {
		value = 1,
		method = "set",
		type = "int"
	}

	if managers.network.account:get_stat("stat_version") < CURRENT_VERSION then
		self:publish_skills_to_steam(true)

		stats.stat_version = {
			method = "set",
			type = "int",
			value = CURRENT_VERSION
		}
	end

	return stats
end

function StatisticsManager:debug_estimate_steam_players()
	local key = nil
	local stats = {}
	local account = managers.network.account
	local days = 60
	local num_players = 0
	local play_times = {
		0,
		10,
		25,
		50,
		100,
		150,
		200,
		250,
		500,
		1000
	}

	for _, play_time in ipairs(play_times) do
		key = "player_time_" .. play_time .. "h"
		num_players = num_players + account:get_global_stat(key, days)
	end

	Application:debug(string.add_decimal_marks_to_string(tostring(num_players)) .. " players have summited statistics to Steam the last 60 days.")
end

function StatisticsManager:_calculate_average()
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1
	self._global.average = {
		killed = deep_clone(self._global.killed),
		sessions = deep_clone(self._global.sessions),
		revives = deep_clone(self._global.revives)
	}

	for _, data in pairs(self._global.average.killed) do
		data.count = math.round(data.count / t)
		data.head_shots = math.round(data.head_shots / t)
		data.melee = math.round(data.melee / t)
		data.explosion = math.round(data.explosion / t)
	end

	self._global.average.sessions.time = self._global.average.sessions.time / t

	for counter, value in pairs(self._global.average.revives) do
		self._global.average.revives[counter] = math.round(value / t)
	end

	self._global.average.shots_fired = deep_clone(self._global.shots_fired)
	self._global.average.shots_fired.total = math.round(self._global.average.shots_fired.total / t)
	self._global.average.shots_fired.hits = math.round(self._global.average.shots_fired.hits / t)
	self._global.average.downed = deep_clone(self._global.downed)
	self._global.average.downed.bleed_out = math.round(self._global.average.downed.bleed_out / t)
	self._global.average.downed.fatal = math.round(self._global.average.downed.fatal / t)
	self._global.average.downed.incapacitated = math.round(self._global.average.downed.incapacitated / t)
	self._global.average.downed.death = math.round(self._global.average.downed.death / t)
	self._global.average.reloads = deep_clone(self._global.reloads)
	self._global.average.reloads.count = math.round(self._global.average.reloads.count / t)
	self._global.average.experience = deep_clone(self._global.experience)

	for size, data in pairs(self._global.average.experience) do
		if data.actions then
			data.count = math.round(data.count / t)

			for action, count in pairs(data.actions) do
				data.actions[action] = math.round(count / t)
			end
		end
	end
end

function StatisticsManager:killed_by_anyone(data)
end

function StatisticsManager:killed(data)
	local stats_name = data.stats_name or data.name
	data.type = tweak_data.character[data.name] and tweak_data.character[data.name].challenges.type

	if not self._global.killed[stats_name] or not self._global.session.killed[stats_name] then
		Application:error("Bad name id applied to killed, " .. tostring(stats_name) .. ". Defaulting to 'other'")

		stats_name = "other"
	end

	local by_bullet = data.variant == "bullet"
	local by_melee = data.variant == "melee"
	local by_explosion = data.variant == "explosion"
	local by_other_variant = not by_bullet and not by_melee and not by_explosion
	local dismembered = data.dismembered
	local type = self._global.killed[stats_name]
	type.count = type.count + 1
	type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
	type.melee = type.melee + (by_melee and 1 or 0)
	type.explosion = type.explosion + (by_explosion and 1 or 0)
	self._global.killed.total.count = self._global.killed.total.count + 1
	self._global.killed.total.head_shots = self._global.killed.total.head_shots + (data.head_shot and 1 or 0)
	self._global.killed.total.melee = self._global.killed.total.melee + (by_melee and 1 or 0)
	self._global.killed.total.explosion = self._global.killed.total.explosion + (by_explosion and 1 or 0)

	if not self._global.killed.total.dismembered then
		self._global.killed.total.dismembered = 0
	end

	self._global.killed.total.dismembered = self._global.killed.total.dismembered + (dismembered and 1 or 0)

	if self._session_started then
		local type = self._global.session.killed[stats_name]
		type.count = type.count + 1
		type.head_shots = type.head_shots + (data.head_shot and 1 or 0)
		type.melee = type.melee + (by_melee and 1 or 0)
		type.explosion = type.explosion + (by_explosion and 1 or 0)
		self._global.session.killed.total.count = self._global.session.killed.total.count + 1
		self._global.session.killed.total.head_shots = self._global.session.killed.total.head_shots + (data.head_shot and 1 or 0)
		self._global.session.killed.total.melee = self._global.session.killed.total.melee + (by_melee and 1 or 0)
		self._global.session.killed.total.explosion = self._global.session.killed.total.explosion + (by_explosion and 1 or 0)

		if not self._global.session.killed.total.dismembered then
			self._global.session.killed.total.dismembered = 0
		end

		self._global.session.killed.total.dismembered = self._global.session.killed.total.dismembered + (dismembered and 1 or 0)
	end

	if by_bullet then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			if self._session_started then
				self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			end

			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		else
			self:_add_to_killed_by_weapon(name_id, data)

			if data and data.attacker_state == "turret" then
				self:_add_to_killed_by_turret(data)
			end

			if data.name == "tank" then
				managers.achievment:set_script_data("dodge_this_active", true)
			end
		end
	elseif by_melee then
		local name_id = data.name_id

		if self._session_started then
			self._global.session.killed_by_melee[name_id] = (self._global.session.killed_by_melee[name_id] or 0) + 1
		end

		self._global.killed_by_melee[name_id] = (self._global.killed_by_melee[name_id] or 0) + 1
	elseif by_explosion then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		if throwable_id then
			if self._session_started then
				self._global.session.killed_by_grenade[throwable_id] = (self._global.session.killed_by_grenade[throwable_id] or 0) + 1
			end

			self._global.killed_by_grenade[throwable_id] = (self._global.killed_by_grenade[throwable_id] or 0) + 1
		end

		local boom_guns = {
			"gre_m79",
			"huntsman",
			"r870",
			"saiga",
			"ksg",
			"striker",
			"serbu",
			"benelli",
			"judge",
			"rpg7",
			"m32"
		}

		if name_id and table.contains(boom_guns, name_id) then
			self:_add_to_killed_by_weapon(name_id, data)
		end
	elseif by_other_variant then
		local name_id, throwable_id = self:_get_name_id_and_throwable_id(data.weapon_unit)

		self:_add_to_killed_by_weapon(name_id, data)
	end
end

function StatisticsManager:_add_to_killed_by_weapon(name_id, data)
	if not name_id then
		return
	end

	if self._session_started then
		self._global.session.killed_by_weapon[name_id] = self._global.session.killed_by_weapon[name_id] or {
			count = 0,
			headshots = 0
		}
		self._global.session.killed_by_weapon[name_id].count = self._global.session.killed_by_weapon[name_id].count + 1
		self._global.session.killed_by_weapon[name_id].headshots = self._global.session.killed_by_weapon[name_id].headshots + (data.head_shot and 1 or 0)
	end

	self._global.killed_by_weapon[name_id] = self._global.killed_by_weapon[name_id] or {
		count = 0,
		headshots = 0
	}
	self._global.killed_by_weapon[name_id].count = self._global.killed_by_weapon[name_id].count + 1
	self._global.killed_by_weapon[name_id].headshots = (self._global.killed_by_weapon[name_id].headshots or 0) + (data.head_shot and 1 or 0)
end

function StatisticsManager:_add_to_killed_by_turret()
	if self._session_started then
		self._global.session.killed_by_turret = self._global.session.killed_by_turret or {
			count = 0
		}
		self._global.session.killed_by_turret.count = self._global.session.killed_by_turret.count + 1
	end

	self._global.killed_by_turret = self._global.killed_by_turret or {
		count = 0
	}
	self._global.killed_by_turret.count = self._global.killed_by_turret.count + 1
end

function StatisticsManager:add_to_killed_by_vehicle()
	Application:trace("[StatisticsManager:_add_to_killed_by_vehicle]")

	if self._session_started then
		self._global.session.killed_by_vehicle = self._global.session.killed_by_vehicle or {
			count = 0
		}
		self._global.session.killed_by_vehicle.count = self._global.session.killed_by_vehicle.count + 1
	end

	self._global.killed_by_vehicle = self._global.killed_by_vehicle or {
		count = 0
	}
	self._global.killed_by_vehicle.count = self._global.killed_by_vehicle.count + 1
end

function StatisticsManager:_get_name_id_and_throwable_id(weapon_unit)
	if not alive(weapon_unit) then
		return nil, nil
	end

	if weapon_unit:base().projectile_entry then
		local projectile_data = tweak_data.projectiles[weapon_unit:base():projectile_entry()]
		local name_id = projectile_data.weapon_id
		local throwable_id = projectile_data.throwable and weapon_unit:base():projectile_entry()

		return name_id, throwable_id
	elseif weapon_unit:base().get_name_id then
		local name_id = weapon_unit:base():get_name_id()

		return name_id, nil
	end
end

function StatisticsManager:completed_job(job_id, difficulty)
	return self._global.sessions.jobs[tostring(job_id) .. "_" .. tostring(difficulty) .. "_completed"] or 0
end

function StatisticsManager:revived(data)
	if not data.reviving_unit or data.reviving_unit ~= managers.player:player_unit() then
		return
	end

	local counter = data.npc and "npc_count" or "player_count"
	self._global.revives[counter] = self._global.revives[counter] + 1

	if self._session_started then
		self._global.session.revives[counter] = self._global.session.revives[counter] + 1
	end

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"revive",
			1
		})
	end
end

function StatisticsManager:session_teammates_revived()
	return self._global.session.revives
end

function StatisticsManager:objective_completed(data)
	if managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	self._global.objectives.count = self._global.objectives.count + 1

	if self._session_started then
		self._global.session.objectives.count = self._global.session.objectives.count + 1
	end
end

function StatisticsManager:health_subtracted(amount)
	self._global.health.amount_lost = self._global.health.amount_lost + amount

	if self._session_started then
		self._global.session.health.amount_lost = self._global.session.health.amount_lost + amount
	end
end

function StatisticsManager:shot_fired(data)
	local name_id = data.name_id or data.weapon_unit:base():get_name_id()

	if not data.skip_bullet_count then
		self._global.shots_fired.total = self._global.shots_fired.total + 1
		self._global.shots_by_weapon[name_id] = self._global.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.shots_by_weapon[name_id].total = self._global.shots_by_weapon[name_id].total + 1

		if self._session_started then
			self._global.session.shots_fired.total = self._global.session.shots_fired.total + 1
			self._global.session.shots_by_weapon[name_id] = self._global.session.shots_by_weapon[name_id] or {
				total = 0,
				hits = 0
			}
			self._global.session.shots_by_weapon[name_id].total = self._global.session.shots_by_weapon[name_id].total + 1
		end
	end

	if data.hit then
		self._global.shots_fired.hits = self._global.shots_fired.hits + 1
		self._global.shots_by_weapon[name_id] = self._global.shots_by_weapon[name_id] or {
			total = 0,
			hits = 0
		}
		self._global.shots_by_weapon[name_id].hits = self._global.shots_by_weapon[name_id].hits + 1

		if self._session_started then
			self._global.session.shots_fired.hits = self._global.session.shots_fired.hits + 1
			self._global.session.shots_by_weapon[name_id] = self._global.session.shots_by_weapon[name_id] or {
				total = 0,
				hits = 0
			}
			self._global.session.shots_by_weapon[name_id].hits = self._global.session.shots_by_weapon[name_id].hits + 1
		end
	end
end

function StatisticsManager:downed(data)
	managers.achievment:set_script_data("stand_together_fail", true)

	local counter = data.bleed_out and "bleed_out" or data.fatal and "fatal" or data.incapacitated and "incapacitated" or "death"
	self._global.downed[counter] = self._global.downed[counter] + 1

	if self._session_started then
		self._global.session.downed[counter] = self._global.session.downed[counter] + 1
	end

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"downed",
			1
		})
	end
end

function StatisticsManager:reloaded(data)
	self._global.reloads.count = self._global.reloads.count + 1

	if self._session_started then
		self._global.session.reloads.count = self._global.session.reloads.count + 1
	end

	if self._data_log and alive(managers.player:player_unit()) then
		table.insert(self._data_log, {
			3,
			Application:time(),
			managers.player:player_unit():position(),
			"reloaded",
			1
		})
	end
end

function StatisticsManager:recieved_experience(data)
	self._global.experience[data.size] = self._global.experience[data.size] or {
		count = 0,
		actions = {}
	}
	self._global.experience[data.size].count = self._global.experience[data.size].count + 1
	self._global.experience[data.size].actions[data.action] = self._global.experience[data.size].actions[data.action] or 0
	self._global.experience[data.size].actions[data.action] = self._global.experience[data.size].actions[data.action] + 1

	if self._session_started then
		self._global.session.experience[data.size] = self._global.session.experience[data.size] or {
			count = 0,
			actions = {}
		}
		self._global.session.experience[data.size].count = self._global.session.experience[data.size].count + 1
		self._global.session.experience[data.size].actions[data.action] = self._global.session.experience[data.size].actions[data.action] or 0
		self._global.session.experience[data.size].actions[data.action] = self._global.session.experience[data.size].actions[data.action] + 1
	end
end

function StatisticsManager:get_killed()
	return self._global.killed
end

function StatisticsManager:get_play_time()
	return self._global and self._global.play_time and self._global.play_time.minutes or 0
end

function StatisticsManager:count_up(id)
	if not self._statistics[id] then
		Application:stack_dump_error("Bad id to count up, " .. tostring(id) .. ".")

		return
	end

	self._statistics[id].count = self._statistics[id].count + 1
end

function StatisticsManager:print_stats()
	local time_text = self:_time_text(math.round(self._global.sessions.time))
	local time_average_text = self:_time_text(math.round(self._global.average.sessions.time))
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1

	print("- Sessions \t\t-")
	print("Total sessions:\t", self._global.sessions.count)
	print("Total time:\t\t", time_text)
	print("Average time:\t", time_average_text)
	print("\n- Levels \t\t-")

	for name, data in pairs(self._global.sessions.levels) do
		local time_text = self:_time_text(math.round(data.time))

		print("Started: " .. data.started .. "\tBeginning: " .. data.from_beginning .. "\tDrop in: " .. data.drop_in .. "\tCompleted: " .. data.completed .. "\tQuited: " .. data.quited .. "\tTime: " .. time_text .. "\t- " .. name)
	end

	print("\n- Kills \t\t-")

	for name, data in pairs(self._global.killed) do
		print("Count: " .. self:_amount_format(data.count) .. "/" .. self:_amount_format(self._global.average.killed[name].count, true) .. " Head shots: " .. self:_amount_format(data.head_shots) .. "/" .. self:_amount_format(self._global.average.killed[name].head_shots, true) .. " Melee: " .. self:_amount_format(data.melee) .. "/" .. self:_amount_format(self._global.average.killed[name].melee, true) .. " Explosion: " .. self:_amount_format(data.explosion) .. "/" .. self:_amount_format(self._global.average.killed[name].explosion, true) .. " " .. name)
	end

	print("\n- Revives \t\t-")
	print("Count: " .. self._global.revives.npc_count .. "/" .. self._global.average.revives.npc_count .. "\t- Npcs")
	print("Count: " .. self._global.revives.player_count .. "/" .. self._global.average.revives.player_count .. "\t- Players")
	print("\n- Objectives \t-")
	print("Count: " .. self._global.objectives.count)
	print("\n- Shots fired \t-")
	print("Total: " .. self._global.shots_fired.total .. "/" .. self._global.average.shots_fired.total)
	print("Hits: " .. self._global.shots_fired.hits .. "/" .. self._global.average.shots_fired.hits)
	print("Hit percentage: " .. math.round(self._global.shots_fired.hits / (self._global.shots_fired.total ~= 0 and self._global.shots_fired.total or 1) * 100) .. "%")
	print("\n- Downed \t-")
	print("Bleed out: " .. self._global.downed.bleed_out .. "/" .. self._global.average.downed.bleed_out)
	print("Fatal: " .. self._global.downed.fatal .. "/" .. self._global.average.downed.fatal)
	print("Incapacitated: " .. self._global.downed.incapacitated .. "/" .. self._global.average.downed.incapacitated)
	print("Death: " .. self._global.downed.death .. "/" .. self._global.average.downed.death)
	print("\n- Reloads \t-")
	print("Count: " .. self._global.reloads.count .. "/" .. self._global.average.reloads.count)
	self:_print_experience_stats()
end

function StatisticsManager:is_dropin()
	return self._start_session_drop_in
end

function StatisticsManager:_print_experience_stats()
	local t = self._global.sessions.count ~= 0 and self._global.sessions.count or 1
	local average = self._global.average.experience
	local total = 0

	print("\n- Experience -")

	for size, data in pairs(self._global.experience) do
		local exp = tweak_data.experience_manager.values[size]
		local average_count = average[size] and self:_amount_format(average[size].count, true) or "-"
		local average_exp = average[size] and self:_amount_format(exp * average[size].count, true) or "-"
		total = total + exp * data.count

		print("\nSize: " .. size .. " " .. self:_amount_format(exp, true) .. "" .. self:_amount_format(data.count) .. "/" .. average_count .. " " .. self:_amount_format(exp * data.count) .. "/" .. average_exp)

		for action, count in pairs(data.actions) do
			local average_count = average[size] and average[size].actions[action] and self:_amount_format(average[size].actions[action], true) or "-"
			local average_exp = average[size] and average[size].actions[action] and self:_amount_format(exp * average[size].actions[action], true) or "-"

			print("\tAction: " .. action)
			print("\t\tCount:" .. self:_amount_format(count) .. "/" .. average_count .. self:_amount_format(exp * count) .. "/" .. average_exp)
		end
	end

	print("\nTotal:" .. self:_amount_format(total) .. "/" .. self:_amount_format(total / t, true))
end

function StatisticsManager:_amount_format(amount, left)
	amount = math.round(amount)
	local s = ""

	for i = 6 - string.len(amount), 0, -1 do
		s = s .. " "
	end

	return left and amount .. s or s .. amount
end

function StatisticsManager:_time_text(time, params)
	local no_days = params and params.no_days
	local days = no_days and 0 or math.floor(time / 86400)
	time = time - days * 86400
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)

	return (no_days and "" or (days < 10 and "0" .. days or days) .. ":") .. (hours < 10 and "0" .. hours or hours) .. ":" .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
end

function StatisticsManager:_check_loaded_data()
	if not self._global.downed.incapacitated then
		self._global.downed.incapacitated = 0
	end

	for name, data in pairs(self._defaults.killed) do
		self._global.killed[name] = self._global.killed[name] or deep_clone(self._defaults.killed[name])
	end

	for name, data in pairs(self._global.killed) do
		data.melee = data.melee or 0
		data.explosion = data.explosion or 0
	end

	for name, lvl in pairs(self._defaults.sessions.levels) do
		self._global.sessions.levels[name] = self._global.sessions.levels[name] or deep_clone(lvl)
	end

	for _, lvl in pairs(self._global.sessions.levels) do
		lvl.drop_in = lvl.drop_in or 0
		lvl.from_beginning = lvl.from_beginning or 0
	end

	self._global.sessions.jobs = self._global.sessions.jobs or {}
	self._global.experience = self._global.experience or deep_clone(self._defaults.experience)
end

function StatisticsManager:time_played()
	local time = math.round(self._global.sessions.time)
	local time_text = self:_time_text(time)

	return time_text, time
end

function StatisticsManager:favourite_level()
	local started = 0
	local c_name = nil

	for name, data in pairs(self._global.sessions.levels) do
		if started < data.started then
			c_name = name or c_name
		end

		if started < data.started then
			started = data.started or started
		end
	end

	return c_name and tweak_data.levels:get_localized_level_name_from_level_id(c_name) or managers.localization:text("debug_undecided")
end

function StatisticsManager:total_completed_campaigns()
	local i = 0

	for name, data in pairs(self._global.sessions.levels) do
		i = i + data.completed
	end

	return i
end

function StatisticsManager:favourite_weapon()
	local weapon_id = nil
	local count = 0

	for id, data in pairs(self._global.killed_by_weapon) do
		if count < data.count then
			count = data.count
			weapon_id = id
		end
	end

	return weapon_id and managers.localization:text(tweak_data.weapon[weapon_id].name_id) or managers.localization:text("debug_undecided")
end

function StatisticsManager:total_kills()
	return self._global.killed.total.count
end

function StatisticsManager:total_head_shots()
	return self._global.killed.total.head_shots
end

function StatisticsManager:hit_accuracy()
	if self._global.shots_fired.total == 0 then
		return 0
	end

	return math.floor(self._global.shots_fired.hits / self._global.shots_fired.total * 100)
end

function StatisticsManager:total_completed_objectives()
	return self._global.objectives.count
end

function StatisticsManager:session_downed()
	return self._global.session.downed.bleed_out + self._global.session.downed.incapacitated
end

function StatisticsManager:session_time_played()
	local time = math.round(self._global.session.sessions.time)
	local time_text = self:_time_text(time, {
		no_days = true
	})

	return time_text, time
end

function StatisticsManager:completed_objectives()
	return self._global.session.objectives.count
end

function StatisticsManager:session_favourite_weapon()
	local weapon_id = nil
	local count = 0

	for id, data in pairs(self._global.session.killed_by_weapon) do
		if count < data.count then
			count = data.count
			weapon_id = id
		end
	end

	return weapon_id and managers.localization:text(tweak_data.weapon[weapon_id].name_id) or managers.localization:text("debug_undecided")
end

function StatisticsManager:session_used_weapons()
	local weapons_used = {}

	if self._global.session.shots_by_weapon then
		for weapon, _ in pairs(self._global.session.shots_by_weapon) do
			table.insert(weapons_used, weapon)
		end
	end

	return weapons_used
end

function StatisticsManager:session_killed_by_grenade()
	local count = 0

	for projectile_id, kills in pairs(self._global.session.killed_by_grenade) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_killed_by_melee()
	local count = 0

	for melee_id, kills in pairs(self._global.session.killed_by_melee) do
		count = count + kills
	end

	return count
end

function StatisticsManager:session_killed_by_weapon(weapon_id)
	return self._global.session.killed_by_weapon[weapon_id] and self._global.session.killed_by_weapon[weapon_id].count or 0
end

function StatisticsManager:session_killed_by_secondary_weapons()
	local secondaries = managers.blackmarket:get_weapon_names_category("secondaries")
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		if secondaries[weapon_id] ~= nil then
			count = count + data.count
		end
	end

	return count
end

function StatisticsManager:session_killed_by_weapons()
	local count = 0

	for weapon_id, data in pairs(self._global.session.killed_by_weapon) do
		count = count + data.count
	end

	return count
end

function StatisticsManager:session_enemy_killed_by_type(enemy, type)
	return self._global.session.killed and self._global.session.killed[enemy] and self._global.session.killed[enemy][type] or 0
end

function StatisticsManager:session_killed()
	return self._global.session.killed
end

function StatisticsManager:session_total_kills()
	return self._global.session.killed.total.count
end

function StatisticsManager:session_total_killed()
	return self._global.session.killed.total
end

function StatisticsManager:session_total_shots(weapon_type)
	local weapon = weapon_type == "primaries" and managers.blackmarket:equipped_primary() or managers.blackmarket:equipped_secondary()
	local weapon_data = weapon and self._global.session.shots_by_weapon[weapon.weapon_id]

	return weapon_data and weapon_data.total or 0
end

function StatisticsManager:session_total_specials_kills()
	local special_kills = 0

	for enemy_id, enemy_kill_data in pairs(self._global.session.killed) do
		if tweak_data.character[enemy_id] and tweak_data.character[enemy_id].is_special then
			special_kills = special_kills + enemy_kill_data.count
		end
	end

	return special_kills
end

function StatisticsManager:session_total_head_shots()
	return self._global.session.killed.total.head_shots
end

function StatisticsManager:session_hit_accuracy()
	if self._global.session.shots_fired.total == 0 then
		return 0
	end

	return math.floor(self._global.session.shots_fired.hits / self._global.session.shots_fired.total * 100)
end

function StatisticsManager:sessions_jobs()
	return self._global.sessions.jobs
end

function StatisticsManager:session_total_civilian_kills()
	return self._global.session.killed.civilian.count + self._global.session.killed.civilian_female.count
end

function StatisticsManager:send_statistics()
	Application:trace("[StatisticsManager:send_statistics] Network:is_server() ", Network:is_server())

	if not managers.network:session() then
		return
	end

	local peer_id = managers.network:session():local_peer():id()
	local kills = self:session_total_kills()
	local specials_kills = self:session_total_specials_kills()
	local head_shots = self:session_total_head_shots()
	local accuracy = math.min(self:session_hit_accuracy(), 1000)
	local downs = self:session_downed()
	local session_revives_data = self:session_teammates_revived() or 0
	local revives = 0

	for i, count in pairs(session_revives_data) do
		revives = revives + count
	end

	if Network:is_server() then
		self:on_statistics_recieved(peer_id, kills, specials_kills, head_shots, accuracy, downs, revives)
	else
		managers.network:session():send_to_host("send_statistics", kills, specials_kills, head_shots, accuracy, downs, revives)
	end
end

function StatisticsManager:on_statistics_recieved(peer_id, kills, specials_kills, head_shots, accuracy, downs, revives)
	Application:trace("[StatisticsManager:on_statistics_recieved]")

	local peer = managers.network:session():peer(peer_id)

	peer:set_statistics(kills, specials_kills, head_shots, accuracy, downs, revives)
	self:check_if_all_stats_received()
end

function StatisticsManager:check_if_all_stats_received()
	Application:trace("[StatisticsManager:check_if_all_stats_received]")

	local all_peers = managers.network:session():all_peers()

	for _, peer in pairs(all_peers) do
		if not peer:has_statistics() then
			managers.queued_tasks:queue("stats_manager_check_if_all_stats_received", self.check_if_all_stats_received, self, nil, 0.2, nil)

			return
		end
	end

	managers.queued_tasks:unqueue_all("stats_manager_check_if_all_stats_received", self)
	self:calculate_top_stats()
	self:calculate_bottom_stats()
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.TOP_STATS_READY)
	managers.network:session():send_to_peers("sync_statistics_result", self.top_stats[1].id, self.top_stats[1].peer_id, self.top_stats[1].peer_name, self.top_stats[1].score, self.top_stats[2].id, self.top_stats[2].peer_id, self.top_stats[2].peer_name, self.top_stats[2].score, self.top_stats[3].id, self.top_stats[3].peer_id, self.top_stats[3].peer_name, self.top_stats[3].score, self.bottom_stats[1].id, self.bottom_stats[1].peer_id, self.bottom_stats[1].peer_name, self.bottom_stats[1].score, self.bottom_stats[2].id, self.bottom_stats[2].peer_id, self.bottom_stats[2].peer_name, self.bottom_stats[2].score, self.bottom_stats[3].id, self.bottom_stats[3].peer_id, self.bottom_stats[3].peer_name, self.bottom_stats[3].score)
end

function StatisticsManager:calculate_top_stats()
	Application:trace("[StatisticsManager:calculate_top_stats]")

	local all_peers = managers.network:session():all_peers()
	local achievement_all_players_downed = true
	local stats = {}

	for index, stat_id in pairs(tweak_data.statistics.top_stats_calculated) do
		stats[stat_id] = {
			score = 0,
			score_difference = 0,
			weight = 0,
			id = stat_id
		}
	end

	for _, peer in pairs(all_peers) do
		if peer:has_statistics() then
			local peer_stats = peer:statistics()

			if not peer_stats.downs or peer_stats.downs < 1 then
				achievement_all_players_downed = false
			end

			for index, stat_id in pairs(tweak_data.statistics.top_stats_calculated) do
				local stat_tweak_data = tweak_data.statistics.top_stats[stat_id]

				if stats[stat_id].score < peer_stats[stat_tweak_data.stat] or stats[stat_id].score == 0 then
					stats[stat_id].score_difference = math.abs(peer_stats[stat_tweak_data.stat] - stats[stat_id].score)
					stats[stat_id].score = peer_stats[stat_tweak_data.stat]
					stats[stat_id].weight = stats[stat_id].score_difference * stat_tweak_data.weight_multiplier
					stats[stat_id].peer_id = peer:id()
					stats[stat_id].peer_name = managers.network:session():peer(peer:id()):name()
				else
					local score_difference = math.abs(peer_stats[stat_tweak_data.stat] - stats[stat_id].score)

					if score_difference < stats[stat_id].score_difference then
						stats[stat_id].score_difference = score_difference
						stats[stat_id].weight = score_difference * stat_tweak_data.weight_multiplier
					end
				end
			end
		end
	end

	local indexed_stats = {}

	for i, stat in pairs(stats) do
		table.insert(indexed_stats, stat)
	end

	table.sort(indexed_stats, function (a, b)
		if a.weight == b.weight then
			return a.weight + tweak_data.statistics.top_stats[a.id].tie_breaker_multiplier > b.weight + tweak_data.statistics.top_stats[b.id].tie_breaker_multiplier
		end

		return b.weight < a.weight
	end)

	self.top_stats = {}
	local peer_1_top_stats_count = 0

	for i = 1, 3 do
		local stat_slot = self:_get_free_stat_slot(self.top_stats)
		self.top_stats[stat_slot] = indexed_stats[i]

		if self.top_stats[stat_slot].peer_id == 1 then
			peer_1_top_stats_count = peer_1_top_stats_count + 1
		end
	end

	Application:trace("peer_1_top_stats_count self.top_stats ", peer_1_top_stats_count, inspect(self.top_stats))

	if #all_peers == 4 and managers.raid_job:stage_success() and peer_1_top_stats_count > 0 then
		self:received_best_of_stat(peer_1_top_stats_count)
	end

	if #all_peers == 4 and achievement_all_players_downed and managers.raid_job:stage_success() then
		managers.achievment:award("ach_all_players_go_to_bleedout")
		managers.network:session():send_to_peers("sync_award_achievement", "ach_all_players_go_to_bleedout")
	end
end

function StatisticsManager:calculate_bottom_stats()
	local all_peers = managers.network:session():all_peers()
	local stats = {}

	for index, bottom_stat in pairs(tweak_data.statistics.bottom_stats_calculated) do
		stats[bottom_stat] = {
			weight = 0,
			score_difference = 0,
			id = bottom_stat
		}
	end

	for _, peer in pairs(all_peers) do
		if peer:has_statistics() then
			local peer_stats = peer:statistics()

			for index, stat_id in pairs(tweak_data.statistics.bottom_stats_calculated) do
				local stat_tweak_data = tweak_data.statistics.bottom_stats[stat_id]

				if stats[stat_id].score == nil or peer_stats[stat_tweak_data.stat] < stats[stat_id].score then
					if stats[stat_id].score == nil then
						stats[stat_id].score = 100000000000.0
					end

					stats[stat_id].score_difference = math.abs(peer_stats[stat_tweak_data.stat] - stats[stat_id].score)
					stats[stat_id].score = peer_stats[stat_tweak_data.stat]
					stats[stat_id].weight = stats[stat_id].score_difference * stat_tweak_data.weight_multiplier
					stats[stat_id].peer_id = peer:id()
					stats[stat_id].peer_name = managers.network:session():peer(peer:id()):name()
				else
					local score_difference = math.abs(peer_stats[stat_tweak_data.stat] - stats[stat_id].score)

					if score_difference < stats[stat_id].score_difference then
						stats[stat_id].score_difference = score_difference
						stats[stat_id].weight = score_difference * stat_tweak_data.weight_multiplier
					end
				end
			end
		end
	end

	local indexed_stats = {}

	for i, stat in pairs(stats) do
		table.insert(indexed_stats, stat)
	end

	table.sort(indexed_stats, function (a, b)
		if a.weight == b.weight then
			return a.weight + tweak_data.statistics.bottom_stats[a.id].tie_breaker_multiplier > b.weight + tweak_data.statistics.bottom_stats[b.id].tie_breaker_multiplier
		end

		return b.weight < a.weight
	end)

	self.bottom_stats = {}

	for i = 1, 3 do
		local stat_slot = self:_get_free_stat_slot(self.bottom_stats)
		self.bottom_stats[stat_slot] = indexed_stats[i]
	end
end

function StatisticsManager:set_top_stats(top_stat_1_id, top_stat_1_peer_id, top_stat_1_peer_name, top_stat_1_score, top_stat_2_id, top_stat_2_peer_id, top_stat_2_peer_name, top_stat_2_score, top_stat_3_id, top_stat_3_peer_id, top_stat_3_peer_name, top_stat_3_score)
	Application:trace("[StatisticsManager:set_top_stats]")

	self.top_stats = {}

	table.insert(self.top_stats, {
		id = top_stat_1_id,
		peer_id = top_stat_1_peer_id,
		peer_name = top_stat_1_peer_name,
		score = top_stat_1_score
	})
	table.insert(self.top_stats, {
		id = top_stat_2_id,
		peer_id = top_stat_2_peer_id,
		peer_name = top_stat_2_peer_name,
		score = top_stat_2_score
	})
	table.insert(self.top_stats, {
		id = top_stat_3_id,
		peer_id = top_stat_3_peer_id,
		peer_name = top_stat_3_peer_name,
		score = top_stat_3_score
	})

	local peer_top_stats_count = 0

	for stats_index, stats_data in pairs(self.top_stats) do
		if stats_data.peer_id == managers.network:session():local_peer():id() then
			peer_top_stats_count = peer_top_stats_count + 1
		end
	end

	local all_peers = managers.network:session():all_peers()

	if #all_peers == 4 and managers.raid_job:stage_success() and peer_top_stats_count > 0 then
		self:received_best_of_stat(peer_top_stats_count)
	end
end

function StatisticsManager:set_bottom_stats(bottom_stat_1_id, bottom_stat_1_peer_id, bottom_stat_1_peer_name, bottom_stat_1_score, bottom_stat_2_id, bottom_stat_2_peer_id, bottom_stat_2_peer_name, bottom_stat_2_score, bottom_stat_3_id, bottom_stat_3_peer_id, bottom_stat_3_peer_name, bottom_stat_3_score)
	self.bottom_stats = {}

	table.insert(self.bottom_stats, {
		id = bottom_stat_1_id,
		peer_id = bottom_stat_1_peer_id,
		peer_name = bottom_stat_1_peer_name,
		score = bottom_stat_1_score
	})
	table.insert(self.bottom_stats, {
		id = bottom_stat_2_id,
		peer_id = bottom_stat_2_peer_id,
		peer_name = bottom_stat_2_peer_name,
		score = bottom_stat_2_score
	})
	table.insert(self.bottom_stats, {
		id = bottom_stat_3_id,
		peer_id = bottom_stat_3_peer_id,
		peer_name = bottom_stat_3_peer_name,
		score = bottom_stat_3_score
	})
end

function StatisticsManager:_get_free_stat_slot(stat_table)
	local slot = math.random(1, 3)

	while stat_table[slot] ~= nil do
		slot = math.random(1, 3)
	end

	return slot
end

function StatisticsManager:get_top_stats()
	return self.top_stats
end

function StatisticsManager:get_bottom_stats()
	return self.bottom_stats
end

function StatisticsManager:get_top_stats_for_player(peer_id)
	peer_id = peer_id or managers.network:session():local_peer():id()
	local top_stats_for_player = {}

	for i = 1, #self.top_stats do
		if self.top_stats[i].peer_id == peer_id then
			table.insert(top_stats_for_player, self.top_stats[i])
		end
	end

	return top_stats_for_player
end

function StatisticsManager:get_kills_top_stat()
end

function StatisticsManager:get_special_kills_top_stat()
end

function StatisticsManager:get_head_shots_top_stat()
end

function StatisticsManager:get_accuracy_top_stat()
end

function StatisticsManager:get_downs_top_stat()
end

function StatisticsManager:get_revives_top_stat()
end

function StatisticsManager:sync_save(data)
	local state = {
		session_started = self._session_started
	}
	data.StatisticsManager = state
end

function StatisticsManager:sync_load(data)
	local state = data.StatisticsManager

	if state and state.session_started then
		self:start_session({
			drop_in = true,
			from_beginning = false
		})
	end
end

function StatisticsManager:save(data)
	local state = {
		downed = self._global.downed,
		killed = self._global.killed,
		objectives = self._global.objectives,
		reloads = self._global.reloads,
		revives = self._global.revives,
		sessions = self._global.sessions,
		shots_fired = self._global.shots_fired,
		experience = self._global.experience,
		killed_by_melee = self._global.killed_by_melee,
		killed_by_weapon = self._global.killed_by_weapon,
		killed_by_grenade = self._global.killed_by_grenade,
		killed_by_turret = self._global.killed_by_turret,
		killed_by_vehicle = self._global.killed_by_vehicle,
		shots_by_weapon = self._global.shots_by_weapon,
		health = self._global.health,
		misc = self._global.misc,
		camp = self._global.camp,
		challenge_cards = self._global.challenge_cards,
		tier_4_weapon_skill_bought = self._global.tier_4_weapon_skill_bought,
		play_time = self._global.play_time
	}
	data.StatisticsManager = state
end

function StatisticsManager:load(data)
	self:reset()

	local state = data.StatisticsManager

	if state then
		for name, stats in pairs(state) do
			self._global[name] = stats
		end

		self:_check_loaded_data()
		self:_calculate_average()
	end
end
