-- media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- cycle through (cyclenext "visible" n'a pas d'équivalent Lua -> hyprctl)
hl.bind("ALT + CTRL + code:23",       hl.dsp.exec_cmd("hyprctl dispatch cyclenext visible next"), { repeating = true })
hl.bind("ALT + CTRL + SHIFT + code:23", hl.dsp.exec_cmd("hyprctl dispatch cyclenext visible prev"), { repeating = true })
hl.bind("ALT + code:23",            hl.dsp.window.cycle_next({ next = true }),  { repeating = true })
hl.bind("ALT + SHIFT + code:23",      hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind("SUPER + code:23",          hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + SHIFT + code:23",    hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + N",                hl.dsp.focus({ workspace = "empty" }), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- utils
hl.bind("SUPER + L",       hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + code:70",   hl.dsp.window.close())

-- Programs
hl.bind("SUPER + SPACE",     hl.dsp.global("caelestia:launcher"))
hl.bind("SUPER + SHIFT + s",   hl.dsp.exec_cmd("hyprshot --clipboard-only -m region"))

-- Submaps
hl.bind("SUPER + W",   hl.dsp.submap("WINDOWS"))
hl.bind("SUPER + G",   hl.dsp.submap("GROUPS"))
hl.bind("SUPER + v",   hl.dsp.submap("SOUND"))
hl.bind("SUPER + p",   hl.dsp.submap("POWER"))
hl.bind("SUPER + F10", hl.dsp.submap("CLEAN"))

-- movements
hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = "4" }))
hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = "5" }))

-- move to workspaces
hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + code:14", hl.dsp.window.move({ workspace = "5" }))

-- move something to monitor
hl.bind("SUPER + code:113",        hl.dsp.focus({ monitor = "1" }))
hl.bind("SUPER + SHIFT + code:113",  hl.dsp.workspace.move({ monitor = "1" }))
hl.bind("SUPER + code:114",        hl.dsp.focus({ monitor = "0" }))
hl.bind("SUPER + SHIFT + code:114",  hl.dsp.workspace.move({ monitor = "0" }))

hl.bind("code:95",            hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SHIFT + code:95",    hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

hl.define_submap("WINDOWS", function()
    -- navigating windows
    hl.bind("h",         hl.dsp.focus({ direction = "l" }))
    hl.bind("l",         hl.dsp.focus({ direction = "r" }))
    hl.bind("k",         hl.dsp.focus({ direction = "u" }))
    hl.bind("j",         hl.dsp.focus({ direction = "d" }))
    hl.bind("n",         hl.dsp.window.cycle_next({ next = true }))
    hl.bind("SHIFT + n", hl.dsp.window.cycle_next({ next = false }))

    -- moving windows
    hl.bind("SHIFT + h", hl.dsp.window.move({ direction = "l" }))
    hl.bind("SHIFT + l", hl.dsp.window.move({ direction = "r" }))
    hl.bind("SHIFT + k", hl.dsp.window.move({ direction = "u" }))
    hl.bind("SHIFT + j", hl.dsp.window.move({ direction = "d" }))

    -- grouping windows
    hl.bind("SHIFT + G", hl.dsp.group.toggle())
    hl.bind("N",         hl.dsp.group.next())
    hl.bind("SHIFT + N", hl.dsp.group.prev())
    hl.bind("ALT + L",        hl.dsp.window.move({ into_group = "r" }))
    hl.bind("ALT + SHIFT + L",  hl.dsp.window.move({ into_or_create_group = "r" }))
    hl.bind("ALT + H",        hl.dsp.window.move({ into_group = "l" }))
    hl.bind("ALT + SHIFT + H",  hl.dsp.window.move({ into_or_create_group = "l" }))
    hl.bind("ALT + K",        hl.dsp.window.move({ into_group = "u" }))
    hl.bind("ALT + SHIFT + K",  hl.dsp.window.move({ into_or_create_group = "u" }))
    hl.bind("ALT + J",        hl.dsp.window.move({ into_group = "d" }))
    hl.bind("ALT + SHIFT + J",  hl.dsp.window.move({ into_or_create_group = "d" }))
    hl.bind("X",         hl.dsp.window.move({ out_of_group = true }))

    -- window actions
    hl.bind("Q",             hl.dsp.window.close())
    hl.bind("F",             hl.dsp.window.fullscreen({ mode = "fullscreen" }))
    hl.bind("SHIFT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }))
    hl.bind("SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
    hl.bind("catchall",  function() hl.exec_cmd('notify-send "Press ESC to go in default"') end)
end)

hl.define_submap("GROUPS", function()
    hl.bind("G",         hl.dsp.group.toggle())
    hl.bind("N",         hl.dsp.group.next())
    hl.bind("SHIFT + N", hl.dsp.group.prev())
    hl.bind("L",         hl.dsp.window.move({ into_group = "r" }))
    hl.bind("SHIFT + L", hl.dsp.window.move({ into_or_create_group = "r" }))
    hl.bind("H",         hl.dsp.window.move({ into_group = "l" }))
    hl.bind("SHIFT + H", hl.dsp.window.move({ into_or_create_group = "l" }))
    hl.bind("X",         hl.dsp.window.move({ out_of_group = true }))

    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
    hl.bind("catchall",  function() hl.exec_cmd('notify-send "Presc ESC to go in default"') end)
end)

hl.define_submap("SOUND", function()
    hl.bind("K", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("J", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
    hl.bind("M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
    hl.bind("catchall",  function() hl.exec_cmd('notify-send "Press ESC to go in default"') end)
end)

hl.define_submap("POWER", function()
    local action = function(name)
        return function()
            hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/Scripts/power-action.sh " .. name)
            hl.dispatch(hl.dsp.submap("reset"))
        end
    end

    hl.bind("R", action("reboot"))
    hl.bind("P", action("poweroff"))
    hl.bind("H", action("hibernate"))
    hl.bind("S", action("suspend"))
    hl.bind("O", action("poweroff"))

    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
    hl.bind("catchall",  function() hl.exec_cmd('notify-send "Press ESC to go in default"') end)
end)

hl.define_submap("CLEAN", function()
    hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = "1" }))
    hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = "2" }))
    hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = "3" }))
    hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = "4" }))
    hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = "5" }))

    hl.bind("SUPER + F10", hl.dsp.submap("reset"))
end)
