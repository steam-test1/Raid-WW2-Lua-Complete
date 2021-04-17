VideoManager = VideoManager or class()

-- Lines 3-6
function VideoManager:init()
	self._videos = {}
	self._updators = {}
end

-- Lines 8-12
function VideoManager:add_video(video)
	local volume = managers.user:get_setting("master_volume")

	video:set_volume_gain(volume / 100)
	table.insert(self._videos, video)
end

-- Lines 14-16
function VideoManager:remove_video(video)
	table.delete(self._videos, video)
end

-- Lines 18-22
function VideoManager:volume_changed(volume)
	for _, video in ipairs(self._videos) do
		video:set_volume_gain(volume)
	end
end

-- Lines 24-26
function VideoManager:add_updator(id, callback)
	self._updators[id] = callback
end

-- Lines 28-30
function VideoManager:remove_updator(id)
	self._updators[id] = nil
end

-- Lines 32-36
function VideoManager:update(t, dt)
	for _, cb in pairs(self._updators) do
		cb(t, dt)
	end
end
