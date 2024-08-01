HUDWeaponBase = HUDWeaponBase or class()
HUDWeaponBase.ALPHA_WHEN_SELECTED = 1
HUDWeaponBase.ALPHA_WHEN_UNSELECTED = 0.5

-- Lines 7-10
function HUDWeaponBase:init(index, weapons_panel, tweak_data)
	self._tweak_data = tweak_data
	self._blocked = false
end

-- Lines 12-14
function HUDWeaponBase:panel()
	return self._object
end

-- Lines 16-18
function HUDWeaponBase:w()
	return self._object:w()
end

-- Lines 20-22
function HUDWeaponBase:h()
	return self._object:h()
end

-- Lines 24-26
function HUDWeaponBase:set_x(x)
	self._object:set_x(x)
end

-- Lines 28-30
function HUDWeaponBase:set_y(y)
	self._object:set_y(y)
end

-- Lines 32-34
function HUDWeaponBase:show()
	self._object:set_visible(true)
end

-- Lines 36-40
function HUDWeaponBase:hide()
	self._object:set_visible(false)

	self._index = nil
end

-- Lines 42-48
function HUDWeaponBase:destroy()
	if self._index and managers.queued_tasks:has_task("hud_weapon_animate_" .. self._index) then
		managers.queued_tasks:unqueue("hud_weapon_animate_" .. self._index)
	end

	self._object:parent():remove(self._object)
end

-- Lines 51-53
function HUDWeaponBase:index()
	return self._index
end

-- Lines 55-57
function HUDWeaponBase:name_id()
	return self._tweak_data.name_id
end

-- Lines 59-61
function HUDWeaponBase:set_index(index)
	self._index = index
end

-- Lines 63-64
function HUDWeaponBase:set_current_clip(current_clip)
end

-- Lines 66-67
function HUDWeaponBase:set_current_left(current_left)
end

-- Lines 69-70
function HUDWeaponBase:set_max_clip(max_clip)
end

-- Lines 72-73
function HUDWeaponBase:set_max(max)
end

-- Lines 75-76
function HUDWeaponBase:set_no_ammo(empty)
end

-- Lines 78-85
function HUDWeaponBase:set_blocked(state)
	self._blocked = not not state

	if self:is_blocked() then
		-- Nothing
	end
end

-- Lines 87-89
function HUDWeaponBase:is_blocked()
	return self._blocked
end

-- Lines 91-105
function HUDWeaponBase:set_selected(selected)
	if self._index and managers.queued_tasks:has_task("hud_weapon_animate_" .. self._index) then
		managers.queued_tasks:unqueue("hud_weapon_animate_" .. self._index)
	end

	if selected and self._index then
		managers.queued_tasks:queue("hud_weapon_animate_" .. self._index, self.animate_alpha, self, selected, 0.01, nil)
	else
		self:animate_alpha(selected)
	end
end

-- Lines 107-110
function HUDWeaponBase:animate_alpha(selected)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_alpha"), selected and HUDWeaponBase.ALPHA_WHEN_SELECTED or HUDWeaponBase.ALPHA_WHEN_UNSELECTED)
end

-- Lines 112-133
function HUDWeaponBase:_animate_alpha(root_panel, new_alpha)
	local start_alpha = new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponBase.ALPHA_WHEN_UNSELECTED or HUDWeaponBase.ALPHA_WHEN_SELECTED
	local duration = 0.2
	local t = (self._object:alpha() - start_alpha) / (new_alpha - start_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, start_alpha, new_alpha - start_alpha, duration)

		self._object:set_alpha(current_alpha)

		if self._current_clip_text then
			self._current_clip_text:set_alpha(1)
		end
	end

	self._object:set_alpha(new_alpha)

	if self._current_clip_text then
		self._current_clip_text:set_alpha(1)
	end
end
