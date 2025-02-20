EventSystemManager = EventSystemManager or class()
EventSystemManager.VERSION = 1
EventSystemManager.DAY_IN_SECONDS = 86400

function EventSystemManager.get_instance()
	if not Global.event_manager then
		Global.event_manager = EventSystemManager:new()
	end

	setmetatable(Global.event_manager, EventSystemManager)

	return Global.event_manager
end

function EventSystemManager:init()
	self:reset()
end

function EventSystemManager:reset()
	self._last_login_utc = 0
	self._last_login_day = 0
	self._last_login_year = 0
	self._consecutive_logins = 0
	self._daily_event_id = "active_duty"

	self:_check_special_event()
end

function EventSystemManager:save_profile_slot(data)
	local state = {
		version = EventSystemManager.VERSION,
		consecutive_logins = self._consecutive_logins,
		last_login_day = self._last_login_day,
		last_login_year = self._last_login_year,
		last_login_utc = self._last_login_utc,
		daily_event_id = self._daily_event_id
	}
	data.EventSystemManager = state
end

function EventSystemManager:load_profile_slot(data)
	local state = data.EventSystemManager

	if not state then
		return
	end

	if state.version and state.version ~= EventSystemManager.VERSION then
		-- Nothing
	end

	local daily_event_id = state.daily_event_id

	self:_check_special_event()

	if self._daily_event_id == daily_event_id then
		self._consecutive_logins = state.consecutive_logins or 0
		self._last_login_day = state.last_login_day or 0
		self._last_login_year = state.last_login_year or 0
		self._last_login_utc = state.last_login_utc or 0
	end
end

function EventSystemManager:_check_special_event()
	local current_date = tonumber(os.date("%y%m%d"))
	local current_year = tonumber(os.date("%y"))

	if not current_date or not current_year then
		return
	end

	current_year = current_year * 10000

	for event_id, event_data in pairs(tweak_data.events.special_events) do
		local start_date = event_data.date.start + current_year
		local finish_date = event_data.date.finish + current_year

		if start_date > finish_date then
			finish_date = finish_date + 10000
		end

		local event_active = start_date <= current_date and current_date <= finish_date

		if event_active then
			self._active_event = event_id

			if event_data.login_rewards then
				self._daily_event_id = event_data.login_rewards
			end
		elseif event_data.camp_continent then
			managers.raid_job:exclude_camp_continent(event_data.camp_continent)
		end
	end
end

function EventSystemManager:is_event_active()
	return not not self._active_event
end

function EventSystemManager:active_event()
	return self._active_event
end

function EventSystemManager:active_event_data()
	if not self._active_event then
		return
	end

	return tweak_data.events.special_events[self._active_event]
end

function EventSystemManager:on_camp_entered()
	local server_time = Steam:server_time()
	local time_table = os.date("!*t", server_time)

	if not time_table then
		return
	end

	local next_day = self._last_login_day + 1

	if (time_table.yday ~= 365 or next_day ~= 365) and next_day == 365 then
		next_day = 1
	end

	if self._last_login_utc == 0 or next_day == time_table.yday then
		self:_fire_daily_event()
	elseif time_table.yday ~= self._last_login_day then
		self._consecutive_logins = 0

		self:_fire_daily_event()
	end

	self._last_login_day = time_table.yday
	self._last_login_year = time_table.year
	self._last_login_utc = server_time
	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
	managers.gold_economy:layout_camp()
end

function EventSystemManager:consecutive_logins()
	return self._consecutive_logins
end

function EventSystemManager:_fire_daily_event()
	local login_rewards = tweak_data.events.login_rewards[self._daily_event_id]

	if not login_rewards then
		return
	end

	self._consecutive_logins = self._consecutive_logins + 1

	if self._consecutive_logins > #login_rewards then
		self._consecutive_logins = 1
	end

	Application:debug("[EventSystemManager:_fire_daily_event()] Award daily reward!", self._consecutive_logins)

	local reward_data = login_rewards[self._consecutive_logins]
	local reward = reward_data.reward
	local notification_params = {
		name = "active_duty_bonus",
		priority = 4,
		duration = 13,
		notification_type = "active_duty_bonus",
		consecutive = self._consecutive_logins,
		total = #login_rewards
	}

	if reward == EventsTweakData.REWARD_TYPE_OUTLAW then
		if not managers.consumable_missions:is_all_missions_unlocked() then
			local outlaw_id = tweak_data.operations:get_random_unowned_consumable_raid()

			managers.consumable_missions:instant_unlock_mission(outlaw_id)

			notification_params.notification_type = HUDNotification.ACTIVE_DUTY_BONUS_OUTLAW
			notification_params.icon = reward_data.icon_outlaw
		else
			local amount = reward_data.amount

			managers.gold_economy:add_gold(amount)

			notification_params.amount = amount
			notification_params.icon = reward_data.icon
		end
	elseif reward == EventsTweakData.REWARD_TYPE_GOLD then
		local amount = reward_data.amount

		managers.gold_economy:add_gold(amount)

		notification_params.amount = amount
		notification_params.icon = reward_data.icon
	elseif reward == EventsTweakData.REWARD_TYPE_CARD then
		notification_params.amount = reward_data.amount
		notification_params.icon = reward_data.icon

		managers.network.account:inventory_reward(reward_data.generator_id, callback(self, self, "card_drop_callback", notification_params))
		managers.network.account:inventory_load()

		return
	else
		Application:warn("[EventSystemManager:_fire_daily_event()] Not implemented!", reward)

		return
	end

	managers.notification:add_notification(notification_params)
end

function EventSystemManager:card_drop_callback(notification_params, error, loot_list)
	Application:debug("[EventSystemManager:card_drop_callback] notification_params, error, loot_list", notification_params, error, inspect(loot_list))

	if loot_list and loot_list[1] then
		local card_key_name = loot_list[1].entry
		local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)
		notification_params.notification_type = HUDNotification.ACTIVE_DUTY_BONUS_CARD
		notification_params.card_data = card_data
	end

	managers.notification:add_notification(notification_params)
end

function EventSystemManager:activate_current_event(force_active)
	if not self._active_event then
		return
	end

	if not Network:is_server() then
		return
	end

	local event = tweak_data.events.special_events[self._active_event]

	if not event or not event.card_id then
		return
	end

	local card = managers.challenge_cards:get_challenge_card_data(event.card_id)
	card.status = force_active and ChallengeCardsManager.CARD_STATUS_ACTIVE or ChallengeCardsManager.CARD_STATUS_NORMAL
	card.locked_suggestion = true

	managers.challenge_cards:set_active_card(card)
end
