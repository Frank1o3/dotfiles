-- ~/.config/hypr/monitors.lua

local function parse_mode(mode)
	local w, h, hz = mode:match("(%d+)x(%d+)@([%d%.]+)")

	return {
		width = tonumber(w) or 0,
		height = tonumber(h) or 0,
		refresh = tonumber(hz) or 60,
		raw = mode,
	}
end

local function best_mode(mon)
	local best = nil
	local best_pixels = 0

	for _, mode in ipairs(mon.availableModes or {}) do
		local parsed = parse_mode(mode)

		local pixels = parsed.width * parsed.height

		if pixels > best_pixels then
			best_pixels = pixels
			best = parsed
		elseif pixels == best_pixels and best then
			if parsed.refresh > best.refresh then
				best = parsed
			end
		end
	end

	return best
end

return function()
	local monitors = hl.get_monitors()

	if not monitors or #monitors == 0 then
		return
	end

	local configured = {}

	--------------------------------------------------
	-- Determine best monitor
	--------------------------------------------------

	local primary = nil
	local primary_pixels = 0

	for _, mon in ipairs(monitors) do
		local mode = best_mode(mon)

		if mode then
			local pixels = mode.width * mode.height

			if pixels > primary_pixels then
				primary_pixels = pixels
				primary = {
					monitor = mon,
					mode = mode,
				}
			end
		end
	end

	if not primary then
		return
	end

	--------------------------------------------------
	-- Configure primary monitor
	--------------------------------------------------

	hl.monitor({
		output = primary.monitor.name,

		mode = primary.mode.raw,

		position = "0x0",

		scale = 1.0,

		cm = "srgb",
	})

	table.insert(configured, primary.monitor.name)

	--------------------------------------------------
	-- Configure secondary monitors
	--------------------------------------------------

	local x_offset = primary.mode.width

	for _, mon in ipairs(monitors) do
		if mon.name ~= primary.monitor.name then
			local mode = best_mode(mon)

			if mode then
				hl.monitor({
					output = mon.name,

					mode = mode.raw,

					position = x_offset .. "x0",

					scale = 1.0,

					cm = "srgb",
				})

				x_offset = x_offset + mode.width
			end
		end
	end

	--------------------------------------------------
	-- Workspace assignment
	--------------------------------------------------

	for i = 1, 10 do
		hl.workspace({
			id = i,
			monitor = primary.monitor.name,
		})
	end
end
