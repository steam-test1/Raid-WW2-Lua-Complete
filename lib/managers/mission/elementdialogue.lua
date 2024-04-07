core:import("CoreMissionScriptElement")

ElementDialogue = ElementDialogue or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDialogue:init(...)
	ElementDialogue.super.init(self, ...)
end

function ElementDialogue:client_on_executed(...)
	return
end

function ElementDialogue:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local char

	if self._values.use_instigator then
		char = managers.criminals:character_name_by_unit(instigator)
	end

	local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator) or nil
	local queue_dialog_unit = {
		skip_idle_check = true,
		instigator = char,
		done_cbk = done_cbk,
		position = self._values.position
	}

	if self._values.dialogue ~= "none" then
		managers.dialog:queue_dialog(self._values.dialogue, queue_dialog_unit)
	end

	if self._values.random and self._values.random ~= "none" then
		managers.dialog:queue_random(self._values.random, queue_dialog_unit)
	end

	ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)
end

function ElementDialogue:_done_callback(instigator, reason)
	Application:debug("[ElementDialogue:_done_callback] reason", reason)

	if reason == "done" then
		self._instigator = instigator

		managers.queued_tasks:queue(nil, self._queueud_done, self, nil, 0.1, nil)
	end
end

function ElementDialogue:_queueud_done()
	ElementDialogue.super._trigger_execute_on_executed(self, self._instigator)
end
