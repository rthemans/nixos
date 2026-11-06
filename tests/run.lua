-- Tests hors-ligne de la configuration Lua Hyprland (API hl mockée par tests/stub.lua).
-- Usage: lua tests/run.lua [chemin-vers-resources/hypr]
local scriptDir = ((arg and arg[0] or ""):match("^(.*/)") or "")
local baseDir = (arg and arg[1]) or "resources/hypr"
package.path = scriptDir .. "?.lua;" .. baseDir .. "/?.lua;" .. package.path

local stub = require("stub")
_G.hl = stub.hl
local calls = stub.calls

local passCount, failCount = 0, 0

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passCount = passCount + 1
        print("PASS  " .. name)
    else
        failCount = failCount + 1
        print("FAIL  " .. name)
        print("      " .. tostring(err))
    end
end

local function assertEq(actual, expected, msg)
    if actual ~= expected then
        error((msg or "assertEq") .. ": attendu " .. tostring(expected) .. ", obtenu " .. tostring(actual), 2)
    end
end

local function assertTrue(v, msg)
    if not v then
        error(msg or "assertTrue a échoué", 2)
    end
end

local function contains(haystack, needle)
    return type(haystack) == "string" and haystack:find(needle, 1, true) ~= nil
end

local MODULES = { "settings", "start", "binds", "rules", "events", "extensions" }

local function clearUserModules()
    for _, name in ipairs(MODULES) do
        package.loaded[name] = nil
    end
end

local function loadAll()
    stub.reset()
    clearUserModules()
    require("settings")
    require("start")
    require("binds")
    require("rules")
    require("events")
end

local function clearRecords(...)
    for _, name in ipairs({ ... }) do
        local list = calls[name]
        for i = #list, 1, -1 do list[i] = nil end
    end
end

local function findBind(keys, submap)
    for _, b in ipairs(calls.binds) do
        if b.keys == keys and (submap == nil or b.submap == submap) then
            return b
        end
    end
end

local function submapBinds(submap)
    local out = {}
    for _, b in ipairs(calls.binds) do
        if b.submap == submap then
            table.insert(out, b)
        end
    end
    return out
end

local function findEvent(event)
    for _, e in ipairs(calls.events) do
        if e.event == event then
            return e
        end
    end
end

local function runTimers()
    for _, t in ipairs(calls.timers) do
        t.cb()
    end
end

local function callWindowActiveHandlers(win)
    for _, e in ipairs(calls.events) do
        if e.event == "window.active" then
            e.cb(win)
        end
    end
end

