MetalDetector = MetalDetector or class()
MetalDetector.DEFAULT_RANGE = 5000
MetalDetector.DEFAULT_SOUND_START = "transmission_sound"
MetalDetector.DEFAULT_SOUND_STOP = "transmission_sound_stop"
MetalDetector.DEFAULT_RTPC = "distance"

-- Lines 10-32
function MetalDetector:init(unit)
	self._unit = unit

	if not self._max_range then
		self._max_range = MetalDetector.DEFAULT_RANGE
	end

	if not self._sound_event_start then
		self._sound_event_start = MetalDetector.DEFAULT_SOUND_START
	end

	if not self._sound_event_stop then
		self._sound_event_stop = MetalDetector.DEFAULT_SOUND_STOP
	end

	if not self._sound_event_rtpc then
		self._sound_event_rtpc = MetalDetector.DEFAULT_RTPC
	end

	self._anim_gauge = Idstring(self._anim_gauge_name)
	self._anim_gauge_length = self._unit:anim_length(self._anim_gauge)
	self._soundsource = SoundDevice:create_source("metal_detector")

	self._soundsource:link(self._unit:get_object(Idstring(self._rp_name)))
end

-- Lines 36-57
function MetalDetector:update(unit, t, dt)
	local dist = self:poll_min_distances()

	if dist >= 0 and dist < self._max_range then
		local ratio = dist / self._max_range * 100

		if not self._sound_event then
			self._sound_event = self._soundsource:post_event(self._sound_event_start)
		end

		self._soundsource:set_rtpc(self._sound_event_rtpc, ratio)
		self._unit:anim_set_time(self._anim_gauge, self._anim_gauge_length * (100 - ratio) / 100)
		self._unit:anim_play(self._anim_gauge)
	else
		if self._sound_event then
			self._soundsource:post_event(self._sound_event_stop)

			self._sound_event = nil
		end

		self._unit:anim_stop(self._anim_gauge)
	end
end

-- Lines 59-76
function MetalDetector:poll_min_distances()
	local pos = self._unit:position()
	local min_dist = managers.mission:find_closest_metal_object_position(pos)

	for world_id, mission_manager in pairs(managers.worldcollection._missions) do
		local dist = mission_manager:find_closest_metal_object_position(pos)

		if dist >= 0 and (min_dist == -1 or dist < min_dist) then
			min_dist = dist
		end
	end

	return min_dist
end
