Utl = {}

function Utl.mul_to_string_percent(mul)
	local val = string.format("%.2f", tostring(mul))

	val = string.sub(val, 3, 4)

	return val
end
