HUDWeaponBase = HUDWeaponBase or class()
HUDWeaponBase.ALPHA_WHEN_SELECTED = 1
HUDWeaponBase.ALPHA_WHEN_UNSELECTED = 0.5

-- Lines 7-9
function HUDWeaponBase:init(index, weapons_panel, tweak_data)
	self._tweak_data = tweak_data
end

-- Lines 11-13
function HUDWeaponBase:panel()
	return self._object
end

-- Lines 15-17
function HUDWeaponBase:w()
	return self._object:w()
end

-- Lines 19-21
function HUDWeaponBase:h()
	return self._object:h()
end

-- Lines 23-25
function HUDWeaponBase:set_x(x)
	self._object:set_x(x)
end

-- Lines 27-29
function HUDWeaponBase:set_y(y)
	self._object:set_y(y)
end

-- Lines 31-33
function HUDWeaponBase:show()
	self._object:set_visible(true)
end

-- Lines 35-39
function HUDWeaponBase:hide()
	self._object:set_visible(false)

	self._index = nil
end

-- Lines 41-43
function HUDWeaponBase:destroy()
	self._object:parent():remove(self._object)
end

-- Lines 46-48
function HUDWeaponBase:index()
	return self._index
end

-- Lines 50-52
function HUDWeaponBase:name_id()
	return self._tweak_data.name_id
end

-- Lines 54-56
function HUDWeaponBase:set_index(index)
	self._index = index
end

-- Lines 58-59
function HUDWeaponBase:set_current_clip(current_clip)
end

-- Lines 61-62
function HUDWeaponBase:set_current_left(current_left)
end

-- Lines 64-65
function HUDWeaponBase:set_max_clip(max_clip)
end

-- Lines 67-68
function HUDWeaponBase:set_max(max)
end

-- Lines 70-73
function HUDWeaponBase:set_selected(selected)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_alpha"), selected and HUDWeaponBase.ALPHA_WHEN_SELECTED or HUDWeaponBase.ALPHA_WHEN_UNSELECTED)
end

-- Lines 76-97
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
