HUDWeaponBase = HUDWeaponBase or class()
HUDWeaponBase.ALPHA_WHEN_SELECTED = 1
HUDWeaponBase.ALPHA_WHEN_UNSELECTED = 0.5

function HUDWeaponBase:init(index, weapons_panel, tweak_data)
	self._tweak_data = tweak_data
end

function HUDWeaponBase:panel()
	return self._object
end

function HUDWeaponBase:w()
	return self._object:w()
end

function HUDWeaponBase:h()
	return self._object:h()
end

function HUDWeaponBase:set_x(x)
	self._object:set_x(x)
end

function HUDWeaponBase:set_y(y)
	self._object:set_y(y)
end

function HUDWeaponBase:show()
	self._object:set_visible(true)
end

function HUDWeaponBase:hide()
	self._object:set_visible(false)

	self._index = nil
end

function HUDWeaponBase:destroy()
	self._object:parent():remove(self._object)
end

function HUDWeaponBase:index()
	return self._index
end

function HUDWeaponBase:name_id()
	return self._tweak_data.name_id
end

function HUDWeaponBase:set_index(index)
	self._index = index
end

function HUDWeaponBase:set_current_clip(current_clip)
	return
end

function HUDWeaponBase:set_current_left(current_left)
	return
end

function HUDWeaponBase:set_max_clip(max_clip)
	return
end

function HUDWeaponBase:set_max(max)
	return
end

function HUDWeaponBase:set_no_ammo(empty)
	return
end

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

function HUDWeaponBase:animate_alpha(selected)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_alpha"), selected and HUDWeaponBase.ALPHA_WHEN_SELECTED or HUDWeaponBase.ALPHA_WHEN_UNSELECTED)
end

function HUDWeaponBase:_animate_alpha(root_panel, new_alpha)
	local start_alpha = new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponBase.ALPHA_WHEN_UNSELECTED or HUDWeaponBase.ALPHA_WHEN_SELECTED
	local duration = 0.2
	local t = (self._object:alpha() - start_alpha) / (new_alpha - start_alpha) * duration

	while t < duration do
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
