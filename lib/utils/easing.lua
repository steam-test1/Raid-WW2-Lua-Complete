Easing = Easing or class()

function Easing.linear(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return change * t / duration + starting_value
end

function Easing.quadratic_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return change * t * t + starting_value
end

function Easing.quadratic_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return -change * t * (t - 2) + starting_value
end

function Easing.quadratic_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t + starting_value
	end

	t = t - 1

	return -(change / 2) * (t * (t - 2) - 1) + starting_value
end

function Easing.cubic_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return change * t * t * t + starting_value
end

function Easing.cubic_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration
	t = t - 1

	return change * (t * t * t + 1) + starting_value
end

function Easing.cubic_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t * t + starting_value
	end

	t = t - 2

	return change / 2 * (t * t * t + 2) + starting_value
end

function Easing.quartic_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return change * t * t * t * t + starting_value
end

function Easing.quartic_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration
	t = t - 1

	return -change * (t * t * t * t - 1) + starting_value
end

function Easing.quartic_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t * t * t + starting_value
	end

	t = t - 2

	return -(change / 2) * (t * t * t * t - 2) + starting_value
end

function Easing.quintic_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return change * t * t * t * t * t + starting_value
end

function Easing.quintic_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration
	t = t - 1

	return change * (t * t * t * t * t + 1) + starting_value
end

function Easing.quintic_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t * t * t * t + starting_value
	end

	t = t - 2

	return change / 2 * (t * t * t * t * t + 2) + starting_value
end

function Easing.sinusoidal_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return -change * math.cos(t / duration * (math.pi / 2)) + change + starting_value
end

function Easing.sinusoidal_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return change * math.sin(t / duration * (math.pi / 2)) + starting_value
end

function Easing.sinusoidal_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return -change / 2 * (math.cos(math.pi * t / duration) - 1) + starting_value
end

function Easing.exponential_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return change * math.pow(2, 10 * (t / duration - 1)) + starting_value
end

function Easing.exponential_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return change * (-math.pow(2, -10 * t / duration) + 1) + starting_value
end

function Easing.exponential_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * math.pow(2, 10 * (t - 1)) + starting_value
	end

	t = t - 1

	return change / 2 * (-math.pow(2, -10 * t) + 2) + starting_value
end

function Easing.circular_in(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / duration

	return -change * (math.sqrt(1 - t * t) - 1) + starting_value
end

function Easing.circular_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t - 1

	return change * math.sqrt(1 - t * t) + starting_value
end

function Easing.circular_in_out(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	t = t / (duration / 2)

	if t < 1 then
		return -change / 2 * (math.sqrt(1 - t * t) - 1) + starting_value
	end

	t = t - 2

	return change / 2 * (math.sqrt(1 - t * t) + 1) + starting_value
end

function Easing.sine_pulse(t, duration)
	duration = duration or 1

	if t <= 0 then
		return 0
	elseif t > 0 and t <= duration then
		return math.sin(t / duration * 2 * 180 - 90) + 1
	end

	return 0
end

function Easing.sine_step(t)
	if t <= 0 then
		return 0
	elseif t > 0 and t <= 1 then
		return math.sin(t * 180 - 90) + 1
	end

	return 1
end
