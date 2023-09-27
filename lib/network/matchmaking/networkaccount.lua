NetworkAccount = NetworkAccount or class()

-- Lines 3-6
function NetworkAccount:init()
	self._postprocess_username = callback(self, self, "_standard_username")

	self:set_lightfx()
end

-- Lines 8-9
function NetworkAccount:update()
end

-- Lines 11-12
function NetworkAccount:create_account(name, password, email)
end

-- Lines 14-15
function NetworkAccount:reset_password(name, email)
end

-- Lines 17-18
function NetworkAccount:login(name, password, cdkey)
end

-- Lines 20-21
function NetworkAccount:logout()
end

-- Lines 23-24
function NetworkAccount:register_callback(event, callback)
end

-- Lines 26-28
function NetworkAccount:register_post_username(cb)
	self._postprocess_username = cb
end

-- Lines 30-32
function NetworkAccount:username()
	return self._postprocess_username(self:username_id())
end

-- Lines 34-36
function NetworkAccount:username_id()
	return 0
end

-- Lines 38-40
function NetworkAccount:username_by_id()
	return ""
end

-- Lines 42-44
function NetworkAccount:signin_state()
	return "not signed in"
end

-- Lines 46-48
function NetworkAccount:set_lightfx()
end

-- Lines 50-52
function NetworkAccount:has_alienware()
	return self._has_alienware
end

-- Lines 54-59
function NetworkAccount:clan_tag()
	if managers.save.get_profile_setting and managers.save:get_profile_setting("clan_tag") and string.len(managers.save:get_profile_setting("clan_tag")) > 0 then
		return "[" .. managers.save:get_profile_setting("clan_tag") .. "]"
	end

	return ""
end

-- Lines 61-63
function NetworkAccount:_standard_username(name)
	return name
end

-- Lines 65-66
function NetworkAccount:set_playing(state)
end

-- Lines 68-69
function NetworkAccount:_load_globals()
end

-- Lines 71-72
function NetworkAccount:_save_globals()
end

-- Lines 74-75
function NetworkAccount:inventory_load()
end

-- Lines 77-78
function NetworkAccount:inventory_is_loading()
end

-- Lines 80-82
function NetworkAccount:inventory_reward(item)
	return false
end

-- Lines 84-85
function NetworkAccount:inventory_reward_dlc()
end

-- Lines 87-88
function NetworkAccount:inventory_reward_unlock(box, key)
end

-- Lines 90-91
function NetworkAccount:inventory_reward_open(item)
end

-- Lines 93-94
function NetworkAccount:inventory_outfit_refresh()
end

-- Lines 96-97
function NetworkAccount:inventory_outfit_verify(id, outfit_data, outfit_callback)
end

-- Lines 99-101
function NetworkAccount:inventory_outfit_signature()
	return ""
end

-- Lines 103-104
function NetworkAccount:inventory_repair_list(list)
end

-- Lines 106-108
function NetworkAccount:is_ready_to_close()
	return true
end
