---@class (exact) DamageNumbers : DamageNumbersOffset, HudBase
---@field get_config fun(): DamageNumbersConfig
---@field GUI020020 app.GUI020020[]?
---@field state table<app.GUI020020.DAMAGE_INFO, {[string]: any}>
---@field written table<app.GUI020020.DAMAGE_INFO, boolean>
---@field actual_written table<app.GUI020020.DAMAGE_INFO, boolean>
---@field children {[string]: DamageNumbersCriticalState}

---@class (exact) DamageNumbersConfig : DamageNumbersOffsetConfig, HudBaseConfig
---@field children {[string]: DamageNumbersCriticalStateConfig}

local critical_state = require("HudController.hud.elements.damage_numbers.critical_state")
local data = require("HudController.data.init")
local e = require("HudController.util.game.enum")
local hud_base = require("HudController.hud.def.hud_base")
local numbers_offset = require("HudController.hud.elements.damage_numbers.numbers_offset")
local util_game = require("HudController.util.game.init")
local util_table = require("HudController.util.misc.table")

local mod = data.mod

---@class DamageNumbers
local this = {}
---@diagnostic disable-next-line: inject-field
this.__index = this
setmetatable(this, { __index = hud_base })

---@param args DamageNumbersConfig
---@return DamageNumbers
function this:new(args)
    local o = hud_base.new(self, args, nil, nil, true, true, function(a_key, b_key)
        if a_key.name_key == "ALL" then
            return true
        end

        if b_key.name_key == "ALL" then
            return false
        end
        return a_key.name_key < b_key.name_key
    end)
    setmetatable(o, self)
    numbers_offset.wrap(o, args)
    ---@cast o DamageNumbers

    o.state = {}
    o.written = {}
    o.actual_written = {}

    for name, _ in e.iter("app.GUI020020.CRITICAL_STATE") do
        o.children[name] = critical_state:new(args.children[name], o)
    end

    o.children.ALL = critical_state:new(args.children.ALL, o)

    return o
end

---@return app.GUI020020[]
function this:get_GUI020020()
    if not self.GUI020020 then
        self.GUI020020 =
            util_game.system_array_to_lua(util_game.get_all_components("app.GUI020020"))
    end

    return self.GUI020020
end

---@return via.gui.Panel[]
function this:get_all_panels()
    local ret = {}
    util_table.do_something(self:get_GUI020020(), function(_, _, GUI020020)
        local arr = GUI020020._DamageInfo
        if arr then
            util_game.do_something(arr, function(_, _, value)
                table.insert(
                    ret,
                    self:get_state_value(value, "<ParentPanel>k__BackingField") --[[@as via.gui.Panel]]
                )
            end)
        end
    end)

    return ret
end

---@return table<app.GUI020020.DAMAGE_INFO, true>
function this:get_dmg()
    util_table.do_something(self:get_GUI020020(), function(_, _, GUI020020)
        local arr = GUI020020._DamageInfoList
        if arr then
            util_game.do_something(arr, function(_, _, value)
                if not self.written[value] then
                    self:get_state_value(value, "<criticalState>k__BackingField", true)
                    self:get_state_value(value, "<State>k__BackingField", true)
                    self.written[value] = true
                end
            end)
        end
    end)

    return self.written
end

---@return table<app.GUI020020.DAMAGE_INFO, true>
function this:get_dmg_static()
    util_table.do_something(self:get_GUI020020(), function(_, _, GUI020020)
        local arr = GUI020020._DamageInfo
        if arr then
            util_game.do_something(arr, function(_, _, value)
                if not self.written[value] then
                    local pnl_wrap = self:get_state_value(value, "<PanelWrap>k__BackingField") --[[@as via.gui.Control]]
                    if not pnl_wrap:get_Visible() then
                        return
                    end

                    self:get_state_value(value, "<criticalState>k__BackingField", true)
                    self:get_state_value(value, "<State>k__BackingField", true)
                    self.written[value] = true
                end
            end)
        end
    end)

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
    self.actual_written = {}
    util_table.do_something(self:get_all_panels(), function(_, _, value)
        self:reset_ctrl(value, key)
        ---@diagnostic disable-next-line: param-type-mismatch
        self:reset_children(nil, nil, value, key)
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
        self.pos_cache[pnl_wrap] = nil
        self.written[hudbase] = nil
        self.state[hudbase] = nil
        self.actual_written[hudbase] = nil

        if not self.actual_written[hudbase] then
            return
        end

        local crit_state = self:get_state_value(hudbase, "<criticalState>k__BackingField") --[[@as app.GUI020020.CRITICAL_STATE]]
        local dmg_state = self:get_state_value(hudbase, "<State>k__BackingField") --[[@as app.GUI020020.State]]
        local crit_child = self.children[e.get("app.GUI020020.CRITICAL_STATE")[crit_state]]
        local dmg_child = crit_child.children[e.get("app.GUI020020.State")[dmg_state]]

        self.children.ALL:reset_ctrl(ctrl)
        ---@diagnostic disable-next-line: param-type-mismatch
        self.children.ALL.children.ALL:reset_specific(nil, nil, ctrl)
        self.children.ALL.children[e.get("app.GUI020020.State")[dmg_state]]:reset_specific(
            ---@diagnostic disable-next-line: param-type-mismatch
            nil,
            ---@diagnostic disable-next-line: param-type-mismatch
            nil,
            ctrl
        )
        crit_child:reset_ctrl(ctrl)
        ---@diagnostic disable-next-line: param-type-mismatch
        crit_child.children.ALL:reset_specific(nil, nil, ctrl)
        ---@diagnostic disable-next-line: param-type-mismatch
        dmg_child:reset_specific(nil, nil, ctrl)

        return
    end

    self.actual_written[hudbase] = true
    self:adjust_offset(hudbase)
    ---@diagnostic disable-next-line: param-type-mismatch
    hud_base.write(self, hudbase, gui_id, ctrl)
end

---@return DamageNumbersConfig
function this.get_config()
    local base = hud_base.get_config(e.get("app.GUIHudDef.TYPE").DAMAGE_NUMBERS, "DAMAGE_NUMBERS") --[[@as DamageNumbersConfig]]
    local children = base.children

    base.hud_type = mod.enum.hud_type.DAMAGE_NUMBERS
    base.box = { x = 0, y = 0, w = 0, h = 0 }
    base.enabled_box = false

    for name, _ in e.iter("app.GUI020020.CRITICAL_STATE") do
        base.children[name] = critical_state.get_config(name)
    end
    children.ALL = critical_state.get_config("ALL")

    return base
end

return this
