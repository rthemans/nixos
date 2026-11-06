-- Utilitaires partagés pour la configuration Hyprland.
local M = {}

function M.shellQuote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Opérateur de notification : "swaync" (popups en haut à droite, lisibles
-- même en fullscreen) ou "caelestia" (toasts compacts en bas à droite,
-- masqués en fullscreen sauf si utilities.toasts.fullscreen = "all").
-- Pour changer d'opérateur, modifier uniquement NOTIFY_OPERATOR.
local NOTIFY_OPERATOR = "swaync"

local NOTIFY_COMMANDS = {
    swaync = {
        send = function(level, title, message)
            local urgency = level == "error" and "critical" or "normal"
            return ("notify-send -u %s -t 10000 %s %s"):format(urgency, M.shellQuote(title), M.shellQuote(message))
        end,
        -- Variante où le message est déjà cité et évalué dans le shell (ex: "$MSG")
        sendQuoted = function(level, title, quotedMessage)
            local urgency = level == "error" and "critical" or "normal"
            return ("notify-send -u %s -t 10000 %s %s"):format(urgency, M.shellQuote(title), quotedMessage)
        end,
    },
    caelestia = {
        send = function(level, title, message)
            local icon = level == "error" and "error" or "info"
            return ("caelestia-shell ipc call toaster %s %s %s %s 2>/dev/null || true")
                :format(level, M.shellQuote(title), M.shellQuote(message), icon)
        end,
        sendQuoted = function(level, title, quotedMessage)
            local icon = level == "error" and "error" or "info"
            return ("caelestia-shell ipc call toaster %s %s %s %s 2>/dev/null || true")
                :format(level, M.shellQuote(title), quotedMessage, icon)
        end,
    },
}

function M.notify(level, title, message)
    hl.exec_cmd(NOTIFY_COMMANDS[NOTIFY_OPERATOR].send(level, title, message))
end

function M.notifySubmapHint(name)
    M.notify("info", "Submap " .. name,
        "Touche non reconnue — ESC pour revenir en arrière, ? pour la liste des binds")
end

local BINDS_LIST_AWK = [==[
function modnames(m,   s) {
    s = ""
    if (and(m, 1))  s = s "SHIFT + "
    if (and(m, 4))  s = s "CTRL + "
    if (and(m, 8))  s = s "ALT + "
    if (and(m, 64)) s = s "SUPER + "
    return s
}
/^\tmodmask:/     { mm = $2 }
/^\tsubmap:/      { cur = $2 }
/^\tkey:/         { key = $0; sub(/^\tkey: /, "", key) }
/^\tkeycode:/     { keycode = $2 }
/^\tdescription:/ { desc = $0; sub(/^\tdescription: /, "", desc) }
/^\tdispatcher:/  {
    if (cur == s && key != "catchall") {
        disp = key
        if (disp == "") disp = "code:" keycode
        else if (disp !~ / \+ /) disp = modnames(mm) disp
        if (desc != "") disp = disp " — " desc
        print disp
    }
}
]==]

function M.showBinds(name)
    local list = ("hyprctl binds | awk -v s=%s '%s'"):format(M.shellQuote(name), BINDS_LIST_AWK)
    local script = ('MSG=$(%s); %s')
        :format(list, NOTIFY_COMMANDS[NOTIFY_OPERATOR].sendQuoted(
            "info", "Submap " .. name .. " — ESC pour revenir", '"$MSG"'))
    hl.exec_cmd("sh -c " .. M.shellQuote(script))
end

local ACTIONS = {
    reboot    = { title = "Redémarrage",  message = "La machine va redémarrer...",                cmd = "systemctl reboot" },
    hibernate = { title = "Hibernation",  message = "La machine va se mettre en hibernation...",  cmd = "systemctl hibernate", lockOnWake = true },
    suspend   = { title = "Suspension",   message = "La machine va se suspendre...",              cmd = "systemctl suspend",   lockOnWake = true },
    poweroff  = { title = "Extinction",   message = "La machine va s'éteindre...",                cmd = "systemctl poweroff" },
}

-- Remplace l'ancien Scripts/power-action.sh : notification info, action systemctl,
-- notification d'échec avec sortie, hyprlock au réveil (suspend/hibernate).
function M.powerAction(name)
    local action = ACTIONS[name]
    if not action then
        M.notify("error", "powerAction", "action inconnue: " .. tostring(name))
        return
    end

    M.notify("info", action.title, action.message)

    local script = {
        ("if ! OUTPUT=$(%s 2>&1); then"):format(action.cmd),
        ('  caelestia-shell ipc call toaster error %s "Erreur: $OUTPUT" error 2>/dev/null || true')
            :format(M.shellQuote("Échec: " .. action.title)),
    }
    if action.lockOnWake then
        table.insert(script, "else")
        table.insert(script, "  hyprlock")
    end
    table.insert(script, "fi")

    -- Laisse le temps à la notification de s'afficher avant l'action
    hl.timer(function()
        hl.exec_cmd("sh -c " .. M.shellQuote(table.concat(script, "\n")))
    end, { timeout = 1000, type = "oneshot" })
end

-- Touches modificatrices pressées seules : silencieuses dans les submaps
-- (pas de hint "ESC"), sans action.
local MODIFIER_KEYS = {
    "Shift_L", "Shift_R", "Control_L", "Control_R",
    "Alt_L", "Alt_R", "Super_L", "Super_R", "ISO_Level3_Shift",
}

-- Définit un submap avec :
--  - notification sur touche inconnue (contournement de la régression catchall
--    0.55.x, issue hyprwm/Hyprland#15063 : les binds connus marquent "géré",
--    le catchall ne notifie que si rien n'a été géré dans la même pression) ;
--  - ESCAPE pour revenir au submap par défaut ;
--  - "?" (SHIFT + code:57, la touche ' du bépo) pour afficher la liste détaillée
--    des binds. NB : Hyprland résout les keysyms des binds sans modificateurs
--    (état de translation dédié), donc les keysyms shiftés comme "question"
--    ne matchent jamais -> bind par keycode.
--  - touches modificatrices seules ignorées (pas de notification).
-- options : { catchall = false } pour tout désactiver (ex: submap CLEAN, qui
-- doit rester passant pendant une session Citrix).
function M.submap(name, binds, options)
    local opts = options or {}
    hl.define_submap(name, function()
        local handled = false

        for _, b in ipairs(binds) do
            local bindOpts = {}
            if b.opts then
                for k, v in pairs(b.opts) do bindOpts[k] = v end
            end
            if b.desc then bindOpts.description = b.desc end

            hl.bind(b.keys, function()
                handled = true
                if b.fn then
                    if type(b.fn) == "function" then
                        b.fn()
                    else
                        -- objet hl.dsp.* : interdit de l'appeler directement,
                        -- il faut passer par hl.dispatch
                        hl.dispatch(b.fn)
                    end
                end
            end, bindOpts)
        end

        if opts.catchall ~= false then
            for _, key in ipairs(MODIFIER_KEYS) do
                hl.bind(key, function() handled = true end)
            end

            hl.bind("ESCAPE", function()
                handled = true
                hl.dispatch(hl.dsp.submap("reset"))
            end, { description = "quitter le submap" })

            hl.bind("SHIFT + code:57", function()
                M.showBinds(name)
            end, { description = "liste des binds" })

            hl.bind("catchall", function()
                if not handled then
                    M.notifySubmapHint(name)
                end
                handled = false
            end)
        end
    end)
end

return M