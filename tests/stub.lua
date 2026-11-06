-- Mock de l'API `hl` de Hyprland pour tester la configuration hors du compositeur.
-- Toutes les fonctions valident leurs arguments comme Hyprland (erreurs fatales
-- dans les tests) et enregistrent les appels dans M.calls.
local M = {}

M.calls = {
    config         = {},
    binds          = {},
    submaps        = {},
    events         = {},
    windowRules    = {},
    workspaceRules = {},
    monitors       = {},
    exec           = {},
    dispatch       = {},
    timers         = {},
    env            = {},
}

M.state = { currentSubmap = nil }

function M.reset()
    for _, list in pairs(M.calls) do
        for i = #list, 1, -1 do list[i] = nil end
    end
    M.state.currentSubmap = nil
end

local MODS = { SUPER = true, ALT = true, CTRL = true, SHIFT = true }

-- Même contrat que parseKeyString côté Hyprland : mods en premier, séparés par '+',
-- une seule touche finale, catchall réservé aux submaps.
local function parseKeys(keys)
    assert(type(keys) == "string", "hl.bind: les touches doivent être une string, reçu " .. type(keys))
    if keys == "catchall" then
        assert(M.state.currentSubmap ~= nil, "hl.bind: catchall interdit hors submap")
        return { catchall = true, mods = 0 }
    end

    local toks = {}
    for tok in keys:gmatch("[^+]+") do
        table.insert(toks, tok:match("^%s*(.-)%s*$"))
    end
    assert(#toks >= 1, "hl.bind: chaine de touches vide")

    local key = toks[#toks]
    assert(key ~= nil and #key > 0, "hl.bind: touche vide dans '" .. keys .. "'")
    assert(key:match("^[%w_:]+$"), "hl.bind: clé inconnue '" .. tostring(key) .. "' dans '" .. keys .. "'")
    for i = 1, #toks - 1 do
        assert(MODS[toks[i]],
            ("hl.bind: modificateur invalide ou mal placé '%s' dans '%s' (mods = SUPER/ALT/CTRL/SHIFT, séparés par +)")
                :format(tostring(toks[i]), keys))
    end
    return { catchall = false, mods = #toks - 1 }
end

local function dspNode(path)
    return setmetatable({ __dspPath = path }, {
        __index = function(_, k)
            return dspNode(path .. "." .. k)
        end,
        __call = function(_, ...)
            -- hl.dsp.X(args) crée un dispatcher ; comme dans Hyprland, il ne
            -- peut PAS être invoqué directement (hl.dispatch ou hl.bind only).
            local args = { ... }
            local d
            d = setmetatable({ _dsp = path, _args = args }, {
                __call = function()
                    error("dispatcher objects cannot be called directly; use hl.dispatch(dispatcher)", 2)
                end,
            })
            return d
        end,
    })
end

local hl = {}

hl.dsp = dspNode("hl.dsp")

function hl.bind(keys, dispatcher, opts)
    local parsed = parseKeys(keys)
    assert(type(dispatcher) == "function" or (type(dispatcher) == "table" and dispatcher._dsp),
        "hl.bind: dispatcher doit être hl.dsp.*() ou une fonction Lua")
    table.insert(M.calls.binds, {
        keys = keys, mods = parsed.mods,
        catchall = parsed.catchall, submap = M.state.currentSubmap, dsp = dispatcher, opts = opts,
    })
end

function hl.define_submap(name, fn)
    assert(type(name) == "string" and type(fn) == "function", "hl.define_submap: (name, function) requis")
    table.insert(M.calls.submaps, name)
    local prev = M.state.currentSubmap
    M.state.currentSubmap = name
    fn()
    M.state.currentSubmap = prev
end

function hl.on(event, cb)
    assert(type(event) == "string" and type(cb) == "function", "hl.on: (event, function) requis")
    table.insert(M.calls.events, { event = event, cb = cb })
end

function hl.config(t)
    assert(type(t) == "table", "hl.config: table requise")
    table.insert(M.calls.config, t)
end

function hl.window_rule(spec)
    assert(type(spec) == "table", "hl.window_rule: table requise")
    table.insert(M.calls.windowRules, spec)
end

function hl.workspace_rule(spec)
    assert(type(spec) == "table" and type(spec.workspace) == "string", "hl.workspace_rule: workspace string requis")
    table.insert(M.calls.workspaceRules, spec)
end

function hl.monitor(spec)
    assert(type(spec) == "table" and type(spec.output) == "string", "hl.monitor: output string requis")
    table.insert(M.calls.monitors, spec)
end

function hl.exec_cmd(cmd)
    assert(type(cmd) == "string", "hl.exec_cmd: string requise, reçu " .. type(cmd))
    table.insert(M.calls.exec, cmd)
end

function hl.dispatch(d)
    assert(type(d) == "table" and d._dsp, "hl.dispatch: dispatcher hl.dsp.*() requis")
    table.insert(M.calls.dispatch, d)
    return { ok = true }
end

function hl.timer(cb, opts)
    assert(type(cb) == "function", "hl.timer: callback requise")
    assert(type(opts) == "table" and type(opts.timeout) == "number" and opts.timeout > 0,
        "hl.timer: opts.timeout (nombre > 0) requis")
    assert(opts.type == "repeat" or opts.type == "oneshot", 'hl.timer: opts.type = "repeat"|"oneshot"')
    table.insert(M.calls.timers, { cb = cb, opts = opts })
    return {}
end

function hl.env(name, value)
    assert(type(name) == "string" and type(value) == "string", "hl.env: (string, string) requis")
    table.insert(M.calls.env, { name = name, value = value })
end

-- Tout appel à une API non mockée fait échouer le test (au lieu d'un silence).
setmetatable(hl, {
    __index = function(_, k)
        error("stub: hl." .. tostring(k) .. " n'est pas mocké, ajoute-le à tests/stub.lua", 2)
    end,
})

M.hl = hl
return M