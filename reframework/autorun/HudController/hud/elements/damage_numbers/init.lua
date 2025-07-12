---@class (exact) DamageNumbers : DamageNumbersOffset, HudBase
---@field get_config fun(): DamageNumbersConfig
---@field GUI020020 app.GUI020020?
---@field previous_state table<via.gui.Control, {damage_state: app.GUI020020.State, critical_state: app.GUI020020.CRITICAL_STATE}>
---@field children {[string]: DamageNumbersCriticalState}

---@class (exact) DamageNumbersConfig : DamageNumbersOffsetConfig, HudBaseConfig
---@field children {[string]: DamageNumbersCriticalStateConfig}

local critical_state = require("HudController.hud.elements.damage_numbers.critical_state")
local data = require("HudController.data")
local game_data = require("HudController.util.game.data")
local hud_base = require("HudController.hud.def.hud_base")
local numbers_offset = require("HudController.hud.elements.damage_numbers.numbers_offset")
local util_game = require("HudController.util.game")
local util_table = require("HudController.util.misc.table")

local ace_enum = data.ace.enum
local mod = data.mod
local rl = game_data.reverse_lookup

---@class DamageNumbers
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args DamageNumbersConfig
---@return DamageNumbers
function this:new(args)
    local o = hud_base.new(self, args, nil, nil, true, true, function(a_key, b_key)
        if a_key == "ALL" then
            return true
        end

        if b_key == "ALL" then
            return false
        end
        return a_key < b_key
    end)
    setmetatable(o, self)
    numbers_offset.wrap(o, args)
    ---@cast o DamageNumbers

    o.previous_state = {}

    for _, state in pairs(ace_enum.critical_state) do
        o.children[state] = critical_state:new(args.children[state], o)
    end

    o.children.ALL = critical_state:new(args.children.ALL, o)

    return o
end

---@return app.GUI020020
function this:get_GUI020020()
    if not self.GUI020020 then
        self.GUI020020 = util_game.get_component_any("app.GUI020020")
    end

    return self.GUI020020
end

---@return via.gui.Panel[]
function this:get_all_panels()
    local ret = {}
    local arr = self:get_GUI020020()._DamageInfo
    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            table.insert(ret, value:get_field("<ParentPanel>k__BackingField") --[[@as via.gui.Panel]])
        end)
    end

    return ret
end

---@param active_only boolean?
---@return app.GUI020020.DAMAGE_INFO[]
function this:get_dmg(active_only)
    local ret = {}
    local arr = self:get_GUI020020()._DamageInfo
    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            if not active_only or value:get_field("<DispTimer>k__BackingField") > 0 then
                table.insert(ret, value)
            end
        end)
    end

    return ret
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.previous_state = {}
    self.pos_cache = {}
    util_table.do_something(self:get_all_panels(), function(_, _, value)
        self:reset_ctrl(value, key)
        local children_keys = self:get_children_keys()
        for i = 1, #children_keys do
            local child = self.children[children_keys[i]]
            if self.write_nodes[child] then
                ---@diagnostic disable-next-line: param-type-mismatch
                child:reset_child(nil, nil, value, key)
            end
        end
    end)
end

---@param hudbase app.GUI020020.DAMAGE_INFO
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control
function this:write(hudbase, gui_id, ctrl)
    self:_reset_on_state(hudbase, ctrl)
    self:adjust_offset(hudbase)

    ---@diagnostic disable-next-line: param-type-mismatch
    hud_base.write(self, hudbase, gui_id, ctrl)
end

---@return DamageNumbersConfig
function this.get_config()
    local base = hud_base.get_config(rl(ace_enum.hud, "DAMAGE_NUMBERS"), "DAMAGE_NUMBERS") --[[@as DamageNumbersConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.DAMAGE_NUMBERS
    base.box = { x = 0, y = 0, w = 0, h = 0 }
    base.enabled_box = false

    for _, state in pairs(ace_enum.critical_state) do
        base.children[state] = critical_state.get_config(state)
    end
    children.ALL = critical_state.get_config("ALL")

    return base
end

---@param hudbase app.GUI020020.DAMAGE_INFO
---@param ctrl via.gui.Control
function this:_reset_on_state(hudbase, ctrl)
    local dmg_state = hudbase:get_field("<State>k__BackingField") --[[@as app.GUI020020.State]]
    local crit_state = hudbase:get_field("<criticalState>k__BackingField") --[[@as app.GUI020020.CRITICAL_STATE]]

    if not self.previous_state[ctrl] then
        self.previous_state[ctrl] = {
            damage_state = dmg_state,
            critical_state = crit_state,
        }
    elseif
        self.previous_state[ctrl] and self.previous_state[ctrl].damage_state ~= dmg_state
        or self.previous_state[ctrl].critical_state ~= crit_state
    then
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children.ALL:reset_child(nil, nil, ctrl)
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children[ace_enum.critical_state[self.previous_state[ctrl].critical_state]]:reset_child(nil, nil, ctrl)
        self.previous_state[ctrl].damage_state = dmg_state
        self.previous_state[ctrl].critical_state = crit_state
    end
end

return this
