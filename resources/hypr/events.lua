-- remplace layout-watch.sh : submap CLEAN tant qu'une fenêtre Citrix est active
local citrixActive = false
hl.on("window.active", function(win)
    local isCitrix = win and win.class and win.class:find("Wfica", 1, true) ~= nil
    if isCitrix and not citrixActive then
        citrixActive = true
        hl.dispatch(hl.dsp.submap("CLEAN"))
    elseif not isCitrix and citrixActive then
        citrixActive = false
        hl.dispatch(hl.dsp.submap("reset"))
    end
end)

-- remplace change-keyboard.sh : layout 1 (us/dvorak) pour StarCraft II
local kbMode = "default"
hl.on("window.active", function(win)
    if not win or not win.class or not win.title then
        return
    end
    local matched = win.class:find("steam_app_default", 1, true) ~= nil
        and win.title:find("StarCraft II", 1, true) ~= nil
    if matched and kbMode ~= "game" then
        kbMode = "game"
        hl.exec_cmd("hyprctl switchxkblayout current 1")
    elseif not matched and kbMode ~= "default" then
        kbMode = "default"
        hl.exec_cmd("hyprctl switchxkblayout current 0")
    end
end)
