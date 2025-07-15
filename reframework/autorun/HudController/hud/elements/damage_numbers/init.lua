---@class (exact) DamageNumbers : DamageNumbersOffset, HudBase
---@field get_config fun(): DamageNumbersConfig
---@field GUI020020 app.GUI020020?
---@field state table<app.GUI020020.DAMAGE_INFO, {[string]: any}>
---@field written table<app.GUI020020.DAMAGE_INFO, boolean>
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

    o.state = {}
    o.written = {}

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
            table.insert(ret, self:get_state_value(value, "<ParentPanel>k__BackingField") --[[@as via.gui.Panel]])
        end)
    end

    return ret
end

---@return app.GUI020020.DAMAGE_INFO[]
function this:get_dmg()
    local arr = self:get_GUI020020()._DamageInfoList
    if arr then
        util_game.do_something(arr, function(system_array, index, value)
            if not self.written[value] then
                self:get_state_value(value, "<criticalState>k__BackingField", true)
                self:get_state_value(value, "<State>k__BackingField", true)
                self.written[value] = true
            end
        end)
    end

    return self.written
end

---@param key HudBaseWriteKey
function this:reset(key)
    if not self.initialized then
        return
    end

    self.state = {}
    self.written = {}
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
---@param field_name string
---@param clear boolean?
---@return any
function this:get_state_value(hudbase, field_name, clear)
    local t = self.state[hudbase]
    if not t then
        self.state[hudbase] = {}
        t = self.state[hudbase]
    end

    local ret = t[field_name]
    if clear or not ret then
        t[field_name] = hudbase:get_field(field_name)
        ret = t[field_name]
    end
    return ret
end

---@param hudbase app.GUI020020.DAMAGE_INFO
---@param gui_id app.GUIID.ID
---@param ctrl via.gui.Control?
function this:write(hudbase, gui_id, ctrl)
    local pnl_wrap = self:get_state_value(hudbase, "<PanelWrap>k__BackingField") --[[@as via.gui.Control]]
    ctrl = self:get_state_value(hudbase, "<ParentPanel>k__BackingField")

    if not pnl_wrap:get_Visible() then
        local crit_state = self:get_state_value(hudbase, "<criticalState>k__BackingField")
        local dmg_state = self:get_state_value(hudbase, "<State>k__BackingField")
        local crit_child = self.children[ace_enum.critical_state[crit_state]]
        local dmg_child = crit_child.children[ace_enum.damage_state[dmg_state]]

        self.children.ALL:reset_ctrl(ctrl)
        self.children.ALL.children.ALL:reset_ctrl(ctrl)
        self.children.ALL.children[ace_enum.damage_state[dmg_state]]:reset_ctrl(ctrl)

        crit_child:reset_ctrl(ctrl)
        crit_child.children.ALL:reset_ctrl(ctrl)
        dmg_child:reset_ctrl(ctrl)

        self.pos_cache[pnl_wrap] = nil
        self.written[hudbase] = nil
        return
    end

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

return this
