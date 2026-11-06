local extensions = require("extensions")

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

extensions.submap("WINDOWS", {
    -- navigating windows (binde -> repeating)
    { keys = "h",         fn = hl.dsp.focus({ direction = "l" }),          opts = { repeating = true }, desc = "focus à gauche" },
    { keys = "l",         fn = hl.dsp.focus({ direction = "r" }),          opts = { repeating = true }, desc = "focus à droite" },
    { keys = "k",         fn = hl.dsp.focus({ direction = "u" }),          opts = { repeating = true }, desc = "focus en haut" },
    { keys = "j",         fn = hl.dsp.focus({ direction = "d" }),          opts = { repeating = true }, desc = "focus en bas" },
    { keys = "n",         fn = hl.dsp.window.cycle_next({ next = true }),  opts = { repeating = true }, desc = "fenêtre suivante" },
    { keys = "SHIFT + n", fn = hl.dsp.window.cycle_next({ next = false }), opts = { repeating = true }, desc = "fenêtre précédente" },

    -- moving windows
    { keys = "SHIFT + h", fn = hl.dsp.window.move({ direction = "l" }), desc = "déplacer à gauche" },
    { keys = "SHIFT + l", fn = hl.dsp.window.move({ direction = "r" }), desc = "déplacer à droite" },
    { keys = "SHIFT + k", fn = hl.dsp.window.move({ direction = "u" }), desc = "déplacer en haut" },
    { keys = "SHIFT + j", fn = hl.dsp.window.move({ direction = "d" }), desc = "déplacer en bas" },

    -- grouping windows
    { keys = "SHIFT + G", fn = hl.dsp.group.toggle(), desc = "grouper/dégrouper" },
    { keys = "N",         fn = hl.dsp.group.next(),   desc = "suivant dans le groupe" },
    { keys = "SHIFT + N", fn = hl.dsp.group.prev(),   desc = "précédent dans le groupe" },
    { keys = "ALT + L",         fn = hl.dsp.window.move({ into_group = "r" }),          desc = "insérer dans le groupe à droite" },
    { keys = "ALT + SHIFT + L", fn = hl.dsp.window.move({ into_or_create_group = "r" }), desc = "déplacer ou grouper à droite" },
    { keys = "ALT + H",         fn = hl.dsp.window.move({ into_group = "l" }),          desc = "insérer dans le groupe à gauche" },
    { keys = "ALT + SHIFT + H", fn = hl.dsp.window.move({ into_or_create_group = "l" }), desc = "déplacer ou grouper à gauche" },
    { keys = "ALT + K",         fn = hl.dsp.window.move({ into_group = "u" }),          desc = "insérer dans le groupe en haut" },
    { keys = "ALT + SHIFT + K", fn = hl.dsp.window.move({ into_or_create_group = "u" }), desc = "déplacer ou grouper en haut" },
    { keys = "ALT + J",         fn = hl.dsp.window.move({ into_group = "d" }),          desc = "insérer dans le groupe en bas" },
    { keys = "ALT + SHIFT + J", fn = hl.dsp.window.move({ into_or_create_group = "d" }), desc = "déplacer ou grouper en bas" },
    { keys = "X",         fn = hl.dsp.window.move({ out_of_group = true }), desc = "sortir du groupe" },

    -- window actions
    { keys = "Q",             fn = hl.dsp.window.close(),                             desc = "fermer la fenêtre" },
    { keys = "F",             fn = hl.dsp.window.fullscreen({ mode = "fullscreen" }), desc = "plein écran" },
    { keys = "SHIFT + F",     fn = hl.dsp.window.fullscreen({ mode = "maximized" }),  desc = "maximiser" },
    { keys = "SHIFT + SPACE", fn = hl.dsp.window.float({ action = "toggle" }),        desc = "flotter/déflotter" },
})

extensions.submap("GROUPS", {
    { keys = "G",         fn = hl.dsp.group.toggle(),                              desc = "grouper/dégrouper" },
    { keys = "N",         fn = hl.dsp.group.next(),                                desc = "suivant dans le groupe" },
    { keys = "SHIFT + N", fn = hl.dsp.group.prev(),                                desc = "précédent dans le groupe" },
    { keys = "L",         fn = hl.dsp.window.move({ into_group = "r" }),           desc = "insérer dans le groupe à droite" },
    { keys = "SHIFT + L", fn = hl.dsp.window.move({ into_or_create_group = "r" }), desc = "déplacer ou grouper à droite" },
    { keys = "H",         fn = hl.dsp.window.move({ into_group = "l" }),           desc = "insérer dans le groupe à gauche" },
    { keys = "SHIFT + H", fn = hl.dsp.window.move({ into_or_create_group = "l" }), desc = "déplacer ou grouper à gauche" },
    { keys = "X",         fn = hl.dsp.window.move({ out_of_group = true }),        desc = "sortir du groupe" },
})

extensions.submap("SOUND", {
    { keys = "K", fn = hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  opts = { locked = true, repeating = true }, desc = "volume +5%" },
    { keys = "J", fn = hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  opts = { locked = true, repeating = true }, desc = "volume -5%" },
    { keys = "M", fn = hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), opts = { locked = true },                   desc = "couper le son" },
})

extensions.submap("POWER", {
    { keys = "R", fn = function() extensions.powerAction("reboot")    hl.dispatch(hl.dsp.submap("reset")) end, desc = "redémarrer" },
    { keys = "P", fn = function() extensions.powerAction("poweroff")  hl.dispatch(hl.dsp.submap("reset")) end, desc = "éteindre" },
    { keys = "H", fn = function() extensions.powerAction("hibernate") hl.dispatch(hl.dsp.submap("reset")) end, desc = "hiberner" },
    { keys = "S", fn = function() extensions.powerAction("suspend")   hl.dispatch(hl.dsp.submap("reset")) end, desc = "suspendre" },
    { keys = "O", fn = function() extensions.powerAction("poweroff")  hl.dispatch(hl.dsp.submap("reset")) end, desc = "éteindre" },
})

-- CLEAN reste passant (session Citrix) : pas de ESCAE/?/catchall
extensions.submap("CLEAN", {
    { keys = "SUPER + code:10", fn = hl.dsp.focus({ workspace = "1" }), desc = "aller au workspace 1" },
    { keys = "SUPER + code:11", fn = hl.dsp.focus({ workspace = "2" }), desc = "aller au workspace 2" },
    { keys = "SUPER + code:12", fn = hl.dsp.focus({ workspace = "3" }), desc = "aller au workspace 3" },
    { keys = "SUPER + code:13", fn = hl.dsp.focus({ workspace = "4" }), desc = "aller au workspace 4" },
    { keys = "SUPER + code:14", fn = hl.dsp.focus({ workspace = "5" }), desc = "aller au workspace 5" },
    { keys = "SUPER + F10",     fn = hl.dsp.submap("reset"),            desc = "quitter le submap CLEAN" },
}, { catchall = false })
