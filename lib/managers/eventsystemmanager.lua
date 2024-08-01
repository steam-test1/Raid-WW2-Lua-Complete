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
end

function EventSystemManager:save_profile_slot(data)
	local state = {
		version = EventSystemManager.VERSION,
		consecutive_logins = self._consecutive_logins,
		last_login_day = self._last_login_day,
		last_login_year = self._last_login_year,
		last_login_utc = self._last_login_utc
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

	self._consecutive_logins = state.consecutive_logins or 0
	self._last_login_day = state.last_login_day or 0
	self._last_login_year = state.last_login_year or 0
	self._last_login_utc = state.last_login_utc or 0
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
	self._consecutive_logins = self._consecutive_logins + 1

	if self._consecutive_logins > #tweak_data.events.active_duty_bonus_rewards then
		self._consecutive_logins = 1
	end

	Application:debug("[EventSystemManager:_fire_daily_event()] Award daily reward!", self._consecutive_logins)

	local reward_data = tweak_data.events.active_duty_bonus_rewards[self._consecutive_logins]
	local reward = reward_data.reward
	local notification_params = {
		priority = 4,
		name = "active_duty_bonus",
		notification_type = "active_duty_bonus",
		duration = 13,
		consecutive = self._consecutive_logins,
		total = #tweak_data.events.active_duty_bonus_rewards
	}

	if reward == EventsTweakData.REWERD_TYPE_OUTLAW then
		if not managers.consumable_missions:is_all_missions_unlocked() then
			local outlaw_id = tweak_data.operations:get_random_unowned_consumable_raid()

			managers.consumable_missions:instant_unlock_mission(outlaw_id)

			notification_params.notification_type = HUDNotification.ACTIVE_DUTY_BONUS_OUTLAW
			notification_params.icon = reward_data.icon_outlaw
		else
			local amount = tweak_data.events.active_duty_bonus_rewards[self._consecutive_logins].amount

			managers.gold_economy:add_gold(amount)

			notification_params.amount = amount
			notification_params.icon = reward_data.icon
		end
	elseif reward == EventsTweakData.REWERD_TYPE_GOLD then
		local amount = tweak_data.events.active_duty_bonus_rewards[self._consecutive_logins].amount

		managers.gold_economy:add_gold(amount)

		notification_params.amount = amount
		notification_params.icon = reward_data.icon
	else
		Application:warn("[EventSystemManager:_fire_daily_event()] Not implemented!", reward)

		return
	end

	managers.notification:add_notification(notification_params)
end
