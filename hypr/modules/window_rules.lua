-- ~/.config/hypr/window_rules.lua

return function()
    hl.window_rule({
        -- Fix some dragging issues with XWayland
        name     = "fix-xwayland-drags",
        match    = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },

        no_focus = true,
        enabled  = true
    })

    hl.window_rule({
        -- Fix some dragging issues with XWayland
        name     = "fix-xwayland-drags",
        match    = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },
        enabled  = true,
        no_focus = true,
    })

    hl.window_rule({
        name = "BloodStrike",
        match = { initial_class = "steam_app_3199170" },
        fullscreen = false,
        persistent_size = true,
        size = { 1280, 720 }, -- 720p or 1280x720
        float = true,
        center = true,
        enabled = true
    })

    hl.window_rule({
        name = "Picture in Picture",
        match = {
            title = "Picture in Picture",
            initial_title = "Picture in Picture"
        },
        float = true,
        persistent_size = true,
        size = { 426, 240 }, -- 240p or 426x240
        enabled = true,
    })

    local suppressMaximizeRule = hl.window_rule({
        -- Ignore maximize requests from all apps. You'll probably like this.
        name           = "suppress-maximize-events",
        match          = { class = ".*" },

        suppress_event = "maximize"
    })
    suppressMaximizeRule:set_enabled(true)
end
