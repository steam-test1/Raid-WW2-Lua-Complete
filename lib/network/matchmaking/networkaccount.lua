NetworkAccount = NetworkAccount or class()

-- Lines 3-5
function NetworkAccount:init()
	self._postprocess_username = callback(self, self, "_standard_username")
end

-- Lines 7-8
function NetworkAccount:update()
end

-- Lines 10-11
function NetworkAccount:create_account(name, password, email)
end

-- Lines 13-14
function NetworkAccount:reset_password(name, email)
end

-- Lines 16-17
function NetworkAccount:login(name, password, cdkey)
end

-- Lines 19-20
function NetworkAccount:logout()
end

-- Lines 22-23
function NetworkAccount:register_callback(event, callback)
end

-- Lines 25-27
function NetworkAccount:register_post_username(cb)
	self._postprocess_username = cb
end

-- Lines 29-31
function NetworkAccount:username()
	return self._postprocess_username(self:username_id())
end

-- Lines 33-35
function NetworkAccount:username_id()
	return 0
end

-- Lines 37-39
function NetworkAccount:username_by_id()
	return ""
end

-- Lines 41-43
function NetworkAccount:signin_state()
	return "not signed in"
end

-- Lines 45-50
function NetworkAccount:clan_tag()
	if managers.save.get_profile_setting and managers.save:get_profile_setting("clan_tag") and string.len(managers.save:get_profile_setting("clan_tag")) > 0 then
		return "[" .. managers.save:get_profile_setting("clan_tag") .. "]"
	end

	return ""
end

-- Lines 52-54
function NetworkAccount:_standard_username(name)
	return name
end

-- Lines 56-57
function NetworkAccount:set_playing(state)
end

-- Lines 59-60
function NetworkAccount:_load_globals()
end

-- Lines 62-63
function NetworkAccount:_save_globals()
end

-- Lines 65-66
function NetworkAccount:inventory_load()
end

-- Lines 68-69
function NetworkAccount:inventory_is_loading()
end

-- Lines 71-73
function NetworkAccount:inventory_reward(item)
	return false
end

-- Lines 75-76
function NetworkAccount:inventory_reward_dlc()
end

-- Lines 78-79
function NetworkAccount:inventory_reward_unlock(box, key)
end

-- Lines 81-82
function NetworkAccount:inventory_reward_open(item)
end

-- Lines 84-85
function NetworkAccount:inventory_outfit_refresh()
end

-- Lines 87-88
function NetworkAccount:inventory_outfit_verify(id, outfit_data, outfit_callback)
end

-- Lines 90-92
function NetworkAccount:inventory_outfit_signature()
	return ""
end

-- Lines 94-95
function NetworkAccount:inventory_repair_list(list)
end

-- Lines 97-99
function NetworkAccount:is_ready_to_close()
	return true
end
