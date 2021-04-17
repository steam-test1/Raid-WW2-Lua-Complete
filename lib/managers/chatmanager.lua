ChatManager = ChatManager or class()
ChatManager.GAME = 1
ChatManager.CREW = 2
ChatManager.GLOBAL = 3
ChatManager.MESSAGE_BUFFER_SIZE = 20

-- Lines 11-13
function ChatManager:init()
	self:_setup()
end

-- Lines 15-19
function ChatManager:_setup()
	self._chatlog = {}
	self._receivers = {}
	self._message_buffer = {}
end

-- Lines 21-42
function ChatManager:register_receiver(channel_id, receiver)
	self._receivers[channel_id] = self._receivers[channel_id] or {}
	self._message_buffer[channel_id] = self._message_buffer[channel_id] or {}

	table.insert(self._receivers[channel_id], receiver)

	local ct_cached_messages = #self._message_buffer[channel_id]
	local ct_chat_cached_messages = receiver:ct_cached_messages()

	if ct_chat_cached_messages < ct_cached_messages then
		for i = ct_chat_cached_messages + 1, ct_cached_messages do
			local message_data = self._message_buffer[channel_id][i]

			receiver:receive_message(message_data.name, message_data.peer_id, message_data.message, message_data.color, message_data.icon, message_data.system_message)
		end
	elseif ct_cached_messages == ct_chat_cached_messages and ct_cached_messages == ChatManager.MESSAGE_BUFFER_SIZE then
		for _, message_data in ipairs(self._message_buffer[channel_id]) do
			receiver:receive_message(message_data.name, message_data.peer_id, message_data.message, message_data.color, message_data.icon, message_data.system_message)
		end
	end
end

-- Lines 44-55
function ChatManager:unregister_receiver(channel_id, receiver)
	if not self._receivers[channel_id] then
		return
	end

	for i, rec in ipairs(self._receivers[channel_id]) do
		if rec == receiver then
			table.remove(self._receivers[channel_id], i)

			break
		end
	end
end

-- Lines 57-68
function ChatManager:send_message(channel_id, sender, message)
	if managers.network:session() then
		sender = managers.network:session():local_peer()

		managers.network:session():send_to_peers_ip_verified("send_chat_message", channel_id, message)
		self:receive_message_by_peer(channel_id, sender, message)
	else
		self:receive_message_by_name(channel_id, sender, message)
	end
end

-- Lines 70-74
function ChatManager:feed_system_message(channel_id, message)
	if not Global.game_settings.single_player then
		self:_receive_message(channel_id, nil, nil, message, Color.white, nil, true)
	end
end

-- Lines 76-87
function ChatManager:receive_message_by_peer(channel_id, peer, message)
	local color_id = peer:id()
	local color = tweak_data.chat_colors[color_id]

	self:_receive_message(channel_id, peer:name(), peer:id(), message, tweak_data.chat_colors[color_id], false)
end

-- Lines 89-91
function ChatManager:receive_message_by_name(channel_id, name, message)
	self:_receive_message(channel_id, name, nil, message, tweak_data.chat_colors[1])
end

-- Lines 93-95
function ChatManager:clear_message_buffer(channel_id)
	self._message_buffer[channel_id] = {}
end

-- Lines 97-105
function ChatManager:_cache_message(channel_id, name, peer_id, message, color, icon, system_message)
	table.insert(self._message_buffer[channel_id], {
		name = name,
		peer_id = peer_id,
		message = message,
		color = color,
		icon = icon,
		system_message = system_message
	})

	if ChatManager.MESSAGE_BUFFER_SIZE < #self._message_buffer[channel_id] then
		table.remove(self._message_buffer[channel_id], 1)
	end
end

-- Lines 107-121
function ChatManager:_receive_message(channel_id, name, peer_id, message, color, icon, system_message)
	if not self._receivers[channel_id] then
		return
	end

	self:_cache_message(channel_id, name, peer_id, message, color, icon, system_message)

	for i, receiver in ipairs(self._receivers[channel_id]) do
		receiver:receive_message(name, peer_id, message, color, icon, system_message)
	end
end

-- Lines 124-127
function ChatManager:save(data)
end

-- Lines 130-133
function ChatManager:load(data)
end
