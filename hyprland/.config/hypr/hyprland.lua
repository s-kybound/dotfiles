-- Hyprland config (lua). hyprlang/.conf is deprecated since 0.55.
-- For a full list of options, see https://wiki.hypr.land/Configuring/Start/
--
-- You can split this configuration into multiple files and pull them in with
-- require("myColors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Desktop: 2K (Q27G4_WS) is main, 1K (25B36X) sits to its left rotated 270deg.
-- Rotated 1920x1080 occupies 1080x1920 in screen space, so it's offset by
-- -1080 on the x axis to sit flush against the main display's left edge.
-- Matched by description, not connector: the DP/HDMI port names shift around.
hl.monitor({ output = "desc:AOC Q27G4_WS XI7S3HA007799", mode = "2560x1440@200", position = "0x0",     scale = 1 })
hl.monitor({ output = "desc:AOC 25B36X 2S0R7HA001993",  mode = "1920x1080@144", position = "-1080x0", scale = 1, transform = 3 })

-- Laptop-only setups (no explicit rule above matched): use the built-in panel.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.6 })

-- Fallback for anything else not explicitly configured above.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal           = "kitty"
local fileManager        = terminal .. " ranger"
local menu               = "wofi --show drun"
local notificationCentre = "swaync"
local wallpaper          = "hyprpaper"
local statusBar          = "qs"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- exec_cmd spawns asynchronously, so no need for `& disown`.
hl.on("hyprland.start", function()
    hl.exec_cmd(terminal)
    hl.exec_cmd(notificationCentre)
    hl.exec_cmd(wallpaper)
    hl.exec_cmd(statusBar)

    -- keyring startup
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("dbus-update-activation-environment --systemd " ..
        "DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- makes any electron file play nice
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 15,

        border_size = 2,

        -- Catppuccin Mocha accents (lavender -> mauve), static gradient - no
        -- borderangle animation, to keep the battery-life win from before.
        col = {
            active_border   = { colors = { "rgba(b4befeff)", "rgba(cba6f7ff)" }, angle = 45 },
            inactive_border = "rgba(6c7086aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 20,

        -- Inactive windows
        dim_inactive = true,
        dim_strength = 0.25,

        -- inactive_opacity = 0.9,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 3,
            noise    = 0.025,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- yes, please :)
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })

-- windows - in -> open, out -> close
hl.animation({ leaf = "windows",    enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 1.5, bezier = "linear", style = "popin 0%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "linear", style = "popin 0%" })

hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })

hl.animation({ leaf = "layers",    enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",  enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 7, bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 7, bezier = "easeOutQuint",   style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 7, bezier = "easeOutQuint",   style = "slidefade" })

hl.animation({ leaf = "border", enabled = true, speed = 5.0, bezier = "easeOutQuint" })
-- figure out how to disable this on battery
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 200, bezier = "linear", style = "loop" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper  = 1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo    = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering = true, -- disables the random splash text quote overlay
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 0,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

-- See https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E",     hl.dsp.exit())
hl.bind(mainMod .. " + C",             hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + X",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + J",             hl.dsp.layout("togglesplit"))    -- dwindle
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move with mainMod + shift + arrow keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace (silently) with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local el = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",             hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), el)
hl.bind("XF86AudioLowerVolume",             hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        el)
hl.bind("XF86AudioMute",                    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       el)
hl.bind("XF86AudioMicMute",                 hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     el)
hl.bind("XF86MonBrightnessUp",              hl.dsp.exec_cmd("brightnessctl s 10%+"),                             el)
hl.bind("XF86MonBrightnessDown",            hl.dsp.exec_cmd("brightnessctl s 10%-"),                             el)
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("brightnessctl s 10%+"),                           el)
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("brightnessctl s 10%-"),                           el)

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd(
    'grim -g "$(slurp)" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png'))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    -- Ignore maximize requests from apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
