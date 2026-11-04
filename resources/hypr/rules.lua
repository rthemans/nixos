hl.window_rule({
    name = "disable-idle",
    match = { class = "steam_app.*" },

    idle_inhibit = "always",
})

hl.window_rule({
    name = "heroic",
    match = { class = "heroic" },

    workspace = 4,
})

hl.window_rule({
    name = "steam",
    match = { class = "steam" },

    workspace = 4,
})

hl.window_rule({
    name = "steam-app",
    match = { class = "steam_app.*" },

    monitor = "desc:AOC",
    workspace = 4,
})

hl.window_rule({
    name = "citrix",
    match = { class = "Wfica" },

    tile = true,
    monitor = "desc:AOC",
    workspace = 5,
})

hl.workspace_rule({ workspace = "1", on_created_empty = "qutebrowser" })
hl.workspace_rule({ workspace = "2", on_created_empty = "kitty tmux new -As0" })
hl.workspace_rule({ workspace = "3", on_created_empty = "discord" })
