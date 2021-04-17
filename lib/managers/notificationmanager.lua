require("lib/managers/hud/HUDNotification")

NotificationManager = NotificationManager or class()

-- Lines 29-32
function NotificationManager:init()
	self._notification_queue = {}
	self._currently_displayed_notification = nil
end

-- Lines 38-116
function NotificationManager:add_notification(notification_data)
	local prompt = nil

	if notification_data.reaction then
		notification_data.reaction.spent = false

		if notification_data.reaction.duration then
			prompt = managers.localization:text("hud_notification_hold_stats", {
				BTN_STATS_VIEW = managers.localization:btn_macro("stats_screen")
			})
		else
			prompt = managers.localization:text("hud_notification_use_stats", {
				BTN_STATS_VIEW = managers.localization:btn_macro("stats_screen")
			})
		end
	end

	notification_data.prompt = prompt
	notification_data.notification_type = notification_data.notification_type or HUDNotification.GENERIC

	if not notification_data.priority then
		notification_data.priority = 1000
	end

	if notification_data.shelf_life then
		notification_data.creation_time = TimerManager:game():time()
	end

	self:_clear_outdated_notifications()

	if self._currently_displayed_notification and self._currently_displayed_notification.id and notification_data.id == self._currently_displayed_notification.id then
		if managers.queued_tasks:has_task("notification_hide") or notification_data.duration then
			managers.queued_tasks:unqueue("notification_hide")

			if notification_data.duration then
				managers.queued_tasks:queue("notification_hide", self.hide_current_notification, self, nil, notification_data.duration, nil, true)
			end
		end

		self._currently_displayed_notification.hud:update_data(notification_data)

		return
	end

	for i = 1, #self._notification_queue do
		if self._notification_queue[i] and notification_data.id == self._notification_queue[i].id then
			table.remove(self._notification_queue, i)
		end
	end

	local table_index = #self._notification_queue + 1

	for i = 1, #self._notification_queue do
		if notification_data.priority < self._notification_queue[i].priority then
			table_index = i

			break
		end
	end

	table.insert(self._notification_queue, table_index, notification_data)

	if self._currently_displayed_notification == nil and #self._notification_queue > 0 then
		self:show_notification(1)
	elseif self._currently_displayed_notification and (notification_data.priority < self._currently_displayed_notification.priority or notification_data.force) and managers.queued_tasks:has_task("notification_hide") then
		self:hide_current_notification()
	end
end

-- Lines 119-131
function NotificationManager:show_notification(index)
	local notification = self._notification_queue[index]
	local hud = HUDNotification.create(notification)
	self._notification_queue[index].hud = hud
	self._currently_displayed_notification = self._notification_queue[index]

	table.remove(self._notification_queue, 1)

	if notification.duration then
		managers.queued_tasks:queue("notification_hide", self.hide_current_notification, self, nil, notification.duration, nil, true)
	end
end

-- Lines 134-147
function NotificationManager:hide_current_notification()
	if self._reaction_in_progress then
		self._delayed_hide = true

		return
	end

	self._delayed_hide = false

	managers.queued_tasks:unqueue("notification_hide")

	if self._currently_displayed_notification and self._currently_displayed_notification.hud then
		self._currently_displayed_notification.hud:hide()
	end
end

-- Lines 150-153
function NotificationManager:execute_current_notification()
	self._currently_displayed_notification.hud:execute()
	managers.queued_tasks:unqueue("notification_hide")
end

-- Lines 156-175
function NotificationManager:react(t)
	if not self._currently_displayed_notification or not self._currently_displayed_notification.reaction then
		return false
	end

	if not self._currently_displayed_notification.reaction.duration then
		return self:_execute_react()
	elseif self._reaction_in_progress then
		self._release_hud_progress = self._currently_displayed_notification.hud:get_progress()

		return true
	else
		self._release_hud_progress = 0
		self._reaction_in_progress = true
		self._reaction_start_t = t

		return true
	end

	return false
end

-- Lines 178-189
function NotificationManager:react_hold(t, dt)
	if self._reaction_in_progress then
		local progress = (t - self._reaction_start_t + self._release_hud_progress) / self._currently_displayed_notification.reaction.duration

		if progress < 1 then
			self._currently_displayed_notification.hud:set_progress(progress)
		elseif progress >= 1 and not self._waiting_for_release then
			self._waiting_for_release = true

			self._currently_displayed_notification.hud:set_full_progress()
		end
	end
end

-- Lines 192-203
function NotificationManager:react_cancel()
	if self._waiting_for_release then
		self:_execute_react()

		self._reaction_in_progress = false
		self._reaction_start_t = nil
	elseif self._reaction_in_progress then
		self._reaction_in_progress = false
		self._reaction_start_t = nil

		self._currently_displayed_notification.hud:cancel_execution()
	end
end

-- Lines 206-220
function NotificationManager:_execute_react()
	local reaction = self._currently_displayed_notification.reaction

	if reaction and not reaction.spent then
		self._waiting_for_release = false
		self._release_hud_progress = 0

		reaction.callback(reaction.callback_self, reaction.data)

		reaction.spent = true

		self:execute_current_notification()

		return true
	end

	return false
end

-- Lines 225-233
function NotificationManager:notification_done()
	self._currently_displayed_notification = nil

	self:_clear_outdated_notifications()

	if #self._notification_queue > 0 then
		self:show_notification(1)
	end
end

-- Lines 237-244
function NotificationManager:on_simulation_ended()
	managers.queued_tasks:unqueue_all(nil, self)

	self._notification_queue = {}

	if self._currently_displayed_notification then
		self._currently_displayed_notification.hud:destroy()
	end

	self._currently_displayed_notification = nil
end

-- Lines 249-257
function NotificationManager:_clear_outdated_notifications()
	local t = TimerManager:game():time()

	for i = #self._notification_queue, 1, -1 do
		local notif = self._notification_queue[i]

		if notif.shelf_life and notif.shelf_life <= t - notif.creation_time then
			table.remove(self._notification_queue, i)
		end
	end
end
