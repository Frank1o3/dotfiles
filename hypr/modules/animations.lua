-- ~/.config/hypr/animations.lua
-- Curves and animation defaults tuned for smooth, modern feel.
return function()
	-- Distinct bezier curves for characterful motion
	hl.curve("snappy", { type = "bezier", points = { { 0.3, 0 }, { 0.1, 1.4 } } })  -- quick with slight overshoot
	hl.curve("dramatic", { type = "bezier", points = { { 0.18, 1.2 }, { 0.08, 1 } } }) -- pronounced entrance
	hl.curve("smooth", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } }) -- smooth easing
	hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

	-- Springs for different feels
	hl.curve("floaty", { type = "spring", mass = 1, stiffness = 45, dampening = 18 }) -- slow, airy
	hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 140, dampening = 9 }) -- energetic bounce
	hl.curve("snap", { type = "spring", mass = 1, stiffness = 220, dampening = 22 }) -- very quick settle

	-- Global baseline
	hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "smooth" })

	-- Border: quick color transitions
	hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "snappy" })

	-- Windows: make open/close feel characterful
	hl.animation({ leaf = "windows", enabled = true, speed = 5, spring = "snap", style = "slide" })
	hl.animation({ leaf = "windowsIn", enabled = true, speed = 10, spring = "bouncy", style = "popin 75%" })
	hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "snappy", style = "slide" })

	-- Fade: slightly quicker fade for popups and overlays
	hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.8, bezier = "smooth" })
	hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.6, bezier = "smooth" })
	hl.animation({ leaf = "fade", enabled = true, speed = 3.2, bezier = "linear" })

	-- Layers: slide in from top with a floaty settle
	hl.animation({ leaf = "layers", enabled = true, speed = 5.5, spring = "floaty" })
	hl.animation({ leaf = "layersIn", enabled = true, speed = 5.5, spring = "floaty", style = "slide top" })
	hl.animation({ leaf = "layersOut", enabled = true, speed = 3.2, bezier = "snappy", style = "slide top" })

	hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "smooth" })
	hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "smooth" })

	-- Workspaces: slower, dramatic slide + fade to emphasize transitions
	hl.animation({ leaf = "workspaces", enabled = true, speed = 9, bezier = "dramatic", style = "slidefade 28%" })
	hl.animation({ leaf = "workspacesIn", enabled = true, speed = 9, bezier = "dramatic", style = "slidefade 28%" })
	hl.animation({ leaf = "workspacesOut", enabled = true, speed = 9, bezier = "dramatic", style = "slidefade 28%" })

	-- Zoom: playful snap
	hl.animation({ leaf = "zoomFactor", enabled = true, speed = 10, spring = "snap" })
end
