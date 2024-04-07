NetworkAccount = NetworkAccount or class()

function NetworkAccount:init()
	self._postprocess_username = callback(self, self, "_standard_username")

	self:set_lightfx()
end

function NetworkAccount:update()
	return
end

function NetworkAccount:create_account(name, password, email)
	return
end

function NetworkAccount:reset_password(name, email)
	return
end

function NetworkAccount:login(name, password, cdkey)
	return
end

function NetworkAccount:logout()
	return
end

function NetworkAccount:register_callback(event, callback)
	return
end

function NetworkAccount:register_post_username(cb)
	self._postprocess_username = cb
end

function NetworkAccount:username()
	return self._postprocess_username(self:username_id())
end

function NetworkAccount:username_id()
	return 0
end

function NetworkAccount:username_by_id()
	return ""
end

function NetworkAccount:signin_state()
	return "not signed in"
end

function NetworkAccount:set_lightfx()
	return
end

function NetworkAccount:has_alienware()
	return self._has_alienware
end

function NetworkAccount:clan_tag()
	if managers.save.get_profile_setting and managers.save:get_profile_setting("clan_tag") and string.len(managers.save:get_profile_setting("clan_tag")) > 0 then
		return "[" .. managers.save:get_profile_setting("clan_tag") .. "]"
	end

	return ""
end

function NetworkAccount:_standard_username(name)
	return name
end

function NetworkAccount:set_playing(state)
	return
end

function NetworkAccount:_load_globals()
	return
end

function NetworkAccount:_save_globals()
	return
end

function NetworkAccount:inventory_load()
	return
end

function NetworkAccount:inventory_is_loading()
	return
end

function NetworkAccount:inventory_reward(item)
	return false
end

function NetworkAccount:inventory_reward_dlc()
	return
end

function NetworkAccount:inventory_reward_unlock(box, key)
	return
end

function NetworkAccount:inventory_reward_open(item)
	return
end

function NetworkAccount:inventory_outfit_refresh()
	return
end

function NetworkAccount:inventory_outfit_verify(id, outfit_data, outfit_callback)
	return
end

function NetworkAccount:inventory_outfit_signature()
	return ""
end

function NetworkAccount:inventory_repair_list(list)
	return
end

function NetworkAccount:is_ready_to_close()
	return true
end