-- 1. Chargement complet (équivaut à un reload de la config)
test("chargement des 5 fichiers de config sans erreur", function()
    loadAll()
    assertEq(#calls.submaps, 5, "nombre de submaps")
    local names = {}
    for _, n in ipairs(calls.submaps) do names[n] = true end
    for _, expected in ipairs({ "WINDOWS", "GROUPS", "SOUND", "POWER", "CLEAN" }) do
        assertTrue(names[expected], "submap manquant: " .. expected)
    end
    assertTrue(#calls.binds >= 90, "trop peu de binds enregistrés: " .. #calls.binds)
    assertTrue(#calls.windowRules == 5, "nombre de window rules: " .. #calls.windowRules)
    assertEq(#calls.workspaceRules, 3, "nombre de workspace rules")
    assertEq(#calls.events, 3, "nombre d'événements (1 start + 2 window.active)")
end)

-- 2. settings.lua
test("settings: layouts clavier", function()
    loadAll()
    assertEq(#calls.config, 1, "un seul appel hl.config")
    local input = calls.config[1].input
    assertTrue(input ~= nil, "bloc input manquant")
    assertEq(input.kb_layout, "fr,us, us", "kb_layout")
    assertEq(input.kb_variant, "bepo, , dvorak", "kb_variant")
end)

-- 3. start.lua
test("start: commandes de démarrage", function()
    loadAll()
    ev = nil
    stub.reset()
    clearUserModules()
    require("start")
    ev = findEvent("hyprland.start")
    assertTrue(ev ~= nil, "hyprland.start non enregistré")
    ev.cb()
    assertEq(#calls.exec, 6, "nombre d'exec au démarrage")
    local all = table.concat(calls.exec, "\n")
    for _, cmd in ipairs({ "caelestia-shell", "nm-applet --indicator", "hyprlock",
                           "hyprpolkitagent", "swaync", "mammouth web" }) do
        assertTrue(contains(all, cmd), "commande de démarrage manquante: " .. cmd)
    end
end)

-- 4. binds.lua : binds clés
test("binds: binds principaux", function()
    loadAll()

    local global = findBind("SUPER + SPACE")
    assertTrue(global ~= nil, "SUPER + SPACE manquant")
    assertEq(global.dsp._dsp, "hl.dsp.global", "dispatcher de SUPER + SPACE")
    assertEq(global.dsp._args[1], "caelestia:launcher", "argument global")

    local powerEntry = findBind("SUPER + p")
    assertTrue(powerEntry ~= nil, "SUPER + p manquant")
    assertEq(powerEntry.dsp._dsp, "hl.dsp.submap", "SUPER + p doit entrer dans un submap")
    assertEq(powerEntry.dsp._args[1], "POWER", "SUPER + p doit activer POWER")

    local cleanEntry = findBind("SUPER + F10")
    assertTrue(cleanEntry ~= nil and cleanEntry.dsp._args[1] == "CLEAN", "SUPER + F10 -> CLEAN manquant")

    local lock = findBind("SUPER + L")
    assertTrue(lock ~= nil and lock.dsp._dsp == "hl.dsp.exec_cmd", "SUPER + L manquant")
    assertTrue(contains(lock.dsp._args[1], "hyprlock"), "SUPER + L doit lancer hyprlock")

    local movews = findBind("SUPER + SHIFT + code:10")
    assertTrue(movews ~= nil, "SUPER + SHIFT + code:10 manquant")
    assertEq(movews.dsp._dsp, "hl.dsp.window.move", "dispatcher movetoworkspace")
    assertEq(movews.dsp._args[1].workspace, "1", "workspace cible")

    local altTab = findBind("ALT + CTRL + code:23")
    assertTrue(altTab ~= nil, "ALT + CTRL + code:23 manquant")
    assertTrue(altTab.opts and altTab.opts.repeating, "ALT + CTRL + code:23 doit répéter")
    assertTrue(contains(altTab.dsp._args[1], "cyclenext visible next"), "cyclenext visible next")

    local media = findBind("XF86AudioRaiseVolume")
    assertTrue(media ~= nil, "touche média manquante")
    assertTrue(media.opts and media.opts.locked and media.opts.repeating, "opts bindle (locked+repeating)")

    local drag = findBind("SUPER + mouse:272")
    assertTrue(drag ~= nil and drag.dsp._dsp == "hl.dsp.window.drag", "bind souris drag manquant")
    assertTrue(drag.opts and drag.opts.mouse, "opts mouse pour mouse:272")
end)

-- 5. binds.lua : submaps
test("submaps: ESCAPE et catchall", function()
    loadAll()
    for _, name in ipairs({ "WINDOWS", "GROUPS", "SOUND", "POWER" }) do
        local esc = findBind("ESCAPE", name)
        assertTrue(esc ~= nil, "ESCAPE manquant dans " .. name)
        assertTrue(type(esc.dsp) == "function", "ESCAPE doit être une fonction (wrapper)")
        clearRecords("dispatch")
        esc.dsp()
        assertEq(calls.dispatch[#calls.dispatch]._dsp, "hl.dsp.submap", "ESCAPE doit réinitialiser le submap")
        assertEq(calls.dispatch[#calls.dispatch]._args[1], "reset", "ESCAPE -> submap reset")
    end

    local catchalls = 0
    for _, b in ipairs(calls.binds) do
        if b.catchall then
            catchalls = catchalls + 1
            assertTrue(b.submap ~= nil, "catchall hors submap: " .. b.keys)
        end
    end
    assertEq(catchalls, 4, "nombre de catchall (WINDOWS/GROUPS/SOUND/POWER)")
end)

-- 5b. submaps: contournement du bug catchall 0.55.x (issue #15063)
test("submaps: catchall silencieux après une touche connue", function()    loadAll()
    local h = findBind("h", "WINDOWS")
    local catch = findBind("catchall", "WINDOWS")
    assertTrue(h ~= nil and type(h.dsp) == "function", "bind h manquant")
    assertTrue(catch ~= nil and type(catch.dsp) == "function", "bind catchall manquant")

    -- touche inconnue seule -> notification
    clearRecords("exec", "dispatch")
    catch.dsp()
    assertTrue(#calls.exec > 0 and contains(calls.exec[#calls.exec], "Submap WINDOWS"),
        "notification attendue sur touche inconnue")

    -- touche connue puis catchall (même pression) -> silence, action passée
    clearRecords("exec", "dispatch")
    h.dsp()
    assertEq(calls.dispatch[#calls.dispatch]._dsp, "hl.dsp.focus", "l'action du bind doit passer")
    clearRecords("exec", "dispatch")
    catch.dsp()
    assertEq(#calls.exec, 0, "pas de notification après une touche connue")

    -- le catchall réarme le marqueur
    catch.dsp()
    assertTrue(#calls.exec > 0, "notification à nouveau si aucune touche connue entre-temps")
end)

-- 5c. submaps: touches modificatrices seules ignorées
test("submaps: touches modificatrices silencieuses", function()
    loadAll()
    local catch = findBind("catchall", "WINDOWS")
    assertTrue(catch ~= nil and type(catch.dsp) == "function", "bind catchall manquant")

    for _, key in ipairs({ "Shift_L", "Shift_R", "Control_L", "Alt_L", "Super_L", "Super_R", "ISO_Level3_Shift" }) do
        local mod = findBind(key, "WINDOWS")
        assertTrue(mod ~= nil, "bind modificateur manquant: " .. key)
        clearRecords("dispatch")
        mod.dsp()
        assertEq(#calls.dispatch, 0, "une touche modificatrice ne doit rien déclencher: " .. key)
        clearRecords("exec", "dispatch")
        catch.dsp()
        assertEq(#calls.exec, 0, "pas de notification pour une touche modificatrice: " .. key)
    end
end)

-- 5d. submaps: aide "?" et CLEAN passant
test("submaps: bind ? et CLEAN passant", function()
    loadAll()
    for _, name in ipairs({ "WINDOWS", "GROUPS", "SOUND", "POWER" }) do
        local q = findBind("SHIFT + code:57", name)
        assertTrue(q ~= nil, "bind ? manquant dans " .. name)
        assertTrue(q.opts == nil or not q.opts.repeating, "bind ? ne doit pas répéter")
        clearRecords("exec")
        q.dsp()
        local all = table.concat(calls.exec, "\n")
        assertTrue(contains(all, "hyprctl binds"), "liste des binds via hyprctl")
        assertTrue(contains(all, "notify-send"), "notification via l'opérateur swaync")
        assertTrue(contains(all, name), "submap passé au filtre awk")

        local esc = findBind("ESCAPE", name)
        assertEq(esc.opts and esc.opts.description, "quitter le submap", "description ESCAPE")
        assertEq(q.opts and q.opts.description, "liste des binds", "description du bind ?")
    end

    assertEq(#submapBinds("CLEAN"), 6, "CLEAN: 6 binds (5 workspaces + F10)")
    for _, b in ipairs(submapBinds("CLEAN")) do
        assertTrue(b.keys ~= "ESCAPE" and not b.catchall and b.keys ~= "SHIFT + code:57",
            "CLEAN doit rester passant (aucun ESCAPE/?/catchall)")
    end

    local h = findBind("h", "WINDOWS")
    assertEq(h.opts and h.opts.description, "focus à gauche", "description du bind h")
    assertTrue(h.opts.repeating, "h doit être répétitif (binde d'origine)")
    local sh = findBind("SHIFT + h", "WINDOWS")
    assertTrue(not (sh.opts and sh.opts.repeating), "SHIFT + h ne doit pas répéter")
end)

-- 6. rules.lua
test("rules: fenêtres et workspaces", function()
    loadAll()
    local byName = {}
    for _, r in ipairs(calls.windowRules) do
        assertTrue(r.name ~= nil, "window rule sans nom")
        assertTrue(r.match ~= nil and r.match.class ~= nil, "match.class manquant pour " .. r.name)
        byName[r.name] = r
    end

    for _, expected in ipairs({ "disable-idle", "heroic", "steam", "steam-app", "citrix" }) do
        assertTrue(byName[expected], "window rule manquante: " .. expected)
    end

    local idle = byName["disable-idle"]
    assertEq(idle.idle_inhibit, "always", "idle_inhibit")
    assertEq(idle.match.class, "steam_app.*", "match class disable-idle")

    local citrix = byName["citrix"]
    assertEq(citrix.match.class, "Wfica", "match class citrix")
    assertTrue(citrix.tile == true, "citrix: tile")
    assertEq(citrix.monitor, "desc:AOC", "citrix: monitor")
    assertEq(citrix.workspace, 5, "citrix: workspace")

    assertEq(byName["heroic"].workspace, 4, "heroic: workspace")
    assertEq(byName["steam"].workspace, 4, "steam: workspace")
    assertEq(byName["steam-app"].monitor, "desc:AOC", "steam-app: monitor")
    assertEq(byName["steam-app"].workspace, 4, "steam-app: workspace")

    local wsBy = {}
    for _, w in ipairs(calls.workspaceRules) do wsBy[w.workspace] = w end
    assertEq(wsBy["1"].on_created_empty, "qutebrowser", "workspace 1")
    assertEq(wsBy["2"].on_created_empty, "kitty tmux new -As0", "workspace 2")
    assertEq(wsBy["3"].on_created_empty, "discord", "workspace 3")
end)

-- 7. events.lua : simulation des handlers window.active
test("events: simulation Citrix et StarCraft II", function()
    loadAll()

    stub.reset()
    clearUserModules()
    require("events")
    assertEq(#calls.events, 2, "deux handlers window.active")

    -- Citrix : entre en CLEAN une seule fois
    callWindowActiveHandlers({ class = "Wfica", title = "Citrix Workspace" })
    assertEq(#calls.dispatch, 1, "un dispatch CLEAN attendu")
    assertEq(calls.dispatch[1]._dsp, "hl.dsp.submap", "dispatch submap")
    assertEq(calls.dispatch[1]._args[1], "CLEAN", "submap CLEAN")
    callWindowActiveHandlers({ class = "Wfica", title = "toujours Citrix" })
    assertEq(#calls.dispatch, 1, "pas de dispatch répété tant que Citrix reste actif")

    -- Fenêtre normale : retour au submap par défaut
    callWindowActiveHandlers({ class = "kitty", title = "term" })
    assertEq(#calls.dispatch, 2, "un dispatch reset attendu")
    assertEq(calls.dispatch[2]._args[1], "reset", "submap reset")

    -- StarCraft II : layout 1
    clearRecords("exec", "dispatch")
    callWindowActiveHandlers({ class = "steam_app_default", title = "StarCraft II" })
    local all = table.concat(calls.exec, "\n")
    assertTrue(contains(all, "switchxkblayout current 1"), "layout 1 pour StarCraft II")

    -- Retour fenêtre normale : layout 0
    clearRecords("exec", "dispatch")
    callWindowActiveHandlers({ class = "kitty", title = "term" })
    all = table.concat(calls.exec, "\n")
    assertTrue(contains(all, "switchxkblayout current 0"), "retour layout 0")
end)

-- 8. extensions.lua : powerAction
test("powerAction: suspend, reboot, action inconnue", function()
    stub.reset()
    clearUserModules()
    local ext = require("extensions")

    assertEq(ext.shellQuote("a'b"), [['a'\''b']], "échappement shellQuote")

    ext.powerAction("suspend")
    assertEq(#calls.exec, 1, "notification info avant l'action")
    assertTrue(contains(calls.exec[1], "Suspension"), "titre de la notification")
    assertEq(#calls.timers, 1, "timer de délai")

    runTimers()
    assertEq(#calls.exec, 2, "commande d'action après timer")
    local cmd = calls.exec[2]
    assertTrue(contains(cmd, "systemctl suspend"), "systemctl suspend")
    assertTrue(contains(cmd, "hyprlock"), "hyprlock au réveil pour suspend")
    assertTrue(contains(cmd, "Échec: Suspension"), "notification d'échec")

    stub.reset()
    ext.powerAction("reboot")
    runTimers()
    cmd = calls.exec[2]
    assertTrue(contains(cmd, "systemctl reboot"), "systemctl reboot")
    assertTrue(not contains(cmd, "hyprlock"), "pas de hyprlock pour reboot")

    stub.reset()
    ext.powerAction("nimporte")
    assertTrue(contains(table.concat(calls.exec, "\n"), "powerAction"), "notification d'erreur pour action inconnue")
    assertTrue(contains(table.concat(calls.exec, "\n"), "-u critical"), "niveau erreur (critique)")
    assertEq(#calls.timers, 0, "pas d'action pour une commande inconnue")
end)

-- 9. Intégration : bind S du submap POWER
test("intégration: bind S du submap POWER", function()
loadAll()
    clearRecords("exec", "dispatch", "timers")

    local sBind = findBind("S", "POWER")
    assertTrue(sBind ~= nil, "bind S manquant dans POWER")
    assertTrue(type(sBind.dsp) == "function", "bind S doit être une fonction Lua")

    sBind.dsp()
    assertTrue(contains(table.concat(calls.exec, "\n"), "Suspension"), "powerAction(suspend) notifié")
    assertEq(#calls.timers, 1, "l'action est programmée via timer")
    assertEq(calls.dispatch[#calls.dispatch]._args[1], "reset", "retour au submap par défaut")
end)

print(("\n%d test(s) réussi(s), %d échoué(s)"):format(passCount, failCount))
if failCount > 0 then
    os.exit(1)
end