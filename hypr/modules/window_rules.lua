-- ~/.config/hypr/window_rules.lua

return function()
    -- Open kitty on workspace 1, tiled by default
    hl.window_rule({
        match = {
            class = "kitty",
            float = true
        },
        size = { 1000, 700 },
        center = true,
        enabled = true
    })
end
