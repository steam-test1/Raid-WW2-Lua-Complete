core:import("CoreMissionScriptElement")

ElementDialogue = ElementDialogue or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDialogue:init(...)
	ElementDialogue.super.init(self, ...)
end

function ElementDialogue:client_on_executed(...)
end

function ElementDialogue:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.repeating then
		self:operation_remove()

		local interval = self._values.repeat_interval or 35
		self._reminder_cb = self._mission_script:add(callback(self, self, "_queue_dialog", instigator), interval)
	else
		self:_queue_dialog(instigator)
	end

	ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)
end

function ElementDialogue:_queue_dialog(instigator)
	local char = self._values.use_instigator and alive(instigator) and managers.criminals:character_name_by_unit(instigator)
	local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator)
	local queue_dialog_unit = {
		skip_idle_check = true,
		instigator = char,
		done_cbk = done_cbk,
		position = self._values.position
	}

	if self._values.dialogue ~= "none" then
		managers.dialog:queue_dialog(self._values.dialogue, queue_dialog_unit)
	elseif self._values.random and self._values.random ~= "none" then
		managers.dialog:queue_random(self._values.random, queue_dialog_unit)
	end
end

function ElementDialogue:operation_remove()
	if self._reminder_cb then
		self._mission_script:remove(self._reminder_cb)

		self._reminder_cb = nil
	end
end

function ElementDialogue:set_enabled(enabled)
	ElementDialogue.super.set_enabled(self, enabled)

	if not enabled then
		self:operation_remove()
	end
end

function ElementDialogue:_done_callback(instigator, reason)
	if not self._values.enabled then
		return
	end

	Application:debug("[ElementDialogue:_done_callback] reason", reason)

	if reason == "done" then
		self._instigator = instigator

		managers.queued_tasks:queue(nil, self._trigger_on_executed, self, nil, 0.1)
	end
end

function ElementDialogue:_trigger_on_executed()
	ElementDialogue.super._trigger_execute_on_executed(self, self._instigator)
end
