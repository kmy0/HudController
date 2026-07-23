---@diagnostic disable: undefined-field, no-unknown, inject-field

local e = require("HudController.util.game.enum")
local migration_base = require("HudController.util.misc.migration_base")
local util_misc = require("HudController.util.misc.util")
local util_table = require("HudController.util.misc.table")

local this = migration_base.new("0.1.0")

---@param config MainSettings
function this.fns.lang(config)
    if config.gui.lang then
        config.mod.lang = util_table.deep_copy(config.gui.lang)
    end
end

---@param config MainSettings
function this.fns.keybinds(config)
    local pad_enum = e.get("ace.ACE_PAD_KEY.BITS")
    local kb_enum = e.get("ace.ACE_MKB_KEY.INDEX")

    if util_table.empty(pad_enum) or util_table.empty(kb_enum) then
        error("Bind Enum, not found. Please press Reset Scripts button.")
    end

    if config.mod.combo_hud then
        config.mod.combo.hud = config.mod.combo_hud
        config.mod.combo_hud = nil
    end

    if config.mod.bind.key.option then
        config.mod.bind.key.option_hud = config.mod.bind.key.option
        config.mod.bind.key.option = nil
    end

    for _, bind in
        pairs(config.mod.bind.key.hud --[==[@as ModBind[]]==])
    do
        bind.action_type = "NONE"
        bind.bound_value = bind.key
    end

    for _, bind in
        pairs(config.mod.bind.key.option_hud--[==[@as ModBind[]]==])
    do
        bind.action_type = "TOGGLE"
        bind.bound_value = bind.key
    end

    for _, name in pairs({ "hud", "option_hud" }) do
        for _, bind in
            pairs(config.mod.bind.key[name] --[==[@as Bind[]]==])
        do
            ---@type string[]
            local names = {}

            if bind.device == "PAD" then
                bind.keys = {}
                for _, key in
                    pairs(util_misc.extract_bits(bind.bit --[[@as integer]]))
                do
                    table.insert(bind.keys, key)
                    table.insert(names, pad_enum[key])
                end

                bind.name_display = table.concat(names, " + ")
                bind.bit = nil
                table.sort(bind.keys, function(a, b)
                    return pad_enum[a] < pad_enum[b]
                end)
            else
                for i = 1, #bind.keys do
                    table.insert(names, kb_enum[bind.keys[i]])
                end

                bind.name_display = bind.name
                table.sort(bind.keys, function(a, b)
                    return kb_enum[a] < kb_enum[b]
                end)
            end

            bind.name = table.concat(names, " + ")
        end
    end
end

return this
