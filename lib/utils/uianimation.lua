UIAnimation = UIAnimation or class()

-- Lines 4-10
function UIAnimation.linear(t, starting_value, change, duration)
	if duration <= t then
		return starting_value + change
	end

	return change * t / duration + starting_value
end

-- Lines 12-48
function UIAnimation.animate_text_glow(text, new_color, duration_per_letter, delay_between_letters, delay, initial_delay)
	if initial_delay ~= nil then
		wait(initial_delay)
	end

	while true do
		local number_of_letters = string.len(text:text())
		local original_color = text:color()
		local change_r = new_color.r - original_color.r
		local change_g = new_color.g - original_color.g
		local change_b = new_color.b - original_color.b
		local t = 0
		local duration = delay_between_letters * (number_of_letters - 1) + duration_per_letter

		while t < duration do
			local dt = coroutine.yield()
			t = t + dt

			for i = 1, number_of_letters do
				local blend_amount = Easing.sine_pulse((t - (i - 1) * delay_between_letters) / duration_per_letter)
				local current_r = original_color.r + blend_amount * change_r
				local current_g = original_color.g + blend_amount * change_g
				local current_b = original_color.b + blend_amount * change_b

				text:set_range_color(i - 1, i, Color(current_r, current_g, current_b))
			end
		end

		text:set_color(original_color)

		if delay ~= nil then
			wait(delay)
		end
	end
end
