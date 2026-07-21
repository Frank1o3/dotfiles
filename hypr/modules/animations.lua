-- =========================
-- Curves
-- =========================

hl.curve("snappy", {
    type = "bezier",
    points = { {0.3, 0}, {0.1, 1.4} }
})

hl.curve("dramatic", {
    type = "bezier",
    points = { {0.18, 1.2}, {0.08, 1} }
})

hl.curve("smooth", {
    type = "bezier",
    points = { {0.25, 0.1}, {0.25, 1} }
})

hl.curve("linear", {
    type = "bezier",
    points = { {0, 0}, {1, 1} }
})

hl.curve("floaty", {
    type = "spring",
    mass = 1,
    stiffness = 45,
    dampening = 18
})

hl.curve("bouncy", {
    type = "spring",
    mass = 1,
    stiffness = 140,
    dampening = 9
})

hl.curve("snap", {
    type = "spring",
    mass = 1,
    stiffness = 220,
    dampening = 22
})

-- =========================
-- Animations
-- =========================

-- Border
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 4,
    bezier = "snappy"
})

-- Windows
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 5,
    spring = "snap"
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 8,
    spring = "bouncy",
    style = "popin 75%"
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 4,
    bezier = "snappy",
    style = "popin 75%"
})

-- Fade
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 1.8,
    bezier = "smooth"
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.6,
    bezier = "smooth"
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3,
    bezier = "linear"
})

-- Layers
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 5,
    spring = "floaty"
})

hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 5,
    spring = "floaty",
    style = "fade"
})

hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 3,
    bezier = "snappy",
    style = "fade"
})

hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 2,
    bezier = "smooth"
})

hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 2,
    bezier = "smooth"
})

-- Workspaces
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 7,
    bezier = "dramatic",
    style = "fade"
})

hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 7,
    bezier = "dramatic",
    style = "fade"
})

hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 7,
    bezier = "dramatic",
    style = "fade"
})

-- Zoom
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 10,
    spring = "snap"
})